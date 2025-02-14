@isTest
public with sharing class IEdisonServiceReportToRequestTest {
    @TestSetup
    static void setupTestData() {
        TestSetup.defaultConfiguration();
    }


    @IsTest
    static void testCreateUtilizationReport() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Utilization_Report__c utilizationReport = SampleDataFactory.createUtilizationReportForSubmit('4911501-16-0003', '18436', 2024, 'Include for Utilization');
        IEdisonUtilizationRequest request = new IEdisonUtilizationRequest();
        Test.startTest();
        IEdisonServiceReportToRequest.mapReportToUtilizationRequest(utilizationReport, request);

        System.assert(request != null, 'request object is null');
        System.assert(request.inventionReportNumber == '4911501-16-0003', 'inventionReportNumber error');
        System.assert(request.latestStageDev == 'Not Licensed', 'latestStageDev error');
        System.assert(request.licensees[0].licenseeName == 'Test licensee 1', 'latestStageDev error');
        System.assert(request.commercialProds[0].commercialName == 'NIH Product A', 'commercialName error');
        System.assert(request.manufacturingCommProds[0].productName == 'Processor', 'productName error');
        System.assert(request.manufacturingCommProds[0].licensees[0].licenseeName == 'Test licensee 1', 'licenseeName error');
        System.assert(request.manufacturingCommProds[0].licensees[0].manufacturers[0].manufacturerName == 'Test Maufacturer1', 'manufacturerName error');
        System.assert(request.manufacturingCommProds[0].licensees[0].manufacturers[0].productLocation[0].country == 'UNITED STATES', 'country error');

        Test.stopTest();
    }

}