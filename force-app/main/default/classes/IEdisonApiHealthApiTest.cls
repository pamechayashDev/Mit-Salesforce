@isTest
private class IEdisonApiHealthApiTest {
    /**
     * 
     *
     * A shallow connectivity check, any error response indicates a problem.
     */
    @isTest
    private static void apiHealthPingGetTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        IEdisonClient client;
        IEdisonApiHealthApi api;
        IEdisonApiHealthPingResponse response;
        IEdisonApiHealthPingResponse expectedResponse;
        String js = '';

        client = new IEdisonClient();
        api = new IEdisonApiHealthApi(client);

        js = JSON.serialize(IEdisonApiHealthPingResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonApiHealthPingResponse.getExample();
        response = (IEdisonApiHealthPingResponse) api.apiHealthPingGet();
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonApiHealthApi(client);

        js = JSON.serialize(IEdisonApiHealthPingResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonApiHealthPingResponse.getExample();
        response = (IEdisonApiHealthPingResponse) api.apiHealthPingGet();
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonApiHealthApi(client);

        js = JSON.serialize(IEdisonApiHealthPingResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonApiHealthPingResponse.getExample();
        response = (IEdisonApiHealthPingResponse) api.apiHealthPingGet();
        System.assertEquals(expectedResponse, response);
    }

    /**
     * 
     *
     * A deep connectivity check, dependency errors indicate an issue impacting the API functionality.
     */
    @isTest
    private static void apiHealthStatusGetTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        IEdisonClient client;
        IEdisonApiHealthApi api;
        IEdisonApiHealthStatusResponse response;
        IEdisonApiHealthStatusResponse expectedResponse;
        String js = '';

        client = new IEdisonClient();
        api = new IEdisonApiHealthApi(client);

        js = JSON.serialize(IEdisonApiHealthStatusResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonApiHealthStatusResponse.getExample();
        response = (IEdisonApiHealthStatusResponse) api.apiHealthStatusGet();
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonApiHealthApi(client);

        js = JSON.serialize(IEdisonApiHealthStatusResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonApiHealthStatusResponse.getExample();
        response = (IEdisonApiHealthStatusResponse) api.apiHealthStatusGet();
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonApiHealthApi(client);

        js = JSON.serialize(IEdisonApiHealthStatusResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonApiHealthStatusResponse.getExample();
        response = (IEdisonApiHealthStatusResponse) api.apiHealthStatusGet();
        System.assertEquals(expectedResponse, response);
    }
}