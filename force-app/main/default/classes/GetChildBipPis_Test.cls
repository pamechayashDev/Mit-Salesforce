@isTest
public class GetChildBipPis_Test {
   @isTest
    public static void testGetData() {
     Account personAccount1 = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id,
            PersonEmail = 'johndoe1@example.com'
        );
         Account personAccount2 = new Account(
            FirstName = 'Test 1',
            LastName = 'Test Lastname',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id,
            PersonEmail = 'test@example.com',
            MitId__pc = '12345'
        );
         BIP_Request__c parentBip = new BIP_Request__c(
            Status__c = 'Request Received',
            TLO_Officer_Name__c = 'Test TLO Officer',
             Primary_Pi_Lookup__c =  personAccount1.Id
        );
        insert parentBip;
        insert new List<Account>{personAccount1,personAccount2};

        parentBip.Primary_PI_Lookup__c = personAccount1.Id;
        update parentBip;

        // Create child BIP_PI__c records and associate them with the parent
        List<BIP_PI__c> childBips = new List<BIP_PI__c>();
        for (Integer i = 0; i < 3; i++) {
            BIP_PI__c childBip = new BIP_PI__c(
                Role__c = 'Primary PI',
                Status__c = 'Pending Assignment',
                TLO_Officer_Name__c = 'Child TLO ' + i,
                BIP_Request__c = parentBip.Id,
                PI__c = personAccount2.Id

            );
            childBips.add(childBip);
        }
        insert childBips;


        Test.startTest();
        Map<String, Object> result = GetChildBipPis.getChildBipPisData(parentBip.Id);
        Test.stopTest();

        // Assertions
        System.assert(result.containsKey('childs'), 'Result map should contain "childs" key');
        System.assert(result.containsKey('primaryPiParent'), 'Result map should contain "primaryPiParent" key');

        // Validate child records
        List<BIP_PI__c> retrievedChildBips = (List<BIP_PI__c>) result.get('childs');
        System.assertEquals(3, retrievedChildBips.size(), 'There should be 3 child BIP records');

        // Validate parent information
        Map<String, String> primaryPiParent = (Map<String, String>) result.get('primaryPiParent');
        System.assertEquals(parentBip.Id, primaryPiParent.get('Id'), 'Parent BIP ID should match');
        System.assertEquals(personAccount1.Id, primaryPiParent.get('PrimaryPIId'), 'Primary PI ID should match');
        System.assertEquals(parentBip.Status__c, primaryPiParent.get('Status'), 'Parent BIP Status should match');
        System.assertEquals(parentBip.TLO_Officer_Name__c, primaryPiParent.get('TLO'), 'Parent BIP TLO Officer Name should match');
    }
}