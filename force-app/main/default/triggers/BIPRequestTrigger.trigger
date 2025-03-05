trigger BIPRequestTrigger on BIP_Request__c (before insert, after update) {
  // System.enqueueJob(new QueryQueueable('Pending'));
  // 
  // system.debug('Trigger------');
  //   if(Trigger.isAfter && Trigger.isInsert){
  //         BipRequestHelper.afterBipRequestInsert(trigger.new);
  //   }
    if(Trigger.isAfter && Trigger.isUpdate){
        BipRequestHelper.afterBipRequestUpdate(trigger.new,trigger.old);
    }
        
    // TODO this is a hack to set TLO officer for 1st release of Research@MIT .. will need to be removed
    // if(Trigger.isBefore && Trigger.isInsert) { 
    //   BipRequestTriggerHandler.onBeforeInsert(trigger.new);
        
    // }
}