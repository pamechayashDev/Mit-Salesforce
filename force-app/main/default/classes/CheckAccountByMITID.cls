public with sharing class CheckAccountByMITID {

   @AuraEnabled
   public static Map<String,Object> checkByMITID(String mitId) {
    system.debug('mitid'+mitId);
   
        List<Account> acc = [SELECT Id, Name, MitId__pc FROM Account WHERE MitId__pc = :mitId LIMIT 1];
        Map<String,Object> result =  new Map<String,Object>();

        if(acc.size()!=0){
            result.put('Status','Account Found');
            result.put('Account',acc);
            result.put('responseToCreateAccount','');
        }
        else{
         
             result.put('Status ','Account Not Found');
              system.debug('res+'+BIPUtils.peopleSearch(mitId));
           
              
          if(BIPUtils.peopleSearch(mitId)!=null){
            String  data = JSON.serialize(BIPUtils.peopleSearch(mitId));
            Map<String,Object> resultList = (Map<String,Object>) JSON.deserializeUntyped(data);
            system.debug('ppl'+resultList.get('people'));
            result.put('responseToCreateAccount',resultList.get('people'));
            result.put('Account','');
          }
          else{
         
            result.put('responseToCreateAccount','NA');
            result.put('Account','');
          }
             
            

               
         
              
           
       
            
        }
        return result;
     }
} 
