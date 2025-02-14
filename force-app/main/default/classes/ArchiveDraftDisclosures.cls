public class ArchiveDraftDisclosures implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String days = olderThanNDays();
        String query =
            'Select Id,CreatedDate,Status__c,Submitting_Contact__c, Submitting_Contact__r.PersonEmail,Draft_Date__c From Disclosure__c where Status__c = \'Draft\' AND Draft_Date__c < LAST_N_Days:' +
            Integer.valueOf(days);
        return Database.getQueryLocator(query);
    }

    public void execute(
        Database.BatchableContext bc,
        List<Disclosure__c> scope
    ) {
        System.debug('--+--' + scope.size());
        List<Disclosure__c> updatedis = new List<Disclosure__c>();
        for (Disclosure__c dis : scope) {
            dis.Status__c = 'Archived';
            updatedis.add(dis);
        }
        if (updatedis != null && !updatedis.isEmpty()) {
            update updatedis;
            // Send Email using Trigger Handler

            System.debug('---+Batch+---');
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    private static String olderThanNDays() {
        return ConfigurationBuilder.getConfigurationToString(
            'archiveDraftOlderThan'
        );
    }
}