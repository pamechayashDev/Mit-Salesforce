public with sharing class iEdisonUtilizationSubmitRetrySchedule implements Schedulable {

    public final static String JOB_NAME = 'iEdison Utilization Submit Retry Schedule';

    public static void scheduleMe() {
        iEdisonUtilizationSubmitRetrySchedule utilizationSubmitRetry = new iEdisonUtilizationSubmitRetrySchedule();
        System.schedule(JOB_NAME, cronSchedule(), utilizationSubmitRetry);
    }

    public static void abortSchedule() {
        List<CronTrigger> triggers = [SELECT  
                                        Id, CronJobDetailId, State, CronExpression, OwnerId, CronJobDetail.Name 
                                      FROM CronTrigger];
        for(CronTrigger delCron: triggers)  {
            if(delCron.CronJobDetail.Name == JOB_NAME) {
                System.abortJob(delCron.Id);
                System.debug('CronTrigger exist ' + delCron.Id);
            }
        }
    }

    public void execute(SchedulableContext sc) {
        SubmitUtilizationReportJob submitReportJob = new SubmitUtilizationReportJob();
        Database.executeBatch(submitReportJob, 20); 
    } 
    
    private static String cronSchedule() {
        return ConfigurationBuilder.getConfigurationToString('iEdisonUtilizationSubmitRetrySchedule');
    }
}