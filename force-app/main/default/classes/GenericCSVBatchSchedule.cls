public with sharing class GenericCSVBatchSchedule implements Schedulable {

    private final static String JOB_NAME = 'Custom Document Report';

    public static void scheduleMe() {
        GenericCSVBatchSchedule sch = new GenericCSVBatchSchedule();
        system.schedule(JOB_NAME, cronSchedule(), sch);
    }

    public static void abortSchedule() {
        List<CronTrigger> triggers = [SELECT  Id, CronJobDetailId, State, CronExpression, OwnerId, CronJobDetail.Name FROM CronTrigger];
        for(CronTrigger delCron: triggers)  {
            if(delCron.CronJobDetail.Name == JOB_NAME) {
                System.abortJob(delCron.Id);
                System.debug('CronTrigger exist ' + delCron.Id);
            }
        }
    }
    
    public void execute(SchedulableContext sc) {
      CustomReports.Settings settings =  CustomReports.getDefaultCustomReportSettings('Content Document Report');
      CustomReports report = new CustomReports();
      report.runContentDocumentReport(settings);
    }

    private static String cronSchedule() {
        return ConfigurationBuilder.getConfigurationToString('csvDocumentReportSchedule');
    }
}