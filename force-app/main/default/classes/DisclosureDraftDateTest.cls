@isTest
public with sharing class DisclosureDraftDateTest {
    @TestSetup
    static void makeData() {
        TestSetup.defaultConfiguration();
        ContactSampleDataFactory.createSampleContacts();
    }

    @isTest
    public static void validateInsertDraftDateSet() {
        String disclosureTitle = 'validateInsertDraftDateSet';
        Disclosure__c d = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            false
        );

        Disclosure__c disclosureToTest = [
            SELECT Id, Draft_Date__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];

        System.assert(
            disclosureToTest.Draft_Date__c != null,
            'Draft_Date__c should have been set for new Disclosures'
        );
    }

    @isTest
    public static void validateDisclosureDraftDateResetWhenMovingBackToDraft() {
        // change current now/today to be only thirty days back, so that we can work throuch a flow where its Draft --> Archieved --> Draft
        DateTime theDate = DateTime.now().addDays(-30);
        Util.now = theDate;
        Util.today = Date.today().addDays(-30);

        String disclosureTitle = 'validateInsertDraftDateSetAfterArchive';
        Disclosure__c d = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            false
        );
        Test.setCreatedDate(d.Id, theDate);

        Disclosure__c disclosureToTest = [
            SELECT Id, Draft_Date__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assert(
            disclosureToTest.Draft_Date__c != null,
            'Draft_Date__c should have been set for new Disclosures'
        );

        // change current now/today to be only twenty days back, and archive Disclosure
        Util.now = DateTime.now().addDays(-20);
        Util.today = Date.today().addDays(-20);
        DisclosureSampleDataFactory.archiveDisclosure(disclosureToTest);

        Disclosure__c disclosureToTest2 = [
            SELECT Id, Draft_Date__c, Status__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assertEquals(
            'Archived',
            disclosureToTest2.Status__c,
            'Disclosure status in test should now be Archived'
        );

        // change current now/today to be only ten days back, where disclosure now set back to Draft Status
        Util.now = DateTime.now().addDays(-10);
        Util.today = Date.today().addDays(-10);
        DisclosureSampleDataFactory.sysAdminMoveBackToDraftDisclosure(
            disclosureToTest2
        ); //TODO only sys admin can do this back to draft

        Disclosure__c disclosureToTest3 = [
            SELECT Id, Draft_Date__c, Status__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];

        System.assertEquals(
            'Draft',
            disclosureToTest3.Status__c,
            'Disclosure status in test should now be Draft'
        );
        System.assertNotEquals(
            disclosureToTest.Draft_Date__c,
            disclosureToTest3.Draft_Date__c,
            'DIf disclosure moved from Archive back to Draft the Draft_Date__c should have changed.'
        );
    }

    @isTest
    public static void testAllReminder() {
        // Reminder 1
        DateTime theDate = DateTime.now().addDays(-31);
        Util.now = theDate;
        Util.today = Date.today().addDays(-30);
        String disclosureTitle = 'validateDraftNotificationsSentForOldDisclosures';
        Disclosure__c d = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            false
        );
        Test.setCreatedDate(d.Id, theDate);

        Disclosure__c disclosureToTest = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assert(
            disclosureToTest.Draft_Date__c != null,
            'Draft_Date__c should have been set for new Disclosures'
        );
        System.assertEquals(
            'No Reminder',
            disclosureToTest.Reminder__c,
            'Reminder__c should not have been set yet'
        );

        Test.startTest();
        Database.executeBatch(new DraftDisclosureReminderBatch(), 200);
        Test.stopTest();

        Disclosure__c disclosureToTest1 = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c, CreatedDate
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assertEquals(
            'Reminder 1',
            disclosureToTest1.Reminder__c,
            'Reminder__c should now be Reminder 1'
        );

        // Reminder 2
        DateTime theDate2 = DateTime.now().addDays(-61);
        Util.now = theDate2;
        Util.today = Date.today().addDays(-60);
        Test.setCreatedDate(disclosureToTest1.Id, theDate2);
        Disclosure__c disclosureToTest2 = [
            SELECT
                Id,
                Draft_Date__c,
                Reminder__c,
                Status__c,
                CreatedDate,
                Name__c,
                Name,
                Submitting_Contact__r.Name,
                Submitting_Contact__r.PersonEmail
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        disclosureToTest2.Draft_Date__c = theDate2.date();
        update disclosureToTest2;
        new DraftDisclosureReminderBatch()
            .execute(null, new List<Disclosure__c>{ disclosureToTest2 });

        Disclosure__c afterBatchRun = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c, CreatedDate
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assertEquals(
            'Reminder 2',
            afterBatchRun.Reminder__c,
            'Reminder__c should now be Reminder 2'
        );

        // Reminder 3
        DateTime theDate3 = DateTime.now().addDays(-91);
        Util.now = theDate3;
        Util.today = Date.today().addDays(-90);
        Test.setCreatedDate(disclosureToTest1.Id, theDate3);
        Disclosure__c disclosureToTest3 = [
            SELECT
                Id,
                Draft_Date__c,
                Reminder__c,
                Status__c,
                CreatedDate,
                Name__c,
                Name,
                Submitting_Contact__r.Name,
                Submitting_Contact__r.PersonEmail
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        disclosureToTest3.Draft_Date__c = theDate3.date();
        update disclosureToTest3;
        new DraftDisclosureReminderBatch()
            .execute(null, new List<Disclosure__c>{ disclosureToTest3 });

        Disclosure__c afterBatchRun1 = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c, CreatedDate
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assertEquals(
            'Reminder 3',
            afterBatchRun1.Reminder__c,
            'Reminder__c should now be Reminder 3'
        );
    }

    @isTest
    public static void testReminder1() {
        // change current now/today to be only thirty days back, so that we can work throuch a flow where its Draft --> Archieved --> Draft
        DateTime theDate = DateTime.now().addDays(-31);
        Util.now = theDate;
        Util.today = Date.today().addDays(-30);
        String disclosureTitle = 'validateDraftNotificationsSentForOldDisclosures';
        Disclosure__c d = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            false
        );
        Test.setCreatedDate(d.Id, theDate);

        Disclosure__c disclosureToTest = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assert(
            disclosureToTest.Draft_Date__c != null,
            'Draft_Date__c should have been set for new Disclosures'
        );
        System.assertEquals(
            'No Reminder',
            disclosureToTest.Reminder__c,
            'Reminder__c should not have been set yet'
        );

        Test.startTest();
        Database.executeBatch(new DraftDisclosureReminderBatch(), 200);
        Test.stopTest();

        Disclosure__c disclosureToTest1 = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assertEquals(
            'Reminder 1',
            disclosureToTest1.Reminder__c,
            'Reminder__c should now be Reminder 1'
        );
    }

    @isTest
    static void testReminder2() {
        String disclosureTitle = 'validateDraftNotificationsSentForOldDisclosures';
        DateTime theDate = DateTime.now().addDays(-61);
        Util.now = theDate;
        Util.today = Date.today().addDays(-61);
        Disclosure__c d = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            false
        );
        d.Reminder__c = 'Reminder 1';
        update d;
        Test.setCreatedDate(d.Id, theDate);
        Disclosure__c disclosureToTest = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assert(
            disclosureToTest.Draft_Date__c != null,
            'Draft_Date__c should have been set for new Disclosures'
        );
        Test.startTest();
        Database.executeBatch(new DraftDisclosureReminderBatch(), 200);
        Test.stopTest();
        Disclosure__c disclosureToTest2 = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assertEquals(
            'Reminder 2',
            disclosureToTest2.Reminder__c,
            'Reminder__c should now be Reminder 2'
        );
    }

    @isTest
    static void testReminder3() {
        String disclosureTitle = 'validateDraftNotificationsSentForOldDisclosures';
        DateTime theDate = DateTime.now().addDays(-90);
        Util.now = theDate;
        Util.today = Date.today().addDays(-90);
        Disclosure__c d = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            false
        );
        d.Reminder__c = 'Reminder 2';
        update d;
        Test.setCreatedDate(d.Id, theDate);
        Disclosure__c disclosureToTest = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assert(
            disclosureToTest.Draft_Date__c != null,
            'Draft_Date__c should have been set for new Disclosures'
        );
        Test.startTest();
        Database.executeBatch(new DraftDisclosureReminderBatch(), 200);
        Test.stopTest();
        Disclosure__c disclosureToTest2 = [
            SELECT Id, Draft_Date__c, Reminder__c, Status__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];
        System.assertEquals(
            'Reminder 3',
            disclosureToTest2.Reminder__c,
            'Reminder__c should now be Reminder 3'
        );
    }
}