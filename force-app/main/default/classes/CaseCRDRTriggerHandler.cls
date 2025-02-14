public with sharing class CaseCRDRTriggerHandler {

    public static void onAfterInsert(List<Case_CRDR__c> caseCRDRList) {
        // this is a issue with the dates on this as its using SF date, not neccesarily the date from Forrester for this
        // is Case_CRDR__c.ModDate the one from DB? can we use that at all
        CaseCRDRTriggerHandler.insertAuditEvent(caseCRDRList, new Map<Id, Case_CRDR__c>());
    }

    public static void onAfterUpdate(List<Case_CRDR__c> caseCRDRList, Map<Id, Case_CRDR__c> oldCaseCRDRMap) {
        CaseCRDRTriggerHandler.insertAuditEvent(caseCRDRList, oldCaseCRDRMap);
        CaseCRDRTriggerHandler.onStatusChangeSyncToForrester (caseCRDRList, oldCaseCRDRMap);
        CaseCRDRTriggerHandler.onCrdrRecidChange(caseCRDRList, oldCaseCRDRMap);

        CaseCRDRTriggerHandler.onStatusChangeCloseFinanceTasks (caseCRDRList, oldCaseCRDRMap);
    }

    private static void onCrdrRecidChange(List<Case_CRDR__c> caseCRDRList, Map<Id, Case_CRDR__c> oldCaseCRDRMap) {
        List<Task> tasksToUpdate = new List<Task>();

        for (Case_CRDR__c caseCrdr : caseCRDRList) {
            if(caseCrdr.ExternalCaseCRDRId__c != oldCaseCRDRMap.get(caseCrdr.Id).ExternalCaseCRDRId__c) {
                List<Task> tasksForCRDR = TaskRepository.getTaskRecords(caseCrdr.Id);
                System.debug('onCrdrRecidChange tasksForCRDR:- ' + tasksForCRDR); 
                for (Task taskToChange : tasksForCRDR) {
                    taskToChange.CRDR__c = caseCrdr.ExternalCaseCRDRId__c;
                    tasksToUpdate.add(taskToChange);
                }
            }
        }

        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
    }

    /**
     * Close Finance Tasks when status is DRAFT and Finalized:
     */
    private static void onStatusChangeCloseFinanceTasks(List<Case_CRDR__c> caseCRDRList, Map<Id, Case_CRDR__c> oldCaseCRDRMap) {
        Group vQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Finance_Queue' AND Type = 'Queue'];
        
        List<Id> crdrsWithStatusChanges = new List<Id>();
        List<Task> tasksToClose = new List<Task>();

        for (Case_CRDR__c currentCrdr : caseCRDRList) {
            String newStatus = currentCrdr.Status__c;

            if (newStatus == 'DRAFT' || newStatus == 'FINALIZED') {
                crdrsWithStatusChanges.add(currentCrdr.Id);
            }
        }

        List<Task> financeQueueTasksForCrdrs = [SELECT Id, WhatId, OwnerId, Status 
                                                FROM Task 
                                                WHERE OwnerId = :vQueue.Id 
                                                    AND WhatId = :crdrsWithStatusChanges  
                                                    AND Status != 'Completed'];
        
        for (Task task : financeQueueTasksForCrdrs) {
            task.Status = 'Completed';
            tasksToClose.add(task);
        }
        if (!tasksToClose.isEmpty()) {
            update tasksToClose;
        }
    }

    private static void onStatusChangeSyncToForrester(List<Case_CRDR__c> caseCRDRList, Map<Id, Case_CRDR__c> oldCaseCRDRMap) {
        List<String> futureRecordIds = new List<String>();
        for (Case_CRDR__c crdr : caseCRDRList) {
            if(crdr.Status__c != oldCaseCRDRMap.get(crdr.Id).Status__c) {
                futureRecordIds.add(crdr.Id);
            }
        }
        if(!futureRecordIds.isEmpty()) {
            CaseCRDRTriggerHandler.futureExternalObjectSync(futureRecordIds);
        }
    }

    @Future(callout=true)
    public static void futureExternalObjectSync(List<String> recordIds) {
        Map<String, Case_CRDR__c> vCaseCRDRMap = new Map<String, Case_CRDR__c>();
        Map<String, Forrester_SHIR_CASE_CRDR_STATUS__x> externalMap = new Map<String, Forrester_SHIR_CASE_CRDR_STATUS__x>();
        // Get the latest current value, this will account for Concurrent updates to the same object. The execution order off a future method is not guaranteed.
        for (Case_CRDR__c event: [select Id, ExternalCaseCRDRId__c, Status__c from Case_CRDR__c where Id = :recordIds ]) {
            vCaseCRDRMap.put(event.ExternalCaseCRDRId__c, event);
        }



        Integer batchSize = 50;
        List<Forrester_SHIR_CASE_CRDR_STATUS__x> crdrStatuses = ExternalObjectQuery.records(
                                                        ExternalObjectRepository.fetchSObjectsByExternalRecIds(new List<String>(vCaseCRDRMap.keySet()), 'Forrester_SHIR_CASE_CRDR_STATUS__x', 'CASE_CRDR_RECID__c', new List<String> {'CRDR_STATUS__c'}, batchSize)
                                                        );

        for (Forrester_SHIR_CASE_CRDR_STATUS__x crdrStatus : crdrStatuses ) {
            externalMap.put(crdrStatus.CASE_CRDR_RECID__c, crdrStatus);
        }

        List<Forrester_SHIR_CASE_CRDR_STATUS__x> updateList = new List<Forrester_SHIR_CASE_CRDR_STATUS__x>();
        List<Forrester_SHIR_CASE_CRDR_STATUS__x> insertList = new List<Forrester_SHIR_CASE_CRDR_STATUS__x>();

        for (String recId :  vCaseCRDRMap.keySet()) {
            Case_CRDR__c crdr = vCaseCRDRMap.get(recId);

            Forrester_SHIR_CASE_CRDR_STATUS__x crdrStatus = null;

            if(externalMap.containsKey(recId)) {
                crdrStatus = externalMap.get(recId);
               	crdrStatus.CRDR_STATUS__c = crdr.Status__c;
               	updateList.add(crdrStatus);
            } else {
                crdrStatus = new Forrester_SHIR_CASE_CRDR_STATUS__x();
                crdrStatus.CASE_CRDR_RECID__c = recId ;
                crdrStatus.CRDR_STATUS__c = crdr.Status__c;
                insertList.add(crdrStatus);
            }
        }
        if (!updateList.isEmpty()) {
            Database.updateAsync(updateList); // updateImmediate will fail, pending transaction need to commit first
        }
        if (!insertList.isEmpty()) {
            Database.insertAsync(insertList);  // insertImmediate will fail, pending transaction need to commit first
        }
    }

    private static void insertAuditEvent(List<Case_CRDR__c> caseCRDRList, Map<Id, Case_CRDR__c> oldCaseCRDRMap) {
        List<Case_CRDR_Audit_Event__c> auditEventList = new List<Case_CRDR_Audit_Event__c>();
        Id currentUserId = UserInfo.getUserId();
        String currentUserNames = UserInfo.getName();

        for (Case_CRDR__c caseCrdr : caseCRDRList) {
            if(caseCrdr.Status__c != oldCaseCRDRMap.get(caseCrdr.Id)?.Status__c) {
                // ignore creation of audit trail for CRDRs created in 2023, as this was on Forrester
                if (caseCrdr.Status__c == 'FINALIZED' && caseCrdr.Name.contains('[2023]')) { 
                    continue;
                }

                String oldEventStatus = oldCaseCRDRMap.get(caseCrdr.Id)?.Status__c;
                Case_CRDR_Audit_Event__c auditEvent = new Case_CRDR_Audit_Event__c();

                auditEvent.Case_CRDR__c = caseCrdr.Id;
                auditEvent.Status__c = caseCrdr.Status__c;
                auditEvent.Message__c = getAuditEventMessage(oldEventStatus, caseCrdr.Status__c, currentUserId, currentUserNames);
                auditEvent.Subject__c = getAuditEventSubject(oldEventStatus, caseCrdr.Status__c);

                auditEventList.add(auditEvent);
            }
        }
        if (!auditEventList.isEmpty()) {
            insert auditEventList;
        }
    }


    private static String getAuditEventMessage(String oldEventType, String eventType, Id currentUserId, String currentUserNames) {
        String message = '';

        if (oldEventType == null && eventType == 'AWAITING_DRAFT') {
            message = '';
        }
        else if (oldEventType == 'IN_REVIEW' && eventType == 'AWAITING_DRAFT') {
            message = '{' + currentUserId + ';' + currentUserNames + '} has requested adjustments';
        }
        else {
            switch on eventType {
                when 'DRAFT' {
                    message = 'CRDR Draft has been created';
                }
                when 'IN_REVIEW' {
                    message = '{' + currentUserId + ';' + currentUserNames + '} has started reviewing the CRDR';
                }
                when 'APPROVED' {
                    message = '{' + currentUserId + ';' + currentUserNames + '} has approved the CRDR';
                }
                when 'FINALIZED' {
                    message = '{' + currentUserId + ';' + currentUserNames + '} has finalized the CRDR';
                }
            }
        }

        return message;
    }

    private static String getAuditEventSubject(String oldEventType, String eventType) {
        String subject = '';

        if (oldEventType == null && eventType == 'AWAITING_DRAFT') {
            subject = '';
        }
        else if (oldEventType == 'IN_REVIEW' && eventType == 'AWAITING_DRAFT') {
            subject = 'Sent for Adjustment/Feedback';
        }
        else {
            switch on eventType {
                when 'DRAFT' {
                    subject = 'Draft Created';
                }
                when 'IN_REVIEW' {
                    subject = 'In Review';
                }
                when 'APPROVED' {
                    subject = 'Approved';
                }
                when 'FINALIZED' {
                    subject = 'Finalized';
                }
            }
        }

        return subject;
    }
}