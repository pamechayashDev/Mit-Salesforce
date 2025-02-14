trigger DisclosuresTrigger on Disclosure__c (before insert, after insert, before update, after update, before delete, after delete) {

    if(trigger.isInsert && trigger.isBefore) {
        DisclosuresTriggerHandler.onBeforeInsert(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore) {
        DisclosuresTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isInsert && trigger.isAfter) {
        DisclosuresTriggerHandler.onAfterInsert(trigger.new);
    }
    if(trigger.isUpdate && trigger.isAfter) {
    	DisclosuresTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isDelete && trigger.isBefore) {
        DisclosuresTriggerHandler.onBeforeDelete(trigger.old);
    }
    if(trigger.isDelete && trigger.isAfter) {
        DisclosuresTriggerHandler.onAfterDelete(trigger.old);
    }
    
}