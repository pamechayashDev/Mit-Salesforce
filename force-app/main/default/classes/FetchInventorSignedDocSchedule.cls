public with sharing class FetchInventorSignedDocSchedule implements Schedulable {

    private final static String JOB_NAME = 'Fetch Inventor Signed Documents';

    public static void scheduleMe() {
        FetchInventorSignedDocSchedule sch = new FetchInventorSignedDocSchedule();
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
        FetchInventorSignedDocJob sfu = new FetchInventorSignedDocJob();
        Database.executeBatch(sfu, 20); // This is doing a call out and can only process one at a time.
    }

    private static String cronSchedule() {
        return ConfigurationBuilder.getConfigurationToString('fetchInventorSignedDocSchedule');
    }
}