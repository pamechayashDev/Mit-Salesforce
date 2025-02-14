@IsTest
public class BipRequestController_Test {
     static Id personAccountRecordTypeId;
       @TestSetup
    static void setup() {
        // Query for Person Account Record Type Id using SOQL
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        personAccountRecordTypeId = rt.Id;

        // Create a Person Account
        Account personAccount = new Account(
            LastName = 'Test Person',
            RecordTypeId = personAccountRecordTypeId // Make sure this is assigned if using Record Types
        );
        
        insert personAccount;
                 ApiConfigurationBuilder apiConfigBuilder = new ApiConfigurationBuilder();
        
        List<ApiConfigurations__c> apiConfigs = apiConfigBuilder.peopleSearchApi('AWS_API', 'people-search-v1').build();
    insert apiConfigs;
    }
    

@isTest
    public static void testCreateBIPReq_KCProposal() {
        BIP_Request__c bipRequest = new BIP_Request__c(
            Proposal_Number__c = '1234',
            Request_Type__c ='Standard',
            Due_Date__c = Date.Today(),
            Project_Description__c = 'Test KC BIP Request',
            Comments__c = 'Test Comment'
        );

        String recordType = 'KC Proposal';

        Test.startTest();
        String bipRequestId = BipRequestController.createBIPReq(bipRequest, recordType);
        Test.stopTest();

        BIP_Request__c createdBipRequest = [SELECT Id, RecordTypeId FROM BIP_Request__c WHERE Id = :bipRequestId LIMIT 1];

        String kcProposalTypeId = Schema.SObjectType.BIP_Request__c.getRecordTypeInfosByName().get('KC Proposal').getRecordTypeId();
        System.assertEquals(kcProposalTypeId, createdBipRequest.RecordTypeId, 'Record Type ID should match the KC Proposal Record Type');
    }

    @isTest
    public static void testCreateBIPReq_NonKCProposal() {
        BIP_Request__c bipRequest = new BIP_Request__c(
            Proposal_Number__c = '1234',
            Request_Type__c ='Standard',
            Due_Date__c = Date.Today(),
            Project_Description__c = 'Test KC BIP Request',
            Comments__c = 'Test Comment'
        );

        String recordType = 'Non-KC Proposal';

        Test.startTest();
        String bipRequestId = BipRequestController.createBIPReq(bipRequest, recordType);
        Test.stopTest();

        BIP_Request__c createdBipRequest = [SELECT Id, RecordTypeId FROM BIP_Request__c WHERE Id = :bipRequestId LIMIT 1];

        String nonKCProposalTypeId = Schema.SObjectType.BIP_Request__c.getRecordTypeInfosByName().get('Non-KC Proposal').getRecordTypeId();
        System.assertEquals(nonKCProposalTypeId, createdBipRequest.RecordTypeId, 'Record Type ID should match the Non-KC Proposal Record Type');
    }
    
    @isTest static void testCreateAdditionalBipsSuccess() {
        // Setup test data with proper references and data entries
        Account personAccount = [SELECT Id FROM Account WHERE LastName = 'Test Person' LIMIT 1];
        Map<String, String> accountData = new Map<String, String>{'123' => personAccount.Id};
        List<Map<String, String>> bipPis = new List<Map<String, String>>();
        bipPis.add(new Map<String, String>{'personRole' => 'Primary PI', 'mitId' => '123'});
        bipPis.add(new Map<String, String>{'personRole' => 'Additional PI', 'mitId' => '123'});

        // Create a dummy BIP Request record
        BIP_Request__c bipRequest = new BIP_Request__c();
        insert bipRequest;

        // Call the method
        Test.startTest();
        String result = BipRequestController.createAdditionalBips(bipPis, bipRequest.Id, accountData);
        Test.stopTest();

        // Verify results
        System.assertEquals('Success', result);
        List<Bip_Pi__c> bipPiList = [SELECT Role__c, PI__c, BIP_Request__c FROM Bip_Pi__c];
 
    }
        @isTest static void testCreateAdditionalBipsException() {
        // Ensure there is a Person Account to link to
        Account personAccount = [SELECT Id FROM Account WHERE LastName = 'Test Person' LIMIT 1];

        // Setup test data with an empty accountData to ensure the method handles missing data gracefully
        Map<String, String> accountData = new Map<String, String>();
        List<Map<String, String>> bipPis = new List<Map<String, String>>();
        bipPis.add(new Map<String, String>{'personRole' => 'PI', 'mitId' => '123'}); // mitId does not match any key in accountData

        BIP_Request__c bipRequest = new BIP_Request__c();
        insert bipRequest;

        // Call the method and expect it to handle the situation without throwing an exception
        Test.startTest();
        try {
            String result = BipRequestController.createAdditionalBips(bipPis, bipRequest.Id, accountData);
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    
    
  

    @isTest
    public static void testSearchMethod() {
        
        // Create mock Account data
     RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        personAccountRecordTypeId = rt.Id;

        // Create a Person Account
        Account acc1 = new Account(
            LastName = 'John Doe',
            RecordTypeId = personAccountRecordTypeId,
            MitId__pc = 'M123',
            PersonEmail = 'john.doe@example.com'
        );
        insert acc1;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBIPUtilsPeopleSearch());

        // Call the method to test
        Map<String, Map<String, Object>> result = BipRequestController.search('John');

        Test.stopTest();

        // Assert the result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('M123'), 'Result should contain the key M123');
        System.assertEquals('John Doe', result.get('M123').get('Name'), 'Name should match');
     
    }
    
    
     @isTest
    public static void testGetResponseForAccountCreations() {
        
        // Prepare mock data
        List<Map<String, String>> bipPis = new List<Map<String, String>>();
        Map<String, String> entry = new Map<String, String>();
        entry.put('mitId', '900047159');
        bipPis.add(entry);

        // Mock HTTP Callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,  new MockBIPUtilsPeopleSearch());

        // Call the method
        Map<Integer, List<Object>> result = BipRequestController.getResponseForAccountCreations(bipPis);

        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assertEquals(1, result.size(), 'Result map size should be 1');
        System.assertEquals('900047159', result.get(0)[1], 'MitId should match');
    }
    
    

    
    @isTest
    public static void testUploadFile() {
        // Prepare mock base64 string and filename
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        String filename = 'TestFile.txt';

        // Create a test Account to link the file
         BIP_Request__c tesBip = new BIP_Request__c(
            Proposal_Number__c = '1234',
            Request_Type__c ='Standard',
            Due_Date__c = Date.Today(),
            Project_Description__c = 'Test KC BIP Request',
            Comments__c = 'Test Comment'
        );

        insert tesBip;

        Test.startTest();
        //String contentLinkId = BipRequestController.uploadFile(base64, filename, tesBip.Id);
        Test.stopTest();

        // Assert content link creation
        //System.assertNotEquals(null, contentLinkId, 'ContentDocumentLink Id should not be null');

        // Verify the ContentVersion
        // ContentVersion cv = [SELECT Title FROM ContentVersion WHERE Title = :filename LIMIT 1];
        // System.assertEquals(filename, cv.Title, 'ContentVersion title should match');

        // Verify the ContentDocumentLink
        // ContentDocumentLink cdl = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE Id = :contentLinkId LIMIT 1];
        // System.assertEquals(tesBip.Id, cdl.LinkedEntityId, 'LinkedEntityId should match the Account Id');
    }

  








    
    
    
    
    
    
    
    
    
    
}