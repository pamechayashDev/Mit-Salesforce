public with sharing class DisclosureInventorSignReminderSchedule implements Schedulable {
    public final static String JOB_NAME = 'Disclosure Inventor Sign Reminder';

    public static void scheduleMe() {
        Configurations__c config = Configurations__c.getInstance(
            'DisclosureInventorSignReminderSchedule'
        );
        system.debug('In Schedule:' + config);
        DisclosureInventorSignReminderSchedule sch = new DisclosureInventorSignReminderSchedule();
        system.schedule(JOB_NAME, config.Value__c, sch);
    }

    public static void abortSchedule() {
        List<CronTrigger> triggers = [
            SELECT
                Id,
                CronJobDetailId,
                State,
                CronExpression,
                OwnerId,
                CronJobDetail.Name
            FROM CronTrigger
        ];
        for (CronTrigger delCron : triggers) {
            if (delCron.CronJobDetail.Name == JOB_NAME) {
                System.abortJob(delCron.Id);
                System.debug('CronTrigger exist ' + delCron.Id);
            }
        }
    }
    public void execute(SchedulableContext sc) {
        DisclosureInventorSignReminder sfu = new DisclosureInventorSignReminder();
        Database.executeBatch(sfu, 200);
    }
}