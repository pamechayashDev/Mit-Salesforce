/**
* @description: Apex class to search CRDR records and create files against these CRDR records
**/
public class GlobalRecordSearchController {
    
    @AuraEnabled(cacheable=true)
    public static List<ObjectWrapper> getContentDocumentLinks(String contentDocumentId, String recordTypeId,String currentRecordId,String entitySubType) {
        List<ObjectWrapper> result = new List<ObjectWrapper>();
        List<Object> objectList = new List<Object>();
        try {
            String objectName = 'ContentVersion';
            String typeName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId)?.getDeveloperName();
            
            // Query ContentDocumentLinks based on ContentDocumentId
            List<ContentDocumentLink> contentDocLinks = [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId = :contentDocumentId
            ];
            
            // Create a map to store ContentDocumentId to its list of ContentDocumentLinks
            Map<String, List<ContentDocumentLink>> contentDocumentIdToLinkedEntityId = new Map<String, List<ContentDocumentLink>>();
            
            // Set to store LinkedEntityIds
            Set<Id> linkedEntityIds = new Set<Id>();
            
            // Iterate through ContentDocumentLinks and populate the map and set
            for (ContentDocumentLink link : contentDocLinks) {
                String sObjName = link.LinkedEntityId.getSObjectType().getDescribe().getName();
                
                if(sObjName == 'Agreement__c' || sObjName == 'TLO_Case__c'){
                    
                    if (!contentDocumentIdToLinkedEntityId.containsKey(link.ContentDocumentId)) {
                        contentDocumentIdToLinkedEntityId.put(link.ContentDocumentId, new List<ContentDocumentLink>());
                    }
                    contentDocumentIdToLinkedEntityId.get(link.ContentDocumentId).add(link);
                    
                    // Add LinkedEntityId to the set
                    linkedEntityIds.add(link.LinkedEntityId);

                }
            }
            
            // Query Agreements based on LinkedEntityIds
            List<Agreement__c> agreementsList = [
                SELECT Id, Name, ExternalAgreement__c
                FROM Agreement__c
                WHERE Id IN :linkedEntityIds
            ];
            
            // Map ExternalAgreement__c to Agreement__c record
            Map<String, Agreement__c> externalAgreementToAgreementMap = new Map<String, Agreement__c>();
            for (Agreement__c agreement : agreementsList) {
                externalAgreementToAgreementMap.put(agreement.ExternalAgreement__c, agreement);
            }
            
            // Query TLO_Case__c based on LinkedEntityIds
            List<TLO_Case__c> caseList = [
                SELECT Id, ExternalCaseId__c
                FROM TLO_Case__c
                WHERE Id IN :linkedEntityIds
            ];
            
            // Map ExternalCaseId__c to TLO_Case__c record
            Map<String, TLO_Case__c> externalCaseIdToCaseMap = new Map<String, TLO_Case__c>();
            for (TLO_Case__c caseRecord : caseList) {
                externalCaseIdToCaseMap.put(caseRecord.ExternalCaseId__c, caseRecord);
            }
            
            // Retrieve objectList using fetchRelatedToRecords method
            if(typeName == 'CRDR' || typeName == 'Case' || typeName == 'Sponsor_Agreement' || typeName == 'Other_Agreement'){
                system.debug('externalCaseIdToCaseMap.keySet() case==> '+externalCaseIdToCaseMap.keySet());
                objectList = fetchForresterCaseRecords(externalCaseIdToCaseMap.keySet());
 
            }else{
                objectList = fetchRelatedToRecords(recordTypeId, currentRecordId, entitySubType);  
            }
            
            // Iterate over objectList to find matching agreements or cases and retrieve ContentDocumentLink count
            for (Object obj : objectList) {
                if (obj instanceof ObjectWrapper) {
                    ObjectWrapper objWrapper = (ObjectWrapper) obj;

                    if (objWrapper.value != null) {
                        String externalId = objWrapper.value;
                        Integer linkCount = 0;
                        String description = objWrapper.description;
                        String recordId = objWrapper.recordId;
                        String label = objWrapper.label;

                        if (externalAgreementToAgreementMap.containsKey(externalId)) {
                            Agreement__c agreement = externalAgreementToAgreementMap.get(externalId);
                            // Retrieve ContentDocumentLink count for the specific Agreement__c
                            if (contentDocumentIdToLinkedEntityId.containsKey(contentDocumentId)) {
                                linkCount = contentDocumentIdToLinkedEntityId.get(contentDocumentId).size();
                            }
                            result.add(createObjectWrapper(recordId, label, description, externalId, linkCount));
                        } else if (externalCaseIdToCaseMap.containsKey(externalId)) {
                            
                            // Retrieve ContentDocumentLink count for the specific TLO_Case__c
                            if (contentDocumentIdToLinkedEntityId.containsKey(contentDocumentId)) {
                                linkCount = contentDocumentIdToLinkedEntityId.get(contentDocumentId).size();
                            }
                            result.add(createObjectWrapper(recordId, label, description, externalId, linkCount));
                        }
                    }
                }
            }
            
        } catch (Exception ex) {
            throw new AuraHandledException('Error: ' + ex.getMessage());
        }

