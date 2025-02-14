@IsTest
public with sharing class TestSetup {

    public static void defaultDocTemplatesConfiguration() {
        SampleDataFactory.createCopyrightDocumentTemplate();
        SampleDataFactory.createSoftwareCodeDocumentTemplate();
        SampleDataFactory.createBioTangDocumentTemplate();
        SampleDataFactory.createInventionDocumentTemplate();
        
        SampleDataFactory.createInventorDocumentTemplate();

        SampleDataFactory.createUtilizationDocumentTemplate();

        SampleDataFactory.createStyleDocumentTemplate();

        SampleDataFactory.createCoverPageDocumentTemplate();
        SampleDataFactory.createCoverPageFooterDocumentTemplate();

        SampleDataFactory.createFooterDocumentTemplate();
    }
    public static void defaultConfiguration() {
        System.debug('Add Cleanup Settings.');
        List<Cleanup_Config__c> cleanupSettings = new List<Cleanup_Config__c>();
        cleanupSettings.add(new Cleanup_Config__c(SObject_Name__c = 'Log_Exception__c', Older_Than_x_days__c = '180', Unit_of_Time__c = 'Days'));
        cleanupSettings.add(new Cleanup_Config__c(SObject_Name__c = 'Notification__c', Older_Than_x_days__c = '1000', Unit_of_Time__c = 'Hours'));
        cleanupSettings.add(new Cleanup_Config__c(SObject_Name__c = 'Async_Request__c', Older_Than_x_days__c = '2', Unit_of_Time__c = 'Years'));

        ConfigurationBuilder configBuilder = new ConfigurationBuilder();
        
        List<Configurations__c> configs = configBuilder.opsEmailAddress('tlo-ops@mit.edu')
        .draftDisclosureReminder('0 0 1 * * ? *') // Run once per day at 01:00 AM
        .draftDisclosureReminderInterval(new List<Integer> { 30, 60, 90 })
        .disclosureDeptHeadEndorsementReminder(new List<Integer> { 7, 14, 30 })
        .inventorSignDisclosureReminder(new List<Integer> { 7, 14, 30 })
        .notifyInventorsEveryNumberOfDaysToCompleteDraft(30)
        .disclosureInventorSignReminderSchedule('0 0 22 * * ? *')
        .fetchInventorSignedDocSchedule('0 0 1 * * ? *')
        .disclosureDeptHeadEndorsementReminderSchedule('0 0 23 * * ? *')
        .forresterTloOfficerSchedule('0 0 12 * * ?')
        .ipiaForresterSchedule('0 0 22 * * ? *')
        .archiveDraftOlderThanSchedule('0 0 23 * * ? *')
        .expiredSignDisclosureActionsSchedule('0 0 21 * * ? *')
        .archiveDraftOlderThan(120)
        .cancelExpiredSignActionOlderThan(120, 999)
        .emailMaxNumberOfRetry(4)
        .batchJobMaxNumberOfRetry(4)
        .initSigningJobMaxNumberOfRetry(2)
        .coverPageDisclosure('Cover_Page_Disclosure')
        .batchJobTloOfficerLastSuccessSyncDate('2023-01-01')
        .calloutPageablePageSize(1000)
        .recordCleanupSchedule('0 0 22 * * ? *')
        .csvDocumentReportSchedule('0 0 23 * * ? SUN')
        .customReportEmailAddress('tlo-admin@mit.edu')
        .customReportEmailEnabled('true')
        .iEdisonInventionSearchSchedule('0 0 2 * * ? *') // Run once per day at 02:00 AM
        .iEdisonInventionUpdateSchedule('0 0 * * * ? *') // Run once per hour on the hour
        .iEdisonUtilizationSubmitRetrySchedule('0 0 3/6 * * ? *') // Runs every 6 hours, start at 03:00 AM
        .enableTriggerIPIASignToForrester('true')
        .enableTriggerIPIADownload('true')
        .orgEnvironment('PROD')
        .ipiaDownloadSchedule('0 0 20 * * ? *')
        .build();
        
        
        insert configs;

        ApiConfigurationBuilder apiConfigBuilder = new ApiConfigurationBuilder();
        
        List<ApiConfigurations__c> apiConfigs = apiConfigBuilder.academicHistoryApi('AWS_API', 'academic-history-v1')
        .appointmentHistoryApi('AWS_API', 'appointment-history-v1')
        .forresterApi('AWS_API', 'forrester-v1')
        .guestAccountApi('AWS_API', 'guest-account-v1')
        .researchApi('AWS_API', 'research-v1')
        .accountApi('AWS_API', 'account-v2')
        .peopleSearchApi('AWS_API', 'people-search-v1')
        .digitalIdApi('AWS_API', 'digital-id-v1')
        .notificationApi('AWS_API', 'notification-v1')
        .pdfGeneratorApi('AWS_API', 'pdf-generator-v1')
        .mitDocusignApi('GLOBAL_AWS_API', 'docusign/v1')
        .iedisonApi('GLOBAL_AWS_API', 'iedison/v1')
        .build();
        
        
        insert apiConfigs;

        EmailTemplateBuilder builder = new EmailTemplateBuilder();
        insert builder.build();

        insertFinanceQueue();
    }

    private static Group insertFinanceQueue() {
        List<Group> existing = [Select Name, DeveloperName FROM GROUP WHERE DeveloperName='Finance_Queue' ];
        if (!existing.isEmpty()) {
            return existing[0];
        }
        Group testGroup = new Group(Name='Finance Queue', DeveloperName='Finance_Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Task');
            insert testQueue;
        }
        return testGroup;
    }
}