public class ExpiredSignDisclosureActionsSchedule implements Schedulable {

    public static string CANCEL_SIGN_ACTIONS_OLDER_THAN_120_DAYS = 'cancelSignActionsOlderThan120Days';
    public static string CANCEL_SIGN_ACTIONS_OLDER_THAN_999_DAYS = 'cancelSignActionsOlderThan999Days';

    public final static String JOB_NAME = 'Expired Sign Disclosure Actions';

    public static void scheduleMe() {
        ExpiredSignDisclosureActionsSchedule sch = new ExpiredSignDisclosureActionsSchedule();
        system.schedule(JOB_NAME, cronSchedule(), sch);
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
        Integer olderThan120 = getConfigValue(CANCEL_SIGN_ACTIONS_OLDER_THAN_120_DAYS, 120);
        Integer olderThan999 = getConfigValue(CANCEL_SIGN_ACTIONS_OLDER_THAN_999_DAYS, 999);
        ExpiredSignDisclosureActions sfu = new ExpiredSignDisclosureActions(olderThan120, olderThan999);
        Database.executeBatch(sfu, 200);        
    }

    private static String cronSchedule() {
        return ConfigurationBuilder.getConfigurationToString('expiredSignDisclosureActionsSchedule');
    }

    @TestVisible
    private static Integer getConfigValue(String key, Integer defaultValue) {
        try{
            return Integer.valueOf(ConfigurationBuilder.getConfigurationToString(key));
        } catch(Exception ex) {
            return defaultValue;
        }
    }
}