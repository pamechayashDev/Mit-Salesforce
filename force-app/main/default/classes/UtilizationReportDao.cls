public with sharing class UtilizationReportDao {

    public static UtilizationReportWrapper getUtilizationReportWrapperById(String utilReportIdStr) {
        UtilizationReportWrapper utilWrapper = new UtilizationReportWrapper();
        IEdisonService iEdisonService = new IEdisonService();
        Utilization_Report__c utilReport = [SELECT
            Id,
            Name,
            Invention_Report_Number__c,
            Invention_Docket_Number__c,
            Reporting_Year__c,
            Latest_Stage_of_Development__c,
            Utilization_Report_Status__c,
            First_Commercial_Year_of_Sale__c,
            Total_Income__c,
            New_Us_Jobs__c,
            New_Us_Companies__c,
            Notes__c,
            Commercialization_Plan_Id__c,
            toLabel(Commercialization_Plan_Id__c) Commercialization_Plan,
            Is_US_Manufacturing_Required_1__c,
            Is_US_Manufacturing_Required_2__c,
            Is_US_Manufacturing_Required_3__c,
            Election_Status__c,
            Primary_Agency__c,
            Error_Messages__c
        FROM Utilization_Report__c
        WHERE Id = :utilReportIdStr LIMIT 1];
        IEdisonUtilizationSearchResponse existingReport = iEdisonService.searchUtilization(1, 0, utilReport.Invention_Report_Number__c, '', new List<String>(), Integer.valueOf(utilReport.Reporting_Year__c), '');
        utilWrapper.utilizationReport = utilReport;
        if (existingReport.utilizations != null && !existingReport.utilizations.isEmpty()) {
            utilWrapper.utilization = existingReport.utilizations[0];
            utilWrapper.helperIsUSManufacturingRequired1 = utilWrapper.utilization.isUSManufacturingRequired1 == 'Y' ? true: null ;
        }

        String strJSON = JSON.serialize(utilWrapper);
        System.debug(strJSON);
        return utilWrapper;
    }

}