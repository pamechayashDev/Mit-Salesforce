@IsTest
public class BioTangDocGenAPITest {
    @TestSetup
    static void setup(){
        TestSetup.defaultDocTemplatesConfiguration();
        TestSetup.defaultConfiguration();
    }

    @IsTest
    static void test_generateDocumentCellLine() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdSub = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('cellLine')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'CellLine-Joe',
            true,
            '900000001'
        );
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'Sample Inventor Submitted Disclosure for CellLine',
            'Inventor Submitted',
            cont
        );

        BioTang_Disclosure__c bioTangDisclosure = test_generateDocumentCommon(
            disclosure,
            recordTypeIdSub
        );
        SampleDataFactory.createCellLine('Test CellLine', bioTangDisclosure);

        Account inventorContact3 = SampleDataFactory.createContact(
            'Inventor3',
            true,
            '900000008'
        );
        DisclosureInventor__c inventor3 = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact3
        );
        SampleDataFactory.addInventorExtraQuestion(inventor3);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'api/disclosure-doc-gen/v1';
        req.httpMethod = 'GET';
        req.params.put('disclosureId', disclosure.Id);
        req.params.put('inventorId', inventor3.Id);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Test.setMock(
            HttpCalloutMock.class,
            new DocGenApiMock()
                .setInventorId(inventor3.Id)
                .setRaiseDocuSignException(true)
        );

        String result = DisclosureDocGenAPI.generateDocument();
        Test.stopTest();
    }

    @IsTest
    static void test_generateDocumentPlasmid() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdSub = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('plasmid')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Plasmid-Pete',
            true,
            '900000001'
        );
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'Sample Draft Disclosure for Plasmid',
            'Draft',
            cont
        );

        BioTang_Disclosure__c bioTangDisclosure = test_generateDocumentCommon(
            disclosure,
            recordTypeIdSub
        );
        SampleDataFactory.createPlasmid('Test Plasmid', bioTangDisclosure);
        performTest(disclosure);
    }

    @IsTest
    static void test_generateDocumentOtherMaterial() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdSub = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('otherMaterial')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'OtherMaterial-Odie',
            true,
            '900000001'
        );
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'Sample Draft Disclosure for OtherMaterial',
            'Draft',
            cont
        );

        BioTang_Disclosure__c bioTangDisclosure = test_generateDocumentCommon(
            disclosure,
            recordTypeIdSub
        );
        SampleDataFactory.createOtherMaterial(
            'Test OtherMaterial',
            bioTangDisclosure
        );
        performTest(disclosure);
    }

    @IsTest
    static void test_generateDocumentMouseStrain() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdSub = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('mouseStrain')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'MouseStrain-Mickey',
            true,
            '900000001'
        );
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'Sample Draft Disclosure for MouseStrain',
            'Draft',
            cont
        );

        BioTang_Disclosure__c bioTangDisclosure = test_generateDocumentCommon(
            disclosure,
            recordTypeIdSub
        );
        SampleDataFactory.createMouseStrain(
            'Test MouseStrain',
            bioTangDisclosure
        );
        performTest(disclosure);
    }

    @IsTest
    static void test_generateDocumentAntibody() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdSub = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('antibody')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Antibody-Andy',
            true,
            '900000001'
        );
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'Sample Draft Disclosure for Antibody',
            'Draft',
            cont
        );

        BioTang_Disclosure__c bioTangDisclosure = test_generateDocumentCommon(
            disclosure,
            recordTypeIdSub
        );
        SampleDataFactory.createAntibody('Test Antibody', bioTangDisclosure);
        performTest(disclosure);
    }

    static BioTang_Disclosure__c test_generateDocumentCommon(
        Disclosure__c disclosure,
        Id recordTypeIdSub
    ) {
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
        Account piContact = SampleDataFactory.createContact(
            'PI1',
            true,
            '900000006'
        );
        SampleDataFactory.createDisclosureExternalFunding(
            disclosure,
            'grantNum1',
            'AwardId1',
            piContact,
            'sponsor1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            disclosure,
            'Yes',
            'costObjectNumber1',
            'fundingDetails1'
        );
        Account dHeadContact = SampleDataFactory.createContact(
            'DepHead1',
            true,
            '900000007'
        );
        Department_Head__c departmentHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            dHeadContact
        );

        Account shipper = SampleDataFactory.createContact(
            'Shipper',
            true,
            '900000004'
        );
        Account pointOfContact = SampleDataFactory.createContact(
            'PointOfContact',
            true,
            '900000005'
        );

        BioTang_Disclosure__c bioTangDisclosure = SampleDataFactory.createBioTang(
            'Test BioTang',
            disclosure,
            recordTypeIdSub,
            pointOfContact,
            shipper
        );
        SampleDataFactory.createLabMaterials(
            'Lab Material 1',
            bioTangDisclosure
        );
        SampleDataFactory.createLabMaterials(
            'Lab Material 2',
            bioTangDisclosure
        );

        String subTypeName = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosById()
            .get(bioTangDisclosure.RecordTypeId)
            .getName();
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.PUBLICATION_MANUSCRIPTS,
            subTypeName + '1.docx',
            'docx',
            disclosure
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.PUBLICATION_MANUSCRIPTS,
            subTypeName + '2.docx',
            'docx',
            disclosure
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_' + subTypeName + '1.docx',
            'docx',
            disclosure
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_' + subTypeName + '2.docx',
            'docx',
            disclosure
        );
        SampleDataFactory.createCommercialInterest(disclosure);

        return bioTangDisclosure;
    }

    static void performTest(Disclosure__c disclosure) {
        List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsWithContactByDisclosureId(
            disclosure.Id
        );
        DisclosureInventor__c inventor = !inventors.isEmpty()
            ? inventors[0]
            : null;
        String inventorId = inventor != null ? inventor.Id : null;

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