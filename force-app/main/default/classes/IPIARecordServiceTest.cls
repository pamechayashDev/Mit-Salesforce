/**
 * Created by Andreas du Preez on 2024/07/30.
 */

@IsTest
public with sharing class IPIARecordServiceTest {
     
    @TestSetup
    public static void testSetup() {
         TestSetup.defaultConfiguration();
    }


    // Test scenario where IPIA Types exist and IPIA Records are inserted
    @IsTest
    public static void StressTestIPIARecordInsert() {
        String IPIA_TYPE_NAME_1 = 'IPIA_TYPE_1';
        String IPIA_TYPE_TEMPLATE_ID_1 = 'a503d2b9-b29e-4b84-8b2a-6436bae3693a';
        String IPIA_TYPE_NAME_2 = 'IPIA_TYPE_2';
        String IPIA_TYPE_TEMPLATE_ID_2 = 'cfee5c68-33d1-475d-84aa-e3daf9c17884';
        String IPIA_TYPE_NAME_3 = 'IPIA_TYPE_3';
        String IPIA_TYPE_TEMPLATE_ID_3 = '48e3c89e-50d1-4265-85b7-24109d978953';
        String IPIA_TYPE_NAME_4 = 'IPIA_TYPE_4';
        String IPIA_TYPE_TEMPLATE_ID_4 = '7768ced8-9441-4f6a-bc75-6d32cf4244a1';
        Integer IPIA_LINKED_TO_TYPE_1 = 100;
        Integer IPIA_LINKED_TO_TYPE_2 = 100;
        Integer IPIA_LINKED_TO_TYPE_3 = 100;

        IPIA_Type__c type1 = new IPIA_Type__c(Name = IPIA_TYPE_NAME_1, Status__c = 'Active', DocusignTemplate__c = IPIA_TYPE_TEMPLATE_ID_1);
        IPIA_Type__c type2 = new IPIA_Type__c(Name = IPIA_TYPE_NAME_2, Status__c = 'Active', DocusignTemplate__c = IPIA_TYPE_TEMPLATE_ID_2);
        IPIA_Type__c type3 = new IPIA_Type__c(Name = IPIA_TYPE_NAME_3, Status__c = 'Active');
        IPIA_Type__c type4 = new IPIA_Type__c(Name = IPIA_TYPE_NAME_4, Status__c = 'Active', DocusignTemplate__c = IPIA_TYPE_TEMPLATE_ID_4);
        List<IPIA_Type__c> types = new List<IPIA_Type__c>{
                type1, type2, type3, type4
        };
        insert types;

        List<IPIA_Record__c> ipiaRecordsToInsert = new List<IPIA_Record__c>();

        Integer startingMitId = 912123654 - 400;
        for (Integer i = 1; i <= IPIA_LINKED_TO_TYPE_1; i++) {
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = (startingMitId + i).toString());
            ipiaRecord.FormName__c = IPIA_TYPE_NAME_1;
            ipiaRecord.SignDatetime__c = Date.today().addDays(-30);
            ipiaRecordsToInsert.add(ipiaRecord);
        }

        for (Integer i = 1; i <= IPIA_LINKED_TO_TYPE_2; i++) {
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = (startingMitId + i).toString());
            ipiaRecord.FormName__c = IPIA_TYPE_NAME_2;
            ipiaRecord.DocusignTemplate__c = IPIA_TYPE_TEMPLATE_ID_2;
            ipiaRecord.SignDatetime__c = Date.today().addDays(-30);
            ipiaRecordsToInsert.add(ipiaRecord);
        }

        for (Integer i = 1; i <= IPIA_LINKED_TO_TYPE_3; i++) {
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = (startingMitId + i).toString());
            ipiaRecord.FormName__c = IPIA_TYPE_NAME_3;
            ipiaRecord.SignDatetime__c = Date.today().addDays(-30);
            ipiaRecordsToInsert.add(ipiaRecord);
        }

        for (Integer i = 1; i <= 100; i++) {
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = (startingMitId + i).toString());
            ipiaRecord.FormName__c = 'Does not exist';
            ipiaRecord.DocusignTemplate__c = 'Does not exist';
            ipiaRecord.SignDatetime__c = Date.today().addDays(-30);
            ipiaRecordsToInsert.add(ipiaRecord);
        }

        Test.startTest();
        insert ipiaRecordsToInsert;
        Test.stopTest();

        Integer counterLinkToCreateFrom1 = [SELECT COUNT() FROM IPIA_Record__c WHERE IPIA_Type__c = :type1.Id];
        Integer counterLinkToCreateFrom2 = [SELECT COUNT() FROM IPIA_Record__c WHERE IPIA_Type__c = :type2.Id];
        Integer counterLinkToCreateFrom3 = [SELECT COUNT() FROM IPIA_Record__c WHERE IPIA_Type__c = :type3.Id];
        Integer counterLinkToCreateFrom4 = [SELECT COUNT() FROM IPIA_Record__c WHERE IPIA_Type__c = :type4.Id];

        // Test IPIATrigger and IPIARecordTriggerHandler
        Assert.areEqual(IPIA_LINKED_TO_TYPE_1, counterLinkToCreateFrom1, 'There should be ' + IPIA_LINKED_TO_TYPE_1 + ' IPIA Records linked to Type 1');
        Assert.areEqual(IPIA_LINKED_TO_TYPE_2, counterLinkToCreateFrom2, 'There should be ' + IPIA_LINKED_TO_TYPE_2 + ' IPIA Records linked to Type 2');
        Assert.areEqual(IPIA_LINKED_TO_TYPE_3, counterLinkToCreateFrom3, 'There should be ' + IPIA_LINKED_TO_TYPE_3 + ' IPIA Records linked to Type 3');
        Assert.areEqual(0, counterLinkToCreateFrom4, 'There should be 0 IPIA Records linked to Type 4');
    }

    // Test scenario where IPIA Records are inserted and IPIA Types are inserted after
    @IsTest
    public static void StressTestIPIATypeInsert() {
        String IPIA_TYPE_NAME_1 = 'IPIA_TYPE_1';
        String IPIA_TYPE_TEMPLATE_ID_1 = 'a503d2b9-b29e-4b84-8b2a-6436bae3693a';
        String IPIA_TYPE_NAME_2 = 'IPIA_TYPE_2';
        String IPIA_TYPE_TEMPLATE_ID_2 = 'cfee5c68-33d1-475d-84aa-e3daf9c17884';
        String IPIA_TYPE_NAME_3 = 'IPIA_TYPE_3';
        String IPIA_TYPE_TEMPLATE_ID_3 = '48e3c89e-50d1-4265-85b7-24109d978953';
        String IPIA_TYPE_NAME_4 = 'IPIA_TYPE_4';
        String IPIA_TYPE_TEMPLATE_ID_4 = '7768ced8-9441-4f6a-bc75-6d32cf4244a1';
        Integer IPIA_LINKED_TO_TYPE_1 = 100;
        Integer IPIA_LINKED_TO_TYPE_2 = 100;
        Integer IPIA_LINKED_TO_TYPE_3 = 100;

        List<IPIA_Record__c> ipiaRecordsToInsert = new List<IPIA_Record__c>();

        Integer startingMitId = 912123654 - 400;
        for (Integer i = 1; i <= IPIA_LINKED_TO_TYPE_1; i++) {
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = (startingMitId + i).toString());
            ipiaRecord.FormName__c = IPIA_TYPE_NAME_1;
            ipiaRecord.SignDatetime__c = Date.today().addDays(-30);
            ipiaRecordsToInsert.add(ipiaRecord);
        }

        for (Integer i = 1; i <= IPIA_LINKED_TO_TYPE_2; i++) {
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = (startingMitId + i).toString());
            ipiaRecord.FormName__c = IPIA_TYPE_NAME_2;
            ipiaRecord.DocusignTemplate__c = IPIA_TYPE_TEMPLATE_ID_2;
            ipiaRecord.SignDatetime__c = Date.today().addDays(-30);
            ipiaRecordsToInsert.add(ipiaRecord);
        }

        for (Integer i = 1; i <= IPIA_LINKED_TO_TYPE_3; i++) {
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = (startingMitId + i).toString());
            ipiaRecord.FormName__c = IPIA_TYPE_NAME_3;
            ipiaRecord.SignDatetime__c = Date.today().addDays(-30);
            ipiaRecordsToInsert.add(ipiaRecord);
        }

        for (Integer i = 1; i <= 100; i++) {
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = (startingMitId + i).toString());
            ipiaRecord.FormName__c = 'Does not exist';
            ipiaRecord.DocusignTemplate__c = 'Does not exist';
            ipiaRecord.SignDatetime__c = Date.today().addDays(-30);
            ipiaRecordsToInsert.add(ipiaRecord);
        }

        insert ipiaRecordsToInsert;

        IPIA_Type__c type1 = new IPIA_Type__c(Name = IPIA_TYPE_NAME_1, Status__c = 'Active', DocusignTemplate__c = IPIA_TYPE_TEMPLATE_ID_1);
        IPIA_Type__c type2 = new IPIA_Type__c(Name = IPIA_TYPE_NAME_2, Status__c = 'Active', DocusignTemplate__c = IPIA_TYPE_TEMPLATE_ID_2);
        IPIA_Type__c type3 = new IPIA_Type__c(Name = IPIA_TYPE_NAME_3, Status__c = 'Active');
        IPIA_Type__c type4 = new IPIA_Type__c(Name = IPIA_TYPE_NAME_4, Status__c = 'Active', DocusignTemplate__c = IPIA_TYPE_TEMPLATE_ID_4);
        List<IPIA_Type__c> types = new List<IPIA_Type__c>{
                type1, type2, type3, type4
        };

        Test.startTest();
        insert types;
        Test.stopTest();

        Integer counterLinkToCreateFrom1 = [SELECT COUNT() FROM IPIA_Record__c WHERE IPIA_Type__c = :type1.Id];
        Integer counterLinkToCreateFrom2 = [SELECT COUNT() FROM IPIA_Record__c WHERE IPIA_Type__c = :type2.Id];
        Integer counterLinkToCreateFrom3 = [SELECT COUNT() FROM IPIA_Record__c WHERE IPIA_Type__c = :type3.Id];
        Integer counterLinkToCreateFrom4 = [SELECT COUNT() FROM IPIA_Record__c WHERE IPIA_Type__c = :type4.Id];

        // Test IPIATrigger and IPIARecordTriggerHandler
        Assert.areEqual(IPIA_LINKED_TO_TYPE_1, counterLinkToCreateFrom1, 'There should be ' + IPIA_LINKED_TO_TYPE_1 + ' IPIA Records linked to Type 1');
        Assert.areEqual(IPIA_LINKED_TO_TYPE_2, counterLinkToCreateFrom2, 'There should be ' + IPIA_LINKED_TO_TYPE_2 + ' IPIA Records linked to Type 2');
        Assert.areEqual(IPIA_LINKED_TO_TYPE_3, counterLinkToCreateFrom3, 'There should be ' + IPIA_LINKED_TO_TYPE_3 + ' IPIA Records linked to Type 3');
        Assert.areEqual(0, counterLinkToCreateFrom4, 'There should be 0 IPIA Records linked to Type 4');
    }

    @IsTest
    public static void updateIPIARecordTypeLink_withTemplateId_FromIPIARecord() {
        IPIA_Record__c record1 = new IPIA_Record__c(FormName__c = 'Type1', DocusignTemplate__c = 'template1', MitId__c = '912345673');
        insert record1;

        IPIA_Type__c type1 = new IPIA_Type__c(Name = 'Type2', Status__c = 'Active', DocusignTemplate__c = 'template1');
        insert type1;

        IPIA_Record__c updatedRecord = [SELECT Id, FormName__c, IPIA_Type__c FROM IPIA_Record__c WHERE Id = :record1.Id];
        Assert.areEqual(type1.Id, updatedRecord.IPIA_Type__c);
        Assert.areEqual('Type2', updatedRecord.FormName__c);
    }

    @IsTest
    public static void updateIPIARecordTypeLink_withFormName_FromIPIARecord() {
        IPIA_Record__c record1 = new IPIA_Record__c(FormName__c = 'Type1', MitId__c = '912345673');
        insert record1;

        IPIA_Type__c type1 = new IPIA_Type__c(Name = 'Type1', Status__c = 'Active');
        insert type1;

        IPIA_Record__c updatedRecord = [SELECT Id, FormName__c, IPIA_Type__c FROM IPIA_Record__c WHERE Id = :record1.Id];
        Assert.areEqual(type1.Id, updatedRecord.IPIA_Type__c);
        Assert.areEqual('Type1', updatedRecord.FormName__c);
    }

    @IsTest
    public static void updateIPIARecordTypeLink_withTemplateId_FromIPIAType() {
        IPIA_Type__c type1 = new IPIA_Type__c(Name = 'Type2', Status__c = 'Active', DocusignTemplate__c = 'template1');
        insert type1;

        IPIA_Record__c record1 = new IPIA_Record__c(FormName__c = 'Type1', DocusignTemplate__c = 'template1', MitId__c = '912345673');
        insert record1;

        IPIA_Record__c updatedRecord = [SELECT Id, FormName__c, IPIA_Type__c FROM IPIA_Record__c WHERE Id = :record1.Id];
        Assert.areEqual(type1.Id, updatedRecord.IPIA_Type__c);
        Assert.areEqual('Type2', updatedRecord.FormName__c);
    }

    @IsTest
    public static void updateIPIARecordTypeLink_withFormName_FromIPIAType() {
        IPIA_Type__c type1 = new IPIA_Type__c(Name = 'Type1', Status__c = 'Active');
        insert type1;

        IPIA_Record__c record1 = new IPIA_Record__c(FormName__c = 'Type1', MitId__c = '912345673');
        insert record1;

        IPIA_Record__c updatedRecord = [SELECT Id, FormName__c, IPIA_Type__c FROM IPIA_Record__c WHERE Id = :record1.Id];
        Assert.areEqual(type1.Id, updatedRecord.IPIA_Type__c);
        Assert.areEqual('Type1', updatedRecord.FormName__c);
    }

    @IsTest
    public static void updateIPIARecordTypeLink_noMatchingTemplateIdButMatchingName() {
        IPIA_Record__c record1 = new IPIA_Record__c(FormName__c = 'Type1', DocusignTemplate__c = 'template2', MitId__c = '912345673');
        insert record1;

        IPIA_Type__c type1 = new IPIA_Type__c(Name = 'Type1', Status__c = 'Active', DocusignTemplate__c = 'template1');
        insert type1;

        IPIA_Record__c updatedRecord = [SELECT Id, IPIA_Type__c FROM IPIA_Record__c WHERE Id = :record1.Id];
        Assert.areEqual(type1.Id, updatedRecord.IPIA_Type__c);
    }

    @IsTest
    public static void updateIPIARecordTypeLink_noMatchingFormName() {
        IPIA_Record__c record1 = new IPIA_Record__c(FormName__c = 'Type2', MitId__c = '912345673');
        insert record1;

        IPIA_Type__c type1 = new IPIA_Type__c(Name = 'Type1', Status__c = 'Active');
        insert type1;

        IPIA_Record__c updatedRecord = [SELECT Id, IPIA_Type__c FROM IPIA_Record__c WHERE Id = :record1.Id];
        Assert.isNull(updatedRecord.IPIA_Type__c);
    }


    @IsTest
    public static void testLinkIPIARecordsToDisclosureInventors() {
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Software_Code_Disclosure').getRecordTypeId();

        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-1));
        IPIA_Record__c ipiaRecord3 = new IPIA_Record__c(FormName__c = 'Test 3', MitId__c = '912345675', SignDatetime__c = Date.today());
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2, ipiaRecord3};
        insert ipiaRecords;

        // Contacts
        Account contact1 = SampleDataFactory.createContact('Bob', true, '912345671');
        Account contact2 = SampleDataFactory.createContact('Donald', true, '912345675');

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(recordTypeIdSoftwareCode, 'Test Inventor Actions on Signing', 'Draft', contact1);

        // Inventors On Disclosure
        DisclosureInventor__c inventor1 = SampleDataFactory.createInventor(disclosure, true, contact1);
        DisclosureInventor__c inventor2 = SampleDataFactory.createInventor(disclosure, true, contact2);

        Test.startTest();
        List<DisclosureInventor__c> disclosureInventors = IPIARecordService.linkIPIARecordsToDisclosureInventors(ipiaRecords);
        Test.stopTest();

        Integer countDisclosureInventors = 0;
        for (DisclosureInventor__c disclosureInventor : disclosureInventors) {
            if (disclosureInventor.Id == inventor1.Id) {
                Assert.areEqual('912345671', disclosureInventor.Contact__r.MitId__pc, 
                    'Disclosure Inventor should be linked to IPIA Record with MitId 912345671');
                Assert.areEqual(ipiaRecord2.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 2');
            }
            else if (disclosureInventor.Id == inventor2.Id) {
                Assert.areEqual('912345675', disclosureInventor.Contact__r.MitId__pc, 
                    'Disclosure Inventor should be linked to IPIA Record with MitId 912345675');
                Assert.areEqual(ipiaRecord3.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 3');
            }
            countDisclosureInventors++;
        }
        Assert.areEqual(2, countDisclosureInventors, 'Should have linked 2 Disclosure Inventors to IPIA Records');
    }

    @IsTest
    public static void testLinkIPIARecordsToDisclosureInventorsAfterCreation() {
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Software_Code_Disclosure').getRecordTypeId();

        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345675', SignDatetime__c = Date.today().addDays(-2));
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2};
        insert ipiaRecords;

        // Contacts
        Account contact1 = SampleDataFactory.createContact('Bob', true, '912345671');
        Account contact2 = SampleDataFactory.createContact('Donald', true, '912345675');

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(recordTypeIdSoftwareCode, 'Test Inventor Actions on Signing', 'Draft', contact1);

        // Inventors On Disclosure
        DisclosureInventor__c inventor1 = SampleDataFactory.createInventor(disclosure, true, contact1);
        DisclosureInventor__c inventor2 = SampleDataFactory.createInventor(disclosure, true, contact2);

        inventor1 = [SELECT Id, IPIA_Record__c, IPIA_Record__r.SignDatetime__c FROM DisclosureInventor__c WHERE Contact__r.FirstName = 'Bob' LIMIT 1];
        inventor2 = [SELECT Id, IPIA_Record__c, IPIA_Record__r.SignDatetime__c FROM DisclosureInventor__c WHERE Contact__r.FirstName = 'Donald' LIMIT 1];

        Assert.areEqual(inventor1.IPIA_Record__r.SignDatetime__c, ipiaRecord1.SignDatetime__c, 'Disclosure Inventor should be linked to IPIA Record 1');
        Assert.areEqual(inventor2.IPIA_Record__r.SignDatetime__c, ipiaRecord2.SignDatetime__c, 'Disclosure Inventor should be linked to IPIA Record 2');

        // Test Disclosure Inventor IPIA did not update since date is before
        IPIA_Record__c ipiaRecord3 = new IPIA_Record__c(FormName__c = 'Test 3', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-3));
        IPIA_Record__c ipiaRecord4 = new IPIA_Record__c(FormName__c = 'Test 4', MitId__c = '912345675', SignDatetime__c = Date.today().addDays(-3));
        ipiaRecords = new List<IPIA_Record__c>{ipiaRecord3, ipiaRecord4};
        insert ipiaRecords;

        inventor1 = [SELECT Id, IPIA_Record__c, IPIA_Record__r.SignDatetime__c FROM DisclosureInventor__c WHERE Contact__r.FirstName = 'Bob' LIMIT 1];
        inventor2 = [SELECT Id, IPIA_Record__c, IPIA_Record__r.SignDatetime__c FROM DisclosureInventor__c WHERE Contact__r.FirstName = 'Donald' LIMIT 1];

        Assert.areEqual(inventor1.IPIA_Record__r.SignDatetime__c, ipiaRecord1.SignDatetime__c, 'Disclosure Inventor should be linked to IPIA Record 1');
        Assert.areEqual(inventor2.IPIA_Record__r.SignDatetime__c, ipiaRecord2.SignDatetime__c, 'Disclosure Inventor should be linked to IPIA Record 2');

        // Test Disclosure Inventor IPIA did update since date is after
        IPIA_Record__c ipiaRecord5 = new IPIA_Record__c(FormName__c = 'Test 5', MitId__c = '912345671', SignDatetime__c = Date.today());
        IPIA_Record__c ipiaRecord6 = new IPIA_Record__c(FormName__c = 'Test 6', MitId__c = '912345675', SignDatetime__c = Date.today());
        ipiaRecords = new List<IPIA_Record__c>{ipiaRecord5, ipiaRecord6};
        insert ipiaRecords;

        inventor1 = [SELECT Id, IPIA_Record__c, IPIA_Record__r.SignDatetime__c FROM DisclosureInventor__c WHERE Contact__r.FirstName = 'Bob' LIMIT 1];
        inventor2 = [SELECT Id, IPIA_Record__c, IPIA_Record__r.SignDatetime__c FROM DisclosureInventor__c WHERE Contact__r.FirstName = 'Donald' LIMIT 1];

        Assert.areEqual(inventor1.IPIA_Record__r.SignDatetime__c, ipiaRecord5.SignDatetime__c, 'Disclosure Inventor should be linked to IPIA Record 5');
        Assert.areEqual(inventor2.IPIA_Record__r.SignDatetime__c, ipiaRecord6.SignDatetime__c, 'Disclosure Inventor should be linked to IPIA Record 6');
    }

    @IsTest
    public static void testFetchIPIASignedDocument() {
        String signedPdfFileContent = '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YW5zcGFyZW5jeS9DUy9EZXZpY2VSR0IvSSB0cnVlPj4vQ29udGVudHMgMiAwIFI+PgplbmRvYmoKCjQgMCBvYmoKPDwvVHlwZS9QYWdlcwovUmVzb3VyY2VzIDExIDAgUgovTWVkaWFCb3hbIDAgMCA1OTUgODQxIF0KL0tpZHNbIDEgMCBSIF0KL0NvdW50IDE+PgplbmRvYmoKCjEyIDAgb2JqCjw8L1R5cGUvQ2F0YWxvZy9QYWdlcyA0IDAgUgovT3BlbkFjdGlvblsxIDAgUiAvWFlaIG51bGwgbnVsbCAwXQovTGFuZyhlbi1aQSkKPj4KZW5kb2JqCgoxMyAwIG9iago8PC9DcmVhdG9yPEZFRkYwMDU3MDA3MjAwNjkwMDc0MDA2NTAwNzI+Ci9Qcm9kdWNlcjxGRUZGMDA0QzAwNjkwMDYyMDA3MjAwNjUwMDRGMDA2NjAwNjYwMDY5MDA2MzAwNjUwMDIwMDAzNjAwMkUwMDM0PgovQ3JlYXRpb25EYXRlKEQ6MjAyMjExMzAxMzAxMzUrMDInMDAnKT4+CmVuZG9iagoKeHJlZgowIDE0CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwNzA4OSAwMDAwMCBuIAowMDAwMDAwMDE5IDAwMDAwIG4gCjAwMDAwMDAyMTkgMDAwMDAgbiAKMDAwMDAwNzI1OCAwMDAwMCBuIAowMDAwMDAwMjM5IDAwMDAwIG4gCjAwMDAwMDYyMzEgMDAwMDAgbiAKMDAwMDAwNjI1MiAwMDAwMCBuIAowMDAwMDA2NDQ3IDAwMDAwIG4gCjAwMDAwMDY3OTQgMDAwMDAgbiAKMDAwMDAwNzAwMiAwMDAwMCBuIAowMDAwMDA3MDM0IDAwMDAwIG4gCjAwMDAwMDczNTcgMDAwMDAgbiAKMDAwMDAwNzQ1NCAwMDAwMCBuIAp0cmFpbGVyCjw8L1NpemUgMTQvUm9vdCAxMiAwIFIKL0luZm8gMTMgMCBSCi9JRCBbIDwzNTE0QjVBOTlCOTk5N0Q2MUE0NjMxOUE1RkE2ODI3RD4KPDM1MTRCNUE5OUI5OTk3RDYxQTQ2MzE5QTVGQTY4MjdEPiBdCi9Eb2NDaGVja3N1bSAvNDBENkEzRTlDQjQ4QjgxRkQ3MEI0RUFEMDY3NDZDOTQKPj4Kc3RhcnR4cmVmCjc2MjkKJSVFT0YK';

        IPIA_Type__c type1 = new IPIA_Type__c(Name = 'Type1', Exemption__c = false, Status__c = 'Active');
        insert new List<IPIA_Type__c>{type1};
        String envelopeId = 'e00cd216-2997-469e-996e-a19177aa4d47';
        IPIA_Record__c record = new IPIA_Record__c(IPIA_Type__c = type1.Id, FormName__c = 'Type1', MitId__c = '912345673', DocusignEnvelopeId__c = envelopeId);
        insert record;

        HttpMockBlobFactory mock = new HttpMockBlobFactory(201, 'OK', signedPdfFileContent, new Map<String,String>());
        Id fakeId = TestUtility.getFakeId(IPIA_Type__c.sObjectType);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        IPIARecordService service = new IPIARecordService();
        Blob pdf = service.getIpiaRecordDocument(record.Id);
        System.assertEquals(true, pdf != null, 'Expected base64 downloaded and converted to Blob');

        Blob emptyPdf = service.getIpiaRecordDocument(fakeId);
        System.assertEquals(true, emptyPdf == null, 'Expected null Blob');
        Test.stopTest();
    }


    @IsTest
    public static void testFailedFetchIPIASignedDocument() {
        String signedPdfFileContent = '{"message": "The envelope specified either does not exist or you have no rights to it."}';

        IPIA_Type__c type1 = new IPIA_Type__c(Name = 'Type1', Exemption__c = false, Status__c = 'Active');
        insert new List<IPIA_Type__c>{type1};
        String envelopeId = 'e00cd216-2997-469e-996e-a19177aa4d47';
        IPIA_Record__c record = new IPIA_Record__c(IPIA_Type__c = type1.Id, FormName__c = 'Type1', MitId__c = '912345673', DocusignEnvelopeId__c = envelopeId);
        insert record;

        HttpMockBlobFactory mock = new HttpMockBlobFactory(400, 'OK', signedPdfFileContent, new Map<String,String>());
        Id fakeId = TestUtility.getFakeId(IPIA_Type__c.sObjectType);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        try {
            IPIARecordService service = new IPIARecordService();
            Blob pdf = service.getIpiaRecordDocument(record.Id);
            System.assert(false, 'Exception not thrown');
        }catch(Exception e) {
        }
        Test.stopTest();
    }

    @IsTest
    public static void testEmptyFetchIPIASignedDocument() {
        String signedPdfFileContent = '';

        IPIA_Type__c type1 = new IPIA_Type__c(Name = 'Type1', Exemption__c = false, Status__c = 'Active');
        insert new List<IPIA_Type__c>{type1};
        String envelopeId = 'e00cd216-2997-469e-996e-a19177aa4d47';
        IPIA_Record__c record = new IPIA_Record__c(IPIA_Type__c = type1.Id, FormName__c = 'Type1', MitId__c = '912345673', DocusignEnvelopeId__c = envelopeId);
        insert record;

        HttpMockBlobFactory mock = new HttpMockBlobFactory(201, 'OK', signedPdfFileContent, new Map<String,String>());
        Id fakeId = TestUtility.getFakeId(IPIA_Type__c.sObjectType);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        try {
            IPIARecordService service = new IPIARecordService();
            Blob pdf = service.getIpiaRecordDocument(record.Id);
            System.assert(false, 'Exception not thrown');
        }catch(Exception e) {
        }
        Test.stopTest();
    }

    @IsTest
    public static void returnsCurrentIPIARecordsWithValidMitIds() {
        List<String> mitIds = new List<String>{'912345673', '912123465' };
        IPIA_Record__c record1 = new IPIA_Record__c(MitId__c = '912345673', FormName__c = 'Type1', SignDatetime__c = Date.today().addDays(-1));
        IPIA_Record__c record2 = new IPIA_Record__c(MitId__c = '912123465' , FormName__c = 'Type2', SignDatetime__c = Date.today().addDays(-2));
        insert new List<IPIA_Record__c>{record1, record2};

        Test.startTest();
        List<IPIA_Record__c> result = IPIARecordService.getCurrentIPIARecords(mitIds);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should return 2 records');
    }

    @IsTest
    public static void getsCurrentIPIARecordsWithHasDoc() {
        List<String> mitIds = new List<String>{'912345673', '912123465' };
        IPIA_Record__c record1 = new IPIA_Record__c(MitId__c = '912345673', FormName__c = 'Type1', SignDatetime__c = Date.today().addDays(-1));
        IPIA_Record__c record2 = new IPIA_Record__c(MitId__c = '912123465' , FormName__c = 'Type2', SignDatetime__c = Date.today().addDays(-2));
        insert new List<IPIA_Record__c>{record1, record2};

        Test.startTest();
        List<IPIA_Record__c> result = IPIARecordService.getCurrentIPIARecords(mitIds);

        IPIAController.uploadIPIADocuments(result[1].id, 'Test File', 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=', '');
        List<IPIA_Record__c> resultWithDocs = IPIARecordService.getCurrentIPIARecords(mitIds);

        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should return 2 records');
        Assert.areEqual(true , resultWithDocs[0].ContentDocumentLinks.isEmpty(), '1st IPIA record, should NOT have linked doc');
        Assert.areEqual(false, resultWithDocs[1].ContentDocumentLinks.isEmpty(), '2nd IPIA record, should have linked doc');
    }

    @IsTest
    public static void returnsMostRecentIPIARecordForEachMitId() {
        List<String> mitIds = new List<String>{'912345673'};
        IPIA_Record__c oldRecord = new IPIA_Record__c(MitId__c = '912345673', FormName__c = 'Type1', SignDatetime__c = Date.today().addDays(-10));
        IPIA_Record__c newRecord = new IPIA_Record__c(MitId__c = '912345673', FormName__c = 'Type2',SignDatetime__c = Date.today().addDays(-1));
        insert new List<IPIA_Record__c>{oldRecord, newRecord};

        Test.startTest();
        List<IPIA_Record__c> result = IPIARecordService.getCurrentIPIARecords(mitIds);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return 1 record');
        System.assertEquals(newRecord.Id, result[0].Id, 'Should return the most recent record');
    }

    @IsTest
    public static void returnsEmptyListForInvalidMitIds() {
        List<String> mitIds = new List<String>{'invalid_mit_id'};

        Test.startTest();
        List<IPIA_Record__c> result = IPIARecordService.getCurrentIPIARecords(mitIds);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return 0 records');
    }

    @IsTest
    public static void returnsEmptyListForBlankMitIds() {
        List<String> mitIds = new List<String>{''};

        Test.startTest();
        List<IPIA_Record__c> result = IPIARecordService.getCurrentIPIARecords(mitIds);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return 0 records');
    }

    @IsTest
    public static void returnsEmptyListWhenNoRecordsExist() {
        List<String> mitIds = new List<String>{'912345673', '912123465' };

        Test.startTest();
        List<IPIA_Record__c> result = IPIARecordService.getCurrentIPIARecords(mitIds);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return 0 records');
    }

    @IsTest
    public static void testRecordsToSync_insert() {
        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-3));
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2};

        Test.startTest();
        insert ipiaRecords;

        List<IPIA_Record__c> testInsertRecords = IPIARecordService.getIpiaRecordToSync(null, ipiaRecords);
        Assert.areEqual(1, testInsertRecords.size(), 'Should return 1 record');

        IPIA_Record__c updateIpiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-1));
        IPIA_Record__c updateIpiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-5));
        List<IPIA_Record__c> updateIpiaRecords = new List<IPIA_Record__c>{updateIpiaRecord1, updateIpiaRecord2};
        insert updateIpiaRecords;
        List<IPIA_Record__c> testUpdateRecords = IPIARecordService.getIpiaRecordToSync(ipiaRecords, updateIpiaRecords);

        Assert.areEqual(1, testUpdateRecords.size(), 'Should return 1 record');
        IPIARecordService.startForresterSync(testUpdateRecords);

        Test.stopTest();
    }

    @IsTest
    public static void testRecordsToSync_update() {
        // Only IPIA Sys Admin can update IPIA Records' MIT ID and historic IPIASs
        insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(),
                PermissionSetId=[SELECT Id FROM PermissionSet WHERE Name='IPIA_TLO_Admin'].Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Test 1', Exemption__c = true, Status__c = 'Active');
            IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'Test 2', Exemption__c = true, Status__c = 'Active');
            insert new List<IPIA_Type__c>{
                    ipiaType1, ipiaType2
            };

            // IPIA Records
            IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(IPIA_Type__c = ipiaType1.Id, MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
            IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(IPIA_Type__c = ipiaType2.Id, MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-3));
            List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{
                    ipiaRecord1, ipiaRecord2
            };

            Test.startTest();
            insert ipiaRecords;

            List<IPIA_Record__c> testInsertRecords = IPIARecordService.getIpiaRecordToSync(null, ipiaRecords);
            Assert.areEqual(1, testInsertRecords.size(), 'Should return 1 record');


            // Update the Current IPIA, should sync
            IPIA_Record__c updatedIpiaRecord1 = new IPIA_Record__c(Id = ipiaRecord1.Id, IPIA_Type__c = ipiaType2.Id, MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
            update updatedIpiaRecord1;

            List<IPIA_Record__c> testUpdateRecords = IPIARecordService.getIpiaRecordToSync(new List<IPIA_Record__c>{
                    ipiaRecord1
            }, new List<IPIA_Record__c>{
                    updatedIpiaRecord1
            });
            Assert.areEqual(1, testUpdateRecords.size(), 'Should return 1 record');
            Assert.areEqual(ipiaRecord1.Id, testUpdateRecords[0].Id, 'Should return the Current IPIA record after IPIA Type was changed');


            // Update a historic IPIA to become the new Current IPIA, should sync
            IPIA_Record__c updatedIpiaRecord2 = new IPIA_Record__c(Id = ipiaRecord2.Id, MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-1));
            update updatedIpiaRecord2;

            List<IPIA_Record__c> testUpdateRecords2 = IPIARecordService.getIpiaRecordToSync(new List<IPIA_Record__c>{
                    ipiaRecord2
            }, new List<IPIA_Record__c>{
                    updatedIpiaRecord2
            });
            Assert.areEqual(1, testUpdateRecords2.size(), 'Should return 1 record');
            Assert.areEqual(ipiaRecord2.Id, testUpdateRecords2[0].Id, 'Should return the Current IPIA record');


            // Should not sync any record since it is a historic IPIA
            updatedIpiaRecord1.IPIA_Type__c = ipiaType1.Id;
            update updatedIpiaRecord1;

            List<IPIA_Record__c> testUpdateRecords3 = IPIARecordService.getIpiaRecordToSync(new List<IPIA_Record__c>{
                    ipiaRecord1
            }, new List<IPIA_Record__c>{
                    updatedIpiaRecord1
            });
            Assert.areEqual(0, testUpdateRecords3.size(), 'Should not return any record since it is not the Current IPIA');

            IPIARecordService.startForresterSync(testUpdateRecords);

            Test.stopTest();
        }
    }

    @IsTest
    public static void testRecordsShouldNotSync() {
        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-1));
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2};

        Test.startTest();
        insert ipiaRecords;

        List<IPIA_Record__c> testInsertRecords = IPIARecordService.getIpiaRecordToSync(null, ipiaRecords);
        Assert.areEqual(1, testInsertRecords.size(), 'Should return 1 record');

        IPIA_Record__c updateIpiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-3));
        IPIA_Record__c updateIpiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-4));
        List<IPIA_Record__c> updateIpiaRecords = new List<IPIA_Record__c>{updateIpiaRecord1, updateIpiaRecord2};
        insert updateIpiaRecords;
        List<IPIA_Record__c> testUpdateRecords = IPIARecordService.getIpiaRecordToSync(ipiaRecords, updateIpiaRecords);

        Assert.areEqual(0, testUpdateRecords.size(), 'Should return 0 record');
        IPIARecordService.startForresterSync(testUpdateRecords);

        Test.stopTest();
    }

    @IsTest
    public static void testDuplicateMitIdSyncToForrester() {
        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1 };


        insert ipiaRecords;
        List<IPIA_Record__c> testInsertRecords = IPIARecordService.getIpiaRecordToSync(null, ipiaRecords);



        // Create mock database instance for external data
        ExternalQueryMock mock = ExternalQueryMock.getInstance();

        // Mock Forrester Contact data
        List<Forrester_CONTACT__x> mockForresterContacts = new List<Forrester_CONTACT__x>();
        Forrester_CONTACT__x mockForresterContact = new Forrester_CONTACT__x(
            MIT_ID__c = '91234567',
            CONTACT_RECID__c = '12345'
        );
        Forrester_CONTACT__x mockDuplicateForresterContact = new Forrester_CONTACT__x(
            MIT_ID__c = '91234567',
            CONTACT_RECID__c = '12346'
        );
        mockForresterContacts.add(mockForresterContact);
        mockForresterContacts.add(mockDuplicateForresterContact);

        mock.setDataStore('Forrester_CONTACT__x:Ids', mockForresterContacts);
        Boolean exceptionThrown = false;
        try{
            Test.startTest();
            Set<Id> asyncRequestIdsList = IPIARecordService.startForresterSync(ipiaRecords);
            IPIARecordUpsertJob upsertIpiaJob = new IPIARecordUpsertJob(asyncRequestIdsList);
            Integer delayInMinutes = 0;
            System.enqueueJob(upsertIpiaJob, delayInMinutes);

            Test.stopTest();
        }catch (Exception e) {
            exceptionThrown = true;
        }
        Assert.isTrue(!exceptionThrown, 'Duplicate Forrester MIT_ID Exception should be handled');

    }

    @IsTest
    public static void testMitIdNotFoundSyncToForrester() {

        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1 };


        insert ipiaRecords;
        List<IPIA_Record__c> testInsertRecords = IPIARecordService.getIpiaRecordToSync(null, ipiaRecords);


        // Create mock database instance for external data
        ExternalQueryMock mock = ExternalQueryMock.getInstance();

        // Mock Forrester Contact data
        List<Forrester_CONTACT__x> mockForresterContacts = new List<Forrester_CONTACT__x>();
        // Empty List
        mock.setDataStore('Forrester_CONTACT__x:Ids', mockForresterContacts);
        Boolean exceptionThrown = false;
        try{
            Test.startTest();
            Set<Id> asyncRequestIdsList = IPIARecordService.startForresterSync(ipiaRecords);
            IPIARecordUpsertJob upsertIpiaJob = new IPIARecordUpsertJob(asyncRequestIdsList);
            Integer delayInMinutes = 0;
            System.enqueueJob(upsertIpiaJob, delayInMinutes);

            Test.stopTest();
        }catch (Exception e) {
            exceptionThrown = true;
        }
        Assert.isTrue(!exceptionThrown, 'MIT_ID not found Exception should be handled');

    }

    @IsTest
    public static void testSyncToForresterBatch() {

        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1 };


        insert ipiaRecords;
        Async_Request__c asyncReq = getAsyncRequestByRecordId(ipiaRecord1.Id);
        System.assert(asyncReq.Has_Processed__c == false, 'Initial value should be false');
        System.assert(asyncReq.Retry_Count__c == 0, 'Initial value should be 0');

        List<IPIA_Record__c> testInsertRecords = IPIARecordService.getIpiaRecordToSync(null, ipiaRecords);


        // Create mock database instance for external data
        ExternalQueryMock mock = ExternalQueryMock.getInstance();

        // Mock Forrester Contact data
        List<Forrester_CONTACT__x> mockForresterContacts = new List<Forrester_CONTACT__x>();
        // Empty List
        mock.setDataStore('Forrester_CONTACT__x:Ids', mockForresterContacts);
        Boolean exceptionThrown = false;
        try{
            Test.startTest();
            IPIASignedToForresterJob ipiaJob = new IPIASignedToForresterJob();
            Database.executeBatch(ipiaJob, 50);
            Test.stopTest();
        }catch (Exception e) {
            exceptionThrown = true;
        }
        Assert.isTrue(!exceptionThrown, 'MIT_ID not found Exception should be handled');

        Async_Request__c asyncReqAfter = getAsyncRequestByRecordId(ipiaRecord1.Id);
        System.assert(asyncReqAfter.Has_Processed__c == false, 'Processed value should be false');
        System.assert(asyncReqAfter.Retry_Count__c == 1, 'Retry count should 1');

    }


    @IsTest
    public static void testSyncToForrester() {

        // IPIA Types
        // ALTERNATE IPIA AGMT FLAG is true when Exemption is true
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Other', Exemption__c = true, Status__c = 'Active');
        insert ipiaType1;
        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = ipiaType1.Name, MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2), IPIA_Type__c = ipiaType1.Id);
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-1));
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2};



        insert ipiaRecords;
        List<IPIA_Record__c> testInsertRecords = IPIARecordService.getIpiaRecordToSync(null, ipiaRecords);



        // Create mock database instance for external data
        ExternalQueryMock mock = ExternalQueryMock.getInstance();

        // Mock Forrester Contact data
        List<Forrester_CONTACT__x> mockForresterContacts = new List<Forrester_CONTACT__x>();
        Forrester_CONTACT__x mockForresterContact = new Forrester_CONTACT__x(
            MIT_ID__c = '912345671',
            CONTACT_RECID__c = '12345',
            Id = TestUtility.getFakeId(Forrester_CONTACT__x.sObjectType)
        );
        mockForresterContacts.add(mockForresterContact);
        Forrester_CONTACT__x mockForresterContact2 = new Forrester_CONTACT__x(
            MIT_ID__c = '912345691',
            CONTACT_RECID__c = '12346',
            Id = TestUtility.getFakeId(Forrester_CONTACT__x.sObjectType)
        );
        mockForresterContacts.add(mockForresterContact2);

        // Mock Forrester IPIA Types data
        List<Forrester_IPIA_TYPES__x> mockForresterIPIATypes = new List<Forrester_IPIA_TYPES__x>();
        Forrester_IPIA_TYPES__x mockForresterIPIAType = new Forrester_IPIA_TYPES__x(
            IPIA_TYPE__c = 'SMART',
            Id = TestUtility.getFakeId(Forrester_IPIA_TYPES__x.sObjectType)
        );
        mockForresterIPIATypes.add(mockForresterIPIAType);

        mock.setDataStore('Forrester_CONTACT__x:Ids', mockForresterContacts);
        mock.setDataStore('Forrester_IPIA_TYPES__x:Ids', mockForresterIPIATypes);
        ExternalObjectDatabase.setMock(new MockExternalObjectDatabase(mockForresterContact.Id));

        Set<Id> asyncRequestIdsList = IPIARecordService.startForresterSync(ipiaRecords);

        Test.startTest();
        IPIARecordUpsertJob upsertIpiaJob = new IPIARecordUpsertJob(asyncRequestIdsList);
        Integer delayInMinutes = 0;
        System.enqueueJob(upsertIpiaJob, delayInMinutes);
        Test.stopTest();

        Id asyncReqId = new List<Id> (asyncRequestIdsList).get(0);
        Async_Request__c asyncReq = getAsyncRequestById(asyncReqId);
        System.assert(asyncReq.Has_Processed__c, 'Has_Processed__c should be true');

        IPIA_Record__c ipiaRecord1Test = [SELECT Id, MitId__c, Contact_Recid__c FROM IPIA_Record__c WHERE MitId__c = :ipiaRecord1.MitId__c];
        System.assertEquals(ipiaRecord1Test.Contact_Recid__c, mockForresterContact.CONTACT_RECID__c, 'The Contact RecId should be updated from Forrester');


    }
    @IsTest
    public static void testCommentSyncToForrester() {
         IPIARecordUpsertJob job = new IPIARecordUpsertJob(new Set<Id>());
         Integer maxLength = 109;
         String ipiaTypeName = 'IBM';
         String comment1 = 'Duplicate Contact ID #44000 had an existing IPIA:';
         comment1 += '\nSigned IPIA: checked';
         comment1 += '\nDate IPIA Signed: 6/3/1995';
         comment1 += '\nSigned: IBM';
         String newComment = job.getIPIATypeComment(maxLength, comment1, 'Other',  DateTime.newInstance(2024, 3, 31 ).date());
         System.debug(newComment);
         System.assert(newComment.length() <= maxLength, 'Comment not truncated');
         System.assert(newComment.startsWith('...'), 'Comment not truncated');

         String nullComment = job.getIPIATypeComment(maxLength, null, 'Other',  DateTime.newInstance(2024, 3, 31 ).date());
         System.assertEquals(nullComment, 'Signed: Other Date: 03/31/2024', 'IPIA comment does not match');

         String emptyComment = job.getIPIATypeComment(maxLength, '', 'Other',  DateTime.newInstance(2024, 3, 31 ).date());
         System.assertEquals(emptyComment, 'Signed: Other Date: 03/31/2024', 'IPIA comment does not match');

         String emptyDateComment = job.getIPIATypeComment(maxLength, '', 'Other',  null);
         System.assertEquals(emptyDateComment, 'Signed: Other', 'IPIA comment does not match');


         String truncationNotNeededComment = job.getIPIATypeComment(maxLength, 'IPIA received from LL on 12/15/2022.', 'Other',  DateTime.newInstance(2024, 3, 31 ).date());
         System.assertEquals(truncationNotNeededComment, 'IPIA received from LL on 12/15/2022.\nSigned: Other Date: 03/31/2024', 'Original comment does not match');
    }

    @IsTest
    public static void testFormTypeChangedExempted() {

        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Other', Exemption__c = true, Status__c = 'Active');
        insert ipiaType1;
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = ipiaType1.Name, MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2), IPIA_Type__c = ipiaType1.Id);
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1};

        insert ipiaRecords;

        Map<Id, IPIA_Type__c> typeLookup = IPIARecordService.getIpiaTypesFromIpiaRecord(ipiaRecords);
        Boolean formExempted = IPIARecordService.ipiaRecordTypeChangedAndExempt(ipiaRecord1, typeLookup);
        System.assertEquals(true, formExempted, 'Exemption flag is true');
    }

   @IsTest
    public static void testFormTypeChangedStandard() {

        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Other', Exemption__c = false, Status__c = 'Active');
        insert ipiaType1;
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = ipiaType1.Name, MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2), IPIA_Type__c = ipiaType1.Id);
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1};

        insert ipiaRecords;

        Map<Id, IPIA_Type__c> typeLookup = IPIARecordService.getIpiaTypesFromIpiaRecord(ipiaRecords);
        Boolean formExempted = IPIARecordService.ipiaRecordTypeChangedAndExempt(ipiaRecord1, typeLookup);
        System.assertEquals(false, formExempted, 'Exemption flag is false');
    }


    private static Async_Request__c getAsyncRequestById(String id) {
        Async_Request__c asyncReq = [
                            SELECT
                                Id,
                                Has_Processed__c,
                                Retry_Count__c,
                                Record_Id__c,
                                sObject_Name__c
                            FROM Async_Request__c
                            WHERE
                                Id = :id
                                AND sObject_Name__c = 'IPIA_Record__c'
                                AND Job_Name__c = 'IPIASignedToForresterJob'
                            LIMIT 1
                        ];
        return asyncReq;
    }

    private static Async_Request__c getAsyncRequestByRecordId(String id) {
        Async_Request__c asyncReq = [
                            SELECT
                                Id,
                                Has_Processed__c,
                                Retry_Count__c,
                                Record_Id__c,
                                sObject_Name__c
                            FROM Async_Request__c
                            WHERE
                                Record_Id__c = :id
                                AND sObject_Name__c = 'IPIA_Record__c'
                                AND Job_Name__c = 'IPIASignedToForresterJob'
                            LIMIT 1
                        ];
        return asyncReq;
    }


   private class MockExternalObjectDatabase extends ExternalObjectDatabase {
          String scopeId;
          MockExternalObjectDatabase(String scopeId) {
            this.scopeId = scopeId;
          }
          protected override void updatePassThrough(SObject sfObject , DataSource.AsyncSaveCallback asyncSaveCallback, System.AccessLevel accessLevel) {
                Database.SaveResult saveResult = (Database.SaveResult) JSON.deserialize(
                  JSON.serialize(
                      new Map<String, Object>{
                          'id' => this.scopeId,
                          'success' => true,
                          'errors' => new List<String>()
                      }
                  ),
                  Database.SaveResult.class
                );
                asyncSaveCallback.processSave(saveResult);
          }
   }
}