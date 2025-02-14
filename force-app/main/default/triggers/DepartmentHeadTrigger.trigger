trigger DepartmentHeadTrigger on Department_Head__c(before insert, after insert, before update, after update, after delete, before delete) {
    
    if(trigger.isBefore && trigger.isInsert) {
        DepartmentHeadTriggerHandler.onBeforeInsert(trigger.new); 
    }
    if(trigger.isBefore && trigger.isUpdate) {
        DepartmentHeadTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert) {
        DepartmentHeadTriggerHandler.onAfterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate) {
        DepartmentHeadTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isDelete) {
        DepartmentHeadTriggerHandler.onAfterDelete(Trigger.old);
    }
}