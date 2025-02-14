public with sharing class CreateBipPisforBipRequest {
@AuraEnabled
 public static string createBipPisforRequest(List<Map<String,String>> bipPis,Id bipReqId,Map<String,String> accountData){
    try {
        List<Bip_Pi__c> bipPiList = new List<Bip_Pi__c>();
        system.debug('bipPis--++'+JSON.serializePretty(bipPis));
        for(Map<String,String> bipMap:bipPis){
            Bip_Pi__c bipPi=new Bip_Pi__c();
            if(bipMap.containsKey('personRole')){
                if(bipMap.get('personRole')=='PI'){
                    bipPi.Role__c='Primary PI';
                } else{
                    bipPi.Role__c='Additional PI';
                }
            }

           String accId= accountData.get(bipMap.get('mitId'));

            

            bipPi.PI__c=accId;
            bipPi.BIP_Request__c=bipReqId;
            bipPiList.add(bipPi);
        }
        insert bipPiList;
      system.debug('class--'+JSON.serializePretty(bipPiList));
       return 'success';
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
 }


 
}