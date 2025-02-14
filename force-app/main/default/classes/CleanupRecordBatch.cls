public with sharing class CleanupRecordBatch implements Database.Batchable<sObject> {

    public String sObjectName{get;set;} 
    public Integer olderThan{get;set;} 
    public String unitOfTime{get;set;}
    
    public CleanupRecordBatch(String sObjectName, Integer olderThan, String unitOfTime) {
        this.sObjectName = sObjectName;
        this.olderThan = olderThan;
        this.unitOfTime = unitOfTime;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime dt = Datetime.now();
        if(String.isNotEmpty(unitOfTime)) {
            if(unitOfTime.toUpperCase() == 'HOURS') {
                dt = dt.addHours(-olderThan);
            } else if(unitOfTime.toUpperCase() == 'YEARS') {
                dt = dt.addYears(-olderThan);
            } else {
                dt = dt.addDays(-olderThan);
            } 
        }
        String query = 'SELECT Id,CreatedDate From ' + sObjectName + ' WHERE CreatedDate <= :dt';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        if(scope != null && !scope.isEmpty()) {
            Database.delete(scope);
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}