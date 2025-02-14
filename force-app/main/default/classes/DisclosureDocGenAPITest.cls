@IsTest
public class DisclosureDocGenAPITest {
    @TestSetup
    static void makeData() {
        TestSetup.defaultConfiguration();
        ContactSampleDataFactory.createSampleContacts();
        TestSetup.defaultDocTemplatesConfiguration();
    }

    @IsTest
    static void testGetInventorPdfWhenNotSigned() {
        String disclosureTitle = 'testGetInventorPdfWhenNotSigned';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            true
        );

        DisclosureInventor__c inventor = [
            SELECT Id
            FROM DisclosureInventor__c
            WHERE
                Disclosure__c = :disclosure.Id
                AND Contact__r.MitId__pc = '900047497'
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'api/disclosure-doc-gen/v1';
        req.httpMethod = 'GET';
        req.params.put('disclosureId', disclosure.Id);
        req.params.put('inventorId', inventor.Id);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Test.setMock(
            HttpCalloutMock.class,
            new DocGenApiMock().setRaiseDocuSignException(true)
        );

        String result = DisclosureDocGenAPI.generateDocument();
        Test.stopTest();

        System.assertEquals(
            PdfGeneratorApiMock.body,
            result,
            'Body Should be generated one from API'
        );
    }

    @IsTest
    static void testGetInventorPdfWhenSigned() {
        String disclosureTitle = 'testGetInventorPdfWhenSigned';
        Disclosure__c d = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            true
        );

        Disclosure__c disclosure = [
            SELECT Id, Name__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];

        disclosure.Signing_Envelop_Id__c = '123456789';
        update disclosure;

        // Account mitInventor = [SELECT Id FROM Account WHERE  MitId__pc = '900047497'];
        DisclosureInventor__c inventor = [
            SELECT
                Id,
                Contact__r.Id,
                Contact__r.MoiraStatus__pc,
                Contact__r.PersonEmail,
                Contact__r.MitId__pc
            FROM DisclosureInventor__c
            WHERE
                Disclosure__c = :disclosure.Id
                AND Contact__r.MitId__pc = '900047497'
            LIMIT 1
        ];

        inventor.DocuSign_Recipient_StatusCode__c = 'Completed';
        inventor.Inventor_Added_to_DocuSign_Envelope__c = true;
        update inventor;

        String signedPdfFileContent = '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YW5zcGFyZW5jeS9DUy9EZXZpY2VSR0IvSSB0cnVlPj4vQ29udGVudHMgMiAwIFI+PgplbmRvYmoKCjQgMCBvYmoKPDwvVHlwZS9QYWdlcwovUmVzb3VyY2VzIDExIDAgUgovTWVkaWFCb3hbIDAgMCA1OTUgODQxIF0KL0tpZHNbIDEgMCBSIF0KL0NvdW50IDE+PgplbmRvYmoKCjEyIDAgb2JqCjw8L1R5cGUvQ2F0YWxvZy9QYWdlcyA0IDAgUgovT3BlbkFjdGlvblsxIDAgUiAvWFlaIG51bGwgbnVsbCAwXQovTGFuZyhlbi1aQSkKPj4KZW5kb2JqCgoxMyAwIG9iago8PC9DcmVhdG9yPEZFRkYwMDU3MDA3MjAwNjkwMDc0MDA2NTAwNzI+Ci9Qcm9kdWNlcjxGRUZGMDA0QzAwNjkwMDYyMDA3MjAwNjUwMDRGMDA2NjAwNjYwMDY5MDA2MzAwNjUwMDIwMDAzNjAwMkUwMDM0PgovQ3JlYXRpb25EYXRlKEQ6MjAyMjExMzAxMzAxMzUrMDInMDAnKT4+CmVuZG9iagoKeHJlZgowIDE0CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwNzA4OSAwMDAwMCBuIAowMDAwMDAwMDE5IDAwMDAwIG4gCjAwMDAwMDAyMTkgMDAwMDAgbiAKMDAwMDAwNzI1OCAwMDAwMCBuIAowMDAwMDAwMjM5IDAwMDAwIG4gCjAwMDAwMDYyMzEgMDAwMDAgbiAKMDAwMDAwNjI1MiAwMDAwMCBuIAowMDAwMDA2NDQ3IDAwMDAwIG4gCjAwMDAwMDY3OTQgMDAwMDAgbiAKMDAwMDAwNzAwMiAwMDAwMCBuIAowMDAwMDA3MDM0IDAwMDAwIG4gCjAwMDAwMDczNTcgMDAwMDAgbiAKMDAwMDAwNzQ1NCAwMDAwMCBuIAp0cmFpbGVyCjw8L1NpemUgMTQvUm9vdCAxMiAwIFIKL0luZm8gMTMgMCBSCi9JRCBbIDwzNTE0QjVBOTlCOTk5N0Q2MUE0NjMxOUE1RkE2ODI3RD4KPDM1MTRCNUE5OUI5OTk3RDYxQTQ2MzE5QTVGQTY4MjdEPiBdCi9Eb2NDaGVja3N1bSAvNDBENkEzRTlDQjQ4QjgxRkQ3MEI0RUFEMDY3NDZDOTQKPj4Kc3RhcnR4cmVmCjc2MjkKJSVFT0YK';

        Id inventorId = inventor.Id;
        Id cvDisclosureInventorRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get('DisclosureInventor')
            .getRecordTypeId();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'DocuSign_' + inventorId + '.pdf'; // Display name of the files
        cv.PathOnClient = 'DocuSign_' + inventorId + '.pdf';
        cv.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        cv.VersionData = EncodingUtil.base64Decode(signedPdfFileContent);
        cv.Document_Classification__c = 'Signed Disclosure';
        cv.RecordTypeId = cvDisclosureInventorRecordTypeId;

        insert cv; //Insert ContentVersion
        System.debug('ContentVersion inventorDocBlob Created');

        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ]
        .ContentDocumentId;
        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.LinkedEntityId = inventorId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc; //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'api/disclosure-doc-gen/v1';
        req.httpMethod = 'GET';
        req.params.put('disclosureId', disclosure.Id);
        req.params.put('inventorId', inventorId);

        RestContext.request = req;
        RestContext.response = res;

        DocuSignApiMock docuSignApiMock = new DocuSignApiMock();
        docuSignApiMock.inventorId = inventor.Id;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, docuSignApiMock);

        String result = DisclosureDocGenAPI.generateDocument();
        Test.stopTest();

        System.assertEquals(
            signedPdfFileContent,
            result,
            'Body Should be generated one from ContentVersion on SF now'
        );
    }
}