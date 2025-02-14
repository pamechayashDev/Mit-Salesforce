@isTest
public class IpiaRecordFetchTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data for IPIA_Acknowledgement__c
        IPIA_Acknowledgement__c ipiaAck = new IPIA_Acknowledgement__c(
            Name = 'Test Acknowledgement',
            Date_Acknowledged__c = Date.today(),
            Acknowledged__c = true,
            Mit_Id__c = '929742457'
        );
        insert ipiaAck;
        
        // Create test data for IPIA_Record__c
        IPIA_Record__c ipiaRecord = new IPIA_Record__c();
        ipiaRecord.FormName__c = 'test test';
        ipiaRecord.MitId__c = '929742457';
        insert ipiaRecord;
        
        // Create test data for IPIA_Record__c
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c();
        ipiaRecord2.FormName__c = 'test test2';
        ipiaRecord2.MitId__c = '929742457';
        insert ipiaRecord2;
    }
    
    @isTest
    static void testGetIpiaAckByMitId() {
        // Positive test for getIpiaAckByMitId
        Test.startTest();
        String testMitId = '929742457';
        IPIA_Acknowledgement__c result = IpiaRecordFetch.getIpiaAckByMitId(testMitId);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result, 'IPIA Acknowledgement should not be null');
        System.assertEquals('929742457', result.Mit_Id__c, 'Mit Id should match'); 
        System.assertEquals(true, result.Acknowledged__c, 'Acknowledged flag should be true');
    }
    
    @isTest
    static void testDeleteIpiaRecords_Success() {
        System.runAs(TestUtility.createSystemAdministrator()) {
            // Query the IPIA_Record__c created in @testSetup
            IPIA_Record__c ipiaRecord = [SELECT Id FROM IPIA_Record__c where FormName__c = 'test test2' LIMIT 1];

            // Positive test for deleteIpiaRecords
            Test.startTest();
            String result = IpiaRecordFetch.deleteIpiaRecords(ipiaRecord.Id);
            Test.stopTest();

            // Verify the record was deleted
            IPIA_Record__c [] deletedRecordList = [SELECT Id FROM IPIA_Record__c WHERE Id = :ipiaRecord.Id LIMIT 1];
            System.assertEquals(0, deletedRecordList.size(), 'IPIA record should be deleted');
        }
    }
    
    @isTest
    static void testDeleteIpiaRecords_Failure() {
        // Negative test for deleteIpiaRecords with invalid recordId
        Test.startTest();
        Boolean hasException = false;
        try {
            IpiaRecordFetch.deleteIpiaRecords('NonExistentId');
        }
        catch (Exception e) {
            hasException = true;
        }
        Test.stopTest();
        
        // Verify the error message
        Assert.isTrue(hasException, 'Result should return an error message');
    }
}