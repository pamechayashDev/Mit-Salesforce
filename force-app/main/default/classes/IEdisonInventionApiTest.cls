@isTest
private class IEdisonInventionApiTest {
    /**
     * 
     *
     * Search for inventions.
     */
    @isTest
    private static void inventionsSearchPostTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        Map<String, Object> params = new Map<String, Object>{
            'iedisonInventionSearchRequest' => IEdisonInventionSearchRequest.getExample()
        };

        IEdisonClient client;
        IEdisonInventionApi api;
        IEdisonInventionSearchResponse response;
        IEdisonInventionSearchResponse expectedResponse;
        String js = '';

        client = new IEdisonClient();
        api = new IEdisonInventionApi(client);

        js = JSON.serialize(IEdisonInventionSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonInventionSearchResponse.getExample();
        response = (IEdisonInventionSearchResponse) api.inventionsSearchPost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonInventionSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonInventionSearchResponse.getExample();
        response = (IEdisonInventionSearchResponse) api.inventionsSearchPost(params);
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonInventionApi(client);

        js = JSON.serialize(IEdisonInventionSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonInventionSearchResponse.getExample();
        response = (IEdisonInventionSearchResponse) api.inventionsSearchPost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonInventionSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonInventionSearchResponse.getExample();
        response = (IEdisonInventionSearchResponse) api.inventionsSearchPost(params);
        System.assertEquals(expectedResponse, response);
        client = new IEdisonClient();
        api = new IEdisonInventionApi(client);

        js = JSON.serialize(IEdisonInventionSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonInventionSearchResponse.getExample();
        response = (IEdisonInventionSearchResponse) api.inventionsSearchPost(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(IEdisonInventionSearchResponse.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = IEdisonInventionSearchResponse.getExample();
        response = (IEdisonInventionSearchResponse) api.inventionsSearchPost(params);
        System.assertEquals(expectedResponse, response);
    }
}