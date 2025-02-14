trigger UtilizationManufacturingCommProdTrigger on Utilization_Manufacturing_Comm_Prod__c (before delete) {
    if(Trigger.isBefore && Trigger.isDelete) {
        UtilizationManCommProdTriggerHandler.onBeforeDelete(Trigger.old);
    }
}