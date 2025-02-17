/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : 
**/
public with sharing class getChildBips {
   @AuraEnabled
   public static Map<String,Object> getChildBipsData(Id recId){
      try {

         BIP_Request__c parentBip =  [SELECT Id, Status__c, Primary_PI_Lookup__r.Id, Owner.Name, Primary_PI_Lookup__r.Name,
                                             TLO_Officer_Name__c,
                                       (SELECT Id, Status__c, Role__c, TLO_Officer_Name__c, 
                                               CreatedBy.Name , PI__r.Id , PI__r.Name 
                                          FROM BIP_PIs__r) 
                                      FROM BIP_Request__c 
                                      WHERE Id = :recId LIMIT 1];

         List<BIP_PI__c> childBips = parentBip.BIP_PIs__r;
         Map<String,Object> result = new Map<String,Object> {
            'childs'=>childBips,
            'primaryPiParent'=> new Map<String,String>{
            'Id'=>parentBip.Id,
            'PrimaryPIId'=>parentBip.Primary_PI_Lookup__r.Id,
            'PrimaryPIName'=>parentBip.Primary_PI_Lookup__r.Name,
            'TLO'=> parentBip.TLO_Officer_Name__c,
            'Status'=> parentBip.Status__c
            }
         };

         return result;
      } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
      }
   }
}