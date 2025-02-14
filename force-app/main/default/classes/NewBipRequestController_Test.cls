/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : 
**/

@isTest
public with sharing class NewBipRequestController_Test {
    
    @isTest
    public static void testCreateBIPReq_KCProposal() {
        BIP_Request__c bipRequest = new BIP_Request__c(
            Proposal_Number__c = '1234',
            Request_Type__c ='Standard',
            Due_Date__c = Date.Today(),
            Project_Description__c = 'Test KC BIP Request',
            Comments__c = 'Test Comment'
        );

        String recordType = 'KC Proposal';

        Test.startTest();
        String bipRequestId = NewBipRequestController.createBIPReq(bipRequest, recordType);
        Test.stopTest();

        BIP_Request__c createdBipRequest = [SELECT Id, RecordTypeId FROM BIP_Request__c WHERE Id = :bipRequestId LIMIT 1];

        String kcProposalTypeId = Schema.SObjectType.BIP_Request__c.getRecordTypeInfosByName().get('KC Proposal').getRecordTypeId();
        System.assertEquals(kcProposalTypeId, createdBipRequest.RecordTypeId, 'Record Type ID should match the KC Proposal Record Type');
    }

    @isTest
    public static void testCreateBIPReq_NonKCProposal() {
        BIP_Request__c bipRequest = new BIP_Request__c(
            Proposal_Number__c = '1234',
            Request_Type__c ='Standard',
            Due_Date__c = Date.Today(),
            Project_Description__c = 'Test KC BIP Request',
            Comments__c = 'Test Comment'
        );

        String recordType = 'Non-KC Proposal';

        Test.startTest();
        String bipRequestId = NewBipRequestController.createBIPReq(bipRequest, recordType);
        Test.stopTest();

        BIP_Request__c createdBipRequest = [SELECT Id, RecordTypeId FROM BIP_Request__c WHERE Id = :bipRequestId LIMIT 1];

        String nonKCProposalTypeId = Schema.SObjectType.BIP_Request__c.getRecordTypeInfosByName().get('Non-KC Proposal').getRecordTypeId();
        System.assertEquals(nonKCProposalTypeId, createdBipRequest.RecordTypeId, 'Record Type ID should match the Non-KC Proposal Record Type');
    }
   
}