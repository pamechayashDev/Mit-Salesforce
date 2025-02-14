trigger DisclosureInventorTrigger on DisclosureInventor__c (before insert, after insert, before update, after update, before delete) {
    if(trigger.isBefore && trigger.isInsert) {
        DisclosureInventorTriggerHandler.onBeforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate) {
        DisclosureInventorTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert) {
        DisclosureInventorTriggerHandler.onAfterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate) {
        DisclosureInventorTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isDelete && trigger.isBefore) {
        DisclosureInventorTriggerHandler.onBeforeDelete(trigger.old);
    }

}