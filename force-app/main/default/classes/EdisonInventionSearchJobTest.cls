@isTest
public with sharing class EdisonInventionSearchJobTest {
    
    @TestSetup
    static void setupTestData() {
        TestSetup.defaultConfiguration();
    }
    
    @isTest
    public static void EdisonInventionSearch() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Utilization_Report_Config__c config1 = SampleDataFactory.createUtilizationReportConfig('2023', '2022-07-01', '2023-06-28', 'LIC;OPT;BY-AGT');
        Utilization_Report_Config__c config2 = SampleDataFactory.createUtilizationReportConfig('2024', '2023-07-01', '2024-06-28', 'LIC;OPT;BY-AGT');
        Utilization_Report__c utilizationReport1 = SampleDataFactory.createUtilizationReport('1', '1574340', 2024, 'New');
        Utilization_Report__c utilizationReport2 = SampleDataFactory.createUtilizationReport('2', '1574341', 2024, 'Include for Utilization');
        Utilization_Report__c utilizationReport3 = SampleDataFactory.createUtilizationReportWithError('3', '1574342', 2024);


        Test.startTest();
            System.enqueueJob(new EdisonInventionSearchJob(false), 0);
        Test.stopTest();

        // ASSERT
        Utilization_Report__c utilizationReport4 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '1' LIMIT 1];
        Utilization_Report__c utilizationReport5 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '2' LIMIT 1];
        Utilization_Report__c utilizationReport6 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '3' LIMIT 1];
        Utilization_Report__c utilizationReport7 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '0820102-15-0070' LIMIT 1];
        System.assert(utilizationReport4.Invention_Report_Number__c == '1');
        System.assert(utilizationReport5.Invention_Report_Number__c == '2');
        System.assert(utilizationReport6.Invention_Report_Number__c == '3');
        System.assert(utilizationReport7.Invention_Report_Number__c == '0820102-15-0070');
    }
    @isTest
    public static void EdisonInventionSearchErrorItems() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Utilization_Report_Config__c config1 = SampleDataFactory.createUtilizationReportConfig('2023', '2022-07-01', '2023-06-28', 'LIC;OPT;BY-AGT');
        Utilization_Report_Config__c config2 = SampleDataFactory.createUtilizationReportConfig('2024', '2023-07-01', '2024-06-28', 'LIC;OPT;BY-AGT');
        Utilization_Report__c utilizationReport1 = SampleDataFactory.createUtilizationReport('1', '1574340', 2024, 'New');
        Utilization_Report__c utilizationReport2 = SampleDataFactory.createUtilizationReportWithError('2', '1574342', 2024);
        Utilization_Report__c utilizationReport3 = SampleDataFactory.createUtilizationReportWithError('0820102-15-0070', '11353', 2024);


        Test.startTest();
            System.enqueueJob(new EdisonInventionSearchJob(true), 0);
        Test.stopTest();

        // ASSERT
        Utilization_Report__c utilizationReport4 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c, Case_RecId__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '1' LIMIT 1];
        Utilization_Report__c utilizationReport5 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c, Case_RecId__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '2' LIMIT 1];
        Utilization_Report__c utilizationReport6 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c, Case_RecId__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '0820102-15-0070' LIMIT 1];
        System.assert(utilizationReport4.Invention_Report_Number__c == '1');
        System.assert(utilizationReport5.Invention_Report_Number__c == '2');
        System.assert(utilizationReport6.Invention_Report_Number__c == '0820102-15-0070');
        System.assert(utilizationReport6.Case_RecId__c == '10856');
    }

}