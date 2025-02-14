@RestResource(urlMapping =  '/api/generate-signing-url/v1/*')
global with sharing class DocumentGenerateEmbeddedSigningAPI {

    @HttpGet
    global static String generateEmbeddedSigningUrl() {        
        String disclosureIdStr = RestContext.request.params.get('disclosureId');
        String returnUrl = RestContext.request.params.get('returnUrl');
        String inventorId = RestContext.request.params.get('inventorId');

        System.debug('#disclosureIdStr: ' + disclosureIdStr);
        System.debug('#returnUrl: ' + returnUrl);
        System.debug('#inventorId: ' + inventorId);

        //Native App not needing to pass the returnUrl in.. therefore always use localhost
        returnUrl = returnUrl != null ? returnUrl : 'http://localhost';

        Disclosure__c disclosure = [SELECT Id, Name, Signing_Envelop_Id__c,
                                            Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                        FROM Disclosure__c 
                                        WHERE Id = :disclosureIdStr];

        Boolean disclosureHasEnvelopeId = disclosure.Signing_Envelop_Id__c != null;
        System.debug('#disclosureHasEnvelopeId: ' + disclosureHasEnvelopeId);

        RestResponse response = RestContext.response;
        if (!disclosureHasEnvelopeId) {            
            // no envelopId therefore respond with error
            response.statusCode = 400; // calling this on a disclosure which has not had initiate signing process run yet
            return 'Ensure `/api/initiate-signing-process/v2/*` has been called first, Disclosure DocuSign Envenlope Creation could Still Processing';
        } else {
            response.statusCode = 200; // 200 - complete

            DocuSignService docuSignService = new DocuSignService();
            return docuSignService.generateEmbeddedSigningUrl(disclosureIdStr, returnUrl, inventorId);
        }
    }
}