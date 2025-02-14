// https://www.salesforceben.com/batch-apex/#:~:text=The%20difference%20between%20queueable%20and,can%20run%20up%20to%20100!

// Batch Apex jobs are limited to five tasks running simultaneously, whereas queueable jobs can run up to 100!

//** Queueable Apex can be used to run processes that will take a long time, such as extensive database operations or external web service callouts. 
 /*  Queueable Apex is a more advanced and enhanced version of the future method with a few added features which are mentioned below */

//
// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_transaction_finalizers.htm
public with sharing class DocuSignEnvelopeForDisclosureJob implements Finalizer, Queueable, Database.AllowsCallouts {
    public static Integer DEFAULT_INIT_SIGNING_JOB_MAX_RETRY = 1;
    private String disclosureIdStr;
    private Integer count;

    public DocuSignEnvelopeForDisclosureJob(String disclosureIdStr, Integer count){
        this.disclosureIdStr = disclosureIdStr;
        this.count = count;
    }

    public void execute(QueueableContext ctx) {
        DocuSignService docuSignService = new DocuSignService();
        Finalizer f = this;
        System.attachFinalizer(f);

        String jobId = '' + ctx.getJobId();
        System.debug('Begin: executing DocuSignEnvelopeForDisclosureJob queueable job: ' + jobId);

        try {

            DisclosureWrapper  disclosureWrapper = DisclosureDao.getDisclosureWrapperById(this.disclosureIdStr, null);
            String disclosureEnvelopeId = disclosureWrapper.disclosure.Signing_Envelop_Id__c;

            Boolean includeCoverPage = false;
            String base64Pdf = DocumentGenerationService.generate(disclosureWrapper.recordTypeDeveloperName, disclosureWrapper, includeCoverPage);
            Blob disclosureDocument = EncodingUtil.base64Decode(base64Pdf);  

            String envelopeId = disclosureWrapper.disclosure.Signing_Envelop_Id__c;
            System.debug('DocuSignEnvelopeForDisclosureJob envelopeId: ' + envelopeId);
            if (String.isEmpty(envelopeId)) {
                envelopeId = docuSignService.createEnvelopeForDisclosure(disclosureIdStr, disclosureDocument, disclosureWrapper);
            } else {
                docuSignService.updateEnvelopeForDisclosure(envelopeId, disclosureDocument, disclosureWrapper);
            }

            Disclosure__c d = disclosureWrapper.disclosure;
            d.Signing_Envelop_Id__c = envelopeId;
            d.Last_Modified_at_time_of_Signing_Request__c = DateTime.now();
            update d;

            System.debug('disclosureWrapper.disclosure.Signing_Envelop_Id__c: ' + disclosureWrapper.disclosure.Signing_Envelop_Id__c);
            System.debug('d.Signing_Envelop_Id__c: ' + disclosureWrapper.disclosure.Signing_Envelop_Id__c);
        } catch (Exception ex) {
            System.debug('DocuSignEnvelopeForDisclosureJob Error executing the job [' + jobId + ']: ' + ex.getMessage());      

            throw ex;
        } finally {
            System.debug('DocuSignEnvelopeForDisclosureJob Completed: execution of queueable job: ' + jobId);
        }
    }

    // Finalizer implementation (Retry) for initial Queueable Job
    public void execute(FinalizerContext ctx) {
        String parentJobId = '' + ctx.getAsyncApexJobId();
        System.debug('Begin: executing finalizer attached to DocuSignEnvelopeForDisclosureJob queueable job: ' + parentJobId);
        
        if (ctx.getResult() == ParentJobResult.SUCCESS) {
            System.debug('DocuSignEnvelopeForDisclosureJob queueable job [' + parentJobId + '] completed successfully.');
        } else {
            System.debug('DocuSignEnvelopeForDisclosureJob queueable job [' + parentJobId + '] failed due to unhandled exception: ' + ctx.getException().getMessage());

            HandleLogException.logException(ctx.getException());

            System.debug('this.count: ' + this.count);
            System.debug('retryCount(): ' + retryCount());


            // retries requests exponentially, increasing the waiting time between retries
            System.debug('Enqueueing another instance of the DocuSignEnvelopeForDisclosureJob queueable...');
            // removing the delay
            Integer delayInMinutes = 0; // will this create a sort of exponential backoff retry (?? increasing the waiting time between retries) is it too much to be in minutes (SF only allows for min's)

            System.debug('this.count <= retryCount(): ' + (this.count <= retryCount()));
            if (this.count <= retryCount()) {
                this.count = count + 1;

                Disclosure__c d = [SELECT Id, Status__c, 
                                            Signing_Envelop_Id__c, Signing_Init_Job_Id__c,
                                            Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                    FROM Disclosure__c 
                                    WHERE Id = :disclosureIdStr];

                String newJobId = '' + System.enqueueJob(new DocuSignEnvelopeForDisclosureJob(this.disclosureIdStr, this.count), delayInMinutes); // This call fails after 5 times when it hits the chaining limit
                System.debug('Enqueued new job: ' + newJobId);

                d.Signing_Init_Job_Id__c = newJobId; // TODO keep this in another table not against the Disclosure .. last mod wont change & can keep retry count
                update d;

            } else {
                System.debug('DocuSignEnvelopeForDisclosureJob queueable job retry\'s have been exhausted');                    
            }            
        }

        System.debug('Completed: execution of finalizer attached to DocuSignEnvelopeForDisclosureJob queueable job: ' + parentJobId);
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