public with sharing class AsyncRequestHelper {

    // https://www.apexhours.com/generic-approach-to-salesforce-queueable/
    public static Async_Request__c prepareAsyncRequest(String recordId, String objectName, String jobName) {
        Async_Request__c asyn = new Async_Request__c();
        asyn.Has_Processed__c = false;
        asyn.Retry_Count__c = 0;
        asyn.Record_Id__c = recordId;
        asyn.sObject_Name__c = objectName;
        asyn.Job_Name__c = jobName;
        return asyn;
    }
}