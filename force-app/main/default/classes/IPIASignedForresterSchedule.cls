public class IPIASignedForresterSchedule implements Schedulable {
     public static final String JOB_NAME = 'IPIA Signed To Forrester Batch';
     public static void scheduleMe() {
        IPIASignedForresterSchedule sch = new IPIASignedForresterSchedule();
        system.schedule(JOB_NAME, cronSchedule(), sch);
    }

    public void execute(SchedulableContext sc) {
        IPIASignedToForresterJob ipiaJob = new IPIASignedToForresterJob();
        Database.executeBatch(ipiaJob, 50);
    }

  public static void abortSchedule() {
        List<CronTrigger> triggers = [SELECT  Id, CronJobDetailId, State, CronExpression, OwnerId ,CronJobDetail.Name FROM CronTrigger]; // and State = 'Waiting'
        for(CronTrigger delCron: triggers)  {
            if (delCron.CronJobDetail.Name == JOB_NAME) {
                System.abortJob(delCron.Id);
                System.debug('CronTrigger exist ' + delCron.Id);
            }
        }
    }

  private static String cronSchedule() {
     return ConfigurationBuilder.getConfigurationToString('IPIAForresterSchedule');
  }

}