@IsTest
public with sharing class BipRequestTriggerHandlerTest {
    
    @TestSetup
    static void setup() {
       TestSetup.defaultConfiguration();
    }

    @IsTest
    public static void testOnBipRequestInsert() {

        BIP_Request__c bipRequest = new BIP_Request__c(
            Proposal_Number__c = '1234',
            Request_Type__c = 'Standard',
            Due_Date__c = Date.Today(),
            Project_Description__c = 'Test KC BIP Request',
            Comments__c = 'Test Comment'
        );
        String recordType = 'Non-KC Proposal';

        Test.startTest();
            String bipRequestId = NewBipRequestController.createBIPReq(bipRequest, recordType);
        Test.stopTest();

        BIP_Request__c createdBipRequest = [SELECT Id, RecordTypeId, 
                                                TLO_Officer_Email__c, TLO_Officer_MIT_ID__c, TLO_Officer_Name__c
                                            FROM BIP_Request__c WHERE Id = :bipRequestId LIMIT 1];

        String nonKCProposalTypeId = Schema.SObjectType.BIP_Request__c.getRecordTypeInfosByName().get('Non-KC Proposal').getRecordTypeId();
        System.assertEquals(nonKCProposalTypeId, createdBipRequest.RecordTypeId, 'Record Type ID should match the Non-KC Proposal Record Type');
    }
}