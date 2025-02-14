public with sharing class CreateDocumentLinkJob implements Queueable, Database.AllowsCallouts    {

    public final List<Id> cvIds;

    public CreateDocumentLinkJob() {
        this.cvIds = new List<Id>();
    }

    public CreateDocumentLinkJob(List<ContentVersion> cvList) {
        this.cvIds = new List<Id>();
        for (ContentVersion cv : cvList) {
            this.cvIds.add(cv.Id);
        }
    }

    public List<ContentVersion> start(QueueableContext ctx) {
        System.debug('CreateDocumentLinkJob:start');

        if (cvIds != null && !cvIds.isEmpty()) {
            return [ SELECT Id, Title, Description, PathOnClient, TagCsv,  Document_Classification__c, ContentSize, VersionNumber,
                                                                     IsLatest,
                                                                     RecordType.Name,
                                                                     ContentDocumentId,
                                                                     Entity_RecId__c
                                                        FROM ContentVersion WHERE Id IN :this.cvIds ];
        } else {
            return new List<ContentVersion>();
        }
    }

    public void execute(QueueableContext ctx) {

        try {
            List<ContentVersion> scope = start(ctx);
            this.cvIds.clear();
            if(scope != null && !scope.isEmpty()) {
                System.debug('CreateDocumentLinkJob:scope ' + scope.size() );
                List<ContentVersion> caseCRDRs = new List<ContentVersion>();
                List<ContentVersion> agreements = new List<ContentVersion>();
                List<ContentVersion> ipias = new List<ContentVersion>();
                for(ContentVersion contentVersion : scope) {
                    if (contentVersion.RecordType.Name == 'CRDR' && contentVersion.Document_Classification__c.contains('CRDR')) {
                        caseCRDRs.add(contentVersion);
                        this.cvIds.add(contentVersion.Id);
                    }
                    if (contentVersion.RecordType.Name.contains('Agreement') ) {
                        agreements.add(contentVersion);
                    }
                    if (contentVersion.RecordType.Name.contains('IPIA') ) {
                        ipias.add(contentVersion);
                    }
                }
                updateCaseCRDREntityRecIds(caseCRDRs);
                new AgreementDocumentLinkProcessor().execute(agreements);
                new IPIADocumentLinkProcessor().execute(ipias);
            }

        } catch(Exception ex) {
            HandleLogException.logException(ex);
            throw ex;
        }
    }

    private static Log_Document_Link__c getLogDocumentLinkInstance(Id id, String pathOnClient ,String logType, String message){
        Log_Document_Link__c log = new Log_Document_Link__c();
        log.ContentVersion_Id__c = String.valueOf(id);
        log.Type__c = logType;
        log.Message__c = message;
        log.PathOnClient__c = pathOnClient;
        return log;

    }

    private void updateCaseCRDREntityRecIds(List<ContentVersion> contentVersions) {
        if(contentVersions.isEmpty()) {
            return;
        }
        List<ContentVersion> contentVersionUpdateList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinkInsertList = new List<ContentDocumentLink>();
        List<Log_Document_Link__c> logs = new List<Log_Document_Link__c>();

        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>(contentVersions);
        Map<Id, FileNameDefinition> fileDefMap = new Map<Id, FileNameDefinition>();
        Map<Id, List<Forrester_SHIR_CRDR_VIEW__x> > externalViewMap = new Map<Id, List<Forrester_SHIR_CRDR_VIEW__x> >();

        // Parse all PathOnClient values
        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = parseCRDRFileName(contentVersion.PathOnClient);
            if(parsed == null) {
                contentVersion.Entity_RecId__c = '-1' ; // will allow retry
                contentVersionUpdateList.add(contentVersion);
                logs.add(getLogDocumentLinkInstance(contentVersion.Id, contentVersion.PathOnClient,'Parsing-PathOnClient', 'Unable to parse'));
                continue;
            }
            fileDefMap.put(contentVersion.Id, parsed);
        }

        //Build the external object query filter sets
        Set<String> caseNumbers = new Set<String>();
        Set<String> financialYears = new Set<String>();
        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = fileDefMap.get(contentVersion.Id);
            if(parsed == null) {
                continue;
            }
            caseNumbers.add(StringUtils.removeNonNumericCharacters(parsed.caseNumber));
            financialYears.add(parsed.financialYear);
        }

        // Bulk query external object
        List<Forrester_SHIR_CRDR_VIEW__x> crdrs = ExternalObjectQuery.records([SELECT Id, CASE_RECID__c, CASE_CRDR_RECID__c, CRDR_DATE__c, FY__c, CONTRACT_CASE_NUM__c, CASE_NO_SUFFIX__c FROM Forrester_SHIR_CRDR_VIEW__x
                   WHERE CASE_NO_SUFFIX__c in :caseNumbers AND FY__c in :financialYears]);
        // Group by is not supported for external objects

        // Attach Documents to Last CRDR Container object
        Map<String, Forrester_SHIR_CRDR_VIEW__x> lastCrdrMap = new Map<String, Forrester_SHIR_CRDR_VIEW__x>();
        for(Forrester_SHIR_CRDR_VIEW__x crdr :crdrs) {
            String key = crdr.CASE_NO_SUFFIX__c + '-' + crdr.FY__c;
            if (lastCrdrMap.containsKey(key)) {
                Forrester_SHIR_CRDR_VIEW__x lastCrdr = lastCrdrMap.get(key);
                DateTime crdrDate = crdr.CRDR_DATE__c;
                DateTime lastCrdrDate = lastCrdr.CRDR_DATE__c;
                // Add the newer Crdr to the Map
                if (crdrDate > lastCrdrDate ) {
                    lastCrdrMap.put(key, crdr);
                }
            } else {
                lastCrdrMap.put(key, crdr);
            }
        }
        List<Forrester_SHIR_CRDR_VIEW__x> crdrFilterList = lastCrdrMap.values();

        // Reconstruct ContentVersion to External Object mapping
        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = fileDefMap.get(contentVersion.Id);
            if(parsed == null) {
                continue;
            }

            List<Forrester_SHIR_CRDR_VIEW__x> crdrList = new List<Forrester_SHIR_CRDR_VIEW__x>();
            for(Forrester_SHIR_CRDR_VIEW__x crdr :crdrFilterList) {
                if (crdr.CASE_NO_SUFFIX__c == StringUtils.removeNonNumericCharacters(parsed.caseNumber) && crdr.FY__c  == parsed.financialYear ){
                    crdrList.add(crdr);
                }
            }
            externalViewMap.put(contentVersion.Id, crdrList);

        }


        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = fileDefMap.get(contentVersion.Id);
            if(parsed == null) {
                continue;
            }

            List<Forrester_SHIR_CRDR_VIEW__x> crdrList = externalViewMap.get(contentVersion.Id);

            if(crdrList.isEmpty()) {
                logs.add(getLogDocumentLinkInstance(contentVersion.Id, contentVersion.PathOnClient, 'External-Object-Query', 'No rows found for caseNumber ' + parsed.caseNumber));
            }
            List<String> externalIds = new List<String>();
            for(Forrester_SHIR_CRDR_VIEW__x crdr :crdrList) {
                externalIds.add(crdr.CASE_CRDR_RECID__c);
            }

            List<Case_CRDR__c> existingContainers = [Select Id, ExternalCaseCRDRId__c from Case_CRDR__c where ExternalCaseCRDRId__c =:externalIds];
            if(existingContainers.isEmpty()) {
                logs.add(getLogDocumentLinkInstance(contentVersion.Id, contentVersion.PathOnClient, 'Container-Object-Query', 'No rows found for ExternalCaseCRDRId__c ' + String.join(externalIds,',')));
            }

            String entityRecId = '';
            for (Case_CRDR__c container : existingContainers ) {
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.LinkedEntityId = container.Id;
                conDocLink.ContentDocumentId = contentVersion.ContentDocumentId;
                // I = Inferred permission. The user’s permission is determined by the related record.
                // V = Viewer permission. The user can explicitly view but not edit the shared file.
                // C = Collaborator permission. The user can explicitly view and edit the shared file.
                conDocLink.ShareType = 'I';
                conDocLink.Visibility = 'AllUsers';
                contentDocumentLinkInsertList.add(conDocLink);
                if(entityRecId == '') {
                     entityRecId = container.ExternalCaseCRDRId__c;
                } else {
                    entityRecId += ',' + container.ExternalCaseCRDRId__c;
                }
            }
            Integer maxSize = 80;
            if(entityRecId.length() > maxSize ){
                entityRecId = entityRecId.substring(0, maxSize);
            }
            contentVersion.Entity_RecId__c = entityRecId != '' ? entityRecId : '-1'; // will allow retry

            contentVersionUpdateList.add(contentVersion);
        }
        if(!contentDocumentLinkInsertList.isEmpty()) {
            insert contentDocumentLinkInsertList;
        }
        if(!contentVersionUpdateList.isEmpty()) {
            update contentVersionUpdateList;
        }
        if(!logs.isEmpty()) {
            insert logs;
        }
    }


    @TestVisible
    private FileNameDefinition parseCRDRFileName(String pathOnClient) {
        List<Pattern> patterns = new List<Pattern>();
        patterns.add(Pattern.compile('^.([0-9]+).*-([0-9]+[A-Z]*)[ _]LLC-.*'));
        // All special cases where the standard naming convention was not used.
        patterns.add(Pattern.compile('^.([0-9]+).*-([0-9]+[A-Z]*)[ _]LLC_NG-.*'));
        patterns.add(Pattern.compile('^.([0-9]+).*-([0-9]+[A-Z]*)-[ ]?Ben Rockney.*'));
        patterns.add(Pattern.compile('^.([0-9]+).*-([0-9]+[A-Z]*)[ _-]equity-Ben Rockney.*'));
        patterns.add(Pattern.compile('^.([0-9]+).*-([0-9]+[A-Z]*)[ _-]equity-Deirdre.*'));
        patterns.add(Pattern.compile('^.([0-9]+).*LLC-([0-9]+[A-Z]*)[ _].*'));
        patterns.add(Pattern.compile('^.([0-9]+).*Broad Institute-([0-9]+[A-Z]*)[ _].*'));
        patterns.add(Pattern.compile('^.([0-9]+).*-([0-9]+[A-Z]*).pdf'));
        patterns.add(Pattern.compile('^.([0-9]+).*-([0-9]+[A-Z]*)[ ].*')); // This could be a problem!
        patterns.add(Pattern.compile('^.([0-9]+).*-[ ]?([0-9]{4,}+[A-Z]*)[ ]?-.*'));
        
        for(Pattern myPattern : patterns) {
            Matcher myMatcher = myPattern.matcher(pathOnClient);

            if (myMatcher.matches()) {
                FileNameDefinition parsed = new FileNameDefinition();
                parsed.financialYear = myMatcher.group(1) ;
                parsed.caseNumber = myMatcher.group(2) ;
                parsed.classification = pathOnClient.contains('Draft CRDR') ? ContentVersionClassification.DRAFT_CRDR : ContentVersionClassification.FINALISED_CRDR ;
                return parsed;
            }
        }
        return null;
    }

    @TestVisible
    private class FileNameDefinition {
        public String caseNumber;
        public String financialYear;
        public String classification;
    }

}