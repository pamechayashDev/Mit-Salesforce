@IsTest
public with sharing class DisclosureInventorNotificationTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    private static Disclosure__c getDisclosureToTest(String title) {
        Disclosure__c disclosureToTest = [
            SELECT
                Id,
                Status__c,
                Name,
                Name__c,
                Case_Number__c,
                SubmittedOnBehalf__c,
                Submitting_Contact__c,
                Submitting_Contact__r.Id,
                Submitting_Contact__r.Name,
                Submitting_Contact__r.PersonEmail,
                Submitting_Contact__r.AltEmail__pc
            FROM Disclosure__c
            WHERE Name__c = :title
            LIMIT 1
        ];
        return disclosureToTest;
    }

    @IsTest
    static void testSignDisclosureRequiredNotification() {
        Test.startTest();
        String disclosureTitle = 'testSignDisclosureRequiredNotification';
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        RecordType swRecordType = [
            SELECT Name
            FROM RecordType
            WHERE ID = :recordTypeIdSoftware
            LIMIT 1
        ];

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
            disclosureTitle,
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
        SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
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
            'Inventor Signed Disclosure Flag need to be false'
        );

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;

        inventorContact.InvitationCode__pc = 'ABCD';
        update inventorContact;

        disclosure.Status__c = 'Approved';
        disclosure.Case_Number__c = '123425';
        update disclosure;

        // TODO -> Case Number changed (we are not sure if this is needed yet,
        // still to be confirmed in that we will use a different field on SF for case type updates and not the case number hack has Forrester/Mendix currently does)
        // currently you cannot edit a disclousre that has been approved
        // disclosure.Case_Number__c = '123425J';
        // update disclosure;

        List<Notification__c> notificationsForBobOnly = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                To__c = 'bob_sample@mit.edu'
                AND Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REQUIRED
        ];
        System.assert(
            notificationsForBobOnly.size() == 1,
            'Signature Required Notifications not Created for Bob.'
        );

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REQUIRED
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 2,
            'Two notifications should have been created, one for each Inventor on the Disclosure'
        );

        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);

        // Update contacts
        nonMitInventorContact = [
            SELECT Id, Name, PersonEmail, InvitationCode__pc
            FROM Account
            WHERE Id = :nonMitInventorContact.Id
        ];

        inventorContact = [
            SELECT Id, Name, PersonEmail, InvitationCode__pc
            FROM Account
            WHERE Id = :inventorContact.Id
        ];

        for (Notification__c n : testAllNotificationsCreated) {
            //nonMitInventorContact tests
            if (n.To__c == nonMitInventorContact.PersonEmail) {
                Map<String, Object> nVariableMap = NotificationBuilder.deserializeVariables(
                    n.Variables__c
                );
                System.debug('\n\nnVariableMap:- \n\n' + nVariableMap + '\n\n');

                System.assertEquals(
                    swRecordType.Name,
                    String.valueOf(nVariableMap.get('disclosure_type')),
                    'disclosure_type should be the Name of Software_Code_Disclosure'
                );
                System.assertEquals(
                    disclosureToTest.Name__c,
                    String.valueOf(nVariableMap.get('disclosure_title')),
                    'disclosure_title not correct'
                );
                System.assertEquals(
                    disclosureToTest.Name,
                    String.valueOf(nVariableMap.get('disclosure_name')),
                    'disclosure_name not correct'
                );

                //Submitted/Inventor
                System.assertEquals(
                    nonMitInventorContact.Name,
                    String.valueOf(nVariableMap.get('inventor_name')),
                    'inventor_name not correct'
                );
                System.assertEquals(
                    nonMitInventorContact.PersonEmail.toLowerCase(),
                    String.valueOf(nVariableMap.get('inventor_email')),
                    'inventor_email not correct'
                );

                System.assertEquals(
                    String.valueOf(nVariableMap.get('invitation_code')),
                    null,
                    'no invite for code nonMitInventorContact should exist'
                );

                System.assert(
                    String.valueOf(nVariableMap.get('isAlumni')).length() > 0,
                    'isAlumni missing'
                );
                System.assert(
                    String.valueOf(nVariableMap.get('case_number')).length() > 0,
                    'case_number missing'
                );
            }

            //inventorContact tests
            if (n.To__c == inventorContact.PersonEmail) {
                Map<String, Object> nnVariableMap = NotificationBuilder.deserializeVariables(
                    n.Variables__c
                );
                System.debug(
                    '\n\nnnVariableMap:- \n\n' + nnVariableMap + '\n\n'
                );

                System.assertEquals(
                    swRecordType.Name,
                    String.valueOf(nnVariableMap.get('disclosure_type')),
                    'disclosure_type should be the Name of Software_Code_Disclosure'
                );
                System.assertEquals(
                    disclosureToTest.Name__c,
                    String.valueOf(nnVariableMap.get('disclosure_title')),
                    'disclosure_title not correct'
                );
                System.assertEquals(
                    disclosureToTest.Name,
                    String.valueOf(nnVariableMap.get('disclosure_name')),
                    'disclosure_name not correct'
                );

                //Submitted/Inventor
                System.assertEquals(
                    inventorContact.Name,
                    String.valueOf(nnVariableMap.get('inventor_name')),
                    'inventor_name not correct'
                );
                System.assertEquals(
                    inventorContact.PersonEmail.toLowerCase(),
                    String.valueOf(nnVariableMap.get('inventor_email')),
                    'inventor_email not correct'
                );

                System.assert(
                    String.valueOf(nnVariableMap.get('invitation_code'))
                        .length() > 0,
                    'invite for code inventor should exist'
                );
                System.assertEquals(
                    inventorContact.InvitationCode__pc,
                    String.valueOf(nnVariableMap.get('invitation_code')),
                    'inventor_email not correct'
                );
            }
        }

        Test.stopTest();
    }

    @IsTest
    static void testRejectDepartmentHeadNotification() {
        Test.startTest();
        String disclosureTitle = 'testRejectDepartmentHeadNotification';
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account departmentHeadContact = SampleDataFactory.createContact(
            'Scott',
            true,
            '123456780'
        );
        // Get Name
        departmentHeadContact.Name = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :departmentHeadContact.Id
        ].Name;

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
        // Get Name
        submittingContact.Name = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :submittingContact.Id
        ].Name;

        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            disclosureTitle,
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
        SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
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

        DisclosureEnableWatchers.enableDraftWatchers(disclosure.Id);

        System.assert(
            inventor.Signed_Status__c == 'Pending',
            'Inventor Signed Disclosure Flag need to be false'
        );

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Rejected';
        disclosure.Rejection_Reason__c = 'Sample Rejection Reason';
        disclosure.Rejected_By__c = 'Department Head';
        update disclosure;

        // ============================
        //
        // ============================
        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);

        List<Notification__c> notificationsForBobOnly = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                To__c = 'bob_sample@mit.edu'
                AND Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD
        ];
        System.assert(
            notificationsForBobOnly.size() == 1,
            'Department Head Declined Notifications not Created for Bob.'
        );

        Notification__c declinedNotification = notificationsForBobOnly.get(0);
        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            declinedNotification.Variables__c
        );
        System.debug('\n\nvariableMap:- \n\n' + variableMap + '\n\n');

        System.assert(
            String.valueOf(variableMap.get('comments')).length() > 0,
            'Declined Reason Comments missing'
        );
        System.assertEquals(
            disclosure.Rejection_Reason__c,
            String.valueOf(variableMap.get('comments')),
            'comments not correct'
        );

        RecordType swRecordType = [
            SELECT Name
            FROM RecordType
            WHERE ID = :recordTypeIdSoftware
            LIMIT 1
        ];
        System.assertEquals(
            swRecordType.Name,
            String.valueOf(variableMap.get('disclosure_type')),
            'disclosure_type should be the Name of Software_Code_Disclosure'
        );

        System.assertEquals(
            submittingContact.Name,
            String.valueOf(variableMap.get('submitter_name')),
            'submitter_name not correct'
        );
        System.assertEquals(
            disclosureToTest.Name__c,
            String.valueOf(variableMap.get('disclosure_title')),
            'disclosure_title not correct'
        );
        System.assertEquals(
            disclosureToTest.Name,
            String.valueOf(variableMap.get('disclosure_name')),
            'disclosure_name not correct'
        );

        System.assertEquals(
            departmentHeadContact.Name,
            String.valueOf(variableMap.get('dlc_name')),
            'dept_head_name not correct'
        );

        // ============================
        //
        // ============================
        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 2,
            'Two notifications should have been created, one for Primary Inventor and Submitting Contact on the Disclosure'
        );

        Test.stopTest();
    }

    @IsTest
    static void testRejectTLOAdminNotification() {
        Test.startTest();
        String disclosureTitle = 'testRejectTLOAdminNotification';
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
        // Get Name
        inventorContact.Name = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :inventorContact.Id
        ].Name;

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
        // Get Name
        submittingContact.Name = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :submittingContact.Id
        ].Name;

        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            disclosureTitle,
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
        SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
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

        DisclosureEnableWatchers.enableDraftWatchers(disclosure.Id);

        System.assert(
            inventor.Signed_Status__c == 'Pending',
            'Inventor Signed Disclosure Flag need to be false'
        );

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;

        disclosure.Status__c = 'Rejected';
        disclosure.Rejection_Reason__c = 'Sample Rejection Reason';
        disclosure.Rejected_By__c = 'TLO Admin';
        update disclosure;

        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);
        RecordType swRecordType = [
            SELECT Name
            FROM RecordType
            WHERE ID = :recordTypeIdSoftware
            LIMIT 1
        ];

        List<Notification__c> notificationsForBobOnly = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                To__c = 'bob_sample@mit.edu'
                AND Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_REJECTION_TLO_ADMIN
        ];
        System.assert(
            notificationsForBobOnly.size() == 1,
            'Department Head Declined Notifications not Created for Bob.'
        );

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_REJECTION_TLO_ADMIN
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 2,
            'Two notifications should have been created, one for Primary Inventor and Submitting Contact on the Disclosure'
        );

        for (Notification__c n : testAllNotificationsCreated) {
            //submitter tests
            if (n.To__c == submittingContact.PersonEmail) {
                Map<String, Object> nVariableMap = NotificationBuilder.deserializeVariables(
                    n.Variables__c
                );
                System.debug('\n\nnVariableMap:- \n\n' + nVariableMap + '\n\n');

                //comments
                System.assert(
                    String.valueOf(nVariableMap.get('comments')).length() > 0,
                    'Declined Reason Comments missing'
                );
                System.assertEquals(
                    disclosure.Rejection_Reason__c,
                    String.valueOf(nVariableMap.get('comments')),
                    'comments not correct'
                );

                System.assertEquals(
                    swRecordType.Name,
                    String.valueOf(nVariableMap.get('disclosure_type')),
                    'disclosure_type should be the Name of Software_Code_Disclosure'
                );
                System.assertEquals(
                    disclosureToTest.Name__c,
                    String.valueOf(nVariableMap.get('disclosure_title')),
                    'disclosure_title not correct'
                );
                System.assertEquals(
                    disclosureToTest.Name,
                    String.valueOf(nVariableMap.get('disclosure_name')),
                    'disclosure_name not correct'
                );

                //Submitted/Inventor
                System.assertEquals(
                    submittingContact.Name,
                    String.valueOf(nVariableMap.get('inventor_name')),
                    'submitting_contact_name not correct'
                );
            }

            //inventor tests
            if (n.To__c == inventorContact.PersonEmail) {
                Map<String, Object> nnVariableMap = NotificationBuilder.deserializeVariables(
                    n.Variables__c
                );
                System.debug(
                    '\n\nnnVariableMap:- \n\n' + nnVariableMap + '\n\n'
                );

                //comments
                System.assert(
                    String.valueOf(nnVariableMap.get('comments')).length() > 0,
                    'Declined Reason Comments missing'
                );
                System.assertEquals(
                    disclosure.Rejection_Reason__c,
                    String.valueOf(nnVariableMap.get('comments')),
                    'comments not correct'
                );

                System.assertEquals(
                    swRecordType.Name,
                    String.valueOf(nnVariableMap.get('disclosure_type')),
                    'disclosure_type should be the Name of Software_Code_Disclosure'
                );
                System.assertEquals(
                    disclosureToTest.Name__c,
                    String.valueOf(nnVariableMap.get('disclosure_title')),
                    'disclosure_title not correct'
                );
                System.assertEquals(
                    disclosureToTest.Name,
                    String.valueOf(nnVariableMap.get('disclosure_name')),
                    'disclosure_name not correct'
                );

                //Submitted/Inventor
                System.assertEquals(
                    inventorContact.Name,
                    String.valueOf(nnVariableMap.get('inventor_name')),
                    'inventor_name not correct'
                );
            }
        }

        Test.stopTest();
    }

    @IsTest
    static void testNoInventorDeleteNotification() {
        Test.startTest();

        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
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
        delete disclosure;

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_DELETION
        ];

        System.Assert(
            testAllNotificationsCreated.size() == 0,
            'No draft delete notifications should have been created'
        );
        Test.stopTest();
    }

    @IsTest
    public static void testInventorDeleteNotification() {
        Test.startTest();

        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Account watcherInventorContact = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );
        Account inventorContact = SampleDataFactory.createContact(
            'Shane',
            true,
            '123456782'
        );

        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            'Title Of',
            'Draft',
            submittingContact
        );

        DisclosureInventor__c watcherInventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            watcherInventorContact
        );
        DisclosureEnableWatchers.enableDraftWatchers(disclosure.Id);
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );
        // DisclosureInventor has a master detail relationship and will be called when disclosure get deleted
        delete disclosure;

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_DELETION
        ];

        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'One draft delete notifications should have been created, one for Inventor'
        );

        Test.stopTest();
    }
    @IsTest
    static void testInventorNamedNotification() {
        Test.startTest();

        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Account inventorContact = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );

        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftware,
            'Title Of',
            'Draft',
            submittingContact
        );

        DisclosureInventor__c submittingInventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            submittingContact
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            false,
            inventorContact
        );

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DRAFT_REVIEW
        ];

        System.Assert(
            testAllNotificationsCreated.size() == 0,
            'Only when watcher is enabled should a notification be created'
        );
        Test.stopTest();
    }

    @IsTest
    static void testSubmitterApprovedNotificationsForOpenSource() {
        Test.startTest();

        String disclosureTitle = 'testSubmitterApprovedNotifications';
        ContactSampleDataFactory.createSampleContacts();
        Disclosure__c disclosureSOB = SoftwareDisclosuresSampleFactory.createDisclosure(
            disclosureTitle,
            false
        );

        disclosureSOB.Status__c = 'Inventor Submitted';
        update disclosureSOB;

        disclosureSOB.Status__c = 'Approved';
        disclosureSOB.Case_Number__c = '12345J';
        update disclosureSOB;

        Account submittingContact = [
            SELECT Id, Name
            FROM Account
            WHERE MitId__pc = '12345678'
        ];
        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);

        List<Notification__c> testTloApprovedNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTER_TLO_APPROVED
        ];
        System.Assert(
            testTloApprovedNotificationsCreated.size() == 0,
            'No tlo approved notifications should have been created, for Submitting Contact'
        );

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_AND_SUBMITTER_DEPT_TLO_APPROVED
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'One Opensource Dept Head endorsed and tlo approved notifications should have been created, for Submitting Contact'
        );

        Map<String, Object> variableMap = (Map<String, Object>) JSON.deserializeUntyped(
            testAllNotificationsCreated[0].Variables__c
        );
        System.debug('\n\nvariableMap:- \n\n' + variableMap + '\n\n');

        System.assert(
            String.valueOf(variableMap.get('case_number')).length() > 0,
            'case_number missing'
        );
        System.assertEquals(
            disclosureSOB.Case_Number__c,
            String.valueOf(variableMap.get('case_number')),
            'case_number not correct'
        );

        System.assertEquals(
            submittingContact.Name,
            String.valueOf(variableMap.get('submitter_name')),
            'submitter_name not correct'
        );
        System.assertEquals(
            disclosureToTest.Name__c,
            String.valueOf(variableMap.get('disclosure_title')),
            'disclosure_title not correct'
        );
        System.assertEquals(
            disclosureToTest.Name,
            String.valueOf(variableMap.get('disclosure_name')),
            'disclosure_name not correct'
        );

        Test.stopTest();
    }

    @IsTest
    static void testSubmitterApprovedNotificationsForNonOpenSource() {
        Test.startTest();

        ContactSampleDataFactory.createSampleContacts();

        Account submittingContact1 = [
            SELECT Id, Name
            FROM Account
            WHERE MitId__pc = '700000001'
        ];

        String disclosureTitle = 'testSubmitterApprovedNotifications';

        Disclosure__c disclosureSOB = DisclosureSampleDataFactory.createApprovedSOBInventionDisclosure(
            disclosureTitle
        );

        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTER_TLO_APPROVED
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'One tlo approved notifications should have been created, one for Submitting Contact'
        );

        List<Notification__c> testNoDeptHeadNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_AND_SUBMITTER_DEPT_TLO_APPROVED
        ];
        System.Assert(
            testNoDeptHeadNotificationsCreated.size() == 0,
            'No Opensource Dept Head endorsed and tlo approved notifications should have been created, for Submitting Contact'
        );

        Map<String, Object> variableMap = (Map<String, Object>) JSON.deserializeUntyped(
            testAllNotificationsCreated[0].Variables__c
        );
        System.debug('\n\nvariableMap:- \n\n' + variableMap + '\n\n');

        System.assert(
            String.valueOf(variableMap.get('case_number')).length() > 0,
            'case_number missing'
        );
        System.assertEquals(
            disclosureSOB.Case_Number__c,
            String.valueOf(variableMap.get('case_number')),
            'case_number not correct'
        );

        System.assertEquals(
            submittingContact1.Name,
            String.valueOf(variableMap.get('submitter_name')),
            'submitter_name not correct'
        );
        System.assertEquals(
            disclosureToTest.Name__c,
            String.valueOf(variableMap.get('disclosure_title')),
            'disclosure_title not correct'
        );
        System.assertEquals(
            disclosureToTest.Name,
            String.valueOf(variableMap.get('disclosure_name')),
            'disclosure_name not correct'
        );

        Test.stopTest();
    }

    @IsTest
    static void testNoWatchersEndorsedAndTloApprovedNotifications() {
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Test.startTest();

        String disclosureTitle = 'testNoWatchersEndorsedAndTloApprovedNotifications';
        ContactSampleDataFactory.createSampleContacts();
        Disclosure__c disclosureSOB = SoftwareDisclosuresSampleFactory.createDisclosure(
            disclosureTitle,
            false
        );

        disclosureSOB.Status__c = 'Inventor Submitted';
        update disclosureSOB;

        disclosureSOB.Status__c = 'Approved';
        disclosureSOB.Case_Number__c = '12345J';
        update disclosureSOB;

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_AND_SUBMITTER_DEPT_TLO_APPROVED
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'One endorsed approved notifications should have been created, one for Submitting Contact'
        );

        List<Notification__c> testTloApprovedNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTER_TLO_APPROVED
        ];
        System.Assert(
            testTloApprovedNotificationsCreated.size() == 0,
            'NO tlo approved notifications should have been created, for Submitting Contact'
        );

        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);
        Account submittingContact = [
            SELECT Id, Name
            FROM Account
            WHERE MitId__pc = '12345678'
        ];

        Map<String, Object> variableMap = (Map<String, Object>) JSON.deserializeUntyped(
            testAllNotificationsCreated[0].Variables__c
        );
        System.debug('\n\nvariableMap:- \n\n' + variableMap + '\n\n');

        RecordType swRecordType = [
            SELECT Name
            FROM RecordType
            WHERE ID = :recordTypeIdSoftware
            LIMIT 1
        ];
        System.assertEquals(
            swRecordType.Name,
            String.valueOf(variableMap.get('disclosure_type')),
            'disclosure_type should be the Name of Software_Code_Disclosure'
        );

        System.assert(
            String.valueOf(variableMap.get('case_number')).length() > 0,
            'case_number missing'
        );
        System.assertEquals(
            disclosureToTest.Case_Number__c,
            String.valueOf(variableMap.get('case_number')),
            'case_number not correct'
        );

        System.assertEquals(
            submittingContact.Name,
            String.valueOf(variableMap.get('submitter_name')),
            'submitter_name not correct'
        );
        System.assertEquals(
            disclosureToTest.Name__c,
            String.valueOf(variableMap.get('disclosure_title')),
            'disclosure_title not correct'
        );
        System.assertEquals(
            disclosureToTest.Name,
            String.valueOf(variableMap.get('disclosure_name')),
            'disclosure_name not correct'
        );

        Account departmentHeadContact = [
            SELECT Id, Name
            FROM Account
            WHERE MitId__pc = '777777778'
        ];
        System.assertEquals(
            departmentHeadContact.Name,
            String.valueOf(variableMap.get('dlc_name')),
            'department head not correct'
        );
        Test.stopTest();
    }

    @IsTest
    static void testEndorsedAndTloApprovedNotifications() {
        Test.startTest();

        String disclosureTitle = 'testEndorsedAndTloApprovedNotifications';
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account departmentHeadContact = SampleDataFactory.createContact(
            'Scott',
            true,
            '123456780'
        );
        // Get Name
        departmentHeadContact.Name = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :departmentHeadContact.Id
        ].Name;

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
        // Get Name
        submittingContact.Name = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :submittingContact.Id
        ].Name;

        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            disclosureTitle,
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
        SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
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

        DisclosureEnableWatchers.enableDraftWatchers(disclosure.Id);

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;

        disclosure.Status__c = 'Approved';
        disclosure.Case_Number__c = '12345J';
        update disclosure;

        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_AND_SUBMITTER_DEPT_TLO_APPROVED
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 2,
            'Two endorsed approved notifications should have been created, one for Primary Inventor and Submitting Contact'
        );

        Map<String, Object> variableMap = (Map<String, Object>) JSON.deserializeUntyped(
            testAllNotificationsCreated[0].Variables__c
        );
        System.debug('\n\nvariableMap:- \n\n' + variableMap + '\n\n');

        RecordType swRecordType = [
            SELECT Name
            FROM RecordType
            WHERE ID = :recordTypeIdSoftware
            LIMIT 1
        ];
        System.assertEquals(
            swRecordType.Name,
            String.valueOf(variableMap.get('disclosure_type')),
            'disclosure_type should be the Name of Software_Code_Disclosure'
        );

        System.assert(
            String.valueOf(variableMap.get('case_number')).length() > 0,
            'case_number missing'
        );
        System.assertEquals(
            disclosureToTest.Case_Number__c,
            String.valueOf(variableMap.get('case_number')),
            'case_number not correct'
        );

        System.assertEquals(
            submittingContact.Name,
            String.valueOf(variableMap.get('submitter_name')),
            'submitter_name not correct'
        );
        System.assertEquals(
            disclosureToTest.Name__c,
            String.valueOf(variableMap.get('disclosure_title')),
            'disclosure_title not correct'
        );
        System.assertEquals(
            disclosureToTest.Name,
            String.valueOf(variableMap.get('disclosure_name')),
            'disclosure_name not correct'
        );

        Test.stopTest();
    }

    // Moving to Archived/Deleting a Disclosure will send the same Notification to Named Primary Inventors.
    // Submitting Contact will get a different Notification.
    @IsTest
    static void testArchivedInventorNotification() {
        Test.startTest();

        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Account inventorContact = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );
        Account inventorContact2 = SampleDataFactory.createContact(
            'John',
            true,
            '123456782'
        );

        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftware,
            'Title Of',
            'Draft',
            submittingContact
        );

        DisclosureInventor__c submittingInventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            submittingContact
        );
        DisclosureInventor__c primaryInventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            false,
            inventorContact2
        );

        DisclosureEnableWatchers.enableDraftWatchers(disclosure.Id);

        disclosure.Status__c = 'Archived';
        update disclosure;

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_ARCHIVED
        ];

        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'Only when watcher is enabled should a notification be created for Primary Inventor, Submitting Inventor should not get notified twice'
        );

        List<Notification__c> testSubmittingNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTED_BY_DRAFT_ARCHIVED
        ];

        System.Assert(
            testSubmittingNotificationsCreated.size() == 1,
            'Submitting Inventor should not get notified that Draft was Archived'
        );

        Test.stopTest();
    }

    @IsTest
    static void testArchivedSOBInventorNotification() {
        Test.startTest();

        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Account inventorContact = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );
        Account inventorContact2 = SampleDataFactory.createContact(
            'John',
            true,
            '123456782'
        );

        Disclosure__c disclosureSOB = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            'Title Of',
            'Draft',
            submittingContact
        );

        DisclosureInventor__c primaryInventor = SampleDataFactory.createInventor(
            disclosureSOB,
            true,
            inventorContact
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosureSOB,
            false,
            inventorContact2
        );

        DisclosureEnableWatchers.enableDraftWatchers(disclosureSOB.Id);

        disclosureSOB.Status__c = 'Archived';
        update disclosureSOB;

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_ARCHIVED
        ];

        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'Only when watcher is enabled should a notification be created for Primary Inventor, Submitting Inventor should not get notified twice'
        );

        List<Notification__c> testSubmittingNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTED_BY_DRAFT_ARCHIVED
        ];

        System.Assert(
            testSubmittingNotificationsCreated.size() == 1,
            'Submitting Inventor should not get notified that Draft was Archived'
        );

        Test.stopTest();
    }

    @IsTest
    static void testDraftSubmittedForApprovalNotification() {
        Test.startTest();

        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Account inventorContact = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );
        Account inventorContact2 = SampleDataFactory.createContact(
            'John',
            true,
            '123456782'
        );

        Disclosure__c disclosureSOB = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            'Title Of',
            'Draft',
            submittingContact
        );

        DisclosureInventor__c primaryInventor = SampleDataFactory.createInventor(
            disclosureSOB,
            true,
            inventorContact
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosureSOB,
            false,
            inventorContact2
        );

        DisclosureEnableWatchers.enableDraftWatchers(disclosureSOB.Id);

        disclosureSOB.Status__c = 'Inventor Submitted';
        update disclosureSOB;

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_SUBMITTED
        ];

        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'Only when watcher is enabled should a notification be created for Primary Inventor, Submitting Inventor should not get notified since he Submitted disclosure'
        );

        Test.stopTest();
    }

    @IsTest
    static void testApprovedInventorAddRemoveNotifications() {
        Test.startTest();
        Test.setMock(
            HttpCalloutMock.class,
            new GuestAccountTest.GuestAccountMock()
        );
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
        SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            softwareCodeDisclosure
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );
        DisclosureInventor__c removeInventor = SampleDataFactory.createInventor(
            disclosure,
            false,
            nonMitInventorContact
        );

        DisclosureEnableWatchers.enableDraftWatchers(disclosure.Id);

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;

        disclosure.Status__c = 'Approved';
        disclosure.Case_Number__c = '12345J';
        update disclosure;

        delete removeInventor;

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_APPROVED_INVENTOR_DELETED
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'One tlo approved inventor deleted from disclosure notification should have been created.'
        );

        // Future callout not finished by the time assertion is taking place, force delivery of Events
        Test.getEventBus().deliver();
        Test.stopTest();

        testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REQUIRED
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 2,
            'One new signature required notification should have been created for each Inventor.'
        );
    }

    @isTest
    static void testAddInventorAfterApproval() {
        Test.setMock(
            HttpCalloutMock.class,
            new GuestAccountTest.GuestAccountMock()
        );
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
        Account nonMitInventorContactAmanda = SampleDataFactory.createContact(
            'Amanda',
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
        SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            softwareCodeDisclosure
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );

        DisclosureEnableWatchers.enableDraftWatchers(disclosure.Id);

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;

        disclosure.Status__c = 'Approved';
        disclosure.Case_Number__c = '12345J';
        update disclosure;

        // Add Inventor after Approval by TLO
        nonMitInventorContactAmanda.GuestAccountNeeded__pc = 'Yes';
        update nonMitInventorContactAmanda;
        DisclosureInventor__c approvedInventorAmanda = SampleDataFactory.createInventor(
            disclosure,
            false,
            nonMitInventorContactAmanda
        );

        // Future callout not finished by the time assertion is taking place, force delivery of Events
        Test.getEventBus().deliver();
        Test.stopTest();

        // Test if the Notification contain the Invite Code
        List<Notification__c> notificationsForAmandaOnly = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                To__c = 'Amanda_sample@external.com'
                AND Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REQUIRED
        ];
        System.assert(
            notificationsForAmandaOnly.size() == 1,
            'Sign Notifications not Created for Amanda.'
        );
        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            notificationsForAmandaOnly[0].Variables__c
        );
        System.assert(
            String.valueOf(variableMap.get('invitation_code')).length() > 0,
            'InvitationCode missing'
        );
        System.assert(
            String.valueOf(variableMap.get('isAlumni')).length() > 0,
            'isAlumni missing'
        );

        List<Async_Request__c> asyncJobs = [
            SELECT
                Id,
                Has_Processed__c,
                Retry_Count__c,
                Record_Id__c,
                sObject_Name__c
            FROM Async_Request__c
            WHERE
                Has_Processed__c = FALSE
                AND Retry_Count__c < 3
                AND sObject_Name__c = 'DisclosureInventor__c'
                AND Job_Name__c = 'InventorAddedToApprovedDisclosureToForresterJob'
        ];
        System.assert(
            asyncJobs.size() == 1,
            'Expecting 1 DisclosureInventor__c InventorAddedToApprovedDisclosureToForresterJob job entry'
        );

        Account contactAmanda = [
            SELECT Id, GuestAccountNeeded__pc, InvitationCode__pc, MitId__pc
            FROM Account
            WHERE Id = :nonMitInventorContactAmanda.Id
        ];
        System.assert(
            contactAmanda.GuestAccountNeeded__pc == 'No',
            'GuestAccountNeeded__pc should be No.'
        );
        System.assert(
            contactAmanda.InvitationCode__pc != null,
            'InvitationCode__pc should not be Empty'
        );
        System.assert(
            contactAmanda.MitId__pc != null,
            'MitId__pc should not be Empty'
        );
    }
}