trigger CopyrightDisclosureTrigger on Copyright_Disclosure__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate) {
        CopyrightDisclosureTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}