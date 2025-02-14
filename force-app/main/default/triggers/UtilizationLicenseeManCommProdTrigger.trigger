trigger UtilizationLicenseeManCommProdTrigger on Utilization_Licensee_Man_Comm_Prod__c (before delete) {
    if (Trigger.isBefore && Trigger.isDelete) {
        UtilizationLicManCommProdTriggerHandler.onBeforeDelete(Trigger.old);
    }
}