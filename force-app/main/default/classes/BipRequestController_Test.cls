@isTest
private class BipRequestController_Test {
    @testSetup
    static void setupTestData() {
         ApiConfigurations__c config = new ApiConfigurations__c(Name = 'piDashApi', Api_Base__c = 'https://example.com', Api_Path__c = '/proposals/all');
        insert config;
        // Create Test Account
        Account personAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            MitId__pc ='920192001',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id,
            PersonEmail = 'johndoe@example.com'
        );
        insert personAccount;

           Account personAccountForBipPi = new Account(
            FirstName = 'John',
            LastName = 'Doe',
             MitId__pc ='995864713',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id,
            PersonEmail = 'johndoe@example.com'
        );
        insert personAccountForBipPi;

    }

    @isTest
    static void testCreateBIPReqForKcProposal() {
     
        testCreateBIPReq('KC Proposal');

    }
    
     @isTest
    static void testCreateBIPReqForNonKcProposal() {

        testCreateBIPReq('Non-KC Proposal');
 
    }
    static void testCreateBIPReq(String recordType) {
       Account personAccountForBipPi = [Select Id from Account where MitId__pc = '995864713'];
       Account personAccount = [Select Id from Account where MitId__pc = '920192001'];
        BIP_Request__c bipRequest = new BIP_Request__c(
            Primary_PI_Lookup__c = personAccount.Id,
            Proposal_Number__c = '11111',
            Request_Type__c = 'Standard',
            Due_Date__c = Date.today(),
            Comments__c = 'Test comments',
            Project_Title__c = 'Test Proposal'
        );

        List<Map<String, String>> bipPis = new List<Map<String, String>>{
            new Map<String, String>{'personRole' => 'PI', 'mitId' => '995864713'}
        };
        Map<String, String> accountData = new Map<String, String>{'995864713' => personAccountForBipPi.Id};

        String fileBase64 = 'U29tZUJhc2U2NERhdGE='; // Base64 encoded dummy data
        String fileName = 'TestFile.pdf';

        Test.startTest();
        String bipRequestId = BipRequestController.createBIPReq(bipRequest, recordType, bipPis, accountData, fileBase64, fileName);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, bipRequestId, 'BIP Request should be created');
        System.assertEquals(1, [SELECT COUNT() FROM BIP_Request__c WHERE Id = :bipRequestId]);
        System.assertEquals(1, [SELECT COUNT() FROM BIP_PI__c WHERE BIP_Request__c = :bipRequestId]);

          // Assertions for file
        ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :bipRequestId LIMIT 1];
        System.assertNotEquals(null, cdl, 'ContentDocumentLink should be created');
        System.assertNotEquals(null, cdl.ContentDocumentId, 'File should be linked to the BIP Request');
     
    }
  
      private class MockKualiCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            // Mock JSON response similar to expected KualiResponse structure
            String mockResponse = '{"totalPages": 1, "totalItems": 1, "results": [{"title": "test title", "startDate": "2023-07-01T00:00:00.000Z", "sponsorName": "NIH", "sponsorCode": "000340", "proposalType": "DevelopmentProposal", "proposalNumber": "64693", "proposalId": "64693", "people": [{"personRole": "PI", "personName": "test person", "mitId": "912654568"}, {"personRole": "COI", "personName": "person for test 1", "mitId": "992069559"}, {"personRole": "KP", "personName": "person for test 2", "mitId": "916615670"}], "leadUnitName": "McGovern Institute for Brain Research", "leadUnitId": "400600", "endDate": "2025-06-30T00:00:00.000Z", "deadlineDate": "2022-12-08T00:00:00.000Z"}] }';
            res.setBody(mockResponse);
            
            return res;
        }
    }
 @isTest
    static void testGetKualiResponseByProposalId() {
        // Set up the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockKualiCallout());
        
        // Execute the method under test
     Test.startTest();
        String testProposalId = '64693';
        Map<String, Object> response = BipRequestController.getKualiResponseByProposalId(testProposalId);
      Test.stopTest();          

        // Verify response is not null
        System.assertNotEquals(response, null, 'Response should not be null');
        
        // Validate the response structure
        System.assert(response.containsKey('results'), 'Response should contain results key');
        List<Object> results = (List<Object>) response.get('results');
        System.assert(results.size() > 0, 'Results should not be empty');
        

        // Verify data inside the response
        Map<String, Object> firstResult = (Map<String, Object>) results[0];
        System.assertEquals('test title', firstResult.get('title'), 'Title should match the mock response');
         System.assertEquals('NIH', firstResult.get('sponsorName'), 'Sponsor Name should match the mock response');
    }






}