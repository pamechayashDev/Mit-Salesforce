@isTest
public with sharing class CRDRDocumentUploadJobTest {
    
    @TestSetup
    static void makeData(){
        TestSetup.defaultConfiguration();
    }
    

   @isTest
   public static void testCRDRUploadDraftEvent() {
        String caseCrdrId = '1574340';
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '5783HGQJ';
        crdr.ExternalCaseCRDRId__c = caseCrdrId;
        crdr.Status__c = 'WAITING_DRAFT';
        insert crdr;
        String fileName = '4906435-Jackson-5783HGQJ LLC-Nestor Franco.pdf';
        String pathOnClient = '/2024\\' + fileName;

        List<Forrester_SHIR_CRDR_VIEW__x > mockRecords = new List<Forrester_SHIR_CRDR_VIEW__x >();
        Forrester_SHIR_CRDR_VIEW__x mockRecord = new Forrester_SHIR_CRDR_VIEW__x();
        mockRecord.CASE_CRDR_RECID__c = '1574340' ;
        mockRecord.CASE_NO_SUFFIX__c = '5783';
        mockRecord.FY__c = '2024';
        mockRecords.add(mockRecord);

        List<Forrester_SHIR_CASE_CRDR_STATUS__x> mockStatusRecords = new List<Forrester_SHIR_CASE_CRDR_STATUS__x>();
        Forrester_SHIR_CASE_CRDR_STATUS__x mockStatusRecord = new Forrester_SHIR_CASE_CRDR_STATUS__x();
        mockStatusRecord.CASE_CRDR_RECID__c = '1574340';
        mockStatusRecord.CRDR_STATUS__c = 'WAITING_DRAFT';
        mockStatusRecords.add(mockStatusRecord);

        StackExternalMock crdrExternalMock = new StackExternalMock();
        crdrExternalMock.push(mockStatusRecords);
        crdrExternalMock.push(mockRecords);

        ExternalObjectQuery.setMock(crdrExternalMock);
        

        Test.startTest();
            String entityRecId = '-1'; //Flag Special Dataloader ContentVersion
            ContentVersion cv = FileRepositoryTest.insertEntityRecIdFile('CRDR', ContentVersionClassification.Draft_CRDR, pathOnClient, fileName, entityRecId) ;
        Test.stopTest();

        List<ContentDocumentLink> cdl =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: crdr.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :cv.Id )];

        System.assert(cdl.isEmpty() == false, 'Expecting ContentDocumentLink Created');
    }

    @isTest
    public static void testCRDRUploadFinalizedEvent() {
        String caseCrdrId = '1574340';
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '5783HGQJ';
        crdr.ExternalCaseCRDRId__c = caseCrdrId;
        crdr.Status__c = 'IN_REVIEW';
        insert crdr;
        String fileName = '4906435-Jackson-5783HGQJ LLC-Nestor Franco.pdf';
        String pathOnClient = '/2024\\' + fileName;

        List<Forrester_SHIR_CRDR_VIEW__x > mockRecords = new List<Forrester_SHIR_CRDR_VIEW__x >();
        Forrester_SHIR_CRDR_VIEW__x mockRecord = new Forrester_SHIR_CRDR_VIEW__x();
        mockRecord.CASE_CRDR_RECID__c = '1574340' ;
        mockRecord.CASE_NO_SUFFIX__c = '5783';
        mockRecord.FY__c = '2024';
        mockRecords.add(mockRecord);

        List<Forrester_SHIR_CASE_CRDR_STATUS__x> mockStatusRecords = new List<Forrester_SHIR_CASE_CRDR_STATUS__x>();
        Forrester_SHIR_CASE_CRDR_STATUS__x mockStatusRecord = new Forrester_SHIR_CASE_CRDR_STATUS__x();
        mockStatusRecord.CASE_CRDR_RECID__c = '1574340';
        mockStatusRecord.CRDR_STATUS__c = 'IN_REVIEW';
        mockStatusRecords.add(mockStatusRecord);

        StackExternalMock crdrExternalMock = new StackExternalMock();
        crdrExternalMock.push(mockStatusRecords);
        crdrExternalMock.push(mockRecords);

        ExternalObjectQuery.setMock(crdrExternalMock);

        Test.startTest();
            String entityRecId = '-1'; //Flag Special Dataloader ContentVersion
            ContentVersion cv = FileRepositoryTest.insertEntityRecIdFile('CRDR', ContentVersionClassification.Finalised_CRDR, pathOnClient, fileName, entityRecId) ;
        Test.stopTest();

        List<ContentDocumentLink> cdl =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: crdr.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :cv.Id )];

       System.assert(cdl.isEmpty() == false, 'Expecting ContentDocumentLink Created');
    }



}