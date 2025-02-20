@isTest
public class BipRequestController_Test {

    // Utility method to create a mock BIP Request
    private static BIP_Request__c createMockBIPRequest(String recordTypeLabel) {
        BIP_Request__c bipRequest = new BIP_Request__c();
        // Set additional fields as necessary
        return bipRequest;
    }
    
    // Utility method to create test data for Bip_Pis
    private static List<Map<String,String>> createMockBipPis() {
        List<Map<String,String>> bipPis = new List<Map<String,String>>();
        Map<String,String> piData = new Map<String,String>{
            'mitId' => '123',
            'personRole' => 'PI'
        };
        bipPis.add(piData);
        return bipPis;
    }

    // Test method for a successful KC Proposal creation
    @isTest
    static void testCreateBIPReqKcProposal() {
        Test.startTest();
        // Setup data
        BIP_Request__c bipRequest = createMockBIPRequest('KC Proposal');
        String recordType = 'KC Proposal';
        List<Map<String,String>> bipPis = createMockBipPis();
        Map<String,String> accountData = new Map<String,String>{'123' => '001xx000003DGv9AAG'};
        String fileBase64 = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        String fileName = 'testFile.pdf';

        // Perform test
        String resultId = BipRequestController.createBIPReq(bipRequest, recordType, bipPis, accountData, fileBase64, fileName);
        
        // Verify results
        System.assertNotEquals(null, resultId, 'The BIP Request ID should not be null');
        BIP_Request__c resultBipRequest = [SELECT Id, RecordTypeId FROM BIP_Request__c WHERE Id = :resultId];
        System.assertNotEquals(null, resultBipRequest, 'Inserted BIP Request should be retrievable from database');
        
        // Verify related Bip_Pi__c records are created
        List<Bip_Pi__c> bipPisResult = [SELECT Id, Role__c, PI__c FROM Bip_Pi__c WHERE BIP_Request__c = :resultId];
        System.assertEquals(1, bipPisResult.size(), 'There should be one Bip_Pi__c record linked to the BIP Request');
        System.assertEquals('Primary PI', bipPisResult[0].Role__c, 'The role of the PI should be correctly set');
        
        Test.stopTest();
    }

    // Test with non-KC Proposal
    @isTest
    static void testCreateBIPReqNonKcProposal() {
        Test.startTest();
        // Setup data
        BIP_Request__c bipRequest = createMockBIPRequest('Non-KC Proposal');
        String recordType = 'Non-KC Proposal';
        List<Map<String,String>> bipPis = createMockBipPis();
        Map<String,String> accountData = new Map<String,String>{'123' => '001xx000003DGv9AAG'};
        String fileBase64 = '';
        String fileName = '';

        // Perform test
        String resultId = BipRequestController.createBIPReq(bipRequest, recordType, bipPis, accountData, fileBase64, fileName);

        // Asserts for Non-KC Proposal specific logic
        System.assertNotEquals(null, resultId, 'The BIP Request ID should not be null for Non-KC Proposal');
        Test.stopTest();
    }

    // Test for exception handling
    @isTest
    static void testCreateBIPReqExceptionHandling() {
        Test.startTest();
        // Intentionally passing null values to cause an exception
        try {
            BipRequestController.createBIPReq(null, null, null, null, null, null);
            System.assert(false, 'Expected an exception to be thrown');
        } catch (AuraHandledException e) {
            System.assert(true, 'Correctly caught an AuraHandledException as expected');
        }
        Test.stopTest();
    }

    // Test future method for case retrieval and manipulation
    @isTest
    static void testGetCases() {
        // Prepare data
        BIP_Request__c bipRequest = createMockBIPRequest('KC Proposal');
        insert bipRequest;
        Bip_Pi__c bipPi = new Bip_Pi__c(BIP_Request__c = bipRequest.Id, PI__c = '001xx000003DGv9AAG', Role__c = 'Primary PI');
        insert bipPi;

        Test.startTest();
        BipRequestController.getCases(bipRequest.Id);
        Test.stopTest();
        
        // Assertions can be expanded based on actual method implementations and expected outcomes
    }
}