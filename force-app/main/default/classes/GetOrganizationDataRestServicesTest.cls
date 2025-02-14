@isTest
public class GetOrganizationDataRestServicesTest {
    @TestSetup
    static void setup() {
       TestSetup.defaultConfiguration();
    }
    
    @isTest
    static void getOrgDataByNameSearch() {
        Test.setMock(HttpCalloutMock.class, new ApexRestMockServices());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/organizations/v1';
        req.params.put('nameSearch','sf org');
        req.params.put('page','1');
        req.params.put('pageSize','1');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        GetOrganizationDataRestServices.getOrganizationData();
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        List<Object> listRecords = (List<Object>) results.get('results');
        Map<String, Object> jsonEachMap = (Map<String, Object>) listRecords[0];
        
        //ASSERT
        system.assertEquals('1001', String.valueOf(jsonEachMap.get('id')));
        Test.stopTest();
    }
    
    public class ApexRestMockServices implements HttpCalloutMock {
        String databaseName = '23ces';
        String boothName = '8366';
        public HTTPResponse respond(HTTPRequest req) {
            String body='{"totalItems": "2","totalPages": "5","currentPage": "1", "results":[{"id":"1001","name":"SF Record"},{"id":"1002","name":"SF Org"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}