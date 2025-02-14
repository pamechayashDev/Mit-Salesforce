public without sharing class BIPUtils {
    public static KualiResponse getKualData(String Url) {
        KualiResponse vKualiResponse;
        try {
            String body = AwsApiCall.restGet('piDashApi', Url);
             vKualiResponse = (KualiResponse) JSON.deserialize(body, KualiResponse.class);
             for(AwardDto vAward : vKualiResponse.results) {
                 System.debug('Title: '+vAward.title);
             }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return vKualiResponse;
    }
    public static KualiResponse getKualDataByProposalId(String vNumber) {
        return getKualData('/proposals/all?page=1&pageSize=10&search=proposalNumber~'+vNumber);
    }
    public static KualiResponse getKualDataByTitle(String vText) {
        //return getKualData('/departments/proposals/summary');
        return getKualData('/proposals/all?page=1&pageSize=10&search=title~'+vText);
    }
    public static MitPeopleResponse peopleSearch(String param) {
        String Url ='/search?query=+'+EncodingUtil.urlEncode(param, 'UTF-8')+'&krbStatus=any&onlyResultsWithEmail=true';
        system.debug('Url'+Url);

        String jsonResponse = AwsApiCall.restGet('peopleSearchApi', Url);
        system.debug('jsonResponse'+jsonResponse);
        MitPeopleResponse response = (MitPeopleResponse) JSON.deserialize(jsonResponse, MitPeopleResponse.class);
        
        system.debug('response '+response.people.size());
        if((response.people).size() > 0){
            return response;
        } else{
            return null;
        }
    }

    //======================= MODEL DEFINITION, 
    // These classes match the RestAPI spec's
    //=======================

    public abstract class PageableDto {
        public Integer totalItems;
        public Integer totalPages;
        public Integer currentPage;
    }
    public class AwardDto {
        private String proposalType;
        private String proposalNumber;
        private String proposalId;
        private String title;
        private String sponsorCode;
        private String sponsorName;
        private String leadUnitId;
        private String leadUnitName;
        private String startDate;
        private String endDate;
        private String deadlineDate;
        private List<Investigator> people;
    }
    public class Investigator{
        public String mitId;
        public String personName;
        public String personRole;
    }

    @TestVisible 
    public class KualiResponse  extends PageableDto {    
        private List<AwardDto> results;  
    }


    public static List<Account> getPerson(String searchParam){
        List<Account> accounts = new List<Account>();
        if(searchParam.contains('@')){
            accounts =  [SELECT Id, Name,PersonEmail, MitId__pc, PersonDepartment, PersonTitle
            FROM Account   WHERE 
            	PersonEmail LIKE :('%' + searchParam + '%') and IsPersonAccount = true ];
        }
        else if(searchParam.isNumericSpace()){
            accounts =  [SELECT Id, Name,PersonEmail, MitId__pc, PersonDepartment, PersonTitle
            FROM Account   WHERE 
            MitId__pc LIKE :('%' + searchParam + '%') and IsPersonAccount = true ];
        }
        else {
             accounts = [
                SELECT Id, Name,PersonEmail, MitId__pc, PersonDepartment, PersonTitle
                FROM Account
                WHERE Name LIKE :('%' + searchParam + '%') and IsPersonAccount = true
            ];
        }

       

  return accounts;

    }

}