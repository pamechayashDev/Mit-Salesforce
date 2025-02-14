public with sharing class KualiCoeusService {
    
    public static final String RESEARCH_API = 'researchApi';

    String baseUrl;
    
    public KualiCoeusService() {
        //Max Length of 100 Char when storing values in Custom Settings.
        baseUrl = kualiCoeusUrl() + 'docOpenedFromAwardSearch=true&docTypeName=AwardDocument&methodToCall=sharedDoc&command=displayDocSearchView&viewDocument=false&docId={0}&AwardId={1}';
    }

    public List<DocumentUrlResponse> generateDocumentUrl(String awardAccountNumber) {
        List<DocumentUrlResponse> response = new List<DocumentUrlResponse>();
        if (awardAccountNumber == null || awardAccountNumber == '') {
            return response;
        }

        String body = AwsApiCall.restGet(RESEARCH_API, '/awards/' + awardAccountNumber + '/parent-awards');
        AwardsResponse awardsResponse = (AwardsResponse) JSON.deserialize(body, AwardsResponse.class);

        if (awardsResponse.results == null) {
            return response;
        }

        for (AwardDto award : awardsResponse.results) {
            String documentNumber = award.documentNumber;
            String awardId = award.awardId;
            string sponsorName = award.sponsorName;
            // The index order is important!
            List<String> replacementValues = new List<String>{documentNumber, awardId};

            String url = String.format(baseUrl, replacementValues);
            DocumentUrlResponse row = new DocumentUrlResponse();
            row.accountNumber = awardAccountNumber;
            row.name = award.title;
            row.sponsorName= sponsorName;
            row.url = url;
            row.urlType = 'link';
            response.add(row);
        }

        return response;

    }

    private static String kualiCoeusUrl() {
        try {
            String retryConf = ConfigurationBuilder.getConfigurationToString('kualiCoeusUrl');
            return retryConf;
        } catch (ConfigurationBuilder.MissingConfigurationException ex) {
            return 'https://kc-qa-wkly.mit.edu/kc-qa-wkly/sharedDoc.do?';
        }
    }

    public class DocumentUrlResponse {
        @AuraEnabled
        public string accountNumber;
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string url;
        @AuraEnabled
        public string urlType;
        @AuraEnabled
        public string sponsorName;
    }

    //======================= MODEL DEFINITION, 
    // These classes match the RestAPI spec's
    //=======================

    private abstract class PageableDto {
        public Integer totalItems;
        public Integer totalPages;
        public Integer currentPage;
    }
    private class AwardDto {
        private String accountNumber;
        private String sponsorAwardNumber;
        private String title;
        private String sponsorCode;
        private String sponsorName;
        private String principalInvestigatorCode;
        private String principalInvestigatorName;
        private String documentNumber;
        private String awardId;
    }

    @TestVisible 
    private class AwardsResponse  extends PageableDto {    
        private List<AwardDto> results;  
    }

}