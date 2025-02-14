@isTest
public class SubmitUtilizationReportJobTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
        TestSetup.defaultDocTemplatesConfiguration();
    }


    @isTest
    public static void submitUtilizationReports() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Utilization_Report__c utilizationReport1 = SampleDataFactory.createUtilizationReport('1', '1574340', 2024, 'New');
        Utilization_Report__c utilizationReport2 = SampleDataFactory.createUtilizationReport('2', '1574341', 2024, 'In Progress');
        Utilization_Report__c utilizationReport3 = SampleDataFactory.createUtilizationReport('3', '1574343', 2024, 'Include for Utilization');
        Utilization_Report__c utilizationReport4 = SampleDataFactory.createUtilizationReport('4', '1574344', 2024, 'In Progress');
      
        List<Utilization_Report__c> testList = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c FROM Utilization_Report__c];
        System.debug('testList0:' + JSON.serialize(testList[0], true));
        System.debug('testList1:' + JSON.serialize(testList[1], true));
        System.debug('testList3:' + JSON.serialize(testList[2], true));
        System.debug('testList4:' + JSON.serialize(testList[3], true));


        Utilization_Report__c testItem = [SELECT 
            Id, 
            Name, 
            Invention_Report_Number__c,
            Reporting_Year__c,
            Latest_Stage_of_Development__c,
            Utilization_Report_Status__c,
            First_Commercial_Year_of_Sale__c,
            Total_Income__c,
            New_Us_Jobs__c,
            New_Us_Companies__c,
            Notes__c,
            Commercialization_Plan_Id__c,
            Is_US_Manufacturing_Required_1__c,
            Is_US_Manufacturing_Required_2__c,
            Is_US_Manufacturing_Required_3__c
        FROM Utilization_Report__c 
        WHERE Invention_Report_Number__c = '2' LIMIT 1];

        System.debug('testItem:' + JSON.serialize(testItem, true));

        Test.startTest();
        Id batchprocessid = Database.executeBatch(
            new SubmitUtilizationReportJob(),
            2
        );

        AsyncApexJob aaj = [
            SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
            FROM AsyncApexJob
            WHERE ID = :batchprocessid
        ];
        System.debug('aaj:' + JSON.serialize(aaj, true));
        System.assert(aaj != null);
        Test.stopTest();
        Utilization_Report__c resultReport1 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '1' LIMIT 1];
        Utilization_Report__c resultReport2 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '2' LIMIT 1];
        Utilization_Report__c resultReport3 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '3' LIMIT 1];
        Utilization_Report__c resultReport4 = [SELECT ID, Name, Invention_Report_Number__c, Utilization_Report_Status__c FROM Utilization_Report__c WHERE Invention_Report_Number__c = '4' LIMIT 1];
        System.assert(resultReport1.Utilization_Report_Status__c == 'New');
        System.assert(resultReport2.Utilization_Report_Status__c == 'Completed');
        System.assert(resultReport3.Utilization_Report_Status__c == 'Include for Utilization');
        System.assert(resultReport4.Utilization_Report_Status__c == 'Completed');
    }
}