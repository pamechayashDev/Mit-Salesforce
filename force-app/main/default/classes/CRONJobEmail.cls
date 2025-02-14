global class CRONJobEmail implements Schedulable {

    // Schedule notifications to be sent every 10 min
    private static final Map<String, String> CRON_MAP = new Map<String, String > {
        'Notification Scheduler 00' => '0 0 * * * ?',
        'Notification Scheduler 10' => '0 10 * * * ?',
        'Notification Scheduler 20' => '0 20 * * * ?',
        'Notification Scheduler 30' => '0 30 * * * ?',
        'Notification Scheduler 40' => '0 40 * * * ?',
        'Notification Scheduler 50' => '0 50 * * * ?'
    };

    public static void scheduleMe() {
        CRONJobEmail emailCRON = new CRONJobEmail ();
        for (String key : CRON_MAP.keySet()) {
            String jobID0 = system.schedule(key, CRON_MAP.get(key), emailCRON);
        }

    }
    // Abort only the Notifications Jobs
    public static void abortSchedule() {
        List<CronTrigger> triggers = [SELECT  Id, CronJobDetailId, State, CronExpression, OwnerId ,CronJobDetail.Name FROM CronTrigger];
        for(CronTrigger delCron: triggers)  {
            if(CRON_MAP.get(delCron.CronJobDetail.Name) != null) {
                System.abortJob(delCron.Id);
                System.debug('CronTrigger exist ' + delCron.Id);
            }
        }
    }
    global void execute(SchedulableContext sc) {
        CRONJobEmailBatch jobEmail = new CRONJobEmailBatch();
        Database.executeBatch(jobEmail, 1);    // From a batch you can only add one Queueable Job
    }


 }