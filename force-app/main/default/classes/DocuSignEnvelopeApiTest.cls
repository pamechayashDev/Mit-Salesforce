@IsTest 
public with sharing class DocuSignEnvelopeApiTest {
    @IsTest 
    public static void getDocumentByRecipientId() {
        DocuSign_Settings__c docuSignConfig = new DocuSign_Settings__c(DocuSign_Account_Id__c = '5529b715-7cb3-4661-b86f-529c9c8571f9', 
                                                                       DocuSign_Disclosure_Signing_TemplateId__c = '123');
        insert docuSignConfig;

        DocuSignEnvelopeApi docuSignApi = new DocuSignEnvelopeApi();

        String envelopeId = '130381d7-b403-466a-9872-2106d362d66d';
        String recipientId = '1';

        Test.startTest();
            DocuSignApiMock docuSignApiMock = new DocuSignApiMock();
            Test.setMock(HttpCalloutMock.class, docuSignApiMock);

            Blob docBlob = docuSignApi.getDocumentByRecipientId(envelopeId, recipientId);
            String base64Pdf = EncodingUtil.base64Encode(docBlob);
            System.debug('\n\nbase64Pdf:- \n\n' + base64Pdf);
        Test.stopTest();

        System.assert(base64Pdf != null, 'This should not be null');
    }
}