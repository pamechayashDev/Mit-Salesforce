trigger TLOContactTrigger on TLO_Contact__c (before insert, after insert, before update, after update) {
    
    if(trigger.isBefore && trigger.isInsert) {
    	TLOContactTriggerHandler.onBeforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate) {
        TLOContactTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert) {
        TLOContactTriggerHandler.onAfterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate) {
        TLOContactTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
}