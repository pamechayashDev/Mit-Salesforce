public class ForresterIPIAAsyncSaveHandler extends DataSource.AsyncSaveCallback {
    public final Id asyncRequestId;

    public ForresterIPIAAsyncSaveHandler(Id asyncRequestId) {
        this.asyncRequestId = asyncRequestId;
    }
    // Implement the handleResult method
    override public void processSave(Database.SaveResult saveResult) {
         Async_Request__c asyncRequest = [SELECT
                                    Id,
                                    Has_Processed__c,
                                    Retry_Count__c,
                                    Record_Id__c,
                                    sObject_Name__c,
                                    Job_Name__c
                                FROM Async_Request__c
                                WHERE
                                   Id = :asyncRequestId
                            ];

        if (saveResult.isSuccess()) {
            System.debug('🐞 ~ ForresterIPIAAsyncSaveHandler ~ processSave ~ saveResult:' + JSON.serializePretty(saveResult));
            asyncRequest.Has_Processed__c = true;
        } else {
            System.debug('Error saving record: ' + saveResult.getErrors()[0].getMessage());
            asyncRequest.Has_Processed__c = false;
            asyncRequest.Retry_Count__c =  Integer.valueOf(asyncRequest.Retry_Count__c) + 1;
        }
        update asyncRequest;
    }
}