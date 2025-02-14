@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class ExternalObjectRepository {
    
    @AuraEnabled(cacheable=true)
    public static SObject getContainerObjectId(String externalObjRecId,
                                               String externalObjApiName,
                                               String externalObjRecIdFieldName,
                                               String matchingContainerObject,
                                               String containerObjRecIdFieldName
    ) {
       
        String theExternalObjectQuery = 'SELECT Id, ' + String.escapeSingleQuotes(externalObjRecIdFieldName) 
                                            + ' from ' + String.escapeSingleQuotes(externalObjApiName)
                                            + ' WHERE Id = \'' + String.escapeSingleQuotes(externalObjRecId) + '\' LIMIT 1';
        List<SObject> results = Database.query(theExternalObjectQuery);

        if(!results.isEmpty()) {

            String recId = (String)results[0].get(externalObjRecIdFieldName);
            System.debug('recId:- ' + recId);

            //theContainerObjectQuery:- SELECT Id, Name, ExternalCaseCRDRId__c from Case_CRDR__c WHERE ExternalCaseCRDRId__c = 1574340
            String theContainerObjectQuery = 'SELECT Id, Name, ' 
                                                + String.escapeSingleQuotes(containerObjRecIdFieldName) 
                                                + ' from '  + String.escapeSingleQuotes(matchingContainerObject)
                                                + ' WHERE ' + String.escapeSingleQuotes(containerObjRecIdFieldName) 
                                                + ' = \'' + String.escapeSingleQuotes(recId) + '\'';
            System.debug('theContainerObjectQuery:- ' + theContainerObjectQuery);

            List<SObject> results2 = Database.query(theContainerObjectQuery);
            
            return results2[0];
        } else {
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> getContainerObjectsByExternalRecid(list<String> externalObjRecIds,
                                               String externalObjApiName,
                                               String externalObjRecIdFieldName,
                                               String matchingContainerObject,
                                               String containerObjRecIdFieldName
    ) {
        
        system.debug('externalObjRecIds>>'+externalObjRecIds);
       
        String theExternalObjectQuery = 'SELECT Id, ' + String.escapeSingleQuotes(externalObjRecIdFieldName) 
                                            + ' from ' + String.escapeSingleQuotes(externalObjApiName)
                                            + ' WHERE Id In :externalObjRecIds';
        List<SObject> results = Database.query(theExternalObjectQuery);

        if(!results.isEmpty()) {
            
            list<String> recIds = new list<String>();
            for(SObject rec:results){
                recIds.add((String)rec.get(externalObjRecIdFieldName));
                
            }

            System.debug('recIds:- ' + recIds);
            
            String theContainerObjectQuery = 'SELECT Id, Name, ' 
                + String.escapeSingleQuotes(containerObjRecIdFieldName) 
                + ' from '  + String.escapeSingleQuotes(matchingContainerObject)
                + ' WHERE ' + String.escapeSingleQuotes(containerObjRecIdFieldName) 
                + ' In :recIds';
            
            System.debug('theContainerObjectQuery:- ' + theContainerObjectQuery);
            List<SObject> results2 = Database.query(theContainerObjectQuery);
            System.debug('results2>>'+results2);
            return results2;
        } else {
            return null;
        }
    }

    /* External OData service throw 414 error [Url to long], if the Id List is to large */
    @AuraEnabled(cacheable=true)
    public static List<SObject> fetchSObjectsByExternalRecIds(List<String> externalObjRecIds,
                                               String externalObjApiName,
                                               String externalObjRecIdFieldName,
                                               List<String> externalObjFieldNames,
                                               Integer batchSize
    ) {

        System.debug('externalObjRecIds>>'+externalObjRecIds);

        Set<String> fields = new Set<String>();
        fields.add('Id');
        fields.add(String.escapeSingleQuotes(externalObjRecIdFieldName));
        if (externalObjFieldNames != null) {
            for (String fieldName : externalObjFieldNames ) {
                fields.add(String.escapeSingleQuotes(fieldName));
            }
        }
        String fieldNames = String.join(fields, ',');

        String theExternalObjectQuery = 'SELECT ' + fieldNames
                                        + ' from ' + String.escapeSingleQuotes(externalObjApiName)
                                        + ' WHERE ' + externalObjRecIdFieldName + ' In :batchFilter';

        return fetchExternalQueryByExternalRecIds(externalObjRecIds, theExternalObjectQuery, batchSize);
    }

 // The query must of the form 'select id from external__x where Id in :batchFilter'
  @AuraEnabled(cacheable=true)
    public static List<SObject> fetchExternalQueryByExternalRecIds(List<String> externalObjRecIds,
                                               String theExternalObjectQuery,
                                               Integer batchSize
    ) {

        System.debug('externalObjRecIds>>'+externalObjRecIds);

        if (!theExternalObjectQuery.contains(':batchFilter')) {
            throw new AuraHandledException('Missing [:batchFilter] filter in query');
        }

       List<SObject> sObjectList = new List<SObject>();
       Set<String> batchFilter = new Set<String>();
       for (String externalObjRecId: externalObjRecIds) {
           batchFilter.add(externalObjRecId);
           if (batchFilter.size() >= batchSize) {
               sObjectList.addAll( Database.query(theExternalObjectQuery) );
               batchFilter.clear();
           }
       }
       if (!batchFilter.isEmpty()) {
           sObjectList.addAll( Database.query(theExternalObjectQuery) );
       }
       return sObjectList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Forrester_SHIR_CASE_CRDR_REV_BREAKDOW__x> getIncomeBreakdown(String crdrRecordId, String agreementRecIdStr) {
        System.debug('crdrRecordId:- ' + crdrRecordId);
        System.debug('agreementRecIdStr:- ' + agreementRecIdStr);

        Forrester_SHIR_CRDR_VIEW__x externalCaseCrdr = [
            SELECT Id, CASE_CRDR_RECID__c from Forrester_SHIR_CRDR_VIEW__x WHERE Id = :crdrRecordId LIMIT 1
        ];
        String crdrRecId = externalCaseCrdr.CASE_CRDR_RECID__c;
        List<Forrester_SHIR_CASE_CRDR_REV_BREAKDOW__x> incomeBreakdown = [SELECT Id, INVOICE_NUM__c, 
                                                                            INVOICE_TYPE__c, 
                                                                            COLLECTED_AMT__c, 
                                                                            INVOICE_LINE_ITEM_DESC__c, AGREEMENT_RECID__c,
                                                                            //format(COLLECTED_DATE__c) COLLECTED_DATE__c
                                                                            COLLECTED_DATE__c, RECEIPT_DATE__c,
                                                                            REV_BREAKDOWN_ID__r.AGREEMENT_RECID__r.Id
                                                                        FROM Forrester_SHIR_CASE_CRDR_REV_BREAKDOW__x 
                                                                        WHERE CASE_CRDR_RECID__c = :crdrRecId
                                                                        AND AGREEMENT_RECID__c = :agreementRecIdStr];
        
        return incomeBreakdown;
    }

    @AuraEnabled(cacheable=true)
    public static List<Forrester_FISCAL_YEAR__x> getFiscalYears() {
        List<Forrester_FISCAL_YEAR__x> fiscalYears = [
                                                        SELECT FY__c, BEGIN_DATE__c, END_DATE__c 
                                                        FROM Forrester_FISCAL_YEAR__x 
                                                        ORDER BY FY__c DESC 
                                                        LIMIT 5
                                                     ]
                                                    ;

        return fiscalYears;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<Forrester_SHIR_CASE_FH_INCOME_SUMMARY__x> getPatentBreakdownIncomeSummary(String caseRecId) {
        if (String.isEmpty(caseRecId)) {
            return new List<Forrester_SHIR_CASE_FH_INCOME_SUMMARY__x>();
        }

        return [SELECT Id,
                AGREEMENT_RECID__c,
                AGREEMENT_RECID__r.Id,
                AGREEMENT_TYPE__c,
                AMOUNT__c,
                CASE_RECID__c,
                INCOME_TYPE__c,
                LICENSEE__c
        FROM Forrester_SHIR_CASE_FH_INCOME_SUMMARY__x
        WHERE CASE_RECID__c = :caseRecId];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Forrester_SHIR_CASE_FH_PATENT_COSTS_D__x> getOutstandingPatentCosts(String caseRecId) {
        if (String.isEmpty(caseRecId)) {
            return new List<Forrester_SHIR_CASE_FH_PATENT_COSTS_D__x>();
        }

        return [SELECT
                    Id,
                    AGREEMENT_NUM__c,
                    AGREEMENT_STATUS__c,
                    AGREEMENT_STATUS_DESCRIPTION__c,
                    AGREEMENT_TYPE__c,
                    CASE_RECID__c,
                    DOMESTIC__c,
                    FOREIGN__c,
                    LICENSEE__c,
                    LINE_TYPE__c,
                    SORT_ORDER__c,
                    TOTAL__c
            FROM Forrester_SHIR_CASE_FH_PATENT_COSTS_D__x
            WHERE CASE_RECID__c = :caseRecId];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Forrester_SHIR_CASE_UNPAID_INVOICES__x> getUnpaidInvoices(String caseRecId) {
        if (String.isEmpty(caseRecId)) {
            return new List<Forrester_SHIR_CASE_UNPAID_INVOICES__x>();
        }

        return [SELECT
                Id,
                ADD_DATE__c,
                AGREEMENT_RECID__c,
                CASE_RECID__c,
                DOM_FOREIGN__c,
                DUE_DATE__c,
                INVOICE_LINE_ITEM_AMT__c,
                INVOICE_NUM__c,
                INVOICE_RECID__c,
                LICENSEE__c,
                AGREEMENT_RECID__r.Id
        FROM Forrester_SHIR_CASE_UNPAID_INVOICES__x
        WHERE CASE_RECID__c = :caseRecId];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Forrester_SHIR_COMMENTS_VIEW__x> getExternalComments(String sourceRecId, String table, String context) {
        if (String.isEmpty(sourceRecId)) {
            return new List<Forrester_SHIR_COMMENTS_VIEW__x>();
        }

        return [SELECT
                Id,
                COMMENT_EXT__c,
                COMMENT_SEQ__c,
                COMMENT_TEXT__c,
                ADD_DATE__c,
                ADD_USER__c,
                MOD_DATE__c
        FROM Forrester_SHIR_COMMENTS_VIEW__x
        WHERE SOURCE_RECID__c = :sourceRecId AND TABLE_NAME__c =: table AND CONTEXT_NAME__c = :context
        ORDER BY MOD_DATE__c DESC, COMMENT_SEQ__c DESC, COMMENT_EXT__c ASC
        ];
    }

    public static List<Forrester_CONTACT__x> getExternalContactByMitIds(List<String> mitIds) {
        if (mitIds.isEmpty()) {
            System.debug('🐞 ~ ExternalObjectRepository ~ getExternalContactByMitIds: No MitIds provided returning empty list');
            return new List<Forrester_CONTACT__x>();
        }
        Integer batchSize = 50;
        String soqlQuery = ' SELECT CONTACT_RECID__c, MIT_ID__c, FIRST_NAME__c, LAST_NAME__c, MIDDLE_NAME__c, MIT_EMPL_FLAG__c, INSTITUTION_RECID__c,';
        soqlQuery += 'IPIA_SIGNED_DATE__c, IPIA_SIGNED_FLAG__c, ALTERNATE_IPIA_AGMT_DATE__c, ALTERNATE_IPIA_AGMT_FLAG__c, ALTERNATE_IPIA_TYPE__c,';
        soqlQuery += ' IPIA_COMMENT__c FROM Forrester_CONTACT__x WHERE MIT_ID__c IN :batchFilter ';

        if (Test.isRunningTest()) {
            System.debug('🐞 ~ ExternalObjectRepository ~ getExternalContactByMitId: Test is running, returning mock data.');
            return ExternalQueryMock.getInstance()
                .query('Forrester_CONTACT__x:Ids');
        }
        // Execute SOQL query
        return ExternalObjectRepository.fetchExternalQueryByExternalRecIds(new List<String>(mitIds), soqlQuery, batchSize);

    }
    public static List<Forrester_IPIA_TYPES__x> getExternalIpiaTypesByName(List<String> typeNames) {
        if (typeNames.isEmpty()) {
            System.debug('🐞 ~ ExternalObjectRepository ~ getExternalIpiaTypesByName: No Type names provided returning empty list');
            return new List<Forrester_IPIA_TYPES__x>();
        }
        Integer batchSize = 50;
        String soqlQuery = ' SELECT IPIA_TYPE__c ';
        soqlQuery += ' FROM Forrester_IPIA_TYPES__x WHERE IPIA_TYPE__c IN :batchFilter ';

        if (Test.isRunningTest()) {
            System.debug('🐞 ~ ExternalObjectRepository ~ getExternalIpiaTypesByName: Test is running, returning mock data.');
            return ExternalQueryMock.getInstance()
                .query('Forrester_IPIA_TYPES__x:Ids');
        }
        // Execute SOQL query
        return ExternalObjectRepository.fetchExternalQueryByExternalRecIds(new List<String>(typeNames), soqlQuery, batchSize);

    }
}