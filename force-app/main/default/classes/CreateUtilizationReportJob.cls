public class CreateUtilizationReportJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =
            'SELECT Id, Utilization_Report_Status__c, Error_Messages__c From Utilization_Report__c where Utilization_Report_Status__c = \'Include for Utilization\' or Utilization_Report_Status__c = \'In Progress\'';
        return Database.getQueryLocator(query);
    }

    public void execute(
        Database.BatchableContext bc,
        List<Utilization_Report__c> scope
    ) {
        System.debug('--+--' + scope.size());

        IEdisonService iEdisonService = new IEdisonService();
        List<Utilization_Report__c> updateList = new List<Utilization_Report__c>();
        for (Utilization_Report__c utilReport : scope) {
            Utilization_Report__c current = [SELECT 
                Id, 
                Utilization_Report_Status__c,
                Error_Messages__c
            FROM Utilization_Report__c
            WHERE Id = :utilReport.Id LIMIT 1];
            // Verify that the status is still 'Include for Utilization'
            // Retry submission of reports that is still 'in Progress' 
            if (current.Utilization_Report_Status__c == 'Include for Utilization' || current.Utilization_Report_Status__c == 'In Progress') {
                updateList.add(current);
                current.Utilization_Submitted_Date__c = Date.today();
                current.Utilization_Report_Status__c = 'In Progress';
                current.Error_Messages__c = '';
            }

            System.debug('---+Batch+---');
        }

        if (!updateList.isEmpty()) {
            update updateList;
        }
    }

    public void finish(Database.BatchableContext bc) {
        SubmitUtilizationReportJob submitReportJob = new SubmitUtilizationReportJob();
        Database.executeBatch(submitReportJob, 20); 
    }
 }