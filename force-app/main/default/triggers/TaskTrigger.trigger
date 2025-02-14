trigger TaskTrigger on Task (before insert, before update, after insert, after update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        TaskTriggerHandler.onBeforeInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        TaskTriggerHandler.onAfterInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        TaskTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        TaskTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}