@IsTest
public with sharing class DraftDisclosureReminderTest {
    private static Integer firstReminderInDays { get; set; }
    private static Integer secondReminderInDays { get; set; }
    private static Integer thirdReminderInDays { get; set; }

    @TestSetup
    static void setupTestData() {
        TestSetup.defaultConfiguration();
    }

    static void setupReminderValues() {
        Configurations__c reminder1Config = Configurations__c.getInstance(
            'DraftDisclosureReminder_1'
        );
        Configurations__c reminder2Config = Configurations__c.getInstance(
            'DraftDisclosureReminder_2'
        );
        Configurations__c reminder3Config = Configurations__c.getInstance(
            'DraftDisclosureReminder_3'
        );
        firstReminderInDays = Integer.valueOf(reminder1Config.Value__c);
        secondReminderInDays = Integer.valueOf(reminder2Config.Value__c);
        thirdReminderInDays = Integer.valueOf(reminder3Config.Value__c);
    }

    static void setupDraftDisclosure(Integer daysSinceDraftCreated) {
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
            'Sample Draft Software',
            'Draft',
            submittingContact
        );

        // Mock the creation date in the Past
        Date pastedDate = Date.today().addDays(-daysSinceDraftCreated);
        Test.setCreatedDate(disclosure.Id, pastedDate);

        disclosure.Draft_Date__c = pastedDate; // because Archived disclosure's can be moved back to Draft by sys admin
        update disclosure;
    }

    @IsTest
    static void draftDisclosureReminderScheduleTest() {
        setupReminderValues();
        setupDraftDisclosure(thirdReminderInDays);
        Test.startTest();
        // Code Coverage only
        DraftDisclosureReminderSchedule.scheduleMe();
        DraftDisclosureReminderSchedule.abortSchedule();
        Test.stopTest();
    }

    @IsTest
    static void draftDisclosureReminder90DaysTest() {
        setupReminderValues();
        setupDraftDisclosure(thirdReminderInDays);

        Test.startTest();
        assertNotificationCountEquals(0);

        // First Reminder
        mockDatabaseExecuteBatch(new DraftDisclosureReminderBatch());
        assertNotificationCountEquals(1);

        // Second Reminder
        mockDatabaseExecuteBatch(new DraftDisclosureReminderBatch());
        assertNotificationCountEquals(2);

        // Third Reminder, using actual Batch job
        Database.executeBatch(new DraftDisclosureReminderBatch(), 200);

        // This should not create any new Reminders
        mockDatabaseExecuteBatch(new DraftDisclosureReminderBatch());
        Test.stopTest();
        assertNotificationCountEquals(3);
    }

    @IsTest
    static void draftDisclosureReminder60DaysTest() {
        setupReminderValues();
        setupDraftDisclosure(secondReminderInDays);

        Test.startTest();
        assertNotificationCountEquals(0);

        // First Reminder
        mockDatabaseExecuteBatch(new DraftDisclosureReminderBatch());
        assertNotificationCountEquals(1);

        // Second Reminder
        mockDatabaseExecuteBatch(new DraftDisclosureReminderBatch());
        assertNotificationCountEquals(2);

        // Third Reminder, using actual Batch job
        Database.executeBatch(new DraftDisclosureReminderBatch(), 200);

        // This should not create any new Reminders
        mockDatabaseExecuteBatch(new DraftDisclosureReminderBatch());
        Test.stopTest();
        assertNotificationCountEquals(2);
    }

    @IsTest
    static void draftDisclosureReminder30DaysTest() {
        setupReminderValues();
        setupDraftDisclosure(firstReminderInDays);

        Test.startTest();
        assertNotificationCountEquals(0);
        Database.executeBatch(new DraftDisclosureReminderBatch(), 200);
        // This should not create any new Reminders
        mockDatabaseExecuteBatch(new DraftDisclosureReminderBatch());
        Test.stopTest();
        assertNotificationCountEquals(1);

        Date draftDate = Date.today().addDays(-firstReminderInDays);
        String olderThanNDays = ConfigurationBuilder.getConfigurationToString(
            'archiveDraftOlderThan'
        );
        System.debug(draftDate.format() + ' olderThanNDays:' + olderThanNDays);
        Integer nDays = Integer.valueOf(olderThanNDays);
        Date archiveDate = draftDate.addDays(nDays);
        assertNotificationArchiveDate(archiveDate);
    }

    @IsTest
    static void draftDisclosureNoReminderTest() {
        setupReminderValues();
        setupDraftDisclosure(firstReminderInDays - 1);

        Test.startTest();
        assertNotificationCountEquals(0);
        Database.executeBatch(new DraftDisclosureReminderBatch(), 200);
        Test.stopTest();
        assertNotificationCountEquals(0);
    }

    private static void assertNotificationCountEquals(Integer expectedCount) {
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_DRAFT_REMINDER
        ];
        System.Assert(
            testAllNotificationsCreated.size() == expectedCount,
            expectedCount + ' reminder notifications should have been created'
        );
    }

    private static void assertNotificationArchiveDate(Date expectedDate) {
        List<Notification__c> draftReminderNotifications = [
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_DRAFT_REMINDER
        ];

        Map<String, Object> jsonVar = (Map<String, Object>) JSON.deserializeUntyped(
            draftReminderNotifications[0].Variables__c
        );
        System.assertEquals(
            Helpers.formatDate(expectedDate, 'MMM dd, yyyy'),
            String.valueOf(jsonVar.get('archive_date')),
            'archive_date not calculated'
        );
    }

    private static void mockDatabaseExecuteBatch(
        DraftDisclosureReminderBatch batch
    ) {
        Database.QueryLocatorIterator it = batch.start(null).iterator();
        List<Disclosure__c> scopes = new List<Disclosure__c>();
        while (it.hasNext()) {
            Disclosure__c disclosure = (Disclosure__c) it.next();
            scopes.add(disclosure);
        }
        batch.execute(null, scopes);
    }
}