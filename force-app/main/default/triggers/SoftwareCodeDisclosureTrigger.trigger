trigger SoftwareCodeDisclosureTrigger on Software_Code_Disclosure__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate) {
        SoftwareCodeDisclosureTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}