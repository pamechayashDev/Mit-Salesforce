/**
 * Created by Andreas du Preez on 2024/11/01.
 */

@IsTest
public with sharing class ComplianceUtilizationReportControlleTest {

    // Mock class for Forrester_Case__x
    class ForresterCaseMock extends ExternalObjectQuery {
        final List<Forrester_Case__x> externalRecords;

        ForresterCaseMock(List<Forrester_Case__x> externalRecords) {
            this.externalRecords = externalRecords;
        }

        protected override List<SObject> passThrough(List<SObject> records) {
            return externalRecords;
        }
    }

    @TestSetup
    public static void testSetup() {
        // Create a Utilization Report Config
        Utilization_Report_Config__c config = new Utilization_Report_Config__c();
        config.Fiscal_Year__c = '2024';
        config.Start_Date__c = Date.newInstance(2024, 1, 1);
        config.End_Date__c = Date.newInstance(2024, 12, 31);
        insert config;

        // Create a Utilization Report: Licensed
        List<Utilization_Report__c> reports = new List<Utilization_Report__c>();
        Utilization_Report__c reportLicensed = new Utilization_Report__c();
        reportLicensed.Invention_Docket_Number__c = '987654321';
        reportLicensed.Utilization_Report_Status__c = 'Include for Utilization';
        reportLicensed.Latest_Stage_of_Development__c = 'Licensed';
        reportLicensed.Notes__c = 'Licensed';
        reportLicensed.Case_RecId__c = '1574340';
        reports.add(reportLicensed);

        // Create a Utilization Report: Commercialized
        Utilization_Report__c reportCommercialized = new Utilization_Report__c();
        reportCommercialized.Invention_Docket_Number__c = '123456789';
        reportCommercialized.Latest_Stage_of_Development__c = 'Commercialized';
        reportCommercialized.Notes__c = 'Commercialized';
        reports.add(reportCommercialized);
        insert reports;

        // Create a Utilization Licensees:
        List<Utilization_Licensee__c> licensees = new List<Utilization_Licensee__c>();
        Utilization_Licensee__c licensee = new Utilization_Licensee__c();
        licensee.Utilization_Report__c = reportCommercialized.Id;
        licensee.Licensee_Name__c = 'Test Licensee 1';
        licensee.Exclusive_Count__c = 1;
        licensee.Non_Exclusive_Count__c = 1;
        licensee.Small_Business__c = true;
        licensees.add(licensee);

        Utilization_Licensee__c licensee2 = new Utilization_Licensee__c();
        licensee2.Utilization_Report__c = reportCommercialized.Id;
        licensee2.Licensee_Name__c = 'Test Licensee 2';
        licensee2.Exclusive_Count__c = 1;
        licensee2.Non_Exclusive_Count__c = 1;
        licensee2.Small_Business__c = true;
        licensees.add(licensee2);
        insert licensees;

        // Create a Utilization Manufacturing Comm Prod:
        List<Utilization_Manufacturing_Comm_Prod__c> manCommProds = new List<Utilization_Manufacturing_Comm_Prod__c>();
        Utilization_Manufacturing_Comm_Prod__c manCommProd = new Utilization_Manufacturing_Comm_Prod__c();
        manCommProd.Utilization_Report__c = reportCommercialized.Id;
        manCommProd.Naics_Code__c = '1234';
        manCommProd.Product_Name__c = 'Some Product 1';
        manCommProds.add(manCommProd);

        Utilization_Manufacturing_Comm_Prod__c manCommProd2 = new Utilization_Manufacturing_Comm_Prod__c();
        manCommProd2.Utilization_Report__c = reportCommercialized.Id;
        manCommProd2.Naics_Code__c = '4321';
        manCommProd2.Product_Name__c = 'Some Product 2';
        manCommProds.add(manCommProd2);
        insert manCommProds;

        // Create a Utilization Licensee Comm Prod Junction Object:
        List<Utilization_Licensee_Man_Comm_Prod__c> licenseeManCommProds = new List<Utilization_Licensee_Man_Comm_Prod__c>();
        Utilization_Licensee_Man_Comm_Prod__c licenseeManCommProd = new Utilization_Licensee_Man_Comm_Prod__c();
        licenseeManCommProd.Utilization_Licensee__c = licensee.Id;
        licenseeManCommProd.Utilization_Manufacturing_Comm_Prod__c = manCommProd.Id;
        licenseeManCommProds.add(licenseeManCommProd);

        Utilization_Licensee_Man_Comm_Prod__c licenseeManCommProd2 = new Utilization_Licensee_Man_Comm_Prod__c();
        licenseeManCommProd2.Utilization_Licensee__c = licensee2.Id;
        licenseeManCommProd2.Utilization_Manufacturing_Comm_Prod__c = manCommProd2.Id;
        licenseeManCommProds.add(licenseeManCommProd2);
        insert licenseeManCommProds;

        // Create Utilization Manufacturers:
        List<Utilization_Manufacturers__c> manufacturers = new List<Utilization_Manufacturers__c>();
        Utilization_Manufacturers__c manufacturer = new Utilization_Manufacturers__c();
        manufacturer.Utilization_Licensee_Man_Comm_Prod__c = licenseeManCommProd.Id;
        manufacturer.Manufacturer_Name__c = 'Test Manufacturer 1';
        manufacturers.add(manufacturer);

        Utilization_Manufacturers__c manufacturer2 = new Utilization_Manufacturers__c();
        manufacturer2.Utilization_Licensee_Man_Comm_Prod__c = licenseeManCommProd2.Id;
        manufacturer2.Manufacturer_Name__c = 'Test Manufacturer 2';
        manufacturers.add(manufacturer2);
        insert manufacturers;

        // Create Utilization Product Locations:
        List<Utilization_Product_Location__c> productLocations = new List<Utilization_Product_Location__c>();
        Utilization_Product_Location__c productLocation = new Utilization_Product_Location__c();
        productLocation.Utilization_Manufacturer__c = manufacturer.Id;
        productLocation.Country__c = 'US';
        productLocation.State__c = 'CA';
        productLocation.First_Date__c = System.today().addDays(-30);
        productLocation.First_Date_Type__c = 'Actual';
        productLocation.Product_Quantity__c = 100;
        productLocations.add(productLocation);

        Utilization_Product_Location__c productLocation2 = new Utilization_Product_Location__c();
        productLocation2.Utilization_Manufacturer__c = manufacturer.Id;
        productLocation2.Country__c = 'US';
        productLocation2.State__c = 'CA';
        productLocation2.First_Date__c = System.today().addDays(-30);
        productLocation2.First_Date_Type__c = 'Actual';
        productLocation2.Product_Quantity__c = 100;
        productLocations.add(productLocation2);

        Utilization_Product_Location__c productLocation3 = new Utilization_Product_Location__c();
        productLocation3.Utilization_Manufacturer__c = manufacturer2.Id;
        productLocation3.Country__c = 'US';
        productLocation3.State__c = 'CA';
        productLocation3.First_Date__c = System.today().addDays(-30);
        productLocation3.First_Date_Type__c = 'Actual';
        productLocation3.Product_Quantity__c = 100;
        productLocations.add(productLocation3);

        Utilization_Product_Location__c productLocation4 = new Utilization_Product_Location__c();
        productLocation4.Utilization_Manufacturer__c = manufacturer2.Id;
        productLocation4.Country__c = 'US';
        productLocation4.State__c = 'CA';
        productLocation4.First_Date__c = System.today().addDays(-30);
        productLocation4.First_Date_Type__c = 'Actual';
        productLocation4.Product_Quantity__c = 100;
        productLocations.add(productLocation4);
        insert productLocations;
    }

    @IsTest
    public static void testGetUtilizationReport() {
        Utilization_Report__c report = [SELECT Id FROM Utilization_Report__c WHERE Invention_Docket_Number__c = '123456789' LIMIT 1];

        Test.startTest();
        ComplianceUtilizationReportController.UtilizationReportWrapper result = ComplianceUtilizationReportController.getUtilizationReport(report.Id);
        Test.stopTest();

        System.assertEquals(report.Id, result.utilizationReport.Id);
        Assert.isNotNull(result.utilizationReportConfig.Id, 'Utilization Report Config should be populated');

        Assert.areEqual(result.utilizationReport.Id, report.Id, 'Utilization Report should be populated');
        Assert.areEqual(2, result.manufacturingCommProds.size(), 'Manufacturing Comm Prods should be populated');
        Assert.areEqual(2, result.licensees.size(), 'Licensees should be populated');
        Assert.isNotNull(result.manufacturingCommProds[0].commercialProd, 'Commercial Prod should be populated');
        Assert.areEqual(2, result.manufacturingCommProds[0].licenseesProducts[0].licenseeManufacturers[0].manufacturerProductLocations.size(), 'Product Locations should be populated');
        Assert.areEqual(2, result.manufacturingCommProds[1].licenseesProducts[0].licenseeManufacturers[0].manufacturerProductLocations.size(), 'Product Locations should be populated');
    }

    @IsTest
    public static void testInsertUtilizationReport() {
        ComplianceUtilizationReportController.UtilizationReportWrapper wrapper = buildUtilizationReportWrapper();

        Test.startTest();
        ComplianceUtilizationReportController.saveUtilizationReport(wrapper, false);
        Test.stopTest();

        ComplianceUtilizationReportController.UtilizationReportWrapper result = ComplianceUtilizationReportController.getUtilizationReport(wrapper.utilizationReport.Id);

        Assert.areEqual(2, result.manufacturingCommProds.size(), 'Manufacturing Comm Prods should be populated');
        Assert.areEqual(2, result.licensees.size(), 'Licensees should be populated');
        Assert.isNotNull(result.manufacturingCommProds[0].commercialProd, 'Commercial Prod should be populated');
        Assert.areEqual(2, result.manufacturingCommProds[0].licenseesProducts[0].licenseeManufacturers[0].manufacturerProductLocations.size(), 'Product Locations should be populated');
        Assert.areEqual(2, result.manufacturingCommProds[1].licenseesProducts[0].licenseeManufacturers[0].manufacturerProductLocations.size(), 'Product Locations should be populated');
    }

    // TODO: Add Update and Delete Tests

    public static ComplianceUtilizationReportController.UtilizationReportWrapper buildUtilizationReportWrapper() {
        // Create a Utilization Report: Commercialized
        Utilization_Report__c reportCommercialized = new Utilization_Report__c();
        reportCommercialized.Invention_Docket_Number__c = '123456789';
        reportCommercialized.Latest_Stage_of_Development__c = 'Commercialized';
        reportCommercialized.Notes__c = 'Commercialized';
        insert reportCommercialized;


        // Create a Utilization Licensees:
        List<Utilization_Licensee__c> licensees = new List<Utilization_Licensee__c>();
        Utilization_Licensee__c licensee = new Utilization_Licensee__c();
        licensee.Utilization_Report__c = reportCommercialized.Id;
        licensee.Licensee_Name__c = 'Test Licensee 1';
        licensee.Exclusive_Count__c = 1;
        licensee.Non_Exclusive_Count__c = 1;
        licensee.Small_Business__c = true;
        licensees.add(licensee);

        Utilization_Licensee__c licensee2 = new Utilization_Licensee__c();
        licensee2.Utilization_Report__c = reportCommercialized.Id;
        licensee2.Licensee_Name__c = 'Test Licensee 2';
        licensee2.Exclusive_Count__c = 1;
        licensee2.Non_Exclusive_Count__c = 1;
        licensee2.Small_Business__c = true;
        licensees.add(licensee2);
        insert licensees;

        // Create a Utilization Manufacturing Comm Prod:
        List<Utilization_Manufacturing_Comm_Prod__c> manCommProds = new List<Utilization_Manufacturing_Comm_Prod__c>();
        Utilization_Manufacturing_Comm_Prod__c manCommProd = new Utilization_Manufacturing_Comm_Prod__c();
        manCommProd.Utilization_Report__c = reportCommercialized.Id;
        manCommProd.Naics_Code__c = '1234';
        manCommProd.Product_Name__c = 'Some Product 1';

        Utilization_Manufacturing_Comm_Prod__c manCommProd2 = new Utilization_Manufacturing_Comm_Prod__c();
        manCommProd2.Utilization_Report__c = reportCommercialized.Id;
        manCommProd2.Naics_Code__c = '4321';
        manCommProd2.Product_Name__c = 'Some Product 2';
        manCommProds.add(manCommProd2);

        // Create a Utilization Licensee Comm Prod Junction Object:
        Utilization_Licensee_Man_Comm_Prod__c licenseeManCommProd = new Utilization_Licensee_Man_Comm_Prod__c();
        licenseeManCommProd.Utilization_Licensee__c = licensee.Id;

        Utilization_Licensee_Man_Comm_Prod__c licenseeManCommProd2 = new Utilization_Licensee_Man_Comm_Prod__c();
        licenseeManCommProd2.Utilization_Licensee__c = licensee2.Id;

        // Create Utilization Manufacturers:
        Utilization_Manufacturers__c manufacturer = new Utilization_Manufacturers__c();
        manufacturer.Utilization_Licensee_Man_Comm_Prod__c = licenseeManCommProd.Id;
        manufacturer.Manufacturer_Name__c = 'Test Manufacturer 1';

        Utilization_Manufacturers__c manufacturer2 = new Utilization_Manufacturers__c();
        manufacturer2.Utilization_Licensee_Man_Comm_Prod__c = licenseeManCommProd2.Id;
        manufacturer2.Manufacturer_Name__c = 'Test Manufacturer 2';

        // Create Utilization Product Locations:
        Utilization_Product_Location__c productLocation = new Utilization_Product_Location__c();
        productLocation.Utilization_Manufacturer__c = manufacturer.Id;
        productLocation.Country__c = 'US';
        productLocation.State__c = 'CA';
        productLocation.First_Date__c = System.today().addDays(-30);
        productLocation.First_Date_Type__c = 'Actual';
        productLocation.Product_Quantity__c = 100;

        Utilization_Product_Location__c productLocation2 = new Utilization_Product_Location__c();
        productLocation2.Utilization_Manufacturer__c = manufacturer.Id;
        productLocation2.Country__c = 'US';
        productLocation2.State__c = 'CA';
        productLocation2.First_Date__c = System.today().addDays(-30);
        productLocation2.First_Date_Type__c = 'Actual';
        productLocation2.Product_Quantity__c = 100;

        Utilization_Product_Location__c productLocation3 = new Utilization_Product_Location__c();
        productLocation3.Utilization_Manufacturer__c = manufacturer2.Id;
        productLocation3.Country__c = 'US';
        productLocation3.State__c = 'CA';
        productLocation3.First_Date__c = System.today().addDays(-30);
        productLocation3.First_Date_Type__c = 'Actual';
        productLocation3.Product_Quantity__c = 100;

        Utilization_Product_Location__c productLocation4 = new Utilization_Product_Location__c();
        productLocation4.Utilization_Manufacturer__c = manufacturer2.Id;
        productLocation4.Country__c = 'US';
        productLocation4.State__c = 'CA';
        productLocation4.First_Date__c = System.today().addDays(-30);
        productLocation4.First_Date_Type__c = 'Actual';
        productLocation4.Product_Quantity__c = 100;

        // Build the Wrapper
        ComplianceUtilizationReportController.ManufacturerWrapper manufacturerWrapper1 = new ComplianceUtilizationReportController.ManufacturerWrapper(manufacturer, new List<Utilization_Product_Location__c>{productLocation, productLocation2}, null);
        ComplianceUtilizationReportController.ManufacturerWrapper manufacturerWrapper2 = new ComplianceUtilizationReportController.ManufacturerWrapper(manufacturer2, new List<Utilization_Product_Location__c>{productLocation3, productLocation4}, null);

        ComplianceUtilizationReportController.LicenseeProductWrapper licenseeProductWrapper1 = new ComplianceUtilizationReportController.LicenseeProductWrapper(licenseeManCommProd, new List<ComplianceUtilizationReportController.ManufacturerWrapper>{manufacturerWrapper1}, null);
        ComplianceUtilizationReportController.LicenseeProductWrapper licenseeProductWrapper2 = new ComplianceUtilizationReportController.LicenseeProductWrapper(licenseeManCommProd2, new List<ComplianceUtilizationReportController.ManufacturerWrapper>{manufacturerWrapper2}, null);

        ComplianceUtilizationReportController.CommProdWrapper commProdWrapper1 = new ComplianceUtilizationReportController.CommProdWrapper(manCommProd, new List<ComplianceUtilizationReportController.LicenseeProductWrapper>{licenseeProductWrapper1}, null);
        ComplianceUtilizationReportController.CommProdWrapper commProdWrapper2 = new ComplianceUtilizationReportController.CommProdWrapper(manCommProd2, new List<ComplianceUtilizationReportController.LicenseeProductWrapper>{licenseeProductWrapper2}, null);

        ComplianceUtilizationReportController.UtilizationReportWrapper wrapper = new ComplianceUtilizationReportController.UtilizationReportWrapper();
        wrapper.utilizationReport = reportCommercialized;
        wrapper.licensees = licensees;
        wrapper.manufacturingCommProds = new List<ComplianceUtilizationReportController.CommProdWrapper>{commProdWrapper1, commProdWrapper2};

        return wrapper;
    }

    @isTest
    static void testGetUtilizationReports(){
        String searchTerm = '1574340';
		Utilization_Report__c report = [SELECT Id FROM Utilization_Report__c WHERE Invention_Docket_Number__c = '987654321' LIMIT 1];
        
        List<Forrester_Case__x> mockRecords = new List<Forrester_Case__x>();
        Forrester_Case__x mockRecord = new Forrester_Case__x();
        mockRecord.CASE_RECID__c = searchTerm;
        mockRecords.add(mockRecord);

        ExternalObjectQuery.setMock(new ForresterCaseMock(mockRecords));

        Test.startTest();
        List<Forrester_Case__x> forresterCaseResult =  ComplianceUtilizationReportController.getCasesRelatedToUtilizationReport(report.Id);
        Test.stopTest();

        Assert.areEqual(0, forresterCaseResult.size());
    }

    @isTest
    static void testGetTotalCasesForUtilizationReports(){
        String searchTerm = '1574340';
        Utilization_Report__c report = [SELECT Id FROM Utilization_Report__c WHERE Invention_Docket_Number__c = '987654321' LIMIT 1];
        
        List<Forrester_Case__x> mockRecords = new List<Forrester_Case__x>();
        Forrester_Case__x mockRecord = new Forrester_Case__x();
        mockRecord.CASE_RECID__c = searchTerm;
        mockRecords.add(mockRecord);
        
        ExternalObjectQuery.setMock(new ForresterCaseMock(mockRecords));
        
        Test.startTest();
        Integer totalCases =  ComplianceUtilizationReportController.getTotalCasesForUtilizationReports();
        Test.stopTest();
    }

}