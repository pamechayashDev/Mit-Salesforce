@isTest
public with sharing class DisclosureInventorSignReminderTest {
    // @TestSetup
    // static void makeData() {
    //     TestSetup.defaultConfiguration();
    // }

    // @IsTest
    // public static void inventorSignReminderTest() {
    //     String disclosureTitle = 'Test Delegate Action';

    //     // Constants
    //     Id disclosureRecordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
    //         .get('BioTang_Disclosure')
    //         .getRecordTypeId();
    //     DateTime theDate = DateTime.now().addDays(-30);
    //     Util.now = DateTime.now().addDays(-30 + 7);

    //     // Contacts
    //     Account inventorContact = SampleDataFactory.createContact(
    //         'Inventor',
    //         true,
    //         '123456781'
    //     );
    //     Account submittingContact = SampleDataFactory.createContact(
    //         'Jeff',
    //         true,
    //         '11345678'
    //     );
    //     Account inactiveContact = SampleDataFactory.createContact(
    //         'InactiveInventor',
    //         false,
    //         '123456782'
    //     );
    //     inactiveContact.InvitationCode__pc = 'INVCODE01';
    //     update inactiveContact;

    //     // Disclosure
    //     Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
    //         disclosureRecordTypeId,
    //         disclosureTitle,
    //         'Draft',
    //         submittingContact
    //     );
    //     Test.setCreatedDate(disclosure.Id, theDate);
    //     DisclosureInventor__c inventor = SampleDataFactory.createInventor(
    //         disclosure,
    //         true,
    //         inventorContact
    //     );
    //     DisclosureInventor__c inactiveInventor = SampleDataFactory.createInventor(
    //         disclosure,
    //         false,
    //         inactiveContact
    //     );

    //     disclosure.Status__c = 'Pending Department Approval';
    //     update disclosure;
    //     disclosure.Status__c = 'Approved';
    //     update disclosure;

    //     Id recordTypeId = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
    //         .get('Sign_Disclosure')
    //         .getRecordTypeId();
    //     List<Disclosure_Action__c> signDisclosureActions = [
    //         SELECT
    //             Id,
    //             CreatedDate,
    //             Reminder_1__c,
    //             Reminder_2__c,
    //             Reminder_3__c,
    //             Contact_Action__c,
    //             Contact_Action__r.Name,
    //             Contact_Action__r.Status__c,
    //             Contact_Action__r.Contact__r.Name,
    //             Contact_Action__r.Contact__r.PersonEmail,
    //             Disclosure__c,
    //             Disclosure__r.Name__c,
    //             Disclosure__r.RecordType.Name,
    //             RecordType.Name,
    //             RecordType.DeveloperName
    //         FROM Disclosure_Action__c
    //         WHERE
    //             Disclosure__c = :disclosure.Id
    //             AND RecordTypeId = :recordTypeId
    //         LIMIT 2
    //     ];
    //     Test.setCreatedDate(signDisclosureActions[0].Id, theDate);
    //     Test.setCreatedDate(signDisclosureActions[1].Id, theDate);

    //     Test.startTest();
    //     Database.executeBatch(new DisclosureInventorSignReminder(), 2);
    //     Test.stopTest();

    //     Disclosure_Action__c disclosureAction;
    //     for (Disclosure_Action__c action : signDisclosureActions) {
    //         if (
    //             action.Contact_Action__r.Contact__r.Id == inventorContact.Id
    //         ) {
    //             disclosureAction = action;
    //         }
    //     }
    //     System.assertNotEquals(
    //         disclosureAction,
    //         null,
    //         'Action not found for Contact'
    //     );

    //     List<Notification__c> notification = [
    //         SELECT Id, Template__c, Variables__c
    //         FROM Notification__c
    //         WHERE
    //             Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REMINDER
    //     ];
    //     System.debug('Notification:' + notification);
    //     Map<String, Object> jsonVal = (Map<String, Object>) JSON.deserializeUntyped(
    //         notification[0].Variables__c
    //     );

    //     Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);
    //     System.assertEquals(
    //         '7',
    //         String.valueOf(jsonVal.get('outstanding')),
    //         'should be 7'
    //     );
    //     System.assertEquals(
    //         disclosureToTest.Name,
    //         String.valueOf(jsonVal.get('disclosure_name')),
    //         'disclosure_name'
    //     );
    //     System.assertEquals(
    //         disclosureToTest.Name__c,
    //         String.valueOf(jsonVal.get('disclosure_title')),
    //         'disclosure_title'
    //     );

    //     // disclosureToTest.RecordType.Name for BioTang need to be replace with 'Tangible Property Disclosure'
    //     System.assertEquals(
    //         Label.Disclosure_Type_Notify_BioTang,
    //         String.valueOf(jsonVal.get('disclosure_type')),
    //         'disclosure_type'
    //     );
    //     System.assertEquals(
    //         disclosureAction.Contact_Action__r.Contact__r.Name,
    //         String.valueOf(jsonVal.get('inventor_name')),
    //         'inventor_name'
    //     );
    //     System.assertEquals(
    //         2,
    //         notification.size(),
    //         'only 2 at this point in time'
    //     );

    //     // NonMit Inventor Reminder
    //     List<Notification__c> nonMitNotification = [
    //         SELECT Id, Template__c, Variables__c
    //         FROM Notification__c
    //         WHERE
    //             Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REMINDER
    //     ];
    //     System.assertEquals(
    //         2,
    //         nonMitNotification.size(),
    //         '2 notification for Inactive Kerb Contact and Active Kerb. Only have one template for both Mit and Non-Mit'
    //     );
    //     Map<String, Object> jsonValInactiveKerb = (Map<String, Object>) JSON.deserializeUntyped(
    //         nonMitNotification[1].Variables__c
    //     );
    //     System.assertEquals(
    //         disclosureToTest.Name,
    //         String.valueOf(jsonValInactiveKerb.get('disclosure_name')),
    //         'disclosure_name'
    //     );
    //     System.assertEquals(
    //         disclosureToTest.Name__c,
    //         String.valueOf(jsonValInactiveKerb.get('disclosure_title')),
    //         'disclosure_title'
    //     );
    //     System.assertEquals(
    //         inactiveContact.InvitationCode__pc,
    //         String.valueOf(jsonValInactiveKerb.get('invitation_code')),
    //         'invitation_code'
    //     );
    //     System.assertEquals(
    //         false,
    //         jsonValInactiveKerb.get('isActiveKerb'),
    //         'isActiveKerb'
    //     );
    //     List<Disclosure_Action__c> disclosureActions = [
    //         SELECT
    //             Id,
    //             CreatedDate,
    //             Contact_Action__r.Name,
    //             Contact_Action__r.Status__c,
    //             Contact_Action__c,
    //             RecordType.DeveloperName,
    //             RecordType.name,
    //             Disclosure__c,
    //             Disclosure__r.Name__c,
    //             Disclosure__r.RecordType.Name,
    //             Contact_Action__r.Contact__r.PersonEmail,
    //             Contact_Action__r.Contact__r.Name,
    //             Reminder_1__c,
    //             Reminder_2__c,
    //             Reminder_3__c
    //         FROM Disclosure_Action__c
    //         WHERE
    //             Disclosure__c = :disclosure.Id
    //             AND RecordTypeId = :recordTypeId
    //     ];
    //     System.debug(
    //         '\n\n disclosureActions:- \n\n' + disclosureActions + '\n\n'
    //     );
    // }

    // @IsTest
    // public static void InviteCodeForExistingInventorSignReminderTest() {
    //     String disclosureTitle = 'Test Delegate Action';

    //     // Constants
    //     Id disclosureRecordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
    //         .get('BioTang_Disclosure')
    //         .getRecordTypeId();
    //     DateTime theDate = DateTime.now().addDays(-30);
    //     Util.now = DateTime.now().addDays(-30 + 7);

    //     // Contacts
    //     Account inventorContact = SampleDataFactory.createContact(
    //         'Inventor',
    //         true,
    //         '123456781'
    //     );
    //     Account submittingContact = SampleDataFactory.createContact(
    //         'Jeff',
    //         true,
    //         '11345678'
    //     );
    //     Account jitContact = SampleDataFactory.createContact(
    //         'Bob',
    //         false,
    //         '02345678'
    //     ); // jitUser
    //     jitContact.InvitationCode__pc = 'INVCODE02';
    //     update jitContact;

    //     // Disclosure
    //     Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
    //         disclosureRecordTypeId,
    //         disclosureTitle,
    //         'Draft',
    //         submittingContact
    //     );
    //     Test.setCreatedDate(disclosure.Id, theDate);
    //     DisclosureInventor__c inventor = SampleDataFactory.createInventor(
    //         disclosure,
    //         true,
    //         inventorContact
    //     );
    //     DisclosureInventor__c inactiveInventor = SampleDataFactory.createInventor(
    //         disclosure,
    //         false,
    //         jitContact
    //     );

    //     disclosure.Status__c = 'Pending Department Approval';
    //     update disclosure;
    //     disclosure.Status__c = 'Approved';
    //     update disclosure;

    //     // The Inventor logged in, used the Invitation Code, but did not sign the disclosure
    //     SampleDataTest.getJitUser(jitContact);

    //     Id recordTypeId = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
    //         .get('Sign_Disclosure')
    //         .getRecordTypeId();
    //     List<Disclosure_Action__c> signDisclosureActions = [
    //         SELECT Id, CreatedDate
    //         FROM Disclosure_Action__c
    //         WHERE
    //             Disclosure__c = :disclosure.Id
    //             AND RecordTypeId = :recordTypeId
    //         LIMIT 2
    //     ];
    //     Test.setCreatedDate(signDisclosureActions[0].Id, theDate);
    //     Test.setCreatedDate(signDisclosureActions[1].Id, theDate);

    //     Test.startTest();
    //     Database.executeBatch(new DisclosureInventorSignReminder(), 2);
    //     Test.stopTest();

    //     // NonMit Inventor Reminder should not contain invitation code since user already signed In
    //     List<Notification__c> nonMitNotification = [
    //         SELECT Id, Template__c, Variables__c
    //         FROM Notification__c
    //         WHERE
    //             Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REMINDER
    //     ];
    //     System.assertEquals(
    //         2,
    //         nonMitNotification.size(),
    //         '2 notification, Inactive Kerb Contact and Active Kerb have only one Template'
    //     );
    //     Map<String, Object> jsonValInactiveKerb = (Map<String, Object>) JSON.deserializeUntyped(
    //         nonMitNotification[0].Variables__c
    //     );
    //     System.assertEquals(
    //         null,
    //         jsonValInactiveKerb.get('invitation_code'),
    //         'invitation_code should not be set'
    //     );
    //     System.assertEquals(
    //         Label.Disclosure_Notify_Inventor_Desc_Copy_BioTang,
    //         jsonValInactiveKerb.get('inventor_description_copy'),
    //         'inventor_description_copy should be set'
    //     );
    // }

    // private static Disclosure__c getDisclosureToTest(String title) {
    //     Disclosure__c disclosureToTest = [
    //         SELECT
    //             Id,
    //             Status__c,
    //             Name,
    //             Name__c,
    //             Case_Number__c,
    //             RecordType.name,
    //             SubmittedOnBehalf__c,
    //             Submitting_Contact__c,
    //             Submitting_Contact__r.Id,
    //             Submitting_Contact__r.Name,
    //             Submitting_Contact__r.PersonEmail,
    //             Submitting_Contact__r.AltEmail__pc
    //         FROM Disclosure__c
    //         WHERE Name__c = :title
    //         LIMIT 1
    //     ];
    //     return disclosureToTest;
    // }
}