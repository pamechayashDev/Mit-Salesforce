@RestResource(urlMapping =  '/api/initiate-signing-process/v2/*')
global with sharing class DisclosureInitiateSigningProcessAPIV2 {    

    @HttpGet
    global static String initiateDisclosureSigningProcess() {
        RestResponse response = RestContext.response;

        String disclosureIdStr = RestContext.request.params.get('disclosureId');
        System.debug('#disclosureIdStr: ' + disclosureIdStr);

        Disclosure__c disclosure = getDisclosure(disclosureIdStr);
        Boolean disclosureHasEnvelopeId = disclosure.Signing_Envelop_Id__c != null;
        System.debug('#disclosureHasEnvelopeId: ' + disclosureHasEnvelopeId);

        String jobId = disclosure.Signing_Init_Job_Id__c;
        Boolean disclosureHasInitJobId = disclosure.Signing_Init_Job_Id__c != null;
        System.debug('#disclosureHasInitJobId: ' + disclosureHasInitJobId);
        
        String requestStatus = '';
        if (!disclosureHasEnvelopeId) { // No DocuSign envelopId for disclosure yes
            if (disclosureHasInitJobId) {
                requestStatus = mapQueueableStatusToResponseStatus(jobId);
                // The Job is completed and we still dont have an EnvelopeId
                if (requestStatus == 'Completed') {
                    requestStatus = 'Failed';
                }
            } else {
                requestStatus = 'NewJobNeeded';
            }
        } else { // DocuSign envelopId exists for disclosure

            Integer toleranceInSec = 2;
            DateTime modifiedDate = disclosure.Last_Modified_at_time_of_Signing_Request__c != null ? disclosure.Last_Modified_at_time_of_Signing_Request__c : disclosure.LastModifiedDate;
            DateTime startDate = disclosure.LastModifiedDate.addSeconds(-toleranceInSec);
            DateTime endDate = disclosure.LastModifiedDate;
            Boolean lastModifiedInTimeRange = modifiedDate >= startDate && modifiedDate <= endDate;

            Boolean isDraft = (disclosure.Status__c == 'Draft');
            Boolean modifiedSinceSigningLastRequest = !lastModifiedInTimeRange ;

            System.debug('#disclosure.Status__c: ' + disclosure.Status__c);
            System.debug('#isDraft: ' + isDraft);
            System.debug('#modifiedSinceSigningLastRequest: ' + modifiedSinceSigningLastRequest);
            if (isDraft && modifiedSinceSigningLastRequest) {
                // new job to be kicked off
                requestStatus = mapQueueableStatusToResponseStatus(jobId);
                if (requestStatus == 'Completed') {
                    requestStatus = 'NewJobNeeded';
                }
            } else {
                // we have env id and its not(isDraft && modifiedSinceSigningLastRequest), we don't need to check the job status everything is in place and ready
                // ie: we will only ever need to do a new job if we have the env id and (its in Draft && modifiedSinceSigningLastRequest) to update main doc on DocuSign.
                System.debug('not in draft with env id, no need for new job');
                requestStatus = 'Completed'; 
            }
        }

        // removing allowing of the app to re-try more than once as its causing lots of looping infinately at the momemetn
        // TODO should we add in checks for retry count? 
         if (requestStatus == 'Failed') {  // allows for job to the re-tried
            // Return 500, client can then resend request to create new jobId
            disclosure.Signing_Init_Job_Id__c = null;
            update disclosure;
         }

        switch on requestStatus  {
            when 'Completed' {
                response.statusCode = 200; // 200 - complete
                return 'Disclosure DocuSign Envenlope Ready for Inventors to start signing';
            }
            when 'Processing' {
                response.statusCode = 202; // 202 - accepted not complete
                return 'Disclosure DocuSign Envenlope Creation Still Processing';
            }
            when 'Failed' {
                response.statusCode = 500; // 500 - internal server error 
                return 'Failed Disclosure DocuSign Envenlope';
            }
            when 'NewJobNeeded' { 
                // happens if we want to update the DocuSign Envelope
                Integer currCount = 1;
                Id newJobId = System.enqueueJob(new DocuSignEnvelopeForDisclosureJob(disclosure.Id, currCount), 0);
                System.debug('#newJobId: ' + newJobId);

                disclosure.Signing_Init_Job_Id__c = newJobId; // TODO keep this in another table not against the Disclosure .. last mod wont change & can keep retry count
                update disclosure;

                response.statusCode = 202; // 202 - accepted not complete
                return 'Disclosure DocuSign Envenlope Creation Still Processing';
            }
            when else {
                response.statusCode = 500; // 500 - internal server error 
                return 'Failed Disclosure DocuSign Envenlope';
            }
        }
    }

    private static Disclosure__c getDisclosure(String disclosureIdStr) {
        Disclosure__c disclosure = [SELECT Id, Status__c, 
                                            Signing_Envelop_Id__c, Signing_Init_Job_Id__c,
                                            Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                    FROM Disclosure__c 
                                    WHERE Id = :disclosureIdStr];

        return disclosure;
    }
    
    private static String mapQueueableStatusToResponseStatus (Id jobId) {
        if (jobId == null) {
            return 'NewJobNeeded';
        }

        AsyncApexJob jobInfo;
        try {
            jobInfo = [SELECT Status FROM AsyncApexJob WHERE Id = :jobId];
        } catch (Exception e) {
            return 'NewJobNeeded';
        }
            
        switch on jobInfo?.Status  {
            when 'Completed' {
                return 'Completed';
            }
            when 'Preparing', 'Processing', 'Queued' {
                return 'Processing'; 
            }
            when else { //'Failed', 'Aborted' and any others not called out above
                return 'Failed';
            }
        }
    }

}