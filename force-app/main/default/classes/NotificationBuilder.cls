public with sharing class NotificationBuilder {
    /**
     *
     * tlo/disclosure-[to]-[event_name]-[disclosure_type]
     *
     * event_name:      declined_by_dept_head  vs. rejected_by_tlo, endorsed_by_dept_head_and_approved_by_tlo
     * to:              ops,  dept_head,  submitted_by,  primary_inventors, all_inventors, non_mit_inventors, all_inventors_and_submitter, primary_inventors_and_submitter
     * disclosure_type: biotang, invention, software, copyright
     */

    public class MissingCustomSettingsException extends Exception {}

    // Name limit of 38 chars for Custom Settings name.
    public static final String TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST = 'DeptHeadEndorsementRequest';   //TLOS-1575, TLOS-793
    public static final String TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST_DELEGATED = 'DeptHeadEndorsementRequestDelegated';   //TLOS-2346
    public static final String TEMPLATE_DEPT_HEAD_ENDORSEMENT_PROXIED = 'DeptHeadEndorsementProxied';   //TLOS-2346
    public static final String TEMPLATE_DEPT_HEAD_ENDORSEMENT_REMINDER = 'DeptHeadEndorsementReminder';
    public static final String TEMPLATE_INVENTOR_ENDORSEMENT_REQUEST_DELEGATED = 'PrimInvSubEndorsementRequestDelegated';  //TLOS-1082
    public static final String TEMPLATE_DISCLOSURE_SIGNATURE_REQUIRED = 'AllInventorsSignatureRequired'; // TLOS-151  TLOS-639
    public static final String TEMPLATE_DISCLOSURE_SIGNATURE_REMINDER = 'AllInventorsSignatureReminder'; // TLOS-2438
    public static final String TEMPLATE_DISCLOSURE_RENEW_INVITATION_CODE = 'AllInventorsRenewInvitationCode';
    public static final String TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD = 'PrimInvSubDeclinedByDeptHead'; //TLOS-1081
    public static final String TEMPLATE_DISCLOSURE_REJECTION_TLO_ADMIN = 'PrimInvSubRejectedByTlo'; //TLOS-1081
    
    public static final String TEMPLATE_DISCLOSURE_DRAFT_REMINDER = 'DraftReminder';    //TLOS-216
    public static final String TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_DELETION = 'PrimInvDraftDeletion';    //TLOS-845
    public static final String TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_ARCHIVED = 'PrimInvDraftArchived';    //TLOS-845
    public static final String TEMPLATE_DISCLOSURE_SUBMITTED_BY_DRAFT_ARCHIVED = 'SubDraftArchived';
    public static final String TEMPLATE_DISCLOSURE_PRIMARY_AND_SUBMITTER_DEPT_TLO_APPROVED = 'PrimInvSubEndorseByDeptHeadApprovedTlo';  //TLOS-1089
    public static final String TEMPLATE_DISCLOSURE_SUBMITTER_TLO_APPROVED = 'SubApprovedByTlo';  //TLOS-152
    public static final String TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DRAFT_REVIEW = 'PrimInvDraftReview';  //TLOS-2198
    public static final String TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_REMOVED = 'PrimInvRemoved';  //TLOS-845
    public static final String TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DELETED = 'PrimInvDeleted'; //TLOS-845
    public static final String TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_SUBMITTED = 'PrimInvDraftSubmittedForApproval'; //TLOS-1083
    public static final String TEMPLATE_DISCLOSURE_APPROVED_INVENTOR_DELETED = 'AllInventorsApprovedInventorDeleted'; //TLOS-639

    public static final String TEMPLATE_OPS_DISCLOSURE_CREATION = 'OpsNewDisclosureReceived';
    public static final String TEMPLATE_OPS_DISCLOSURE_DECLINED_DEPT_HEAD = 'OpsDeclinedByDeptHead';  //TLOS-1081

    public static final String TEMPLATE_DISCLOSURE_ALL_SIGNED = 'OpsAllInventorsSigned';  //TLOS-2460
    public static final String TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT = 'OpsPerInventorsSigned';  //TLOS-2464
    public static final String TEMPLATE_DISCLOSUREINVENTOR_OPTED_OUT = 'OpsPerInventorsOptedOut';  //TLOS-2464

    public static Notification__c buildNotificationEmail(String toAddress, String templateName, Map<String,String> variables){

        Notification__c newEmail = new Notification__c(
            To__c = toAddress,
            Template__c = templateName,
            Variables__c = notifyVariableMapToString(variables),
            Status__c = 'Pending'
        );
        validateEmailTemplateSettings(newEmail);
        return newEmail;
    }

    public static Notification__c buildNotificationEmail(String toAddress, String templateName, Object customObject){
        String json =  JSON.serialize(customObject, true );
        Notification__c newEmail = new Notification__c(
            To__c = toAddress,
            Template__c = templateName,
            Variables__c = json,
            Status__c = 'Pending'
        );
        validateEmailTemplateSettings(newEmail);
        return newEmail;
    }

    private static Boolean validateEmailTemplateSettings(Notification__c notification) {
        Email_Templates__c config = Email_Templates__c.getInstance(notification.Template__c);
        if (config == null) {
            throw new MissingCustomSettingsException(notification.Template__c);
        }
        return true;
    }


    public static Email_Templates__c getEmailTemplateCustomSettings(String instanceName) {
        Email_Templates__c config = Email_Templates__c.getInstance(instanceName);
        if (config != null) {
            return config;
        } else {
            throw new MissingCustomSettingsException(instanceName);
        }
    }

   /*
   * Build Notification__c Variables String
   */
    @TestVisible
    private static String notifyVariableMapToString(Map<String,String> variables) {
      if (variables == null) {
          return null;
      }
        return JSON.serialize(variables);
    }

    public static Map<String, Object> deserializeVariables(String jsonObject) {
       if (jsonObject == null) {
        return null;
       }
       Map<String, Object> jsonAsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonObject);
       return jsonAsMap;
    }

}