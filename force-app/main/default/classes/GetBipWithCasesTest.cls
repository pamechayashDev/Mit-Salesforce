@isTest
public class GetBipWithCasesTest {
    @isTest
    public static void testGetBipInfo() {
        // Create test data
        // Parent BIP_Request__c record
       

        // Primary PI record
              Account primaryPi = new Account(
            FirstName = 'Test 1',
            LastName = 'Test Lastname',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id,
            PersonEmail = 'test@example.com',
            MitId__pc = '12345'
        );
        
         BIP_Request__c bipRequest = new BIP_Request__c(
            Status__c = 'Request Received',
            TLO_Officer_Name__c = 'Test TLO Officer',
             Primary_Pi_Lookup__c =  primaryPi.Id
        );


 
        insert bipRequest;

        // Child BIP_Case_Junction__c records
        List<BIP_Case_Junction__c> bipCaseJunctions = new List<BIP_Case_Junction__c>();
        for (Integer i = 0; i < 2; i++) {
            BIP_Case_Junction__c junction = new BIP_Case_Junction__c(
                Case__c = 'CASE' + i,
                BIP_Request__c = bipRequest.Id
            );
            bipCaseJunctions.add(junction);
        }
        insert bipCaseJunctions;

        // Mock external Forrester_Case__x records
        List<Forrester_Case__x> forresterCases = new List<Forrester_Case__x>();
        for (Integer i = 0; i < 2; i++) {
            Forrester_Case__x caseRecord = new Forrester_Case__x(
                CASE_RECID__c = 'CASE' + i,
                CONTRACT_CASE_NUM__c = 'Contract' + i,
                DISCLOSURE_TITLE__c = 'Case Title ' + i,
                STATUS__c = 'Open',
                ADD_DATE__c = Date.today(),
                FIRST_PUBLISH_DATE__c = Date.today().addDays(30),
                TLO_NAME__c = 'TLO Officer ' + i,
                CASE_TYPE__c = 'Type ' + i,
                CASE_SPONSOR_NAMES__c = 'Sponsor ' + i
            );
            forresterCases.add(caseRecord);
        }
        Test.startTest();
       

        // Test for 'parent'
        List<String> vrecordIds = new List<String>();
        vrecordIds.add(bipRequest.Id);
        List<sObject> bipResult = GetBipWithCases.getBipInfo(vrecordIds, 'parent');
       
        System.assertEquals(1, bipResult.size(), 'Result size should be 1');
        BIP_Request__c resultParent = (BIP_Request__c) bipResult[0];
 

        // Test for 'child'
    
         BIP_PI__c bipPI = new BIP_PI__c(
                Role__c = 'Primary PI',
                Status__c = 'Pending Assignment',
                TLO_Officer_Name__c = 'Child TLO ',
                BIP_Request__c = bipRequest.Id,
                PI__c = primaryPi.Id

            );
        insert bipPI;
        vrecordIds = new List<String>();
        vrecordIds.add(bipPI.Id);

        List<sObject> bipPIResult = GetBipWithCases.getBipInfo(vrecordIds, 'child');
 
        System.assertEquals(1, bipPIResult.size(), 'Result size should be 1');

        Test.stopTest();
    }

  
}