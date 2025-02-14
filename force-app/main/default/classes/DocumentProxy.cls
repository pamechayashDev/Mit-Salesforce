@RestResource(urlMapping =  '/api/document-proxy/v1/*')
global with sharing class DocumentProxy {

    // https://sfdcblog.binaryrepublik.com/2019/06/generate-pdf-file-with-apex-trigger-in.html#.Y8blftJBwYs
    // 12 MB limit on Callout
    @HttpGet
    global static void getDocument() {
        
        String urlStr = RestContext.request.params.get('url');
        String endpoint = EncodingUtil.urlDecode(urlStr, 'UTF-8');

        HttpResponse httpRes = restCallout('GET', endpoint);


        RestContext.response.StatusCode = httpRes.getStatusCode();
        RestContext.response.responseBody = httpRes.getBodyAsBlob();
        RestContext.response.addHeader('Content-Type', httpRes.getHeader('Content-Type'));


    }


    private static HttpResponse restCallout(String method ,string endpoint) {
            System.debug('endpoint: ' + endpoint);

            try {
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod(method);
                req.setTimeout(30000);


                System.debug(req);

                // Get response
                HttpResponse res = http.send(req);
                System.debug(res);
                return res;
            } catch (Exception e) {
                System.debug(e.getMessage());
                HandleLogException.logException(e);
                throw new CalloutException(e.getMessage());
            }
        }
}