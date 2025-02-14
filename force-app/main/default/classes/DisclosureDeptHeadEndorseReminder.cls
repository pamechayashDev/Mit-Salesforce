public with sharing class DisclosureDeptHeadEndorseReminder implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    CreatedDate,
                    Contact_Action__r.Name,
                    Contact_Action__r.Status__c,
                    Contact_Action__c,
                    RecordType.DeveloperName,
                    RecordType.name,
                    Disclosure__c,
                    Disclosure__r.Name,
                    Disclosure__r.Name__c,
                    Disclosure__r.RecordType.Name,
                    Disclosure__r.Submitting_Contact__c,
                    Disclosure__r.Submitting_Contact__r.Id,
                    Disclosure__r.Submitting_Contact__r.Name,
                    Disclosure__r.Submitting_Contact__r.PersonEmail,
                    Disclosure__r.Submitting_Contact__r.AltEmail__pc,
                    Contact_Action__r.Contact__r.PersonEmail,
                    Contact_Action__r.Contact__r.Name,
                    Reminder_1__c,
                    Reminder_2__c,
                    Reminder_3__c
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Status__c = 'Pending'
                    AND CreatedDate = LAST_N_DAYS:30
            ]
        );
    }

    public void execute(
        Database.BatchableContext bc,
        List<Disclosure_Action__c> scope
    ) {
        Set<String> disclosureIds = new Set<String>();
        try {
            List<Notification__c> sendNotificationEmail = new List<Notification__c>();
            List<Disclosure_Action__c> updateDisclosureAction = new List<Disclosure_Action__c>();

            for (Disclosure_Action__c action : scope) {
                Datetime nowdate = Util.now();

                Datetime cdate = action.CreatedDate;
                Integer daysBetween = cdate.Date().daysBetween(nowdate.Date());
                String configInstance =
                    'DisclosureDeptHeadEndtReminder_' +
                    daysBetween +
                    '_Days';

                if (
                    action.RecordType.DeveloperName ==
                    'Endorse_or_Delegate_Disclosure'
                ) {
                    Configurations__c config = Configurations__c.getInstance(
                        configInstance
                    );
                    if (config == null) {
                        // We dont have a reminder configured for this time period
                        continue;
                    }

                    Boolean hasReminderEmailBeenSent = (Boolean) action.get(
                        config.Email_Interval_Flag_Field__c
                    );
                    if (
                        daysBetween == Integer.valueOf(config.Value__c) &&
                        !hasReminderEmailBeenSent
                    ) {
                        Map<String, String> variables = new Map<String, String>();
                        variables.put(
                            'disclosure_name',
                            action.Disclosure__r.Name
                        );
                        variables.put(
                            'disclosure_title',
                            action.Disclosure__r.Name__c
                        );
                        variables.put(
                            'dlc_name',
                            action.Contact_Action__r.Contact__r.Name
                        );
                        variables.put(
                            'disclosure_type',
                            action.Disclosure__r.RecordType.Name
                        );
                        variables.put(
                            'outstanding',
                            String.valueOf(daysBetween)
                        );
                        variables.put(
                            'submitter_name',
                            action.Disclosure__r.Submitting_Contact__r.Name
                        );

                        sendNotificationEmail.add(
                            NotificationBuilder.buildNotificationEmail(
                                action.Contact_Action__r.Contact__r.PersonEmail,
                                NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REMINDER,
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
        system.debug('IN FINISH METHOD');
    }
}