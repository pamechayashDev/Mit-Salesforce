// https://www.salesforceben.com/batch-apex/#:~:text=The%20difference%20between%20queueable%20and,can%20run%20up%20to%20100!

public with sharing class DocuSignSummaryInfoJob implements Finalizer, Queueable, Database.AllowsCallouts {
    public static Integer DEFAULT_INIT_SIGNING_JOB_MAX_RETRY = 1;
    private String disclosureIdStr;
    private Integer count;

    public DocuSignSummaryInfoJob(String disclosureIdStr, Integer count){
        this.disclosureIdStr = disclosureIdStr;
        this.count = count;
    }

    public void execute(QueueableContext ctx) {
        DocuSignService docuSignService = new DocuSignService();
        Finalizer f = this;
        System.attachFinalizer(f);

        String jobId = '' + ctx.getJobId();
        System.debug('Begin: executing DocuSignSummaryInfoJob queueable job: ' + jobId);

        

        try {

            Disclosure__c disclosure = [SELECT Id, Name, Signing_Envelop_Id__c, Inventors_Count__c, All_Inventors_Signed__c, Last_Modified_at_time_of_Signing_Request__c,
                                Signing_Init_Job_Id__c
                                FROM Disclosure__c
                                WHERE Id = :this.disclosureIdStr];
            String envelopeId = disclosure.Signing_Envelop_Id__c;
            System.debug('Query: executing DocuSignSummaryInfoJob envelopeId: ' + envelopeId);
            if (String.isEmpty(envelopeId) && this.count <= retryCount()) {
               // Disclosure has no EnvelopId
               DisclosureWrapper disclosureWrapper = DisclosureDao.getDisclosureWrapperById(this.disclosureIdStr, null);
               Boolean includeCoverPage = false;
               String base64Pdf = DocumentGenerationService.generate(disclosureWrapper.recordTypeDeveloperName, disclosureWrapper, includeCoverPage);
               Blob disclosureDocument = EncodingUtil.base64Decode(base64Pdf);
               Integer delayInMinutes = 0;
               this.count = this.count + 1;
               envelopeId = docuSignService.createEnvelopeForDisclosure(disclosureIdStr, disclosureDocument, disclosureWrapper);
               disclosure.Signing_Envelop_Id__c = envelopeId;
               disclosure.Last_Modified_at_time_of_Signing_Request__c = DateTime.now();
               String newJobId = '' + System.enqueueJob(new DocuSignSummaryInfoJob(this.disclosureIdStr, this.count), delayInMinutes); // This call fails after 5 times when it hits the chaining limit
               disclosure.Signing_Init_Job_Id__c = newJobId;
               update disclosure;

               return;
            }
            System.debug('Step: executing DocuSignSummaryInfoJob addSummaryInfoDocument: ' + this.disclosureIdStr);
            docuSignService.addSummaryInfoDocument(this.disclosureIdStr);

            System.debug('Step: executing DocuSignSummaryInfoJob fetchDisclosureDocument: ' + this.disclosureIdStr);
            fetchDisclosureDocument(docuSignService, this.disclosureIdStr, disclosure.Name);

        } catch (Exception ex) {
            System.debug('DocuSignSummaryInfoJob Error executing the job [' + jobId + ']: ' + ex.getMessage());

            throw ex;
        } finally {
            System.debug('DocuSignSummaryInfoJob Completed: execution of queueable job: ' + jobId);
        }
    }

    private void fetchDisclosureDocument(DocuSignService docuSignService, String disclosureId, String disclosureName) {
        Blob inventorDocBlob = docuSignService.getDisclosureDocument(disclosureId);
        
        System.debug('DocuSignSummaryInfoJob inventorDocBlob received create ContentVersion');
        String fileName = 'DocuSign_' + disclosureName + '.pdf';

        List<ContentDocumentLink> documentLinks = [SELECT  LinkedEntityId , ContentDocumentId FROM  ContentDocumentLink
                WHERE LinkedEntityId = :disclosureId
                AND ContentDocumentId IN (SELECT ContentDocumentId FROM ContentVersion WHERE PathOnClient = :fileName and Document_Classification__c = 'Signed Disclosure' )
            ];
        Boolean isUpdate = false;    
        ContentDocumentLink documentLink = null;
        if( documentLinks.size() == 1 ){
            isUpdate = true;
            documentLink = documentLinks.get(0);
        }


        Id cvDisclosureRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Disclosure').getRecordTypeId();
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName; // Display name of the files
        cv.PathOnClient = fileName;
        cv.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        cv.VersionData = inventorDocBlob;
        cv.Document_Classification__c = 'Signed Disclosure';
        if (isUpdate && documentLink != null) {
            cv.ContentDocumentId = documentLink.ContentDocumentId; // Use the same ContentDocumentId
        }
        cv.RecordTypeId = cvDisclosureRecordTypeId;

        //Insert ContentVersion, need the Id.
        insert cv;

        System.debug('ContentVersion inventorDocBlob Created');
        if (!isUpdate) {
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.LinkedEntityId = disclosureId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
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
        System.debug('Begin: executing finalizer attached to DocuSignSummaryInfoJob queueable job: ' + parentJobId);
        
        if (ctx.getResult() == ParentJobResult.SUCCESS) {
            System.debug('DocuSignSummaryInfoJob queueable job [' + parentJobId + '] completed successfully.');
        } else {
            if (ctx.getException() != null) {
                System.debug('DocuSignSummaryInfoJob queueable job [' + parentJobId + '] failed due to unhandled exception: ' + ctx.getException().getMessage());
                HandleLogException.logException(ctx.getException());
            }

            System.debug('DocuSignSummaryInfoJob failed, this.count: ' + this.count);
            System.debug('retryCount(): ' + retryCount());


            // retries requests exponentially, increasing the waiting time between retries
            System.debug('Enqueueing another instance of the DocuSignSummaryInfoJob queueable...');
            // removing the delay
            Integer delayInMinutes = 0; // will this create a sort of exponential backoff retry (?? increasing the waiting time between retries) is it too much to be in minutes (SF only allows for min's)

            System.debug('this.count <= retryCount(): ' + (this.count <= retryCount()));
            if (this.count <= retryCount()) {
                this.count = this.count + 1;
                String newJobId = '' + System.enqueueJob(new DocuSignSummaryInfoJob(this.disclosureIdStr, this.count), delayInMinutes); // This call fails after 5 times when it hits the chaining limit
                System.debug('Enqueued new job: ' + newJobId);


            } else {
                System.debug('DocuSignSummaryInfoJob queueable job retry\'s have been exhausted');
            }            
        }

        System.debug('Completed: execution of finalizer attached to DocuSignSummaryInfoJob queueable job: ' + parentJobId);
    }

  public static void onDisclosureApprove(List<Disclosure__c> queryDisclosures,  Map<Id,Disclosure__c> oldDis) {
      for(Disclosure__c d:queryDisclosures) {
            Boolean onApproved = d.Status__c == 'Approved' && d.Status__c != oldDis.get(d.Id).Status__c;
            if(onApproved) {
                Integer currCount = 1;
                String envelopeId = d.Signing_Envelop_Id__c;
                Boolean createJob = true;
                // Dont create the Job if the envelopeId is Empty and we are busy with Unit testing
                if ((Test.isRunningTest() && String.isEmpty(envelopeId))) {
                    // If a disclosure is approved in a Unit test then a Queueable job is created. To avoid having to mock ALL the Call outs for each test
                    // not related to DocuSign we only run the test where the envelopeId was set.
                    createJob = false;
                }
                if (createJob) {
                    Id newJobId = System.enqueueJob(new DocuSignSummaryInfoJob(d.Id, currCount), 0);
                }
            }
        }
    }

    private static Integer retryCount() {
        try {
            String retryConf = ConfigurationBuilder.getConfigurationToString('initSigningJobMaxNumberOfRetry');
            return Integer.ValueOf(retryConf);
        } catch (ConfigurationBuilder.MissingConfigurationException ex) {
            return DocuSignEnvelopeForDisclosureJob.DEFAULT_INIT_SIGNING_JOB_MAX_RETRY;
        }
    }


}