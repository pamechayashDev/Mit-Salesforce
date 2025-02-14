/**
 * Created by Andreas du Preez on 2024/07/30.
 */

public with sharing class IPIARecordService {

    public static String IPIA_SYSTEM_ADMIN_ACCESS = 'IPIA_System_Admin_Access';

    /**
     * Returns a list of IPIA Records to update for the given list of IPIA Records.
     *
     * This method categorizes the IPIA records based on whether they have a DocusignTemplate__c
     * or FormName__c field populated. It then assigns the IPIA Type to the IPIA Records accordingly.
     *
     * @param ipiaRecords List of IPIA_Record__c records to be processed.
     * @return List of IPIA_Record__c records with updated IPIA Type Links.
     */
    public static List<IPIA_Record__c> updateIPIARecordTypeLink(List<IPIA_Record__c> ipiaRecords) {
        List<IPIA_Record__c> result = new List<IPIA_Record__c>();
        List<IPIA_Record__c> ipiaUpdateIPIALinkWithTemplateId = new List<IPIA_Record__c>();
        List<IPIA_Record__c> ipiaUpdateIPIALinkWithFormName = new List<IPIA_Record__c>();

        for (IPIA_Record__c ipiaRecord : ipiaRecords) {
            // Skip records that already have an IPIA Type
            if (ipiaRecord.IPIA_Type__c != null) {
                continue;
            }

            // If DocusignTemplate__c is populated, update the IPIA Type Link
            if (ipiaRecord.DocusignTemplate__c != null) {
                ipiaUpdateIPIALinkWithTemplateId.add(ipiaRecord);
            }
            // If DocusignTemplate__c is not populated but the FormName__c is, update the IPIA Type Link
            else if (ipiaRecord.FormName__c != null) {
                ipiaUpdateIPIALinkWithFormName.add(ipiaRecord);
            }
        }

        if (!ipiaUpdateIPIALinkWithTemplateId.isEmpty()) {
            result.addAll(IPIARecordService.linkIPIARecordsWithTypeByTemplateId(ipiaUpdateIPIALinkWithTemplateId));
        }

        if (!ipiaUpdateIPIALinkWithFormName.isEmpty()) {
            result.addAll(IPIARecordService.linkIPIARecordsWithTypeByFormName(ipiaUpdateIPIALinkWithFormName));
        }

        return result;
    }

    /**
     * Links IPIA records with their corresponding IPIA Types based on the DocusignTemplate__c field.
     *
     * @param ipiaRecords List of IPIA_Record__c records to be linked with IPIA Types.
     * @return List of IPIA_Record__c records with updated IPIA_Type__c fields.
     */
    public static List<IPIA_Record__c> linkIPIARecordsWithTypeByTemplateId(List<IPIA_Record__c> ipiaRecords) {
        Map<String, Id> templateIds = new Map<String, Id>();
        Map<String, String> templateName = new Map<String, String>();

        // Get unique DocusignTemplate__c's
        for (IPIA_Record__c ipiaRecord : ipiaRecords) {
            if (ipiaRecord.DocusignTemplate__c != null) {
                templateIds.put(ipiaRecord.DocusignTemplate__c.toLowerCase(), null);
                templateName.put(ipiaRecord.DocusignTemplate__c.toLowerCase(), null);
            }
        }

        List<IPIA_Type__c> ipiaTypes = [SELECT Id, Name, DocusignTemplate__c FROM IPIA_Type__c WHERE DocusignTemplate__c IN :templateIds.keySet()];

        // Update the Map with the IPIA_Type__c's Id
        for (IPIA_Type__c ipiaType : ipiaTypes) {
            String lowerCaseTemplate = ipiaType.DocusignTemplate__c != null ? ipiaType.DocusignTemplate__c.toLowerCase() : null;
            if (lowerCaseTemplate != null && templateIds.containsKey(lowerCaseTemplate)) {
                templateIds.put(lowerCaseTemplate, ipiaType.Id);
                templateName.put(lowerCaseTemplate, ipiaType.Name);
            }
        }

        // Update the IPIA Records' IPIA_Type__c with the Id, and also the FormName__c if the IPIA Type is found.
        for (IPIA_Record__c ipiaRecord : ipiaRecords) {
            if (ipiaRecord.DocusignTemplate__c != null) {
                ipiaRecord.IPIA_Type__c = templateIds.get(ipiaRecord.DocusignTemplate__c.toLowerCase());

                if (ipiaRecord.IPIA_Type__c != null) {
                    ipiaRecord.FormName__c = templateName.get(ipiaRecord.DocusignTemplate__c.toLowerCase());
                }
            }
        }

        return ipiaRecords;
    }

    /**
     * Links IPIA records with their corresponding IPIA Types based on the FormName__c field.
     *
     * @param ipiaRecords List of IPIA_Record__c records to be linked with IPIA Types.
     * @return List of IPIA_Record__c records with updated IPIA_Type__c fields.
     */
    public static List<IPIA_Record__c> linkIPIARecordsWithTypeByFormName(List<IPIA_Record__c> ipiaRecords) {
        Map<String, Id> formNames = new Map<String, Id>();

        // Get unique FormName__c's
        for (IPIA_Record__c ipiaRecord : ipiaRecords) {
            if (ipiaRecord.FormName__c != null) {
                formNames.put(ipiaRecord.FormName__c.toLowerCase(), null);
            }
        }

        List<IPIA_Type__c> ipiaTypes = [SELECT Id, Name FROM IPIA_Type__c WHERE Name IN :formNames.keySet()];

        // Update the Map with the IPIA_Type__c's Id
        for (IPIA_Type__c ipiaType : ipiaTypes) {
            String lowerCaseName = ipiaType.Name != null ? ipiaType.Name.toLowerCase() : null;
            if (lowerCaseName != null && formNames.containsKey(lowerCaseName)) {
                formNames.put(lowerCaseName, ipiaType.Id);
            }
        }

        // Update the IPIA Records' IPIA_Type__c with the Id.
        for (IPIA_Record__c ipiaRecord : ipiaRecords) {
            if (ipiaRecord.FormName__c != null) {
                ipiaRecord.IPIA_Type__c = formNames.get(ipiaRecord.FormName__c.toLowerCase());
            }
        }

        return ipiaRecords;
    }

    /**
     * Returns a list of IPIA Records to update for the given list of IPIA types.
     *
     * This method categorizes the IPIA types based on whether they have a DocusignTemplate__c
     * field populated. It then assigns the IPIA Type to the IPIA Records accordingly.
     *
     * @param ipiaTypes List of IPIA_Type__c records to be processed.
     * @return List of IPIA_Record__c records with updated IPIA_Type__c field.
     */
    public static List<IPIA_Record__c> updateIPIARecordTypeLink(List<IPIA_Type__c> ipiaTypes) {
        List<IPIA_Record__c> result = new List<IPIA_Record__c>();
        Map<String, Id> ipiaTypeTemplateIds = new Map<String, Id>();
        Map<String, String> ipiaTypeTemplateIdName = new Map<String, String>();
        Map<String, Id> ipiaTypeNames = new Map<String, Id>();

        for (IPIA_Type__c ipiaType : ipiaTypes) {
            // If DocusignTemplate__c is populated, update the IPIA Type Link, and the FormName__c
            if (ipiaType.DocusignTemplate__c != null) {
                ipiaTypeTemplateIds.put(ipiaType.DocusignTemplate__c, ipiaType.Id);
                ipiaTypeTemplateIdName.put(ipiaType.DocusignTemplate__c, ipiaType.Name);
            }

            ipiaTypeNames.put(ipiaType.Name, ipiaType.Id);
        }

        List<IPIA_Record__c> ipiaRecords = [SELECT Id, IPIA_Type__c, FormName__c, DocusignTemplate__c FROM IPIA_Record__c WHERE (DocusignTemplate__c IN :ipiaTypeTemplateIds.keySet() OR FormName__c IN :ipiaTypeNames.keySet()) AND IPIA_Type__c = NULL];

        for (IPIA_Record__c ipiaRecord : ipiaRecords) {
            if (ipiaRecord.DocusignTemplate__c != NULL && ipiaTypeTemplateIds.containsKey(ipiaRecord.DocusignTemplate__c)) {
                ipiaRecord.IPIA_Type__c = ipiaTypeTemplateIds.get(ipiaRecord.DocusignTemplate__c);
                ipiaRecord.FormName__c = ipiaTypeTemplateIdName.get(ipiaRecord.DocusignTemplate__c);
                result.add(ipiaRecord);
            } else if (ipiaRecord.FormName__c != NULL && ipiaTypeNames.containsKey(ipiaRecord.FormName__c)) {
                ipiaRecord.IPIA_Type__c = ipiaTypeNames.get(ipiaRecord.FormName__c);
                result.add(ipiaRecord);
            }
        }

        return result;
    }

    /**
     * Links IPIA records to Disclosure Inventors based on the MIT ID.
     *
     * This method retrieves unique MIT IDs from the provided IPIA records,
     * queries the Disclosure Inventor records that match these MIT IDs,
     * and links the IPIA records to the corresponding Disclosure Inventors.
     *
     * @param ipiaRecords List of IPIA_Record__c records to be linked with Disclosure Inventors.
     * @return List of DisclosureInventor__c records linked to the IPIA records.
     */
    public static List<DisclosureInventor__c> linkIPIARecordsToDisclosureInventors(List<IPIA_Record__c> ipiaRecords) {
        Set<String> mitIds = new Set<String>();

        // Get unique MIT ID's
        for (IPIA_Record__c ipiaRecord : ipiaRecords) {
            mitIds.add(ipiaRecord.MitId__c);
        }

        // Get the Disclosure Inventor's Id by MIT ID
        List<DisclosureInventor__c> disclosureInventors = [SELECT Id, Contact__r.MitId__pc FROM DisclosureInventor__c WHERE Contact__r.MitId__pc IN :mitIds];
        List<IPIA_Record__c> ipiaRecordsLinkedToDisclosureInventors = [SELECT Id, MitId__c, SignDatetime__c FROM IPIA_Record__c WHERE MitId__c IN :mitIds];

        // Link the IPIA Records with the Disclosure Inventor
        return DisclosureInventorService.processIPIARecordToDisclosureInventorLink(disclosureInventors, ipiaRecordsLinkedToDisclosureInventors);
    }

    public Blob getIpiaRecordDocument(String ipiaRecordIdStr) {
        MitDocuSignApi docuSignApi = new MitDocuSignApi();

        List<IPIA_Record__c> ipiaRecords = [
                SELECT Id, DocusignEnvelopeId__c
                FROM IPIA_Record__c
                WHERE Id = :ipiaRecordIdStr
        ];
        if (!ipiaRecords.isEmpty()) {
            String envelopeId = ipiaRecords[0].DocusignEnvelopeId__c;
            return docuSignApi.getDocumentByEnvelopeId(envelopeId);
        }
        return null;
    }

    public static List<IPIA_Record__c> getCurrentIPIARecords(List<String> mitIds) {
        return getCurrentIPIARecordsMap(mitIds).values();
    }

    public static Map<String, IPIA_Record__c> getCurrentIPIARecordsMap(List<String> mitIds) {
        Map<String, IPIA_Record__c> recordsByMitId = new Map<String, IPIA_Record__c>();

        for (IPIA_Record__c record : [
                SELECT Id, Name, MitId__c, DocusignEnvelopeId__c, DocusignTemplate__c, FormName__c, IPIA_Type__c, SignDatetime__c, 
                    IPIA_Type__r.Name, IPIA_Type__r.Status__c, IPIA_Type__r.Exemption__c,
                    (SELECT ContentDocumentId FROM ContentDocumentLinks)
                FROM IPIA_Record__c
                WHERE MitId__c IN :mitIds
        ]) {
            if (recordsByMitId.get(record.MitId__c) == null || record.SignDatetime__c > recordsByMitId.get(record.MitId__c).SignDatetime__c) {
                recordsByMitId.put(record.MitId__c, record);
            }
        }

        return recordsByMitId;
    }

    @TestVisible
    private static Map<Id, IPIA_Type__c> getIpiaTypesFromIpiaRecord(List<IPIA_Record__c> newIpiaRecords) {
        Set<Id> typeIds = new Set<Id>();
        for (IPIA_Record__c ipias : newIpiaRecords) {
            if (ipias.IPIA_Type__c != null) {
                typeIds.add(ipias.IPIA_Type__c);
            }
        }
        Map<Id, IPIA_Type__c> typeLookup = new Map<Id, IPIA_Type__c>([select Id, Exemption__c from IPIA_Type__c where Id = :typeIds]);
        return typeLookup;
    }

    @TestVisible
    private static Boolean ipiaRecordTypeChangedAndExempt(IPIA_Record__c newRecord, Map<Id, IPIA_Type__c> typeLookup) {
        Boolean formExempted = false;
        if (newRecord.IPIA_Type__c != null && typeLookup.get(newRecord.IPIA_Type__c) != null) {
            IPIA_Type__c ipiaType = typeLookup.get(newRecord.IPIA_Type__c);
            formExempted = ipiaType.Exemption__c == true;
        }
        return formExempted;
    }

    public static List<IPIA_Record__c> getIpiaRecordToSync(List<IPIA_Record__c> oldIpiaRecords, List<IPIA_Record__c> newIpiaRecords) {
        // Get the Current IPIAs for the new IPIA Records' MIT IDs
        Map<String, IPIA_Record__c> ipiaRecordsMap = new Map<String, IPIA_Record__c>();
        for (IPIA_Record__c ipiaRecord : newIpiaRecords) {
            ipiaRecordsMap.put(ipiaRecord.MitId__c, ipiaRecord);
        }
        Map<String, IPIA_Record__c> currentIPIARecords = IPIARecordService.getCurrentIPIARecordsMap(new List<String>(ipiaRecordsMap.keySet()));


        // If this is an insert:
        // Sync all new IpiaRecords if they are, or became, the Current IPIA
        if (oldIpiaRecords == null || oldIpiaRecords.isEmpty()) {
            List<IPIA_Record__c> newIpiaRecordsToSync = new List<IPIA_Record__c>();

            for (IPIA_Record__c newRecord : newIpiaRecords) {
                if (currentIPIARecords.get(newRecord.MitId__c) != null && currentIPIARecords.get(newRecord.MitId__c).Id == newRecord.Id) {
                    newIpiaRecordsToSync.add(currentIPIARecords.get(newRecord.MitId__c));
                }
            }

            return newIpiaRecordsToSync;
        }

        // If this is an update:
        Map<Id, IPIA_Type__c> typeLookup = getIpiaTypesFromIpiaRecord(newIpiaRecords);
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>();
        for (Integer i = 0; i < newIpiaRecords.size(); i++) {
            IPIA_Record__c oldRecord = oldIpiaRecords[i];
            IPIA_Record__c newRecord = newIpiaRecords[i];

            // Skip if the MitId changed
            if (oldRecord.MitId__c != newRecord.MitId__c) {
                continue;
            }

            // If this is the Current IPIA, and the Type changed, then sync the Current IPIA
            if (currentIPIARecords.get(newRecord.MitId__c) != null && currentIPIARecords.get(newRecord.MitId__c).Id == newRecord.Id) {
                // The Type changed
                Boolean formTypeChanged = oldRecord.IPIA_Type__c != newRecord.IPIA_Type__c;
                // The signed Date changed
                Boolean signedDateChanged = oldRecord.SignDatetime__c != newRecord.SignDatetime__c;

                if (signedDateChanged || formTypeChanged) {
                    ipiaRecords.add(newRecord);
                }
            } else if (currentIPIARecords.get(newRecord.MitId__c) != null) {
                // If the updated record is not the Current IPIA anymore, then sync the Current IPIA
                if (oldRecord.SignDatetime__c > currentIPIARecords.get(newRecord.MitId__c).SignDatetime__c) {
                    ipiaRecords.add(currentIPIARecords.get(newRecord.MitId__c));
                }
            }
        }
        return ipiaRecords;
    }

    public static Set<Id> startForresterSync(List<IPIA_Record__c> ipiaRecords) {
        // Sync fields
        Map<Id, IPIA_Record__c> ipiaMap = new Map<Id, IPIA_Record__c>(ipiaRecords);

        List<Async_Request__c> asyncJobsForIpiaSigned = new List<Async_Request__c>();
        for (Id ipiaRecordId : ipiaMap.keySet()) {
            asyncJobsForIpiaSigned.add(
                    AsyncRequestHelper.prepareAsyncRequest(
                            ipiaRecordId,
                            'IPIA_Record__c',
                            'IPIASignedToForresterJob'
                    )
            );
        }
        insert asyncJobsForIpiaSigned;
        Map<Id, Async_Request__c> asyncMap = new Map<Id, Async_Request__c>(asyncJobsForIpiaSigned);

        IPIARecordService.queueIPIARecordChangesSyncToForrester(asyncMap.keySet());
        return asyncMap.keySet();
    }

    private static void queueIPIARecordChangesSyncToForrester(Set<Id> asyncRequestIdsList) {
        if (asyncRequestIdsList == null || asyncRequestIdsList.isEmpty()) {
            return;
        }
        Integer delayInMinutes = 0;
        IPIARecordUpsertJob upsertIpiaJob = new IPIARecordUpsertJob(asyncRequestIdsList);
        if (!Test.isRunningTest()) {
            System.enqueueJob(upsertIpiaJob, delayInMinutes);
        }
    }

    public static Boolean isIPIASystemAdmin() {
        return FeatureManagement.checkPermission(IPIA_SYSTEM_ADMIN_ACCESS);
    }
}