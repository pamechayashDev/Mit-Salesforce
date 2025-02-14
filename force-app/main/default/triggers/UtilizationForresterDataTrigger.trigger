trigger UtilizationForresterDataTrigger on Utilization_Report__c (before update) {
    if (trigger.isBefore && trigger.isUpdate) {
        UtilizationForresterDataTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
}