public class SubmitUtilizationReportJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =
            'SELECT Id, Invention_Report_Number__c From Utilization_Report__c where Utilization_Report_Status__c = \'In Progress\'';
        return Database.getQueryLocator(query);
    }

    public void execute(
        Database.BatchableContext bc,
        List<Utilization_Report__c> scope
    ) {
        System.debug('--+--' + scope.size());

        IEdisonService edisonService = new IEdisonService();
        List<Utilization_Report__c> updateList = new List<Utilization_Report__c>();
        List<ContentVersion> insertContentVersions = new List<ContentVersion>();
        List<Exception> exceptions =  new List<Exception>();
        try {
            for (Utilization_Report__c utilReport : scope) {
                Utilization_Report__c current = [SELECT 
                    Id, 
                    Name,
                    Invention_Docket_Number__c,
                    Invention_Report_Number__c,
                    Reporting_Year__c,
                    Latest_Stage_of_Development__c,
                    Utilization_Report_Status__c,
                    Utilization_Report_Title__c,
                    First_Commercial_Year_of_Sale__c,
                    Total_Income__c,
                    New_Us_Jobs__c,
                    New_Us_Companies__c,
                    Notes__c,
                    Commercialization_Plan_Id__c,
                    Is_US_Manufacturing_Required_1__c,
                    Is_US_Manufacturing_Required_2__c,
                    Is_US_Manufacturing_Required_3__c,
                    Error_Messages__c
                FROM Utilization_Report__c
                WHERE Id = :utilReport.Id LIMIT 1];
                if (current.Utilization_Report_Status__c == 'In Progress') {
                    updateList.add(current);
                    try {
                        IEdisonUtilizationSearchResponse existingReport = edisonService.searchUtilization(1, 0, current.Invention_Report_Number__c, '', new List<String>(), integer.valueof(current.Reporting_Year__c), '');
                        Map<Integer, Object> response;
                        if (existingReport.totalRecords > 0) {
                            response = edisonService.updateUtilization(current.Id);
                        } else {
                            response = edisonService.createUtilization(current.Id);
                        }

                        if (response.get(400) != null) {
                            current.Utilization_Report_Status__c = 'Error';
                            current.Error_Messages__c = JSON.serialize(response.get(400), true);
                        } else {
                            current.Utilization_Report_Status__c = 'Completed';
                            edisonService.mapUtilizationToReport(current, (IEdisonUtilizationResponse)response.get(201));
                            // Submission is Successful, generate the document
                            ContentVersion utilizationDocument = IEdisonService.generateUtilizationDocument(current);
                            insertContentVersions.add(utilizationDocument);
                        }
                    } catch (exception ex) {
                        String message = ex.getMessage();
                        if ((ex.getTypeName() == 'System.CalloutException') &&  (message.contains('401') || message.contains('403') || message.contains('500') || message.contains('502'))) {
                            // Keep report 'In Progress' and retry submission on next scheduled run 
                            System.debug('inner:-' + ex.getMessage());
                            exceptions.add(ex);
                        } else {
                            current.Utilization_Report_Status__c = 'Error';    
                        }
                        IEdisonErrorResponse errorResponse = IEdisonService.FormulateError(ex);
                        current.Error_Messages__c = JSON.serialize(errorResponse, true);
                    }
                }

                System.debug('---+Batch+---');
            }

            for (Exception e : exceptions) {
                HandleLogException.logException(e);
            }

            if (!updateList.isEmpty()) {
                update updateList;
            }
            if (!insertContentVersions.isEmpty()) {
                insert insertContentVersions;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            HandleLogException.logException(e);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

 }