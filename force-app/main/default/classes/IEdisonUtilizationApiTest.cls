@isTest
private class IEdisonUtilizationApiTest {
    /**
     * 
     *
     * Create a new utilization report.
     */
    @isTest
    private static void utilizationsCreatePostTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        Map<String, Object> params = new Map<String, Object>{
            'iedisonUtilizationRequest' => IEdisonUtilizationRequest.getExample()
        };

        IEdisonClient client;
        IEdisonUtilizationApi api;
        IEdisonUtilizationResponse response;
        IEdisonUtilizationResponse expectedResponse;
        String js = '';

        client = new IEdisonClient();
        api = new IEdisonUtilizationApi(client);

        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsCreatePost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsCreatePost(params);
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonUtilizationApi(client);

        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsCreatePost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsCreatePost(params);
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonUtilizationApi(client);

        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsCreatePost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsCreatePost(params);
        System.assertEquals(expectedResponse, response);
    }

    /**
     * 
     *
     * Search for utilization reports.
     */
    @isTest
    private static void utilizationsSearchPostTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        Map<String, Object> params = new Map<String, Object>{
            'iedisonUtilizationSearchRequest' => IEdisonUtilizationSearchRequest.getExample()
        };

        IEdisonClient client;
        IEdisonUtilizationApi api;
        IEdisonUtilizationSearchResponse response;
        IEdisonUtilizationSearchResponse expectedResponse;
        String js = '';

        client = new IEdisonClient();
        api = new IEdisonUtilizationApi(client);

        js = JSON.serialize(IEdisonUtilizationSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationSearchResponse.getExample();
        response = (IEdisonUtilizationSearchResponse) api.utilizationsSearchPost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonUtilizationSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationSearchResponse.getExample();
        response = (IEdisonUtilizationSearchResponse) api.utilizationsSearchPost(params);
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonUtilizationApi(client);

        js = JSON.serialize(IEdisonUtilizationSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationSearchResponse.getExample();
        response = (IEdisonUtilizationSearchResponse) api.utilizationsSearchPost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonUtilizationSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationSearchResponse.getExample();
        response = (IEdisonUtilizationSearchResponse) api.utilizationsSearchPost(params);
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonUtilizationApi(client);

        js = JSON.serialize(IEdisonUtilizationSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationSearchResponse.getExample();
        response = (IEdisonUtilizationSearchResponse) api.utilizationsSearchPost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonUtilizationSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationSearchResponse.getExample();
        response = (IEdisonUtilizationSearchResponse) api.utilizationsSearchPost(params);
        System.assertEquals(expectedResponse, response);
    }

    /**
     * 
     *
     * Update an utilization report.
     */
    @isTest
    private static void utilizationsUpdatePostTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        Map<String, Object> params = new Map<String, Object>{
            'iedisonUtilizationRequest' => IEdisonUtilizationRequest.getExample()
        };

        IEdisonClient client;
        IEdisonUtilizationApi api;
        IEdisonUtilizationResponse response;
        IEdisonUtilizationResponse expectedResponse;
        String js = '';

        client = new IEdisonClient();
        api = new IEdisonUtilizationApi(client);

        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsUpdatePost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsUpdatePost(params);
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonUtilizationApi(client);

        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsUpdatePost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsUpdatePost(params);
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonUtilizationApi(client);

        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsUpdatePost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonUtilizationResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonUtilizationResponse.getExample();
        response = (IEdisonUtilizationResponse) api.utilizationsUpdatePost(params);
        System.assertEquals(expectedResponse, response);
    }
}