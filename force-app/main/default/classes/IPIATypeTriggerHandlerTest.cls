/**
 * Created by Andreas du Preez on 2024/08/23.
 */

@IsTest
public with sharing class IPIATypeTriggerHandlerTest {
    @IsTest
    public static void testSuccessMultipleIPIATypeInserts() {
        try {
            IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Duplicate IPIA Type 1', Status__c = 'Active');
            IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'Duplicate IPIA Type 2', Status__c = 'Legacy');
            IPIA_Type__c ipiaType3 = new IPIA_Type__c(Name = 'Duplicate IPIA Type 3', Status__c = 'Needs TLO Review');
            insert new List<IPIA_Type__c>{ipiaType1, ipiaType2, ipiaType3};
        }
        catch (Exception e) {
            System.assert(false, 'Should not throw exception');
        }
    }

    @IsTest
    public static void addsErrorWhenIPIATypeNameExistsUnderExemption() {
        IPIA_Type__c existingIPIAType = new IPIA_Type__c(Name = 'Existing IPIA Type', Exemption__c = true, Status__c = 'Active');
        insert existingIPIAType;

        IPIA_Type__c newIPIAType = new IPIA_Type__c(Name = 'Existing IPIA Type', Exemption__c = false);
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            insert newIPIAType;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw exception when IPIA Type Name exists under Exemption');
    }

    @IsTest
    public static void addsErrorWhenIPIATypeNameExistsUnderNonExemption() {
        IPIA_Type__c existingIPIAType = new IPIA_Type__c(Name = 'Existing IPIA Type', Exemption__c = false, Status__c = 'Active');
        insert existingIPIAType;

        IPIA_Type__c newIPIAType = new IPIA_Type__c(Name = 'Existing IPIA Type', Exemption__c = true, Status__c = 'Active');
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            insert newIPIAType;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw exception when IPIA Type Name exists under Non-Exemption');
    }

    @IsTest
    public static void addsErrorWhenIPIATypeNameExistsUnderExemptionAndIsObsolete() {
        IPIA_Type__c existingIPIAType = new IPIA_Type__c(Name = 'Existing IPIA Type', Exemption__c = true, Status__c = 'Needs TLO Review');
        insert existingIPIAType;

        IPIA_Type__c newIPIAType = new IPIA_Type__c(Name = 'Existing IPIA Type', Exemption__c = false);
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            insert newIPIAType;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw exception when IPIA Type Name exists under Exemption');
    }

    @IsTest
    public static void addsErrorWhenDuplicateIPIATypeNameInSameList() {
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Duplicate IPIA Type', Status__c = 'Active');
        IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'Duplicate IPIA Type', Status__c = 'Active');
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            insert new List<IPIA_Type__c>{ipiaType1, ipiaType2};
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw exception when duplicate IPIA Type Name in same list');
    }

    @IsTest
    public static void addsErrorWhenDuplicateIPIATypeNameInSameListUpdate() {
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Duplicate IPIA Type', Status__c = 'Active');
        IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'Duplicate IPIA Type 2', Status__c = 'Active');
        insert new List<IPIA_Type__c> {ipiaType1, ipiaType2};

        ipiaType2.Name = 'Duplicate IPIA Type';
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            update ipiaType2;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw exception when duplicate IPIA Type Name in same list');
    }

    @IsTest
    public static void doesNotAddErrorWhenIPIATypeNameIsUnique() {
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Unique IPIA Type 1', Status__c = 'Active');
        IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'Unique IPIA Type 2', Status__c = 'Active');

        Test.startTest();
        insert new List<IPIA_Type__c>{ipiaType1, ipiaType2};
        Test.stopTest();

        System.assertEquals(0, ipiaType1.getErrors().size(), 'Should not add error for unique IPIA Type 1');
        System.assertEquals(0, ipiaType2.getErrors().size(), 'Should not add error for unique IPIA Type 2');
    }

    @IsTest
    public static void isIPATypesDeletable_withLinkedRecords() {
        IPIA_Type__c ipiaType = new IPIA_Type__c(Name = 'Type1', Status__c = 'Active');
        insert ipiaType;

        IPIA_Record__c ipiaRecord = new IPIA_Record__c(FormName__c = 'Type1', MitId__c ='912345681', SignDatetime__c = Date.today());
        insert ipiaRecord;

        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            delete ipiaType;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw exception when IPIA Type has linked records');
    }

    @IsTest
    public static void isIPATypesDeletable_withoutLinkedRecords() {
        IPIA_Type__c ipiaType = new IPIA_Type__c(Name = 'Type1', Status__c = 'Active');
        insert ipiaType;

        Test.startTest();
        delete ipiaType;
        Test.stopTest();

        List<IPIA_Type__c> deletedIPIAType = [SELECT Id FROM IPIA_Type__c WHERE Id = :ipiaType.Id];
        System.assertEquals(0, deletedIPIAType.size());
    }

    @IsTest
    public static void isIPATypesDeletable_multipleIPIATypeRecords() {
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Type1', Status__c = 'Active');
        IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'Type2', Status__c = 'Active');
        insert new List<IPIA_Type__c>{ipiaType1, ipiaType2};

        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(IPIA_Type__c = ipiaType1.Id, MitId__c = '912345681', SignDatetime__c = System.today());
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(IPIA_Type__c = ipiaType2.Id, MitId__c = '912345681', SignDatetime__c = System.today());
        insert new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2};

        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            delete new List<IPIA_Type__c>{ipiaType1, ipiaType2};
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw exception when IPIA Type has linked records');
    }

    @IsTest
    public static void testDeleteIPIAType_ContentDocument(){
        String fileName = 'Test File';
        String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';

        IPIA_Type__c ipiaType = new IPIA_Type__c(Name = 'Test IPIA Type', Description__c = 'Test Description', Status__c = 'Active');
        IPIA_Type__c insertedIpiaType = IPIAController.createIPIAType(ipiaType, fileName, fileBase64);

        IPIA_Type__c ipiaTypeShouldExist = [SELECT Id, Description__c, Status__c FROM IPIA_Type__c WHERE Name = 'Test IPIA Type' LIMIT 1];
        ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ipiaTypeShouldExist.Id LIMIT 1];
        ContentVersion cv = [SELECT Id, Title, FileType, LastModifiedDate, ContentSize, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1];

        Assert.isNotNull(cdl.Id, 'ContentDocumentLink should exist');
        Assert.isNotNull(cv.Id, 'ContentVersion should exist');

        Test.startTest();
        delete ipiaTypeShouldExist;
        Test.stopTest();

        List<IPIA_Type__c> ipiaTypeShouldNotExist = [SELECT Id, Description__c, Status__c FROM IPIA_Type__c WHERE Name = 'Test IPIA Type'];
        List<ContentDocumentLink> cdlShouldNotExist = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :insertedIpiaType.Id];
        List<ContentVersion> cvShouldNotExist = [SELECT Id, Title, FileType, LastModifiedDate, ContentSize, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId];

        Assert.areEqual(0, ipiaTypeShouldNotExist.size(), 'IPIA Type should not exist');
        Assert.areEqual(0, cdlShouldNotExist.size(), 'ContentDocumentLink should not exist');
        Assert.areEqual(0, cvShouldNotExist.size(), 'ContentVersion should not exist');
    }
}