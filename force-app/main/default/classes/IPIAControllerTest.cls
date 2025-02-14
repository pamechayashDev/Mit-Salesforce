/**
 * Created by Andreas du Preez on 2024/07/29.
 */

@IsTest
public with sharing class IPIAControllerTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @IsTest
    public static void returnsTrueWhenUserHasCreatePermission() {
        Test.startTest();
        Boolean result = IPIAController.userHasIPIARecordCreatePermission();
        Test.stopTest();

        Assert.isTrue(result, 'Should return true when user has create permission');
    }

    @IsTest
    static void returnsTrueWhenUserHasIPIATypeCreatePermission() {
        Test.startTest();
        Boolean result = IPIAController.userHasIPIATypeCreatePermission();
        Test.stopTest();

        System.assert(result, 'Should return true when user has create permission for IPIA Type');
    }

    @IsTest
    public static void testCreateIPIAType() {
        String ipiaTypeName = 'Test IPIA Type';
        String ipiaTypeDescription = 'Test Description';
        String ipiaStatus = 'Active';
        String fileName = 'Test File';
        String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';

        IPIA_Type__c ipiaType = new IPIA_Type__c(Name = ipiaTypeName, Description__c = ipiaTypeDescription, Status__c = ipiaStatus);

        Test.startTest();
        IPIA_Type__c result = IPIAController.createIPIAType(ipiaType, fileName, fileBase64);
        ContentVersion contentVersionResult = IPIAController.getIPIATypeTemplate(ipiaType.Id);
        Test.stopTest();

        IPIA_Type__c ipiaTypeShouldExist = [SELECT Id, Description__c, Status__c FROM IPIA_Type__c WHERE Name = 'Test IPIA Type' LIMIT 1];
        ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ipiaTypeShouldExist.Id LIMIT 1];
        ContentVersion cv = [SELECT Id, Title, FileType, LastModifiedDate, ContentSize, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1];

        Assert.isNotNull(result.Id, 'Controller method should return true');
        Assert.areEqual(ipiaTypeDescription, ipiaTypeShouldExist.Description__c, 'Description does not matched inserted value');
        Assert.areEqual(ipiaStatus, ipiaTypeShouldExist.Status__c, 'Status does not matched inserted value');
        Assert.areEqual(EncodingUtil.base64Encode(cv.VersionData), fileBase64, 'Content does not matched inserted value');
        Assert.isNotNull(contentVersionResult.Id, 'ContentVersion should exist');
    }

    @IsTest
    public static void testCreateIPIATypeNoData() {
        String fileName = 'Test File';
        String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            IPIAController.createIPIAType(null, fileName, fileBase64);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Should throw exception when no data is provided');
    }


    @IsTest
    public static void returnsCurrentAndHistoricIPIARecordsWithValidMitId() {
        String mitId = '912345673';
        IPIA_Record__c currentIPIA = new IPIA_Record__c(MitId__c = mitId, FormName__c = 'Current Form', SignDatetime__c = Date.today().addDays(-1));
        insert currentIPIA;

        IPIA_Record__c historicIPIA1 = new IPIA_Record__c(MitId__c = mitId, FormName__c = 'Historic Form 1', SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c historicIPIA2 = new IPIA_Record__c(MitId__c = mitId, FormName__c = 'Historic Form 2', SignDatetime__c = Date.today().addDays(-3));
        insert new List<IPIA_Record__c>{historicIPIA1, historicIPIA2};

        Test.startTest();
        IPIAController.CurrentHistoricIPIARecords result = IPIAController.getIPIARecords(mitId);
        Test.stopTest();

        Assert.isNotNull(result.currentIPIARecord, 'Current IPIA should not be null');
        Assert.areEqual(2, result.historicIPIARecords.size(), 'Should return 2 historic IPIA records');
    }

    @IsTest
    public static void getIPIARecordsWithHasDoc() {
        String mitId = '912345673';
        IPIA_Record__c currentIPIA = new IPIA_Record__c(MitId__c = mitId, FormName__c = 'Current Form', SignDatetime__c = Date.today().addDays(-1));
        insert currentIPIA;

        IPIA_Record__c historicIPIA1 = new IPIA_Record__c(MitId__c = mitId, FormName__c = 'Historic Form 1', SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c historicIPIA2 = new IPIA_Record__c(MitId__c = mitId, FormName__c = 'Historic Form 2', SignDatetime__c = Date.today().addDays(-3));
        insert new List<IPIA_Record__c>{historicIPIA1, historicIPIA2};

        Test.startTest();
        IPIAController.CurrentHistoricIPIARecords result = IPIAController.getIPIARecords(mitId);

        IPIAController.uploadIPIADocuments(result.currentIPIARecord.id, 'Test File 1', 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=', '');
        IPIAController.uploadIPIADocuments(result.historicIPIARecords[1].id, 'Test File 2', 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=', '');

        IPIAController.CurrentHistoricIPIARecords resultWithDocs = IPIAController.getIPIARecords(mitId);
        Test.stopTest();

        Assert.isNotNull(result.currentIPIARecord, 'Current IPIA should not be null');
        Assert.areEqual(2, result.historicIPIARecords.size(), 'Should return 2 historic IPIA records');

        Assert.areEqual(false, resultWithDocs.currentIPIARecord.ContentDocumentLinks.isEmpty(), 'Current IPIA record, should have linked doc');
        Assert.areEqual(true , resultWithDocs.historicIPIARecords[0].ContentDocumentLinks.isEmpty(), '1st historic IPIA records, should NOT have linked doc');
        Assert.areEqual(false, resultWithDocs.historicIPIARecords[1].ContentDocumentLinks.isEmpty(), '2nd historic IPIA records, should have linked doc');
    }

    @IsTest
    public static void returnsEmptyHistoricIPIARecordsWithValidMitIdAndNoHistoricRecords() {
        String mitId = '912345673';
        IPIA_Record__c currentIPIA = new IPIA_Record__c(MitId__c = mitId, FormName__c = 'Current Form', SignDatetime__c = Date.today().addDays(-1));
        insert currentIPIA;

        Test.startTest();
        IPIAController.CurrentHistoricIPIARecords result = IPIAController.getIPIARecords(mitId);
        Test.stopTest();

        Assert.isNotNull(result.currentIPIARecord, 'Current IPIA should not be null');
        Assert.areEqual(0, result.historicIPIARecords.size(), 'Should return 0 historic IPIA records');
    }

    @IsTest
    public static void returnsEmptyCurrentAndHistoricIPIARecordsWithInvalidMitId() {
        String mitId = 'invalid_mit_id';

        Test.startTest();
        IPIAController.CurrentHistoricIPIARecords result = IPIAController.getIPIARecords(mitId);
        Test.stopTest();

        Assert.isNull(result.currentIPIARecord, 'Current IPIA should be null');
        Assert.areEqual(0, result.historicIPIARecords.size(), 'Should return 0 historic IPIA records');
    }

    @IsTest
    public static void returnsEmptyCurrentAndHistoricIPIARecordsWithBlankMitId() {
        String mitId = '';

        Test.startTest();
        IPIAController.CurrentHistoricIPIARecords result = IPIAController.getIPIARecords(mitId);
        Test.stopTest();

        Assert.isNull(result.currentIPIARecord, 'Current IPIA should be null');
        Assert.areEqual(0, result.historicIPIARecords.size(), 'Should return 0 historic IPIA records');
    }

    @IsTest
    public static void returnsCurrentIPIARecordWithValidMitId() {
        String mitId = '912345673';
        IPIA_Record__c currentIPIA = new IPIA_Record__c(MitId__c = mitId, FormName__c = 'Current Form', SignDatetime__c = Date.today().addDays(-1));
        insert currentIPIA;

        Test.startTest();
        IPIA_Record__c result = IPIAController.getCurrentIPIARecord(mitId);
        Test.stopTest();

        Assert.isNotNull(result, 'Current IPIA should not be null');
        Assert.areEqual(mitId, result.MitId__c, 'MitId should match');
    }

    @IsTest
    public static void returnsNullForInvalidMitId() {
        String mitId = 'invalid_mit_id';

        Test.startTest();
        IPIA_Record__c result = IPIAController.getCurrentIPIARecord(mitId);
        Test.stopTest();

        Assert.isNull(result, 'Current IPIA should be null');
    }

    @IsTest
    public static void returnsNullForBlankMitId() {
        String mitId = '';

        Test.startTest();
        IPIA_Record__c result = IPIAController.getCurrentIPIARecord(mitId);
        Test.stopTest();

        Assert.isNull(result, 'Current IPIA should be null');
    }

    @IsTest
    public static void returnsNullWhenNoCurrentIPIARecordExists() {
        String mitId = '912345673';

        Test.startTest();
        IPIA_Record__c result = IPIAController.getCurrentIPIARecord(mitId);
        Test.stopTest();

        Assert.isNull(result, 'Current IPIA should be null');
    }


    @IsTest
    public static void createsIPIARecordSuccessfully() {
        IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = '912345673', FormName__c = 'Test Form');

        Test.startTest();
        IPIA_Record__c result = IPIAController.createIPIARecord(ipiaRecord);
        Test.stopTest();

        IPIA_Record__c insertedRecord = [SELECT Id, MitId__c, FormName__c FROM IPIA_Record__c WHERE Id = :result.Id LIMIT 1];
        Assert.isNotNull(insertedRecord, 'IPIA Record should be inserted');
        Assert.areEqual('912345673', insertedRecord.MitId__c, 'MitId should match');
        Assert.areEqual('Test Form', insertedRecord.FormName__c, 'FormName should match');
    }

    @IsTest
    public static void throwsExceptionWhenIPIARecordIsNull() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            IPIAController.createIPIARecord(null);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Exception should be thrown when IPIA Record is null');
    }

    @IsTest
    public static void throwsExceptionWhenMitIdIsNull() {
        IPIA_Record__c ipiaRecord = new IPIA_Record__c(FormName__c = 'Test Form');
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            IPIAController.createIPIARecord(ipiaRecord);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Exception should be thrown when MitId is null');
    }

    @IsTest
    public static void throwsExceptionWhenFormNameIsNull() {
        IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = '912345673');
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            IPIAController.createIPIARecord(ipiaRecord);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();


        Assert.isTrue(exceptionThrown, 'Exception should be thrown when FormName is null');
    }

    @IsTest
    public static void returnsIPIATypesWithExemption() {
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'IPIA Type 1', Exemption__c = true, Status__c = 'Active');
        IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'IPIA Type 2', Exemption__c = true, Status__c = 'Legacy');
        IPIA_Type__c ipiaType3 = new IPIA_Type__c(Name = 'IPIA Type 3', Exemption__c = true, Status__c = 'Needs TLO Review');
        insert new List<IPIA_Type__c>{ipiaType1, ipiaType2, ipiaType3};

        Test.startTest();
        List<IPIA_Type__c> result = IPIAController.getAllIPIATypes(true);
        Test.stopTest();

        Assert.areEqual(3, result.size(), 'Should return 3 current IPIA Types with exemption');
    }

    @IsTest
    public static void returnsIPIATypesWithMixedExemption() {
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Non-Exemption IPIA Type 1', Exemption__c = false, Status__c = 'Active');
        IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'Non-Exemption IPIA Type 2', Exemption__c = false, Status__c = 'Active');
        IPIA_Type__c ipiaType3 = new IPIA_Type__c(Name = 'IPIA Type 3', Exemption__c = true, Status__c = 'Active');
        IPIA_Type__c ipiaType4 = new IPIA_Type__c(Name = 'IPIA Type 4', Exemption__c = true, Status__c = 'Active');
        IPIA_Type__c ipiaType5 = new IPIA_Type__c(Name = 'IPIA Type 5', Exemption__c = true, Status__c = 'Active');
        insert new List<IPIA_Type__c>{ipiaType1, ipiaType2, ipiaType3, ipiaType4, ipiaType5};

        Test.startTest();
        List<IPIA_Type__c> nonExceptionTypes = IPIAController.getAllIPIATypes(false);
        List<IPIA_Type__c> exceptionTypes = IPIAController.getAllIPIATypes(true);        
        Test.stopTest();

        Assert.areEqual(2, nonExceptionTypes.size(), 'Should return 2 IPIA Types without exemption');
        Assert.isTrue(nonExceptionTypes[0].Name.contains('Non-Exemption'), 'First result should NOT be an Exemption IPIA Type');
        Assert.isTrue(nonExceptionTypes[1].Name.contains('Non-Exemption'), 'Second result should NOT be an Exemption IPIA Type');

        Assert.areEqual(3, exceptionTypes.size(), 'Should return 3 IPIA Types with exemption');
        Assert.isTrue(!exceptionTypes[0].Name.contains('Non-Exemption'), 'First result should be an Exemption IPIA Type');
        Assert.isTrue(!exceptionTypes[1].Name.contains('Non-Exemption'), 'Second result should be an Exemption IPIA Type');
        Assert.isTrue(!exceptionTypes[2].Name.contains('Non-Exemption'), '3rd result should be an Exemption IPIA Type');
    }

    @IsTest
    public static void returnsIPIATypesWithMixedExemptionAndTypeStatus() {
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'Non-Exemption IPIA Type 1', Exemption__c = false, Status__c = 'Active');
        IPIA_Type__c ipiaType2 = new IPIA_Type__c(Name = 'Non-Exemption IPIA Type 2', Exemption__c = false, Status__c = 'Legacy');
        IPIA_Type__c ipiaType2a = new IPIA_Type__c(Name = 'Non-Exemption IPIA Type 3', Exemption__c = false, Status__c = 'Needs TLO Review');
        IPIA_Type__c ipiaType3 = new IPIA_Type__c(Name = 'IPIA Type 3', Exemption__c = true, Status__c = 'Active');
        IPIA_Type__c ipiaType4 = new IPIA_Type__c(Name = 'IPIA Type 4', Exemption__c = true, Status__c = 'Legacy');
        IPIA_Type__c ipiaType5 = new IPIA_Type__c(Name = 'IPIA Type 5', Exemption__c = true, Status__c = 'Needs TLO Review');
        insert new List<IPIA_Type__c>{ipiaType1, ipiaType2, ipiaType2a, ipiaType3, ipiaType4, ipiaType5};

        Test.startTest();
        List<IPIA_Type__c> nonExceptionTypes = IPIAController.getAllIPIATypes(false);
        List<IPIA_Type__c> exceptionTypes = IPIAController.getAllIPIATypes(true);        
        Test.stopTest();

        // non Exemption tests
        Assert.areEqual(3, nonExceptionTypes.size(), 'Should return 3 IPIA Types without exemption');
        Assert.areEqual('Active', nonExceptionTypes[0].Status__c, 'First result should status Active');
        Assert.areEqual('Legacy', nonExceptionTypes[1].Status__c, 'Second result should status Legacy');
        Assert.areEqual('Needs TLO Review', nonExceptionTypes[2].Status__c, '3rd result should status Needs TLO Review');
        Assert.isFalse(nonExceptionTypes[0].Exemption__c, 'First result should not be Exemption');
        Assert.isFalse(nonExceptionTypes[1].Exemption__c, 'Second result should not be Exemption');
        Assert.isFalse(nonExceptionTypes[2].Exemption__c, '3rd result should not be Exemption');

        // Exemption tests
        Assert.areEqual(3, exceptionTypes.size(), 'Should return 3 IPIA Types with exemption');
        Assert.areEqual('Active', exceptionTypes[0].Status__c, 'First result should status Active');
        Assert.areEqual('Legacy', exceptionTypes[1].Status__c, 'Second result should status Legacy');
        Assert.areEqual('Needs TLO Review', exceptionTypes[2].Status__c, '3rd result should status Needs TLO Review');
        Assert.isTrue(exceptionTypes[0].Exemption__c, 'First result should be Exemption');
        Assert.isTrue(exceptionTypes[1].Exemption__c, 'Second result should be Exemption');
        Assert.isTrue(exceptionTypes[2].Exemption__c, '3rd result should not Exemption');
    }

    @IsTest
    public static void testUploadIPIADocuments() {
        String ipiaTypeName = 'Test IPIA Type';
        String ipiaTypeDescription = 'Test Description';
        String ipiaStatus = 'Active';
        String fileName = 'Test File';
        String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';

        IPIA_Type__c ipiaType = new IPIA_Type__c(Name = ipiaTypeName, Description__c = ipiaTypeDescription, Status__c = ipiaStatus);
        insert ipiaType;

        Test.startTest();
        Id result = IPIAController.uploadIPIADocuments(ipiaType.Id, fileName, fileBase64, '');
        IPIAController.deleteFile(result);
        Test.stopTest();

        ContentVersion [] cvList = [SELECT Id, Title, FileType, LastModifiedDate, ContentSize, ContentDocumentId, VersionData FROM ContentVersion WHERE Id = :result LIMIT 1];
        Assert.isNotNull(result, 'Controller method should return true');
        Assert.isNotNull(cvList, 'Controller method should return true');
    }


    @IsTest
    public static void getUnlinkedIpiaDocs() {
        String mitId = '923583401';
        
        String classification = 'Original_Document';
        String entitySubType = 'IPIA';
        String recordType='IPIA';
        String subTypeClassification = classification;
        String fileName = '923583401-MarlaD.pdf';

        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        String pdfFileContent = 'JVBERi0xLjYKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0ZpbHRlci9GbGF0ZURlY29kZT4+CnN0cmVhbQp4nDPQM1Qo5ypUMFAw0DMwslAwtTTVMzI3VbAwMdSzMDNUKErlCtdSyOMKVAAAtxIIrgplbmRzdHJlYW0KZW5kb2JqCgozIDAgb2JqCjUwCmVuZG9iagoKNSAwIG9iago8PAo+PgplbmRvYmoKCjYgMCBvYmoKPDwvRm9udCA1IDAgUgovUHJvY1NldFsvUERGL1RleHRdCj4+CmVuZG9iagoKMSAwIG9iago8PC9UeXBlL1BhZ2UvUGFyZW50IDQgMCBSL1Jlc291cmNlcyA2IDAgUi9NZWRpYUJveFswIDAgNTk1LjMwMzkzNzAwNzg3NCA4NDEuODg5NzYzNzc5NTI4XS9Hcm91cDw8L1MvVHJhbnNwYXJlbmN5L0NTL0RldmljZVJHQi9JIHRydWU+Pi9Db250ZW50cyAyIDAgUj4+CmVuZG9iagoKNCAwIG9iago8PC9UeXBlL1BhZ2VzCi9SZXNvdXJjZXMgNiAwIFIKL01lZGlhQm94WyAwIDAgNTk1LjMwMzkzNzAwNzg3NCA4NDEuODg5NzYzNzc5NTI4IF0KL0tpZHNbIDEgMCBSIF0KL0NvdW50IDE+PgplbmRvYmoKCjcgMCBvYmoKPDwvVHlwZS9DYXRhbG9nL1BhZ2VzIDQgMCBSCi9PcGVuQWN0aW9uWzEgMCBSIC9YWVogbnVsbCBudWxsIDBdCi9MYW5nKGVuLVpBKQo+PgplbmRvYmoKCjggMCBvYmoKPDwvQ3JlYXRvcjxGRUZGMDA1NzAwNzIwMDY5MDA3NDAwNjUwMDcyPgovUHJvZHVjZXI8RkVGRjAwNEMwMDY5MDA2MjAwNzIwMDY1MDA0RjAwNjYwMDY2MDA2OTAwNjMwMDY1MDAyMDAwMzcwMDJFMDAzMz4KL0NyZWF0aW9uRGF0ZShEOjIwMjQwMjIxMTQ0NjQyKzAyJzAwJyk+PgplbmRvYmoKCnhyZWYKMCA5CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDIzNCAwMDAwMCBuIAowMDAwMDAwMDE5IDAwMDAwIG4gCjAwMDAwMDAxNDAgMDAwMDAgbiAKMDAwMDAwMDQwMiAwMDAwMCBuIAowMDAwMDAwMTU5IDAwMDAwIG4gCjAwMDAwMDAxODEgMDAwMDAgbiAKMDAwMDAwMDUyNiAwMDAwMCBuIAowMDAwMDAwNjIyIDAwMDAwIG4gCnRyYWlsZXIKPDwvU2l6ZSA5L1Jvb3QgNyAwIFIKL0luZm8gOCAwIFIKL0lEIFsgPEZCRkE4QzUzMzU4NjBDRTUzNzMwMTJEMUY4MzI0RDdCPgo8RkJGQThDNTMzNTg2MENFNTM3MzAxMkQxRjgzMjREN0I+IF0KL0RvY0NoZWNrc3VtIC9DQ0UzRjIzOUVDMjUyMTFFMzAwNDU2NTVBNTFGMURDRAo+PgpzdGFydHhyZWYKNzk2CiUlRU9GCg==';
        ContentVersion conVer = new ContentVersion();
        conVer.Title = 'Test 1 ' + fileName; // Display name of the files
        conVer.Description = 'MitId: '+mitId+' ContactId: 103957 FileWriteDate: 2024/05/30 00:00:00';
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
        conVer.RecordTypeId = recordTypeId;
        conVer.Document_Classification__c = subTypeClassification;
        conVer.Entity_Sub_Type__c = entitySubType;
        conVer.VersionData = EncodingUtil.base64Decode(pdfFileContent);
        conVer.Entity_RecId__c = '-1'; // '-1' will trigger linking
        conVer.TagCsv = String.valueOf(mitId);
        insert conVer; 

        ContentVersion conVer2 = new ContentVersion();
        conVer2.Title = 'Test 2 ' + fileName; // Display name of the files
        conVer2.Description = 'MitId: '+mitId+' ContactId: 103957 FileWriteDate: 2023/05/30 00:00:00';
        conVer2.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer2.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
        conVer2.RecordTypeId = recordTypeId;
        conVer2.Document_Classification__c = subTypeClassification;
        conVer2.Entity_Sub_Type__c = entitySubType;
        conVer2.VersionData = EncodingUtil.base64Decode(pdfFileContent);
        conVer2.Entity_RecId__c = mitId; // '-1' will trigger linking
        conVer2.TagCsv = String.valueOf(mitId);
        insert conVer2; 

        Test.startTest();
            List<ContentVersion> result = IPIAController.getUnlinkedDocuments(mitId);
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Should return 1 unlinked document for this mitId');
    }
}