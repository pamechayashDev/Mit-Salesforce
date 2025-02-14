public with sharing class CRONJobEmailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    //NOT Database.Stateful
    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('CRONJobEmailBatch start: ' + bc.getJobId() );
        if (isBatchRunning()){
             System.debug('This batch can only process one job at a time: ' + bc.getJobId() );
             System.AbortJob(bc.getJobId());
             return Database.getQueryLocator([SELECT Id FROM Notification__c limit 0]); // Empty list
        }
        return Database.getQueryLocator([SELECT Id FROM Notification__c
                                    WHERE Status__c = 'Pending']);
    }
    public void execute(Database.BatchableContext bc, List<Notification__c> scope) {
        System.debug('CRONJobEmailBatch ' + scope.size() );
        if(scope != null && !scope.isEmpty()) {
            for(Notification__c notify : scope) {
                System.enqueueJob(new SendEmailJob(notify.Id), 0);
            }
        }
    }

    public Boolean isBatchRunning(){
        String currentBatchClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        return [
            SELECT count()
            FROM AsyncApexJob
            WHERE JobType='BatchApex'
            AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Holding' OR Status = 'Queued')
            AND ApexClass.Name = :currentBatchClassName
        ] > 1;
    }

    public void finish(Database.BatchableContext BC) {
        
    }

}