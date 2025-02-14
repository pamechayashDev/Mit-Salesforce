@isTest
public with sharing class EmailTest {

    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
        String templateName = NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST;

        EmailTemplateBuilder builder = new EmailTemplateBuilder();
        insert builder.build();

        Map<String,String> variables = new Map<String,String>();
        variables.put('disclosure_title', 'Title');
        variables.put('disclosure_name', 'Name');
        Notification__c newNotification = NotificationBuilder.buildNotificationEmail('test@mit.edu', templateName, variables);
        insert newNotification;
    }

    private static Id getEmailId() {
        Notification__c notification = [SELECT Id FROM Notification__c WHERE TO__c = 'test@mit.edu'];
        return notification.Id;
    }

    @isTest
    public static void TestCRON() {
        SchedulableContext sc = null;
        CRONJobEmail cron = new CRONJobEmail();
        MockHttpCalloutCounter mock = new MockHttpCalloutCounter();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        cron.execute(sc);
        cron.execute(sc);
        Test.stopTest();
        
        List<Notification__c> testNotificationsCreated = [SELECT Id, Status__c
                                FROM Notification__c WHERE Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST];
        System.Assert(testNotificationsCreated[0].Status__c == 'Successful', 'Unexpected Email Send status');
        System.Assert(mock.counter == 1, 'Duplicate email notification callouts was made');
    }

    @isTest
    public static void TestEmail() {
        HttpMockFactory mock = new HttpMockFactory(201, 'OK', '{}', new Map<String,String>());

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        Email.sendEmail(new List<String>{'matty_w@mit.edu'}, NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST, new Map<String, String>{'name' => 'CRON Test Build', 'disclosure_list' => 'Disclosure Test'}, null, null, getEmailId());
        Test.stopTest();
    }

    // No Configuration exist, default to enabled status
    @isTest
    public static void TestEmailDefault() {
        HttpMockFactory mock = new HttpMockFactory(201, 'OK', '{}', new Map<String,String>());

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        String templateName = NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST;
        Email.sendEmail(new List<String>{'matty_w@mit.edu'}, templateName, new Map<String, String>{'name' => 'CRON Test Build', 'disclosure_list' => 'Disclosure Test'}, null, null, getEmailId());

        List<Notification__c> testNotificationsCreated = [SELECT Id, Name, BCC__c, CC__c, Failure_Count__c, Status__c, Template__c, To__c, Variables__c
                FROM Notification__c WHERE Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST];
        System.Assert(testNotificationsCreated.size() == 1, 'One email template need to exist');

        System.Assert(testNotificationsCreated[0].Status__c == 'Successful', 'Unexpected Email Send status');
        Test.stopTest();

    }

    @isTest
    public static void TestEmailBatchConcurrency() {

        List<Notification__c> scopeOne = new List<Notification__c>();
        List<Notification__c> scopeTwo = new List<Notification__c>();

        Database.BatchableContext bc = new BatchableContextMock();
        CRONJobEmailBatch batch = new CRONJobEmailBatch();

        // First Batch
        Database.QueryLocator qlOne = batch.start(bc);
        Database.QueryLocatorIterator iteratorOne = qlOne.iterator();


        // Second Batch
        Database.QueryLocator qlTwo = batch.start(bc);
        Database.QueryLocatorIterator iteratorTwo = qlTwo.iterator();
        if(iteratorTwo.hasNext()){
            Notification__c notification = (Notification__c) iteratorTwo.next();
            scopeTwo.add(notification);
        }


        MockHttpCalloutCounter mock = new MockHttpCalloutCounter();
        Test.setMock(HttpCalloutMock.class, mock);
        batch.execute(bc, scopeTwo);

        Test.startTest();
        if(iteratorOne.hasNext()){
            Notification__c notification = (Notification__c) iteratorOne.next();
            scopeOne.add(notification);
        }
        batch.execute(bc, scopeOne);
        Test.stopTest();

        System.Assert(mock.counter == 1, 'Duplicate email notification callouts was made');


    }

    @isTest
    public static void TestEmailEnabled() {
        HttpMockFactory mock = new HttpMockFactory(201, 'OK', '{}', new Map<String,String>());


        String templateName = NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST;

        Email_Templates__c emailTemplateSettings = NotificationBuilder.getEmailTemplateCustomSettings(templateName);
        emailTemplateSettings.Enabled__c = true;
        update emailTemplateSettings;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        Email.sendEmail(new List<String>{'matty_w@mit.edu'}, templateName, new Map<String, String>{'name' => 'CRON Test Build', 'disclosure_list' => 'Disclosure Test'}, null, null, getEmailId());

        List<Notification__c> testNotificationsCreated = [SELECT Id, Name, BCC__c, CC__c, Failure_Count__c, Status__c, Template__c, To__c, Variables__c
                FROM Notification__c WHERE Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST];
        System.Assert(testNotificationsCreated.size() == 1, 'One email template need to exist');

        System.Assert(testNotificationsCreated[0].Status__c == 'Successful', 'Unexpected Email Send status');
        Test.stopTest();

    }

    @isTest
    public static void TestEmailDisabled() {
        HttpMockFactory mock = new HttpMockFactory(201, 'OK', '{}', new Map<String,String>());

        String templateName = NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST;

        Email_Templates__c emailTemplateSettings = NotificationBuilder.getEmailTemplateCustomSettings(templateName);
        emailTemplateSettings.Enabled__c = false;
        update emailTemplateSettings;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        Email.sendEmail(new List<String>{'matty_w@mit.edu'}, templateName, new Map<String, String>{'name' => 'CRON Test Build', 'disclosure_list' => 'Disclosure Test'}, null, null, getEmailId());

        List<Notification__c> testNotificationsCreated = [SELECT Id, Name, BCC__c, CC__c, Failure_Count__c, Status__c, Template__c, To__c, Variables__c
                FROM Notification__c WHERE Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST];
        System.Assert(testNotificationsCreated.size() == 1, 'One email template need to exist');

        System.Assert(testNotificationsCreated[0].Status__c == 'Disabled', 'Unexpected Email Send status');
        Test.stopTest();

    }

    @isTest
    public static void TestEmailDisableBuilder() {
        EmailTemplateBuilder builder = new EmailTemplateBuilder();
        builder.disableDeptHeadEndorsementRequest()
        .disableDeptHeadEndorsementRequestDelegated()
        .disableDeptHeadEndorsementProxied()
        .disableDeptHeadEndorsementReminder()
        .disableInventorEndorsementRequestDelegated()
        .disableInventorSignatureRequired()
        .disableInventorSignatureReminder()
        .disableRenewInvitationCode()
        .disableInventorDeclinedByDeptHead()
        .disableInventorRejectedByTlo()
        .disableSubmitterDraftReminder()
        .disableInventorDraftDeletion()
        .disableInventorDraftArchived()
        .disableSubmitterDraftArchived()
        .disablePrimInventorSubmitterEndorsedAndApproved()
        .disableSubmitterApprovedByTlo()
        .disablePrimInventorDraftReview()
        .disablePrimInventorRemoved()
        .disablePrimInventorDeleted()
        .disablePrimInventorDraftSubmittedForApproval()
        .disableInventorApprovedInventorDeleted()
        .disableOpsNewDisclosureReceived()
        .disableOpsDeclinedByDeptHead()
        .disableOpsAllInventorsSigned()
        .disableOpsPerInventorsSigned()
        .disableOpsPerInventorsOptOut()
        ;


        List<Email_Templates__c> templateSettings = builder.build();
        for(Email_Templates__c setting: templateSettings) {
            System.assert(setting.Enabled__c == false, 'Email Template Custom Setting not disabled ' + setting.Name );
        }
    }

    private class MockHttpCalloutCounter implements HttpCalloutMock {
        // Implement this interface method
        public Integer counter = 0;
        public HTTPResponse respond(HTTPRequest req) {
            counter++;
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
        }
    }
}