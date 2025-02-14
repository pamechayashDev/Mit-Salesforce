@isTest
public with sharing class CreateDocumentLinkJobTest {
    

    @TestSetup
    static void makeData(){
        TestSetup.defaultConfiguration();
    }
 
   @isTest
   public static void testCRDRFileDefinitionParser() {
       CreateDocumentLinkJob job = new CreateDocumentLinkJob();

       String pathOnClient = '/2023\\4916739-Skyline Therapeutics Limited-22960J LLC-Jim Roberts.pdf';
       CreateDocumentLinkJob.FileNameDefinition parseFileName = job.parseCRDRFileName(pathOnClient);
       System.assert(parseFileName.caseNumber == '22960J', 'Expecting 22960J ');
       System.assert(parseFileName.financialYear == '2023', 'Expecting 2023 ');

       pathOnClient = '/2023\\4916739-Skyline Therapeutics Limited-22960 LLC-Jim Roberts.pdf';
       parseFileName = job.parseCRDRFileName(pathOnClient);
       System.assert(parseFileName.caseNumber == '22960', 'Expecting 22960 ');
       System.assert(parseFileName.financialYear == '2023', 'Expecting 2023 ');


       pathOnClient = '/2023\\4916739-Skyline Therapeutics Limited-5783HGQJ LLC-Jim Roberts.pdf';
       parseFileName = job.parseCRDRFileName(pathOnClient);
       System.assert(parseFileName.caseNumber == '5783HGQJ', 'Expecting 5783HGQJ ');
       System.assert(parseFileName.financialYear == '2023', 'Expecting 2023 ');
       System.assert(parseFileName.classification == 'Finalised_CRDR', 'Finalised_CRDR');

       pathOnClient = '/2024\\Cordellia Sita\\FY24 Draft CRDR\\4916739-Skyline Therapeutics Limited-5783HGQJ LLC-Jim Roberts.pdf';
       parseFileName = job.parseCRDRFileName(pathOnClient);
       System.assert(parseFileName.caseNumber == '5783HGQJ', 'Expecting 5783HGQJ ');
       System.assert(parseFileName.financialYear == '2024', 'Expecting 2024');
       System.assert(parseFileName.classification == 'Draft_CRDR', 'Draft_CRDR');

       assertCRDRCaseNumberMatchFound('/2023\\4916830-Electrolyte_Solutions,_Inc.-22456_LLC-Deirdre_Zammit.pdf', '22456');
       assertCRDRCaseNumberMatchFound('/2023\\4916654-Instancio LLC-24566 equity-Kevin Hgan-rerun with CSail at C1.pdf', '24566');
       assertCRDRCaseNumberMatchFound('/2023\\No-Royalty Revenue-16988TEJQ-Ben Rockney.pdf', '16988TEJQ');
       assertCRDRCaseNumberMatchFound('/2023\\4913730-3-D Matrix Asia-9191-Ben Rockney.pdf', '9191');
       assertCRDRCaseNumberMatchFound('/2023\\No-Royalty Revenue-16988TEJQ- Ben Rockney.pdf', '16988TEJQ');
       assertCRDRCaseNumberMatchFound('/2023\\4916756-Ray Therapeutics, Inc.-16950TEJ-Ben Rockney.pdf', '16950TEJ');
       assertCRDRCaseNumberMatchFound('/2023\\4915640-Broad Institute-25152R with reserve-Lauren Foster.pdf', '25152R');
       assertCRDRCaseNumberMatchFound('/2023\\4915640-Broad Institute-25152R off-cycle distribution 08.16.2023.pdf', '25152R');
       assertCRDRCaseNumberMatchFound('/2023\\4913014-Erbi Bio-15934 equity-Ben Rockney.pdf', '15934');
       assertCRDRCaseNumberMatchFound('/2023\\4916876-Pine Trees Health-22543JRHM.pdf', '22543JRHM');
       assertCRDRCaseNumberMatchFound('/2023\\4915059-Dragonfly Therapeutics-18893H LLC_NG-Jim Roberts.pdf', '18893H');
       assertCRDRCaseNumberMatchFound('/2023\\4908449-GVD_Corp-23562_equity-Deirdre_Zammit.pdf', '23562');
       assertCRDRCaseNumberMatchFound('/2023\\4912816-GelSight Corporation-13283 Deirdre Zammit.pdf', '13283');
       assertCRDRCaseNumberMatchFound('/2024\\4912071-Clontech Laboratories, Inc- 12049Q-Lauren Foster.pdf', '12049Q');
       assertCRDRCaseNumberMatchFound('/2024\\No Royalty revenue-4972J-Myron Kassaraba.pdf', '4972J');
       assertCRDRCaseNumberMatchFound('/2024\\No Royalty revenue-4972-Myron Kassaraba.pdf', '4972');
       


   }

   @isTest
   public static void testAgreementFileDefinitionParser() {
        String licenseType = null;
        String agreementType = null;
        String mtaType = null;
        assertAgreementNumberMatchFound('/Agreements/License/4900030-[3987].pdf', '4900030', licenseType);
        assertAgreementNumberMatchFound('/Agreements/Agreement/4914425.PDF', '4914425', agreementType);
        assertAgreementNumberMatchFound('/Agreements/Agreement/4915792 - MTA Natural Expiration Termination.pdf', '4915792', mtaType);
        assertAgreementNumberMatchFound('/ImageSilo\\Agreements\\License by Agent\\4911972-[503].pdf', '4911972', null);


   }

  private static void assertAgreementNumberMatchFound(String pathOnClient, String agreementNumber, String classification) {
       AgreementDocumentLinkProcessor processor = new AgreementDocumentLinkProcessor();
       DocumentLinkProcessor.FileNameDefinition parseFileName;
       String entityRecId = '-1';
       parseFileName= processor.parsePathOnClient(pathOnClient, entityRecId);
       System.assert(parseFileName.agreementNumber == agreementNumber, 'Expecting ' + agreementNumber);
       System.assert(parseFileName.classification == classification, 'Expecting ' + classification);

   }


   private static void assertCRDRCaseNumberMatchFound(String pathOnClient, String caseNumber) {
       CreateDocumentLinkJob job = new CreateDocumentLinkJob();
       CreateDocumentLinkJob.FileNameDefinition parseFileName = job.parseCRDRFileName(pathOnClient);
       System.assert(parseFileName.caseNumber == caseNumber, 'Expecting ' + caseNumber);
   }

   @isTest
   public static void testCRDRDataloaderEvent() {
        String caseCrdrId = '1574340';
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '5783HGQJ';
        crdr.ExternalCaseCRDRId__c = caseCrdrId;
        insert crdr;
        String fileName = '4906435-Jackson-5783HGQJ LLC-Nestor Franco.pdf';
        String pathOnClient = '/2023\\' + fileName;

        List<Forrester_SHIR_CRDR_VIEW__x > mockRecords = new List<Forrester_SHIR_CRDR_VIEW__x >();
        Forrester_SHIR_CRDR_VIEW__x mockRecord = new Forrester_SHIR_CRDR_VIEW__x();
        mockRecord.CASE_CRDR_RECID__c = '1574340' ;
        mockRecord.CASE_NO_SUFFIX__c = '5783';
        mockRecord.FY__c = '2023';
        mockRecords.add(mockRecord);

        List<Forrester_SHIR_CASE_CRDR_STATUS__x> mockStatusRecords = new List<Forrester_SHIR_CASE_CRDR_STATUS__x>();

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

    @isTest
    public static void testIPIADataloaderEvent() {
        String mitId = '920990598';
        String fileName = '920990598-Luciane Chimetto-Tonan.txt';
        String classification = 'Original_Document';
        String entitySubType = 'IPIA';
        String recordType='IPIA';
        String subTypeClassification = classification;
        String fileWriteDate = '2024/05/30 00:00:00';

        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'DOCUSIGN_IPIA_1', Exemption__c = false, Status__c = 'Active');
        insert ipiaType1;
        IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = '920990598', IPIA_Type__c = ipiaType1.Id, FormName__c = ipiaType1.Name, SignDatetime__c = DateTime.newInstance(2024, 5, 29).date() );
        insert ipiaRecord;

        IPIA_Record__c olderIpiaRecord = new IPIA_Record__c(MitId__c = '920990598', IPIA_Type__c = ipiaType1.Id, FormName__c = ipiaType1.Name, SignDatetime__c = DateTime.newInstance(2024, 4, 29).date() );
        insert olderIpiaRecord;

        IPIA_Record__c oldestIpiaRecord = new IPIA_Record__c(MitId__c = '920990598', IPIA_Type__c = ipiaType1.Id, FormName__c = ipiaType1.Name, SignDatetime__c = DateTime.newInstance(2023, 5, 29).date() );
        insert oldestIpiaRecord;


        List<Forrester_CONTACT__x > mockRecords = new List<Forrester_CONTACT__x >();
        Forrester_CONTACT__x mockRecord = new Forrester_CONTACT__x();
        mockRecord.MIT_ID__c = mitId ;
        mockRecord.ALTERNATE_IPIA_AGMT_DATE__c = DateTime.newInstance(2024, 5, 28).date();
        mockRecords.add(mockRecord);

        ExternalQueryMock mock = ExternalQueryMock.getInstance();
        mock.setDataStore('Forrester_CONTACT__x:Ids', mockRecords);

        Test.startTest();
            String entityRecId = '-1';
            Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            String txtFileContent = 'test';
            ContentVersion conVer = new ContentVersion();
            conVer.Title = 'Test ' + fileName; // Display name of the files
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
            conVer.RecordTypeId = recordTypeId;
            conVer.Document_Classification__c = subTypeClassification;
            conVer.Entity_Sub_Type__c = entitySubType;
            conVer.VersionData = Blob.valueOf(txtFileContent);
            conVer.Entity_RecId__c = String.valueOf(entityRecId);
            conVer.TagCsv = String.valueOf(mitId);
            conVer.Description = 'MitId: '+mitId+' ContactId: 103957 FileWriteDate: ' + fileWriteDate;
            insert conVer;
        Test.stopTest();

        List<ContentDocumentLink> cdl =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: ipiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVer.Id )];

        System.assert(cdl.isEmpty() == false, 'Expecting ContentDocumentLink Created');

        List<ContentDocumentLink> cdlEmtpy =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: olderIpiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVer.Id )];

        System.assert(cdlEmtpy.isEmpty() == true, 'Expecting no ContentDocumentLink for older IPIA Record');

        cdlEmtpy =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: oldestIpiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVer.Id )];

        System.assert(cdlEmtpy.isEmpty() == true, 'Expecting no ContentDocumentLink for oldest IPIA Record');

    }

    @isTest
    public static void testIPIADataloaderEmptyList() {
        List<ContentVersion> emptyList = new List<ContentVersion>();
        IPIADocumentLinkProcessor p1 = new IPIADocumentLinkProcessor();
        p1.execute(emptyList);
        p1.createDocumentLink(emptyList);
        try {
             p1.execute(null);
             p1.createDocumentLink(null);
             System.assert(false, 'Exception not thrown');
        } catch(Exception e) {
             System.assert(true, 'Exception thrown');
        }
    }

    @isTest
    public static void testIPIADateRange() {
      IPIADocumentLinkProcessor processor = new IPIADocumentLinkProcessor();

      Boolean isEqual = processor.isDatesInRange(DateTime.newInstance(2024, 5, 29).date(), DateTime.newInstance(2024, 5, 29).date(), 0);
      System.assert(isEqual, 'Dates are equal');

      Boolean isInRange = processor.isDatesInRange(DateTime.newInstance(2024, 5, 29).date(), DateTime.newInstance(2024, 5, 29).date(), 1);
      System.assert(isInRange, 'Dates are equal');

      Boolean isOneDayApart = processor.isDatesInRange(DateTime.newInstance(2024, 5, 29).date(), DateTime.newInstance(2024, 5, 30).date(), 1);
      System.assert(isOneDayApart, 'Dates are one day apart');

      Boolean isTwoDaysApart = processor.isDatesInRange(DateTime.newInstance(2024, 5, 29).date(), DateTime.newInstance(2024, 5, 31).date(), 1);
      System.assert(isTwoDaysApart == false, 'Dates are two days apart');

      isTwoDaysApart = processor.isDatesInRange(DateTime.newInstance(2024, 5, 31).date(), DateTime.newInstance(2024, 5, 29).date(), 1);
      System.assert(isTwoDaysApart == false, 'Dates are two days apart');

      Boolean notInRange = processor.isDatesInRange(DateTime.newInstance(2024, 6, 29).date(), DateTime.newInstance(2024, 5, 29).date(), 3);
      System.assert(notInRange == false, 'Dates are not in range');


    }


    @isTest
    public static void testIPIADataloaderNoCsvTag() {
        String mitId = '920990598';
        String fileName = '920990598-Luciane Chimetto-Tonan.txt';
        String classification = 'Original_Document';
        String entitySubType = 'IPIA';
        String recordType='IPIA';
        String subTypeClassification = classification;

        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'DOCUSIGN_IPIA_1', Exemption__c = false, Status__c = 'Active');
        insert ipiaType1;
        IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = '920990598', IPIA_Type__c = ipiaType1.Id, FormName__c = ipiaType1.Name, SignDatetime__c = DateTime.newInstance(2024, 5, 29).date() );
        insert ipiaRecord;

        List<Forrester_CONTACT__x > mockRecords = new List<Forrester_CONTACT__x >();
        Forrester_CONTACT__x mockRecord = new Forrester_CONTACT__x();
        mockRecord.MIT_ID__c = mitId ;
        mockRecords.add(mockRecord);

        ExternalQueryMock mock = ExternalQueryMock.getInstance();
        mock.setDataStore('Forrester_CONTACT__x:Ids', mockRecords);


        Test.startTest();
            String entityRecId = '-1';
            Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            String txtFileContent = 'test';
            ContentVersion conVer = new ContentVersion();
            conVer.Title = 'Test ' + fileName; // Display name of the files
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
            conVer.RecordTypeId = recordTypeId;
            conVer.Document_Classification__c = subTypeClassification;
            conVer.Entity_Sub_Type__c = entitySubType;
            conVer.VersionData = Blob.valueOf(txtFileContent);
            conVer.Entity_RecId__c = String.valueOf(entityRecId);
            conVer.TagCsv = null;
            insert conVer;
        Test.stopTest();
        ContentVersion testCv = [SELECT Id, Entity_RecId__c FROM ContentVersion WHERE Id = :conVer.Id];
        System.assert(testCv.Entity_RecId__c == '-1', 'No changes');

        List<ContentDocumentLink> cdl =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: ipiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVer.Id )];
        System.assert(cdl.isEmpty() == true, 'Expecting No ContentDocumentLink');

    }

    @isTest
    public static void testIPIADataloaderInvalidMitId() {
        String mitId = '920990598';
        String invalidMitId = '900000008';
        String fileName = '920990598-Luciane Chimetto-Tonan.txt';
        String classification = 'Original_Document';
        String entitySubType = 'IPIA';
        String recordType='IPIA';
        String subTypeClassification = classification;

        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'DOCUSIGN_IPIA_1', Exemption__c = false, Status__c = 'Active');
        insert ipiaType1;
        IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = invalidMitId, IPIA_Type__c = ipiaType1.Id, FormName__c = ipiaType1.Name, SignDatetime__c = DateTime.newInstance(2024, 5, 29).date() );
        insert ipiaRecord;

        List<Forrester_CONTACT__x > mockRecords = new List<Forrester_CONTACT__x >();
        Forrester_CONTACT__x mockRecord = new Forrester_CONTACT__x();
        mockRecord.MIT_ID__c = mitId ;
        mockRecords.add(mockRecord);

        ExternalQueryMock mock = ExternalQueryMock.getInstance();
        mock.setDataStore('Forrester_CONTACT__x:Ids', mockRecords);

        Test.startTest();
            String entityRecId = '-1';
            Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            String txtFileContent = 'test';
            ContentVersion conVer = new ContentVersion();
            conVer.Title = 'Test ' + fileName; // Display name of the files
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
            conVer.RecordTypeId = recordTypeId;
            conVer.Document_Classification__c = subTypeClassification;
            conVer.Entity_Sub_Type__c = entitySubType;
            conVer.VersionData = Blob.valueOf(txtFileContent);
            conVer.Entity_RecId__c = String.valueOf(entityRecId);
            conVer.TagCsv = String.valueOf(mitId);
            insert conVer;
        Test.stopTest();
        ContentVersion testCv = [SELECT Id, Entity_RecId__c FROM ContentVersion WHERE Id = :conVer.Id];
        System.assert(testCv.Entity_RecId__c == '-1', 'No changes');

        List<ContentDocumentLink> cdl =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: ipiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVer.Id )];
        System.assert(cdl.isEmpty() == true, 'Expecting No ContentDocumentLink');

    }

    @isTest
    public static void testRelinkIPIADocuments() {
        String mitId = '920990598';
        String fileName = '920990598-Luciane Chimetto-Tonan.txt';
        String classification = 'Original_Document';
        String entitySubType = 'IPIA';
        String recordType='IPIA';
        String subTypeClassification = classification;


        List<Forrester_CONTACT__x > mockRecords = new List<Forrester_CONTACT__x >();
        Forrester_CONTACT__x mockRecord = new Forrester_CONTACT__x();
        mockRecord.MIT_ID__c = mitId ;
        mockRecords.add(mockRecord);

        ExternalQueryMock mock = ExternalQueryMock.getInstance();
        mock.setDataStore('Forrester_CONTACT__x:Ids', mockRecords);


        String entityRecId = '-1';
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        String txtFileContent = 'test';
        ContentVersion conVer = new ContentVersion();
        conVer.Title = 'Test ' + fileName; // Display name of the files
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
        conVer.RecordTypeId = recordTypeId;
        conVer.Document_Classification__c = subTypeClassification;
        conVer.Entity_Sub_Type__c = entitySubType;
        conVer.VersionData = Blob.valueOf(txtFileContent);
        conVer.Entity_RecId__c = String.valueOf(entityRecId);
        conVer.TagCsv = String.valueOf(mitId);
        String fileWriteDate = '2024/05/30 00:00:00';
        conVer.Description = 'MitId: '+mitId+' ContactId: 103957 FileWriteDate: ' + fileWriteDate;
        insert conVer;

        Test.startTest();
           IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'DOCUSIGN_IPIA_1', Exemption__c = false, Status__c = 'Active');
           insert ipiaType1;
           IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = mitId, IPIA_Type__c = ipiaType1.Id, FormName__c = ipiaType1.Name, SignDatetime__c = DateTime.newInstance(2024, 5, 29).date() );
           insert ipiaRecord;

           Database.executeBatch(new CreateDocumentLinkBatch(CreateDocumentLinkBatch.DocumentLinkType.IPIA), 50);
        Test.stopTest();

        ContentVersion testCv = [SELECT Id, Entity_RecId__c FROM ContentVersion WHERE Id = :conVer.Id];
        System.assert(testCv.Entity_RecId__c == mitId, 'Retry linking error');

        List<ContentDocumentLink> cdl =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: ipiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVer.Id )];
        System.assert(cdl.isEmpty() == false, 'Expecting ContentDocumentLink');

    }
    @isTest
    public static void testRelinkIPIADocumentsNoDocumentType() {
        // Code Coverage for null
         Test.startTest();
            Database.executeBatch(new CreateDocumentLinkBatch(null), 50);
         Test.stopTest();

    }


    @isTest
    public static void testReLinkMultipleContentVersionsToOneIPIADocument() {
        String mitId = '920990598';
        String fileName = '920990598-Luciane Chimetto-Tonan.txt';
        String classification = 'Original_Document';
        String entitySubType = 'IPIA';
        String recordType='IPIA';
        String subTypeClassification = classification;


        String entityRecId = '-1';
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        String txtFileContent = 'test';

        ContentVersion conVer = new ContentVersion();
        conVer.Title = 'Test 2 ' + fileName; // Display name of the files
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
        conVer.RecordTypeId = recordTypeId;
        conVer.Document_Classification__c = subTypeClassification;
        conVer.Entity_Sub_Type__c = entitySubType;
        conVer.VersionData = Blob.valueOf(txtFileContent);
        conVer.Entity_RecId__c = String.valueOf(entityRecId);
        conVer.TagCsv = String.valueOf(mitId);
        String fileWriteDate = '2024/05/30 12:00:59';
        conVer.Description = 'MitId: '+mitId+' ContactId: 103957 FileWriteDate: ' + fileWriteDate;

        ContentVersion conVerOlder = new ContentVersion();
        conVerOlder.Title = 'Test 1 ' + fileName; // Display name of the files
        conVerOlder.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVerOlder.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
        conVerOlder.RecordTypeId = recordTypeId;
        conVerOlder.Document_Classification__c = subTypeClassification;
        conVerOlder.Entity_Sub_Type__c = entitySubType;
        conVerOlder.VersionData = Blob.valueOf(txtFileContent);
        conVerOlder.Entity_RecId__c = String.valueOf(entityRecId);
        conVerOlder.TagCsv = String.valueOf(mitId);
        String fileWriteDateOlder = '2024/05/30 12:00:00';
        conVerOlder.Description = 'MitId: '+mitId+' ContactId: 103957 FileWriteDate: ' + fileWriteDateOlder;

        insert new List<ContentVersion>{conVerOlder, conVer};


        Test.startTest();
           IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'DOCUSIGN_IPIA_1', Exemption__c = false, Status__c = 'Active');
           insert ipiaType1;
           IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = mitId, IPIA_Type__c = ipiaType1.Id, FormName__c = ipiaType1.Name, SignDatetime__c = DateTime.newInstance(2024, 5, 29).date() );
           insert ipiaRecord;

           Database.executeBatch(new CreateDocumentLinkBatch(CreateDocumentLinkBatch.DocumentLinkType.IPIA), 50);
        Test.stopTest();

        ContentVersion testCv = [SELECT Id, Entity_RecId__c FROM ContentVersion WHERE Id = :conVer.Id];
        System.assert(testCv.Entity_RecId__c == mitId, 'Retry linking error');

        List<ContentDocumentLink> cdl =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: ipiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVer.Id )];
        System.assert(cdl.isEmpty() == false, 'Expecting ContentDocumentLink');

        List<ContentDocumentLink> cdlOld =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: ipiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVerOlder.Id )];
        System.assert(cdlOld.isEmpty() == true, 'Expecting No ContentDocumentLink');

        IPIADocumentLinkProcessor ipiaDocumentLinkProcessor = new IPIADocumentLinkProcessor();
        List<ContentVersion> contentVersions = new List<ContentVersion>{conVerOlder, conVer};
        Map<Id, DocumentLinkProcessor.FileNameDefinition> fileDefMap = new Map<Id, DocumentLinkProcessor.FileNameDefinition>();
        // Parse all TagCsv values
        for(ContentVersion contentVersion : contentVersions) {
            DocumentLinkProcessor.FileNameDefinition parsed = ipiaDocumentLinkProcessor.parseCsvTag(contentVersion.TagCsv, contentVersion.Description);
            if(parsed == null) {
                continue;
            }
            fileDefMap.put(contentVersion.Id, parsed);
        }
        List<ContentVersion> sortedContentVersions = ipiaDocumentLinkProcessor.sortContentVersionsDesc(contentVersions, fileDefMap);

        System.assertEquals(conVer, sortedContentVersions[0],  'Should be sorted desc');
        System.assertEquals(conVerOlder, sortedContentVersions[1], 'Should be sorted desc');

    }

    @isTest
    public static void testLinkMultipleContentVersionsToOneIPIADocument() {
        String mitId = '920990598';
        String fileName = '920990598-Luciane Chimetto-Tonan.txt';
        String classification = 'Original_Document';
        String entitySubType = 'IPIA';
        String recordType='IPIA';
        String subTypeClassification = classification;

        // Existing IPIA Record
        IPIA_Type__c ipiaType1 = new IPIA_Type__c(Name = 'DOCUSIGN_IPIA_1', Exemption__c = false, Status__c = 'Active');
        insert ipiaType1;
        IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = mitId, IPIA_Type__c = ipiaType1.Id, FormName__c = ipiaType1.Name, SignDatetime__c = DateTime.newInstance(2024, 5, 29).date() );
        insert ipiaRecord;


        String entityRecId = '-1';
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        String txtFileContent = 'test';

        Test.startTest();
        ContentVersion conVer = new ContentVersion();
        conVer.Title = 'Test 2 ' + fileName; // Display name of the files
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
        conVer.RecordTypeId = recordTypeId;
        conVer.Document_Classification__c = subTypeClassification;
        conVer.Entity_Sub_Type__c = entitySubType;
        conVer.VersionData = Blob.valueOf(txtFileContent);
        conVer.Entity_RecId__c = String.valueOf(entityRecId);
        conVer.TagCsv = String.valueOf(mitId);
        String fileWriteDate = '2024/05/30 12:00:59';
        conVer.Description = 'MitId: '+mitId+' ContactId: 103957 FileWriteDate: ' + fileWriteDate;
        insert conVer;

        ContentVersion conVerOlder = new ContentVersion();
        conVerOlder.Title = 'Test 1 ' + fileName; // Display name of the files
        conVerOlder.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVerOlder.PathOnClient = '/ImageSilo\\IPIAs\\' + fileName;
        conVerOlder.RecordTypeId = recordTypeId;
        conVerOlder.Document_Classification__c = subTypeClassification;
        conVerOlder.Entity_Sub_Type__c = entitySubType;
        conVerOlder.VersionData = Blob.valueOf(txtFileContent);
        conVerOlder.Entity_RecId__c = String.valueOf(entityRecId);
        conVerOlder.TagCsv = String.valueOf(mitId);
        String fileWriteDateOlder = '2024/05/30 12:00:00';
        conVerOlder.Description = 'MitId: '+mitId+' ContactId: 103957 FileWriteDate: ' + fileWriteDateOlder;
        insert conVerOlder;
        Test.stopTest();

        ContentVersion testCv = [SELECT Id, Entity_RecId__c FROM ContentVersion WHERE Id = :conVer.Id];
        System.assert(testCv.Entity_RecId__c == mitId, 'Retry linking error');

        List<ContentDocumentLink> cdl =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: ipiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVer.Id )];
        System.assert(cdl.isEmpty() == false, 'Expecting ContentDocumentLink');

        List<ContentDocumentLink> cdlOld =[ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: ipiaRecord.Id
                                AND ContentDocumentId IN (SELECT ContentDocumentId
                                    FROM ContentVersion
                                    WHERE Id = :conVerOlder.Id )];
        System.assert(cdlOld.isEmpty() == true, 'Expecting No ContentDocumentLink');

        List<Log_Document_Link__c> logs = [SELECT Id, Name, ContentVersion_Id__c, Message__c, PathOnClient__c, Type__c, CreatedDate FROM Log_Document_Link__c where Type__c in ('IPIA-SObject-Link', 'IPIA-SObject-Query')];
        System.assertEquals(1, logs.size(), 'Expecting One Log_Document_Link__c');
    }

}