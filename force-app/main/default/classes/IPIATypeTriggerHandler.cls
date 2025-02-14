/**
 * Created by Andreas du Preez on 2024/08/23.
 */

public without sharing class IPIATypeTriggerHandler {

    public static String IPIA_TYPE_STATUS_ADMIN = 'IPIA_Type_Status_Admin';

    public static void onBeforeInsert(List<IPIA_Type__c> ipiaTypes) {
        validateIPIATypeName(ipiaTypes);
    }

    public static void onBeforeUpdate(List<IPIA_Type__c> oldIpiaTypes, List<IPIA_Type__c> newIpiaTypes) {
        validateIPIATypeName(newIpiaTypes);
        validateIPIATypeStatus(oldIpiaTypes, newIpiaTypes);
    }

    public static void onAfterInsert(List<IPIA_Type__c> ipiaTypes) {
        linkIPIATypesWithRecords(ipiaTypes);
    }

    public static void onBeforeDelete(List<IPIA_Type__c> ipiaTypes) {
        isIPATypesDeletable(ipiaTypes);
        deleteContentVersions(ipiaTypes);
    }

    private static void validateIPIATypeName(List<IPIA_Type__c> ipiaTypes) {
        Set<String> ipiaTypeNames = new Set<String>();
        for (IPIA_Type__c ipiaType : ipiaTypes) {
            ipiaTypeNames.add(ipiaType.Name);
        }

        List<IPIA_Type__c> existingIPIATypes = [SELECT Id, Name, Exemption__c, Status__c FROM IPIA_Type__c WHERE Name IN : ipiaTypeNames];

        // Check if the IPIA Type Name already exist
        for (IPIA_Type__c ipiaType : ipiaTypes) {
            for (IPIA_Type__c existingIPIAType : existingIPIATypes) {
                if (ipiaType.Name.toLowerCase() == existingIPIAType.Name.toLowerCase() && ipiaType.Id != existingIPIAType.Id) {
                    if (existingIPIAType.Status__c == 'Active') {
                        if (existingIPIAType.Exemption__c) {
                            ipiaType.Name.addError('The name for the IPIA Type already exist under Exemption IPIA\'s');
                        } else {
                            ipiaType.Name.addError('The name for the IPIA Type already exist under Non-Exemption IPIA\'s');
                        }
                    }
                    else {
                        ipiaType.Name.addError('The name for the IPIA Type already exist for an Needs TLO Review or Legacy IPIA Type');
                    }
                }
            }
        }

        // Check for duplicate IPIA Type Name
        for (Integer i = 0; i < ipiaTypes.size() - 1; i++) {
            for (Integer j = i + 1; j < ipiaTypes.size(); j++) {
                if (ipiaTypes[i].Name.toLowerCase() == ipiaTypes[j].Name.toLowerCase()) {
                    ipiaTypes[i].Name.addError('Duplicate IPIA Type Name');
                    ipiaTypes[j].Name.addError('Duplicate IPIA Type Name');
                }
            }
        }
    }

    private static void validateIPIATypeStatus(List<IPIA_Type__c> oldIpiaTypes, List<IPIA_Type__c> newIpiaTypes) {
        for (Integer i = 0; i < oldIpiaTypes.size(); i++) {
            if ((oldIpiaTypes[i].Status__c == 'Legacy' || oldIpiaTypes[i].Status__c == 'Needs TLO Review') && newIpiaTypes[i].Status__c == 'Active') {
                if (!(FeatureManagement.checkPermission(IPIA_TYPE_STATUS_ADMIN) || IPIARecordService.isIPIASystemAdmin())) {
                    newIpiaTypes[i].Status__c.addError(Label.IPIA_Type_Status_Change_To_Active);
                }
            }
        }
    }

    private static void linkIPIATypesWithRecords(List<IPIA_Type__c> ipiaTypes) {
        List<IPIA_Record__c> ipiaRecords = IPIARecordService.updateIPIARecordTypeLink(ipiaTypes);
        if (!ipiaRecords.isEmpty()) {
            update ipiaRecords;
        }
    }

    private static void isIPATypesDeletable(List<IPIA_Type__c> ipiaTypes) {
        List<AggregateResult> aggregateResult = [SELECT IPIA_Type__c, IPIA_Type__r.Name, COUNT(Id)
            FROM IPIA_Record__c
            WHERE IPIA_Type__c IN :ipiaTypes
            GROUP BY IPIA_Type__c, IPIA_Type__r.Name];

        for (AggregateResult result : aggregateResult) {
            for (IPIA_Type__c ipiaType : ipiaTypes) {
                Id ipiaTypeId = (Id) result.get('IPIA_Type__c');
                String ipiaTypeName = (String) result.get('Name');
                if (ipiaType.Id == ipiaTypeId) {
                    Integer recordCount = (Integer) result.get('expr0');
                    if (recordCount > 0) {
                        ipiaType.addError(Label.IPIA_Type_Delete_Error.replace('<IPIA_TYPE_NAME>', ipiaTypeName).replace('<IPIA_RECORD_COUNT>', recordCount.toString()));
                    }
                }
            }
        }
    }

    private static void deleteContentVersions(List<IPIA_Type__c> ipiaTypes) {
        List<Id> ipiaTypeIds = new List<Id>();
        List<ContentDocument> contentDocuments = new List<ContentDocument>();

        for (IPIA_Type__c ipiaType : ipiaTypes) {
            ipiaTypeIds.add(ipiaType.Id);
        }

        ContentDocumentLinkUtils.deleteContentVersions(ipiaTypeIds);
    }
}