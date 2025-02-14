global class PostInstallScheduler implements PostInstall {

    global void beforeInstall() {
       DisclosureInventorSignedForresterSch.abortSchedule();
       CRONJobEmail.abortSchedule();
       DraftDisclosureReminderSchedule.abortSchedule();
       ArchiveDraftDisclosuresSchedule.abortSchedule();
       DisclosureDeptHeadEndorseReminderSch.abortSchedule();
       DisclosureInventorSignReminderSchedule.abortSchedule();
       TloOfficerForresterSchedule.abortSchedule();
       CleanupRecordBatchSchedule.abortSchedule();
       FetchInventorSignedDocSchedule.abortSchedule();
       IPIASignedForresterSchedule.abortSchedule();
       ExpiredSignDisclosureActionsSchedule.abortSchedule();
       IPIADocuSignDownloadBatchSchedule.abortSchedule();
       iEdisonInventionSearchSchedule.abortSchedule();
       iEdisonInventionUpdateSchedule.abortSchedule();
       iEdisonUtilizationSubmitRetrySchedule.abortSchedule();

    }

    // We dont have a managed package.
    global void afterInstall() {
        DisclosureInventorSignedForresterSch.scheduleMe();
        CRONJobEmail.scheduleMe();
        DraftDisclosureReminderSchedule.scheduleMe();
        ArchiveDraftDisclosuresSchedule.scheduleMe();
        DisclosureDeptHeadEndorseReminderSch.scheduleMe();
        DisclosureInventorSignReminderSchedule.scheduleMe();
        TloOfficerForresterSchedule.scheduleMe();
        CleanupRecordBatchSchedule.scheduleMeForCleanUp();
        FetchInventorSignedDocSchedule.scheduleMe();
        IPIASignedForresterSchedule.scheduleMe();
        ExpiredSignDisclosureActionsSchedule.scheduleMe();
        IPIADocuSignDownloadBatchSchedule.scheduleMe();
        iEdisonInventionSearchSchedule.scheduleMe();
        iEdisonInventionUpdateSchedule.scheduleMe();
        iEdisonUtilizationSubmitRetrySchedule.scheduleMe();
    }
}