public with sharing class DisclosureInventorDocumentService {
    public class InventorNotFoundException extends Exception {
    }
    public class NotSubmitterOfDisclosureFoundException extends Exception {
    }

    //** This needs to account for Inventor Downloading the document as well as a Submitter who submitted it for someone else.
    //*  in which case the submitter would not see the inventor Pagereference
    //******
    public static string getDisclosureInventorDocument(
        Id disclosureId,
        Id inventorId
    ) {
        System.debug(
            'DisclosureInventorDocumentService inventorId:- ' + inventorId
        );
        DisclosureInventor__c inventor = null;
        try {
            inventor = [
                SELECT
                    Id,
                    Name,
                    Disclosure__r.Id,
                    Signed_Status__c,
                    Inventor_Added_to_DocuSign_Envelope__c,
                    Disclosure__r.Signing_Envelop_Id__c
                FROM DisclosureInventor__c
                WHERE Id = :inventorId
                LIMIT 1
            ];
        } catch (System.QueryException e) {
            System.debug(
                'DisclosureInventorDocumentService: no inventor found its the submitting person downloading the docs'
            );
            //TODO don't throw this for now
            // Disclosure__c disclsoureDetails = [SELECT Id, Submitting_Contact__r.Id
            //                                    FROM Disclosure__c
            //                                    WHERE Id = :disclosureId
            //                                    LIMIT 1];

            // if (disclsoureDetails.Submitting_Contact__r.Id != inventorId) {

            //    //throw new NotSubmitterOfDisclosureFoundException();
            // }
            // //nothing to do here for the inventorId let to go get the doc with a null inventorId it will fall though to the generate doc for us
            // //without the inventor page on it
        }

        System.debug(
            'DisclosureInventorDocumentService Inventor:- ' + inventor
        );

        String envelopeId = inventor != null
            ? inventor.Disclosure__r.Signing_Envelop_Id__c
            : null;
        System.debug(
            'DisclosureInventorDocumentService envelopeId:- ' + envelopeId
        );

        DocuSignService docuSignService = new DocuSignService();
        String docuSignedStatusForInventor = (envelopeId != null &&
            inventor.Inventor_Added_to_DocuSign_Envelope__c)
            ? docuSignService.getInventorSignedStatus(disclosureId, inventorId)
            : '';
        System.debug(
            'DisclosureInventorDocumentService docuSignedStatusForInventor:- ' +
            docuSignedStatusForInventor
        );

        /*
            Signed_Status__c == 'Yes' Can not be-used.
            because the Inventor could have just used the Native APP to sign the disclosure and immediately tries to download the Document.

            DocuSign may have already updated the flag to 'Yes' BUT our system is yet to download and saved the document to ContentVersion on SF. 
            .:. check DocuSign status, if signed or completed then
            First try to get the document from Content Version, then try to get the document directly from DocuSign 
                (we cannot download from DocuSign before they've signed 
                 because we might have initiated the document with DocuSign already, if so and its not signed we'd still get Doc on DocuSign without signiture.)

            ie: effectively means we only show the generate the document if its not yet been signed. 
        */
        String docPdfBase64 = '';
        try {
            if (
                docuSignedStatusForInventor?.toLowerCase() == 'signed' ||
                docuSignedStatusForInventor?.toLowerCase() == 'completed'
            ) {
                System.debug(
                    'DisclosureInventorDocumentService attempt get doc from SF or DocuSign itself.'
                );
                Blob inventorDoc = DisclosureInventorDocumentService.getInventorSignedDocument(
                    disclosureId,
                    inventorId
                );
                docPdfBase64 = EncodingUtil.base64Encode(inventorDoc);
            }
        } catch (Exception ex) {
            System.debug('Failed To Get Document for Inventor:- ' + ex);
            if (inventor != null && inventor.Signed_Status__c == 'Yes') {
                // We can not generate a document, it is marked as signed by DocuSign and needs to exist either in DocuSign Or Content Version
                HandleLogException.logException(ex);
                throw ex;
            }
        }

        // We dont have a document, generate it.
        if (docPdfBase64 == null || docPdfBase64 == '') {
            System.debug(
                'DisclosureInventorDocumentService We dont have a document, generate it.'
            );
            DisclosureWrapper disclosureWrapper = DisclosureDao.getDisclosureWrapperById(
                disclosureId,
                inventorId
            );
            Boolean includeCoverPage = (disclosureWrapper.disclosure.Status__c ==
                'Approved')
                ? true
                : false;
            docPdfBase64 = DocumentGenerationService.generate(
                disclosureWrapper.recordTypeDeveloperName,
                disclosureWrapper,
                includeCoverPage
            );
        }

        return docPdfBase64;
    }

    @TestVisible
    private static Blob getInventorSignedDocument(
        Id disclosureId,
        Id inventorId
    ) {
        ContentVersion cv = null;
        List<ContentDocumentLink> cdList = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE
                LinkedEntityId = :inventorId
                AND ContentDocumentId IN (
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE
                        IsLatest = TRUE
                        AND Document_Classification__c = 'Signed Disclosure'
                )
            LIMIT 1
        ];

        System.debug(
            'DisclosureInventorDocumentService cdList.isEmpty():- ' +
            cdList.isEmpty()
        );
        if (!cdList.isEmpty()) {
            ContentDocumentLink cdl = cdList[0];
            cv = [
                SELECT VersionData
                FROM ContentVersion
                WHERE
                    isLatest = TRUE
                    AND ContentDocumentId = :cdl.ContentDocumentId
                LIMIT 1
            ];
        }

        System.debug('DisclosureInventorDocumentService cv:- ' + cv);
        if (cv != null) {
            return cv.VersionData;
        } else {
            System.debug(
                'DisclosureInventorDocumentService call DocuSignService'
            );
            // Account for people who want to download the document immediately after signing before its been saved to Salesforce
            // download it directly from DocuSign. FetchInventorSignedDocJob Still needs to save the CV Blob at a later point in time
            // The doc will not always be on DocuSign as it gets Archieved on DocuSign
            DocuSignService docuSignService = new DocuSignService();
            Blob inventorDocBlob = docuSignService.getDocumentForInventor(
                disclosureId,
                inventorId
            );

            return inventorDocBlob;
        }
    }
}