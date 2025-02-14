public with sharing class CRDRDocumentUploadJob implements Queueable, Database.AllowsCallouts  {

    public final List<Id> cvIds;

    public CRDRDocumentUploadJob(List<Id> cvList) {
        this.cvIds = cvList;
    }

    public List<ContentVersion> start(QueueableContext ctx) {
        System.debug('CreateDocumentLinkJob:start ' + ctx.getJobId());

        if (cvIds != null && !cvIds.isEmpty()) {
            Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('CRDR').getRecordTypeId();
            return [ SELECT Id, Title, Description, PathOnClient, TagCsv,  Document_Classification__c, ContentSize, VersionNumber,
                                                                     IsLatest,
                                                                     RecordType.Name,
                                                                     ContentDocumentId,
                                                                     Entity_RecId__c
                                                        FROM ContentVersion WHERE Id IN :this.cvIds AND RecordTypeId = :recordTypeId  ];
        } else {
            return null;
        }
    }

    public void execute(QueueableContext ctx) {
        try {
            List<ContentVersion> scope = start(ctx);
            System.debug('CRDRDocumentUploadJob.execute');
            if(scope != null && !scope.isEmpty()) {
                System.debug('CreateDocumentLinkJob:scope ' + scope.size() );
                List<ContentVersion> caseCRDRs = new List<ContentVersion>();

                for(ContentVersion contentVersion : scope) {
                    if (contentVersion.RecordType.Name == 'CRDR' && contentVersion.Document_Classification__c.contains('CRDR')) {
                        caseCRDRs.add(contentVersion);
                    }
                }
            }
        } catch(Exception ex) {
            System.debug(ex);
            HandleLogException.logException(ex);
            throw ex;
        }
    }
}