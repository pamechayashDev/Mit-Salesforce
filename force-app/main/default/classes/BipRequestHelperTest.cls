@isTest
public class BipRequestHelperTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data for Primary_PI_Lookup__c (Person Account)
        Account personAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id,
            MitId__pc = '900047159'
        );
        insert personAccount;
    

              
    }

    @isTest
    static void testAfterBipRequestInsert() {
        // Fetch the test data
        Account testPersonAccount = [SELECT Id FROM Account LIMIT 1];
     

        Test.startTest();
     BIP_Request__c  testBipRequest = new BIP_Request__c(Primary_PI_Lookup__c = testPersonAccount.Id);
        insert testBipRequest;
        Test.stopTest();
      system.debug('testBipRequest.Id'+testBipRequest.Id);
        // Assert that TLO_Case__c records were created
        //List<TLO_Case__c> tloCases = [SELECT Primary_PI__c, BIP_Request__c, ExternalCaseId__c FROM TLO_Case__c];
        //System.assert(tloCases.size()!=0);
        
    }


}