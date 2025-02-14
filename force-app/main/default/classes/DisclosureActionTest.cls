@isTest
public with sharing class DisclosureActionTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }
    /**
     * If a Department Head delegates a disclosure to another Department Head,
     * the Disclosure Action against the first Department Head must be marked
     * as Complete and a new Disclosure Action must be created for the new
     * Department Head
     */
    @isTest
    public static void deptHeadDelegatedTest() {
        Test.startTest();

        // Create data for tests

        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account inventorContact = SampleDataFactory.createContact(
            'Inventor',
            true,
            '123456781'
        );
        Account piContact = SampleDataFactory.createContact(
            'PI',
            true,
            '123456784'
        );
        Account firstDeptHeadContact = SampleDataFactory.createContact(
            'DeptHead1',
            true,
            '123456782'
        );
        Account secondDeptHeadContact = SampleDataFactory.createContact(
            'DeptHead2',
            true,
            '123456783'
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Test Delegate Action',
            'Draft',
            submittingContact
        );
        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Test Delegate Action',
            disclosure
        );
        Department_Head__c firstDeptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            firstDeptHeadContact
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );

        // Update Disclosure with next status (submission)
        inventor.Signed_Status__c = 'Yes';
        update inventor;

        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        // Start tests
        try {
            // Assert Dept Head Action was created
            List<Disclosure_Action__c> firstDeptHeadActions = getDisclosureActionsByType(
                firstDeptHeadContact.Id,
                disclosure.Id,
                'Endorse_or_Delegate_Disclosure'
            );
            System.assert(
                !firstDeptHeadActions.isEmpty(),
                'Department Head Action was not created'
            );

            // Delegate Dept Head
            Department_Head__c secondDeptHead = SampleDataFactory.createDepartmentHead(
                disclosure,
                secondDeptHeadContact
            );
            firstDeptHead.Delegated_To__c = secondDeptHead.Id;
            update firstDeptHead;

            // Assert second Dept Head Action was created
            List<Disclosure_Action__c> secondDeptHeadActions = getDisclosureActionsByType(
                secondDeptHeadContact.Id,
                disclosure.Id,
                'Endorse_or_Delegate_Disclosure'
            );
            System.assert(
                !secondDeptHeadActions.isEmpty(),
                'Delegated Department Head Action was not created'
            );

            // Assert first Dept Head Action was Completed
            firstDeptHeadActions = getContactDisclosureActions(
                firstDeptHeadContact.Id
            );
            System.assert(
                !firstDeptHeadActions.isEmpty() &&
                firstDeptHeadActions[0].Contact_Action__r.Status__c ==
                'Completed',
                'Contact Action is not Complted, it is instead ' +
                firstDeptHeadActions[0].Contact_Action__r.Status__c
            );
        } catch (Exception error) {
            System.assert(false, error.getMessage());
        }
        Test.stopTest();
    }

    /**
     * If a Department Head Endorses a disclosure, the Disclosure Action
     * against the Department Head must be marked as Complete
     */
    @isTest
    public static void deptHeadEndorsedTest() {
        Test.startTest();

        // Create data for tests

        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account inventorContact = SampleDataFactory.createContact(
            'Inventor',
            true,
            '123456781'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'DeptHead1',
            true,
            '123456782'
        );
        Account piContact = SampleDataFactory.createContact(
            'PI',
            true,
            '123456784'
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Test Delegate Action',
            'Draft',
            submittingContact
        );
        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Test Delegate Action',
            disclosure
        );
        Department_Head__c deptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            deptHeadContact
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );

        // Update Disclosure with next status (submission)
        inventor.Signed_Status__c = 'Yes';
        update inventor;

        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        // Start tests
        try {
            // Assert Dept Head Action was created
            Disclosure_Action__c deptHeadAction = [
                SELECT Id, Contact_Action__r.Status__c
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Contact__c = :deptHeadContact.Id
                    AND Disclosure__c = :disclosure.Id
                    AND RecordType.DeveloperName = 'Endorse_or_Delegate_Disclosure'
            ];
            System.assert(
                deptHeadAction != null,
                'Department Head Action was not created'
            );

            // Endorse Disclosure (change to Inventor Submitted)
            disclosure.Status__c = 'Inventor Submitted';
            update disclosure;

            // Assert Dept Head Action was Completed
            deptHeadAction = [
                SELECT Id, Contact_Action__r.Status__c
                FROM Disclosure_Action__c
                WHERE Id = :deptHeadAction.Id
            ];
            System.assert(
                deptHeadAction.Contact_Action__r.Status__c == 'Completed',
                'Contact Action is not Complted, it is instead ' +
                deptHeadAction.Contact_Action__r.Status__c
            );
        } catch (Exception error) {
            System.assert(false, error.getMessage());
        }
        Test.stopTest();
    }

    /**
     * If a Department Head Rejects a disclosure, the Disclosure Action
     * against the Department Head must be marked as Complete
     */
    @isTest
    public static void deptHeadRejectedTest() {
        Test.startTest();

        // Create data for tests

        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account inventorContact = SampleDataFactory.createContact(
            'Inventor',
            true,
            '123456781'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'DeptHead1',
            true,
            '123456782'
        );
        Account piContact = SampleDataFactory.createContact(
            'PI',
            true,
            '123456784'
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Test Delegate Action',
            'Draft',
            submittingContact
        );
        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Test Delegate Action',
            disclosure
        );
        Department_Head__c deptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            deptHeadContact
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );

        // Update Disclosure with next status (submission)
        inventor.Signed_Status__c = 'Yes';
        update inventor;

        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        // Start tests
        try {
            // Assert Dept Head Action was created
            Disclosure_Action__c deptHeadAction = [
                SELECT Id, Contact_Action__r.Status__c
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Contact__c = :deptHeadContact.Id
                    AND Disclosure__c = :disclosure.Id
                    AND RecordType.DeveloperName = 'Endorse_or_Delegate_Disclosure'
            ];
            System.assert(
                deptHeadAction != null,
                'Department Head Action was not created'
            );

            // Endorse Disclosure (change to Inventor Submitted)
            disclosure.Status__c = 'Rejected';
            disclosure.Rejection_Reason__c = 'Test for rejection';
            disclosure.Rejected_By__c = 'Department Head';
            update disclosure;

            // Assert Dept Head Action was Canceled
            deptHeadAction = [
                SELECT Id, Contact_Action__r.Status__c
                FROM Disclosure_Action__c
                WHERE Id = :deptHeadAction.Id
            ];
            System.assert(
                deptHeadAction.Contact_Action__r.Status__c == 'Canceled',
                'Contact Action is not Canceled, it is instead ' +
                deptHeadAction.Contact_Action__r.Status__c
            );
        } catch (Exception error) {
            System.assert(false, error.getMessage());
        }
        Test.stopTest();
    }

    /**
     * When a Disclosure moves from the Draft stage, the Complete Draft Disclosure action
     * should be marked as "Completed"
     */
    @isTest
    public static void completeDraftDisclosureTest() {
        Test.startTest();

        // Create data for tests

        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account inventorContact = SampleDataFactory.createContact(
            'Inventor',
            true,
            '123456781'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'DeptHead1',
            true,
            '123456782'
        );
        Account piContact = SampleDataFactory.createContact(
            'PI',
            true,
            '123456784'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Test Delegate Action',
            'Draft',
            inventorContact
        );
        System.assertEquals(
            disclosure.SubmittedOnBehalf__c,
            false,
            'SOB (Submitted On Behalf) can not be false'
        );
        update disclosure;
        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Test Delegate Action',
            disclosure
        );
        Department_Head__c deptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            deptHeadContact
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );

        // Start Tests
        try {
            // Assert that the Submitting Inventor has a Complete Draft Disclosure action
            List<Disclosure_Action__c> submitterAction = [
                SELECT
                    Id,
                    Contact_Action__r.Status__c,
                    Contact_Action__r.Contact__r.PersonEmail,
                    Contact_Action__r.Contact__r.FirstName
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Contact__c = :inventorContact.Id
                    AND Disclosure__c = :disclosure.Id
                    AND RecordType.DeveloperName = 'Complete_Draft_Disclosure'
            ];
            System.assert(
                submitterAction != null,
                'Complete Draft Disclosure Action was not created'
            );
            System.assert(
                submitterAction.size() == 1,
                'only one Complete Draft Disclosure Action should have been created for the submitted'
            );

            // Update Disclosure with next status (submission)
            inventor.Signed_Status__c = 'Yes';
            update inventor;

            disclosure.Status__c = 'Pending Department Approval'; // 'Draft' --> 'Pending Department Approval'
            update disclosure;

            // Assert that the Complete Draft Disclosure is completed when the Disclosure status changes
            submitterAction = [
                SELECT Id, Contact_Action__r.Status__c
                FROM Disclosure_Action__c
                WHERE Id = :submitterAction[0].Id
            ];
            System.assert(
                submitterAction[0].Contact_Action__r.Status__c == 'Completed',
                'Complete Draft Disclosure Action should be marked as Compelted once the Disclosure leaves the Draft status'
            );
        } catch (Exception error) {
            System.assert(false, error.getMessage());
        }

        Test.stopTest();
    }

    /**
     * When a Department Head gets deleted, the pending actions should be removed
     */
    @isTest
    public static void deleteDepartmentHeadTest() {
        Test.startTest();

        // Create data for tests

        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account inventorContact = SampleDataFactory.createContact(
            'Inventor',
            true,
            '123456781'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'DeptHead1',
            true,
            '123456782'
        );
        Account piContact = SampleDataFactory.createContact(
            'PI',
            true,
            '123456784'
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Test Delegate Action',
            'Draft',
            submittingContact
        );
        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Test Delegate Action',
            disclosure
        );
        Department_Head__c deptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            deptHeadContact
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );

        // Update Disclosure with next status (submission)
        inventor.Signed_Status__c = 'Yes';
        update inventor;

        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        // Start tests
        try {
            // Assert Dept Head Action was created
            Disclosure_Action__c deptHeadAction = [
                SELECT Id, Contact_Action__r.Status__c
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Contact__c = :deptHeadContact.Id
                    AND Disclosure__c = :disclosure.Id
                    AND RecordType.DeveloperName = 'Endorse_or_Delegate_Disclosure'
            ];
            System.assert(
                deptHeadAction != null,
                'Department Head Action was not created'
            );

            // Delete Department Head
            delete deptHead;

            // Assert Department Head Action was Canceled
            deptHeadAction = [
                SELECT Id, Contact_Action__r.Status__c
                FROM Disclosure_Action__c
                WHERE Id = :deptHeadAction.Id
            ];
            System.assert(
                deptHeadAction.Contact_Action__r.Status__c == 'Canceled',
                'Department Head action should be Canceled when the Department Head is deleted, instead it is ' +
                deptHeadAction.Contact_Action__r.Status__c
            );
        } catch (Exception error) {
            System.assert(false, error.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testSignDisclosureWithPendingActions() {
        Test.startTest();
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account departmentHeadContact = SampleDataFactory.createContact(
            'Scott',
            true,
            '123456780'
        );
        Account inventorContact = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );
        Account nonMitInventorContact = SampleDataFactory.createContact(
            'Donald',
            false,
            null
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );

        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            'Title Of',
            'Draft',
            submittingContact
        );
        SampleDataFactory.createDepartmentHead(
            disclosure,
            departmentHeadContact
        );
        SampleDataFactory.createDisclosureInternalFunding(
            disclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(disclosure);
        Software_Code_Disclosure__c softwareCodeDisclosure = SampleDataFactory.createSoftwareCode(
            'Sample Inventor Submitted Software Code',
            disclosure
        );
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Software Code',
            null,
            softwareCodeDisclosure
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );
        SampleDataFactory.createInventor(
            disclosure,
            false,
            nonMitInventorContact
        );

        System.assert(
            inventor.Signed_Status__c == 'Pending',
            'Inventor Signed Disclosure Status must be Pending to start with'
        );

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;

        disclosure.Status__c = 'Approved';
        disclosure.Case_Number__c = '123425';
        update disclosure;

        List<Disclosure_Action__c> actions = getPendingSignedActions(
            disclosure
        );

        System.Assert(
            actions.size() == 2,
            'Two Sign Disclosure actions should have been created, one for each Inventor on the Disclosure'
        );

        // inventor signed
        inventor.Signed_Status__c = 'Yes';
        update inventor;

        List<Disclosure_Action__c> actionsAfter = getPendingSignedActions(
            disclosure
        );
        System.Assert(
            actionsAfter.size() == 1,
            'One Sign Disclosure action should have been removed, one Inventor Signed on the Disclosure'
        );

        Test.stopTest();
    }

    /*
     * Helper class for getting SignDisclosure Actions
     */
    private static List<Disclosure_Action__c> getPendingSignedActions(
        Disclosure__c disclosure
    ) {
        Id recordTypeIdSignDisclosure = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
            .get('Sign_Disclosure')
            .getRecordTypeId();
        List<Disclosure_Action__c> actions = [
            SELECT Id, Contact_Action__r.Id
            FROM Disclosure_Action__c
            WHERE
                Contact_Action__r.Status__c = 'Pending'
                AND Disclosure__c = :disclosure.Id
                AND RecordTypeId = :recordTypeIdSignDisclosure
        ];
        return actions;
    }

    /**
     * Helper class for getting all Disclosure Actions for a single Contact
     */
    private static List<Disclosure_Action__c> getContactDisclosureActions(
        Id contactId
    ) {
        List<Disclosure_Action__c> disclosureActionList = [
            SELECT Id, Contact_Action__r.Status__c
            FROM Disclosure_Action__c
            WHERE Contact_Action__r.Contact__c = :contactId
        ];

        return disclosureActionList;
    }

    /**
     * Helper class for getting Disclosure Actions for a single Contact,
     * Disclosure, and Record Type
     */
    private static List<Disclosure_Action__c> getDisclosureActionsByType(
        Id contactId,
        Id disclosureId,
        String recordTypeDevName
    ) {
        List<Disclosure_Action__c> disclosureActionList = [
            SELECT Id, Contact_Action__r.Status__c
            FROM Disclosure_Action__c
            WHERE
                Contact_Action__r.Contact__c = :contactId
                AND Disclosure__c = :disclosureId
                AND RecordType.DeveloperName = :recordTypeDevName
        ];

        return disclosureActionList;
    }
}