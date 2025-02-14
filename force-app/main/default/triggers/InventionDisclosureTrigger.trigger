trigger InventionDisclosureTrigger on Invention_Disclosure__c (before insert, before update, after insert, after update) {
    
    if(trigger.isBefore && trigger.isInsert) {
        InventionDisclosureTriggerHandler.onBeforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate) {
        InventionDisclosureTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert) {
        InventionDisclosureTriggerHandler.onAfterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate) {
        InventionDisclosureTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
}