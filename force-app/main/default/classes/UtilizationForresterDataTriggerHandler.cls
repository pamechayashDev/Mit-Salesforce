public with sharing class UtilizationForresterDataTriggerHandler {
    public static void onBeforeUpdate(
            List<Utilization_Report__c> utilizationReports,
            Map<Id, Utilization_Report__c> oldUtilizationReports
    ) {
        for (Utilization_Report__c currentReport : utilizationReports ) {
            Utilization_Report__c oldReport = (oldUtilizationReports != null &&
                oldUtilizationReports.get(currentReport.Id) != null)
                    ? oldUtilizationReports.get(currentReport.Id)
                    : null;
            checkAndUpdateStatus(currentReport, oldReport); //, updateList);
        }
    }

    private static void checkAndUpdateStatus(Utilization_Report__c current, Utilization_Report__c old) { // , List<Utilization_Report__c> updateList) {
        // System.debug('Begin: checkAndUpdateStatus');
        // System.debug(JSON.serializePretty(old));
        // System.debug(JSON.serializePretty(current));
        Boolean dataChanged = false;

        if ((current.Forrester_Latest_Stage_of_Development__c ?? '') != (old.Forrester_Latest_Stage_of_Development__c ?? '')) {
            dataChanged = true;
        }

        if ((current.Forrester_First_Commercial_Year_of_Sale__c ?? '') != (old.Forrester_First_Commercial_Year_of_Sale__c ?? '')) {
            dataChanged = true;
        }

        if ( current.Forrester_Summarized_Agreement_Income__c <> old.Forrester_Summarized_Agreement_Income__c) {
            dataChanged = true;
        }
        
        if (!String.isBlank(old.Forrester_Exclusive_Optionee_Name__c)) {
            if ((current.Forrester_Exclusive_Optionee_Name__c ?? '') != (old.Forrester_Exclusive_Optionee_Name__c ?? '')) {
                dataChanged = true;
            }
        }
        if (!String.isBlank(old.Forrester_Non_Exclusive_Optionee_Name__c)) {
            if ((current.Forrester_Non_Exclusive_Optionee_Name__c ?? '') != (old.Forrester_Non_Exclusive_Optionee_Name__c ?? '')) {
                dataChanged = true;
            }
        }
        if (!String.isBlank(old.Forrester_Small_Business_Optionee_Name__c)) {
            if ((current.Forrester_Small_Business_Optionee_Name__c ?? '') != (old.Forrester_Small_Business_Optionee_Name__c ?? '')) {
                dataChanged = true;
            }
        }
        
        if (dataChanged) {
            if (
            current.Utilization_Report_Status__c == 'Completed' ||
            current.Utilization_Report_Status__c == 'Error') {
                current.Utilization_Report_Status__c = 'New';
                System.debug('Updating utilization report status to New:' + String.valueOf(current.Id));
            }
        }
        //System.debug('End: checkAndUpdateStatus');
    }
}