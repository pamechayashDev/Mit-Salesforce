/**
 * Created by Andreas du Preez on 2024/11/18.
 */

public with sharing class UtilizationManCommProdTriggerHandler {
    public static void onBeforeDelete(
            List<Utilization_Manufacturing_Comm_Prod__c> utilizationManCommProdList
    ) {
        // Future Todo:
        // Use the standard Salesforce Cascade Delete feature to delete related records:
        // https://help.salesforce.com/s/articleView?id=000382017&type=1
        // This feature first needs to be activated by Salesforce Support.
        // For now, we will manually delete the related records.
        deleteRelatedRecords(utilizationManCommProdList);
    }

    private static void deleteRelatedRecords(List<Utilization_Manufacturing_Comm_Prod__c> utilizationManCommProdList) {
        Set<Id> utilizationManCommProdIds = new Set<Id>();
        for (
                Utilization_Manufacturing_Comm_Prod__c utilizationManCommProd : utilizationManCommProdList
        ) {
            utilizationManCommProdIds.add(utilizationManCommProd.Id);
        }

        List<Utilization_Licensee_Man_Comm_Prod__c> utilizationLicenseeManCommProdList = [
                SELECT Id
                FROM Utilization_Licensee_Man_Comm_Prod__c
                WHERE Utilization_Manufacturing_Comm_Prod__c = :utilizationManCommProdIds
        ];

        System.debug(JSON.serializePretty(utilizationLicenseeManCommProdList));

        delete utilizationLicenseeManCommProdList;
    }
}