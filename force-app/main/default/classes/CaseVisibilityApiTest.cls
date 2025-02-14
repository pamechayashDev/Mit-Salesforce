@IsTest
public class CaseVisibilityApiTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    static List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x > getExternalInventorMock() {
        List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x > mockRecords = new List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x >();
        Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x mockRecord = new Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x();
        mockRecord.CASE_RECID__c = '16235' ;
        mockRecord.MIT_ID__c = '910006320';
        mockRecord.CONTRACT_CASE_NUM__c = '9209L';
        mockRecord.IS_PRIMARY_PI__c = true;
        mockRecord.INVENTOR_NAME__c = 'Mr Inventor';
        mockRecord.PREFERRED_EMAIL__c = 'mrinventor@test.com';
        mockRecords.add(mockRecord);
        return mockRecords;
    }
    static List<Forrester_Case__x> getExternalCaseMock() {

        List<Forrester_Case__x> mockCaseRecords = new List<Forrester_Case__x>();
        Forrester_Case__x mockCaseRecord = new Forrester_Case__x();
        mockCaseRecord.CASE_RECID__c = '16235';
        mockCaseRecord.CONTRACT_CASE_NUM__c = '10368J';
        mockCaseRecord.CASE_NO_SUFFIX__c = '10368';
        mockCaseRecord.SORT_ORDER__c = '1';
        mockCaseRecord.CASE_SUFFIX__c = 'J';
        mockCaseRecord.CASE_TYPE__c = 'Invention';
        mockCaseRecord.DISCLOSURE_TITLE__c = 'DISCLOSURE_TITLE';
        mockCaseRecord.STATUS__c = 'Pre Closed';
        mockCaseRecord.CASE_STATUS__c = 'Active';
        mockCaseRecord.OPEN_DATE__c = Date.newInstance(2025, 7, 7);
        mockCaseRecord.CONCEPTION_DATE__c = DateTime.now();
        mockCaseRecords.add(mockCaseRecord);
        return mockCaseRecords;

    }
    static List<Forrester_SHIR_CASE_IP_VIEW__x> getExternalPatentMock() {
        List<Forrester_SHIR_CASE_IP_VIEW__x> mockPatentRecords = new List<Forrester_SHIR_CASE_IP_VIEW__x>();
        Forrester_SHIR_CASE_IP_VIEW__x mockPatentRecord = new Forrester_SHIR_CASE_IP_VIEW__x();
        mockPatentRecord.SERIAL_NUM__c = '08/486806';
        mockPatentRecord.FILE_DATE__c = DateTime.now().date();
        mockPatentRecord.IP_STATUS_DESCRIPTION__c = 'Granted';
        mockPatentRecord.IP_TYPE_DESCRIPTION__c = 'Patent Cooperation Treaty';
        mockPatentRecord.PATENT_NUM__c = '11/662551';
        mockPatentRecord.PATENT_ISSUED_DATE__c =  DateTime.now().date();
        mockPatentRecord.PUB_NUMBER__c = 'WO89/007136';
        mockPatentRecord.COUNTRY_CODE__c = 'US,NL';
        mockPatentRecord.COUNTRY_NAME__c = 'United States of America,Netherlands';
        mockPatentRecord.DESIGNATED_COUNTRIES__c = 'US;NL';
        mockPatentRecords.add(mockPatentRecord);
        return mockPatentRecords;

    }

    static void mockExternalCases() {
        List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x > mockRecords = getExternalInventorMock();
        List<Forrester_Case__x> mockCaseRecords = getExternalCaseMock();
        StackExternalMock externalMock = new StackExternalMock();
        externalMock.push(mockCaseRecords);
        externalMock.push(mockRecords);

        ExternalObjectQuery.setMock(externalMock);
    }

    static void mockExternalCaseDetail() {
        List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x > mockRecords = getExternalInventorMock();
        List<Forrester_Case__x> mockCaseRecords = getExternalCaseMock();
        StackExternalMock externalMock = new StackExternalMock();
        externalMock.push(mockRecords);
        externalMock.push(mockCaseRecords);

        ExternalObjectQuery.setMock(externalMock);
    }

    @IsTest
    static void caseVisibilityCasesByMitIdTest() {
        mockExternalCases();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/cases/v1/';
        req.httpMethod = 'GET';
        req.params.put('page', '1');
        req.params.put('pageSize', '10');
        req.params.put('mitId', '900053951');
        req.params.put('nameSearch', 'TITLE');
        req.params.put('filters', 'caseStatus:Active,caseType:Invention,openDate>2003-06-20');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CaseVisibilityCasesApi.getCases();
        System.assert(res.statusCode == 200, 'HTTP Status Code should be 200');
        String body = String.valueOf(RestContext.response.responseBody);
        System.debug(body);
        Test.stopTest();
    }

    @IsTest
    static void caseVisibilityCasesByCurrentUserTest() {
        mockExternalCases();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/cases/v1/';
        req.httpMethod = 'GET';
        req.params.put('page', '1');
        req.params.put('pageSize', '10');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        System.runAs(SampleDataTest.getJitUser()) {
            String mitId = CaseVisibilityCasesApi.getContextMitId();
            System.assert(mitId == '02345678', 'Current Account MitId should be used');
            CaseVisibilityCasesApi.getCases();
            String body = String.valueOf(RestContext.response.responseBody);
            System.debug(body);
            System.assert(RestContext.response.statusCode == 200, 'HTTP Status Code should be 200 found ' + res.statusCode);
        }

        Test.stopTest();
    }


    @IsTest
    static void caseVisibilityCaseDetailByMitIdTest() {
        mockExternalCaseDetail();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/cases/detail/v1/';
        req.httpMethod = 'GET';
        req.params.put('caseNumber', '10368');
        req.params.put('mitId', '900053951');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CaseVisibilityCaseDetailApi.getCaseByCaseNumber();
        System.assert(RestContext.response.statusCode == 200, 'HTTP Status Code should be 200');
        String body = String.valueOf(RestContext.response.responseBody);
        System.debug(body);
        Test.stopTest();
    }

    @IsTest
    static void caseVisibilityPatentByCaseNumberTest() {
        List<Forrester_SHIR_CASE_IP_VIEW__x > mockRecords = getExternalPatentMock();
        StackExternalMock externalMock = new StackExternalMock();
        externalMock.push(mockRecords);
        ExternalObjectQuery.setMock(externalMock);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/cases/detail/patents/v1/';
        req.httpMethod = 'GET';
        req.params.put('caseNumber', '10368');
        req.params.put('mitId', '900053951');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CaseVisibilityPatentsApi.getCasePatentsByCaseNumber();
        System.assert(RestContext.response.statusCode == 200, 'HTTP Status Code should be 200');
        String body = String.valueOf(RestContext.response.responseBody);
        System.debug(body);
        Test.stopTest();
    }

    @IsTest
    static void caseVisibilityInventorByCaseNumberTest() {
        List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x > mockRecords = getExternalInventorMock();
        StackExternalMock externalMock = new StackExternalMock();
        externalMock.push(mockRecords);
        ExternalObjectQuery.setMock(externalMock);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/cases/detail/inventors/v1/';
        req.httpMethod = 'GET';
        req.params.put('caseNumber', '9209L');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CaseVisibilityInventorsApi.getCaseInventorsByCaseNumber();
        System.assert(RestContext.response.statusCode == 200, 'HTTP Status Code should be 200');
        String body = String.valueOf(RestContext.response.responseBody);
        System.debug(body);
        Test.stopTest();
    }
}