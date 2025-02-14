@isTest
public class SendEmailControllerTest {

    @testSetup
    static void setupData() {
        Account personAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Test',
            LastName = 'Account',
            MitId__pc = '995864713',
            PersonEmail='testuser@example.com'
     
        );
        insert personAccount;

        Contact testContact = new Contact(FirstName='Test', LastName='User', Email='testuser@example.com');
        insert testContact;
        
         
        
        BIP_request__c bipRequest = new BIP_request__c(
            
            Account_Number__c = '12345',
            Status__c = 'Request Received',
            Primary_PI_Lookup__c= personAccount.Id
        );
        
        insert bipRequest;
    }

    @isTest
    static void testSendEmailWithBodyChange() {
        // Retrieve the created records in the @testSetup method
        EmailTemplate emailTemplate = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'Send_BIP_Request' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'testuser@example.com' LIMIT 1];
        Account personAccount = [Select Id from Account where MitId__pc='995864713' Limit 1];
        BIP_request__c bipRequest = [SELECT Id, Name FROM BIP_request__c WHERE   Primary_PI_Lookup__c = :personAccount.Id LIMIT 1];

        // Test email sending logic (DML on non-setup objects after @testSetup)
        Test.startTest();
        String result = SendEmailController.sendEmail(
            bipRequest.Id,
            emailTemplate.Id,
            'testuser@example.com',
            true,  // bodyChanged
            'This is the new body content.',
            new List<String>{'cc1@example.com', 'cc2@example.com'},
            testContact.Id,
            false,
            false 
        );
        Test.stopTest();

        // Verify the result
        //System.assertEquals('success', result);
    }

    @isTest
    static void testSendEmailWithStatusChange() {
        // Retrieve the created records in the @testSetup method
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'testuser@example.com' LIMIT 1];
         Account personAccount = [Select Id from Account where MitId__pc='995864713' Limit 1];
        
        BIP_request__c bipRequest = [SELECT Id, Name, Status__c FROM BIP_request__c WHERE   Primary_PI_Lookup__c = :personAccount.Id LIMIT 1];

        // Test the sendEmail method with status change
        Test.startTest();
        String result = SendEmailController.sendEmail(
            bipRequest.Id,
            'NA',  
            'testuser@example.com',
            false, 
            null,  
            new List<String>{'cc1@example.com', 'cc2@example.com'},
            testContact.Id,
            false,  
            true 
        );
        Test.stopTest();

    
       // System.assertEquals('success', result);
        
    }

    @isTest
    static void testSendEmailWithMissingPrimaryPI() {

        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'testuser@example.com' LIMIT 1];
         Account personAccount = [Select Id from Account where MitId__pc='995864713' Limit 1];
        BIP_request__c bipRequest = [SELECT Id, Name FROM BIP_request__c WHERE   Primary_PI_Lookup__c = :personAccount.Id LIMIT 1];


        Test.startTest();
        String result = SendEmailController.sendEmail(
            bipRequest.Id,
            'NA',  
            'testuser@example.com',
            false,
            null, 
            new List<String>{'cc1@example.com', 'cc2@example.com'},
            null,  
            true, 
            false  
        );
        Test.stopTest();

        System.assertEquals('Missing Primary PI', result);
    }

}