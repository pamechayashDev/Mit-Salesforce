public with sharing class CreateAccount {
        @AuraEnabled
        public static List<String> saveAccount(List<String> mitIdList,List<String> accNames){
            try {
                 
                system.debug('mitId++++++++++'+mitIdList);
                system.debug(accNames);
                integer i=0;
               List<String> results = new List<String>();
             for(String mitId:mitIdList){
                boolean found=false;
                if(mitId!=''){
                    List<Account> accList = [Select LastName, Id , IsPersonAccount from Account where MitId__pc = :mitId  and IsPersonAccount=true];
                    if(!accList.isEmpty()){
                        system.debug('innn');
                        system.debug(accList);
                        system.debug(accList[0].IsPersonAccount);
                        system.debug(accList[0].Id);
                       results.add(accList[0].Id);
                       found=true;
                    }
                }
                else{
                    List<Account> accList = [Select LastName, Id , IsPersonAccount from Account where LastName = :accNames[i]  and IsPersonAccount=true];
                    if(!accList.isEmpty()){
                        system.debug('innn');
                        system.debug(accList);
                        system.debug(accList[0].IsPersonAccount);
                        system.debug(accList[0].Id);
                        results.add(accList[0].Id);
                        found=true;
                    }
                }
                
              
               
     if(!found){
        Account personAccount;
        system.debug('accNames[i]--'+accNames[i]);
        if(mitId==null || mitId==''){
           personAccount = new Account(
              LastName = accNames[i],
              RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id
          );
        }
        else{
           personAccount = new Account(
              LastName = accNames[i],
              RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id,
              MitId__pc = mitId
          );
        }
                 
  
          insert personAccount;
  
          system.debug(personAccount.Id);
        
          results.add(personAccount.Id);
     }
     i=i+1;        
    }
    return results;
 
     
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
}