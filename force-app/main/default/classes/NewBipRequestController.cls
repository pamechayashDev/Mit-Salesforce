/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : 
**/
public with sharing class NewBipRequestController {
        
    @AuraEnabled
    public static string createBIPReq(BIP_Request__c bipRequest, String recordType){
        try {
            system.debug('bip req ---'+bipRequest.Primary_PI_Lookup__c);
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
            System.debug('----- '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}