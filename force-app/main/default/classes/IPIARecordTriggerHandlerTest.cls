/**
 * Created by Andreas du Preez on 2024/08/06.
 */

@IsTest
public with sharing class IPIARecordTriggerHandlerTest {

    @TestSetup
    public static void testSetup() {
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Software_Code_Disclosure').getRecordTypeId();

        // Contacts
        Account contact1 = SampleDataFactory.createContact('Bob', true, '912345691');
        Account contact2 = SampleDataFactory.createContact('Donald', true, '912345692');

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(recordTypeIdSoftwareCode, 'Test Inventor Actions on Signing', 'Draft', contact1);

        // Inventors On Disclosure
        DisclosureInventor__c inventor1 = SampleDataFactory.createInventor(disclosure, true, contact1);
        DisclosureInventor__c inventor2 = SampleDataFactory.createInventor(disclosure, true, contact2);
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>{inventor1, inventor2};
    }

    @IsTest
    public static void testInsertDisclosureInventorIPIALookup() {
        List<DisclosureInventor__c> disclosureInventors = [SELECT Id, Contact__r.MitId__pc, Contact__r.FirstName FROM DisclosureInventor__c];
        DisclosureInventor__c inventor1 = disclosureInventors[0].Contact__r.FirstName == 'Bob' ? disclosureInventors[0] : disclosureInventors[1];
        DisclosureInventor__c inventor2 = disclosureInventors[1].Contact__r.FirstName == 'Bob' ? disclosureInventors[0] : disclosureInventors[1];

        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-1));
        IPIA_Record__c ipiaRecord3 = new IPIA_Record__c(FormName__c = 'Test 3', MitId__c = '912345692', SignDatetime__c = Date.today());
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2, ipiaRecord3};

        Test.startTest();
        insert ipiaRecords;
        Test.stopTest();

        List<DisclosureInventor__c> updatedDisclosureInventors = [SELECT Id, Contact__r.MitId__pc, IPIA_Record__c FROM DisclosureInventor__c WHERE Id IN :disclosureInventors];

        Integer countDisclosureInventors = 0;
        for (DisclosureInventor__c disclosureInventor : updatedDisclosureInventors) {
            if (disclosureInventor.Id == inventor1.Id) {
                Assert.areEqual('912345691', disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 1');
                Assert.areEqual(ipiaRecord2.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 2');
            }
            else if (disclosureInventor.Id == inventor2.Id) {
                Assert.areEqual('912345692', disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 2');
                Assert.areEqual(ipiaRecord3.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 3');
            }
            countDisclosureInventors++;
        }
        Assert.areEqual(2, countDisclosureInventors, 'Should have linked 2 Disclosure Inventors to IPIA Records');
    }

    @IsTest
    public static void testUpdateDisclosureInventorIPIALookup() {
        List<DisclosureInventor__c> disclosureInventors = [SELECT Id, Contact__r.MitId__pc, Contact__r.FirstName FROM DisclosureInventor__c];
        DisclosureInventor__c inventor1 = disclosureInventors[0].Contact__r.FirstName == 'Bob' ? disclosureInventors[0] : disclosureInventors[1];
        DisclosureInventor__c inventor2 = disclosureInventors[1].Contact__r.FirstName == 'Bob' ? disclosureInventors[0] : disclosureInventors[1];

        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-40));
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-30));
        IPIA_Record__c ipiaRecord3 = new IPIA_Record__c(FormName__c = 'Test 3', MitId__c = '912345692', SignDatetime__c = Date.today().addDays(-20));
        IPIA_Record__c ipiaRecord4 = new IPIA_Record__c(FormName__c = 'Test 4', MitId__c = '912345692', SignDatetime__c = Date.today().addDays(-10));
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2, ipiaRecord3, ipiaRecord4};
        insert ipiaRecords;

        ipiaRecord2.SignDatetime__c = Date.today().addDays(-50);
        ipiaRecord4.SignDatetime__c = Date.today().addDays(-30);
        ipiaRecords = new List<IPIA_Record__c>{ipiaRecord2, ipiaRecord4};

        Test.startTest();
        update ipiaRecords;
        Test.stopTest();

        List<DisclosureInventor__c> updatedDisclosureInventors = [SELECT Id, Contact__r.MitId__pc, IPIA_Record__c FROM DisclosureInventor__c WHERE Id IN :disclosureInventors];

        Integer countDisclosureInventors = 0;
        for (DisclosureInventor__c disclosureInventor : updatedDisclosureInventors) {
            if (disclosureInventor.Id == inventor1.Id) {
                Assert.areEqual('912345691', disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 1');
                Assert.areEqual(ipiaRecord1.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 2');
            }
            else if (disclosureInventor.Id == inventor2.Id) {
                Assert.areEqual('912345692', disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 2');
                Assert.areEqual(ipiaRecord3.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 3');
            }
            countDisclosureInventors++;
        }
        Assert.areEqual(2, countDisclosureInventors, 'Should have linked 2 Disclosure Inventors to IPIA Records');
    }

    @IsTest
    public static void testUpdateDisclosureInventorIPIALookup_UpdateIPIARecordMITId() {
        // Only IPIA Sys Admin can update IPIA Records' MIT ID and historic IPIASs
        insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(),
                PermissionSetId=[SELECT Id FROM PermissionSet WHERE Name='IPIA_TLO_Admin'].Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {

            List<DisclosureInventor__c> disclosureInventors = [SELECT Id, Contact__r.MitId__pc, Contact__r.FirstName FROM DisclosureInventor__c];
            DisclosureInventor__c inventor1 = disclosureInventors[0].Contact__r.FirstName == 'Bob' ? disclosureInventors[0] : disclosureInventors[1];
            DisclosureInventor__c inventor2 = disclosureInventors[1].Contact__r.FirstName == 'Bob' ? disclosureInventors[0] : disclosureInventors[1];

            // IPIA Records
            IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-40));
            IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-30));
            IPIA_Record__c ipiaRecord3 = new IPIA_Record__c(FormName__c = 'Test 3', MitId__c = '912345692', SignDatetime__c = Date.today().addDays(-20));
            IPIA_Record__c ipiaRecord4 = new IPIA_Record__c(FormName__c = 'Test 4', MitId__c = '912345692', SignDatetime__c = Date.today().addDays(-10));
            List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2, ipiaRecord3, ipiaRecord4};
            insert ipiaRecords;

            ipiaRecord2.SignDatetime__c = Date.today();
            ipiaRecord2.MitId__c = '912345692';
            ipiaRecords = new List<IPIA_Record__c>{ipiaRecord2};

            Test.startTest();
            update ipiaRecords;
            Test.stopTest();

            List<DisclosureInventor__c> updatedDisclosureInventors = [SELECT Id, Contact__r.MitId__pc, IPIA_Record__c FROM DisclosureInventor__c WHERE Id IN :disclosureInventors];

            Integer countDisclosureInventors = 0;
            for (DisclosureInventor__c disclosureInventor : updatedDisclosureInventors) {
                if (disclosureInventor.Id == inventor1.Id) {
                    Assert.areEqual('912345691', disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 1');
                    Assert.areEqual(ipiaRecord1.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 1');
                }
                else if (disclosureInventor.Id == inventor2.Id) {
                    Assert.areEqual('912345692', disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 2');
                    Assert.areEqual(ipiaRecord2.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 2');
                }
                countDisclosureInventors++;
            }
            Assert.areEqual(2, countDisclosureInventors, 'Should have linked 2 Disclosure Inventors to IPIA Records');
        }
    }

    @IsTest
    public static void testUpdateDisclosureInventorIPIALookup_DeleteIPIARecord() {
        System.runAs(TestUtility.createSystemAdministrator()) {
            List<DisclosureInventor__c> disclosureInventors = [SELECT Id, Contact__r.MitId__pc, Contact__r.FirstName FROM DisclosureInventor__c];
            DisclosureInventor__c inventor1 = disclosureInventors[0].Contact__r.FirstName == 'Bob' ? disclosureInventors[0] : disclosureInventors[1];
            DisclosureInventor__c inventor2 = disclosureInventors[1].Contact__r.FirstName == 'Bob' ? disclosureInventors[0] : disclosureInventors[1];

            // IPIA Records
            IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-40));
            IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-30));
            IPIA_Record__c ipiaRecord3 = new IPIA_Record__c(FormName__c = 'Test 3', MitId__c = '912345692', SignDatetime__c = Date.today().addDays(-20));
            List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{
                    ipiaRecord1, ipiaRecord2, ipiaRecord3
            };
            insert ipiaRecords;

            Test.startTest();
            delete ipiaRecords;
            Test.stopTest();

            List<DisclosureInventor__c> updatedDisclosureInventors = [SELECT Id, Contact__r.MitId__pc, IPIA_Record__c FROM DisclosureInventor__c WHERE Id IN :disclosureInventors];

            for (DisclosureInventor__c disclosureInventor : updatedDisclosureInventors) {
                if (disclosureInventor.Id == inventor1.Id) {
                    Assert.areEqual('912345691', disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 1');
                    Assert.isNull(disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should not be linked to an IPIA Record.');
                } else if (disclosureInventor.Id == inventor2.Id) {
                    Assert.areEqual('912345692', disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 2');
                    Assert.isNull(disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should not be linked to an IPIA Record.');
                }
            }
        }
    }

    @IsTest
    public static void testIPIARecordUpdateValidation_CurrentIPIA() {
        // Only IPIA Sys Admin can update IPIA Records' MIT ID and historic IPIASs
        insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(),
                PermissionSetId=[SELECT Id FROM PermissionSet WHERE Name='IPIA_TLO_Admin'].Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-10));
            IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-20));
            insert new List<IPIA_Record__c>{
                    ipiaRecord1, ipiaRecord2
            };

            ipiaRecord1.SignDatetime__c = Date.today().addDays(-5);
            Boolean exceptionThrown = false;
            try {
                update ipiaRecord1;
            } catch (Exception ex) {
                exceptionThrown = true;
            }
            Assert.isFalse(exceptionThrown, 'Should not have thrown an exception for updating a Current IPIA Record');

            ipiaRecord2.SignDatetime__c = Date.today().addDays(-5);
            exceptionThrown = false;
            try {
                update ipiaRecord2;
            } catch (Exception ex) {
                exceptionThrown = true;
            }
            Assert.isFalse(exceptionThrown, 'Should not have thrown an exception for updating a historic IPIA Record');
        }
    }

    @IsTest
    public static void testIPIARecordUpdateValidation_FutureSignDate() {
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(10));
        Boolean exceptionThrown = false;
        try {
            insert ipiaRecord1;
        }
        catch (Exception ex) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Should have thrown an exception for inserting a IPIA Record with a future Sign Date');
    }

    @IsTest
    public static void testIPIARecordUpdate_FormName() {
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Current IPIA Type 1', Exemption__c = true, Status__c = 'Active');
        IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'Current IPIA Type 2', Exemption__c = true, Status__c = 'Active');
        insert new List<IPIA_Type__c>{ipiaType1, ipiaType2};

        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Current IPIA Type 1', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-40));
        insert ipiaRecord1;

        IPIA_Record__c insertedIPIARecord = [SELECT Id, FormName__c, IPIA_Type__c FROM IPIA_Record__c WHERE Id = :ipiaRecord1.Id];

        Assert.areEqual('Current IPIA Type 1', insertedIPIARecord.FormName__c, 'Should have inserted the correct Form Name');
        Assert.areEqual(ipiaType1.Id, insertedIPIARecord.IPIA_Type__c, 'Should have inserted the correct IPIA Type');

        insertedIPIARecord.IPIA_Type__c = ipiaType2.Id;
        update insertedIPIARecord;

        IPIA_Record__c updatedIPIARecord = [SELECT Id, FormName__c, IPIA_Type__c FROM IPIA_Record__c WHERE Id = :ipiaRecord1.Id];
        Assert.areEqual('Current IPIA Type 2', updatedIPIARecord.FormName__c, 'Should have updated the Form Name');
        Assert.areEqual(ipiaType2.Id, updatedIPIARecord.IPIA_Type__c, 'Should have updated the IPIA Type');
    }

    @IsTest
    public static void testSyncToForrester() {
        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-1));
        IPIA_Record__c ipiaRecord3 = new IPIA_Record__c(FormName__c = 'Test 3', MitId__c = '912345692', SignDatetime__c = Date.today());
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2, ipiaRecord3};

        Test.startTest();
        insert ipiaRecords;
        Test.stopTest();
    }

    @IsTest
    public static void testEmptyFormName() {

        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Other', Exemption__c = true, Status__c = 'Active');
        insert ipiaType1;

        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345691', SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c ipiaRecordWithType = new IPIA_Record__c(FormName__c = null, IPIA_Type__c = ipiaType1.Id, MitId__c = '912345692', SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c ipiaEmptyFormName = new IPIA_Record__c(FormName__c = null, MitId__c = '912345692', SignDatetime__c = Date.today().addDays(-2));


        Test.startTest();
        insert ipiaRecord1;
        insert ipiaRecordWithType;
        try {
            insert ipiaEmptyFormName;
            System.assert(false, 'Exception not thrown');
        } catch(Exception e) {
            System.assert(true, 'Exception thrown');
        }
        Test.stopTest();
    }

    @IsTest
    public static void testDeleteIpiaRecord_ContentDocument() {
        System.runAs(TestUtility.createSystemAdministrator()) {
            String mitId = '912345692';
            String fileName = 'Test File';
            String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';

            IPIA_Type__c ipiaType = new IPIA_Type__c(Name = 'Test IPIA Type', Description__c = 'Test Description', Status__c = 'Active');
            IPIA_Type__c insertedIpiaType = IPIAController.createIPIAType(ipiaType, fileName, fileBase64);

            IPIA_Record__c ipiaRecord = new IPIA_Record__c(FormName__c = null, IPIA_Type__c = insertedIpiaType.Id, MitId__c = mitId,
                    SignDatetime__c = Date.today().addDays(-2));
            insert ipiaRecord;

            IPIA_Record__c insertedIpia = [SELECT Id, MitId__c FROM IPIA_Record__c WHERE MitId__c = :mitId LIMIT 1];
            IPIAController.uploadIPIADocuments(ipiaRecord.Id, fileName, fileBase64, '');

            ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpia.Id LIMIT 1];
            ContentVersion cv = [SELECT Id, Title, FileType, LastModifiedDate, ContentSize, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1];
            Assert.isNotNull(cdl.Id, 'ContentDocumentLink should exist');
            Assert.isNotNull(cv.Id, 'ContentVersion should exist');

            Test.startTest();
            delete insertedIpia;
            Test.stopTest();

            List<IPIA_Record__c> insertedIpiaShouldNotExist = [SELECT Id, MitId__c FROM IPIA_Record__c WHERE MitId__c = '912345692'];
            List<ContentDocumentLink> cdlShouldNotExist = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpia.Id];
            List<ContentVersion> cvShouldNotExist = [SELECT Id, Title, FileType, LastModifiedDate, ContentSize, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId];

            Assert.areEqual(0, insertedIpiaShouldNotExist.size(), 'IPIA Record should not exist');
            Assert.areEqual(0, cdlShouldNotExist.size(), 'ContentDocumentLink should not exist');
            Assert.areEqual(0, cvShouldNotExist.size(), 'ContentVersion should not exist');
        }
    }

    // ===============
    // Unit Tests for changing of linked Document Name against IPIA Record
    // ===============
    private static String ipiaSignedDateAsStr(Date signedDate) {
        DateTime dt = DateTime.newInstance(signedDate.year(), signedDate.month(), signedDate.day());

        return dt.format('MM_dd_yyyy', 'Etc/UTC'); // using UTC that is what was used in personIpiaList.js
    }

    @IsTest
    public static void testFileNameChange_OnUpdateIPIARecordMitId() {
        // Only IPIA Admin can update IPIA Records' MIT ID & Effective Dates
        System.runAs(TestUtility.createIpiaAdminUser()) {
            String mitIdOrig = '912345691';
            String mitIdChangeTo = '912345692';

            Date signedDate = Date.newInstance(2023, 3, 13);            
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = mitIdOrig, SignDatetime__c = signedDate);
            insert ipiaRecord;

            IPIA_Record__c insertedIpia = IPIAController.getCurrentIPIARecord(mitIdOrig);
            IPIAController.uploadIPIADocuments(insertedIpia.Id, mitIdOrig + '-Melissa Palmer.pdf', 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=', '');            
            ContentDocumentLink origCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpia.Id LIMIT 1];
            Assert.isNotNull(origCdl.Id, 'origCdl should exist');

            Test.startTest();
                insertedIpia.MitId__c = mitIdChangeTo;
                update insertedIpia;
            Test.stopTest();

            ContentDocumentLink updatedCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpia.Id LIMIT 1];            
            
            System.debug('origCdl.ContentDocument.Title:' + origCdl.ContentDocument.Title);
            System.debug('updatedCdl.ContentDocument.Title:' + updatedCdl.ContentDocument.Title);
            Assert.areNotEqual(origCdl.ContentDocument.Title, updatedCdl.ContentDocument.Title, 'The origCdl document title should have been updated');
            Assert.areEqual(mitIdChangeTo + '-' + ipiaSignedDateAsStr(signedDate) + '.pdf', updatedCdl.ContentDocument.Title, 'The updatedCdl document new title be in format of mitId and effective date');
        }
    }

    @IsTest
    public static void testFileNameChange_OnUpdateIPIARecordEffectiveDate() {
        // Only IPIA Admin can update IPIA Records' MIT ID & Effective Dates
        System.runAs(TestUtility.createIpiaAdminUser()) {
            String mitId = '912345693';
            Date signedDate = Date.newInstance(1998, 12, 21);
            Date signedDateChange = Date.newInstance(2023, 12, 02);

            IPIA_Record__c ipiaRecordTwo = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = mitId, SignDatetime__c = signedDate);
            insert ipiaRecordTwo;
            IPIA_Record__c insertedIpiaTwo = IPIAController.getCurrentIPIARecord(mitId);
            IPIAController.uploadIPIADocuments(insertedIpiaTwo.Id, mitId + '-Keith Palmer.pdf', 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=', '');            
            ContentDocumentLink origCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaTwo.Id LIMIT 1];
            Assert.isNotNull(origCdl.Id, 'origCdl should exist');

            Test.startTest();
                insertedIpiaTwo.SignDatetime__c = signedDateChange;
                update insertedIpiaTwo;
            Test.stopTest();

            ContentDocumentLink updatedCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaTwo.Id LIMIT 1];            
            System.debug('origCdl.ContentDocument.Title:' + origCdl.ContentDocument.Title);
            System.debug('updatedCdl.ContentDocument.Title:' + updatedCdl.ContentDocument.Title);
            Assert.areNotEqual(origCdl.ContentDocument.Title, updatedCdl.ContentDocument.Title, 'The IPIAs document title should have been updated');
            Assert.areEqual(mitId + '-' + ipiaSignedDateAsStr(signedDateChange) + '.pdf', updatedCdl.ContentDocument.Title, 'The IPIAs document new title be in format of mitId and effective date');
        }
    }

    @IsTest
    public static void testNoFileNameChange_OnUpdateIPIARecordFormName() {
        // Only IPIA Admin can update IPIA Records' MIT ID & Effective Dates
        System.runAs(TestUtility.createIpiaAdminUser()) {
            String mitId = '912345694';
            IPIA_Record__c ipiaRecordThree = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = mitId, SignDatetime__c = Date.today().addDays(-23));
            insert ipiaRecordThree;
            IPIA_Record__c insertedIpiaThree = IPIAController.getCurrentIPIARecord(mitId);
            IPIAController.uploadIPIADocuments(insertedIpiaThree.Id, mitId + '-Wendy Palmer.pdf', 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=', '');            
            ContentDocumentLink origCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaThree.Id LIMIT 1];
            Assert.isNotNull(origCdl.Id, 'origCdl should exist');

            Test.startTest();
                insertedIpiaThree.FormName__c = 'No Doc name changes expected';
                update insertedIpiaThree;
            Test.stopTest();

            ContentDocumentLink updatedCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaThree.Id LIMIT 1];            
            System.debug('origCdl.ContentDocument.Title:' + origCdl.ContentDocument.Title);
            System.debug('updatedCdl.ContentDocument.Title:' + updatedCdl.ContentDocument.Title);
            Assert.areEqual(origCdl.ContentDocument.Title, updatedCdl.ContentDocument.Title, 'The IPIAs document title should NOT have been updated');
        }
    }

    @IsTest
    public static void testFileNameChange_OnUpdateIPIARecordThatHasNoLinkedDocs() {
        // Only IPIA Admin can update IPIA Records' MIT ID & Effective Dates
        System.runAs(TestUtility.createIpiaAdminUser()) {
            String mitIdOrig = '912345695';
            String mitIdChange = '912345696';
            IPIA_Record__c ipiaRecord = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = mitIdOrig, SignDatetime__c = Date.today().addDays(-23));
            insert ipiaRecord;
            IPIA_Record__c insertedIpia = IPIAController.getCurrentIPIARecord(mitIdOrig);
            List<ContentDocumentLink> cdlShouldNotExist = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpia.Id];
            Assert.areEqual(0, cdlShouldNotExist.size(), 'ContentDocumentLink should not exist');

            Test.startTest();
                ipiaRecord.MitId__c = mitIdChange;
                update ipiaRecord;
            Test.stopTest();

            List<ContentDocumentLink> cdlAfterChangeShouldNotExist = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpia.Id];
            Assert.areEqual(0, cdlAfterChangeShouldNotExist.size(), 'ContentDocumentLink should not exist');
        }
    }


    //922787214-Arturo D. Pacheco.pdf
    @IsTest
    public static void testFileNameChange_OnUpdateIPIARecordsMultipleSituationsAtOnce() {
        // Only IPIA Admin can update IPIA Records' MIT ID & Effective Dates
        System.runAs(TestUtility.createIpiaAdminUser()) {
            String mitIdOrig = '912345691';
            String mitIdChangeTo = '912345692';
            
            IPIA_Record__c ipiaRecordOne = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = mitIdOrig, SignDatetime__c = Date.today().addDays(-40));
            insert ipiaRecordOne;
            IPIA_Record__c insertedIpiaOne = IPIAController.getCurrentIPIARecord(mitIdOrig);
            IPIAController.uploadIPIADocuments(insertedIpiaOne.id, mitIdOrig + '-Melissa Palmer.pdf', 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=', '');            
            ContentDocumentLink ipiaOneOrigCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaOne.Id LIMIT 1];
            Assert.isNotNull(ipiaOneOrigCdl.Id, 'ipiaOneOrigCdl should exist');

            String mitIdOrigTwo = '912345693';
            Date signedDateChange = Date.today().addDays(-10);
            IPIA_Record__c ipiaRecordTwo = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = mitIdOrigTwo, SignDatetime__c = Date.today().addDays(-23));
            insert ipiaRecordTwo;
            IPIA_Record__c insertedIpiaTwo = IPIAController.getCurrentIPIARecord(mitIdOrigTwo);
            IPIAController.uploadIPIADocuments(insertedIpiaTwo.Id, mitIdOrigTwo + '-Keith Palmer.pdf', 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=', '');            
            ContentDocumentLink ipiaTwoOrigCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaTwo.Id LIMIT 1];
            Assert.isNotNull(ipiaTwoOrigCdl.Id, 'ipiaTwoOrigCdl should exist');


            String mitIdOrigThree = '912345694';
            IPIA_Record__c ipiaRecordThree = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = mitIdOrigThree, SignDatetime__c = Date.today().addDays(-23));
            insert ipiaRecordThree;
            IPIA_Record__c insertedIpiaThree = IPIAController.getCurrentIPIARecord(mitIdOrigThree);
            IPIAController.uploadIPIADocuments(insertedIpiaThree.id, mitIdOrigThree + '-Wendy Palmer.pdf', 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=', '');            
            ContentDocumentLink ipiaThreeOrigCdl = [SELECT ContentDocument.Title, ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaThree.Id LIMIT 1];
            Assert.isNotNull(ipiaThreeOrigCdl.Id, 'ipiaThreeOrigCdl should exist');

            String mitIdOrigFour = '912345695';
            String mitIdChangeFour = '912345696';
            IPIA_Record__c ipiaRecordFour = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = mitIdOrigFour, SignDatetime__c = Date.today().addDays(-23));
            insert ipiaRecordFour;
            IPIA_Record__c insertedIpiaFour = IPIAController.getCurrentIPIARecord(mitIdOrigFour);
            List<ContentDocumentLink> cdlFourShouldNotExist = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaFour.Id];
            Assert.areEqual(0, cdlFourShouldNotExist.size(), 'cdlFourShouldNotExist should not exist');

            Test.startTest();
                insertedIpiaOne.MitId__c = mitIdChangeTo;
                insertedIpiaTwo.SignDatetime__c = signedDateChange;
                insertedIpiaThree.FormName__c = 'No Doc name changes expected';
                ipiaRecordFour.MitId__c = mitIdChangeFour;

                List<IPIA_Record__c> updatesNeeded = new List<IPIA_Record__c> {insertedIpiaOne, insertedIpiaTwo, insertedIpiaThree, ipiaRecordFour};
                update updatesNeeded;
            Test.stopTest();

            ContentDocumentLink ipiaOneUpdatedCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaOne.Id LIMIT 1];
            System.debug('ipiaOneOrigCdl.ContentDocument.Title:' + ipiaOneOrigCdl.ContentDocument.Title);
            System.debug('ipiaOneUpdatedCdl.ContentDocument.Title:' + ipiaOneUpdatedCdl.ContentDocument.Title);
            Assert.areNotEqual(ipiaOneOrigCdl.ContentDocument.Title, ipiaOneUpdatedCdl.ContentDocument.Title, 'The ipiaOneOrigCdl document title should have been updated');
            Assert.areEqual(mitIdChangeTo + '-' + ipiaSignedDateAsStr(insertedIpiaOne.SignDatetime__c) + '.pdf', ipiaOneUpdatedCdl.ContentDocument.Title, 'The ipiaOneUpdatedCdl document new title be in format of mitId and effective date');

            ContentDocumentLink ipiaTwoUpdatedCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaTwo.Id LIMIT 1];            
            System.debug('ipiaTwoOrigCdl.ContentDocument.Title:' + ipiaTwoOrigCdl.ContentDocument.Title);
            System.debug('ipiaTwoUpdatedCdl.ContentDocument.Title:' + ipiaTwoUpdatedCdl.ContentDocument.Title);
            Assert.areNotEqual(ipiaTwoOrigCdl.ContentDocument.Title, ipiaTwoUpdatedCdl.ContentDocument.Title, 'The ipiaTwoOrigCdl document title should have been updated');
            Assert.areEqual(mitIdOrigTwo + '-' + ipiaSignedDateAsStr(signedDateChange) + '.pdf', ipiaTwoUpdatedCdl.ContentDocument.Title, 'The ipiaTwoUpdatedCdl document new title be in format of mitId and effective date');

            ContentDocumentLink ipiaThreeUpdatedCdl = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaThree.Id LIMIT 1];            
            System.debug('ipiaThreeOrigCdl.ContentDocument.Title:' + ipiaThreeOrigCdl.ContentDocument.Title);
            Assert.areEqual(ipiaThreeOrigCdl.ContentDocument.Title, ipiaThreeUpdatedCdl.ContentDocument.Title, 'The ipiaThreeUpdatedCdl document title should NOT have been updated');

            List<ContentDocumentLink> cdlOnIpiaWithNoDcoAfterChangeShouldNotExist = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaFour.Id];
            Assert.areEqual(0, cdlOnIpiaWithNoDcoAfterChangeShouldNotExist.size(), 'cdlOnIpiaWithNoDcoAfterChangeShouldNotExist should not exist');

        }
    }
}