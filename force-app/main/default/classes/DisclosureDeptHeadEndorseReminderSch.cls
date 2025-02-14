public with sharing class DisclosureDeptHeadEndorseReminderSch implements Schedulable {

    public final static String JOB_NAME = 'Disclosure Dept. Head Reminder Notification';

    public static void scheduleMe() {
        Configurations__c config = Configurations__c.getInstance('DisclosureDeptHeadEndorseReminderSch');
        System.debug('In Schedule:'+config);
        DisclosureDeptHeadEndorseReminderSch sch = new DisclosureDeptHeadEndorseReminderSch();
        System.schedule(JOB_NAME, config.Value__c, sch);
    }

    public static void abortSchedule() {
        List<CronTrigger> triggers = [SELECT  Id, CronJobDetailId, State, CronExpression, OwnerId ,CronJobDetail.Name FROM CronTrigger];
        for(CronTrigger delCron: triggers)  {
            if(delCron.CronJobDetail.Name == JOB_NAME) {
                System.abortJob(delCron.Id);
                System.debug('CronTrigger exist ' + delCron.Id);
            }
        }
    }
    public void execute(SchedulableContext sc) {
        DisclosureDeptHeadEndorseReminder sfu = new DisclosureDeptHeadEndorseReminder();
        Database.executeBatch(sfu, 200);        
    }
}