public class BipRequestHelper {
    public static void afterBIPPIInsert(List<BIP_PI__c> vBIPPIList){

        if (!Test.isRunningTest()) {
            System.enqueueJob(new QueryQueueable(vBIPPIList));
        }
    }
    
}