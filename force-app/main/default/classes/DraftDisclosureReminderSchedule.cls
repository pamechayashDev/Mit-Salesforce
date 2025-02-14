public with sharing class DraftDisclosureReminderSchedule implements Schedulable {

    public final static String JOB_NAME = 'Draft Reminder Scheduler';

    public static void scheduleMe() {
        // TLOS-216 Should receive email reminders that disclosure is still in Draft once a month for 3 months.
        // 30 days after draft is started.
        // 60 days after draft is started and 90 days after draft is started
        // DraftDisclosureReminder draftDisclosure = new DraftDisclosureReminder();

        DraftDisclosureReminderSchedule draftDisclosure = new DraftDisclosureReminderSchedule();
        System.schedule(JOB_NAME, cronSchedule(), draftDisclosure);
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
        DraftDisclosureReminderBatch draftDisclosureBatch = new DraftDisclosureReminderBatch();
        Database.executeBatch(draftDisclosureBatch, 50);
    } 
    
    private static String cronSchedule() {
        return ConfigurationBuilder.getConfigurationToString('draftDisclosureReminder');
    }
}