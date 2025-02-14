public with sharing class GetKualiResponse {
    public GetKualiResponse() { }
     @AuraEnabled
     public static Map<String,Object> getResponse(String proposalId){
         
       String jsonString =  json.serialize(BIPUtils.getKualDataByProposalId(proposalId));
        Map<String,Object>  Res = (Map<String,Object>) JSON.deserializeUntyped(jsonString);
       return Res;
     }

}