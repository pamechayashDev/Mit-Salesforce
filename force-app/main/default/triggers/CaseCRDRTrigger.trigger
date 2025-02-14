trigger CaseCRDRTrigger on Case_CRDR__c (before insert, after insert, before update, after update) {

    if(Trigger.isAfter && Trigger.isInsert) {
        CaseCRDRTriggerHandler.onAfterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        CaseCRDRTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}