        return result;
    }
    
    /**
* @description: Fetches Forrester_Case__x records based on given Ids and returns a list of ObjectWrapper instances.
* @param caseIds Set<String> containing the Ids of Forrester_Case__x records.
* @return List<ObjectWrapper> containing ObjectWrapper instances.
**/
    private static List<ObjectWrapper> fetchForresterCaseRecords(Set<String> caseIds) {
        List<ObjectWrapper> objWrapperList = new List<ObjectWrapper>();
        for (Forrester_Case__x caseRecord : [SELECT Id, CASE_RECID__c, CONTRACT_CASE_NUM__c, DISCLOSURE_TITLE__c FROM Forrester_Case__x WHERE CASE_RECID__c IN :caseIds]) {
            ObjectWrapper wrapper = new ObjectWrapper();
            wrapper.recordId = caseRecord.Id;
            wrapper.label = caseRecord.CONTRACT_CASE_NUM__c;
            wrapper.value = caseRecord.CASE_RECID__c;
            wrapper.description = caseRecord.DISCLOSURE_TITLE__c;
            wrapper.icon = ''; 
            wrapper.variant = ''; 
            objWrapperList.add(wrapper);
        }

        return objWrapperList;
    }
    // Helper method to create ObjectWrapper instance
    private static ObjectWrapper createObjectWrapper(String recordId, String label, String description, String value, Integer linkCount) {
        ObjectWrapper wrapper = new ObjectWrapper();
        wrapper.recordId = recordId;
        wrapper.label = label;
        wrapper.description = description;
        wrapper.value = value;
        wrapper.icon = ''; 
        wrapper.variant = ''; 
        wrapper.linkCount = linkCount;
        return wrapper;
    }
    
    
    /**
* @description: Searches for CRDR records based on the provided search term and selected record type.
* @param selectedSubEntityType The data subtype searched for.
* @param crdrRecordId The recordId of TLO Objects to search for.
* @param selectedRecordType The selected record type.
* @return List of ObjectWrapper containing search results.
**/
    @AuraEnabled(cacheable = true)
    public static List<ObjectWrapper> fetchRelatedToRecords(String selectedRecordType, String crdrRecordId, String selectedSubEntityType) {
        List<ObjectWrapper> wrapperList = new List<ObjectWrapper>();
        
        try {
            String objectName = 'ContentVersion';
            String typeName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(selectedRecordType)?.getDeveloperName();
            if (typeName != null) {
                List<SObject> records = new List<SObject>();
                // Construct SOSL query for each record type
                switch on typeName {
                    when 'CRDR' {
                        // SOQL query for CRDR records
                        records = searchCRDRRecords(crdrRecordId);
                        
                        // records = searchCaseRecords(searchTerm, crdrRecordId);
                    }
                    when 'Case' {
                        // SOQL query for Case records
                        records = searchCaseRecords(crdrRecordId);
                    }
                    when 'Sponsor_Agreement' {
                        // SOQL query for Case records
                        records = searchCaseRecords(crdrRecordId);
                    }
                    when 'Other_Agreement' {
                        // SOQL query for Case records
                        records = searchCaseRecords(crdrRecordId);
                    }
                    when 'TLO_Agreement' {
                        // SOQL query for TLO_Agreement records
                        records = searchTLOAgreementRecords(crdrRecordId, selectedSubEntityType);
                    }
                }
                
                // Process search results
                for (SObject record : records) {
                    
                    String icon = 'standard:approval';
                    String label = '';
                    String value = '';
                    String description = '';
                    String variant = 'success';
                    if (typeName == 'CRDR') {
                        icon = 'custom:custom5';
                        label = (String) record.get('CONTRACT_CASE_NUM__c');
                        value = (String) record.get('CASE_RECID__c');
                        description = (String) record.get('DISCLOSURE_TITLE__c');
                    }
                    if (typeName == 'CASE') {
                        icon = 'custom:custom5';
                        label = (String) record.get('CONTRACT_CASE_NUM__c');
                        value = (String) record.get('CASE_RECID__c');
                        description = (String) record.get('DISCLOSURE_TITLE__c');
                    }
                    
                    if (typeName == 'TLO_Agreement') {
                        String agreementStatus = (String) record.get('AGREEMENT_STATUS__c');
                        icon ='standard:approval';
                        variant ='success';
                        label = (String) record.get('AGREEMENT_RECID__c');
                        value = (String) record.get('AGREEMENT_RECID__c');
                        description = (String) record.get('COMPANY_NAME__c');
                    }
                    
                    if (typeName == 'Sponsor_Agreement') {
                        icon = 'standard:record';
                        label = (String) record.get('CONTRACT_CASE_NUM__c');
                        value = (String) record.get('CASE_RECID__c');
                        description = (String) record.get('DISCLOSURE_TITLE__c');
                    }
                    
                    if (typeName == 'Other_Agreement') {
                        icon = 'standard:network_contract';
                        label = (String) record.get('CONTRACT_CASE_NUM__c');
                        value = (String) record.get('CASE_RECID__c');
                        description = (String) record.get('DISCLOSURE_TITLE__c');
                    }
                    
                    ObjectWrapper objWrapper = new ObjectWrapper();
                    objWrapper.recordId = (String) record.get('Id');
                    objWrapper.label = label;
                    objWrapper.value = value;
                    objWrapper.description = description;
                    objWrapper.icon = icon;
                    objWrapper.variant = variant;
                    
                    wrapperList.add(objWrapper);
                }
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error : ' + ex.getMessage());
        }
        return wrapperList;
    }

    /**
* @description: This is used to get the default CRDR .
* @return default crdr record which will not be removed
**/
    @AuraEnabled(cacheable = true)
    public static List<ObjectWrapper> getDefaultCrdr(String selectedRecordDeveloperName, String crdrRecordId) {
        List<ObjectWrapper> wrapperList = new List<ObjectWrapper>();

        try {
            if (crdrRecordId != null){
                String caseRecId = null;
                if (selectedRecordDeveloperName == 'CRDR' || selectedRecordDeveloperName == 'Case' || selectedRecordDeveloperName == 'Other_Agreement' || selectedRecordDeveloperName == 'Sponsor_Agreement' ) {
                    List<Forrester_SHIR_CRDR_VIEW__x> records =[SELECT Id, CASE_CRDR_RECID__c, CONTRACT_CASE_NUM__c, CASE_RECID__c, DISCLOSURE_TITLE__c FROM Forrester_SHIR_CRDR_VIEW__x WHERE Id =: crdrRecordId LIMIT 1];
                    if (!records.isEmpty()){
                        caseRecId = records[0].CASE_RECID__c ;
                    }
                } else {
                    return wrapperList;
                }

                if( caseRecId != null){
                    List<Forrester_Case__x> caseRecords =[SELECT Id, CASE_RECID__c, CONTRACT_CASE_NUM__c, DISCLOSURE_TITLE__c FROM Forrester_Case__x WHERE CASE_RECID__c =: caseRecId LIMIT 1];

                    ObjectWrapper objWrapper = new ObjectWrapper();
                    objWrapper.recordId = caseRecords[0].Id;
                    objWrapper.label = caseRecords[0].CONTRACT_CASE_NUM__c;
                    objWrapper.value = caseRecords[0].CASE_RECID__c;
                    objWrapper.description = caseRecords[0].DISCLOSURE_TITLE__c;
                    objWrapper.icon ='custom:custom5';
                    objWrapper.variant ='success';
                    wrapperList.add(objWrapper);
                }
            }
        }catch (Exception ex) {
            throw new AuraHandledException('Error : ' + ex.getMessage());
        }
        return wrapperList;
    }

    // Helper method to search CRDR records
    private static List<SObject> searchCRDRRecords(String crdrRecordId) {
        List<SObject> records = new List<SObject>();
        Set<String> crdrIds = new Set<String>();

        // Fetch related CRDR records based on crdrRecordId
        for (Forrester_SHIR_CRDR_RELATED_CRDRS_VIE__x fcrdr : [SELECT Id, RELATED_CASE_CRDR_RECID__r.Id FROM Forrester_SHIR_CRDR_RELATED_CRDRS_VIE__x WHERE CASE_CRDR_RECID__r.Id = :crdrRecordId]) {
            crdrIds.add(fcrdr.RELATED_CASE_CRDR_RECID__r.Id);
        }

        // Build SOQL query for CRDR records based on search term and numeric check
        Integer batchSize = 50;
        String soqlQuery = 'SELECT Id, CASE_RECID__c, CASE_CRDR_RECID__c, CONTRACT_CASE_NUM__c, DISCLOSURE_TITLE__c FROM Forrester_SHIR_CRDR_VIEW__x WHERE Id IN :batchFilter ';
        // Execute SOQL query
        return ExternalObjectRepository.fetchExternalQueryByExternalRecIds(new List<String>(crdrIds), soqlQuery, batchSize);

    }

    // Helper method to search Case records
    public static List<SObject> searchCaseRecords(String crdrRecordId) {
        List<SObject> records = new List<SObject>();
        Set<String> caseIds = new Set<String>();

        // Fetch related Case records based on crdrRecordId
        for (Forrester_SHIR_CRDR_RELATED_CRDRS_VIE__x fcrdr : [SELECT Id, CASE_RECID__r.Id, CASE_RECID__c FROM Forrester_SHIR_CRDR_RELATED_CRDRS_VIE__x WHERE CASE_CRDR_RECID__r.Id = :crdrRecordId]) {
            caseIds.add(fcrdr.CASE_RECID__r.Id);
        }

        // Build SOQL query for Case records based on search term and numeric check
        String soqlQuery = 'SELECT Id, CASE_RECID__c, CONTRACT_CASE_NUM__c, DISCLOSURE_TITLE__c FROM Forrester_Case__x WHERE Id IN :caseIds';
        // Execute SOQL query
        records = Database.query(soqlQuery);
        return records;
    }

    // Helper method to search TLO_Agreement records
    private static List<SObject> searchTLOAgreementRecords(String crdrRecordId, String selectedSubEntityType) {
        List<SObject> records = new List<SObject>();
        Set<String> agreementIds = new Set<String>();

        // Fetch related Agreement records based on crdrRecordId and selectedSubEntityType
        for (Forrester_SHIR_CASE_CRDR_AGREEMENT_VI__x fcrdr : [SELECT Id, CASE_CRDR_RECID__r.Id, AGREEMENT_RECID__r.Id FROM Forrester_SHIR_CASE_CRDR_AGREEMENT_VI__x WHERE CASE_CRDR_RECID__r.Id = :crdrRecordId]) {
            agreementIds.add(fcrdr.AGREEMENT_RECID__r.Id);
        }

        // Build SOQL query for TLO_Agreement records based on search term, numeric check, and selectedSubEntityType.
        Integer batchSize = 50;
        String soqlQuery = 'SELECT Id, AGREEMENT_RECID__c, AGREEMENT_TYPE__c, COMPANY_NAME__c, AGREEMENT_STATUS__c FROM Forrester_SHIR_AGREEMENT_VIEW__x WHERE Id IN :batchFilter AND AGREEMENT_TYPE__c = \'' + selectedSubEntityType + '\'';
        // Execute SOQL query
        return ExternalObjectRepository.fetchExternalQueryByExternalRecIds(new List<String>(agreementIds), soqlQuery, batchSize);

    }

    /**
* @description: Uploads files against selected CRDR records.
* @param selectedItems List of selected items.
* @param filedata Serialized file data.
* @param selectedEntitySubType Selected EntitySubType.
* @param selectedRecordType Selected record type.
* @param selectedDocumentTypeOptions Selected document type options.
* @return Upload status.
**/
    @AuraEnabled
    public static String uploadFiles(List<ObjectWrapper> selectedItems, String filedata, String selectedEntitySubType, String selectedRecordType, String selectedDocumentTypeOptions) {
        try {
            if (String.isBlank(filedata)) {
                return 'File data is blank.';
            }

            List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
            if (files.isEmpty()) {
                return 'No files found to upload.';
            }

            Set<String> externalIds = new Set<String>();
            for (ObjectWrapper selectedItem : selectedItems) {
                if (selectedItem.value != null) {
                    String value = selectedItem.value;
                    externalIds.add(value);
                }
            }

            List<ContentVersion> cvList = new List<ContentVersion>();
            for (FileDataWP file : files) {
                ContentVersion conVer = new ContentVersion();
                conVer.Document_Classification__c = selectedDocumentTypeOptions;
                conVer.ContentLocation = 'S';
                conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
                conVer.Title = file.fileName;
                conVer.RecordTypeId = selectedRecordType;
                conVer.Entity_Sub_Type__c = selectedEntitySubType;
                conVer.PathOnClient = file.fileName ;
                cvList.add(conVer);
            }

            List<SObject> existingContainers = new List<SObject>();
            String objectName = 'ContentVersion';

            if (selectedRecordType != null) {
                String typeName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(selectedRecordType)?.getDeveloperName();
                if (typeName == 'CRDR') {
                    // CRDRs will only upload to Cases and never to CRDRs
                    existingContainers = [SELECT Id, ExternalCaseId__c FROM TLO_Case__c WHERE ExternalCaseId__c IN :externalIds];
                } else if (typeName == 'TLO_Agreement') {
                    existingContainers = [Select Id, ExternalAgreement__c from Agreement__c where ExternalAgreement__c IN :externalIds];
                }else if(typeName == 'Case'){
                    existingContainers = [SELECT Id, ExternalCaseId__c FROM TLO_Case__c WHERE ExternalCaseId__c IN :externalIds];
                }else if(typeName == 'Other_Agreement'){
                    existingContainers = [SELECT Id, ExternalCaseId__c FROM TLO_Case__c WHERE ExternalCaseId__c IN :externalIds];
                }else if(typeName == 'Sponsor_Agreement'){
                    existingContainers = [SELECT Id, ExternalCaseId__c FROM TLO_Case__c WHERE ExternalCaseId__c IN :externalIds];
                }
            }

            if (existingContainers != null && !existingContainers.isEmpty()) {
                insert cvList;
                List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                for (ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvList]) {
                    for (SObject container : existingContainers) {
                        ContentDocumentLink conDocLink = new ContentDocumentLink();
                        conDocLink.LinkedEntityId = container.Id;
                        conDocLink.ContentDocumentId = cv.ContentDocumentId;
                        conDocLink.Visibility = 'AllUsers';
                        conDocLink.shareType = 'I';
                        cdList.add(conDocLink);
                    }
                }
                insert cdList;
            } else {
                return 'Found no existing Record to link the file(s) with.';
            }
            return 'success';
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static String uploadRelatedDocuments(String filedata, String recordId, String contentVersionRecordTypeId, String agreementDataSubTypeValue, String agreementRecId, String selectedDocumentTypeOptions) {
        try {
            if (String.isBlank(filedata)) {
                return 'File data is blank.';
            }

            List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
            if (files.isEmpty()) {
                return 'No files found to upload.';
            }

            List<ContentVersion> cvList = new List<ContentVersion>();
            for (FileDataWP file : files) {
                ContentVersion conVer = new ContentVersion();
                conVer.Document_Classification__c = selectedDocumentTypeOptions;
                conVer.ContentLocation = 'S';
                conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
                conVer.Title = file.fileName;
                conVer.RecordTypeId = contentVersionRecordTypeId;
                conVer.Entity_Sub_Type__c = agreementDataSubTypeValue;
                conVer.PathOnClient = file.fileName ;
                cvList.add(conVer);
            }

            List<SObject> existingContainers = new List<SObject>();
            String objectName = 'ContentVersion';

            if (agreementRecId != null) {
                String typeName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(contentVersionRecordTypeId)?.getDeveloperName();
                if (typeName == 'TLO_Agreement') {
                    existingContainers = [Select Id, ExternalAgreement__c from Agreement__c where ExternalAgreement__c =:agreementRecId];
                }
            }

            if (existingContainers != null && !existingContainers.isEmpty()) {
                insert cvList; // We dont want Orphan documents
                List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                for (ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvList]) {
                    for (SObject container : existingContainers) {
                        ContentDocumentLink conDocLink = new ContentDocumentLink();
                        conDocLink.LinkedEntityId = container.Id;
                        conDocLink.ContentDocumentId = cv.ContentDocumentId;
                        conDocLink.Visibility = 'AllUsers';
                        conDocLink.shareType = 'I';
                        cdList.add(conDocLink);
                    }
                }
                insert cdList;
            } else {
                return 'Found no existing Record to link the file(s) with.';
            }
            return 'success';
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    /**
* @description: This is used to get all recordtypes on case object except the master .
* @return all recordtypes on Content version as picklist except the master recordtype.
**/
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeInfoWrapper> getContentVersionRecordTypes() {
        List<RecordTypeInfoWrapper> recordTypes = new List<RecordTypeInfoWrapper>();

        // Get all record types of ContentVersion
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType contentType = globalDescribe.get('ContentVersion');
        Schema.DescribeSObjectResult describeResult = contentType.getDescribe();

        List<Schema.RecordTypeInfo> recordTypeInfos = describeResult.getRecordTypeInfos();

        for(Schema.RecordTypeInfo recordTypeInfo : recordTypeInfos) {
            // Exclude the master record type
            if (!recordTypeInfo.isMaster() && recordTypeInfo.getDeveloperName() != 'Disclosure' && recordTypeInfo.getDeveloperName() != 'DisclosureInventor' && recordTypeInfo.getDeveloperName() != 'Note') {
                recordTypes.add(new RecordTypeInfoWrapper(recordTypeInfo));
            }
        }

        return recordTypes;
    }

    // Wrapper class for RecordTypeInfo
    public class RecordTypeInfoWrapper {
        @AuraEnabled
        public String recordTypeId { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String developerName { get; set; }

        public RecordTypeInfoWrapper(Schema.RecordTypeInfo recordTypeInfo) {
            this.recordTypeId = recordTypeInfo.getRecordTypeId();
            this.name = recordTypeInfo.getName();
            this.developerName = recordTypeInfo.getDeveloperName();
        }
    }
    public class ObjectWrapper {
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String icon { get; set; }
        @AuraEnabled public String variant { get; set; }
        @AuraEnabled public Integer linkCount { get; set; }

    }

    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
}