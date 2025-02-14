public without sharing class CreateAdditionalBip {
   @AuraEnabled
   public static string createAdditionalBips(List<Map<String,String>> bipPis,Id bipReqId,Map<String,String> accountData){
    try {
        system.debug('createAdditionalBips');
        List<Bip_Pi__c> bipPiList = new List<Bip_Pi__c>();
        for(Map<String,String> bipMap:bipPis){
            Bip_Pi__c bipPi=new Bip_Pi__c();
            if(bipMap.containsKey('personRole')){
                bipPi.Role__c=bipMap.get('personRole');
            }
            else{
                bipPi.Role__c='Additional PI'; 
            }
    
           String accId= accountData.get(bipMap.get('mitId'));
           
           system.debug('accId--'+accId);
            bipPi.PI__c=accId;
            bipPi.BIP_Request__c=bipReqId;
            bipPiList.add(bipPi);
        }
       
      
        insert bipPiList;
        system.debug('recooInserted '+bipPiList);
        return 'Success';


        
    } catch (Exception e) {
 
        throw new AuraHandledException(e.getMessage());
    }
   }
}