/**
 * Created by Andreas du Preez on 2024/07/26.
 */

public with sharing class IPIAController {

    @AuraEnabled
    public static boolean userHasIPIARecordCreatePermission() {
        return Schema.sObjectType.IPIA_Record__c.isCreateable();
    }

    @AuraEnabled
    public static boolean userHasIPIATypeCreatePermission() {
        return Schema.sObjectType.IPIA_Type__c.isCreateable();
    }

    @AuraEnabled
    public static IPIA_Record__c createIPIARecord(IPIA_Record__c ipiaRecord) {
        if (Schema.sObjectType.IPIA_Record__c.isCreateable()) {
            if (ipiaRecord != null && ipiaRecord.MitId__c != null && ipiaRecord.FormName__c != null) {
                insert ipiaRecord;
                return ipiaRecord;
            } else {
                throw new AuraHandledException('No IPIA Record data provided');
            }
        }
        else {
            throw new AuraHandledException('User does not have permission to create IPIA Record');
        }
    }

    @AuraEnabled
    public static void linkIPIARecordToDoc(Id ipiaRecordId, Id contentDocumentId) {
        // Create ContentDocumentLink
        ContentDocumentLink documentLink = new ContentDocumentLink();
        documentLink.ContentDocumentId = contentDocumentId;
        documentLink.LinkedEntityId = ipiaRecordId;
        // I = Inferred permission. The user’s permission is determined by the related record.
        // V = Viewer permission. The user can explicitly view but not edit the shared file.
        // C = Collaborator permission. The user can explicitly view and edit the shared file.
        documentLink.ShareType = 'I';
        documentLink.Visibility = 'AllUsers';
        insert documentLink;

        ContentVersion conVer = [SELECT Id, Entity_RecId__c 
                                 FROM ContentVersion 
                                 WHERE ContentDocumentId = :contentDocumentId];
        conVer.Entity_RecId__c = ipiaRecordId;
        update conVer; //Update ContentVersion
    }

    @AuraEnabled
    public static IPIA_Type__c createIPIAType(IPIA_Type__c ipiaType, String fileName, String fileBase64) {
        if (Schema.SObjectType.IPIA_Type__c.isCreateable()) {
            if (ipiaType != null) {
                insert ipiaType;

                if (!String.isBlank(fileBase64)) {
                    if (fileName == null) {
                        throw new AuraHandledException('No file name provided');
                    }

                    Id ipiaContentVersionRecordType = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('IPIA_Type_Template').getRecordTypeId();

                    ContentVersion version = new ContentVersion(
                            Title = fileName,
                            PathOnClient = fileName,
                            Document_Classification__c = 'IPIA_Type_Template',
                            VersionData = EncodingUtil.base64Decode(String.valueOf(fileBase64)),
                            RecordTypeId = ipiaContentVersionRecordType,
                            IsMajorVersion = false
                    );
                    insert version;

                    ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :version.Id];

                    ContentDocumentLink cdl = new ContentDocumentLink(
                            ContentDocumentId = cd.Id,
                            LinkedEntityId = ipiaType.Id,
                            ShareType = 'V',
                            Visibility = 'AllUsers'
                    );
                    insert cdl;
                }

                return ipiaType;
            } else {
                throw new AuraHandledException('No IPIA Type data or file provided');
            }
        }
        else {
            throw new AuraHandledException('User does not have permission to create IPIA Type');
        }
    }

    @AuraEnabled
    public static Id uploadIPIADocuments(Id recordId, String fileName, String base64FileContent, String contentVersionId) {
        try {
            base64FileContent = EncodingUtil.urlDecode(base64FileContent, 'UTF-8');
            
            if (String.isBlank(contentVersionId)) {
                // Get IPIA content version record type ID
                Id ipiaContentVersionRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('IPIA').getRecordTypeId();
                
                // Create new ContentVersion object
                ContentVersion newContentVersion = new ContentVersion();
                newContentVersion.Title = fileName;
                newContentVersion.VersionData = EncodingUtil.base64Decode(base64FileContent);
                newContentVersion.PathOnClient = fileName;
                newContentVersion.Document_Classification__c = 'Original_Document';
                newContentVersion.RecordTypeId = ipiaContentVersionRecordTypeId;
                newContentVersion.Entity_Sub_Type__c = 'IPIA';
                newContentVersion.IsMajorVersion = false;
                insert newContentVersion;

                // Retrieve ContentDocumentId
                Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :newContentVersion.Id].ContentDocumentId;

                // Create ContentDocumentLink
                ContentDocumentLink documentLink = new ContentDocumentLink();
                documentLink.ContentDocumentId = contentDocumentId;
                documentLink.LinkedEntityId = recordId;
                // I = Inferred permission. The user’s permission is determined by the related record.
                // V = Viewer permission. The user can explicitly view but not edit the shared file.
                // C = Collaborator permission. The user can explicitly view and edit the shared file.
                documentLink.ShareType = 'I';
                documentLink.Visibility = 'AllUsers';
                insert documentLink;

                contentVersionId = newContentVersion.Id;
            } else {
                // Update existing ContentVersion
                List<ContentVersion> existingContentVersions = [SELECT Id, VersionData, ContentDocumentId 
                                                                FROM ContentVersion 
                                                                WHERE Id = :contentVersionId];
                
                if (!existingContentVersions.isEmpty()) {
                    ContentVersion existingContentVersion = existingContentVersions[0];
                    String currentFileContent = EncodingUtil.base64Encode(existingContentVersion.VersionData);
                    existingContentVersion.VersionData = EncodingUtil.base64Decode(currentFileContent + base64FileContent);
                    update existingContentVersion;
                }
            }

            return Id.valueOf(contentVersionId);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+'  line'+ex.getLineNumber());
        }
    }


    // New method to delete the ContentDocument associated with a ContentVersion
    @AuraEnabled
    public static void deleteFile(Id contentVersionId) {
        try {
            // Query the ContentDocumentId from the ContentVersion
            ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
            // Query the ContentDocument and delete it, which will cascade to delete ContentVersions
            ContentDocument [] cdList = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId LIMIT 1];
            delete cdList;
        } catch (Exception ex) {
            throw new AuraHandledException('Error while deleting file: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static ContentVersion getIPIATypeTemplate(Id recordId) {
        try {
            ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            ContentVersion cv = [SELECT Id, Title, FileType, LastModifiedDate, ContentSize, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
            return cv;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static CurrentHistoricIPIARecords getIPIARecords(String mitId) {
        try {
            if (!String.isBlank(mitId)) {
                List<IPIA_Record__c> currentIPIA = IPIARecordService.getCurrentIPIARecords(new List<String>{mitId});
                List<IPIA_Record__c> historicIpiaRecords;

                if (currentIPIA.isEmpty()) {
                    // This will change when IPIA Record Status is implemented
                    return new CurrentHistoricIPIARecords(null, new List<IPIA_Record__c>());
                }
                else {
                    historicIPIARecords = [SELECT Id, Name, FormName__c, IPIA_Type__c, SignDatetime__c, IPIA_Type__r.Name, 
                                                  IPIA_Type__r.Exemption__c, IPIA_Type__r.Status__c, 
                                                  (SELECT ContentDocumentId FROM ContentDocumentLinks)
                                           FROM IPIA_Record__c 
                                           WHERE MitId__c = :mitId 
                                           AND Id != :currentIPIA[0].Id 
                                           ORDER BY SignDatetime__c DESC];
                }

                return new CurrentHistoricIPIARecords(currentIPIA[0], historicIpiaRecords);
            } else {
                return new CurrentHistoricIPIARecords(null, new List<IPIA_Record__c>());
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static IPIA_Record__c getCurrentIPIARecord(String mitId) {
        if (String.isEmpty(mitId)) {
            return null;
        }

        List<IPIA_Record__c> result = IPIARecordService.getCurrentIPIARecords(new List<String>{mitId});
        return result.isEmpty() ? null : result[0];
    }

    @AuraEnabled
    public static List<IPIA_Type__c> getAllIPIATypes(Boolean exemption) {
        return [SELECT Id, Name, Status__c, Exemption__c
                FROM IPIA_Type__c 
                WHERE Exemption__c = :exemption
                ORDER BY Name];
    }

    @AuraEnabled
    public static List<ContentVersion> getUnlinkedDocuments(String mitId) {
        try {
            Id ipiaContentVersionRecordType = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('IPIA').getRecordTypeId();
            
            String mitLikeStr  = '%' + mitId + '%';
            List<ContentVersion> ipiaCvsForMitId = [SELECT Id, Title, Description, PathOnClient, 
                                                    FileExtension, ContentDocumentId
                                        FROM ContentVersion 
                                        WHERE RecordTypeId = : ipiaContentVersionRecordType
                                        AND Entity_Sub_Type__c = 'IPIA' 
                                        AND (description like :mitLikeStr) 
                                        AND Entity_RecId__c = '-1'
                                        ORDER BY createddate desc];

            return ipiaCvsForMitId;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class CurrentHistoricIPIARecords {
        @AuraEnabled
        public IPIA_Record__c currentIPIARecord;
        @AuraEnabled
        public List<IPIA_Record__c> historicIPIARecords;

        public CurrentHistoricIPIARecords(IPIA_Record__c currentIPIARecord, List<IPIA_Record__c> historicIPIARecords) {
            this.currentIPIARecord = currentIPIARecord;
            this.historicIPIARecords = historicIPIARecords;
        }
    }
}