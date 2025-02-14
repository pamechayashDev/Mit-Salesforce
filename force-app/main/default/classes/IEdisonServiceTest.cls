@isTest
public with sharing class IEdisonServiceTest {
    @TestSetup
    static void setupTestData() {
        TestSetup.defaultConfiguration();
        TestSetup.defaultDocTemplatesConfiguration();
    }

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

    @IsTest
    static void testUpdateUtilizationReportStatus() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Utilization_Report__c utilizationReport = SampleDataFactory.createUtilizationReportForSubmit('4911501-16-0003', '18436', 2024, 'New');

        Test.startTest();
        String  result = IEdisonService.updateUtilizationReportStatus(utilizationReport.Id, 'Include for Utilization');
        
        Utilization_Report__c current = [SELECT 
                Id, 
                Utilization_Report_Status__c,
                Error_Messages__c
            FROM Utilization_Report__c
            WHERE Id = :utilizationReport.Id LIMIT 1];

        System.assert(result ==  'Success', 'Error');
        System.assert(current.Utilization_Report_Status__c == 'Include for Utilization',
            'Status error'
        );
        Test.stopTest();
    }

    @IsTest
    static void testSubmitUtilizationReport() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Utilization_Report__c utilizationReport = SampleDataFactory.createUtilizationReportForSubmit('4911501-16-0003', '18436', 2024, 'Include for Utilization');

        Test.startTest();
        String  result = IEdisonService.submitUtilizationReport(utilizationReport.Id);
        
        Utilization_Report__c current = [SELECT 
                Id, 
                Utilization_Report_Status__c,
                Error_Messages__c
            FROM Utilization_Report__c
            WHERE Id = :utilizationReport.Id LIMIT 1];

        System.assert(result ==  'Success', 'Error');
        System.assert(current.Utilization_Report_Status__c == 'Completed',
            'Status error'
        );


        List<ContentDocumentLink> cdl = [ SELECT ContentDocumentId,LinkedEntityId
                               FROM ContentDocumentLink WHERE LinkedEntityId =: utilizationReport.Id
                                ];
        System.assert(!cdl.isEmpty(), 'Utilization Document not created');
        try{
          delete new ContentDocument(Id = cdl[0].ContentDocumentId );
          System.assert(false, 'Exception not thrown');
        } catch (Exception e) {
            System.assert(true, 'Cannot delete Utilization Document');
        }

        Test.stopTest();
    }

    @IsTest
    static void testUpdateForresterDataReport() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);
        
        Utilization_Report_Config__c config = SampleDataFactory.createUtilizationReportConfig('2024', '2023-07-01', '2024-06-28', 'LIC;OPT;BY-AGT');
        Utilization_Report__c utilizationReport = SampleDataFactory.createUtilizationReportForSubmit('4911501-16-0003', '11353', 2024, 'New');

        Test.startTest();
        String  result = IEdisonService.updateForresterDataReport(utilizationReport.Id);
        
        Utilization_Report__c current = [SELECT 
                Id, 
                Utilization_Report_Status__c,
                Error_Messages__c
            FROM Utilization_Report__c
            WHERE Id = :utilizationReport.Id LIMIT 1];

        System.assert(result ==  'Success', 'Error');
        System.assert(current.Utilization_Report_Status__c == 'New',
            'Status error'
        );
        Test.stopTest();
    }


    @IsTest
    static void testCreateUtilizationReport() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Utilization_Report__c utilizationReport = SampleDataFactory.createUtilizationReportForSubmit('4911501-16-0003', '18436', 2024, 'Include for Utilization');

        Test.startTest();
        IEdisonService iEdisonService = new IEdisonService();
        Map<Integer,Object> response = iEdisonService.createUtilization(utilizationReport.Id);
        
        IEdisonUtilizationResponse iedisonResponse = (IEdisonUtilizationResponse)response.get(201);

        System.assert(iedisonResponse != null, 'response object is null');
        System.assert(iedisonResponse.inventionReportNumber == '0820102-15-0070',
            'inventionReportNumber error'
        );
        Test.stopTest();
    }

    @IsTest
    static void testUpdateUtilizationReport() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Utilization_Report__c utilizationReport = SampleDataFactory.createUtilizationReport('2', '1574340', 2024, 'New');

        Test.startTest();
        IEdisonService iEdisonService = new IEdisonService();
        Map<Integer,Object> response = iEdisonService.updateUtilization(utilizationReport.Id);

        IEdisonUtilizationResponse iedisonResponse = (IEdisonUtilizationResponse)response.get(201);

        System.debug('response:- ' + JSON.serialize(response, true));
        System.assert(iedisonResponse != null, 'response object is null');
        System.assert(iedisonResponse.inventionReportNumber == '0820102-15-0070',
            'inventionReportNumber error'
        );
        Test.stopTest();
    }

    @IsTest
    static void testSearchUtilizationReport() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Test.startTest();
        IEdisonService iEdisonService = new IEdisonService();
        List<String> titleElectionStatus = new List<String>();
        IEdisonUtilizationSearchResponse response = iEdisonService.searchUtilization(10, 0, '', '', titleElectionStatus, 2022, '');

        System.assert(response != null, 'response object is null');
        System.assert(response.utilizations[0].inventionReportNumber == '0820102-15-0070',
            'inventionReportNumber error'
        );
        Test.stopTest();
    }

    @IsTest
    static void testSearchInventionReport() {
        IEdisonApiMock iEdisonApiMock = new IEdisonApiMock();
        Test.setMock(HttpCalloutMock.class, iEdisonApiMock);

        Test.startTest();
        IEdisonService iEdisonService = new IEdisonService();
        List<String> titleElectionStatus = new List<String>();
        titleElectionStatus.add('Elect to Retain Title');
        titleElectionStatus.add('Designated as Unpatented Biological Material or Research Tool');
        IEdisonInventionSearchResponse response = iEdisonService.searchInvention(10, 0, '', '', titleElectionStatus, '', '');

        System.assert(response != null, 'response object is null');
        System.assert(response.inventions[0].inventionReportNumber == '0820102-15-0070',
            'inventionReportNumber error'
        );
        Test.stopTest();
    }
}