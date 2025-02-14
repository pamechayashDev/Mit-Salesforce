/**
 * Created by Andreas du Preez on 2025/02/07.
 */

@IsTest
public with sharing class BIPControllerTest {
    // Mock class for Forrester_Case__x
    class CaseMock extends ExternalObjectQuery {
        final List<Forrester_Case__x> externalRecords;

        CaseMock(List<Forrester_Case__x> externalRecords) {
            this.externalRecords = externalRecords;
        }

        protected override List<SObject> passThrough(List<SObject> records) {
            return externalRecords;
        }
    }

    @TestSetup
    public static void testSetup() {
        // Insert Mock Data
        // Mock BIP_Request__c record
        BIP_Request__c bipRequest = new BIP_Request__c();
        bipRequest.Status__c = 'Request Received';
        bipRequest.Project_Description__c = 'UNIQUE_TEST_COMMENT1';

        insert bipRequest;

        // Mock BIP_PI__c record
        List<BIP_PI__c> bipPis = new List<BIP_PI__c>();
        BIP_PI__c bipPi1 = new BIP_PI__c();
        bipPi1.Role__c = 'Primary PI';
        bipPi1.Status__c = 'Pending Assignment';
        bipPi1.BIP_Request__c = bipRequest.Id;
        bipPis.add(bipPi1);

        BIP_PI__c bipPi2 = new BIP_PI__c();
        bipPi2.Role__c = 'Additional PI';
        bipPi2.Status__c = 'Pending Assignment';
        bipPi2.BIP_Request__c = bipRequest.Id;
        bipPis.add(bipPi2);

        insert bipPis;

        // Mock BIP_Case_Junction__c records
        List<BIP_Case_Junction__c> bipCaseJunctions = new List<BIP_Case_Junction__c>();
        BIP_Case_Junction__c bipCaseJunction = new BIP_Case_Junction__c();
        bipCaseJunction.BIP_PI__c = bipPi1.Id;
        bipCaseJunction.Case__c = 'testRecId1';
        bipCaseJunctions.add(bipCaseJunction);

        BIP_Case_Junction__c bipCaseJunction2 = new BIP_Case_Junction__c();
        bipCaseJunction2.BIP_PI__c = bipPi1.Id;
        bipCaseJunction2.Case__c = 'testRecId2';
        bipCaseJunctions.add(bipCaseJunction2);

        BIP_Case_Junction__c bipCaseJunction3 = new BIP_Case_Junction__c();
        bipCaseJunction3.BIP_PI__c = bipPi1.Id;
        bipCaseJunction3.Case__c = 'testRecId3';
        bipCaseJunctions.add(bipCaseJunction3);

        BIP_Case_Junction__c bipCaseJunction4 = new BIP_Case_Junction__c();
        bipCaseJunction4.BIP_PI__c = bipPi2.Id;
        bipCaseJunction4.Case__c = 'testRecId4';
        bipCaseJunctions.add(bipCaseJunction4);

        insert bipCaseJunctions;
    }

    private static void setExternalMockData(){
        // Mock Forrester_Case__x records
        List<Forrester_Case__x> mockRecords = new List<Forrester_Case__x>();
        Forrester_Case__x mockRecord1 = new Forrester_Case__x();
        mockRecord1.CASE_RECID__c = 'testRecId1';
        mockRecord1.TLO_NAME__c = 'Test TLO Name 1';
        mockRecord1.TLO_MIT_ID__c = '123';
        mockRecord1.TLO_EMAIL__c = 'test1@email.com';
        mockRecords.add(mockRecord1);

        Forrester_Case__x mockRecord2 = new Forrester_Case__x();
        mockRecord2.CASE_RECID__c = 'testRecId2';
        mockRecord2.TLO_NAME__c = 'Test TLO Name 1';
        mockRecord2.TLO_MIT_ID__c = '123';
        mockRecord2.TLO_EMAIL__c = 'test1@email.com';
        mockRecords.add(mockRecord2);

        Forrester_Case__x mockRecord3 = new Forrester_Case__x();
        mockRecord3.CASE_RECID__c = 'testRecId3';
        mockRecord3.TLO_NAME__c = 'Test TLO Name 3';
        mockRecord3.TLO_MIT_ID__c = '789';
        mockRecord3.TLO_EMAIL__c = 'test3@email.com';
        mockRecords.add(mockRecord3);

        Forrester_Case__x mockRecord4 = new Forrester_Case__x();
        mockRecord4.CASE_RECID__c = 'testRecId4';
        mockRecord4.TLO_NAME__c = 'Test TLO Name 4';
        mockRecord4.TLO_MIT_ID__c = '147';
        mockRecord4.TLO_EMAIL__c = 'test4@email.com';
        mockRecords.add(mockRecord4);

        ExternalObjectQuery.setMock(new CaseMock(mockRecords));
    }

    @IsTest
    public static void testGetBipPisForTLOAssignment() {
        setExternalMockData();
        BIP_Request__c bipRequest = [SELECT Id FROM BIP_Request__c WHERE Project_Description__c = 'UNIQUE_TEST_COMMENT1' LIMIT 1];

        Test.startTest();
        List<BIPController.BIPPITLOAssignment> result = BIPController.getBipPisForTLOAssignment(bipRequest.Id);
        Test.stopTest();

        // Assert
        System.assertEquals(2, result.size());
        for (BIPController.BIPPITLOAssignment bipPiTloAssignment : result) {
            if (bipPiTloAssignment.bipPi.Role__c == 'Primary PI') {
                System.assertEquals(2, bipPiTloAssignment.availableTloOfficers.size());
                System.assertEquals('123', bipPiTloAssignment.recommendedTloOfficer.mitId);
                System.assertEquals('Test TLO Name 1', bipPiTloAssignment.recommendedTloOfficer.name);
            } else {
                System.assertEquals(1, bipPiTloAssignment.availableTloOfficers.size());
                System.assertEquals('147', bipPiTloAssignment.recommendedTloOfficer.mitId);
                System.assertEquals('Test TLO Name 4', bipPiTloAssignment.recommendedTloOfficer.name);
            }
        }
    }

    @IsTest
    public static void testUpdateBipPiTLOAssignment() {
        setExternalMockData();
        BIP_Request__c bipRequest = [SELECT Id FROM BIP_Request__c WHERE Project_Description__c = 'UNIQUE_TEST_COMMENT1' LIMIT 1];
        List<BIPController.BIPPITLOAssignment> result = BIPController.getBipPisForTLOAssignment(bipRequest.Id);

        List<BIP_PI__c> bipPisToUpdate = new List<BIP_PI__c>();
        for (BIPController.BIPPITLOAssignment bipPiTloAssignment : result) {
            bipPiTloAssignment.bipPi.TLO_Officer_MIT_ID__c = bipPiTloAssignment.recommendedTloOfficer.mitId;
            bipPiTloAssignment.bipPi.TLO_Officer_Name__c = bipPiTloAssignment.recommendedTloOfficer.name;
            bipPiTloAssignment.bipPi.TLO_Officer_Email__c = bipPiTloAssignment.recommendedTloOfficer.email;
            bipPisToUpdate.add(bipPiTloAssignment.bipPi);
        }

        Test.startTest();
        Boolean isUpdated = BIPController.updateBipPiTLOAssignment(bipPisToUpdate);
        Test.stopTest();

        List<BIP_PI__c> updatedBipPis = [SELECT Id, TLO_Officer_MIT_ID__c, TLO_Officer_Name__c, TLO_Officer_Email__c, Role__c FROM BIP_PI__c WHERE Id IN :bipPisToUpdate];
        BIP_Request__c updatedBipRequest = [SELECT Id, Status__c FROM BIP_Request__c WHERE Project_Description__c = 'UNIQUE_TEST_COMMENT1' LIMIT 1];

        System.assertEquals(true, isUpdated);
        System.assertEquals(2, updatedBipPis.size());
        System.assertEquals('Assigned to TLO', updatedBipRequest.Status__c);
        for (BIP_PI__c updatedBipPi : updatedBipPis) {
            if (updatedBipPi.Role__c == 'Primary PI') {
                System.assertEquals('123', updatedBipPi.TLO_Officer_MIT_ID__c);
                System.assertEquals('Test TLO Name 1', updatedBipPi.TLO_Officer_Name__c);
                System.assertEquals('test1@email.com', updatedBipPi.TLO_Officer_Email__c);
            } else {
                System.assertEquals('147', updatedBipPi.TLO_Officer_MIT_ID__c);
                System.assertEquals('Test TLO Name 4', updatedBipPi.TLO_Officer_Name__c);
                System.assertEquals('test4@email.com', updatedBipPi.TLO_Officer_Email__c);
            }
        }
    }
}