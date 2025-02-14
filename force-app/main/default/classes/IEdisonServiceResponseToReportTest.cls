@isTest
public with sharing class IEdisonServiceResponseToReportTest {
    @TestSetup
    static void setupTestData() {
        TestSetup.defaultConfiguration();
    }


    @IsTest
    static void testCreateUtilizationReport() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Utilization_Report__c utilizationReport = SampleDataFactory.createUtilizationReportForSubmit('4911501-16-0003', '18436', 2024, 'Include for Utilization');
        IEdisonUtilizationResponse response = IEdisonUtilizationResponse.getExample();
        response.reportingYear = 2024;
        response.commercializationPlanId = 3;
        response.latestStageDev = 'Not Licensed';
        response.isUSManufacturingRequired1 = 'Y';
        response.commercialProds[0].commercialName = 'NIH Product A';
        response.licensees[0].licenseeName = 'Test licensee 1';
        response.manufacturingCommProds[0].productName = 'Processor';
        response.manufacturingCommProds[0].licensees[0].licenseeName = 'Test licensee 1';
        response.manufacturingCommProds[0].licensees[0].manufacturers[0].manufacturerName = 'Test Maufacturer1';
        response.manufacturingCommProds[0].licensees[0].manufacturers[0].productLocation[0].country = 'UNITED STATES';


        Test.startTest();
        IEdisonServiceResponseToReport.mapUtilizationResponseToReport(utilizationReport, response, null);

        System.assert(utilizationReport != null, 'utilizationReport object is null');
        System.assert(utilizationReport.Reporting_Year__c == '2024', 'Reporting_Year__c error');
        System.assert(utilizationReport.Total_Income__c == 1.3579, 'Total_Income__c error');
        System.assert(utilizationReport.Latest_Stage_of_Development__c == 'Not Licensed', 'Latest_Stage_of_Development__c error');
        System.assert(utilizationReport.Commercialization_Plan_Id__c == '3', 'Commercialization_Plan_Id__c error');
        System.assert(utilizationReport.Is_US_Manufacturing_Required_1__c == 'Y', 'Is_US_Manufacturing_Required_1__c error');

        Utilization_Commercial_Prods__c  commercialProd = [SELECT Id, Commercial_Name__c from Utilization_Commercial_Prods__c WHERE Utilization_Report__c = :utilizationReport.Id LIMIT 1];
        System.assert(commercialProd.Commercial_Name__c == 'NIH Product A', 'Commercial_Name__c error');

        Utilization_Licensee__c  licensee = [SELECT Id, Licensee_Name__c from Utilization_Licensee__c WHERE Utilization_Report__c = :utilizationReport.Id LIMIT 1];
        System.assert(licensee.Licensee_Name__c == 'Test licensee 1', 'Licensee_Name__c error');

        Utilization_Manufacturing_Comm_Prod__c  manufacturingCommProd = [SELECT Id, Product_Name__c from Utilization_Manufacturing_Comm_Prod__c WHERE Utilization_Report__c = :utilizationReport.Id LIMIT 1];
        System.assert(manufacturingCommProd.Product_Name__c == 'Processor', 'Product_Name__c error');

        Utilization_Licensee_Man_Comm_Prod__c  licenseeManCommProd = [SELECT Id, Utilization_Licensee__c, Utilization_Manufacturing_Comm_Prod__c from Utilization_Licensee_Man_Comm_Prod__c WHERE Utilization_Licensee__c = :licensee.Id  AND Utilization_Manufacturing_Comm_Prod__c = :manufacturingCommProd.Id LIMIT 1];
        System.assert(licenseeManCommProd.Utilization_Licensee__c != null, 'Utilization_Licensee__c error');
        System.assert(licenseeManCommProd.Utilization_Manufacturing_Comm_Prod__c != null, 'Utilization_Manufacturing_Comm_Prod__c error');

        Utilization_Manufacturers__c manufacturer = [SELECT Id, Manufacturer_Name__c from Utilization_Manufacturers__c WHERE Utilization_Licensee_Man_Comm_Prod__c = :licenseeManCommProd.Id LIMIT 1];
        System.assert( manufacturer.Manufacturer_Name__c == 'Test Maufacturer1', 'Manufacturer_Name__c error');

        Utilization_Product_Location__c productLocation  = [SELECT Id, Country__c from Utilization_Product_Location__c WHERE Utilization_Manufacturer__c = :manufacturer.Id LIMIT 1];
        System.assert( productLocation.Country__c == 'US', 'Country__c error');

        Test.stopTest();
    }

}