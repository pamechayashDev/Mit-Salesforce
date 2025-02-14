trigger UtilizationManufacturerTrigger on Utilization_Manufacturers__c (before delete) {
    if (Trigger.isBefore && Trigger.isDelete) {
        UtilizationManufacturerTriggerHandler.onBeforeDelete(Trigger.old);
    }
}