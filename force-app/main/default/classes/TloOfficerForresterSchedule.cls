public class TloOfficerForresterSchedule implements Schedulable {
     public static final String JOB_NAME = 'Disclosure TLO Officer From Forrester Batch';
     public static void scheduleMe() {
        TloOfficerForresterSchedule sch = new TloOfficerForresterSchedule();
        system.schedule(JOB_NAME, cronSchedule(), sch);
    }
    
    public void execute(SchedulableContext sc) {
        // Can not do a call out from a Schedulable class
        TloOfficerFromForrester tloOfficerJob = new TloOfficerFromForrester();
        Database.executeBatch(tloOfficerJob, 1);
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
     return ConfigurationBuilder.getConfigurationToString('ForresterTloOfficerSchedule');
  }

}