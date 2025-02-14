public with sharing class IPIADocuSignDownloadBatchSchedule implements Schedulable {

    private final static String JOB_NAME = 'IPIA DocuSign Download Batch';

    public static void scheduleMe() {
        IPIADocuSignDownloadBatchSchedule sch = new IPIADocuSignDownloadBatchSchedule();
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
      IPIADocuSignDownloadBatch batchJob = new IPIADocuSignDownloadBatch();
      Database.executeBatch(batchJob, 1); // Can only process one at a time.
    }

    private static String cronSchedule() {
        return ConfigurationBuilder.getConfigurationToString('ipiaDownloadSchedule');
    }
}