@isTest
public class GetEmailData_Test {
    
    @testSetup
    static void setupTestData() {
        Account personAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id,
            PersonEmail = 'johndoe@example.com'
        );
        insert personAccount;

        BIP_Request__c bipRequest = new BIP_Request__c(
            Account_Number__c = '12345',
            Primary_PI_Lookup__c = personAccount.Id,
            Proposal_Number__c = '2387512',
            Request_Type__c = 'Standard',
            Due_Date__c = Date.today(),
            Comments__c = 'Test comments',
            Project_Title__c = 'Test Proposal'
        );
        
        
        
        
    BIP_Request__c childBipRequest = new BIP_Request__c(
        Parent_Bip__c = bipRequest.Id,
     Primary_PI_Lookup__c = personAccount.Id
        );
        
        List<sObject> lst = new List<sObject>{bipRequest,childBipRequest};
        insert lst;
    }

    @isTest
    static void testGetEmailInfo() {
        BIP_Request__c testRequest = [Select Id From BIP_Request__c LIMIT 1];


        Test.startTest();
        Map<String, Object> result = getEmailData.getEmailInfo(testRequest.Id);
        Test.stopTest();
         system.debug('result --'+result);
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        System.assert(result.containsKey('to'), 'Result should contain the "to" key');
        System.assert(result.containsKey('cc'), 'Result should contain the "cc" key');
        System.assert(result.containsKey('templateBody'), 'Result should contain the "templateBody" key');
     
    }
}