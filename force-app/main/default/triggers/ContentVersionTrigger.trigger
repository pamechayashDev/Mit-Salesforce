trigger ContentVersionTrigger on ContentVersion (before insert, after insert, before update, after update) {
    if(trigger.isBefore && trigger.isInsert) {
        ContentVersionHandler.onBeforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate) {
        
    }
    if(trigger.isAfter && trigger.isInsert) {
        ContentVersionHandler.onAfterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate) {
        
    }
}