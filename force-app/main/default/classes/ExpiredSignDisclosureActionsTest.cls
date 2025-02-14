@isTest
public with sharing class ExpiredSignDisclosureActionsTest {
    
    @TestSetup
    static void makeData(){
        TestSetup.defaultConfiguration();
    }

    @isTest
    public static void testCancelSignDisclosureActions_Test1() {

        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account inventorContact = SampleDataFactory.createContact('Bob', true, '123456781');
        Account inventorTwoContact = SampleDataFactory.createContact('Jack', false, '123456780');
        Account nonMitInventorContact = SampleDataFactory.createContact('Donald', false, null);
        Account submittingContact = SampleDataFactory.createContact('Jeff', true, '11345678');

        Disclosure__c disclosure120Days = SampleDataFactory.createDisclosureSOB(recordTypeIdSoftware, 'Title Of', 'Draft', submittingContact);
        Disclosure__c disclosure119Days = SampleDataFactory.createDisclosureSOB(recordTypeIdSoftware, 'Title Of', 'Draft', submittingContact);
        Disclosure__c disclosure999Days = SampleDataFactory.createDisclosureSOB(recordTypeIdSoftware, 'Title Of', 'Draft', submittingContact);

        Util.now = DateTime.newInstanceGmt(2024, 8, 1, 0 ,0 , 0);
        disclosure120Days.Last_Modified_at_time_of_Signing_Request__c = Util.now().addDays(-120); // DocuSign marked the Envelopes as 120 days
        disclosure119Days.Last_Modified_at_time_of_Signing_Request__c = Util.now().addDays(-119); // This should still be valid
        disclosure999Days.Last_Modified_at_time_of_Signing_Request__c = Util.now().addDays(-999);
        update new List<Disclosure__c> {disclosure120Days, disclosure119Days, disclosure999Days};

        createContactAction(disclosure120Days, inventorContact);
        createContactAction(disclosure119Days, inventorTwoContact);
        createContactAction(disclosure999Days, nonMitInventorContact);

        List<Disclosure_Action__c> actions = getPendingSignedActions();

        System.Assert(actions.size() == 3, 'Three Sign Disclosure actions should have been created, one for each Inventor on the Disclosures');

        Test.startTest();
            Integer lastNDaysBefore = 120;
            Integer lastNDaysAfter = 999;
            ExpiredSignDisclosureActions sfu = new ExpiredSignDisclosureActions(lastNDaysBefore, lastNDaysAfter);
            Database.executeBatch(sfu, 200);
        Test.stopTest();
        List<Disclosure_Action__c> actionsAfter = getPendingSignedActions();
        System.Assert(actionsAfter.size() == 1, 'Two Expired Sign Disclosure Actions should have been Canceled');

    }

    @isTest
    public static void testExpiryScheduler() {
        Test.startTest();

        Integer olderThan120 = ExpiredSignDisclosureActionsSchedule.getConfigValue(ExpiredSignDisclosureActionsSchedule.CANCEL_SIGN_ACTIONS_OLDER_THAN_120_DAYS, 12);
        Integer olderThan999 = ExpiredSignDisclosureActionsSchedule.getConfigValue(ExpiredSignDisclosureActionsSchedule.CANCEL_SIGN_ACTIONS_OLDER_THAN_999_DAYS, 99);
        Integer defaultConfig = ExpiredSignDisclosureActionsSchedule.getConfigValue('missingConfig', 800);

        SchedulableContext sc = null;
        ExpiredSignDisclosureActionsSchedule job = new ExpiredSignDisclosureActionsSchedule();
        job.execute(sc);
        Test.stopTest();

        System.assert(olderThan120 == 120, 'Config value not read');
        System.assert(olderThan999 == 999, 'Config value not read');
        System.assert(defaultConfig == 800, 'Default value not set');


    }


    @isTest
    public static void testCancelSignDisclosureActions_Test2() {

        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account inventorContact = SampleDataFactory.createContact('Bob', true, '123456781');
        Account inventorTwoContact = SampleDataFactory.createContact('Jack', false, '123456780');
        Account nonMitInventorContact = SampleDataFactory.createContact('Donald', false, null);
        Account submittingContact = SampleDataFactory.createContact('Jeff', true, '11345678');

        Disclosure__c disclosure120Days = SampleDataFactory.createDisclosureSOB(recordTypeIdSoftware, 'Title Of', 'Draft', submittingContact);
        Disclosure__c disclosure119Days = SampleDataFactory.createDisclosureSOB(recordTypeIdSoftware, 'Title Of', 'Draft', submittingContact);
        Disclosure__c disclosure999Days = SampleDataFactory.createDisclosureSOB(recordTypeIdSoftware, 'Title Of', 'Draft', submittingContact);

        Util.now = DateTime.newInstanceGmt(2024, 11, 29, 0, 0, 0); // 120 days in the future from 1st Aug
        disclosure120Days.Last_Modified_at_time_of_Signing_Request__c = Util.now().addDays(-120);
        disclosure119Days.Last_Modified_at_time_of_Signing_Request__c = Util.now().addDays(-119); // The expiry should be 999 for these
        disclosure999Days.Last_Modified_at_time_of_Signing_Request__c = Util.now().addDays(-999); // Still created before 1st Aug
        update new List<Disclosure__c> {disclosure120Days, disclosure119Days, disclosure999Days};

        createContactAction(disclosure120Days, inventorContact);
        createContactAction(disclosure119Days, inventorTwoContact);
        createContactAction(disclosure999Days, nonMitInventorContact);

        List<Disclosure_Action__c> actions = getPendingSignedActions();

        System.Assert(actions.size() == 3, 'Three Sign Disclosure actions should have been created, one for each Inventor on the Disclosure');

        Test.startTest();
            ExpiredSignDisclosureActions sfu = new ExpiredSignDisclosureActions();
            Database.executeBatch(sfu, 200);
        Test.stopTest();
        List<Disclosure_Action__c> actionsAfter = getPendingSignedActions();
        System.Assert(actionsAfter.size() == 2, 'One Expired Sign Disclosure Actions should have been Canceled');

    }

    @isTest
    public static void testCancelSignDisclosureActions_Test3() {

        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account inventorContact = SampleDataFactory.createContact('Bob', true, '123456781');
        Account inventorTwoContact = SampleDataFactory.createContact('Jack', false, '123456780');
        Account nonMitInventorContact = SampleDataFactory.createContact('Donald', false, null);
        Account submittingContact = SampleDataFactory.createContact('Jeff', true, '11345678');

        Disclosure__c disclosure120Days = SampleDataFactory.createDisclosureSOB(recordTypeIdSoftware, 'Title Of', 'Draft', submittingContact);
        Disclosure__c disclosure119Days = SampleDataFactory.createDisclosureSOB(recordTypeIdSoftware, 'Title Of', 'Draft', submittingContact);
        Disclosure__c disclosure999Days = SampleDataFactory.createDisclosureSOB(recordTypeIdSoftware, 'Title Of', 'Draft', submittingContact);


        Util.now = DateTime.newInstanceGmt(2027, 4, 27, 0, 0, 0); // 999 days in the future from 1st Aug
        disclosure120Days.Last_Modified_at_time_of_Signing_Request__c = Util.now().addDays(-120);
        disclosure119Days.Last_Modified_at_time_of_Signing_Request__c = Util.now().addDays(-119); // The expiry should be 999 for these
        disclosure999Days.Last_Modified_at_time_of_Signing_Request__c = Util.now().addDays(-999);
        update new List<Disclosure__c> {disclosure120Days, disclosure119Days, disclosure999Days};

        createContactAction(disclosure120Days, inventorContact);
        createContactAction(disclosure119Days, inventorTwoContact);
        createContactAction(disclosure999Days, nonMitInventorContact);

        List<Disclosure_Action__c> actions = getPendingSignedActions();

        System.Assert(actions.size() == 3, 'Three Sign Disclosure actions should have been created, one for each Inventor on the Disclosure');

        Test.startTest();
            ExpiredSignDisclosureActions sfu = new ExpiredSignDisclosureActions();
            Database.executeBatch(sfu, 200);
        Test.stopTest();
        List<Disclosure_Action__c> actionsAfter = getPendingSignedActions();
        System.Assert(actionsAfter.size() == 2, 'One Expired Sign Disclosure Actions should have been Canceled');

    }

    private static void createContactAction(Disclosure__c disclosure, Account contact) {
        Id recordTypeIdSignDisclosure = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName().get('Sign_Disclosure').getRecordTypeId();

        Contact_Action__c contactAction = new Contact_Action__c();
        contactAction.Status__c = 'Pending';
        contactAction.Contact__c = contact.Id;
        insert contactAction;


        Disclosure_Action__c signAction = new Disclosure_Action__c();
        signAction.Disclosure__c = disclosure.Id;
        signAction.RecordTypeId = recordTypeIdSignDisclosure;
        signAction.Contact_Action__c = contactAction.Id;
        insert signAction;


    }

     /*
     * Helper class for getting SignDisclosure Actions
     */
    private static List<Disclosure_Action__c> getPendingSignedActions() {
        Id recordTypeIdSignDisclosure = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
            .get('Sign_Disclosure')
            .getRecordTypeId();
        List<Disclosure_Action__c> actions = [
            SELECT Id, Contact_Action__r.Id
            FROM Disclosure_Action__c
            WHERE
                Contact_Action__r.Status__c = 'Pending'
                AND RecordTypeId = :recordTypeIdSignDisclosure
        ];
        return actions;
    }

}