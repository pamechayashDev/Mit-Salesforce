public class DraftDisclosureReminderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public Integer reminder1 { get; set; }
    public Integer reminder2 { get; set; }
    public Integer reminder3 { get; set; }

    public DraftDisclosureReminderBatch() {
        Configurations__c reminder1Config = Configurations__c.getInstance(
            'DraftDisclosureReminder_1'
        );
        Configurations__c reminder2Config = Configurations__c.getInstance(
            'DraftDisclosureReminder_2'
        );
        Configurations__c reminder3Config = Configurations__c.getInstance(
            'DraftDisclosureReminder_3'
        );
        if (
            reminder1Config == null ||
            reminder2Config == null ||
            reminder3Config == null
        ) {
            throw new ConfigurationBuilder.MissingConfigurationException(
                'Missing configuration for draftDisclosureReminder'
            );
        }

        this.reminder1 = Integer.valueOf(reminder1Config.Value__c);
        this.reminder2 = Integer.valueOf(reminder2Config.Value__c);
        this.reminder3 = Integer.valueOf(reminder3Config.Value__c);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (bc != null) {
            System.debug('start of ' + bc.getJobId());
        }
        String query =
            'SELECT Submitting_Contact__c, Submitting_Contact__r.Name, Submitting_Contact__r.PersonEmail, Name, Name__c, Draft_Date__c, Reminder__c' +
            ' FROM Disclosure__c' +
            ' WHERE Status__c = \'Draft\' AND Draft_Date__c = Last_N_Days:' +
            reminder3;
        // Starts at 12:00:00 AM n days before the current day and continues up to the current second.
        // (The range includes today. Using this date value includes records from n + 1 days ago up to the current day.)
        return Database.getQueryLocator(query);
    }

    public void execute(
        Database.BatchableContext bc,
        List<Disclosure__c> scope
    ) {
        if (bc != null) {
            System.debug('start of ' + bc.getJobId());
        }
        System.debug('***Batch Started***');
        try {
            List<Disclosure__c> updateDisclosures = new List<Disclosure__c>();
            List<Notification__c> insertNotifications = new List<Notification__c>();
            if (scope != null && !scope.isEmpty()) {
                System.debug(scope.size() + ' Disclosures found');
                if (
                    reminder1 != null &&
                    reminder2 != null &&
                    reminder3 != null
                ) {
                    Date firstReminder = Date.today().addDays(-reminder1);
                    Date secondReminder = Date.today().addDays(-reminder2);
                    Date thirdReminder = Date.today().addDays(-reminder3);
                    System.debug(
                        'Reminders: ' +
                        firstReminder +
                        ', ' +
                        secondReminder +
                        ', ' +
                        thirdReminder
                    );
                    for (Disclosure__c disclosure : scope) {
                        System.debug(
                            'Checking Disclosure ' +
                            disclosure.Name +
                            ' ' +
                            disclosure.Name__c +
                            ': ' +
                            disclosure.Draft_Date__c
                        );
                        if (
                            disclosure.Draft_Date__c <= thirdReminder &&
                            disclosure.Reminder__c == 'Reminder 2'
                        ) {
                            // Third reminder required
                            Notification__c newEmail = buildNotification(
                                disclosure
                            );
                            updateDisclosures.add(
                                new Disclosure__c(
                                    Id = disclosure.Id,
                                    Reminder__c = 'Reminder 3'
                                )
                            );
                            insertNotifications.add(newEmail);
                            System.debug(
                                'Adding third reminder for ' + disclosure.Name
                            );
                        } else if (
                            disclosure.Draft_Date__c <= secondReminder &&
                            disclosure.Reminder__c == 'Reminder 1'
                        ) {
                            // Second reminder required
                            Notification__c newEmail = buildNotification(
                                disclosure
                            );
                            updateDisclosures.add(
                                new Disclosure__c(
                                    Id = disclosure.Id,
                                    Reminder__c = 'Reminder 2'
                                )
                            );
                            insertNotifications.add(newEmail);
                            System.debug(
                                'Adding second reminder for ' + disclosure.Name
                            );
                        } else if (
                            disclosure.Draft_Date__c <= firstReminder &&
                            (disclosure.Reminder__c == 'No Reminder' ||
                            disclosure.Reminder__c == null)
                        ) {
                            // First reminder required
                            Notification__c newEmail = buildNotification(
                                disclosure
                            );
                            updateDisclosures.add(
                                new Disclosure__c(
                                    Id = disclosure.Id,
                                    Reminder__c = 'Reminder 1'
                                )
                            );
                            insertNotifications.add(newEmail);
                            System.debug(
                                'Adding first reminder for ' + disclosure.Name
                            );
                        }
                    }
                    if (
                        updateDisclosures != null &&
                        !updateDisclosures.isEmpty()
                    ) {
                        System.debug(
                            'Found ' +
                            updateDisclosures.size() +
                            ' Disclosures to update'
                        );
                        update updateDisclosures;
                        System.debug('Update complete');
                    }
                    if (
                        insertNotifications != null &&
                        !insertNotifications.isEmpty()
                    ) {
                        System.debug(
                            'Found ' +
                            insertNotifications.size() +
                            ' Notifications to insert'
                        );
                        insert insertNotifications;
                        System.debug('Insert complete');
                    }
                }
            }
        } catch (exception ex) {
            HandleLogException.logException(ex);
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (bc != null) {
            System.debug('start of ' + bc.getJobId());
        }
        System.debug('***Batch Finshed***');
    }

    private Notification__c buildNotification(Disclosure__c disclosure) {
        Map<String, String> variables = new Map<String, String>();
        variables.put('disclosure_name', disclosure.Name);
        variables.put('disclosure_title', disclosure.Name__c);
        variables.put('submitter_name', disclosure.Submitting_Contact__r.Name);
        variables.put('archive_date', calculateArchiveDate(disclosure));
        Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
            disclosure.Submitting_Contact__r.PersonEmail,
            NotificationBuilder.TEMPLATE_DISCLOSURE_DRAFT_REMINDER,
            variables
        );
        return newEmail;
    }

    private String calculateArchiveDate(Disclosure__c disclosure) {
        // Draft Date should always exist.
        Integer nDays = Integer.valueOf(olderThanNDays());
        Date archiveDate = disclosure.Draft_Date__c.addDays(nDays);
        return Helpers.formatDate(archiveDate, 'MMM dd, yyyy');
    }

    private static String olderThanNDays() {
        return ConfigurationBuilder.getConfigurationToString(
            'archiveDraftOlderThan'
        );
    }
}