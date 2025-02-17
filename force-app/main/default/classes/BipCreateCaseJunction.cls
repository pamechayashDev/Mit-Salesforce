public class BipCreateCaseJunction {  
    @AuraEnabled
    public static string queryCases(String recId) {
        System.debug('inside Queuable');
         
        Bip_Request__c bipReq = [Select Id , (Select Id , BIP_Request__c, PI_MIT_ID__c,PI__c from Bip_Pis__r) from Bip_Request__c where Id = :recId LIMIT 1];
            List<BIP_PI__c> vBIPPIList = bipReq.Bip_Pis__r;
        
        Map<String,BIP_PI__c> vBIPPIMap = new Map<String,BIP_PI__c>();

        List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x> recordList = new List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x>();
        Map<String,Forrester_Case__x> caseMap = new Map<String,Forrester_Case__x>();
        
        
            for(BIP_PI__c vBIPPI :  vBIPPIList ){
                vBIPPIMap.put(vBIPPI.PI_MIT_ID__c, vBIPPI);
            }
            
            List<String> caseRecIds = new List<String>();         
            recordList = [SELECT CASE_INVENTOR_RECID__c, CASE_RECID__c,INVENTOR_NAME__c,INVENTOR_RECID__c,MIT_ID__c 
                          FROM Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x 
                          WHERE MIT_ID__c= :vBIPPIMap.keySet() 
                          AND INVENTOR_ASSOCIATION_TYPE__c NOT IN ('Non-Inventor', 'Non-Inv-Removed') 
                          AND CASE_STATUS__c NOT IN ('Closed', 'Dormant', 'Archive')];
            
            for(Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x rec:recordList){
                caseRecIds.add(rec.CASE_RECID__c);
            }  
        
            Integer batchSize = 50;
            List<Forrester_Case__x> caseList = ExternalObjectQuery.records(
                ExternalObjectRepository.fetchSObjectsByExternalRecIds(caseRecIds, 
                    'Forrester_Case__x', 
                    'CASE_RECID__c', 
                    new List<String> {'DISCLOSURE_TITLE__c', 'STATUS__c', 'CASE_RECID__c', 'ADD_DATE__c', 'FIRST_PUBLISH_DATE__c', 'TLO_MIT_ID__c',
                                    'TLO_NAME__c', 'TLO_EMAIL__c', 'TLO_ID__c', 'CASE_TYPE__c', 'CONTRACT_CASE_NUM__c'}, 
                    batchSize)
            );

            for(Forrester_Case__x vCase : caseList){
                caseMap.put(vCase.CASE_RECID__c,vCase);
            }
            
           if (Test.isRunningTest()) {
            // Simulate query results during test execution
            recordList = new List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x>();
            recordList.add(new Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x(CASE_INVENTOR_RECID__c = '39782', CASE_RECID__c = '12345',INVENTOR_NAME__c='Steven R. H Barrett', INVENTOR_RECID__c=12904 ,MIT_ID__c='995864713'));
            system.debug('rec===='+recordList);            
            for(Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x rec:recordList){
                caseRecIds.add(rec.CASE_RECID__c);
              
            }
            system.debug('caseRecIds===='+caseRecIds);
           
            Forrester_Case__x caseInstance = new Forrester_Case__x(DISCLOSURE_TITLE__c='Test',STATUS__c='Active',ADD_DATE__c= date.today(),CASE_RECID__c='12345',FIRST_PUBLISH_DATE__c= date.today().addDays(-1),CASE_TYPE__c='Copyright' );
              
        
            caseMap.put(caseInstance.CASE_RECID__c,caseInstance);
             system.debug('caseMap===='+caseMap);
            
        }
        
        
        
        
      List<BIP_Case_Junction__c> tloCaseList = new List<BIP_Case_Junction__c>();
         system.debug('tloCaseList');
        for(Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x rec:recordList){
            BIP_Case_Junction__c vCaseJunction = new BIP_Case_Junction__c(); 
            if(vBIPPIMap.containsKey(rec.MIT_ID__c)){
                     vCaseJunction.BIP_PI__c = vBIPPIMap.get(rec.MIT_ID__c).Id;
                     vCaseJunction.BIP_Request__c = vBIPPIMap.get(rec.MIT_ID__c).BIP_Request__c;
            }
      
            vCaseJunction.Case__c = rec.CASE_RECID__c;

            tloCaseList.add(vCaseJunction);
        }
        
  
         insert tloCaseList;
        system.debug('tloCaseList '+tloCaseList);
          return 'success';
     



   }
    
    
}