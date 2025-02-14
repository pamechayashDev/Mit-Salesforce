@IsTest
public class DisclosureDaoTest {
    @TestSetup
    static void makeData() {
        System.debug('======makeData======');
        TestSetup.defaultConfiguration();
        ContactSampleDataFactory.createSampleContacts();

    }

    @isTest
    public static void DocumentSummaryTest() {
        String disclosureTitle = 'validateSummaryDocInfo';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            false
        );
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;

        disclosure.Status__c = 'Approved';
        disclosure.Case_Number__c = '1234';
        update disclosure;

        Test.startTest();

        DisclosureSummaryWrapper disclosureWrapper = DisclosureDao.getDisclosureSummaryWrapperById(
            disclosure.Id
        );
        System.assertEquals(
            '1234',
            disclosureWrapper.disclosure.Case_Number__c,
            'Case Number not set'
        );

        Account submittingContact = [
            SELECT Id, FirstName, MiddleName, LastName
            FROM Account
            WHERE MitId__pc = '12345678'
        ];

        String fullName = ContactNameUtil.toFullName(
            submittingContact.FirstName,
            submittingContact.MiddleName,
            submittingContact.LastName,
            true
        );

        System.assertEquals(
            fullName,
            disclosureWrapper.submittingContactFullName,
            'Submitting Contact Fullname not set'
        );
        System.assert(
            !String.isEmpty(disclosureWrapper.submittedDate),
            'Submitted Date not set'
        );

        Test.stopTest();
    }

    @IsTest
    static void getInventorByIdTest() {
        System.debug('======getInventorByIdTest======');
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
            'Sample Draft Disclosure for CellLine',
            'Draft',
            cont
        );

        DisclosureInventor__c inventor1 = generateDocumentCommonTest(
            disclosure,
            recordTypeIdSub
        );

        Test.startTest();

        DisclosureInventorWrapper inventorWrapper = DisclosureDao.getInventorById(
            disclosure.Id,
            inventor1.Id
        );

        Test.stopTest();

        System.assertEquals(inventor1.Id, inventorWrapper.inventor.Id);
    }

    static DisclosureInventor__c generateDocumentCommonTest(
        Disclosure__c disclosure,
        Id recordTypeIdSub
    ) {
        System.debug('======generateDocumentCommonTest======');
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

        return inventor1;
    }
}