public with sharing class CleanupRecordBatchSchedule implements Schedulable {
    
    public final static String CLEANUP_JOB_NAME_INITIAL = 'RECORD CLEANUP';
    
    public String sObjectName {get; set;}
    public Integer numberOfDays{get;set;} 
    public String olderThan{get;set;} 
    
    public CleanupRecordBatchSchedule(String sObjectName, Integer numberOfDays, String olderThan) {
        this.sObjectName = sObjectName;
        this.numberOfDays = numberOfDays;
        this.olderThan = this.olderThan;
    }
    
    public static void scheduleMeForCleanUp() {
        List<Cleanup_Config__c> configList = [SELECT Id, 
                                                Older_Than_x_days__c, 
                                                sObject_Name__c, 
                                                Unit_of_Time__c 
                                            FROM 
                                                Cleanup_Config__c 
                                            LIMIT 100];
        if(configList != null && !configList.isEmpty()) {
            for(Cleanup_Config__c config:configList) {
                CleanupRecordBatchSchedule sch = new CleanupRecordBatchSchedule(config.sObject_Name__c, Integer.valueOf(config.Older_Than_x_days__c), config.Unit_of_Time__c);
                System.schedule(CLEANUP_JOB_NAME_INITIAL + config.sObject_Name__c, config.Older_Than_x_days__c, sch);
            }
        }
    }
    
    public static void abortSchedule() {
        List<CronTrigger> triggers = [SELECT  Id, CronJobDetailId, State, CronExpression, OwnerId ,CronJobDetail.Name FROM CronTrigger];
        for(CronTrigger delCron: triggers)  {
            String cronJobName = delCron.CronJobDetail.Name;
            if(cronJobName != null && cronJobName.startsWith(CLEANUP_JOB_NAME_INITIAL)) {
                System.abortJob(delCron.Id);
            }
        }
    }
    public void execute(SchedulableContext sc) {
        CleanupRecordBatch sfu = new CleanupRecordBatch(sObjectName, numberOfDays, olderThan);
        Database.executeBatch(sfu, 200);        
    }
}