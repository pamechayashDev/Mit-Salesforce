public without sharing class ContentDocumentTriggerHandler {

    public static void onBeforeDelete(List<ContentDocument> oldContentDocuments) {
        validateDelete(oldContentDocuments);
    }

    private static void validateDelete(List<ContentDocument> oldContentDocuments) {
        Map<Id, ContentDocument> contentDocumentIds = new Map<Id, ContentDocument>(oldContentDocuments);
        Map<Id, ContentVersion> allContentVersions = new Map<Id, ContentVersion>([SELECT Id, RecordType.DeveloperName, OwnerId, ContentDocumentId 
                                                                                  FROM ContentVersion 
                                                                                  WHERE ContentDocumentId IN :contentDocumentIds.keySet()]);
        
        Map<Id, List<ContentDocumentLink>> contentDocumentLinks = new Map<Id, List<ContentDocumentLink>>();        
        List<ContentDocumentLink> allContentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink 
                                                             WHERE ContentDocumentId IN :contentDocumentIds.keySet()];
        for (ContentDocumentLink contentDocumentLink : allContentDocumentLinks) {
            if (!contentDocumentLinks.containsKey(contentDocumentLink.ContentDocumentId)) {
                contentDocumentLinks.put(contentDocumentLink.ContentDocumentId, new List<ContentDocumentLink>());
            }
            contentDocumentLinks.get(contentDocumentLink.ContentDocumentId).add(contentDocumentLink);
        }

        for (Id contentVersionId : allContentVersions.keySet()) {
            ContentVersion contentVersion = allContentVersions.get(contentVersionId);

            // Prevent deletion of IPIA Type Template ContentDocument if it is linked to an IPIA Type
            // The IPIA Type Delete Trigger will validate if the IPIA Type is deletable, and if so, it will delete the ContentDocumentLink first.
            if (contentVersion.RecordType.DeveloperName == 'IPIA_Type_Template') {
                for (ContentDocumentLink contentDocumentLink : contentDocumentLinks.get(contentVersion.ContentDocumentId)) {
                    if (contentDocumentLink.LinkedEntityId.getSobjectType() == IPIA_Type__c.SObjectType) {
                        contentDocumentIds.get(contentVersion.ContentDocumentId).addError(Label.IPIA_Type_Template_Delete_Error);
                    }
                }
            }
            if (contentVersion.RecordType.DeveloperName == 'Compliance') {
                for (ContentDocumentLink contentDocumentLink : contentDocumentLinks.get(contentVersion.ContentDocumentId)) {
                    if (contentDocumentLink.LinkedEntityId.getSobjectType() == Utilization_Report__c.SObjectType) {
                        contentDocumentIds.get(contentVersion.ContentDocumentId).addError(Label.Compliance_Type_Delete_Error);
                    }
                }
            }
        }


        // Prevent deletion of IPIA ContentDocument if it is linked to an IPIA_Record that has DocuSign meta data against it
        // outside of the above loop as we need to also query IPIA Records (in bulkified way)
        Map<Id, ContentVersion> ipiaContentVersions = new Map<Id, ContentVersion>();
        for (Id contentVersionId : allContentVersions.keySet()) {
            ContentVersion cv = allContentVersions.get(contentVersionId);
            if (cv.RecordType.DeveloperName == 'IPIA') {
                ipiaContentVersions.put(cv.ContentDocumentId, cv);
            }
        }

        Set<Id> linkedEntityIds = new Set<Id>();
        for (Id contentDocumentId : ipiaContentVersions.keySet()) {
            if (contentDocumentLinks.containsKey(contentDocumentId)) {
                List<ContentDocumentLink> links = contentDocumentLinks.get(contentDocumentId);
                for (ContentDocumentLink link : links) {
                    linkedEntityIds.add(link.LinkedEntityId);
                }
            }
        }
        Map<Id, IPIA_Record__c> ipiaRecords = new Map<Id, IPIA_Record__c>([SELECT Id, DocusignTemplate__c, DocusignEnvelopeId__c
                                                            FROM IPIA_Record__c 
                                                            WHERE Id IN :linkedEntityIds]);

        for (Id contentVersionId : ipiaContentVersions.keySet()) {
            ContentVersion contentVersion = ipiaContentVersions.get(contentVersionId);
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinks.get(contentVersion.ContentDocumentId)) {
                IPIA_Record__c ipiaRecord = ipiaRecords.get(contentDocumentLink.LinkedEntityId);

                if (contentDocumentLink.LinkedEntityId.getSobjectType() == IPIA_Record__c.SObjectType) {
                    Boolean docuSignMetaDataExists = (ipiaRecord != null) && (ipiaRecord.DocusignTemplate__c != null || ipiaRecord.DocusignEnvelopeId__c != null);
                    if (docuSignMetaDataExists) {
                        contentDocumentIds.get(contentVersion.ContentDocumentId).addError(Label.IPIA_Record_Delete_DocuSignDoc_Error);
                    }
                }
            }
        }
    }
}