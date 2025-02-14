public class ArchiveDraftDisclosuresSchedule implements Schedulable {

    public final static String JOB_NAME = 'Archive Draft Disclosures';

    public static void scheduleMe() {
        ArchiveDraftDisclosuresSchedule sch = new ArchiveDraftDisclosuresSchedule();
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
        ArchiveDraftDisclosures sfu = new ArchiveDraftDisclosures();
        Database.executeBatch(sfu, 200);        
    }

    private static String cronSchedule() {
        return ConfigurationBuilder.getConfigurationToString('archiveDraftOlderThanSchedule');
    }
}