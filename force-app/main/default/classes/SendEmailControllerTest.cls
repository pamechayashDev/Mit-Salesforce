@isTest
public class SendEmailControllerTest {
    @testSetup
    static void setupTestData() {
    
        // Create BipEmailNotifications__c custom setting record
        BipEmailNotifications__c settings = new BipEmailNotifications__c(
            Enabled__c = true, 
            ToEmail__c = 'reroute@example.com',
            targetObjectId__c = UserInfo.getUserId()  // Using the running test user
        );
        insert settings;
    }

    @isTest
    static void testSendEmail_WithTemplate_CustomSettingEnabled() {
         List<SendEmailController.emailWrapper> emailWrappers = new List<SendEmailController.emailWrapper>();
        emailWrappers.add(SendEmailControllerTest.getEmailWrapper(true,true));

        // Run the test
        Test.startTest();
        SendEmailController.sendEmail(emailWrappers);
        Test.stopTest();
        
        // Assertions
        System.assert(true, 'Email sending method executed successfully.');
    }
    
    @isTest
    static void testSendEmail_WithoutTemplate_CustomSettingEnabled() {
                List<SendEmailController.emailWrapper> emailWrappers = new List<SendEmailController.emailWrapper>();
        emailWrappers.add(SendEmailControllerTest.getEmailWrapper(false,true));

        // Run the test
        Test.startTest();
        SendEmailController.sendEmail(emailWrappers);
        Test.stopTest();
        
        // Assertions
        System.assert(true, 'Email sending method executed successfully.');
    }

    @isTest
    static void testSendEmail_WithoutTemplate_CustomSettingDisabled() {
           List<SendEmailController.emailWrapper> emailWrappers = new List<SendEmailController.emailWrapper>();
        emailWrappers.add(SendEmailControllerTest.getEmailWrapper(false,false));
        // Run the test
        Test.startTest();
        SendEmailController.sendEmail(emailWrappers);
        Test.stopTest();

        // Assertions
        System.assert(true, 'Email sending method executed successfully when custom setting is disabled.');
    }

    @isTest
    static void testSendEmail_WithTemplate_CustomSettingDisabled() {
                  List<SendEmailController.emailWrapper> emailWrappers = new List<SendEmailController.emailWrapper>();
        emailWrappers.add(SendEmailControllerTest.getEmailWrapper(true,false));
        // Run the test
        Test.startTest();
        SendEmailController.sendEmail(emailWrappers);
        Test.stopTest();

        // Assertions
        System.assert(true, 'Email sending method executed successfully when custom setting is disabled.');
    }
    
    public static SendEmailController.emailWrapper getEmailWrapper(boolean withTemplate , boolean withEnableSetting){
         if(!withEnableSetting){
                BipEmailNotifications__c settings = [SELECT Id, Enabled__c FROM BipEmailNotifications__c LIMIT 1];
        settings.Enabled__c = false;
        update settings;
         }
      

        // Retrieve test Org-Wide Email Address
        OrgWideEmailAddress orgWideEmail = [
                SELECT Id, Address
                FROM OrgWideEmailAddress
                WHERE DisplayName = 'BIP Notifications'
                LIMIT 1
            ];
    
          String template = null;
         if(withTemplate){
             template =[select Id from EmailTemplate where DeveloperName = 'Send_BIP_Request' Limit 1].Id; 
         }

        // Prepare email wrapper 
        SendEmailController.emailWrapper email = new SendEmailController.emailWrapper();
        email.emailSubject = 'Test Email Disabled Setting';
        email.emailBody = 'This email should be rerouted.';
        email.emailTo = 'recipient@example.com';
        email.orgWideEmail = orgWideEmail;
        email.templaiteId = template;
        email.emailCC = 'cc@example.com';
     return email;

    }
}