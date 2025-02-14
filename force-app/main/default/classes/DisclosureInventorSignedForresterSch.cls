public class DisclosureInventorSignedForresterSch implements Schedulable {
     public static final String JOB_NAME = 'Disclosure Inventor Signed To Forrester';
     private static final String MANUAL_JOB_NAME = JOB_NAME + '(M)';

     // Schedule Forrester Sync data to be sent every 10 min
     private static final Map<String, String> CRON_MAP = new Map<String, String > {
         JOB_NAME + ' 00' => '0 0 * * * ?',
         JOB_NAME + ' 10' => '0 10 * * * ?',
         JOB_NAME + ' 20' => '0 20 * * * ?',
         JOB_NAME + ' 30' => '0 30 * * * ?',
         JOB_NAME + ' 40' => '0 40 * * * ?',
         JOB_NAME + ' 50' => '0 50 * * * ?'
     };
   public static void scheduleMe() {
           DisclosureInventorSignedForresterSch sch = new DisclosureInventorSignedForresterSch ();
           for (String key : CRON_MAP.keySet()) {
               String jobID0 = system.schedule(key, CRON_MAP.get(key), sch);
           }

       }

   public static void abortSchedule() {
       List<CronTrigger> triggers = [SELECT  Id, CronJobDetailId, State, CronExpression, OwnerId ,CronJobDetail.Name FROM CronTrigger];
       for(CronTrigger delCron: triggers)  {
           if(CRON_MAP.get(delCron.CronJobDetail.Name) != null || delCron.CronJobDetail.Name == MANUAL_JOB_NAME) {
               System.abortJob(delCron.Id);
               System.debug('CronTrigger exist ' + delCron.Id);
           }
       }
   }
    
    public void execute(SchedulableContext sc) {
        DisclosureInventorSignedToForrester inventorSigned = new DisclosureInventorSignedToForrester();
        Database.executeBatch(inventorSigned, 1);
    }


}