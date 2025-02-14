public with sharing class MitDocuSignApi {
    public static final String MIT_DOCUSIGN_API = 'mitDocusignApi';

    public Blob getDocumentByEnvelopeId(String envelopeId) {
        String endpoints = '/envelopes/'+ envelopeId +'/documents/1';

        Blob response = AwsApiCall.restGetBodyAsBlob(MIT_DOCUSIGN_API, endpoints);
        if (response == null || response.size() == 0) {
            throw new CalloutException(
                'Call to Mit Docusign Account /envelopes failed, response is empty '
            );
        }

        System.debug('MitDocuSignApi.response');
        return response;
    }
}