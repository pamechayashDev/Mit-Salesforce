@IsTest
public class InventionDocGenAPITest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }
    
    @IsTest
    static void test_generateDocumentInvention() {
        Id recordTypeIdInvention = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Invention_Disclosure')
            .getRecordTypeId();

        Account sampleContact1 = SampleDataFactory.createContact(
            'Peter',
            true,
            '777777777'
        );
        Account sampleContact2 = SampleDataFactory.createContact(
            'John',
            false,
            '12345678'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );

        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdInvention,
            'Sample Draft Disclosure for Invention',
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(disclosure, deptHeadContact);
        SampleDataFactory.createDisclosureExternalFunding(
            disclosure,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            disclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(disclosure);
        Invention_Disclosure__c inventionDraftSample = SampleDataFactory.createInvention(
            'Invention Disclosure Draft Sample',
            disclosure
        );
        SampleDataFactory.createThesis(
            'Thesis Sample for Invention Draft',
            inventionDraftSample
        );

        Account inventorContact1 = SampleDataFactory.createContact(
            'Inventor1',
            true,
            '900000002'
        );
        Account inventorContact2 = SampleDataFactory.createContact(
            'Inventor2',
            true,
            '900000003'
        );
        DisclosureInventor__c inventor1 = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact1
        );
        DisclosureInventor__c inventor2 = SampleDataFactory.createInventor(
            disclosure,
            false,
            inventorContact2
        );
        SampleDataFactory.addInventorExtraQuestion(inventor1);
        SampleDataFactory.addInventorExtraQuestion(inventor2);

        SampleDataFactory.createInventionDocumentTemplate();
        SampleDataFactory.createInventorDocumentTemplate();

        SampleDataFactory.createStyleDocumentTemplate();
        SampleDataFactory.createFooterDocumentTemplate();
        SampleDataFactory.createCoverPageDocumentTemplate();
        SampleDataFactory.createCoverPageFooterDocumentTemplate();

        performTest(disclosure, inventor1.Id);
    }

    static void performTest(Disclosure__c disclosure, Id inventorId) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'api/disclosure-doc-gen/v1';
        req.httpMethod = 'GET';
        req.params.put('disclosureId', disclosure.Id);
        req.params.put('inventorId', inventorId);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Test.setMock(
            HttpCalloutMock.class,
            new DocGenApiMock()
                .setInventorId(inventorId)
                .setRaiseDocuSignException(true)
        );

        String result = DisclosureDocGenAPI.generateDocument();
        Test.stopTest();
    }
}