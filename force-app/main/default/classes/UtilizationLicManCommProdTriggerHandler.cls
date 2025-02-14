/**
 * Created by Andreas du Preez on 2024/11/18.
 */

public with sharing class UtilizationLicManCommProdTriggerHandler {

    public static void onBeforeDelete(
            List<Utilization_Licensee_Man_Comm_Prod__c> utilizationLicenseeManCommProdList
    ) {
        // Future Todo:
        // Use the standard Salesforce Cascade Delete feature to delete related records:
        // https://help.salesforce.com/s/articleView?id=000382017&type=1
        // This feature first needs to be activated by Salesforce Support.
        // For now, we will manually delete the related records.
        deleteRelatedRecords(utilizationLicenseeManCommProdList);
    }

    private static void deleteRelatedRecords(List<Utilization_Licensee_Man_Comm_Prod__c> utilizationLicenseeManCommProdList) {
        Set<Id> utilizationLicenseeManCommProdIds = new Set<Id>();
        for (
                Utilization_Licensee_Man_Comm_Prod__c utilizationLicenseeManCommProd : utilizationLicenseeManCommProdList
        ) {
            utilizationLicenseeManCommProdIds.add(utilizationLicenseeManCommProd.Id);
        }

        List<Utilization_Manufacturers__c> utilizationManufacturersList = [
                SELECT Id
                FROM Utilization_Manufacturers__c
                WHERE Utilization_Licensee_Man_Comm_Prod__c = :utilizationLicenseeManCommProdIds
        ];

        System.debug(JSON.serializePretty(utilizationManufacturersList));

        delete utilizationManufacturersList;
    }
}