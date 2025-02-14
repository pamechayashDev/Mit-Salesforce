public with sharing class AgreementDocumentLinkProcessor extends DocumentLinkProcessor {


    protected override void createDocumentLink(List<ContentVersion> contentVersions) {
        if(contentVersions.isEmpty()) {
            return;
        }
        List<ContentVersion> contentVersionUpdateList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinkInsertList = new List<ContentDocumentLink>();
        List<Log_Document_Link__c> logs = new List<Log_Document_Link__c>();

        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>(contentVersions);
        Map<Id, FileNameDefinition> fileDefMap = new Map<Id, FileNameDefinition>();
        Map<Id, List<Forrester_SHIR_AGREEMENT_VIEW__x> > externalViewMap = new Map<Id, List<Forrester_SHIR_AGREEMENT_VIEW__x> >();

        // Parse all PathOnClient values
        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = parsePathOnClient(contentVersion.PathOnClient, contentVersion.Entity_RecId__c);
            if(parsed == null) {
                contentVersion.Entity_RecId__c = '-1' ; // will allow retry
                contentVersionUpdateList.add(contentVersion);
                logs.add(getLogDocumentLinkInstance(contentVersion.Id, contentVersion.PathOnClient,'Parsing-PathOnClient', 'Unable to parse'));
                continue;
            }
            fileDefMap.put(contentVersion.Id, parsed);
        }

        //Build the SObject query filter sets
        Set<String> agreementNumbers = new Set<String>();
        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = fileDefMap.get(contentVersion.Id);
            if(parsed == null) {
                continue;
            }
            agreementNumbers.add(parsed.agreementNumber);
        }

        // Bulk query SObject
        List<Agreement__c> agreementBulkList = [Select Id, ExternalAgreement__c from Agreement__c where ExternalAgreement__c =:agreementNumbers ];
        Map<String, Agreement__c> agreementLookup = new Map<String, Agreement__c>();
        for(Agreement__c agreement : agreementBulkList) {
            agreementLookup.put(agreement.ExternalAgreement__c, agreement);
        }

        for(ContentVersion contentVersion : contentVersions) {
            FileNameDefinition parsed = fileDefMap.get(contentVersion.Id);
            if(parsed == null) {
                continue;
            }

            Agreement__c agreement = agreementLookup.get(parsed.agreementNumber);
            if (agreement == null) {
                contentVersion.Entity_RecId__c = '-1' ; // will allow retry
                contentVersionUpdateList.add(contentVersion);

                logs.add(getLogDocumentLinkInstance(contentVersion.Id, contentVersion.PathOnClient, 'Container-Object-Query', 'No rows found for ExternalAgreement__c ' + parsed.agreementNumber ));
                continue;
            }


            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.LinkedEntityId = agreement.Id;
            conDocLink.ContentDocumentId = contentVersion.ContentDocumentId;
            conDocLink.ShareType = 'I';
            conDocLink.Visibility = 'AllUsers';
            contentDocumentLinkInsertList.add(conDocLink);
            String entityRecId = String.valueOf(agreement.ExternalAgreement__c);

            contentVersion.Entity_RecId__c = entityRecId;
            Boolean updateClassification = !isImageSiloDocument(contentVersion);
            if(parsed.classification != null && updateClassification) {
                contentVersion.Document_Classification__c =  parsed.classification;
            }
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

    Boolean isImageSiloDocument(ContentVersion cv) {
        // Do not update the Classification if the data was uploaded from ImageSilo Source
        if (cv.TagCsv != null && cv.TagCsv != null && cv.TagCsv.contains('ImageSilo')) { // Will revisit this when importing NewSilo Documents
            return true;
        }
        return false;
    }


    @TestVisible
    protected override FileNameDefinition parsePathOnClient(String pathOnClient, String entityRecId) {
        // We have a Entity RecId, use the value.
        if (entityRecId != '-1') {
            FileNameDefinition parsed = new FileNameDefinition();
            parsed.agreementNumber = StringUtils.removeNonNumericCharacters(entityRecId); // example '4912302.b'
            parsed.classification = getClassification(pathOnClient) ;
            return parsed;
        }

        List<Pattern> patterns = new List<Pattern>();
        patterns.add(Pattern.compile('(?i).*[\\/\\\\]([0-9]+)-[\\[].*pdf'));
        patterns.add(Pattern.compile('(?i).*[\\/\\\\]([0-9]+).pdf'));
        patterns.add(Pattern.compile('(?i).*[\\/\\\\]([0-9]+)[ ]*[-]+[^\\[].*pdf'));

        for(Pattern myPattern : patterns) {
            Matcher myMatcher = myPattern.matcher(pathOnClient);

            if (myMatcher.matches()) {
                FileNameDefinition parsed = new FileNameDefinition();
                parsed.agreementNumber = myMatcher.group(1) ;
                parsed.classification = null;
                return parsed;
            }
        }
        return null;
    }
   @TestVisible
   private String getClassification(String pathOnClient) {
        Map<Pattern, String> patterns = new Map<Pattern, String>();
        patterns.put(Pattern.compile('(?i).*[\\/](License).*'), ContentVersionClassification.ORIGINAL_DOCUMENT);

        for(Pattern myPattern : patterns.keySet()) {
            Matcher myMatcher = myPattern.matcher(pathOnClient);
            if (myMatcher.matches()) {
                return patterns.get(myPattern);
            }
        }
        return null;
   }


}