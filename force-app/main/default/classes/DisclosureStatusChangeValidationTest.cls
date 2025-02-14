@isTest
public class DisclosureStatusChangeValidationTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    public static Disclosure__c initDisclosure(String type, String status) {
        Account sampleContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '777777777'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );

        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get(type)
            .getRecordTypeId();
        Disclosure__c testDisclosure = new Disclosure__c(
            Name__c = 'Test Disclosure',
            Status__c = 'Draft',
            RecordTypeId = recordTypeId,
            Submitting_Contact__c = sampleContact.Id
        );
        insert testDisclosure;

        DisclosureInventor__c sampleInventor1 = new DisclosureInventor__c(
            MitAtTimeOfInvention__c = true,
            PrimaryInventor__c = true,
            Signed_Status__c = 'Pending',
            Contact__c = sampleContact.Id,
            Disclosure__c = testDisclosure.Id
        );

        insert sampleInventor1;
        Department_Head__c depHead = new Department_Head__c(
            Disclosure__c = testDisclosure.Id,
            Signed_Date__c = Date.newInstance(2020, 7, 7),
            Contact__c = deptHeadContact.Id
        );
        insert depHead;

        update new Disclosure__c(Id = testDisclosure.Id, Status__c = status);
        return testDisclosure;
    }

    @isTest
    public static void NullToDraftTest() {
        Test.startTest();
        Account sampleContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '777777777'
        );
        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Disclosure__c testDisclosure = new Disclosure__c(
            Name__c = 'Test Disclosure',
            RecordTypeId = recordTypeId,
            Submitting_Contact__c = sampleContact.Id
        );
        insert testDisclosure;

        Disclosure__c updated = [
            SELECT Id, Status__c
            FROM Disclosure__c
            WHERE Id = :testDisclosure.Id
        ];
        System.assert(
            updated.Status__c == 'Draft',
            'Disclosure__c Status should be Draft'
        );
        Test.stopTest();
    }

    @isTest
    public static void draftToInventorSubmittedTest() {
        Test.startTest();
        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Disclosure__c testDisclosure = initDisclosure('Software_Code_Disclosure', 'Draft');
        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            testDisclosure
        );
        Open_Source__c openSource = SampleDataFactory.createOpenSource(
            'Sample Open Source',
            null,
            softwareCode
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Marcus',
            true,
            '12345579'
        );

        Disclosure__c updatedDisclosure = [
            SELECT Id, Submitted_Date__c, Status__c
            FROM Disclosure__c
            WHERE Id = :testDisclosure.Id
        ];

        System.assert(
            updatedDisclosure.Submitted_Date__c == null,
            'Disclosure__c Submitted_Date__c should be null'
        );

        updatedDisclosure.Status__c = 'Inventor Submitted';

        update updatedDisclosure;

        Disclosure__c disclosureControl = [
            SELECT Id, Submitted_Date__c
            FROM Disclosure__c
            WHERE Id = :testDisclosure.Id
        ];

        System.assert(
            disclosureControl.Submitted_Date__c == Date.today(),
            'Disclosure__c Submitted_Date__c should be set to Todays date'
        );

        Test.stopTest();
    }

    @isTest
    public static void InventorSubmittedToApprovedTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PdfGeneratorApiMock());

        SampleDataFactory.createSoftwareCodeDocumentTemplate();

        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Disclosure__c testDisclosure = initDisclosure('Software_Code_Disclosure', 'Draft');

        Disclosure__c updatedDisclosure = [
            SELECT Id, Submitted_Date__c, Status__c
            FROM Disclosure__c
            WHERE Id = :testDisclosure.Id
        ];

        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            testDisclosure
        );
        Account contact = SampleDataFactory.createContact(
            'Marcus',
            true,
            '12345579'
        );
        
        updatedDisclosure.Status__c = 'Inventor Submitted';
        update updatedDisclosure;

        updatedDisclosure.Status__c = 'Approved';

        update updatedDisclosure;

        // Should be able to update TLO Office once disclosure is approved
        TLO_Officer__c tloOfficer = SampleDataFactory.createTLOOfficer(
            'MA',
            'Mary',
            '12345559'
        );
        updatedDisclosure.TLO_License_Officer__c = tloOfficer.Id;
        update updatedDisclosure;

        Disclosure__c disclosureControl = [
            SELECT Id, Submitted_Date__c
            FROM Disclosure__c
            WHERE Id = :testDisclosure.Id
        ];

        System.assert(
            disclosureControl.Submitted_Date__c == Date.today(),
            'Disclosure__c Submitted_Date__c should be set to Todays date'
        );

        Test.stopTest();
    }

   @isTest
    public static void approvedToInventorSubmittedTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PdfGeneratorApiMock());

        SampleDataFactory.createSoftwareCodeDocumentTemplate();

        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Disclosure__c testDisclosure = initDisclosure('Software_Code_Disclosure', 'Draft');

        Disclosure__c updatedDisclosure = [
            SELECT Id, Submitted_Date__c, Status__c
            FROM Disclosure__c
            WHERE Id = :testDisclosure.Id
        ];

        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            testDisclosure
        );
        Account contact = SampleDataFactory.createContact(
            'Marcus',
            true,
            '12345579'
        );

        updatedDisclosure.Status__c = 'Inventor Submitted';
        update updatedDisclosure;

        updatedDisclosure.Status__c = 'Approved';

        update updatedDisclosure;

        try {
            // Change Approve Disclosure back to Inventor Submitted
            updatedDisclosure.Status__c = 'Inventor Submitted';
            update updatedDisclosure;
            System.assert(false, 'Expecting exception for invalid flow transition');
        } catch (Exception error) {
           System.assert(true, error.getMessage());
        }



        Test.stopTest();
    }

    @isTest
    public static void InventorSubmittedToRejectedTest() {
        Test.startTest();
        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Disclosure__c testDisclosure = initDisclosure('Software_Code_Disclosure', 'Draft');

        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            testDisclosure
        );
        Account contact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '12345579'
        );
                testDisclosure.Status__c = 'Inventor Submitted';
        update testDisclosure;

        Disclosure__c updatedDisclosure = [
            SELECT Id, Submitted_Date__c, Status__c
            FROM Disclosure__c
            WHERE Id = :testDisclosure.Id
        ];

        updatedDisclosure.Status__c = 'Rejected';
        updatedDisclosure.Rejection_Reason__c = 'Sample Rejection Reason';
        updatedDisclosure.Rejected_By__c = 'TLO Admin';

        update updatedDisclosure;

        Disclosure__c disclosureControl = [
            SELECT Id, Submitted_Date__c
            FROM Disclosure__c
            WHERE Id = :testDisclosure.Id
        ];

        Test.stopTest();
    }

    @isTest
    public static void draftToAnyPrimaryInventorStaffMemberTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account nonMitContact = SampleDataFactory.createContact(
            'Parker',
            false,
            null
        );
        Account mitContact = SampleDataFactory.createContact(
            'Donald',
            true,
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

        Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            mitContact
        );
        SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newDraftSoftwareCodeDisclosureSample
        );
        Software_Code_Disclosure__c newDraftSoftwareCodeSample = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            newDraftSoftwareCodeDisclosureSample
        );
        Open_Source__c openSource = SampleDataFactory.createOpenSource(
            'Sample Open Source',
            null,
            newDraftSoftwareCodeSample
        );
        SampleDataFactory.createInventor(
            newDraftSoftwareCodeDisclosureSample,
            true,
            nonMitContact
        );

        Account contact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '12345579'
        );
        
        newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';

        try {
            update newDraftSoftwareCodeDisclosureSample;
            System.assert(
                false,
                'Primary Inventor must be MIT Staff Member, error not thrown.'
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void draftToAnyDepartmentHeadInventorStaffMemberTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account nonMitContact = SampleDataFactory.createContact(
            'Parker',
            false,
            null
        );
        Account mitContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            false,
            '12345679'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );

        Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            mitContact
        );
        SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            nonMitContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newDraftSoftwareCodeDisclosureSample
        );
        Software_Code_Disclosure__c newDraftSoftwareCodeSample = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            newDraftSoftwareCodeDisclosureSample
        );
        Open_Source__c openSource = SampleDataFactory.createOpenSource(
            'Sample Open Source',
            null,
            newDraftSoftwareCodeSample
        );
        SampleDataFactory.createInventor(
            newDraftSoftwareCodeDisclosureSample,
            true,
            mitContact
        );

        Account contact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '12345579'
        );
        
        newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';

        try {
            update newDraftSoftwareCodeDisclosureSample;
            System.assert(
                false,
                'Department Head must be MIT Staff Member, error not thrown.'
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void draftToAnyDepartmentHeadSameAsInventorTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account mitContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );

        Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            mitContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newDraftSoftwareCodeDisclosureSample
        );
        Software_Code_Disclosure__c newDraftSoftwareCodeSample = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            newDraftSoftwareCodeDisclosureSample
        );
        SampleDataFactory.createInventor(
            newDraftSoftwareCodeDisclosureSample,
            true,
            mitContact
        );

        Account contact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '12345579'
        );
        
        newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';

        try {
            SampleDataFactory.createDepartmentHead(
                newDraftSoftwareCodeDisclosureSample,
                mitContact
            );
            update newDraftSoftwareCodeDisclosureSample;
            System.assert(
                false,
                'Dept. Head cannot be one of the Inventors already listed on disclosure, error not thrown.'
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void draftToAnyInventorSameAsDepartmentHeadTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account nonMitContact = SampleDataFactory.createContact(
            'Parker',
            false,
            null
        );
        Account mitContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );
        Account sampleContact1 = SampleDataFactory.createContact(
            'Peter',
            true,
            '777777777'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );

        Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            mitContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newDraftSoftwareCodeDisclosureSample
        );
        Software_Code_Disclosure__c newDraftSoftwareCodeSample = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            newDraftSoftwareCodeDisclosureSample
        );
        Open_Source__c openSource = SampleDataFactory.createOpenSource(
            'Sample Open Source',
            null,
            newDraftSoftwareCodeSample
        );

        Account contact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '12345579'
        );
        
        newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';

        try {
            SampleDataFactory.createInventor(
                newDraftSoftwareCodeDisclosureSample,
                true,
                mitContact
            );
            update newDraftSoftwareCodeDisclosureSample;
            System.assert(
                false,
                'Inventor cannot be one of the Dept. Heads already listed on disclosure, error not thrown.'
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void draftToAnyOneDepartmentHeadTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account nonMitContact = SampleDataFactory.createContact(
            'Parker',
            false,
            null
        );
        Account mitContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Account mitContact2 = SampleDataFactory.createContact(
            'Peter',
            true,
            '12345677'
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

        Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            mitContact
        );
        SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            mitContact2
        );
        SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newDraftSoftwareCodeDisclosureSample
        );
        Software_Code_Disclosure__c newDraftSoftwareCodeSample = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            newDraftSoftwareCodeDisclosureSample
        );
        Open_Source__c openSource = SampleDataFactory.createOpenSource(
            'Sample Open Source',
            null,
            newDraftSoftwareCodeSample
        );
        SampleDataFactory.createInventor(
            newDraftSoftwareCodeDisclosureSample,
            true,
            mitContact
        );

        Account contact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '12345579'
        );
        
        newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';

        try {
            update newDraftSoftwareCodeDisclosureSample;
            System.assert(
                false,
                'Only 1 Department Head is allowed, error not thrown.'
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void draftToAnyPrimaryInventorCountTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account nonMitContact = SampleDataFactory.createContact(
            'Parker',
            false,
            null
        );
        Account mitContact = SampleDataFactory.createContact(
            'Donald',
            true,
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

        Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            mitContact
        );
        SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            mitContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newDraftSoftwareCodeDisclosureSample
        );
        Software_Code_Disclosure__c newDraftSoftwareCodeSample = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            newDraftSoftwareCodeDisclosureSample
        );
        Open_Source__c openSource = SampleDataFactory.createOpenSource(
            'Sample Open Source',
            null,
            newDraftSoftwareCodeSample
        );
        SampleDataFactory.createInventor(
            newDraftSoftwareCodeDisclosureSample,
            false,
            nonMitContact
        );

        Account contact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '12345579'
        );
        
        newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';

        try {
            update newDraftSoftwareCodeDisclosureSample;
            System.assert(
                false,
                'At least 1 Primary Inventor, error not thrown.'
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void draftToAnySuccessTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account nonMitContact = SampleDataFactory.createContact(
            'Parker',
            false,
            null
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Account mitContact = SampleDataFactory.createContact(
            'Donald',
            true,
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

        Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            submittingContact
        );
        SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newDraftSoftwareCodeDisclosureSample
        );
        Software_Code_Disclosure__c newDraftSoftwareCodeSample = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            newDraftSoftwareCodeDisclosureSample
        );
        Open_Source__c openSource = SampleDataFactory.createOpenSource(
            'Sample Open Source',
            null,
            newDraftSoftwareCodeSample
        );
        SampleDataFactory.createInventor(
            newDraftSoftwareCodeDisclosureSample,
            true,
            mitContact
        );
        SampleDataFactory.createInventor(
            newDraftSoftwareCodeDisclosureSample,
            false,
            nonMitContact
        );

        Account contact = SampleDataFactory.createContact(
            'John',
            true,
            '12345579'
        );

        newDraftSoftwareCodeDisclosureSample.Status__c = 'Pending Department Approval';
        update newDraftSoftwareCodeDisclosureSample;

        newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';
        newDraftSoftwareCodeDisclosureSample.Rejection_Reason__c = 'Sample Rejection Reason';
        newDraftSoftwareCodeDisclosureSample.Rejected_By__c = 'TLO Admin';

        try {
            update newDraftSoftwareCodeDisclosureSample;
            System.assert(true, 'Success');
        } catch (Exception error) {
            System.assert(false, error.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    public static void draftToAnySuccessPIContactTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account nonMitContact = SampleDataFactory.createContact(
            'Parker',
            false,
            null
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Account mitContact = SampleDataFactory.createContact(
            'Donald',
            true,
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

        Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            submittingContact
        );
        SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newDraftSoftwareCodeDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newDraftSoftwareCodeDisclosureSample
        );
        Software_Code_Disclosure__c newDraftSoftwareCodeSample = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            newDraftSoftwareCodeDisclosureSample
        );
        Open_Source__c openSource = SampleDataFactory.createOpenSource(
            'Sample Open Source',
            null,
            newDraftSoftwareCodeSample
        );
        SampleDataFactory.createInventor(
            newDraftSoftwareCodeDisclosureSample,
            true,
            mitContact
        );
        SampleDataFactory.createInventor(
            newDraftSoftwareCodeDisclosureSample,
            false,
            nonMitContact
        );
        // Can not change status from Draft to Rejected
        newDraftSoftwareCodeDisclosureSample.Status__c = 'Pending Department Approval';
        update newDraftSoftwareCodeDisclosureSample;
        //Dept. Head can be listed as PI on disclosure - Unlikely but is still possible.
        newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';
        newDraftSoftwareCodeDisclosureSample.Rejection_Reason__c = 'Sample Rejection Reason';
        newDraftSoftwareCodeDisclosureSample.Rejected_By__c = 'TLO Admin';

        try {
            update newDraftSoftwareCodeDisclosureSample;
            System.assert(true, 'Success');
        } catch (Exception error) {
            System.assert(false, error.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void approvedFromInsertTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        try {
            Account mitContact = SampleDataFactory.createContact(
                'Donald',
                true,
                '12345678'
            );
            Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosure(
                recordTypeIdSoftwareCode,
                'Sample Draft Disclosure for Software Code',
                'Approved',
                mitContact
            );
            System.assert(
                false,
                'Initial Disclosure with Approved Status, error not thrown '
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void draftToRejectedToDraftTest() {
        Test.startTest();
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        try {
            Account nonMitContact = SampleDataFactory.createContact(
                'Parker',
                false,
                null
            );
            Account mitContact = SampleDataFactory.createContact(
                'Donald',
                true,
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
            Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosure(
                recordTypeIdSoftwareCode,
                'Sample Draft Disclosure for Software Code',
                null,
                mitContact
            );

            SampleDataFactory.createDepartmentHead(
                newDraftSoftwareCodeDisclosureSample,
                deptHeadContact
            );
            SampleDataFactory.createDisclosureExternalFunding(
                newDraftSoftwareCodeDisclosureSample,
                '12345',
                '6789',
                piContact,
                'External Sponsor 1'
            );
            SampleDataFactory.createDisclosureInternalFunding(
                newDraftSoftwareCodeDisclosureSample,
                'Yes',
                '12345678',
                'Internal Funding 1'
            );
            SampleDataFactory.createCommercialInterest(
                newDraftSoftwareCodeDisclosureSample
            );
            Software_Code_Disclosure__c newDraftSoftwareCodeSample = SampleDataFactory.createSoftwareCode(
                'Sample Draft Software Code',
                newDraftSoftwareCodeDisclosureSample
            );
            Open_Source__c openSource = SampleDataFactory.createOpenSource(
                'Sample Open Source',
                null,
                newDraftSoftwareCodeSample
            );
            SampleDataFactory.createInventor(
                newDraftSoftwareCodeDisclosureSample,
                true,
                mitContact
            );
            SampleDataFactory.createInventor(
                newDraftSoftwareCodeDisclosureSample,
                false,
                nonMitContact
            );
            
            newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';
            update newDraftSoftwareCodeDisclosureSample;
            newDraftSoftwareCodeDisclosureSample.Status__c = 'Draft';
            update newDraftSoftwareCodeDisclosureSample;
            System.assert(
                false,
                'Disclosure with Rejected Status can not be updated, error not thrown '
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        Test.stopTest();
    }
}