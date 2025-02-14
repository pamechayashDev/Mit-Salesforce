public with sharing class UpdateBipPi {

   //TODO move to the BIPController rather 
   @AuraEnabled
   public static string UpdateBipPiRecords(List<Map<String,String>> records){
    try {
        List<Bip_Pi__c> bipis = new List<BIP_Pi__c>();
         
       for(Map<String,String> record:records){
        Bip_Pi__c bip_pi= [Select Requested_Action__c, BIP_Request__r.Id, Comment__c from Bip_Pi__c where Id = :record.get('Id') limit 1];
        if(record.get('selectedActions')!=''){
            bip_pi.Requested_Action__c=record.get('selectedActions');
            system.debug('UpdateBipPi selectedActions updated');
            
        }
      

        if(record.get('comments')!=''){
            bip_pi.Comment__c=record.get('comments');
            system.debug('UpdateBipPi comments updated');
        }

        bip_pi.Status__c = 'Pending Feedback';
    
        bipis.add(bip_pi);
       }
       system.debug(JSON.serializePretty(records));
       update bipis;
       BIP_Request__c vRequest = new Bip_Request__c(id=bipis[0].BIP_Request__r.id, Status__c='Assigned to PI');
       update vRequest;  


        return 'success';


    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
   }
}