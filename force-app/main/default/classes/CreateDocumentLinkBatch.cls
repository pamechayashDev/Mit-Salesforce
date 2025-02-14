// This will be a manual trigger as the Sys Admin Job Users
// Or the user that has ownership of the ContentVersion Files
global class CreateDocumentLinkBatch implements Database.Batchable<SObject>, Database.Stateful {
    public  Enum DocumentLinkType { IPIA }
    private DocumentLinkType documentType { get; set; }

    public CreateDocumentLinkBatch(DocumentLinkType documentType) {
        this.documentType = documentType;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('CreateDocumentLinkBatch Start');
        String likeValue = null;
        if (this.documentType == DocumentLinkType.IPIA ) {
            likeValue = '%IPIAs%';
        }

        if (!String.isBlank(likeValue)) {
            System.debug('CreateDocumentLinkBatch Linking IPIAs');
            return Database.getQueryLocator([SELECT Id, Title, Description, PathOnClient, TagCsv, Entity_Recid__c, Document_Classification__c,
                                             ContentSize, VersionNumber, IsLatest, ContentDocumentId
                                             FROM ContentVersion
                                             WHERE PathOnClient like :likeValue
                                         	    and Entity_Recid__c = '-1'
                                                and isLatest = true]);
        } else {
            System.debug('CreateDocumentLinkBatch Empty Document Link Type');
            // Empty result set
            return Database.getQueryLocator([SELECT Id FROM ContentVersion  where Id = null LIMIT 0]);
        }
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug(scope.size() + ' ContentVersions found');
        if (!scope.isEmpty()) {
            //System.enqueueJob(new CreateDocumentLinkJob(scope), 0);
            CreateDocumentLinkJob job = new CreateDocumentLinkJob(scope);
            QueueableContext ctx = null;
            job.execute(ctx);
        }
    }

    global void finish(Database.BatchableContext bc) {
    }


}