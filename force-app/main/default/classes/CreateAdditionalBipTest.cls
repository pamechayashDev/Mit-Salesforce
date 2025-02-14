@isTest
public class CreateAdditionalBipTest {
    @isTest
    public static void testCreateAdditionalBips() {
        // Create a test BIP_Request__c record
            Account personAccount1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Test',
            LastName = 'Bip Account',
            MitId__pc ='100000',
            PersonEmail='testuser1@example.com'
     
        );
        insert personAccount1;
        BIP_Request__c bipRequest = new BIP_Request__c(
           
            Approved__c = false,
            Comments__c = 'Test Comments',
            Due_Date__c = Date.today().addDays(7),
            email_CCs__c = 'test@test.com',
        
            OSP_Contact__c = 'Test OSP Contact',
   
       
       
            Project_Description__c = 'Test Project Description',
            Proposal_Number__c = '12345',
           
            Request_Type__c = 'Standard',
             Primary_Pi_Lookup__c = personAccount1.Id,
          
            Sponsor_Name_Text__c = 'Test Sponsor',
            Status__c = 'Request Received',
  
            Project_Title__c = 'Test Project Title'
        );
        insert bipRequest;

        // Create test Account records for additional PIs
        List<Account> additionalAccounts = new List<Account>();
        for (Integer i = 1; i <= 2; i++) {
             Account personAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Test',
            LastName = 'Account '+i,
            MitId__pc ='000000'+i,
            PersonEmail='testuser@example.com'
                 
     
        );
      additionalAccounts.add(personAccount);
            
        }
        insert additionalAccounts;

        // Call the method
        Test.startTest();
        String result = CreateAdditionalBip.createAdditionalBips(bipRequest.Id, new List<String>{ additionalAccounts[0].Id, additionalAccounts[1].Id });
        Test.stopTest();

        // Assertions
        System.assertEquals('Success', result, 'The result should be "Success".');

        // Verify that BIP_PI__c records were inserted
        List<BIP_PI__c> insertedBips = [SELECT Id, BIP_Request__c, PI__c, Role__c, Status__c FROM BIP_PI__c WHERE BIP_Request__c = :bipRequest.Id];
        System.assertEquals(3, insertedBips.size(), 'Three BIP_PI__c records should have been inserted (1 Primary PI and 2 Additional PIs).');

        // Validate roles and statuses
        System.assertEquals('Primary PI', insertedBips[0].Role__c, 'The first record should have the role "Primary PI".');
        System.assertEquals('Pending Assignment', insertedBips[0].Status__c, 'The status should be "Pending Assignment".');

        for (Integer i = 1; i < insertedBips.size(); i++) {
            System.assertEquals('Additional PI', insertedBips[i].Role__c, 'The additional records should have the role "Additional PI".');
            System.assertEquals('Pending Assignment', insertedBips[i].Status__c, 'The status should be "Pending Assignment".');
        }
    }
}