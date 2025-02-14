/**
 * Created by Andreas du Preez on 2024/03/18.
 */

public with sharing class CrdrController {
    private static final String FINANCE_QUEUE = 'Finance_Queue';

    /**
     * This function retrieves related CRDRs and a count of open tasks for a given CRDR case.
     *
     * @param caseCrdrRecId The ID of the case for which related CRDR tasks are to be fetched.
     * @return List<RelatedCRDRTasks> A list of RelatedCRDRs objects, each representing a related CRDR.
     */
    @AuraEnabled
    public static List<RelatedCRDRs> getRelatedCRDROpenTaskCount(String caseCrdrRecId) {
        List<RelatedCRDRs> forresterRelatedCrdrsList = new List<RelatedCRDRs>();
        List<String> forresterRelatedCrdrsIds = new List<String>();

        // Do callout and fetch related CRDRs for the given case.
        if (Test.isRunningTest())
        {
            RelatedCRDRs testRelatedCRDR = CrdrControllerTest.getRelatedCRDRTestData();
            forresterRelatedCrdrsList.add(testRelatedCRDR);
            forresterRelatedCrdrsIds.add(testRelatedCRDR.ForresterCaseCrdrRecId);
        }
        else {
                for (Forrester_SHIR_CRDR_RELATED_CRDRS_VIE__x forresterCaseCrdr : [
                    SELECT
                            RELATED_CASE_CRDR_RECID__r.Id,
                            CASE_CRDR_RECID__c,
                            RELATED_CASE_CRDR_RECID__r.CRDR_NAME__c,
                            CASE_RECID__r.Id,
                            CASE_RECID__r.CONTRACT_CASE_NUM__c,
                            AGREEMENT_RECID__r.Id,
                            AGREEMENT_RECID__c,
                            HAS_OPEN_CHK_LIST__c,
                            RELATED_HAS_OPEN_CHK_LIST__c,
                            TLO_NAME__c,
                            RELATED_CASE_CRDR_RECID__r.TLO_EMAIL__c

                    FROM Forrester_SHIR_CRDR_RELATED_CRDRS_VIE__x
                    WHERE CASE_CRDR_RECID__c = :caseCrdrRecId //current CASE_CRDR_RECID that is being looked at                    
            ]) {
                    forresterRelatedCrdrsIds.add(forresterCaseCrdr.RELATED_CASE_CRDR_RECID__c);
                    forresterRelatedCrdrsList.add(
                            new RelatedCRDRs(
                                    forresterCaseCrdr.RELATED_CASE_CRDR_RECID__r.Id,
                                    forresterCaseCrdr.RELATED_CASE_CRDR_RECID__c,
                                    forresterCaseCrdr.RELATED_CASE_CRDR_RECID__r.CRDR_NAME__c,
                                    forresterCaseCrdr.CASE_RECID__r.Id,
                                    forresterCaseCrdr.CASE_RECID__r.CONTRACT_CASE_NUM__c,
                                    forresterCaseCrdr.AGREEMENT_RECID__r.Id,
                                    forresterCaseCrdr.AGREEMENT_RECID__c,
                                    forresterCaseCrdr.RELATED_HAS_OPEN_CHK_LIST__c,
                                    forresterCaseCrdr.TLO_NAME__c,
                                    forresterCaseCrdr.RELATED_CASE_CRDR_RECID__r.TLO_EMAIL__c
                            )
                    );
            }

            // Include the current CRDR in the list
            forresterRelatedCrdrsIds.add(caseCrdrRecId);
            Forrester_SHIR_CRDR_VIEW__x forresterCaseCrdr = [SELECT
                        Id,
                        CASE_CRDR_RECID__c,
                        CRDR_NAME__c,
                        CASE_RECID__c,
                        CONTRACT_CASE_NUM__c,
                        HAS_OPEN_CHK_LIST__c,
                        (SELECT AGREEMENT_RECID__r.Id, AGREEMENT_RECID__c FROM Forrester_Case_CRDR_Revenues__r),
                        TLO_NAME__c,
                        TLO_EMAIL__c
                    FROM Forrester_SHIR_CRDR_VIEW__x
                    WHERE CASE_CRDR_RECID__c = :caseCrdrRecId
                    LIMIT 1
            ];

            Forrester_Case__x forresterCase = [SELECT Id FROM Forrester_Case__x WHERE CASE_RECID__c = :forresterCaseCrdr.CASE_RECID__c LIMIT 1];

            RelatedCRDRs currentCRDR = new RelatedCRDRs(
                    forresterCaseCrdr.Id,
                    forresterCaseCrdr.CASE_CRDR_RECID__c,
                    forresterCaseCrdr.CRDR_NAME__c,
                    forresterCase.Id,
                    forresterCaseCrdr.CONTRACT_CASE_NUM__c,
                    null,
                    null,
                    forresterCaseCrdr.HAS_OPEN_CHK_LIST__c,
                    forresterCaseCrdr.TLO_NAME__c,
                    forresterCaseCrdr.TLO_EMAIL__c
            );

            // If the current CRDR does not have Revenue records, add it to the list without an Agreement.
            if (forresterCaseCrdr.Forrester_Case_CRDR_Revenues__r.isEmpty()) {
                forresterRelatedCrdrsList.add(currentCRDR);
            }
            else{
                for (Forrester_Case_CRDR_Revenue__x crdrRevenue : forresterCaseCrdr.Forrester_Case_CRDR_Revenues__r) {
                    RelatedCRDRs currentCRDRClone = currentCRDR.clone();
                    currentCRDRClone.AgreementId = crdrRevenue.AGREEMENT_RECID__r.Id;
                    currentCRDRClone.AgreementRecId = crdrRevenue.AGREEMENT_RECID__c;
                    forresterRelatedCrdrsList.add(currentCRDRClone);
                }
            }
        }

        // Fetch the related Case_CRDR__c, and populate the CaseCrdrId and Status fields in the forresterRelatedCrdrsMap.
        Map<Id, String> relatedCaseCrdrsIdsMap = new Map<Id, String>();
        for (Case_CRDR__c relatedCRDRContainer : [
                SELECT
                        Id,
                        Status__c,
                        ExternalCaseCRDRId__c
                FROM Case_CRDR__c
                WHERE ExternalCaseCRDRId__c IN :forresterRelatedCrdrsIds
        ]) {
            for (Integer i = (forresterRelatedCrdrsList.size()-1); i>= 0; i--){
                RelatedCRDRs relatedCRDR = forresterRelatedCrdrsList[i];
                if (relatedCRDR.ForresterCaseCrdrRecId == relatedCRDRContainer.ExternalCaseCRDRId__c.toString()) {
                    // Remove Finalized CRDRs from the result list
                    if (relatedCRDRContainer.Status__c == 'FINALIZED') {
                        forresterRelatedCrdrsList.remove(i);
                    }
                    else {
                        relatedCRDR.CaseCrdrId = relatedCRDRContainer.Id;
                        relatedCRDR.Status = relatedCRDRContainer.Status__c;
                    }
                }
            }

            if (relatedCRDRContainer.Status__c != 'FINALIZED') {
                relatedCaseCrdrsIdsMap.put(relatedCRDRContainer.Id, relatedCRDRContainer.ExternalCaseCRDRId__c);
            }
        }

        // Fetch the number of tasks for each related CRDR.
        for (AggregateResult taskCountRecord : [
                SELECT
                        COUNT(Id) TaskCount,
                        WhatId
                FROM Task
                WHERE WhatId IN :relatedCaseCrdrsIdsMap.keySet()
                AND Status != 'Completed'
                GROUP BY WhatId
        ]) {
            String recId = relatedCaseCrdrsIdsMap.get((Id) taskCountRecord.get('WhatId'));

            for (RelatedCRDRs relatedCRDR : forresterRelatedCrdrsList) {
                if (relatedCRDR.ForresterCaseCrdrRecId == recId) {
                    relatedCRDR.OpenTaskCount = (Integer) taskCountRecord.get('TaskCount');
                }
            }
        }

        return forresterRelatedCrdrsList;
    }


    @AuraEnabled
    public static void updateMultipleCaseCRDRStatus(List<String> caseCrdrIdList, String newStatus) {
        List<Case_CRDR__c> caseCrdrList = [SELECT Id, Status__c FROM Case_CRDR__c WHERE Id IN :caseCrdrIdList AND Status__c != 'FINALIZED'];
        List<Case_CRDR__c> caseCrdrListToUpdate = new List<Case_CRDR__c>();

        for (Case_CRDR__c caseCrdr : caseCrdrList) {
            if (caseCrdr.Status__c != newStatus) {
                caseCrdrListToUpdate.add(new Case_CRDR__c(Id = caseCrdr.Id, Status__c = newStatus));
            }
        }

        update caseCrdrListToUpdate;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Case_CRDR_Audit_Event__c> getCaseCRDRAuditEvents(Id caseCrdrId) {
        return [SELECT Id, CreatedDate, Status__c, Subject__c, Message__c
                FROM Case_CRDR_Audit_Event__c
                WHERE Case_CRDR__c = :caseCrdrId
                ORDER BY CreatedDate ASC];
    }


     public class PermissionsCheckResult {
        @AuraEnabled
        public Boolean hasPermission { get; set; }
        @AuraEnabled
        public String userProfile { get; set; }
        @AuraEnabled
        public List<String> userPermissions { get; set; }
    }

     /**
     * This function retrieves checks if current user has the correct permissions to update a crdr record from review to approve
     *
     * @param recordId The ID of the Forrester_SHIR_CRDR_VIEW__x being edited.
     * @return  A list of objects, each representing a the users permsiions and if they have rights to modify the record to approve.
     */
    @AuraEnabled(cacheable=true)
    public static PermissionsCheckResult checkPermissions(String recordId) {
        PermissionsCheckResult result = new PermissionsCheckResult();
        // Retrieve the record
        Forrester_SHIR_CRDR_VIEW__x record = [SELECT Id, TLO_EMAIL__c FROM Forrester_SHIR_CRDR_VIEW__x WHERE Id = :recordId LIMIT 1];

        // Get the logged in user's information
        User currentUser = [SELECT Id, Email, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        // Query all permission set assignments for the current user
        Set<String> permissionSetDeveloperNames = new Set<String>();
        for (PermissionSetAssignment assignment : [SELECT PermissionSetGroup.DeveloperName FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()]) {
            permissionSetDeveloperNames.add(assignment.PermissionSetGroup.DeveloperName);
        }

        // Set the userProfile attribute
        result.userProfile = currentUser.Profile.Name;

        // Set the userPermissions attribute
        result.userPermissions = new List<String>(permissionSetDeveloperNames);

        // Check if the user is a System Administrator
        if (currentUser.Profile.Name == 'System Administrator' || permissionSetDeveloperNames.contains('Finance_Manager')) {
            result.hasPermission = true;
        }
        // Check if the user has TLO General permission set and email matches
        else if (permissionSetDeveloperNames.contains('TLO_Officer') && currentUser.Email == record.TLO_EMAIL__c) {
            result.hasPermission = true;
        }
        // If none of the above conditions are met, set hasPermission to false
        else {
            result.hasPermission = false;
        }

        return result;
    }

    // Inner class representing a related CRDR task.
    // Currently these fields' names are confusing.
    // The `CaseCrdrId` field is the current CRDR.
    // All other fields are related CRDRs fields.
    // TODO: Rename this class's fields to match the field names from DB view SHIR_CRDR_RELATED_CRDRS_VIEW after the view's fields is renamed.
    public class RelatedCRDRs {
        @AuraEnabled
        public Id CaseCrdrId { get; set; }
        @AuraEnabled
        public Id ForresterCaseCrdrId { get; set; }
        @AuraEnabled
        public String ForresterCaseCrdrRecId { get; set; }
        @AuraEnabled
        public String ForresterCaseCrdrName { get; set; }
        @AuraEnabled
        public Id CaseId { get; set; }
        @AuraEnabled
        public String CaseContractNumber { get; set; }
        @AuraEnabled
        public Id AgreementId { get; set; }
        @AuraEnabled
        public String AgreementRecId { get; set; }
        @AuraEnabled
        public String Status { get; set; }
        @AuraEnabled
        public Integer OpenTaskCount { get; set; }
        @AuraEnabled
        public Boolean RelatedHasOpenChecklist { get; set; }
        @AuraEnabled
        public String TLOOfficer { get; set; }
        @AuraEnabled
        public String TLOOfficerEmail { get; set; }

        public RelatedCRDRs(Id forresterCaseCrdrId, String forresterCaseCrdrRecId, String ForresterCaseCrdrName, Id caseId, String caseContractNumber, Id agreementId, String agreementRecId, Boolean relatedHasOpenChecklist, String tloOfficer, String tloOfficerEmail) {
            this.ForresterCaseCrdrId = forresterCaseCrdrId;
            this.ForresterCaseCrdrRecId = forresterCaseCrdrRecId;
            this.ForresterCaseCrdrName = ForresterCaseCrdrName;
            this.CaseId = caseId;
            this.CaseContractNumber = caseContractNumber;
            this.AgreementId = agreementId;
            this.AgreementRecId = agreementRecId;
            this.Status = '';
            this.OpenTaskCount = 0;
            this.RelatedHasOpenChecklist = relatedHasOpenChecklist;
            this.TLOOfficer = tloOfficer;
            this.TLOOfficerEmail = tloOfficerEmail;
        }
    }
}