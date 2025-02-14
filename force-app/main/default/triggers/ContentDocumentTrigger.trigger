trigger ContentDocumentTrigger on ContentDocument (before delete) {
    if (trigger.isBefore && trigger.isDelete) {
        ContentDocumentTriggerHandler.onBeforeDelete(trigger.old);
    }
}