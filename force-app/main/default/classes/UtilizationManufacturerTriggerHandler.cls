/**
 * Created by Andreas du Preez on 2024/11/18.
 */

public with sharing class UtilizationManufacturerTriggerHandler {
    public static void onBeforeDelete(
            List<Utilization_Manufacturers__c> utilizationManufacturers
    ) {
        // Future Todo:
        // Use the standard Salesforce Cascade Delete feature to delete related records:
        // https://help.salesforce.com/s/articleView?id=000382017&type=1
        // This feature first needs to be activated by Salesforce Support.
        // For now, we will manually delete the related records.
        deleteRelatedRecords(utilizationManufacturers);
    }

    private static void deleteRelatedRecords(List<Utilization_Manufacturers__c> utilizationManufacturersList) {
        Set<Id> utilizationManufacturerIds = new Set<Id>();
        for (
                Utilization_Manufacturers__c utilizationManufacturer : utilizationManufacturersList
        ) {
            utilizationManufacturerIds.add(utilizationManufacturer.Id);
        }

        List<Utilization_Product_Location__c> utilizationProductLocations = [
                SELECT Id
                FROM Utilization_Product_Location__c
                WHERE Utilization_Manufacturer__c = :utilizationManufacturerIds
        ];

        System.debug(JSON.serializePretty(utilizationProductLocations));

        delete utilizationProductLocations;
    }
}