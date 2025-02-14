public with sharing class FileRepository {

    @AuraEnabled
    public static List<ContentDocumentLink> getThirdPartyCodeFilesByDisclosureId(String disclosureId) {
        if(disclosureId == null) {
            return null;
        }
        List<Id> thirdPartyIds = new List<Id>();
        List<Third_Party_Code__c> partyCodes = DisclosureRecordFetch.getThirdPartyCodeByDisclosureId(disclosureId);
        for(Third_Party_Code__c key : partyCodes) {
            thirdPartyIds.add(key.Id);
        }
        if(thirdPartyIds.size() > 0) {
            return getFilesByIdsAndType(thirdPartyIds , 'Disclosure');
        }

        return null;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getThirdPartyContentFilesByDisclosureId(String disclosureId) {
        if(disclosureId == null) {
            return null;
        }
        List<Id> thirdPartyIds = new List<Id>();
        List<Third_Party_Content__c> licenseAgreements = DisclosureRecordFetch.getThirdPartyContentByDisclosureId(disclosureId);
        for(Third_Party_Content__c key : licenseAgreements) {
            thirdPartyIds.add(key.Id);
        }
        if(thirdPartyIds.size() > 0) {
            return getFilesByIdsAndType(thirdPartyIds , 'Disclosure');
        }

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getFilesByRecordId(String recordId, String dataType, String subType, String docType) {
 
        try {
            List<String> linkedRecIds = new List<String>{recordId};
            Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(dataType).getRecordTypeId();
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                        ContentDocument.FileType,
                        ContentDocument.ContentSize,
                        ContentDocument.CreatedDate
                        FROM ContentDocumentLink WHERE LinkedEntityId = :linkedRecIds
                            AND ContentDocumentId IN (SELECT ContentDocumentId
                                FROM ContentVersion
                                WHERE RecordTypeId = :recordTypeId 
                                AND Entity_Sub_Type__c = :subType
                                AND Document_Classification__c = :docType )
                        ];

            List<Id> contentDocumentIds = new List<Id>();
            for (ContentDocumentLink documentLink : cdlList) {
                contentDocumentIds.add(documentLink.ContentDocumentId);
            }
            List<ContentVersion> cvs =  FileRepository.getFileContentVersionsByDocumentIds(contentDocumentIds);

            return cvs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getFilesByIdsAndType(List<String> linkedRecIds, String recordType){
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                    ContentDocument.FileType,
                       ContentDocument.ContentSize,
                       ContentDocument.CreatedDate
                       FROM ContentDocumentLink WHERE LinkedEntityId =: linkedRecIds
                        AND ContentDocumentId IN (SELECT ContentDocumentId
                            FROM ContentVersion
                            WHERE RecordTypeId = :recordTypeId   )
                       ];
           return cdlList;
    }

   @AuraEnabled
   public static List<ContentDocumentLink> getFilesByType(String linkedRecId, String recordType){
        if (linkedRecId == null ) {
            return new List<ContentDocumentLink>();
        }
        Set<Id> recordTypeIds = new Set<Id>();
        if (recordType == 'Case') {
              recordTypeIds = RecordTypeIdUtility.getContentVersionRecordTypIds(new List<String>{'Sponsor_Agreement', 'Other_Agreement'});
        } else {
            Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            recordTypeIds.add(recordTypeId);
        }

        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                    ContentDocument.FileType,
                    ContentDocument.ContentSize,
                    ContentDocument.CreatedDate
                    FROM ContentDocumentLink WHERE LinkedEntityId =: linkedRecId
                     AND ContentDocumentId IN (SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE RecordTypeId = :recordTypeIds  )
                    ];
        return cdlList;
    }
    @AuraEnabled
    public static List<ContentDocumentLink> getFilesByTypeAndClassification(String linkedRecId, String recordType, String recordClassification){
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                    ContentDocument.FileType,
                    ContentDocument.ContentSize,
                    ContentDocument.CreatedDate
                    FROM ContentDocumentLink WHERE LinkedEntityId =: linkedRecId
                     AND ContentDocumentId IN (SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE RecordTypeId = :recordTypeId AND  Document_Classification__c = :recordClassification )
                    ];
        return cdlList;
    }


    @AuraEnabled
    public static List<ContentDocumentLink> getFileContentVersionsByEntityRecId(String entityRecId, String recordType, String recordClassification){

        Set<Id> ids = new Set<Id>();
        Set<Id> recordTypeIds = new Set<Id>();
        List<String> classifications = new List<String>();
        if (recordType == 'Case') {
              recordTypeIds = RecordTypeIdUtility.getContentVersionRecordTypIds(new List<String>{'Sponsor_Agreement', 'Other_Agreement'});
              Map<Id, TLO_Case__c> lookup = new Map<Id, TLO_Case__c>([Select Id from TLO_Case__c where ExternalCaseId__c =:entityRecId]);
              ids = lookup.keySet();
        } if (recordType == 'TLO_Agreement') {
               recordTypeIds = RecordTypeIdUtility.getContentVersionRecordTypIds(new List<String>{'TLO_Agreement'});
               Map<Id, Agreement__c> lookup = new Map<Id, Agreement__c>([Select Id from Agreement__c where ExternalAgreement__c =:entityRecId]);
               ids = lookup.keySet();
         } else if (recordType == 'CRDR') {
              recordTypeIds = RecordTypeIdUtility.getContentVersionRecordTypIds(new List<String>{'CRDR'});
              Map<Id, Case_CRDR__c> lookup = new Map<Id, Case_CRDR__c>([Select Id from Case_CRDR__c where ExternalCaseCRDRId__c =:entityRecId]);
              ids = lookup.keySet();
              classifications.add(recordClassification);
        } else {
              Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
              recordTypeIds.add(recordTypeId);
              classifications.add(recordClassification);
        }
        if (ids.isEmpty()) {
            throw new AuraHandledException('No Container Object found for ' + entityRecId);
        }
        List<ContentDocumentLink> cdlList = null;
        if (classifications.isEmpty()) {
            cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                                     ContentDocument.FileType,
                                     ContentDocument.ContentSize,
                                     ContentDocument.CreatedDate,
                                     ContentDocument.ContentModifiedDate
                                     FROM ContentDocumentLink WHERE LinkedEntityId = :ids
                                      AND ContentDocumentId IN (SELECT ContentDocumentId
                                          FROM ContentVersion
                                          WHERE RecordTypeId = :recordTypeIds  )
                                     limit 2000];
        } else {
            cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                                     ContentDocument.FileType,
                                     ContentDocument.ContentSize,
                                     ContentDocument.CreatedDate,
                                     ContentDocument.ContentModifiedDate
                                     FROM ContentDocumentLink WHERE LinkedEntityId = :ids
                                      AND ContentDocumentId IN (SELECT ContentDocumentId
                                          FROM ContentVersion
                                          WHERE RecordTypeId = :recordTypeIds AND Document_Classification__c = :classifications  )
                                     limit 2000];
        }

        return cdlList;
    }

    @AuraEnabled(cacheable = true)
    // Helper method to search TLO_Agreement data subtypes
    public static List<String> relatedTLOAgreementDataSubTypes(String crdrRecordId) {
        List<String> agreementTypes = new List<String>();

        // Fetch unique AGREEMENT_TYPE__c values based on crdrRecordId
        for (Forrester_SHIR_CASE_CRDR_AGREEMENT_VI__x fcrdr : [SELECT Id, CASE_CRDR_RECID__r.Id, AGREEMENT_RECID__r.AGREEMENT_TYPE__c FROM Forrester_SHIR_CASE_CRDR_AGREEMENT_VI__x WHERE CASE_CRDR_RECID__r.Id = :crdrRecordId]) {
            if (fcrdr.AGREEMENT_RECID__r.AGREEMENT_TYPE__c != null) {
                agreementTypes.add(fcrdr.AGREEMENT_RECID__r.AGREEMENT_TYPE__c);
            }
        }

        // Remove duplicate values
        agreementTypes = new List<String>(new Set<String>(agreementTypes));
        return agreementTypes;
    }

    @AuraEnabled
    // The size of the document in bytes.
    // Exclude the Blob to prevent 'Query of LOB fields caused heap usage to exceed limit'
    public static List<ContentVersion> getFileContentVersionsByDocumentIds(List<Id> contentDocumentIds){

        List<ContentVersion> cvList = [SELECT ContentDocumentId,
                        ContentSize,
                        CreatedDate,
                        Description,
                        toLabel(Document_Classification__c) Document_Classification_Label,
                        Document_Classification__c,
                        toLabel(Entity_Sub_Type__c) Entity_Sub_Type_Label,
                        Entity_Sub_Type__c,
                        FileExtension,
                        FileType,
                        Title,
                        RecordType.Name,
                        ContentModifiedDate,
                        CreatedBy.Name,
                        VersionNumber
                        FROM ContentVersion
                        WHERE isLatest = true 
                        AND  ContentDocumentId IN :contentDocumentIds
                        ORDER BY ContentModifiedDate DESC
                    ];
        return cvList;
    }



   @AuraEnabled
   public static List<AgreementSRAFileResponse> getCrdrSponsorSRAFilesByCaseRecId(String caseRecId) {
        KualiCoeusService kcService = new KualiCoeusService();

        List<Forrester_Case_Sponsor__x> sponsors = [SELECT Id, ExternalId, OSP_PROJECT_NUMS__c, OSP_PROJECT_RECID__c,
                        OSP_PROJECT_RECID__r.OSP_PROJECT_NUM__c
                        FROM Forrester_Case_Sponsor__x
                        WHERE CASE_RECID__c = :caseRecId
                    ];


        List<AgreementSRAFileResponse> response = new List<AgreementSRAFileResponse>();
        for (Forrester_Case_Sponsor__x sponsor : sponsors) {
            String ospProjectNum = sponsor.OSP_PROJECT_NUMS__c ;
            Boolean ospProjectNumNullOrEmpty = ospProjectNum == null || ospProjectNum == '';

            if (ospProjectNumNullOrEmpty) {
                ospProjectNum = sponsor.OSP_PROJECT_RECID__r.OSP_PROJECT_NUM__c ;
            }

            List<KualiCoeusService.DocumentUrlResponse> documentUrls = kcService.generateDocumentUrl(ospProjectNum);
            for (KualiCoeusService.DocumentUrlResponse documentUrl : documentUrls) {
                AgreementSRAFileResponse sra = new AgreementSRAFileResponse();
                sra.title = documentUrl.name;
                sra.accountNumber = documentUrl.accountNumber;
                sra.url = documentUrl.url;
                sra.sponsorName = documentUrl.sponsorName;
                sra.fileExtension = documentUrl.urlType;
                sra.documentType = 'Other Agreement';
                sra.documentClassification = 'Link';
                sra.entitySubType = 'Kuali';
                sra.recordId = sponsor.Id;
                sra.recordLabel = String.valueOf(sponsor.ExternalId);
                response.add(sra);
            }
        }
        return response;

    }
 

   @AuraEnabled
   public static List<AgreementFileResponse> getCrdrAgreementFilesByCaseRecId(Decimal caseRecId, String financialYear){
        Set<Id> recordTypeIds = RecordTypeIdUtility.getContentVersionRecordTypIds(new List<String>{'TLO_Agreement'});

        Set<String> agreementNumbers = new Set<String>();

        Decimal financialYearFilter = Decimal.valueOf(financialYear);
        String caseRecIdFilter = String.valueOf(caseRecId);
        List<Forrester_SHIR_CASE_CRDR_AGREEMENT_VI__x> caseCrdrAgreementList = [SELECT Id, CASE_RECID__c, AGREEMENT_RECID__c, FY__c
                                                                                FROM Forrester_SHIR_CASE_CRDR_AGREEMENT_VI__x
                                                                                WHERE CASE_RECID__c = :caseRecIdFilter 
                                                                                AND FY__c = :financialYearFilter];

        for(Forrester_SHIR_CASE_CRDR_AGREEMENT_VI__x caseAgreement : caseCrdrAgreementList) {
            if (caseAgreement.AGREEMENT_RECID__c != null) {
                agreementNumbers.add(caseAgreement.AGREEMENT_RECID__c);
            }
        }
        if (agreementNumbers.size() == 0 ){
            return new List<AgreementFileResponse>();
        }

        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                    ContentDocument.FileType,
                    ContentDocument.ContentSize,
                    ContentDocument.CreatedDate,
                    ContentDocument.CreatedBy.Name,
                    ContentDocument.ContentModifiedDate
                    FROM ContentDocumentLink WHERE LinkedEntityId in ( SELECT ID from Agreement__c WHERE ExternalAgreement__c = :agreementNumbers )
                     AND ContentDocumentId IN (SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE RecordTypeId = :recordTypeIds  )
                    ];

        Map<Id, Agreement__c> agreementContainerMap = new Map<Id, Agreement__c>([SELECT ID, ExternalAgreement__c from Agreement__c WHERE ExternalAgreement__c = :agreementNumbers ]);

        //Inline query has too many rows for direct assignment, use FOR loop
        Integer batchSize = 50;
        List<Forrester_SHIR_AGREEMENT_VIEW__x> agreementList = ExternalObjectRepository.fetchSObjectsByExternalRecIds(new List<String>(agreementNumbers), 'Forrester_SHIR_AGREEMENT_VIEW__x', 'AGREEMENT_RECID__c', null, batchSize);

        Map<String, Forrester_SHIR_AGREEMENT_VIEW__x> agreementLookup = new Map<String, Forrester_SHIR_AGREEMENT_VIEW__x>();
        for(Forrester_SHIR_AGREEMENT_VIEW__x agreement : agreementList) {
            agreementLookup.put(agreement.AGREEMENT_RECID__c, agreement);
        }

        List<AgreementFileResponse> fileList = new List<AgreementFileResponse>();
        for(ContentDocumentLink documentLink : cdlList) {
            AgreementFileResponse file = new AgreementFileResponse();
            file.contentDocumentId = documentLink.ContentDocumentId;

            if(agreementContainerMap.containsKey(documentLink.LinkedEntityId)) {
                Agreement__c agreement = agreementContainerMap.get(documentLink.LinkedEntityId);
                if(agreementLookup.containsKey(agreement.ExternalAgreement__c)) {
                    Forrester_SHIR_AGREEMENT_VIEW__x extObj = agreementLookup.get(agreement.ExternalAgreement__c);
                    file.recordId = extObj.Id;
                    file.recordLabel = String.valueOf(extObj.AGREEMENT_RECID__c);
                }

            }
            fileList.add(file);
        }


        return fileList;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink>  getRelatedFilesByAgreementRecId(String recordId){
         Set<String> agreementNumbers = new Set<String>();

          List<Forrester_SHIR_AGREEMENT_VIEW__x> agreementList = [SELECT Id, ExternalId, AGREEMENT_NUM__c, AGREEMENT_RECID__c
                                                                                  FROM Forrester_SHIR_AGREEMENT_VIEW__x
                                                                                  WHERE Id = :recordId
                                                                                 ];

         for(Forrester_SHIR_AGREEMENT_VIEW__x agreement : agreementList) {
             if (agreement.AGREEMENT_RECID__c != null) {
                 agreementNumbers.add(agreement.AGREEMENT_RECID__c);
             }
         }
         if (agreementNumbers.size() == 0 ){
             return new List<ContentDocumentLink>();
         }
         List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                     ContentDocument.FileType,
                     ContentDocument.ContentSize,
                     ContentDocument.CreatedDate,
                     ContentDocument.ContentModifiedDate,
                     ContentDocument.CreatedBy.Name
                     FROM ContentDocumentLink WHERE LinkedEntityId in ( SELECT ID from Agreement__c WHERE ExternalAgreement__c = :agreementNumbers )
                     ];
        return cdlList;
     }

   @AuraEnabled
   public static List<AgreementFileResponse> getCaseRelatedFilesByCaseRecId(String caseRecId){
        Id crdrRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('CRDR').getRecordTypeId();
        Set<Id> recordTypeIds = RecordTypeIdUtility.getContentVersionRecordTypIds(new List<String>{'Sponsor_Agreement', 'Other_Agreement', 'Case' });

        Map<String, Forrester_Case__x> caseLookup = new Map<String, Forrester_Case__x>();
        List<Forrester_Case__x> caseList = ExternalObjectQuery.records([SELECT Id, CASE_RECID__c, CONTRACT_CASE_NUM__c FROM Forrester_Case__x
                        WHERE CASE_RECID__c = :caseRecId ]);


        for(Forrester_Case__x tloCase : caseList) {
            caseLookup.put(tloCase.CASE_RECID__c, tloCase);
        }

        List<String> crdrClassificationTypes = new List<String>{ ContentVersionClassification.WORKSHEET,
            ContentVersionClassification.CORRESPONDENCE
        };

        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                    ContentDocument.FileType,
                    ContentDocument.ContentSize,
                    ContentDocument.CreatedDate,
                    ContentDocument.ContentModifiedDate
                    FROM ContentDocumentLink WHERE LinkedEntityId in ( SELECT ID from TLO_Case__c WHERE ExternalCaseId__c = :caseLookup.keySet()  )
                         AND ContentDocumentId IN (SELECT ContentDocumentId
                             FROM ContentVersion
                             WHERE RecordTypeId = :recordTypeIds
                            )
                     ];
        //SOQL Limit: Can not combine this in ONE Query. `Maximum 2 semi join sub-selects are allowed`
        List<ContentDocumentLink> crdrCdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                    ContentDocument.FileType,
                    ContentDocument.ContentSize,
                    ContentDocument.CreatedDate,
                    ContentDocument.ContentModifiedDate
                    FROM ContentDocumentLink WHERE LinkedEntityId in ( SELECT ID from TLO_Case__c WHERE ExternalCaseId__c = :caseLookup.keySet()  )
                        AND ContentDocumentId IN (SELECT ContentDocumentId
                             FROM ContentVersion
                             WHERE RecordTypeId = :crdrRecordTypeId
                                    AND Document_Classification__c = :crdrClassificationTypes
                           )
                     ];
        cdlList.addAll(crdrCdlList);

        Map<Id,TLO_Case__c> caseMap = new Map<Id,TLO_Case__c>([SELECT ID, ExternalCaseId__c, Name from TLO_Case__c WHERE ExternalCaseId__c = :caseLookup.keySet() ]);

        List<AgreementFileResponse> fileList = new List<AgreementFileResponse>();
        for(ContentDocumentLink documentLink : cdlList) {
            AgreementFileResponse file = new AgreementFileResponse();
            file.contentDocumentId = documentLink.ContentDocumentId;

            if(caseMap.containsKey(documentLink.LinkedEntityId)) {
                TLO_Case__c tloCase = caseMap.get(documentLink.LinkedEntityId);

                Forrester_Case__x extObj = caseLookup.get(tloCase.ExternalCaseId__c);
                file.recordId = extObj.Id;
                file.recordLabel = String.valueOf(extObj.CONTRACT_CASE_NUM__c);

            }
            fileList.add(file);
        }
        return fileList;
    }

   /*
    CRDR doc's to only show for previous FY
    - Draft section only shows current FY’s Draft Documents
    - Finalised section shows previous 1 year’s FY doc & the current FY finalised doc when the CRDR reaches that status.
   */
   @AuraEnabled
   public static List<CRDRFileResponse> getCrdrFilesByCaseRecId(Decimal caseRecId, String financialYear, String status, String caseCrdrRecId){
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('CRDR').getRecordTypeId();

        String financialYearFilter = financialYear ;
        if (status == 'Finalised') {
            Double previousFinancialYear = Decimal.valueOf(financialYearFilter) - 1 ;
            financialYearFilter = String.valueOf(previousFinancialYear);
        }

        String caseRecIdFilter = String.valueOf(caseRecId);

        Map<String, Forrester_SHIR_CRDR_VIEW__x> crdrLookup = new Map<String, Forrester_SHIR_CRDR_VIEW__x>();
        List<Forrester_SHIR_CRDR_VIEW__x> crdrList = [SELECT Id, CASE_RECID__c, CASE_CRDR_RECID__c, CRDR_DATE__c, FY__c, DRAFT_FLAG__c FROM Forrester_SHIR_CRDR_VIEW__x
                        WHERE CASE_RECID__c = :caseRecIdFilter AND FY__c <= :financialYear AND FY__c >= :financialYearFilter];

        
        for(Forrester_SHIR_CRDR_VIEW__x caseCRDR : crdrList) {
            crdrLookup.put(caseCRDR.CASE_CRDR_RECID__c, caseCRDR);
        }
        /* Still to be determined */
        String classification;
        List<String> statuses = new List<String>();
        if (status != 'Finalised') {
            statuses.add(null);
            statuses.add(status);
            classification = ContentVersionClassification.DRAFT_CRDR;
        } else {
            statuses.add(status);
            classification = ContentVersionClassification.FINALISED_CRDR;
        }

        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId , ContentDocument.Title, ContentDocument.FileExtension,
                    ContentDocument.FileType,
                    ContentDocument.ContentSize,
                    ContentDocument.CreatedDate,
                    ContentDocument.ContentModifiedDate
                    FROM ContentDocumentLink WHERE LinkedEntityId in ( SELECT ID from Case_CRDR__c WHERE ExternalCaseCRDRId__c = :crdrLookup.keySet()  ) //Still to be determined, and Status__c = :statuses
                     AND ContentDocumentId IN (SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE RecordTypeId = :recordTypeId
                           AND Document_Classification__c = :classification)
                    ];
        
        Map<Id,Case_CRDR__c> caseCRDRMap = new Map<Id,Case_CRDR__c>([SELECT ID, ExternalCaseCRDRId__c from Case_CRDR__c WHERE ExternalCaseCRDRId__c = :crdrLookup.keySet() ]); //Still to be determined,  and Status__c = :statuses

        List<CRDRFileResponse> fileList = new List<CRDRFileResponse>();
        for(ContentDocumentLink documentLink : cdlList) {
            CRDRFileResponse file = new CRDRFileResponse();
            file.contentDocumentId = documentLink.ContentDocumentId;
            file.contentModifiedDate = documentLink.ContentDocument.ContentModifiedDate;
            file.fileExtension = documentLink.ContentDocument.FileExtension;
            file.title = documentLink.ContentDocument.Title;
            file.crdrDate = documentLink.ContentDocument.CreatedDate;
            if(caseCRDRMap.containsKey(documentLink.LinkedEntityId)) {
                Case_CRDR__c caseCRDR = caseCRDRMap.get(documentLink.LinkedEntityId);

                //Show all Finalised CRDR for the Previous FinancialYear but exclude any future CRDR from the scoped CRDR currently viewed.
                Forrester_SHIR_CRDR_VIEW__x shirCrdr = crdrLookup.get(caseCRDR.ExternalCaseCRDRId__c);
                Forrester_SHIR_CRDR_VIEW__x scopedCrdr = (caseCrdrRecId != null) ? crdrLookup.get(caseCrdrRecId) : null;
                Boolean mapContainKeys = scopedCrdr != null && shirCrdr != null;
                if (status == 'Finalised' && mapContainKeys && shirCrdr.CRDR_DATE__c > scopedCrdr.CRDR_DATE__c ) {
                    continue;
                }
                if (status != 'Finalised' && caseCRDR.ExternalCaseCRDRId__c != caseCrdrRecId ) {
                    //If viewing Drafts, only show the documents linked to the current Case CRDR
                    continue;
                }
                Forrester_SHIR_CRDR_VIEW__x externalCRDR = crdrLookup.get(caseCRDR.ExternalCaseCRDRId__c);
                file.financialYear =  externalCRDR != null ? externalCRDR.FY__c : null;
               // file.crdrDate = externalCRDR != null ? externalCRDR.CRDR_DATE__c : null;

            }
            fileList.add(file);
        }
        return fileList;
    }

    public class CRDRFileResponse {
        @AuraEnabled
        public String contentDocumentId;
        @AuraEnabled
        public String financialYear;
        @AuraEnabled
        public DateTime contentModifiedDate;
        @AuraEnabled
        public DateTime crdrDate;
        @AuraEnabled
        public String fileExtension;
        @AuraEnabled
        public String title;

    }

    public class AgreementFileResponse {
        @AuraEnabled
        public String contentDocumentId;
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String recordLabel;
    }

    public class AgreementSRAFileResponse {
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String accountNumber;
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String fileExtension;
        @AuraEnabled
        public String documentType;
        @AuraEnabled
        public String sponsorName;
        @AuraEnabled
        public String documentClassification;
        @AuraEnabled
        public String entitySubType;
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String recordLabel;


    }
}