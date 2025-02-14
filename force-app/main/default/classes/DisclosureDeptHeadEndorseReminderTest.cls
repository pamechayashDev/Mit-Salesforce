@isTest
public with sharing class DisclosureDeptHeadEndorseReminderTest {
    @TestSetup
    static void makeData() {
        TestSetup.defaultConfiguration();
    }

    @isTest
    public static void testReminderNotification() {
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();
        DateTime theDate = DateTime.now().addDays(-30);
        Util.now = DateTime.now().addDays(-30 + 7);

        String disclosureTitle = 'Test DisclosureDeptHeadEndorseReminder';

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

        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            disclosureTitle,
            'Draft',
            submittingContact
        );
        Test.setCreatedDate(disclosure.Id, theDate);

        Copyright_Disclosure__c copyrightDisclosure = SampleDataFactory.createCopyright(
            disclosureTitle,
            disclosure,
            piContact
        );

        Open_Source__c openSource = SampleDataFactory.createOpenSource(
            disclosureTitle,
            copyrightDisclosure,
            null
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

        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        Id recordTypeId = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
            .get('Endorse_or_Delegate_Disclosure')
            .getRecordTypeId();
        Disclosure_Action__c disclosureAction = [
            SELECT
                Id,
                CreatedDate,
                Contact_Action__r.Name,
                Contact_Action__r.Status__c,
                Contact_Action__c,
                RecordType.DeveloperName,
                RecordType.name,
                Disclosure__c,
                Disclosure__r.Name,
                Disclosure__r.Name__c,
                Disclosure__r.RecordType.Name,
                Contact_Action__r.Contact__r.PersonEmail,
                Contact_Action__r.Contact__r.Name,
                Disclosure__r.Submitting_Contact__c,
                Disclosure__r.Submitting_Contact__r.Id,
                Disclosure__r.Submitting_Contact__r.Name,
                Disclosure__r.Submitting_Contact__r.PersonEmail,
                Disclosure__r.Submitting_Contact__r.AltEmail__pc,
                Reminder_1__c,
                Reminder_2__c,
                Reminder_3__c
            FROM Disclosure_Action__c
            WHERE
                Disclosure__c = :disclosure.Id
                AND RecordTypeId = :recordTypeId
            LIMIT 1
        ];
        Test.setCreatedDate(disclosureAction.Id, theDate);

        Test.startTest();
        Database.executeBatch(new DisclosureDeptHeadEndorseReminder(), 1);
        Test.stopTest();

        List<Notification__c> notification = [
            SELECT Id, Template__c, Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REMINDER
        ];
        Map<String, Object> jsonVal = (Map<String, Object>) JSON.deserializeUntyped(
            notification[0].Variables__c
        );
        System.debug('\n\nnotification:- \n\n' + notification + '\n\n');
        System.debug(
            '\n\nnotification[0].Variables__c):- \n\n' +
            notification[0].Variables__c +
            '\n\n'
        );

        System.assertEquals(
            '7',
            String.valueOf(jsonVal.get('outstanding')),
            'First reminder is 7 days outstanding'
        );
        System.assertEquals(
            disclosureAction.Disclosure__r.Name,
            String.valueOf(jsonVal.get('disclosure_name')),
            'disclosure_name'
        );
        System.assertEquals(
            ContactNameUtil.toFullName(
                firstDeptHeadContact.FirstName,
                firstDeptHeadContact.MiddleName,
                firstDeptHeadContact.LastName,
                true
            ),
            String.valueOf(jsonVal.get('dlc_name')),
            'dlc_name is not correct'
        );
        System.assertEquals(
            1,
            notification.size(),
            'We should have at least one notification'
        );

        System.assertEquals(
            disclosureAction.Disclosure__r.RecordType.Name,
            String.valueOf(jsonVal.get('disclosure_type')),
            'disclosure_type not set correctly'
        );
        System.assertEquals(
            disclosureAction.Disclosure__r.Submitting_Contact__r.Name,
            String.valueOf(jsonVal.get('submitter_name')),
            'submitter_name not set correctly'
        );
        System.assertEquals(
            disclosureAction.Disclosure__r.Name,
            String.valueOf(jsonVal.get('disclosure_name')),
            'disclosure_name not set correctly'
        );
        System.assertEquals(
            disclosureAction.Disclosure__r.Name__c,
            String.valueOf(jsonVal.get('disclosure_title')),
            'disclosure_title not set correctly'
        );

        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);
        List<Disclosure_Action__c> disclosureActions = [
            SELECT
                Id,
                CreatedDate,
                Contact_Action__r.Name,
                Contact_Action__r.Status__c,
                Contact_Action__c,
                RecordType.DeveloperName,
                RecordType.name,
                Disclosure__c,
                Disclosure__r.Name,
                Disclosure__r.Name__c,
                Disclosure__r.RecordType.Name,
                Contact_Action__r.Contact__r.PersonEmail,
                Contact_Action__r.Contact__r.Name,
                Reminder_1__c,
                Reminder_2__c,
                Reminder_3__c
            FROM Disclosure_Action__c
            WHERE
                Disclosure__c = :disclosureToTest.Id
                AND RecordTypeId = :recordTypeId
        ];
        System.debug(
            '\n\n disclosureActions:- \n\n' +
            disclosureActions +
            '\n\n'
        );
    }

    private static Disclosure__c getDisclosureToTest(String title) {
        Disclosure__c disclosureToTest = [
            SELECT
                Id,
                Status__c,
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
}