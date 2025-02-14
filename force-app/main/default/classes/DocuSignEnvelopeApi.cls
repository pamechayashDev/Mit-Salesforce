public with sharing class DocuSignEnvelopeApi {
    private String accountId = '';
    private Map<string, string> headers = new Map<String, String>();

    public DocuSignEnvelopeApi() {
        headers.put( 'Content-Type',  'application/json;charset=UTF-8');

        DocuSign_Settings__c docuSignSettings = DocuSign_Settings__c.getInstance();
        System.debug('docuSignSettings.DocuSign_Account_Id__c: ' + docuSignSettings.DocuSign_Account_Id__c);
        
        accountId = docuSignSettings.DocuSign_Account_Id__c;
    }

    public Blob getDocumentByRecipientId(String envelopeId, String recipientId) {
        Map<string, string> queryParams = new Map<String, String>();
        queryParams.put('documents_by_userid', 'false');
        queryParams.put('recipient_id', recipientId);
        
        String queryParamsStr = StringUtils.convertMapToQueryString(queryParams);
        Blob docBlob = DocuSignApiCall.restGetBodyAsBlob('accounts/' + accountId + '/envelopes/' + envelopeId + '/documents/combined?' + queryParamsStr, headers);

        return docBlob;
    }

    public Blob getDocumentByEnvelopeId(String envelopeId) {
        Map<string, string> queryParams = new Map<String, String>();
        queryParams.put('documents_by_userid', 'false');

        String queryParamsStr = StringUtils.convertMapToQueryString(queryParams);
        Blob docBlob = DocuSignApiCall.restGetBodyAsBlob('accounts/' + accountId + '/envelopes/' + envelopeId + '/documents/combined?' + queryParamsStr, headers);

        return docBlob;
    }

   
}