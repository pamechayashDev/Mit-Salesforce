// https://www.salesforceben.com/batch-apex/#:~:text=The%20difference%20between%20queueable%20and,can%20run%20up%20to%20100!

public with sharing class IPIADocuSignDownloadJob implements Finalizer, Queueable, Database.AllowsCallouts {
    public static Integer DEFAULT_IPIA_DOWNLOAD_JOB_MAX_RETRY = 3;
    private String asyncRequestIdStr;

    public IPIADocuSignDownloadJob(String asyncRequestIdStr){
        this.asyncRequestIdStr = asyncRequestIdStr;
    }

    private Async_Request__c getAsyncRequest() {
        Async_Request__c asyncRequest = [SELECT Id, Record_Id__c, Has_Processed__c, Retry_Count__c
                                            FROM Async_Request__c
                                            WHERE Id = :asyncRequestIdStr];
        return asyncRequest;
    }

    public void execute(QueueableContext ctx) {
        IPIARecordService ipiaService = new IPIARecordService();
        Finalizer f = this;
        System.attachFinalizer(f);

        String jobId = '' + ctx.getJobId();
        System.debug('Begin: executing IPIADocuSignDownloadJob queueable job: ' + jobId);

        Async_Request__c asyncRequest = getAsyncRequest();
        try {

            String ipiaRecordIdStr = asyncRequest.Record_Id__c;

            IPIA_Record__c ipiaRecord = [ SELECT Id, DocusignEnvelopeId__c,
                                                 IPIA_Type__c,
                                                 IPIA_Type__r.Name,
                                                 FormName__c,
                                                 MitId__c
                                                 FROM IPIA_Record__c
                                                 WHERE Id = :ipiaRecordIdStr];

            String envelopeId = ipiaRecord.DocusignEnvelopeId__c;
            System.debug('Query: executing IPIADocuSignDownloadJob envelopeId: ' + envelopeId);

            if (!String.isEmpty(envelopeId) && asyncRequest.Has_Processed__c == false) {
               String formName = (ipiaRecord.IPIA_Type__c != null) ? ipiaRecord.IPIA_Type__r.Name : ipiaRecord.FormName__c;
               String documentTitle = ipiaRecord.MitId__c + '-' + formName ;
               fetchIPIADocument(ipiaService, ipiaRecordIdStr, documentTitle);
            }
            asyncRequest.Has_Processed__c = true;
            update asyncRequest;

        } catch (Exception ex) {
             System.debug('IPIADocuSignDownloadJob Error executing the job [' + jobId + ']: ' + ex.getMessage());
             asyncRequest.Retry_Count__c = Integer.valueOf(asyncRequest.Retry_Count__c) + 1;
             asyncRequest.Has_Processed__c = false;
             update asyncRequest;

            throw ex;
        } finally {
            System.debug('IPIADocuSignDownloadJob Completed: execution of queueable job: ' + jobId);
        }
    }

    private void fetchIPIADocument(IPIARecordService ipiaService, String ipiaRecordId, String disclosureName) {
        Blob docBlob = ipiaService.getIpiaRecordDocument(ipiaRecordId);
        
        System.debug('IPIADocuSignDownloadJob docBlob received create ContentVersion');
        String fileName = 'IPIA_' + disclosureName + '.pdf';

        List<ContentDocumentLink> documentLinks = [SELECT  LinkedEntityId , ContentDocumentId FROM  ContentDocumentLink
                WHERE LinkedEntityId = :ipiaRecordId
                AND ContentDocumentId IN (SELECT ContentDocumentId FROM ContentVersion WHERE PathOnClient = :fileName and Entity_Sub_Type__c = 'IPIA' and Document_Classification__c = 'Original_Document' )
            ];
        Boolean isUpdate = false;    
        ContentDocumentLink documentLink = null;
        if( documentLinks.size() == 1 ){
            isUpdate = true;
            documentLink = documentLinks.get(0);
        }


        Id cvDisclosureRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('IPIA').getRecordTypeId();
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName; // Display name of the files
        cv.PathOnClient = fileName;
        cv.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        cv.VersionData = docBlob;
        cv.Document_Classification__c = 'Original_Document';
        cv.Entity_Sub_Type__c = 'IPIA';
        if (isUpdate && documentLink != null) {
            cv.ContentDocumentId = documentLink.ContentDocumentId; // Use the same ContentDocumentId
        }
        cv.RecordTypeId = cvDisclosureRecordTypeId;

        //Insert ContentVersion, need the Id.
        insert cv;

        System.debug('ContentVersion docBlob Created');
        if (!isUpdate) {
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.LinkedEntityId = ipiaRecordId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            //V - Viewer permission. C - Collaborator permission. I - Inferred permission
            conDocLink.ShareType = 'I';
            conDocLink.Visibility = 'AllUsers';

            insert conDocLink;
        }


    }

    // Finalizer implementation (Retry) for initial Queueable Job
    public void execute(FinalizerContext ctx) {
        String parentJobId = '' + ctx.getAsyncApexJobId();
        System.debug('Begin: executing finalizer attached to IPIADocuSignDownloadJob queueable job: ' + parentJobId);
        
        if (ctx.getResult() == ParentJobResult.SUCCESS) {
            System.debug('IPIADocuSignDownloadJob queueable job [' + parentJobId + '] completed successfully.');
        } else {
            if (ctx.getException() != null) {
                System.debug('IPIADocuSignDownloadJob queueable job [' + parentJobId + '] failed due to unhandled exception: ' + ctx.getException().getMessage());
                HandleLogException.logException(ctx.getException());
            }
        }
    }

  public static void startDocuSignIpiaDownload(List<IPIA_Record__c> queryIpiaRecords,  Map<Id,IPIA_Record__c> oldIpias) {

      List<Async_Request__c> asyncJobs = new List<Async_Request__c>();
      for(IPIA_Record__c d: queryIpiaRecords) {
            if (String.isBlank(d.DocusignEnvelopeId__c)) {
                continue;
            }
            IPIA_Record__c oldIpia = (oldIpias != null && oldIpias.get(d.Id) != null) ? oldIpias.get(d.Id) : new IPIA_Record__c();
            Boolean onRecordChanged = d.DocusignEnvelopeId__c != oldIpia.DocusignEnvelopeId__c ;
            System.debug('IPIADocuSignDownloadJob.onRecordChanged: ' + onRecordChanged );
            if(onRecordChanged) {

                String envelopeId = d.DocusignEnvelopeId__c;
                Async_Request__c asyncJob =
                                        AsyncRequestHelper.prepareAsyncRequest(
                                            d.Id,
                                            'IPIA_Record__c',
                                            'IPIADownloadSignedJob'
                                        );
                 asyncJobs.add(asyncJob);
            }
        }
        if (!asyncJobs.isEmpty()) {
            insert asyncJobs;
            for (Async_Request__c asyncJob : asyncJobs) {
              if (!Test.isRunningTest()) {
                Id newJobId = System.enqueueJob(new IPIADocuSignDownloadJob(asyncJob.Id), 0);
              }
            }
        }
    }

    private static Integer retryCount() {
        try {
            String retryConf = ConfigurationBuilder.getConfigurationToString('batchJobMaxNumberOfRetry');
            return Integer.ValueOf(retryConf);
        } catch (ConfigurationBuilder.MissingConfigurationException ex) {
            return DEFAULT_IPIA_DOWNLOAD_JOB_MAX_RETRY;
        }
    }


}