/**
 * Created by Andreas du Preez on 2024/07/30.
 */

public with sharing class IPIARecordTriggerHandler {
    public static String ENABLE_TRIGGER_IPIA_SIGN_TO_FORRESTER_SYNC = 'EnableTriggerIpiaSignToForrester';
    public static String ENABLE_TRIGGER_IPIA_DOWNLOAD = 'EnableTriggerIpiaDownload';
    public static String IPIA_RECORD_MIT_ID_EDITABLE = 'IPIA_Record_MIT_ID_Editable';
    public static String IPIA_RECORD_EDIT_HISTORIC_DATA = 'IPIA_Record_Edit_Historic_Data';
    public static String IPIA_RECORD_DELETE_HISTORIC_DATA = 'IPIA_Record_Delete_Historic_Data';

    public static void onBeforeInsert(List<IPIA_Record__c> ipiaRecords) {
        validateIPIARecord(ipiaRecords);
        IPIARecordService.updateIPIARecordTypeLink(ipiaRecords);
    }

    public static void onAfterInsert(List<IPIA_Record__c> ipiaRecords) {
        updateDisclosureInventorIPIALookup(ipiaRecords);

        if (enabledTriggerForresterSync()) {
            List<IPIA_Record__c> ipiaSyncRecords = IPIARecordService.getIpiaRecordToSync(null, ipiaRecords);
            IPIARecordService.startForresterSync(ipiaSyncRecords);
        }
        if (enabledTriggerIPIADownload()) {
            Map<Id,IPIA_Record__c> oldIpias = null;
            IPIADocuSignDownloadJob.startDocuSignIpiaDownload(ipiaRecords, oldIpias);
        }
    }

    public static void onBeforeUpdate(List<IPIA_Record__c> oldIpiaRecords, List<IPIA_Record__c> newIpiaRecords) {
        validateIPIARecord(oldIpiaRecords, newIpiaRecords);
        updateIPIARecordFormName(oldIpiaRecords, newIpiaRecords);
    }

    public static void onAfterUpdate(List<IPIA_Record__c> oldIpiaRecords, List<IPIA_Record__c> newIpiaRecords) {
        updateDisclosureInventorIPIALookup(oldIpiaRecords, newIpiaRecords);
        updateIpiaLinkedDocumentsNames(oldIpiaRecords, newIpiaRecords);

        if (enabledTriggerForresterSync()) {
            List<IPIA_Record__c> ipiaSyncRecords = IPIARecordService.getIpiaRecordToSync(oldIpiaRecords, newIpiaRecords);
            IPIARecordService.startForresterSync(ipiaSyncRecords);
        }
        if (enabledTriggerIPIADownload()) {
            Map<Id,IPIA_Record__c> oldIpias = new Map<Id,IPIA_Record__c>(oldIpiaRecords);
            IPIADocuSignDownloadJob.startDocuSignIpiaDownload(newIpiaRecords, oldIpias);
        }
    }

    public static void onBeforeDelete(List<IPIA_Record__c> oldIpiaRecords) {
        validateDelete(oldIpiaRecords);
        
        Boolean hasErrors = false;
        for (IPIA_Record__c ipia : oldIpiaRecords) {
            if (ipia.hasErrors()) {
                hasErrors = true;
                return;
            }
        }
        if (!hasErrors) {
            // docs/ContentDocumentLink's get deleted in onAfterDelete because:
            // SF clears the Id field on the ContentDocumentLink object once on object is deleted.
            deleteContentVersions(oldIpiaRecords);
        }
    }

    public static void onAfterDelete(List<IPIA_Record__c> ipiaRecords) {
        updateDisclosureInventorIPIALookup(ipiaRecords);
    }

    /**
     * Updates the Disclosure Inventor IPIA Lookup for the given lists of old and new IPIA records.
     *
     * This method compares the old and new IPIA records to determine if the
     * SignDatetime__c field has changed. If the field has changed, the new record
     * is added to a list for updating the Disclosure Inventor IPIA Lookup.
     * If the MitId__c field has changed, both the old and new records are added to the list.
     *
     * @param oldIpiaRecords List of old IPIA_Record__c records before the update.
     * @param newIpiaRecords List of new IPIA_Record__c records after the update.
     */
    @TestVisible
    private static void updateDisclosureInventorIPIALookup(List<IPIA_Record__c> oldIpiaRecords, List<IPIA_Record__c> newIpiaRecords) {
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>();
        Set<Id> includedIPIARecords = new Set<Id>();

        for (Integer i = 0; i < newIpiaRecords.size(); i++) {
            IPIA_Record__c oldRecord = oldIpiaRecords[i];
            IPIA_Record__c newRecord = newIpiaRecords[i];

            if (oldRecord.SignDatetime__c != newRecord.SignDatetime__c) {
                ipiaRecords.add(newRecord);
                includedIPIARecords.add(newRecord.Id);
            }

            if (oldRecord.MitId__c != newRecord.MitId__c) {
                if (includedIPIARecords.contains(newRecord.Id)) {
                    ipiaRecords.add(oldRecord);
                }
                else {
                    ipiaRecords.add(oldRecord);
                    ipiaRecords.add(newRecord);
                }
            }
        }

        if (!ipiaRecords.isEmpty()) {
            updateDisclosureInventorIPIALookup(ipiaRecords);
        }
    }

     /**
     * Updates the linked documents for the given lists of old and new IPIA records.
     *
     * This method compares the old and new IPIA records to determine if the MitId__c or SignDatetime__c field has changed. 
     * If either have changed it will updated the linked IPIA Documents Name/Title: to be in format of
     * mitId-MM_dd_yy.fileExtension
     *
     * @param oldIpiaRecords List of old IPIA_Record__c records before the update.
     * @param newIpiaRecords List of new IPIA_Record__c records after the update.
     */
    @TestVisible
    private static void updateIpiaLinkedDocumentsNames(List<IPIA_Record__c> oldIpiaRecords, List<IPIA_Record__c> newIpiaRecords) {
        
        if (!oldIpiaRecords.isEmpty()) {
            // ===============
            // workout which IPIA's have had their mitId and/or effective date changed (which means file name change needede)
            // ===============
            Map<Id, IPIA_Record__c> ipiasNeedFileNameChanged = new Map<Id, IPIA_Record__c>();
            for (Integer i = 0; i < newIpiaRecords.size(); i++) {
                IPIA_Record__c oldIpia = oldIpiaRecords[i];
                IPIA_Record__c newIpia = newIpiaRecords[i];

                Boolean mitIdChanged = oldIpia.MitId__c != newIpia.MitId__c;
                Boolean effectedDateChanged = oldIpia.SignDatetime__c != newIpia.SignDatetime__c;
                
                Boolean isFileNameChangeNeeded = mitIdChanged || effectedDateChanged;                
                if (isFileNameChangeNeeded) {
                    ipiasNeedFileNameChanged.put(oldIpia.Id, newIpia);
                }
            }
            
            // ===============
            // get document objects (which exist) for those IPIAs that have mitId or effectiveDate changes
            // ===============
            List<ContentDocumentLink> oldMitIdDocs = FileRepository.getFilesByIdsAndType(new List<Id>(ipiasNeedFileNameChanged.keySet()), 'IPIA');
            List<Id> contentDocumentIds = new List<Id>();
            for (ContentDocumentLink cdl : (oldMitIdDocs)) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }            
            Map<Id, ContentVersion> conDocCsvId = new Map<Id, ContentVersion>();            
            List<ContentVersion> cvs = [SELECT Id, ContentDocumentId
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN :contentDocumentIds];
            for(ContentVersion cvToUp: cvs) { 
                conDocCsvId.put(cvToUp.ContentDocumentId, cvToUp);
            }

            // ===============
            // update the names of documents in format of: mitId-MM_dd_yy.fileExtension
            // ===============
            List<ContentVersion> cvsToUpdate = new List<ContentVersion> ();
            for(ContentDocumentLink oldDoc: oldMitIdDocs) {      
                IPIA_Record__c newIpia = ipiasNeedFileNameChanged.get(oldDoc.LinkedEntityId);
               
                Date newEffectiveDate = newIpia.SignDatetime__c;
                DateTime dt = DateTime.newInstance(newEffectiveDate.year(), newEffectiveDate.month(), newEffectiveDate.day());
                String ipiaEffectiveDateStr = dt.format('MM_dd_yyyy', 'Etc/UTC'); // using UTC that is what was used in personIpiaList.js

                ContentVersion cvToUpdate = conDocCsvId.get(oldDoc.ContentDocumentId);
                cvsToUpdate.add(new ContentVersion(
                        Id = cvToUpdate.Id,
                        Title = newIpia.MitId__c + '-' + ipiaEffectiveDateStr + '.' + oldDoc.ContentDocument.FileExtension
                ));
            }

            update cvsToUpdate;
        }
    }

    /**
     * Updates the Disclosure Inventor IPIA Lookup for the given list of IPIA records.
     *
     * This method links the provided IPIA records to their corresponding Disclosure Inventors
     * and updates the Disclosure Inventor records after the IPIA records have been inserted/updated.
     *
     * @param ipiaRecords List of IPIA_Record__c records that need their Disclosure Inventor IPIA Lookup updated.
     */
    @TestVisible
    private static void updateDisclosureInventorIPIALookup(List<IPIA_Record__c> ipiaRecords) {
        List<DisclosureInventor__c> disclosureInventorsToUpdate = IPIARecordService.linkIPIARecordsToDisclosureInventors(ipiaRecords);

        if (!disclosureInventorsToUpdate.isEmpty()) {
            update disclosureInventorsToUpdate;
        }
    }

    private static Boolean enabledTriggerForresterSync() {
        return Boolean.valueOf(getConfigValue(ENABLE_TRIGGER_IPIA_SIGN_TO_FORRESTER_SYNC, 'false'));
    }

    private static Boolean enabledTriggerIPIADownload() {
        return Boolean.valueOf(getConfigValue(ENABLE_TRIGGER_IPIA_DOWNLOAD, 'false'));
    }

    @TestVisible
    private static String getConfigValue(String key, String defaultValue) {
        try {
            return String.valueOf(ConfigurationBuilder.getConfigurationToString(key));
        } catch (Exception ex) {
            return defaultValue;
        }
    }

    private static void validateIPIARecord(List<IPIA_Record__c> newIpiaRecords) {
        validateIPIARecord(new List<IPIA_Record__c>(), newIpiaRecords);
    }

    private static void validateIPIARecord(List<IPIA_Record__c> oldIpiaRecords, List<IPIA_Record__c> newIpiaRecords) {
        // FormName__c or IPIA_Type__c is required.
        for (IPIA_Record__c ipiaRecord : newIpiaRecords) {
            Boolean typeAndNameEmpty = String.isBlank(String.valueOf(ipiaRecord.IPIA_Type__c)) && String.isBlank(String.valueOf(ipiaRecord.FormName__c));
            if(typeAndNameEmpty) {
                ipiaRecord.FormName__c.addError('Either form name or record type for the IPIA Record need to exist');
            }
        }

        // Validation for Sign Date not on the future.
        for (IPIA_Record__c ipiaRecord : newIpiaRecords) {
            if (ipiaRecord.SignDatetime__c > Date.today()) {
                ipiaRecord.SignDatetime__c.addError(Label.IPIA_Record_Error_Sign_Date_Today.replace('<TODAY>', String.valueOf(Date.today().format())));
            }
        }

        Set<String> mitIds = new Set<String>();
        for (IPIA_Record__c ipiaRecord : newIpiaRecords) {
            if (ipiaRecord.MitId__c != null) {
                mitIds.add(ipiaRecord.MitId__c);
            }
        }
        for (IPIA_Record__c ipiaRecord : oldIpiaRecords) {
            if (ipiaRecord.MitId__c != null) {
                mitIds.add(ipiaRecord.MitId__c);
            }
        }

        Map<String, IPIA_Record__c> currentIPIARecords = IPIARecordService.getCurrentIPIARecordsMap(new List<String>(mitIds));

        // Validation for record updates
        if (!oldIpiaRecords.isEmpty()) {
            for (Integer i = 0; i < newIpiaRecords.size(); i++) {
                IPIA_Record__c oldRecord = oldIpiaRecords[i];
                IPIA_Record__c newRecord = newIpiaRecords[i];

                // If the IPIA Type is updated from NULL, and nothing else, allow the update.
                if (oldRecord.IPIA_Type__c == null && newRecord.IPIA_Type__c != null && oldRecord.SignDatetime__c == newRecord.SignDatetime__c && oldRecord.MitId__c == newRecord.MitId__c) {
                    continue;
                }

                // If IPIA Type or Sign Date is updated:
                if (oldRecord.IPIA_Type__c != newRecord.IPIA_Type__c || oldRecord.SignDatetime__c != newRecord.SignDatetime__c) {
                    // If the record is not a manual IPIA record, do not allow the update, unless the user has the correct permissions.
                    if (!String.isEmpty(newRecord.DocusignTemplate__c) || !String.isEmpty(newRecord.DocusignEnvelopeId__c)) {
                        if (!IPIARecordService.isIPIASystemAdmin()) {
                            newRecord.addError(Label.IPIA_Record_Error_Update_Not_Manual_IPIA);
                        }
                    }

                    // If the record is a historic IPIA, do not allow the update, unless the user has the correct permissions.
                    if (currentIPIARecords.containsKey(newRecord.MitId__c) && currentIPIARecords.get(newRecord.MitId__c).Id != newRecord.Id) {
                        if (!(FeatureManagement.checkPermission(IPIA_RECORD_EDIT_HISTORIC_DATA) || IPIARecordService.isIPIASystemAdmin())) {
                            newRecord.addError(Label.IPIA_Record_Error_Update_Not_Current_IPIA);
                        }
                    }
                }

                if (oldRecord.MitId__c != newRecord.MitId__c) {
                    if (!(FeatureManagement.checkPermission(IPIA_RECORD_MIT_ID_EDITABLE) || IPIARecordService.isIPIASystemAdmin())) {
                        newRecord.MitId__c.addError('MIT ID cannot be changed.');
                    }
                }
            }
        }
    }

    public static void validateDelete(List<IPIA_Record__c> oldIpiaRecords) {
        Set<String> mitIds = new Set<String>();
        for (IPIA_Record__c ipiaRecord : oldIpiaRecords) {
            if (ipiaRecord.MitId__c != null) {
                mitIds.add(ipiaRecord.MitId__c);
            }
        }

        Map<String, IPIA_Record__c> currentIPIARecords = IPIARecordService.getCurrentIPIARecordsMap(new List<String>(mitIds));

        for (IPIA_Record__c ipiaRecord : oldIpiaRecords) {
            // If the record is the current IPIA, do not allow the delete.
            if (currentIPIARecords.containsKey(ipiaRecord.MitId__c) && currentIPIARecords.get(ipiaRecord.MitId__c).Id == ipiaRecord.Id) {
                if (!IPIARecordService.isIPIASystemAdmin()) {
                    ipiaRecord.addError(Label.IPIA_Record_Error_Delete_Not_Current_IPIA);
                }
            }
            else if (!(FeatureManagement.checkPermission(IPIA_RECORD_DELETE_HISTORIC_DATA) || IPIARecordService.isIPIASystemAdmin())) {
                ipiaRecord.addError(Label.IPIA_Record_Error_Delete_Historic_Data);
            }
        }

        // May not delete the IPIA if it has a Docusign Template or Envelope ID:
        for (IPIA_Record__c ipiaRecord : oldIpiaRecords) {
            if (!String.isEmpty(ipiaRecord.DocusignTemplate__c) && !String.isEmpty(ipiaRecord.DocusignEnvelopeId__c)) {
                if (!IPIARecordService.isIPIASystemAdmin()) {
                    ipiaRecord.addError(Label.IPIA_Record_Error_Delete_Has_Docusign_Metadata);
                }
            }
        }
    }

    private static void updateIPIARecordFormName(List<IPIA_Record__c> oldIpiaRecords, List<IPIA_Record__c> newIpiaRecords) {
        Map<Id, String> ipiaTypeNames = new Map<Id, String>();
        for (IPIA_Record__c ipiaRecord : newIpiaRecords) {
            ipiaTypeNames.put(ipiaRecord.IPIA_Type__c, null);
        }

        List<IPIA_Type__c> ipiaTypes = [SELECT Id, Name FROM IPIA_Type__c WHERE Id IN :ipiaTypeNames.keySet()];

        for (IPIA_Type__c ipiaType : ipiaTypes) {
            ipiaTypeNames.put(ipiaType.Id, ipiaType.Name);
        }

        // Check if the IPIA Type has changed and update the Form Name.
        if (!oldIpiaRecords.isEmpty()) {
            for (Integer i = 0; i < newIpiaRecords.size(); i++) {
                IPIA_Record__c oldRecord = oldIpiaRecords[i];
                IPIA_Record__c newRecord = newIpiaRecords[i];

                if (oldRecord.IPIA_Type__c != newRecord.IPIA_Type__c) {
                    newRecord.FormName__c = ipiaTypeNames.get(newRecord.IPIA_Type__c);
                }
            }
        }
    }

    private static void deleteContentVersions(List<IPIA_Record__c> ipiaRecords) {
        List<Id> ipiaRecordIds = new List<Id>();
        List<ContentDocument> contentDocuments = new List<ContentDocument>();

        for (IPIA_Record__c ipiaType : ipiaRecords) {
            ipiaRecordIds.add(ipiaType.Id);
        }

        ContentDocumentLinkUtils.deleteContentVersions(ipiaRecordIds);
    }
}