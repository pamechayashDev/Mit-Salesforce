trigger OpenSourceTrigger on Open_Source__c (before insert, before update, after delete) {
    if(Trigger.isInsert && Trigger.isBefore) {
        OpenSourceTriggerHandler.onBeforeInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore) {
        OpenSourceTriggerHandler.onBeforeUpdate(Trigger.new);
    }
    if(Trigger.isDelete && Trigger.isAfter) {
        OpenSourceTriggerHandler.onAfterDelete(Trigger.old);
    }
}