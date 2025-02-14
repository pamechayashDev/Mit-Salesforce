public with sharing class ExternalDocumentController {

    @AuraEnabled(cacheable=false)
    public static String getSessionIdFromVFPage() {

        PageReference pageSessionId = Page.GetSessionId;
        String pageContent = pageSessionId.getContent().toString();
        String sessionIdStart = 'SESSION_ID_START';
        String sessionIdEnd = 'SESSION_ID_END';
        Integer startIndex = pageContent.indexOf(sessionIdStart) + sessionIdEnd.length();
        Integer endIndex = pageContent.indexOf(sessionIdEnd);
        String sessionId=pageContent.substring(startIndex, endIndex);
        return sessionId;

    }

    @AuraEnabled(cacheable=false)
    public static List<RecordResponse> getRecordsByProvider(String provider, String recordId ) {
        // This was only done for the POC, this need to move to Repository or Service Class.
        if (provider == 'Case_Sponsor') {
            KauliCoeusDataProvider dataProvider = new KauliCoeusDataProvider();
            return dataProvider.buildRecordSet();
        } else {
            DocuSignDataProvider dataProvider = new DocuSignDataProvider();
            return dataProvider.buildRecordSet();
        }
        
    }



    public class KauliCoeusDataProvider {

        public List<RecordResponse> buildRecordSet() {
            List<RecordResponse> response = new List<RecordResponse>();
            
            RecordResponse row = new RecordResponse();
            row.name = 'KC-3887859';
            row.url = 'https://kc-qa-wkly.mit.edu/kc-qa-wkly/kr/maintenance.do?methodToCall=docHandler&docId=3888105&command=displayDocSearchView#topOfForm';
            row.recordType = 'pdf';
            response.add(row);

            row = new RecordResponse();
            row.name = 'KC-3891987';
            row.url = 'https://kc-qa-wkly.mit.edu/kc-qa-wkly/kr/maintenance.do?methodToCall=docHandler&docId=3891987&command=displayDocSearchView#topOfForm';
            row.recordType = 'pdf';
            response.add(row);

            return response;
        }
    }

    public class DocuSignDataProvider {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String pathParam = '/services/apexrest/api/document-proxy/v1?url=';

        public List<RecordResponse> buildRecordSet() {
            String endPoint =  baseUrl + '' + pathParam;
            List<RecordResponse> response = new List<RecordResponse>();
            RecordResponse row = new RecordResponse();
            row.name = 'Docusign-900047498';
            row.url = endPoint + EncodingUtil.urlEncode('callout:DocuSign_API/accounts/5529b715-7cb3-4661-b86f-529c9c8571f9/envelopes/0cb80692-9ffb-4179-b9a4-5d0f80c7a8d9/documents/combined?recipient_id=900047498', 'UTF-8');
            row.recordType = 'pdf';
            
            response.add(row);

            return response;
        }
    }

    
    public class RecordResponse {
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string url;
        @AuraEnabled
        public string recordType;
        
    }
}