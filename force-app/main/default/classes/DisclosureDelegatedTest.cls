@isTest
public with sharing class DisclosureDelegatedTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @isTest
    public static void testDisclosureCannotBeDelegatedWhenInRejectStatus() {
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
        Account deptHeadContactDelegated = SampleDataFactory.createContact(
            'Scott',
            true,
            '12345680'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );

        Disclosure__c otherDraftSoftwareCode = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code Disclosure2',
            'Draft',
            submittingContact
        );
        Department_Head__c deptHeadMit = SampleDataFactory.createDepartmentHead(
            otherDraftSoftwareCode,
            mitContact
        ); // Delegate to existing Department Head listed on other case

        Disclosure__c newDraftSoftwareCodeDisclosureSample = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code Disclosure',
            'Draft',
            submittingContact
        );
        Department_Head__c deptHeadForDelegationAfterRejectionTest = SampleDataFactory.createDepartmentHead(
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
            'Sample Draft Software Code Disclosure',
            newDraftSoftwareCodeDisclosureSample
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

        newDraftSoftwareCodeDisclosureSample.Status__c = 'Pending Department Approval';
        update newDraftSoftwareCodeDisclosureSample;

        newDraftSoftwareCodeDisclosureSample.Rejected_By__c = 'Department Head';
        newDraftSoftwareCodeDisclosureSample.Rejection_Reason__c = 'Rejected for unit tests';
        newDraftSoftwareCodeDisclosureSample.Status__c = 'Rejected';
        update newDraftSoftwareCodeDisclosureSample;

        Department_Head__c queryDepHead = [
            SELECT Id, Delegated_To__c, Disclosure__r.Status__c
            FROM Department_Head__c
            WHERE Id = :deptHeadForDelegationAfterRejectionTest.Id
        ];
        try {
            queryDepHead.Delegated_To__c = deptHeadMit.Id;
            update queryDepHead;
            // force test to fail as this delegation not allowed when Disclosure in Rejected Status
            System.assert(
                false,
                'You can only delegate to another dept head whn Disclosure in Draft Status. Thus error should have been thrown in this case. As test case moved Disclosure to Rejected before delegation.'
            );
        } catch (Exception error) {
            // test case should always fall into the exception (as this delegation not allowed when Disclosure in Rejected Status)
            // check that we do have an error thrown
            // and also check that the error specifically has custom validation error
            String msg = error.getMessage();
            System.assert(
                msg != null,
                'Exception should have a message associated with it'
            );
            System.assert(
                msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                'CUSTOM_VALIDATION_EXCEPTION should have been thrown. You can only delegate to another dept head for endorsement when Disclosure in Draft Status. And test case moved Disclosure to Rejected before delegation.'
            );
        }
        Test.stopTest();
    }

    @isTest
    public static void draftDisclosureDelegatedTest() {
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
        Account deptHeadContactDelegated = SampleDataFactory.createContact(
            'Scott',
            true,
            '12345680'
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
        Department_Head__c deptHead1 = SampleDataFactory.createDepartmentHead(
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

        try {
            Department_Head__c deptHeadEndorse = SampleDataFactory.createDepartmentHead(
                newDraftSoftwareCodeDisclosureSample,
                mitContact
            );
            deptHead1.Delegated_To__c = deptHeadEndorse.Id;
            update deptHead1;

            newDraftSoftwareCodeDisclosureSample.Status__c = 'Approved';
            update newDraftSoftwareCodeDisclosureSample;

            System.assert(
                false,
                'Delegated Department head can not be an Inventor ,Error not thrown'
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }

        // Delegate chain back to the Original Department head
        // Should be possible to delegate a disclosure back to one of the previous Dept. Heads
        Department_Head__c deptHead2 = SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            deptHeadContactDelegated
        );
        deptHead1.Delegated_To__c = deptHead2.Id;
        update deptHead1;

        Department_Head__c deptHeadOriginal = SampleDataFactory.createDepartmentHead(
            newDraftSoftwareCodeDisclosureSample,
            deptHeadContact
        );
        deptHead2.Delegated_To__c = deptHeadOriginal.Id;
        update deptHead2;

        Test.stopTest();
    }

    @isTest
    public static void draftDisclosureDelegatedSuccessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PdfGeneratorApiMock());

        SampleDataFactory.createSoftwareCodeDocumentTemplate();

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
        Account deptHeadContactDelegated = SampleDataFactory.createContact(
            'Scott',
            true,
            '12345680'
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
        Department_Head__c deptHeadFirst = SampleDataFactory.createDepartmentHead(
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

        try {
            /*
            Clone the Endorsement. Set the parent Disclosure, and update the Delegate_To chain
            */
            Department_Head__c deptHeadEndorse = SampleDataFactory.createDepartmentHead(
                newDraftSoftwareCodeDisclosureSample,
                deptHeadContactDelegated
            );
            deptHeadFirst.Delegated_To__c = deptHeadEndorse.Id;
            update deptHeadFirst;

            Department_Head__c deptHeadTest = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                newDraftSoftwareCodeDisclosureSample.Id
            )[0];

            System.assert(
                deptHeadTest.Id == deptHeadEndorse.Id,
                'Disclosure Department Head should be the new Department Head'
            );
            System.assert(
                deptHeadTest.Delegated_To__c == null,
                'Delegated To must be null, this is now child node'
            );
            System.assert(
                deptHeadTest.Contact__r.PersonDepartment != null,
                'Contact Department should not be null'
            );
            System.assert(
                deptHeadTest.Disclosure__c != null,
                'Disclosure should not be null'
            );
            System.assert(
                deptHeadTest.Signed_Date__c != null,
                'Signed Date should not be null'
            );
            System.assert(
                deptHeadTest.Contact__c != null,
                'Contact should not be null'
            );
            System.assert(
                deptHeadTest.Contact__r.PersonTitle != null,
                'Contact Title should not be null'
            );
            System.assert(
                deptHeadTest.Contact__c == deptHeadContactDelegated.Id,
                'Contact should matched Delegated To Contact'
            );

            Department_Head__c parentDeptHead = [
                SELECT Id, Delegated_To__c
                FROM Department_Head__c
                WHERE Id = :deptHeadFirst.Id
                LIMIT 1
            ];

            System.assert(
                parentDeptHead.Delegated_To__c == deptHeadTest.Id,
                'Delegated To Parent Child Relationship not valid '
            );

            newDraftSoftwareCodeDisclosureSample.Status__c = 'Pending Department Approval';
            update newDraftSoftwareCodeDisclosureSample;

            newDraftSoftwareCodeDisclosureSample.Status__c = 'Inventor Submitted';
            update newDraftSoftwareCodeDisclosureSample;

            newDraftSoftwareCodeDisclosureSample.Status__c = 'Approved';
            update newDraftSoftwareCodeDisclosureSample;

            System.assert(true, 'Success');
        } catch (Exception error) {
            System.assert(false, error.getMessage());
        }

        List<Department_Head__c> result = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
            newDraftSoftwareCodeDisclosureSample.Id
        );
        for (Department_Head__c deptHead : result) {
            if (deptHead.Delegated_To__c != null) {
                System.assert(
                    deptHead.Delegated_To__r.Contact__r.MitId__pc == '12345680',
                    'Delegated To Not Found'
                );
            }
        }
        Test.stopTest();
    }
}