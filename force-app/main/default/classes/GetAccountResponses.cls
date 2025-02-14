public with sharing class GetAccountResponses {
    @AuraEnabled
    public static Map<Integer,List<Object>> getResponseForAccountCreations(List<Map<String,String>> bipPis){
        try {
            system.debug('inside getResponseForAccountCreations');
            integer i=0;
            Map<Integer,List<Object>> resultMap =new   Map<Integer,List<Object>>();
          
            for(Map<String,String> mapping:bipPis){
                Bip_Pi__c bipPi = new Bip_Pi__c();
                String mitId  = mapping.get('mitId');
                system.debug('peopleSearch '+JSON.serializePretty(BipUtils.peopleSearch(mitId)));
                String  data = JSON.serialize(BIPUtils.peopleSearch(mitId));
               if(data!='null'){
                Map<String,Object> resultList = (Map<String,Object>) JSON.deserializeUntyped(data);
    
                system.debug('ppl'+resultList.get('people'));
                resultMap.put(i,new List<Object>{resultList.get('people'),mitId});
               }
              
    
                 
              
            
             
                i=i+1;
    
            }
            return  resultMap; 
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}