@IsTest
public with sharing class IPIADocuSignDownloadBatchScheduleTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @isTest
    public static void testScheduleAbort() {
        Test.startTest();
        IPIADocuSignDownloadBatchSchedule.scheduleMe();
        IPIADocuSignDownloadBatchSchedule.abortSchedule();
        Test.stopTest();
    }


    @IsTest
    public static void testRetryIPIADownload() {
       HttpMockBlobFactory mock = new HttpMockBlobFactory(201, 'OK', '', new Map<String,String>());

       IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Other', Exemption__c = true, Status__c = 'Active');
       insert ipiaType1;

       String envelopeId = 'e00cd216-2997-469e-996e-a19177aa4d47';
       IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = ipiaType1.Name, MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2), IPIA_Type__c = ipiaType1.Id, DocusignEnvelopeId__c = envelopeId);
       List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1};

       insert ipiaRecords;
       try {
            Test.startTest();
            IPIADocuSignDownloadBatch batchJob = new IPIADocuSignDownloadBatch();
            Database.executeBatch(batchJob, 1); // Can only process one at a time.
            Test.stopTest();
            System.assert(false,'Exception not thrown');
       } catch(Exception e) {
       }
       List<Async_Request__c> asyncReqs = [
                                 SELECT
                                     Id,
                                     Has_Processed__c,
                                     Retry_Count__c,
                                     Record_Id__c,
                                     sObject_Name__c
                                 FROM Async_Request__c
                                 WHERE
                                     sObject_Name__c = 'IPIA_Record__c'
                                     AND Job_Name__c = 'IPIADownloadSignedJob'
                                     AND Has_Processed__c = false

                             ];
       System.assert(asyncReqs.size() == 1, 'Expecting one Async Request');

    }

}