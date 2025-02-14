@isTest
private class PeopleSearchApiTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @isTest 
    static void testCallout() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Call the method to be tested
        List<PeopleSearchApiDto.people> peopleList = PeopleSearchApi.getPeopleDataWithSource('peopleSearchApi', '/search?query=916308536&showSource=1');
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(null, peopleList);
    }

    // MockHttpResponseGenerator class to simulate the HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"people":[{"mitId":"916308536","krbName":"alainkh","legalFirstName":"Alain","legalLastName":"Elkhoury","dobDay":"23","dobMonth":"07","affiliate":false,"student":false,"staff":false,"alumni":true,"gradStudent":false,"undergradStudent":false,"visitingStudent":false,"moiraStatus":"1","moiraClass":"G","mitEmail":"alainkh@mit.edu","nonMitEmail":"elkhoury.alain@outlook.com","alumniEmail":"alainkh@mit.edu","mitHrOrgUnitId":"00000000","mitIdCreationDate":"Thu Oct 01 2020 08:37:21 GMT+0000 (Coordinated Universal Time)","mitIdObsolete":"N","alumniRecordTypeCode":"1A","alumniRecordTypeName":"alumni","alumniCanLogin":true}],"pagination":{"nextPageFrom":null}}');
            res.setStatusCode(200);
            return res;
        }
    }
}