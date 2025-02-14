@IsTest
public class DocumentGenerateEmbeddedSigningAPITest {
    private static String disclosureName = '';

    @TestSetup
    static void setupTestData() {
        TestSetup.defaultDocTemplatesConfiguration();
        TestSetup.defaultConfiguration();
    }

    @IsTest
    public static void testGenerateEmbeddedSigningUrl() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdCellLine = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('cellLine')
            .getRecordTypeId();

        Account inventorContact = SampleDataFactory.createContact(
            'Peter',
            true,
            '777777777'
        );
        Account mitShipperContact = SampleDataFactory.createContact(
            'John',
            false,
            '12345678'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );
        Account fundingPiContact = SampleDataFactory.createContact(
            'Henry',
            true,
            '23200'
        );

        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'Sample Draft BioTang',
            'Draft',
            inventorContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            disclosure,
            '12345',
            '6789',
            fundingPiContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            disclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(disclosure);
        BioTang_Disclosure__c newDraftBioSample = SampleDataFactory.createBioTang(
            'Sample Draft BioTang',
            disclosure,
            recordTypeIdCellLine,
            piContact,
            mitShipperContact
        );
        SampleDataFactory.createCellLine('Cell Line Sample', newDraftBioSample);
        SampleDataFactory.createLabMaterials(
            'Lab Material 1',
            newDraftBioSample
        );
        SampleDataFactory.createLabMaterials(
            'Lab Material 2',
            newDraftBioSample
        );

        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );

        // Fake that envelop has been created and set against the disclosure
        Disclosure__c disclosureToUpdate = [
            SELECT Id
            FROM Disclosure__c
            WHERE Id = :disclosure.Id
        ];
        disclosureToUpdate.Signing_Envelop_Id__c = '123456789';
        update disclosureToUpdate;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'api/embedded-signing/v1';
        req.httpMethod = 'GET';
        req.params.put('disclosureId', disclosure.Id);
        req.params.put('inventorId', inventor.Id);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DocuSignApiMock docuSignApiMock = new DocuSignApiMock();
        docuSignApiMock.inventorId = inventor.Id;

        Test.setMock(HttpCalloutMock.class, docuSignApiMock);

        String result = DocumentGenerateEmbeddedSigningAPI.generateEmbeddedSigningUrl();
        Map<String, Object> inventorSigningUrlMap = (Map<String, Object>) JSON.deserializeUntyped(
            result
        );
        String embeddedSigningUrlResponse = String.valueOf(
            inventorSigningUrlMap.get('url')
        );
        System.debug(
            'embeddedSigningUrlResponse: ' + embeddedSigningUrlResponse
        );
        Test.stopTest();

        String expectedStr = 'http://www.google.com';
        System.assertEquals(
            expectedStr,
            embeddedSigningUrlResponse,
            'Embedded URL should have been set correctly here.'
        );
    }
}