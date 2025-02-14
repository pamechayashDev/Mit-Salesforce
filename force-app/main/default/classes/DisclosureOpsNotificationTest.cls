@IsTest
public with sharing class DisclosureOpsNotificationTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
        ContactSampleDataFactory.createSampleContacts();
    }

    private static Disclosure__c getDisclosureToTest(String title) {
        Disclosure__c disclosureToTest = [
            SELECT
                Id,
                Status__c,
                SubmittedOnBehalf__c,
                Submitting_Contact__c,
                Submitting_Contact__r.Id,
                Submitting_Contact__r.Name,
                Submitting_Contact__r.PersonEmail,
                Submitting_Contact__r.AltEmail__pc,
                Name__c,
                Name
            FROM Disclosure__c
            WHERE Name__c = :title
            LIMIT 1
        ];
        return disclosureToTest;
    }

    @IsTest
    static void testOpsRejectNotification() {
        Test.startTest();
        Disclosure__c disclosure = SoftwareDisclosuresSampleFactory.createDisclosure(
            'Sample Inventor Submitted Disclosure for Software',
            false
        );

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Rejected_By__c = 'Department Head';
        disclosure.Status__c = 'Rejected';
        disclosure.Rejection_Reason__c = 'Sample Rejection Reason';
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
                Template__c = :NotificationBuilder.TEMPLATE_OPS_DISCLOSURE_DECLINED_DEPT_HEAD
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'One reject notifications should have been created, one for TLO Ops'
        );

        Notification__c rejectNotification = testAllNotificationsCreated.get(0);
        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            rejectNotification.Variables__c
        );
        System.assert(
            String.valueOf(variableMap.get('comments')).length() > 0,
            'Rejection Comments missing'
        );
        System.assert(
            String.valueOf(variableMap.get('submitter_name')).length() > 0,
            'Submitter Name missing'
        );

        String opsEmail = ConfigurationBuilder.getConfigurationToString(
            'DisclosureOpsEmail'
        );
        System.assertEquals(
            opsEmail,
            testAllNotificationsCreated[0].To__c,
            'Ops Email Address expected'
        );

        Test.stopTest();
    }

    @IsTest
    static void testOpsInventorSubmittedNotification() {
        Test.startTest();
        Disclosure__c disclosure = SoftwareDisclosuresSampleFactory.createDisclosure(
            'Sample Inventor Submitted Disclosure for Software',
            false
        );

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
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
                Template__c = :NotificationBuilder.TEMPLATE_OPS_DISCLOSURE_CREATION
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'One created and approval required notification should have been created, one for TLO Ops'
        );

        Test.stopTest();
    }

    @IsTest
    static void testEachSignedInventorNotification() {
        String title = 'testEachSignedInventorNotification';
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account inventorContact = SampleDataFactory.createContact(
            'Inventor1',
            true,
            '123456781'
        );
        Account submittingContact = SampleDataFactory.createContact(
            'SubmittingInventor',
            true,
            '123456782'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            title,
            'Draft',
            submittingContact
        );
        disclosure.SubmittedOnBehalf__c = false;
        update disclosure;

        DisclosureInventor__c submittingInventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            submittingContact
        );
        submittingInventor.Signed_Status__c = 'Yes';

        DisclosureInventor__c inventor1 = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );
        inventor1.Signed_Status__c = 'Yes';
        inventor1.AdditionalComments__c = 'I added some additional comments too';
        // Adding and signing new Inventors will trigger All_Inventors_Signed__c calculated field to be true. Each time he will be the last inventor who signed
        update submittingInventor;
        update inventor1;

        // ASSERT
        Disclosure__c disclosureToTest = getDisclosureToTest(title);

        List<Notification__c> notifications = [
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT
        ];
        System.assertEquals(
            1,
            notifications.size(),
            'There should be one notification for the inventor who just signed (and is not the submitting person)'
        );

        Notification__c notification = notifications.get(0);
        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            notification.Variables__c
        );

        System.assert(
            String.valueOf(variableMap.get('inventor_name')).length() > 0,
            'inventor_name missing'
        );
        System.assert(
            String.valueOf(variableMap.get('submitter_name')).length() > 0,
            'submitter_name missing'
        );

        System.assertEquals(
            String.valueOf(variableMap.get('submitter_name')),
            'SubmittingInventor SubmittingInventor SubmittingInventor',
            'submitter_name incorrect'
        );
        System.assertEquals(
            String.valueOf(variableMap.get('inventor_name')),
            'Inventor1 Inventor1 Inventor1',
            'inventor_name incorrect'
        );

        System.assert(
            String.valueOf(variableMap.get('additional_comments')).length() > 0,
            'additional_comments missing'
        );

        System.assertEquals(
            String.valueOf(variableMap.get('disclosure_title')),
            title,
            'disclosure_title incorrect'
        );
        System.assertEquals(
            String.valueOf(variableMap.get('disclosure_name')),
            disclosureToTest.Name,
            'disclosure_name incorrect'
        );

        System.assertEquals(
            String.valueOf(variableMap.get('signed_status')),
            'Yes',
            'signed_status incorrect'
        );
        System.assertEquals(
            String.valueOf(variableMap.get('signed_comment')),
            null,
            'signed_comment incorrect'
        );

        //variables.put('case_number', inventor.Disclosure__r.Case_Number__c);
        //variables.put('link', URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Disclosure__c/'+inventor.Disclosure__c+'/view');

        String opsEmail = ConfigurationBuilder.getConfigurationToString(
            'DisclosureOpsEmail'
        );
        System.assertEquals(
            opsEmail,
            notification.To__c,
            'Ops Email Address expected'
        );

        List<Notification__c> opsNotifications = [
            SELECT Id, Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED
        ];
        System.assertEquals(
            1,
            opsNotifications.size(),
            'There should be one notification for ops that all have signed'
        );
        Map<String, Object> nVariableMap = NotificationBuilder.deserializeVariables(
            opsNotifications[0].Variables__c
        );
        System.assertEquals(
            disclosureToTest.Name,
            String.valueOf(nVariableMap.get('disclosure_name')),
            'disclosure_name not correct'
        );
    }

    @isTest
    static void testEachSignedInventorNotificationFalse() {
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account inventorContact = SampleDataFactory.createContact(
            'Inventor1',
            true,
            '123456781'
        );
        Account submittingContact = SampleDataFactory.createContact(
            'submittingperson',
            true,
            '123456782'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Test Delegate Action',
            'Draft',
            submittingContact
        );
        disclosure.SubmittedOnBehalf__c = true;
        update disclosure;

        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );
        inventor.Signed_Status__c = 'Yes';
        update inventor;

        // ASSERT
        List<Notification__c> notifications = [
            SELECT Id
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT
        ];
        System.assertEquals(
            1,
            notifications.size(),
            'There should be one notification for the inventor who just signed (and is not the submitting person)'
        );
    }

    @IsTest
    static void testOpsInventorSigningNotification() {
        Disclosure__c disclosure = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            'testOpsInventorSigningNotification',
            false
        );
        disclosure.Case_Number__c = '123456';
        DisclosureSampleDataFactory.tloApprovesDisclosure(disclosure);

        List<DisclosureInventor__c> updateInventors = new List<DisclosureInventor__c>();
        DisclosureInventor__c submitterInventor = [
            SELECT
                Id,
                Contact__r.Id,
                Contact__r.MoiraStatus__pc,
                Contact__r.PersonEmail,
                Contact__r.MitId__pc
            FROM DisclosureInventor__c
            WHERE
                Disclosure__c = :disclosure.Id
                AND Contact__r.MitId__pc = '12345678'
            LIMIT 1
        ];

        submitterInventor.DocuSign_Recipient_StatusCode__c = 'Completed';
        updateInventors.add(submitterInventor);

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
        updateInventors.add(inventor);

        DisclosureInventor__c inventor2 = [
            SELECT
                Id,
                Contact__r.Id,
                Contact__r.MoiraStatus__pc,
                Contact__r.PersonEmail,
                Contact__r.MitId__pc,
                Signed_Status__c
            FROM DisclosureInventor__c
            WHERE
                Disclosure__c = :disclosure.Id
                AND Contact__r.PersonEmail = 'cr11@guest.test'
            LIMIT 1
        ];

        inventor2.Signed_Status__c = 'Opted Out';
        inventor2.Signed_Comment__c = 'Adding a reason as to why I have opted out of this disclosure.';
        updateInventors.add(inventor2);

        Test.startTest();
        update updateInventors;

        // ========= SIGNED
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT
        ];

        System.assertEquals(
            1,
            testAllNotificationsCreated.size(),
            'One created and approval required notification should have been created, one for TLO Ops'
        );
        Map<String, Object> variableMap1 = NotificationBuilder.deserializeVariables(
            testAllNotificationsCreated[0].Variables__c
        );

        System.debug(
            '\n\ntestAllNotificationsCreated:- \n\n' +
            testAllNotificationsCreated
        );
        System.debug('\n\nvariableMap1:- \n\n' + variableMap1);
        System.debug(
            '\n\ntestAllNotificationsCreated[0].Variables__c:- \n\n' +
            testAllNotificationsCreated[0].Variables__c
        );

        // ========= OPT OUT
        List<Notification__c> testAllNotificationsCreated2 = [
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_OPTED_OUT
        ];

        System.assertEquals(
            1,
            testAllNotificationsCreated2.size(),
            'One created and approval required notification should have been created, one for TLO Ops'
        );
        Notification__c notification = testAllNotificationsCreated2.get(0);
        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            notification.Variables__c
        );
        System.assert(
            String.valueOf(variableMap.get('inventor_name')).length() > 0,
            'inventor_name missing'
        );
        System.assert(
            String.valueOf(variableMap.get('inventor_email')).length() > 0,
            'inventor_email missing'
        );

        System.debug(
            '\n\testAllNotificationsCreated2:- \n\n' +
            testAllNotificationsCreated2
        );
        System.debug(
            '\n\testAllNotificationsCreated2[0].Variables__c:- \n\n' +
            testAllNotificationsCreated2[0].Variables__c
        );

        assertOpsAllSignedNotification();
        Test.stopTest();
    }

    @IsTest
    static void testOpsOnlyPrimaryInventorSigningNotification() {
        Disclosure__c disclosure = DisclosureSampleDataFactory.createDraftSoftwareDisclosurePrimaryInventorOnly(
            'testOpsInventorSigningNotification',
            false
        );
        disclosure.Case_Number__c = '123456';

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
                AND Contact__r.MitId__pc = '12345678'
            LIMIT 1
        ];

        inventor.DocuSign_Recipient_StatusCode__c = 'Completed';
        update inventor;

        Test.startTest();
        // ========= SIGNED
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT
        ];

        System.assertEquals(
            0,
            testAllNotificationsCreated.size(),
            'No Notification for submitter should be created'
        );

        // ======== Only signed the Draft disclosure
        List<Notification__c> opsAllSigned = [
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED
        ];

        System.assertEquals(
            0,
            opsAllSigned.size(),
            'All Inventors signed should not exist, delay sending notification, case number is required for the notification'
        );

        // ========= Approved
        DisclosureSampleDataFactory.tloApprovesDisclosure(disclosure);

        assertOpsAllSignedNotification();

        Test.stopTest();
    }

    private static void assertOpsAllSignedNotification() {
        List<Notification__c> testAllNotificationsCreated2 = [
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED
        ];

        System.assertEquals(
            1,
            testAllNotificationsCreated2.size(),
            'All Inventors signed'
        );
        Notification__c notification = testAllNotificationsCreated2.get(0);
        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            notification.Variables__c
        );
        System.assert(
            String.valueOf(variableMap.get('link')).length() > 0,
            'link missing'
        );
        System.assert(
            String.valueOf(variableMap.get('case_number')).length() > 0,
            'case_number missing'
        );

        System.debug(
            '\n\testAllNotificationsCreated2:- \n\n' +
            testAllNotificationsCreated2
        );
        System.debug(
            '\n\testAllNotificationsCreated2[0].Variables__c:- \n\n' +
            testAllNotificationsCreated2[0].Variables__c
        );
    }
}