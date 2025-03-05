@isTest
public class BIPRequestHelperTest {
    
    @testSetup
    static void setupTestData() {

           Account personAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Test',
            LastName = 'Account',
            MitId__pc = '995864713',
            PersonEmail='testuser@example.com'
     
        );     
      insert personAccount;
        // Create a test BIP_Request__c record
      BIP_request__c bipRequest = new BIP_request__c(
            Status__c = 'Request Received',
            Project_Title__c = 'Test Project',
            Primary_PI_Lookup__c= personAccount.Id
        );
        insert bipRequest;
         BIP_PI__c bipPi = new BIP_PI__c(
            Role__c = 'Primary PI',
     BIP_request__c = bipRequest.Id
        );
        insert bipPi;
        
        
    BipEmailNotifications__c settings = new BipEmailNotifications__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Enabled__c = true,
            ToEmail__c = 'reroute@example.com'
        );
        insert settings;
    }

    @isTest
    static void testAfterBipRequestUpdate() {
        // Fetch the inserted record
        BIP_Request__c bipRequest = [SELECT Id, Status__c FROM BIP_Request__c LIMIT 1];

        Test.startTest();
        
        // Capture email count before update
        Integer emailsBefore = Limits.getEmailInvocations();
        
        // Update the record to trigger after update logic
        bipRequest.Status__c = 'Assigned to PI';

        update bipRequest;

        // Capture email count after update
        Integer emailsAfter = Limits.getEmailInvocations();

        Test.stopTest();

        // Assert that the email was sent
        System.assert(emailsAfter > emailsBefore, 'Expected an email to be sent on status change');
    }
}