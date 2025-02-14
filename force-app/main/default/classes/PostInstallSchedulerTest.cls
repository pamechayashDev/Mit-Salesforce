@isTest
public with sharing class PostInstallSchedulerTest {
    @TestSetup
    static void makeData(){
        TestSetup.defaultConfiguration();
    }

    @isTest
    public static void testInstallScript() {
       Test.startTest();
        PostInstallScheduler postInstall = new PostInstallScheduler();

        // execute sfdx push, and enable Triggers afterInstall
        postInstall.afterInstall();

        List<CronTrigger> triggers = [SELECT  Id, CronJobDetailId, State, CronExpression, OwnerId ,CronJobDetail.Name FROM CronTrigger ];
        System.assert(triggers.size() > 0, 'Trigger not created' );

        Boolean foundEmailJob = false;
        Boolean foundInventorSignedJob = false;
        Boolean foundDraftDisclosureJob = false;
        Boolean foundMitDraftDisclosureJob = false;
        Boolean foundInventorSignReminderJob = false;
        Boolean foundDeptHeadEndtReminderJob = false;
        Boolean foundTloOfficerSyncJob = false;
        Boolean foundIPIASignedSyncJob = false;
        Boolean foundExpiredSignDisclosureActionJob = false;
        Boolean foundExpiredInventionSearchJob = false;
        Boolean foundExpiredInventionUpdateJob = false;
        Boolean foundExpiredSubmitUtilizationJob = false;

        for(CronTrigger delCron: triggers)  {

            if(delCron.CronJobDetail.Name == 'Notification Scheduler 50') {
                foundEmailJob = true;
            }


            if(delCron.CronJobDetail.Name == DisclosureInventorSignedForresterSch.JOB_NAME + ' 50') {
               foundInventorSignedJob = true;
            }


            if(delCron.CronJobDetail.Name == DraftDisclosureReminderSchedule.JOB_NAME) {
               foundDraftDisclosureJob = true;
            }

            if(delCron.CronJobDetail.Name == ArchiveDraftDisclosuresSchedule.JOB_NAME) {
               foundMitDraftDisclosureJob = true;
            }

            if(delCron.CronJobDetail.Name == DisclosureInventorSignReminderSchedule.JOB_NAME) {
               foundInventorSignReminderJob = true;
            }

            if(delCron.CronJobDetail.Name == DisclosureDeptHeadEndorseReminderSch.JOB_NAME) {
               foundDeptHeadEndtReminderJob = true;
            }

            if(delCron.CronJobDetail.Name == TloOfficerForresterSchedule.JOB_NAME) {
                foundTloOfficerSyncJob = true;
            }

            if(delCron.CronJobDetail.Name == IPIASignedForresterSchedule.JOB_NAME) {
                foundIPIASignedSyncJob = true;
            }

            if(delCron.CronJobDetail.Name == ExpiredSignDisclosureActionsSchedule.JOB_NAME) {
                foundExpiredSignDisclosureActionJob = true;
            }

            if(delCron.CronJobDetail.Name == iEdisonInventionSearchSchedule.JOB_NAME) {
                foundExpiredInventionSearchJob = true;
            }

            if(delCron.CronJobDetail.Name == iEdisonInventionUpdateSchedule.JOB_NAME) {
                foundExpiredInventionUpdateJob = true;
            }

            if(delCron.CronJobDetail.Name == iEdisonUtilizationSubmitRetrySchedule.JOB_NAME) {
                foundExpiredSubmitUtilizationJob = true;
            }
        }

        System.assert(foundInventorSignedJob, 'Disclosure Inventor Signed Disclosure Forrester Job not found' );
        System.assert(foundEmailJob, 'Notification Scheduler 50 Job not found' );
        System.assert(foundDraftDisclosureJob, 'Draft Disclosure Reminder Job not found' );
        System.assert(foundMitDraftDisclosureJob, 'MIT Draft Disclosures Job not found' );
        System.assert(foundInventorSignReminderJob, 'Inventor Sign Reminder Job not found' );
        System.assert(foundDeptHeadEndtReminderJob, 'Dept. Head Endorsement Reminder Job not found' );
        System.assert(foundTloOfficerSyncJob, 'Tlo Officer Sync from Forrester Job not found' );
        System.assert(foundIPIASignedSyncJob, 'IPIA Sync to Forrester Job not found' );
        System.assert(foundExpiredSignDisclosureActionJob, 'ExpiredSignDisclosureActions Job not found');
        System.assert(foundExpiredInventionSearchJob, 'ExpiredInventionSearchJob Job not found');
        System.assert(foundExpiredInventionUpdateJob, 'ExpiredInventionUpdateJob Job not found');
        System.assert(foundExpiredSubmitUtilizationJob, 'ExpiredSubmitUtilizationJob Job not found');

        // Simulate removing existing CronJobs, before doing a deployment
        postInstall.beforeInstall();

        List<CronTrigger> abortTriggers = [SELECT  Id, CronJobDetailId, State, CronExpression, OwnerId ,CronJobDetail.Name FROM CronTrigger where CronJobDetail.JobType = '7' ]; // JobType 7 = Scheduled Apex
      //   System.assert(abortTriggers.size() == 0, 'Not All Triggers aborted' );

        Test.stopTest();
      }
}