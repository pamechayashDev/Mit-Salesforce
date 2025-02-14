public with sharing class iEdisonInventionUpdateSchedule implements Schedulable {

    public final static String JOB_NAME = 'iEdison Invention Update Schedule';

    public static void scheduleMe() {
        iEdisonInventionUpdateSchedule inventionUpdate = new iEdisonInventionUpdateSchedule();
        System.schedule(JOB_NAME, cronSchedule(), inventionUpdate);
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
        System.enqueueJob(new EdisonInventionSearchJob(true), 0);
    } 
    
    private static String cronSchedule() {
        return ConfigurationBuilder.getConfigurationToString('iEdisonInventionUpdateSchedule');
    }
}