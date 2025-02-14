public class IPIADocuSignDownloadBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    // Will retry Jobs that did not complete
    public class InvalidBatchSizeException extends Exception {
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        Integer retryCount = Integer.ValueOf(retryCount());
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Has_Processed__c,
                    Retry_Count__c,
                    Record_Id__c,
                    sObject_Name__c,
                    Job_Name__c
                FROM Async_Request__c
                WHERE
                   Has_Processed__c = FALSE
                   AND Retry_Count__c < :retryCount
                   AND sObject_Name__c = 'IPIA_Record__c'
                   AND Job_Name__c = 'IPIADownloadSignedJob'
                ORDER BY Job_Name__c
            ]
        );

    }

    public void execute(Database.BatchableContext bc, List<Async_Request__c> scope) {
       if (scope != null && !scope.isEmpty()) {
         Map<Id, Async_Request__c> asyncMap = new Map<Id, Async_Request__c>(scope);
         Integer delayInMinutes = 0;

         if (scope.size() > 1) {
            throw new InvalidBatchSizeException('Batchable can only add one Queueable Job');
         }
         // From a batch you can only add one Queueable Job
         // Use the same code base
         IPIADocuSignDownloadJob ipiaJob = new IPIADocuSignDownloadJob(scope[0].Id);
         System.enqueueJob(ipiaJob, delayInMinutes);
       }
    }

    public void finish(Database.BatchableContext bc) {
    }


    private static String retryCount() {
        return ConfigurationBuilder.getConfigurationToString(
            'batchJobMaxNumberOfRetry'
        );
    }
}