public with sharing class EmailTemplateBuilder {
    /**
     *
     * tlo/disclosure-[to]-[event_name]-[disclosure_type]
     *
     * event_name:      declined_by_dept_head  vs. rejected_by_tlo, endorsed_by_dept_head_and_approved_by_tlo
     * to:              ops,  dept_head,  submitted_by,  primary_inventors, all_inventors, non_mit_inventors, all_inventors_and_submitter, primary_inventors_and_submitter
     * disclosure_type: biotang, invention, software, copyright
     */


    private Map<String, Email_Templates__c> configs = new Map<String, Email_Templates__c>();

    public EmailTemplateBuilder() {
        setup();
    }

    public EmailTemplateBuilder disableDeptHeadEndorsementRequest(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST);
    }

    public EmailTemplateBuilder disableDeptHeadEndorsementRequestDelegated(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST_DELEGATED);
    }

    public EmailTemplateBuilder disableDeptHeadEndorsementProxied(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_PROXIED);
    }

    public EmailTemplateBuilder disableDeptHeadEndorsementReminder(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REMINDER);
    }


    public EmailTemplateBuilder disableInventorEndorsementRequestDelegated(){
        return disableTemplate(NotificationBuilder.TEMPLATE_INVENTOR_ENDORSEMENT_REQUEST_DELEGATED);
    }

    public EmailTemplateBuilder disableInventorSignatureRequired(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REQUIRED);
    }

    public EmailTemplateBuilder disableInventorSignatureReminder(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REMINDER);
    }

    public EmailTemplateBuilder disableRenewInvitationCode(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_RENEW_INVITATION_CODE);
    }

    public EmailTemplateBuilder disableInventorDeclinedByDeptHead(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD);
    }

    public EmailTemplateBuilder disableInventorRejectedByTlo(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_REJECTION_TLO_ADMIN);
    }

    public EmailTemplateBuilder disableSubmitterDraftReminder(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_DRAFT_REMINDER);
    }

    public EmailTemplateBuilder disableInventorDraftDeletion(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_DELETION);
    }

   public EmailTemplateBuilder disableInventorDraftArchived(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_ARCHIVED);
    }

    public EmailTemplateBuilder disableSubmitterDraftArchived(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTED_BY_DRAFT_ARCHIVED);
    }

    public EmailTemplateBuilder disablePrimInventorSubmitterEndorsedAndApproved(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_AND_SUBMITTER_DEPT_TLO_APPROVED);
    }

    public EmailTemplateBuilder disableSubmitterApprovedByTlo(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTER_TLO_APPROVED);
    }

    public EmailTemplateBuilder disablePrimInventorDraftReview(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DRAFT_REVIEW);
    }

    public EmailTemplateBuilder disablePrimInventorRemoved(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_REMOVED);
    }

    public EmailTemplateBuilder disablePrimInventorDeleted(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DELETED);
    }

    public EmailTemplateBuilder disablePrimInventorDraftSubmittedForApproval(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_SUBMITTED);
    }

    public EmailTemplateBuilder disableInventorApprovedInventorDeleted(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_APPROVED_INVENTOR_DELETED);
    }

    public EmailTemplateBuilder disableOpsNewDisclosureReceived(){
        return disableTemplate(NotificationBuilder.TEMPLATE_OPS_DISCLOSURE_CREATION);
    }

    public EmailTemplateBuilder disableOpsDeclinedByDeptHead(){
        return disableTemplate(NotificationBuilder.TEMPLATE_OPS_DISCLOSURE_DECLINED_DEPT_HEAD);
    }

    public EmailTemplateBuilder disableOpsAllInventorsSigned(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED);
    }

    public EmailTemplateBuilder disableOpsPerInventorsSigned(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT);
    }

    public EmailTemplateBuilder disableOpsPerInventorsOptOut(){
        return disableTemplate(NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_OPTED_OUT);
    }

    public EmailTemplateBuilder disableTemplate(String templateName){
        Email_Templates__c template = getInstance(templateName);
        template.Enabled__c = false;
        return this;
    }


    private Email_Templates__c getInstance(String name) {
        Email_Templates__c template = configs.get(name);
        if (template == null) {
            template = new Email_Templates__c();
            template.name = name;
            template.Enabled__c = true;
            configs.put(name, template);
        }
        return configs.get(name);
    }

    private void setup() {
        getInstance(NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST).Template__c = 'tlo/disclosure-dept_head-opensource_endorsement_request';
        getInstance(NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST_DELEGATED).Template__c = 'tlo/disclosure-dept_head-opensource_endorsement_request_delegated';
        getInstance(NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_PROXIED).Template__c = 'tlo/disclosure-dept_head-endorsement_proxied';
        getInstance(NotificationBuilder.TEMPLATE_INVENTOR_ENDORSEMENT_REQUEST_DELEGATED).Template__c = 'tlo/disclosure-primary_inventors_and_submitter-endorsement_request_delegated';
        getInstance(NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REMINDER).Template__c = 'tlo/disclosure-dept_head-endorsement_reminder';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REQUIRED).Template__c = 'tlo/disclosure-all_inventors-signature_required';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REMINDER).Template__c = 'tlo/disclosure-all_inventors-signature_reminder';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_RENEW_INVITATION_CODE).Template__c = 'tlo/disclosure-all_inventors-renew_invitation_code_requested';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD).Template__c = 'tlo/disclosure-primary_inventors_and_submitter-declined_by_dept_head';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_REJECTION_TLO_ADMIN).Template__c = 'tlo/disclosure-primary_inventors_and_submitter-rejected_by_tlo';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_DRAFT_REMINDER).Template__c = 'tlo/disclosure-submitted_by-draft_reminder';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_DELETION).Template__c = 'tlo/disclosure-primary_inventors-draft_deletion';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_ARCHIVED).Template__c = 'tlo/disclosure-primary_inventors-draft_archived';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTED_BY_DRAFT_ARCHIVED).Template__c = 'tlo/disclosure-submitted_by-draft_archived';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_AND_SUBMITTER_DEPT_TLO_APPROVED).Template__c = 'tlo/disclosure-primary_inventors_and_submitter-endorsed_by_dept_head_and_approved_by_tlo';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTER_TLO_APPROVED).Template__c = 'tlo/disclosure-submitted_by-approved_by_tlo';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DRAFT_REVIEW).Template__c = 'tlo/disclosure-primary_inventors-draft_review_request';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_REMOVED).Template__c = 'tlo/disclosure-primary_inventors-removed';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DELETED).Template__c = 'tlo/disclosure-primary_inventors-deleted';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_SUBMITTED).Template__c = 'tlo/disclosure-primary_inventors-draft_submitted_for_approval';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_APPROVED_INVENTOR_DELETED).Template__c = 'tlo/disclosure-all_inventors-approved_inventor_deleted';
        getInstance(NotificationBuilder.TEMPLATE_OPS_DISCLOSURE_CREATION).Template__c = 'tlo/disclosure-ops-new_disclosure_received';
        getInstance(NotificationBuilder.TEMPLATE_OPS_DISCLOSURE_DECLINED_DEPT_HEAD).Template__c = 'tlo/disclosure-ops-declined_by_dept_head';

        getInstance(NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED).Template__c = 'tlo/disclosure-ops-all_inventors_signed';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT).Template__c = 'tlo/disclosure-ops-per_inventor_signed';
        getInstance(NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_OPTED_OUT).Template__c = 'tlo/disclosure-ops-per_inventor_optedout';
    }

    public List<Email_Templates__c> build(){
        return configs.values();
    }

}