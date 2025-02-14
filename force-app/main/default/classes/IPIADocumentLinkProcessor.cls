public with sharing class IPIADocumentLinkProcessor extends DocumentLinkProcessor {

    @TestVisible
    protected override void createDocumentLink(List<ContentVersion> contentVersions) {
        if(contentVersions.isEmpty()) {
            return;
        }
        List<ContentVersion> contentVersionUpdateList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinkInsertList = new List<ContentDocumentLink>();
        List<Log_Document_Link__c> logs = new List<Log_Document_Link__c>();

        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>(contentVersions);
        Map<Id, FileNameDefinition> fileDefMap = new Map<Id, FileNameDefinition>();

        // Parse all TagCsv values
        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = parseCsvTag(contentVersion.TagCsv, contentVersion.Description);
            if(parsed == null) {
                contentVersion.Entity_RecId__c = '-1' ; // will allow retry
                contentVersionUpdateList.add(contentVersion);
                logs.add(getLogDocumentLinkInstance(contentVersion.Id, contentVersion.PathOnClient,'IPIA-Parsing-CsvTag', 'Unable to parse'));
                continue;
            }
            fileDefMap.put(contentVersion.Id, parsed);
        }

        //Build the SObject query filter sets
        Set<String> mitIdNumbers = new Set<String>();
        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = fileDefMap.get(contentVersion.Id);
            if(parsed == null) {
                continue;
            }
            mitIdNumbers.add(parsed.mitId);
        }

        // Bulk query SObject
        List<IPIA_Record__c> ipiaBulkList = [SELECT Id, MitId__c, FormName__c, SignDatetime__c, IPIA_Type__r.Name
                                                FROM IPIA_Record__c
                                                WHERE MitId__c =:mitIdNumbers ];
        Map<String, List<IPIA_Record__c>> ipiaLookup = new Map<String, List<IPIA_Record__c>>();
        for(IPIA_Record__c ipiaRecord : ipiaBulkList) {
            if (!ipiaLookup.containsKey(ipiaRecord.MitId__c)) {
                ipiaLookup.put(ipiaRecord.MitId__c, new List<IPIA_Record__c>());
            }
            ipiaLookup.get(ipiaRecord.MitId__c).add(ipiaRecord);
        }

        Map<String, String> existingIpiaDocumentLinkMap = getContentDocumentLinkMap(ipiaBulkList);
        List<ContentVersion> sortedContentVersions = sortContentVersionsDesc(contentVersions, fileDefMap);

        for(ContentVersion contentVersion : sortedContentVersions) {
            FileNameDefinition parsed = fileDefMap.get(contentVersion.Id);
            if(parsed == null) {
                continue;
            }

            List<IPIA_Record__c> ipiaRecords = ipiaLookup.get(parsed.mitId);
            if (ipiaRecords == null) {
                contentVersion.Entity_RecId__c = '-1' ; // will allow retry
                contentVersionUpdateList.add(contentVersion);

                logs.add(getLogDocumentLinkInstance(contentVersion.Id, contentVersion.PathOnClient, 'IPIA-SObject-Query', 'No rows found for IPIA_Record__c ' + parsed.mitId ));
                continue;
            }

            List<Id> linkedEntityIds = getLinkedEntityIds(existingIpiaDocumentLinkMap, ipiaRecords, parsed);
            if(linkedEntityIds.isEmpty()) {
                if (ipiaRecords.size() > 1) {
                    logs.add(getLogDocumentLinkInstance(contentVersion.Id, contentVersion.PathOnClient, 'IPIA-SObject-Link', 'Duplicate rows found for IPIA_Record__c ' + parsed.mitId + ' FileWriteDate ' + String.valueOf(parsed.fileWriteDate) ));
                } else {
                    logs.add(getLogDocumentLinkInstance(contentVersion.Id, contentVersion.PathOnClient, 'IPIA-SObject-Link', 'No Effective Date match found for IPIA_Record__c ' + parsed.mitId + ' FileWriteDate ' + String.valueOf(parsed.fileWriteDate) ));
                }
                continue;
            }

            for(Id linkedEntityId : linkedEntityIds) {
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.LinkedEntityId = linkedEntityId;
                conDocLink.ContentDocumentId = contentVersion.ContentDocumentId;
                conDocLink.ShareType = 'I';
                conDocLink.Visibility = 'AllUsers';
                contentDocumentLinkInsertList.add(conDocLink);
                // If duplicates exist in the same batch
                existingIpiaDocumentLinkMap.put(linkedEntityId, contentVersion.ContentDocumentId);

            }
            if (!linkedEntityIds.isEmpty()) {
                String entityRecId = String.valueOf(parsed.mitId);
                contentVersion.Entity_RecId__c = entityRecId;
                contentVersionUpdateList.add(contentVersion);
            }


        }
        if(!contentDocumentLinkInsertList.isEmpty()) {
            insert contentDocumentLinkInsertList;
        }
        if(!contentVersionUpdateList.isEmpty()) {
            update contentVersionUpdateList;
        }
        if(!logs.isEmpty()) {
            insert logs;
        }
    }

    @TestVisible
    private List<ContentVersion> sortContentVersionsDesc(List<ContentVersion> contentVersions, Map<Id, FileNameDefinition> fileDefMap) {
        List<IPIAContentVersionWrapper> contentVersionWrappers = new List<IPIAContentVersionWrapper>();
        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = fileDefMap.get(contentVersion.Id);
            contentVersionWrappers.add(new IPIAContentVersionWrapper(contentVersion, parsed));
        }
        contentVersionWrappers.sort();
        List<ContentVersion> sortedContentVersion = new List<ContentVersion>();
        for(IPIAContentVersionWrapper wrapper :contentVersionWrappers) {
            sortedContentVersion.add(wrapper.contentVersion);
        }
        return sortedContentVersion;
    }

    private Map<String, String> getContentDocumentLinkMap(List<IPIA_Record__c> ipiaBulkList) {
        Map<Id, IPIA_Record__c> ipiaMap = new Map<Id, IPIA_Record__c>(ipiaBulkList);
        Set<Id> ipiaIds = ipiaMap.keySet();
        if(ipiaIds.isEmpty()) {
            return new Map<String, String>();
        }
        List<ContentDocumentLink> cdLinks = [ SELECT Id, ContentDocumentId, LinkedEntityId
                            FROM ContentDocumentLink WHERE  LinkedEntityId in :ipiaIds
        					];
        Map<String, String> ipiaDocumentLinkMap = new Map<String, String>();
        for (ContentDocumentLink cdl : cdLinks ) {
            ipiaDocumentLinkMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
        }
        return ipiaDocumentLinkMap;
    }

    private List<Id> getLinkedEntityIds(Map<String, String> existingIpiaDocumentLinkMap, List<IPIA_Record__c> ipiaRecords, FileNameDefinition parsed ) {
        Integer maxRangeInDays = getConfigValue('IpiaDocumentLinkSignedMaxRangeInDays', 90); // 3 months

        // Limit to signed date being in close proximity
        List<Id> linkedEntityIds = new List<Id>();
        Integer minVal = maxRangeInDays;
        for(IPIA_Record__c ipiaRecord : ipiaRecords) {

             // Ignore already linked IPIAs
             if (existingIpiaDocumentLinkMap.containsKey(ipiaRecord.Id)) {
                continue;
             }

            if(isFileWriteDatesInCloseProximity(maxRangeInDays, ipiaRecord, parsed)) {
                Integer daysBetween = getDaysBetween(ipiaRecord.SignDatetime__c, parsed.fileWriteDate);
                if(daysBetween != -1 && daysBetween <= minVal) {
                    minVal = daysBetween;
                    linkedEntityIds = new List<Id>{ipiaRecord.Id};
                }
            }
        }
        return linkedEntityIds;
    }
    private Boolean isFileWriteDatesInCloseProximity(Integer maxRangeInDays, IPIA_Record__c ipiaRecord, FileNameDefinition parsed){
        if (parsed.fileWriteDate == null) {
            // we dont have a file write date
            return true;
        }
        Boolean isMatch = false;
        if (parsed.fileWriteDate != null) {
            Datetime recordSignDate = ipiaRecord.SignDatetime__c;
            Datetime fileWriteDate = parsed.fileWriteDate;
            isMatch = isDatesInRange(recordSignDate, fileWriteDate, maxRangeInDays);
        }
        return isMatch;
    }


    @TestVisible
    private Boolean isDatesInRange(Datetime firstDate, Datetime secondDate, Integer rangeInDays) {
        if (firstDate == null || secondDate == null) {
            return false;
        }
        Integer days = getDaysBetween(firstDate, secondDate);
        if(days < 0 ) {
            return false;
        }
        return days <= rangeInDays;

    }

    private Integer getDaysBetween(Datetime firstDate, Datetime secondDate) {
        if (firstDate == null || secondDate == null) {
            return -1;
        }
        Integer daysBetween = firstDate.date().daysBetween(secondDate.date());
        Integer days = Math.abs(daysBetween);
        return days;
    }

    @TestVisible
    private FileNameDefinition parseCsvTag(String csvTag, String description) {
        DateTime fileWriteDate = null;
        if (description != null && description.contains('FileWriteDate:')) {
            String fileWriteDateStr =  description.substringAfter('FileWriteDate:').trim();
            fileWriteDate = DateTime.valueOf(fileWriteDateStr.replace('/', '-'));
        }
        // We have a csvTag, use the value.
        if (csvTag != null) {
            System.debug(csvTag);
            FileNameDefinition parsed = new FileNameDefinition();
            parsed.mitId = StringUtils.removeNonNumericCharacters(csvTag);
            parsed.fileWriteDate = fileWriteDate;
            parsed.classification = null;
            return parsed;
        }
        return null;
    }

    @TestVisible
    private static Integer getConfigValue(String key, Integer defaultValue) {
        try {
            return Integer.valueOf(ConfigurationBuilder.getConfigurationToString(key));
        } catch (Exception ex) {
            return defaultValue;
        }
    }

}