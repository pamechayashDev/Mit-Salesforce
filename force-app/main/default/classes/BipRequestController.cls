public with sharing class BipRequestController {
    @AuraEnabled
    public static string createBIPReq(BIP_Request__c bipRequest, String recordType){
        try {
            String kcProposalTypeId = Schema.SObjectType.BIP_Request__c.getRecordTypeInfosByName().get('KC Proposal').getRecordTypeId();
            String nonKCProposalTypeId = Schema.SObjectType.BIP_Request__c.getRecordTypeInfosByName().get('Non-KC Proposal').getRecordTypeId();
            if (recordType == 'KC Proposal') {
                bipRequest.RecordTypeId = kcProposalTypeId;
            }else{
                bipRequest.RecordTypeId = nonKCProposalTypeId;
            }
            insert bipRequest;
            return bipRequest.Id;   
        } catch (Exception e) {
            System.debug('----- '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String uploadFileInBipRequest(String base64, String filename, String result) {
        system.debug('upload file');
        
          ContentVersion cv = createContentVersion(base64, filename);
          ContentDocumentLink cdl = createContentLink(cv.Id, result);
          if (cv == null || cdl == null) { return null; }
          return cdl.Id;
    }

    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.Document_Classification__c = 'Original_Document';
        cv.PathOnClient = filename;
        try {
          insert cv;
          return cv;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
      }

    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
    insert cdl;
    return cdl;
    } catch(DMLException e) {
        System.debug(e);
        return null;
    }
    }

    @AuraEnabled
    public static Map<String,Object> getKualiResponseByProposalId(String proposalId){
        
      String jsonString =  json.serialize(BIPUtils.getKualiDataByProposalId(proposalId));
       Map<String,Object>  mappedResponse = (Map<String,Object>) JSON.deserializeUntyped(jsonString);
      return mappedResponse;
    }

    @AuraEnabled
    public static string createBipPis(List<Map<String,String>> bipPis,Id bipReqId,Map<String,String> accountData){
     try {
         List<Bip_Pi__c> bipPiList = new List<Bip_Pi__c>();
         for(Map<String,String> bipMap:bipPis){
             Bip_Pi__c bipPi=new Bip_Pi__c();
             if(bipMap.containsKey('personRole')){
                if('PI'==bipMap.get('personRole')){
                    bipPi.Role__c='Primary PI';
                } else {
                    bipPi.Role__c='Additional PI'; 
                }
            }
     
            String accId= accountData.get(bipMap.get('mitId'));

             bipPi.PI__c=accId;
             bipPI.Status__c='Pending Assignment';
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

    @AuraEnabled
    public static Map<String,Map<String,Object>> searchAccounts(String searchParam){
        try {
            
            Map<String,Map<String,Object>> accountInfoMap = new Map<String,Map<String,Object>>();
            
            List<Account> accountsFromGetPerson = BIPUtils.getPerson(searchParam);

            String responseString = JSON.serialize(BIPUtils.peopleSearch(searchParam));
            if(responseString!='null' && responseString!=''){
                Map<String,Object> accountsFromPeopleSearch = (Map<String,Object>) JSON.deserializeUntyped(
                    responseString
                );
                
                
                
                List<Object> people = (List<Object>) accountsFromPeopleSearch.get('people');
                 system.debug('Peoples :'+JSON.serializePretty(people));
                for (Object person : people) {
                    Map<String,Object> p = (Map<String,Object>) person;
                             Map<String,Object> result2 =  new Map<String,Object>{
                             'Name'=> p.get('legalFirstName')+' '+p.get('legalLastName'),
                             'Id'=>'',
                             'MitId'=> p.get('mitId'),
                             'apiResponse' => p,
                             'personEmail' => p.get('mitEmail'),
                             'personDepartment' => null,
                             'personTitle' => p.get('jobTitle')
                             };
                
                    accountInfoMap.put((String) p.get('mitId'),result2);
                }
            } 
            for(Account acc : accountsFromGetPerson){
                Map<String,Object> result1 =  new Map<String,Object>{
                'Name'=>acc.Name,
                'Id'=>acc.Id,
                'from'=>'GetPerson',
                'personEmail'=> acc.PersonEmail,
                'personDepartment'=> acc.PersonDepartment,
                'personTitle' => acc.PersonTitle
                };
             
                if(acc.MitId__pc!=null){
                    result1.put('MitId', acc.MitId__pc);
                }
                else{
                    result1.put('MitId','');
                }
                
                system.debug(result1);
                accountInfoMap.put(acc.MitId__pc,result1);
                
            }
            
            return accountInfoMap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<Integer,List<Object>> getResponseForAccountCreations(List<Map<String,String>> bipPis){
        try {
            system.debug('bipPis--'+bipPis);
            integer i=0;
            Map<Integer,List<Object>> resultMap =new Map<Integer,List<Object>>();
          
            for(Map<String,String> mapping : bipPis){
                
                if(mapping.containsKey('mitId')){
                   
                    Bip_Pi__c bipPi = new Bip_Pi__c();
                       
                    String mitId  = mapping.get('mitId');
                    system.debug('peopleSearch '+JSON.serializePretty(BipUtils.peopleSearch(mitId)));
                    String  data = JSON.serialize(BIPUtils.peopleSearch(mitId));
                   if(data!='null'){
                    Map<String,Object> resultList = (Map<String,Object>) JSON.deserializeUntyped(data);
        
                    system.debug('ppl'+resultList.get('people'));
               
                    resultMap.put(i,new List<Object>{resultList.get('people'),mitId});
                }
           
               
               } 
              i=i+1;
            }
            system.debug('resultMap -'+resultMap);
            return  resultMap; 
        }
        catch (Exception e) {
            system.debug('Exception =' + e);
            throw new AuraHandledException(e.getMessage());
        }
    }



}