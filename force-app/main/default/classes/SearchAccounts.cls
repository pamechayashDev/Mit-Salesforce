public with sharing class SearchAccounts {
    
    @AuraEnabled
    public static Map<String,Map<String,Object>> search(String searchParam){
        try {
            
            //     Map<String,Object> result1 =  new Map<String,Object>();
            //Map<String,Object> result2 =  new Map<String,Object>();
            Map<String,Map<String,Object>> finalMap = new Map<String,Map<String,Object>>();
            
            List<Account> accountsFromGetPerson = BIPUtils.getPerson(searchParam);
            
            
            
            system.debug('accountsFromGetPerson'+JSON.serializePretty(accountsFromGetPerson));
            String responseString = JSON.serialize(BIPUtils.peopleSearch(searchParam));
            //  String responseString='';
            system.debug('responseString-'+responseString);
            system.debug('responseString-'+json.serializePretty(responseString));
            if(responseString!='null' && responseString!=''){
                system.debug('inside');
                Map<String,Object> accountsFromPeopleSearch = (Map<String,Object>) JSON.deserializeUntyped(
                    responseString
                );
                
                
                
                List<Object> people = (List<Object>) accountsFromPeopleSearch.get('people');
                 system.debug('Peoples --- '+JSON.serializePretty(people));
                for (Object person : people) {
                    Map<String,Object> result2 =  new Map<String,Object>();
                    Map<String,Object> p = (Map<String,Object>) person;
                    result2.put('Name',p.get('legalFirstName')+' '+p.get('legalLastName'));
                    
                    result2.put('Id','');
                    result2.put('MitId',p.get('mitId'));
                    result2.put('from','PeopleSearch');
                    result2.put('apiResponse',p);
                  
          
                    result2.put('personEmail', p.get('mitEmail'));
                    result2.put('personDepartment', null);
                    result2.put('personTitle', p.get('jobTitle'));
                    finalMap.put((String) p.get('mitId'),result2);
                }
            }
            
            system.debug('from person ---'+finalMap);
            
            for(Account acc : accountsFromGetPerson){
                Map<String,Object> result1 =  new Map<String,Object>();
                result1.put('Name',acc.Name);
                result1.put('Id',acc.Id);
                if(acc.MitId__pc!=null){
                    result1.put('MitId', acc.MitId__pc);
                }
                else{
                    result1.put('MitId','');
                }
                
                result1.put('from','GetPerson');
                result1.put('personEmail', acc.PersonEmail);
                result1.put('personDepartment', acc.PersonDepartment);
                result1.put('personTitle', acc.PersonTitle);
                system.debug(result1);
                finalMap.put(acc.MitId__pc,result1);
                
            }
            // system.debug('accountsFromPeopleSearch) '+accountsFromPeopleSearch.get('people'));
            
            return finalMap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}