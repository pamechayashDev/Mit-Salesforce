/**
 * Created by Andreas du Preez on 2024/09/23.
 */

@IsTest
public with sharing class ContentDocumentTriggerHandlerTest {

    @IsTest
    public static void preventsDeletionOfIPIATypeTemplateLinkedToIPIAType() {
        String ipiaTypeName = 'Test IPIA Type';
        String ipiaTypeDescription = 'Test Description';
        String ipiaStatus = 'Active';
        String fileName = 'Test File';
        String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';

        IPIA_Type__c ipiaType = new IPIA_Type__c(Name = ipiaTypeName, Description__c = ipiaTypeDescription, Status__c = ipiaStatus);
        IPIA_Type__c result = IPIAController.createIPIAType(ipiaType, fileName, fileBase64);

        ContentDocumentLink contentDocumentLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :result.Id];
        ContentDocument contentDocumentToDelete = new ContentDocument(Id = contentDocumentLink.ContentDocumentId);

        Test.startTest();
        try {
            delete contentDocumentToDelete;
            System.assert(false, 'Expected DMLException was not thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains(Label.IPIA_Type_Template_Delete_Error), 'Expected error message not found');
        }
        Test.stopTest();
    }

    @IsTest
    public static void allowsDeletionOfContentDocumentNotLinkedToIPIAType() {
        String fileName = 'Test File';
        String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';

        Id otherContentVersionRecordType = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Other_Agreement').getRecordTypeId();

        ContentVersion version = new ContentVersion(
                Title = fileName,
                PathOnClient = fileName,
                Document_Classification__c = 'Original_Document',
                VersionData = EncodingUtil.base64Decode(String.valueOf(fileBase64)),
                RecordTypeId = otherContentVersionRecordType,
                IsMajorVersion = false
        );
        insert version;

        ContentVersion insertedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :version.Id];
        ContentDocument contentDocumentToDelete = new ContentDocument(Id = insertedContentVersion.ContentDocumentId);

        Test.startTest();
        delete contentDocumentToDelete;
        Test.stopTest();

        List<ContentDocument> deletedDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentToDelete.Id];
        System.assertEquals(0, deletedDocument.size(), 'ContentDocument should be deleted');
    }

    @IsTest
    public static void allowsDeletionOfContentDocumentWithNoLinks() {
        String fileName = 'Test File';
        String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';

        Id ipiaContentVersionRecordType = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('IPIA_Type_Template').getRecordTypeId();

        ContentVersion version = new ContentVersion(
                Title = fileName,
                PathOnClient = fileName,
                Document_Classification__c = 'IPIA_Type_Template',
                VersionData = EncodingUtil.base64Decode(String.valueOf(fileBase64)),
                RecordTypeId = ipiaContentVersionRecordType,
                IsMajorVersion = false
        );
        insert version;

        ContentVersion insertedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :version.Id];
        ContentDocument contentDocumentToDelete = new ContentDocument(Id = insertedContentVersion.ContentDocumentId);

        Test.startTest();
        delete contentDocumentToDelete;
        Test.stopTest();

        List<ContentDocument> deletedDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentToDelete.Id];
        System.assertEquals(0, deletedDocument.size(), 'ContentDocument should be deleted');
    }

    // =======================================================
    // TESTS FOR:- 
    //      Prevent deletion of IPIA ContentDocument if it is linked to an IPIA_Record that has DocuSign meta data against it
    // =======================================================
    @IsTest
    public static void preventsDeletionOfIPIADocLinkedToIPIARecordWithDocuSignMetaData() {
        String fileName = 'Test File';
        String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';

        IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = '912345456', FormName__c = 'Test Form', 
                                                       DocusignTemplate__c = '390847530986738957', DocusignEnvelopeId__c = '23498723984');
        IPIA_Record__c resultIpiaRecord = IPIAController.createIPIARecord(ipiaRecord);
        IPIAController.uploadIPIADocuments(resultIpiaRecord.Id, fileName, fileBase64, '');

        ContentDocumentLink contentDocumentLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId = :resultIpiaRecord.Id];
        ContentDocument contentDocumentToDelete = new ContentDocument(Id = contentDocumentLink.ContentDocumentId);

        Test.startTest();
        try {
            delete contentDocumentToDelete;
            System.assert(false, 'Expected DMLException was not thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains(Label.IPIA_Record_Delete_DocuSignDoc_Error), 'Expected error message not found');
        }
        Test.stopTest();
    }

    @IsTest
    public static void allowsDeletionOfIPIADocLinkedToIPIARecordWithoutDocuSignMetaData() {
        String fileName = 'Test File';
        String fileBase64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBiYXNlNjQ=';

        IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = '912345456', FormName__c = 'Test Form');
        IPIA_Record__c resultIpiaRecord = IPIAController.createIPIARecord(ipiaRecord);
        IPIAController.uploadIPIADocuments(resultIpiaRecord.Id, fileName, fileBase64, '');

        ContentDocumentLink contentDocumentLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId = :resultIpiaRecord.Id];
        ContentDocument contentDocumentToDelete = new ContentDocument(Id = contentDocumentLink.ContentDocumentId);

        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            delete contentDocumentToDelete;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(!exceptionThrown, 'Should NOT throw exception when no DocuSign meta data for linked IPIA Record');
        List<ContentDocument> deletedDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentToDelete.Id];
        System.assertEquals(0, deletedDocument.size(), 'ContentDocument should be deleted');
    }
}