@isTest
public with sharing class DocumentGenerationServiceTest {

    @TestSetup
    static void setupTestData() {
        TestSetup.defaultConfiguration();

        SampleDataFactory.createStyleDocumentTemplate();
        SampleDataFactory.createCrdrCoverPageDocumentTemplate();
    }


    @IsTest
    static void testCreateCrdrNotes() {
        DocuSignApiMock docuSignApiMock = new DocuSignApiMock();
        Test.setMock(HttpCalloutMock.class, docuSignApiMock);

        Case_CRDR__C crdr = new Case_CRDR__c();
        crdr.ExternalCaseCRDRId__c = '12334';
        crdr.Name = 'Unit Test CRDR';
        insert crdr;

        ContentVersion note = new ContentVersion(
            Title = 'Test Note',
            VersionData = Blob.valueOf(EncodingUtil.base64Encode(Blob.valueOf('Test Content'))),
            Note_level__c='Level A'
        );
        CreateNoteRecord.createRecord(note, crdr.Id);

        List<Forrester_SHIR_CRDR_VIEW__x> mockRecords = new List<Forrester_SHIR_CRDR_VIEW__x>();
        Forrester_SHIR_CRDR_VIEW__x mockRecord = new Forrester_SHIR_CRDR_VIEW__x();
        mockRecord.CASE_CRDR_RECID__c = '12334';
        mockRecord.FY__c = '2023';
        mockRecord.Id = TestUtility.getFakeId(Forrester_SHIR_CRDR_VIEW__x.sObjectType);
        mockRecords.add(mockRecord);

        ExternalObjectQuery.setMock(new CrdrViewExternalMock(mockRecords));

        Test.startTest();
         String pdf = DocumentGenerationService.getCrdrNotesPdfFileAsBase64String(mockRecord.Id);
         System.assert(pdf != null, 'CrdrNotes not created');
        Test.stopTest();

    }

}