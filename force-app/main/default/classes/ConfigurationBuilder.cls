public with sharing class ConfigurationBuilder {
    public class MissingConfigurationException extends Exception {
    }
    private List<Configurations__c> configs = new List<Configurations__c>();

    public ConfigurationBuilder opsEmailAddress(String email) {
        configs.add(
            new Configurations__c(Name = 'DisclosureOpsEmail', Value__c = email)
        );
        return this;
    }

    public ConfigurationBuilder notifyInventorsEveryNumberOfDaysToCompleteDraft(
        Integer nDays
    ) {
        configs.add(
            new Configurations__c(
                Name = 'InventorLast_N_Days',
                Value__c = String.valueOf(nDays)
            )
        );
        return this;
    }

    public ConfigurationBuilder disclosureInventorSignReminderSchedule(
        String cron
    ) {
        //0 0 22 * * ? *
        configs.add(
            new Configurations__c(
                Name = 'DisclosureInventorSignReminderSchedule',
                Value__c = cron
            )
        );
        return this;
    }

    public ConfigurationBuilder draftDisclosureReminder(String cron) {
        //0 0 1 * * ? *
        configs.add(
            new Configurations__c(
                Name = 'draftDisclosureReminder',
                Value__c = cron
            )
        );
        return this;
    }

    public ConfigurationBuilder disclosureDeptHeadEndorsementReminderSchedule(
        String cron
    ) {
        //0 0 22 * * ? *
        configs.add(
            new Configurations__c(
                Name = 'DisclosureDeptHeadEndorseReminderSch',
                Value__c = cron
            )
        );
        return this;
    }

    public ConfigurationBuilder forresterTloOfficerSchedule(String cron) {
        //0 15 * * * ?
        configs.add(
            new Configurations__c(
                Name = 'ForresterTloOfficerSchedule',
                Value__c = cron
            )
        );
        return this;
    }
     public ConfigurationBuilder ipiaForresterSchedule(String cron) {
        configs.add(
            new Configurations__c(
                Name = 'IPIAForresterSchedule',
                Value__c = cron
            )
        );
        return this;
    }


    public ConfigurationBuilder archiveDraftOlderThanSchedule(String cron) {
        //0 23 * * * ?
        configs.add(
            new Configurations__c(
                Name = 'archiveDraftOlderThanSchedule',
                Value__c = cron
            )
        );
        return this;
    }


    public ConfigurationBuilder cancelExpiredSignActionOlderThan(Integer olderThan120Days, Integer olderThan999Days ) {

        configs.add(
            new Configurations__c(
                Name = ExpiredSignDisclosureActionsSchedule.CANCEL_SIGN_ACTIONS_OLDER_THAN_120_DAYS,
                Value__c = String.valueOf(olderThan120Days)
            )
        );

        configs.add(
            new Configurations__c(
                Name = ExpiredSignDisclosureActionsSchedule.CANCEL_SIGN_ACTIONS_OLDER_THAN_999_DAYS,
                Value__c = String.valueOf(olderThan999Days)
            )
        );


        return this;
    }


    public ConfigurationBuilder expiredSignDisclosureActionsSchedule(String cron) {
        //0 23 * * * ?
        configs.add(
            new Configurations__c(
                Name = 'expiredSignDisclosureActionsSchedule',
                Value__c = cron
            )
        );
        return this;
     }


    public ConfigurationBuilder archiveDraftOlderThan(Integer nDays) {
        //120
        configs.add(
            new Configurations__c(
                Name = 'archiveDraftOlderThan',
                Value__c = String.valueOf(nDays)
            )
        );
        return this;
    }

    public ConfigurationBuilder emailMaxNumberOfRetry(
        Integer maxNumberOfRetries
    ) {
        configs.add(
            new Configurations__c(
                Name = 'EmailMaxNumberOfRetry',
                Value__c = String.valueOf(maxNumberOfRetries)
            )
        );
        return this;
    }

    public ConfigurationBuilder batchJobMaxNumberOfRetry(
        Integer maxNumberOfRetries
    ) {
        configs.add(
            new Configurations__c(
                Name = 'batchJobMaxNumberOfRetry',
                Value__c = String.valueOf(maxNumberOfRetries)
            )
        );
        return this;
    }

    public ConfigurationBuilder initSigningJobMaxNumberOfRetry(
        Integer maxNumberOfRetries
    ) {
        configs.add(
            new Configurations__c(
                Name = 'initSigningJobMaxNumberOfRetry',
                Value__c = String.valueOf(maxNumberOfRetries)
            )
        );
        return this;
    }

    public ConfigurationBuilder coverPageDisclosure(
        String coverPageDisclosure
    ) {
        configs.add(
            new Configurations__c(
                Name = 'coverPageDisclosure',
                Value__c = String.valueOf(coverPageDisclosure)
            )
        );
        return this;
    }

    public ConfigurationBuilder batchJobTloOfficerLastSuccessSyncDate(
        String lastSyncDate
    ) {
        configs.add(
            new Configurations__c(
                Name = 'batchJobTloOfficerLastSuccessSyncDate',
                Value__c = String.valueOf(lastSyncDate)
            )
        );
        return this;
    }

    public ConfigurationBuilder calloutPageablePageSize(Integer pagesize) {
        configs.add(
            new Configurations__c(
                Name = 'calloutPageablePageSize',
                Value__c = String.valueOf(pagesize)
            )
        );
        return this;
    }

    //START: 2901 Changes
    public ConfigurationBuilder recordCleanupSchedule(String cron) {
        configs.add(
            new Configurations__c(
                Name = 'RecordCleanUpSchedule',
                Value__c = cron
            )
        );
        return this;
    }

    public ConfigurationBuilder csvDocumentReportSchedule(String cron) {
        configs.add(
            new Configurations__c(
                Name = 'csvDocumentReportSchedule',
                Value__c = cron
            )
        );
        return this;
    }

    public ConfigurationBuilder ipiaDownloadSchedule(String cron) {
        configs.add(
            new Configurations__c(
                Name = 'ipiaDownloadSchedule',
                Value__c = cron
            )
        );
        return this;
    }

    public ConfigurationBuilder customReportEmailAddress(String email) {
        configs.add(
            new Configurations__c(Name = 'CustomReportEmail', Value__c = email)
        );
        return this;
    }

    public ConfigurationBuilder customReportEmailEnabled(String enabled) {
        configs.add(
            new Configurations__c(Name = 'CustomReportEmailEnabled', Value__c = enabled)
        );
        return this;
    }

    public ConfigurationBuilder enableTriggerIPIASignToForrester(String enabled) {
        configs.add(
            new Configurations__c(Name = IPIARecordTriggerHandler.ENABLE_TRIGGER_IPIA_SIGN_TO_FORRESTER_SYNC, Value__c = enabled)
        );
        return this;
    }

    public ConfigurationBuilder enableTriggerIPIADownload(String enabled) {
        configs.add(
            new Configurations__c(Name = IPIARecordTriggerHandler.ENABLE_TRIGGER_IPIA_DOWNLOAD, Value__c = enabled)
        );
        return this;
    }

    //END: 2901 CHANGES
    public ConfigurationBuilder fetchInventorSignedDocSchedule(String cron) {
        configs.add(
            new Configurations__c(
                Name = 'fetchInventorSignedDocSchedule',
                Value__c = cron
            )
        );
        return this;
    }

    public ConfigurationBuilder personAccountMigrationInProgress(String value) {
        configs.add(
            new Configurations__c(
                Name = 'personAccountMigrationInProgress',
                Value__c = value
            )
        );
        return this;
    }

    public ConfigurationBuilder orgEnvironment(String value) {
        configs.add(
            new Configurations__c(
                Name = 'orgEnvironment',
                Value__c = value
            )
        );
        return this;
    }


    //TODO does this allow us to get 7, 14, 30 (... 30 is not a multiple of 7) lets as if it really needs to be 30
    public ConfigurationBuilder disclosureDeptHeadEndorsementReminder(
        List<Integer> reminderInDays
    ) {
        Integer cnt = 0;
        for (Integer reminder : reminderInDays) {
            cnt++;

            Configurations__c config = new Configurations__c();
            config.Name =
                'DisclosureDeptHeadEndtReminder_' +
                reminder +
                '_Days';
            config.Value__c = String.valueOf(reminder);
            config.Email_Interval_Flag_Field__c = 'Reminder_' + cnt + '__c';
            configs.add(config);
        }
        return this;
    }

    public ConfigurationBuilder draftDisclosureReminderInterval(
        List<Integer> reminderIntervals
    ) {
        // Only allow for three reminders
        if (reminderIntervals.size() != 3) {
            throw new MissingConfigurationException(
                'draftDisclosureReminder requires 3 intervals, found ' +
                reminderIntervals.size()
            );
        }
        for (Integer i = 0; i < 3; i++) {
            Configurations__c config = new Configurations__c();
            config.Name = 'DraftDisclosureReminder_' + (Integer) (i + 1);
            config.Value__c = String.valueOf(reminderIntervals[i]);
            configs.add(config);
        }
        return this;
    }

    //TODO does this allow us to get 7, 14, 30 (... 30 is not a multiple of 7) lets as if it really needs to be 30
    public ConfigurationBuilder inventorSignDisclosureReminder(
        List<Integer> reminderInDays
    ) {
        Integer cnt = 0;
        for (Integer reminder : reminderInDays) {
            cnt++;

            Configurations__c config = new Configurations__c();
            config.Name =
                'DisclosureInventorSignReminder_' +
                reminder +
                '_Days';
            config.Value__c = String.valueOf(reminder);
            config.Email_Interval_Flag_Field__c = 'Reminder_' + cnt + '__c';
            configs.add(config);
        }
        return this;
    }

    public ConfigurationBuilder kualiCoeusDocumentUrl(String kualiCoeusUrl) {
        configs.add(new Configurations__c(Name = 'kualiCoeusUrl', Value__c = String.valueOf(kualiCoeusUrl)));
        return this;
    }

    public List<Configurations__c> build(){
        return configs;
    }

    public static String getConfigurationToString(String instanceName) {
        Configurations__c config = Configurations__c.getInstance(instanceName);
        if (config != null) {
            return config.Value__c;
        } else {
            throw new MissingConfigurationException(instanceName);
        }
    }

    public ConfigurationBuilder iEdisonInventionSearchSchedule(String cron) {
        //0 0 1 * * ? *
        configs.add(
            new Configurations__c(
                Name = 'iEdisonInventionSearchSchedule',
                Value__c = cron
            )
        );
        return this;
    }

    public ConfigurationBuilder iEdisonInventionUpdateSchedule(String cron) {
        //0 0 1 * * ? *
        configs.add(
            new Configurations__c(
                Name = 'iEdisonInventionUpdateSchedule',
                Value__c = cron
            )
        );
        return this;
    }

    public ConfigurationBuilder iEdisonUtilizationSubmitRetrySchedule(String cron) {
        //0 0 1 * * ? *
        configs.add(
            new Configurations__c(
                Name = 'iEdisonUtilizationSubmitRetrySchedule',
                Value__c = cron
            )
        );
        return this;
    }
}