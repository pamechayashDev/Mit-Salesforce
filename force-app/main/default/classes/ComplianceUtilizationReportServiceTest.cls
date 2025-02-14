/**
 * Created by Andreas du Preez on 2024/11/20.
 */

@IsTest
public with sharing class ComplianceUtilizationReportServiceTest {

    @IsTest
    static void testValidateComplianceUtilizationReportNotLicensed_Notes() {
        // Test data setup
        Utilization_Report__c utilizationReport = new Utilization_Report__c(
            Latest_Stage_of_Development__c = 'Not Licensed',
            Commercialization_Plan_Id__c = '3'
        );
        insert utilizationReport;

        // Test method
        Test.startTest();
        ComplianceUtilizationReportController.UtilizationReportValidationResult result = ComplianceUtilizationReportService.validateComplianceUtilizationReport(utilizationReport.Id);
        Test.stopTest();

        // Verify result
        System.assertEquals(false, result.isValid);
        System.assertEquals(1, result.errorMessages.size());
        System.assertEquals('Notes is required<br>', result.errorMessages[0]);
    }

    @IsTest
    static void testValidateComplianceUtilizationReportsNotLicensedBulk_Notes() {
        // Test data setup
        Utilization_Report__c utilizationReport1 = new Utilization_Report__c(
                Latest_Stage_of_Development__c = 'Not Licensed',
                Commercialization_Plan_Id__c = '3'
        );
        Utilization_Report__c utilizationReport2 = new Utilization_Report__c(
                Latest_Stage_of_Development__c = 'Not Licensed',
                Commercialization_Plan_Id__c = '6'
        );
        insert new List<Utilization_Report__c>{
                utilizationReport1, utilizationReport2
        };

        // Test method
        Test.startTest();
        Map<Id, ComplianceUtilizationReportController.UtilizationReportValidationResult> result = ComplianceUtilizationReportService.validateComplianceUtilizationReports(new List<Id>{
                utilizationReport1.Id, utilizationReport2.Id
        });
        Test.stopTest();

        // Verify result
        System.assertEquals(2, result.size());
        System.assertEquals(false, result.get(utilizationReport1.Id).isValid);
        System.assertEquals(1, result.get(utilizationReport1.Id).errorMessages.size());
        System.assertEquals('Notes is required<br>', result.get(utilizationReport1.Id).errorMessages[0]);
        System.assertEquals(false, result.get(utilizationReport2.Id).isValid);
        System.assertEquals(1, result.get(utilizationReport2.Id).errorMessages.size());
        System.assertEquals('Notes is required<br>', result.get(utilizationReport2.Id).errorMessages[0]);
    }

    @IsTest
    static void testValidateComplianceUtilizationReportNotLicensed_Commercialized() {
        // Test data setup
        Utilization_Report__c utilizationReport = new Utilization_Report__c(
                Latest_Stage_of_Development__c = 'Not Licensed',
                Commercialization_Plan_Id__c = null
        );
        insert utilizationReport;

        // Test method
        Test.startTest();
        ComplianceUtilizationReportController.UtilizationReportValidationResult result = ComplianceUtilizationReportService.validateComplianceUtilizationReport(utilizationReport.Id);
        Test.stopTest();

        // Verify result
        System.assertEquals(false, result.isValid);
        System.assertEquals(1, result.errorMessages.size());
        System.assertEquals('Commercialization Plan is required<br>', result.errorMessages[0]);
    }

    @IsTest
    static void testValidateComplianceUtilizationReportsLicensed_USManufacturingRequired() {
        // Test data setup
        ComplianceUtilizationReportController.UtilizationReportWrapper testData = ComplianceUtilizationReportControlleTest.buildUtilizationReportWrapper();

        testData.utilizationReport.Latest_Stage_of_Development__c = 'Licensed';
        testData.utilizationReport.Is_US_Manufacturing_Required_1__c = null;
        testData.utilizationReport.Is_US_Manufacturing_Required_2__c = null;
        ComplianceUtilizationReportController.saveUtilizationReport(testData, false);

        // Test method
        Test.startTest();
        ComplianceUtilizationReportController.UtilizationReportValidationResult result = ComplianceUtilizationReportService.validateComplianceUtilizationReport(testData.utilizationReport.Id);
        Test.stopTest();

        // Verify result
        System.assertEquals(false, result.isValid);
        System.assertEquals(1, result.errorMessages.size());
        System.assertEquals('Is US Manufacturing Required 1 and 2 is required<br>', result.errorMessages[0]);

    }

    @IsTest
    static void testValidateComplianceUtilizationReportsCommercialized_USManufacturingRequired() {
        // Test data setup
        ComplianceUtilizationReportController.UtilizationReportWrapper testData = ComplianceUtilizationReportControlleTest.buildUtilizationReportWrapper();

        testData.utilizationReport.Latest_Stage_of_Development__c = 'Commercialized';
        testData.utilizationReport.Is_US_Manufacturing_Required_1__c = 'N';
        testData.utilizationReport.Is_US_Manufacturing_Required_2__c = 'N';
        testData.utilizationReport.Is_US_Manufacturing_Required_3__c = null;

        ComplianceUtilizationReportController.saveUtilizationReport(testData, false);

        // Test method
        Test.startTest();
        ComplianceUtilizationReportController.UtilizationReportValidationResult result = ComplianceUtilizationReportService.validateComplianceUtilizationReport(testData.utilizationReport.Id);
        Test.stopTest();

        // Verify result
        System.assertEquals(false, result.isValid);
        System.assertEquals(1, result.errorMessages.size());
        System.assertEquals('Is US Manufacturing Required 1, 2 and 3 is required<br>', result.errorMessages[0]);
    }

    @IsTest
    static void testValidateComplianceUtilizationReportsCommercialized_ProductLocationRequired() {
        // Test data setup
        ComplianceUtilizationReportController.UtilizationReportWrapper testData = ComplianceUtilizationReportControlleTest.buildUtilizationReportWrapper();

        testData.utilizationReport.Latest_Stage_of_Development__c = 'Commercialized';
        testData.utilizationReport.Is_US_Manufacturing_Required_1__c = 'N';
        testData.utilizationReport.Is_US_Manufacturing_Required_2__c = 'N';
        testData.utilizationReport.Is_US_Manufacturing_Required_3__c = 'N';

        testData.manufacturingCommProds[0].licenseesProducts[0].licenseeManufacturers[0].manufacturerProductLocations = null;

        ComplianceUtilizationReportController.saveUtilizationReport(testData, false);

        // Test method
        Test.startTest();
        ComplianceUtilizationReportController.UtilizationReportValidationResult result = ComplianceUtilizationReportService.validateComplianceUtilizationReport(testData.utilizationReport.Id);
        Test.stopTest();

        // Verify result
        System.assertEquals(false, result.isValid);
        System.assertEquals(1, result.errorMessages.size());
        System.debug(result.errorMessages[0]);
        Assert.isTrue(result.errorMessages[0].contains('Locations are missing for the following Manufacturers'));

    }
}