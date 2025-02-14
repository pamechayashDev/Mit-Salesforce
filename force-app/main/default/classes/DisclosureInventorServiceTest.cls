/**
 * Created by Andreas du Preez on 2024/08/06.
 */

@IsTest
public with sharing class DisclosureInventorServiceTest {

    @IsTest
    public static void returnsDisclosureInventorsWithUpdatedIPIALookup() {
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>{
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345123' )),
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345456' ))
        };
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{
                new IPIA_Record__c(MitId__c = '912345123' , FormName__c = 'TestForm1', SignDatetime__c = Date.today().addDays(-2)),
                new IPIA_Record__c(MitId__c = '912345123' , FormName__c = 'TestForm2', SignDatetime__c = Date.today().addDays(-1)),
                new IPIA_Record__c(MitId__c = '912345456' , FormName__c = 'TestForm3', SignDatetime__c = Date.today().addDays(-3)),
                new IPIA_Record__c(MitId__c = '912345456' , FormName__c = 'TestForm4', SignDatetime__c = Date.today())
        };
        insert ipiaRecords;

        Test.startTest();
        List<DisclosureInventor__c> updatedInventors = DisclosureInventorService.linkDisclosureInventorToIPIARecords(disclosureInventors);
        Test.stopTest();

        Assert.areEqual(ipiaRecords[1].Id, updatedInventors[0].IPIA_Record__c, 'First inventor should be linked to the latest IPIA record');
        Assert.areEqual(ipiaRecords[3].Id, updatedInventors[1].IPIA_Record__c, 'Second inventor should be linked to the latest IPIA record');
    }

    @IsTest
    public static void returnsDisclosureInventorsWithNoIPIALookupWhenNoMatchingIPIARecords() {
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>{
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345120' )),
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345450' ))
        };
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{
                new IPIA_Record__c(MitId__c = '912345123' , FormName__c = 'TestForm1', SignDatetime__c = Date.today().addDays(-2)),
                new IPIA_Record__c(MitId__c = '912345456' , FormName__c = 'TestForm2', SignDatetime__c = Date.today().addDays(-1))
        };
        insert ipiaRecords;

        Test.startTest();
        List<DisclosureInventor__c> updatedInventors = DisclosureInventorService.linkDisclosureInventorToIPIARecords(disclosureInventors);
        Test.stopTest();

        Assert.isNull(updatedInventors[0].IPIA_Record__c, 'First inventor should not be linked to any IPIA record');
        Assert.isNull(updatedInventors[1].IPIA_Record__c, 'Second inventor should not be linked to any IPIA record');
    }

    @IsTest
    public static void handlesEmptyDisclosureInventorsList() {
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>();
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{
                new IPIA_Record__c(MitId__c = '912345123' , FormName__c= 'TestForm1', SignDatetime__c = Date.today().addDays(-2)),
                new IPIA_Record__c(MitId__c = '912345123' , FormName__c= 'TestForm2', SignDatetime__c = Date.today().addDays(-1))
        };
        insert ipiaRecords;

        Test.startTest();
        List<DisclosureInventor__c> updatedInventors = DisclosureInventorService.linkDisclosureInventorToIPIARecords(disclosureInventors);
        Test.stopTest();

        Assert.areEqual(0, updatedInventors.size(), 'No inventors should be updated');
    }

    @IsTest
    public static void handlesEmptyIPIARecordsList() {
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>{
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345123' )),
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345456' ))
        };

        Test.startTest();
        List<DisclosureInventor__c> updatedInventors = DisclosureInventorService.linkDisclosureInventorToIPIARecords(disclosureInventors);
        Test.stopTest();

        Assert.isNull(updatedInventors[0].IPIA_Record__c, 'First inventor should not be linked to any IPIA record');
        Assert.isNull(updatedInventors[1].IPIA_Record__c, 'Second inventor should not be linked to any IPIA record');
    }

    @IsTest
    public static void returnsProcessDisclosureInventorsWithUpdatedIPIALookup() {
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>{
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345123' )),
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345456' ))
        };
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{
                new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345123' , SignDatetime__c = Date.today().addDays(-2)),
                new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345123' , SignDatetime__c = Date.today().addDays(-1)),
                new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345456' , SignDatetime__c = Date.today().addDays(-3)),
                new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345456' , SignDatetime__c = Date.today())
        };

        List<DisclosureInventor__c> updatedInventors = DisclosureInventorService.processIPIARecordToDisclosureInventorLink(disclosureInventors, ipiaRecords);

        Assert.areEqual(ipiaRecords[1].Id, updatedInventors[0].IPIA_Record__c, 'First inventor should be linked to the latest IPIA record');
        Assert.areEqual(ipiaRecords[3].Id, updatedInventors[1].IPIA_Record__c, 'Second inventor should be linked to the latest IPIA record');
    }

    @IsTest
    public static void returnsProcessDisclosureInventorsWithNoIPIALookupWhenNoMatchingIPIARecords() {
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>{
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345123' )),
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345456' ))
        };
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{
                new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345789' , SignDatetime__c = Date.today().addDays(-2)),
                new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345789' , SignDatetime__c = Date.today().addDays(-1))
        };

        List<DisclosureInventor__c> updatedInventors = DisclosureInventorService.processIPIARecordToDisclosureInventorLink(disclosureInventors, ipiaRecords);

        Assert.isNull(updatedInventors[0].IPIA_Record__c, 'First inventor should not be linked to any IPIA record');
        Assert.isNull(updatedInventors[1].IPIA_Record__c, 'Second inventor should not be linked to any IPIA record');
    }

    @IsTest
    public static void handlesProcessEmptyDisclosureInventorsList() {
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>();
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{
                new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345123' , SignDatetime__c = Date.today().addDays(-2)),
                new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345123' , SignDatetime__c = Date.today().addDays(-1))
        };

        List<DisclosureInventor__c> updatedInventors = DisclosureInventorService.processIPIARecordToDisclosureInventorLink(disclosureInventors, ipiaRecords);

        Assert.areEqual(0, updatedInventors.size(), 'No inventors should be updated');
    }

    @IsTest
    public static void handlesProcessEmptyIPIARecordsList() {
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>{
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345123' )),
                new DisclosureInventor__c(Contact__r = new Account(MitId__pc = '912345456' ))
        };
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>();

        List<DisclosureInventor__c> updatedInventors = DisclosureInventorService.processIPIARecordToDisclosureInventorLink(disclosureInventors, ipiaRecords);

        Assert.isNull(updatedInventors[0].IPIA_Record__c, 'First inventor should not be linked to any IPIA record');
        Assert.isNull(updatedInventors[1].IPIA_Record__c, 'Second inventor should not be linked to any IPIA record');
    }
}