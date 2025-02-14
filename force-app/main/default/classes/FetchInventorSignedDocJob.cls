public with sharing class FetchInventorSignedDocJob implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Integer retryCount = Integer.ValueOf(
            ConfigurationBuilder.getConfigurationToString(
                'batchJobMaxNumberOfRetry'
            )
        );
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Has_Processed__c,
                    Retry_Count__c,
                    Record_Id__c,
                    sObject_Name__c
                FROM Async_Request__c
                WHERE
                    Has_Processed__c = FALSE
                    AND Retry_Count__c < :retryCount
                    AND sObject_Name__c = 'DisclosureInventor__c'
                    AND Job_Name__c = 'FetchInventorSignedDocJob'
            ]
        );
    }

    public void execute(
        Database.BatchableContext bc,
        List<Async_Request__c> scopes
    ) {
        // We can not do a callout if there is transactions that have not committed.

        List<ContentDocumentLink> conDocLinkInsert = new List<ContentDocumentLink>();
        List<Async_Request__c> asyncRequestUpdate = new List<Async_Request__c>();
        List<Log_Exception__c> logExceptions = new List<Log_Exception__c>();

        Set<String> inventorIds = new Set<String>();
        for (Async_Request__c async : scopes) {
            inventorIds.add(async.Record_Id__c);
        }
        List<DisclosureInventor__c> inventors = [
            SELECT Id, Disclosure__r.Id
            FROM DisclosureInventor__c
            WHERE Id = :inventorIds
        ];

        Map<Id, DisclosureInventor__c> inventorMap = new Map<Id, DisclosureInventor__c>(
            inventors
        );
        Map<Id, Blob> docusignMap = new Map<Id, Blob>();

        // Get all the blobs and add to inventor map.
        for (Async_Request__c async : scopes) {
            try {
                DisclosureInventor__c inventor = inventorMap.get(
                    async.Record_Id__c
                );

                Id disclosureId = inventor.Disclosure__r.Id;
                Id inventorId = inventor.Id;
                System.debug(
                    'FetchInventorSignedDocJob disclosureId:- ' +
                    disclosureId +
                    ', inventorId:- ' +
                    inventorId +
                    ' Blob START'
                );

                DocuSignService docuSignService = new DocuSignService();
                Blob inventorDocBlob = docuSignService.getDocumentForInventor(
                    disclosureId,
                    inventorId
                );
                docusignMap.put(inventorId, inventorDocBlob);
                System.debug(
                    'FetchInventorSignedDocJob disclosureId:- ' +
                    disclosureId +
                    ', inventorId:- ' +
                    inventorId +
                    ' Blob END'
                );
            } catch (exception ex) {
                logExceptions.add(HandleLogException.logExceptionInstance(ex));
            }
        }

        for (Async_Request__c async : scopes) {
            try {
                DisclosureInventor__c inventor = inventorMap.get(
                    async.Record_Id__c
                );

                Id disclosureId = inventor.Disclosure__r.Id;
                Id inventorId = inventor.Id;
                System.debug(
                    'FetchInventorSignedDocJob disclosureId:- ' +
                    disclosureId +
                    ', inventorId:- ' +
                    inventorId +
                    ' CV START'
                );

                Blob inventorDocBlob = docusignMap.get(inventorId);

                System.debug(
                    'FetchInventorSignedDocJob inventorDocBlob received create ContentVersion'
                );

                Id cvDisclosureInventorRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
                    .get('DisclosureInventor')
                    .getRecordTypeId();
                ContentVersion cv = new ContentVersion();
                cv.Title = 'DocuSign_' + inventorId + '.pdf'; // Display name of the files
                cv.PathOnClient = 'DocuSign_' + inventorId + '.pdf';
                cv.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                cv.VersionData = inventorDocBlob;
                cv.Document_Classification__c = 'Signed Disclosure';
                cv.RecordTypeId = cvDisclosureInventorRecordTypeId;

                //Insert ContentVersion, need the Id.
                insert cv;

                System.debug('ContentVersion inventorDocBlob Created');

                // First get the Content Document Id from ContentVersion Object
                Id conDoc = [
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :cv.Id
                ]
                .ContentDocumentId;
                //create ContentDocumentLink  record
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.LinkedEntityId = inventorId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                conDocLink.ContentDocumentId = conDoc; //ContentDocumentId Id from ContentVersion
                //V - Viewer permission. C - Collaborator permission. I - Inferred permission
                conDocLink.ShareType = 'I';
                conDocLink.Visibility = 'AllUsers';

                // We can do all the inserts later
                conDocLinkInsert.add(conDocLink);
                System.debug(
                    'FetchInventorSignedDocJob disclosureId:- ' +
                    disclosureId +
                    ', inventorId:- ' +
                    inventorId +
                    ' CV END'
                );

                async.Has_Processed__c = true;
                asyncRequestUpdate.add(async);
            } catch (exception ex) {
                logExceptions.add(HandleLogException.logExceptionInstance(ex));

                async.Retry_Count__c =
                    Integer.valueOf(async.Retry_Count__c) + 1;
                async.Has_Processed__c = false;
                asyncRequestUpdate.add(async);
            }
        }
        if (!logExceptions.isEmpty()) {
            insert logExceptions;
        }

        if (!conDocLinkInsert.isEmpty()) {
            insert conDocLinkInsert;
        }
        if (!asyncRequestUpdate.isEmpty()) {
            update asyncRequestUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug(
            'FetchInventorSignedDocJob Finished JobId:- ' + bc.getJobId()
        );
    }
}