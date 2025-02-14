//https://www.forcetalks.com/blog/salesforce-rest-api-http-and-callout-basics-all-you-need-to-know/
public with sharing class DocuSignApiCall {
    
    @AuraEnabled(cacheable=true)
    public static String restGet(String resource, Map<String, String> headers){
        System.debug('Resource: ' + resource);
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:DocuSign_API/' + resource);
            req.setMethod('GET');
            req.setTimeout(30000);
            // Set Headers
            for (string key : headers.keySet()) {
                string value = headers.get(key);
                req.setHeader(key, value);
            }
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('response body');
            System.debug(res.getBody());
            return res.getBody();
        } catch (Exception e) {
            throw new CalloutException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Blob restGetBodyAsBlob(String resource, Map<String, String> headers) {
        try {
            HttpResponse res = restCallout('GET' ,resource, headers);
            
            Blob bodyAsBlob = res.getBodyAsBlob();
            return bodyAsBlob;

        } catch (Exception e) {
            throw new CalloutException(e.getMessage());
        }
    }

    private static HttpResponse restCallout(String method ,string resource, Map<string, string> headers) {
        System.debug('resource: ' + resource);
        System.debug('headers: ' + headers);
        
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:DocuSign_API/' + resource);
            req.setMethod(method);
            req.setTimeout(30000);
           
            // Set Headers
            for (string key : headers.keySet()) {
                string value = headers.get(key);
                req.setHeader(key, value);
            }

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

    @AuraEnabled
    public static String restDelete(String resource, Map<String, String> headers){
        System.debug('Resource: ' + resource);
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:DocuSign_API/' + resource);
            req.setMethod('DELETE');
            req.setTimeout(30000);
            Http http = new Http();
            // Set Headers
            for (string key : headers.keySet()) {
                string value = headers.get(key);
                req.setHeader(key, value);
            }

            HttpResponse res = http.send(req);
            System.debug('response body');
            System.debug(res.getBody());
            return res.getBody();
        } catch (Exception e) {
            throw new CalloutException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string restPost(string resource, Map<string, string> headers,string body) {
        System.debug('resource: ' + resource);
        System.debug('headers: ' + headers);
        System.debug('body: ' + body);
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:DocuSign_API/' + resource);
            req.setMethod('POST');
            req.setTimeout(30000);
            req.setBody(body);
            // Set Headers
            for (string key : headers.keySet()) {
                string value = headers.get(key);
                req.setHeader(key, value);
            }

            System.debug(req);

            // Get response
            HttpResponse res = http.send(req);
            System.debug(res);

            List<Integer> validSuccessStatuses = new List<Integer> {200, 201};
            System.debug('res.getStatusCode():- ' + res.getStatusCode());
            if (!validSuccessStatuses.contains(res.getStatusCode())) {
                System.debug(LoggingLevel.ERROR, 'Call to DocuSign failed, status code:- ' + res.getBody());
                throwDocuSignError(res.getStatusCode(), res.getBody());
            }

            return res.getBody();
        } catch (Exception e) {
            throw new CalloutException(e.getMessage());
        }
    }
    private static void throwDocuSignError(Integer statusCode, String body) {
        DocuSignErrorResponse docuSignErrorResponse = (DocuSignErrorResponse) JSON.deserialize(body, DocuSignErrorResponse.class);
        String message =  docuSignErrorResponse != null ? docuSignErrorResponse.message: '';
        throw new CalloutException('Call to DocuSign failed, status code:- ' + statusCode + ' message:- ' + message);
    }

    @AuraEnabled
    public static string restPut(string resource, Map<string, string> headers,string body) {
        System.debug('resource: ' + resource);
        System.debug('headers: ' + headers);
        System.debug('body: ' + body);
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:DocuSign_API/' + resource);
            req.setMethod('PUT');
            req.setTimeout(30000);
            req.setBody(body);
            // Set Headers
            for (string key : headers.keySet()) {
                string value = headers.get(key);
                req.setHeader(key, value);
            }

            System.debug(req);

            // Get response
            HttpResponse res = http.send(req);
            System.debug(res);
            
            List<Integer> validSuccessStatuses = new List<Integer> {200, 201};
            System.debug('res.getStatusCode():- ' + res.getStatusCode());
            if (!validSuccessStatuses.contains(res.getStatusCode())) {
                System.debug(LoggingLevel.ERROR, 'Call to DocuSign failed, status code:- ' + res.getBody());
                throwDocuSignError(res.getStatusCode(), res.getBody());
            }

            return res.getBody();
        } catch (Exception e) {
            throw new CalloutException(e.getMessage());
        }
    }

     public class DocuSignErrorResponse {
        public String errorCode;
        public String message;
    }
}