public with sharing class DisclosureInventorSignReminder implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Configurations__c config = Configurations__c.getInstance(
            'InventorLast_N_Days'
        );
        Integer numberOfDays = 31;
        Integer maximumNumberOfDays = 120;
        if (config != null) {
            numberOfDays = Integer.valueOf(config.Value__c) - 1;
        }
        Date dateFrom = System.today().addDays(-numberOfDays);
        Date maximumDateFrom = System.today().addDays(-maximumNumberOfDays);
        String status = 'Pending';

        Database.QueryLocator queryLocator = Database.getQueryLocator(
            [
                SELECT
                    Id,
                    CreatedDate,
                    Reminder_1__c,
                    Reminder_2__c,
                    Reminder_3__c,
                    Contact_Action__c,
                    Contact_Action__r.Name,
                    Contact_Action__r.Status__c,
                    Contact_Action__r.Contact__r.InvitationCode__pc,
                    Contact_Action__r.Contact__r.MoiraStatus__pc,
                    Contact_Action__r.Contact__r.IsAlumni__pc,
                    Contact_Action__r.Contact__r.Name,
                    Contact_Action__r.Contact__r.PersonEmail,
                    Disclosure__c,
                    Disclosure__r.RecordTypeId,
                    Disclosure__r.RecordType.name,
                    Disclosure__r.Name,
                    Disclosure__r.Name__c,
                    Disclosure__r.Case_Number__c,
                    RecordType.DeveloperName,
                    RecordType.name
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Status__c = :status
                    AND CreatedDate < :dateFrom
                    AND CreatedDate > :maximumDateFrom
                    AND Reminder_3__c = FALSE
            ]
        );

        System.debug(queryLocator.getQuery() + '--' + numberOfDays);
        return queryLocator;
    }

    public void execute(
        Database.BatchableContext bc,
        List<Disclosure_Action__c> scope
    ) {
        Set<String> disclosureIds = new Set<String>();
        try {
            List<Notification__c> sendNotificationEmail = new List<Notification__c>();
            List<Disclosure_Action__c> updateDisclosureAction = new List<Disclosure_Action__c>();
            Configurations__c lastReminderConfig = Configurations__c.getInstance('DisclosureInventorSignReminder_30_Days');
            Integer lastReminderInDays = Integer.valueOf(lastReminderConfig.Value__c); // Throw exception if null

            for (Disclosure_Action__c action : scope) {
                Datetime nowdate = Util.now();

                Datetime cdate = action.CreatedDate;
                Integer daysBetween = cdate.Date().daysBetween(nowdate.Date());
                String configInstance =
                    'DisclosureInventorSignReminder_' +
                    daysBetween +
                    '_Days';

                System.debug('Record Type:' + action.recordType.DeveloperName);
                if (action.RecordType.DeveloperName == 'Sign_Disclosure') {
                    Configurations__c config;
                    // If the days between is greater or equal to the last reminder days, use the last reminder config
                    if (daysBetween >= lastReminderInDays) {
                        config = lastReminderConfig;
                    }
                    else {
                        config = Configurations__c.getInstance(configInstance);
                    }

                    if (config == null) {
                        // We dont have a reminder configured for this time period
                        continue;
                    }
                    String emailTemplateName = NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REMINDER;

                    Boolean hasReminderEmailBeenSent = (Boolean) action.get(
                        config.Email_Interval_Flag_Field__c
                    );
                    if (
                        (daysBetween == Integer.valueOf(config.Value__c) || daysBetween >= lastReminderInDays) &&
                        !hasReminderEmailBeenSent
                    ) {
                        Map<String, Object> variables = new Map<String, Object>();
                        variables.put(
                            'disclosure_name',
                            action.Disclosure__r.Name
                        );
                         if (action.Disclosure__r.Case_Number__c != null) {
                            variables.put(
                                'case_number',
                                action.Disclosure__r.Case_Number__c
                            );
                        }
                        variables.put(
                            'disclosure_title',
                            action.Disclosure__r.Name__c
                        );
                        variables.put(
                            'inventor_name',
                            action.Contact_Action__r.Contact__r.Name
                        );
                        variables.put(
                            'inventor_email',
                            action.Contact_Action__r.Contact__r.PersonEmail
                        );
                        variables.put(
                            'outstanding',
                            String.valueOf(daysBetween)
                        );
                        if (
                            action.Contact_Action__r.Contact__r.InvitationCode__pc !=
                            null
                        ) {
                            variables.put(
                                'invitation_code',
                                action.Contact_Action__r.Contact__r.InvitationCode__pc
                            );
                        }
                        Boolean isActiveKerb = Helpers.isActiveKerb(
                            action.Contact_Action__r.Contact__r.MoiraStatus__pc
                        );
                        variables.put('isActiveKerb', isActiveKerb);
                        variables.put('isAlumni', action.Contact_Action__r.Contact__r.IsAlumni__pc);
                        variables.put(
                            'disclosure_type',
                            getDisclosureTypeName(action)
                        );
                        variables.put(
                            'inventor_description_copy',
                            getContributorInventorAuthorName(action)
                        );

                        sendNotificationEmail.add(
                            NotificationBuilder.buildNotificationEmail(
                                action.Contact_Action__r.Contact__r.PersonEmail,
                                emailTemplateName,
                                variables
                            )
                        );

                        action.put(config.Email_Interval_Flag_Field__c, true);
                        updateDisclosureAction.add(action);
                    }
                }
            }
            if (
                sendNotificationEmail != null &&
                !sendNotificationEmail.isEmpty()
            ) {
                insert sendNotificationEmail;
            }
            if (
                updateDisclosureAction != null &&
                !updateDisclosureAction.isEmpty()
            ) {
                update updateDisclosureAction;
            }
        } catch (Exception ex) {
            HandleLogException.logException(ex);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    // The template does not use BioTang but 'Tangible'
    public static String getDisclosureTypeName(Disclosure_Action__c action) {
        if (action.Disclosure__r.recordTypeId != null) {
            String recordTypeName = Schema.getGlobalDescribe()
                .get('Disclosure__c')
                .getDescribe()
                .getRecordTypeInfosById()
                .get(action.Disclosure__r.recordTypeId)
                .getDeveloperName();

            if (recordTypeName != null) {
                if (recordTypeName == 'BioTang_Disclosure') {
                    return Label.Disclosure_Type_Notify_BioTang;
                }
            }
        }
        return action.Disclosure__r.RecordType.Name;
    }

    // TLOS-3548
    public static String getContributorInventorAuthorName(
        Disclosure_Action__c action
    ) {
        if (action.Disclosure__r.recordTypeId != null) {
            String recordTypeName = Schema.getGlobalDescribe()
                .get('Disclosure__c')
                .getDescribe()
                .getRecordTypeInfosById()
                .get(action.Disclosure__r.recordTypeId)
                .getDeveloperName();

            if (recordTypeName != null) {
                if (recordTypeName == 'BioTang_Disclosure') {
                    return Label.Disclosure_Notify_Inventor_Desc_Copy_BioTang;
                } else if (recordTypeName == 'Invention_Disclosure') {
                    return Label.Disclosure_Notify_Inventor_Desc_Copy_Invention;
                } else if (
                    recordTypeName == 'Copyright_Disclosure' ||
                    recordTypeName == 'Software_Code_Disclosure'
                ) {
                    return Label.Disclosure_Notify_Inventor_Desc_Copy_Copyright;
                } else if (
                    recordTypeName == 'Copyright_Disclosure' ||
                    recordTypeName == 'Software_Code_Disclosure'
                ) {
                    return Label.Disclosure_Notify_Inventor_Desc_Copy_Software;
                }
            }
        }
        return 'co-inventor/author';
    }
}