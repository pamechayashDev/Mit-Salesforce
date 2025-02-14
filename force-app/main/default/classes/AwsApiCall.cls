public with sharing class AwsApiCall {
    @AuraEnabled(cacheable=true)
    public static string restGet(string api, string resource){
        System.debug('Resource: ' + resource);
        try {
            string apiBase = getApiBase(api);
            string apiPath = getApiPath(api);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:' + apiBase + '/' + apiPath + resource);
            req.setMethod('GET');
            req.setTimeout(30000);
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('response body');
            System.debug(res.getBody());
            return res.getBody();
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Blob restGetBodyAsBlob(string api, string resource) {

        try {
            string apiBase = getApiBase(api);
            string apiPath = getApiPath(api);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:' + apiBase + '/' + apiPath + resource);
            req.setMethod('GET');
            req.setTimeout(30000);
            Http http = new Http();
            HttpResponse res = http.send(req);

            List<Integer> validSuccessStatuses = new List<Integer> {200, 201};
            System.debug('res.getStatusCode():- ' + res.getStatusCode());
            if (!validSuccessStatuses.contains(res.getStatusCode())) {
                String msg = 'Callout failed';
                if(!String.isBlank(res.getBody())) {
                    System.debug(LoggingLevel.ERROR, 'Call failed, status code:- ' + res.getBody());
                    Map<String, Object> jsonVal = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    msg = String.valueOf(jsonVal.get('message'));
                }
                throw new CalloutException('Something went wrong. If this problem persists please contact your administrator, ' + msg + ' (' + res.getStatusCode() + ')');
            }
            Blob bodyAsBlob = res.getBodyAsBlob();
            return bodyAsBlob;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new CalloutException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String restGetWithHeaders(string api,string resource, Map<string, string> headers, List<Integer> validSuccessStatuses) {
        try {
            string apiBase = getApiBase(api);
            string apiPath = getApiPath(api);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:' + apiBase + '/' + apiPath + resource);
            req.setMethod('GET');
            req.setTimeout(30000);

            // Set Headers
            if(headers != Null){
                for (string key : headers.keySet()) {
                    string value = headers.get(key);
                    req.setHeader(key, value);
                }
            }
            // Get response
            HttpResponse res = http.send(req);
            System.debug(res);

            Boolean validStatusesNullOrEmpty = validSuccessStatuses == null || validSuccessStatuses.isEmpty();
            if (!validStatusesNullOrEmpty && !validSuccessStatuses.contains(res.getStatusCode())) {
                Map<String, Object> jsonVal = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                throw new CalloutException('Something went wrong. If this problem persists please contact your administrator and share the code' + ' (' + res.getStatusCode() + ').:' + jsonVal.get('message'));
            }
			System.debug(res.getBody());
            return res.getBody();
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new CalloutException(e.getMessage());
        }
    }

    //TODO this needs to be the same as the one belwo for restPostGetBodyAsBlob
    @AuraEnabled(cacheable=true)
    public static string getImageContent(string api, string resource){
        try {
            string apiBase = getApiBase(api);
            string apiPath = getApiPath(api);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:' + apiBase + '/' + apiPath + resource);
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res = http.send(req);

            return res.getBody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String restPost(string api, string resource, Map<string, string> headers,string body) {
        List<Integer> validSuccessStatuses = null;
        return restCallout(api, 'POST' ,resource, headers, body, validSuccessStatuses);
    }

    @AuraEnabled
    public static String restPostSuccess(string api, string resource, Map<string, string> headers,string body, List<Integer> validSuccessStatuses) {
        return restCallout(api, 'POST' ,resource, headers, body, validSuccessStatuses);
    }

    @AuraEnabled
    public static String restPatch(string api, string resource, Map<string, string> headers,string body) {
        List<Integer> validSuccessStatuses = null;
        return restCallout(api, 'PATCH' ,resource, headers, body, validSuccessStatuses);
    }

    @AuraEnabled
    public static String restPut(string api, string resource, Map<string, string> headers,string body) {
        List<Integer> validSuccessStatuses = null;
        return restCallout(api, 'PUT' ,resource, headers, body, validSuccessStatuses);
    }

    @AuraEnabled
    public static String restCallout(string api, string method ,string resource, Map<string, string> headers,string body, List<Integer> validSuccessStatuses) {
        System.debug('resource: ' + resource);
        System.debug('headers: ' + headers);
        System.debug('body: ' + body);
        try {
            string apiBase = getApiBase(api);
            string apiPath = getApiPath(api);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:' + apiBase + '/' + apiPath + resource);
            req.setMethod(method);
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

            Boolean validStatusesNullOrEmpty = validSuccessStatuses == null || validSuccessStatuses.isEmpty();
            if (!validStatusesNullOrEmpty && !validSuccessStatuses.contains(res.getStatusCode())) {
                try {
                    Map<String, Object> jsonVal = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    throw new CalloutException('Something went wrong. If this problem persists please contact your administrator and share the code' + ' (' + res.getStatusCode() + ').:' + jsonVal.get('message'));
                } catch (Exception e) {
                    throw new CalloutException('Something went wrong. If this problem persists please contact your administrator and share the code' + ' (' + res.getStatusCode() + ').:'  + res.getBody());
                }
            }

            return res.getBody();
        } catch (Exception e) {
            throw new CalloutException(e.getMessage());
        }
    }

    public static Blob restPostGetBodyAsBlob(string api, string resource, Map<string, string> headers,string body) {
        System.debug('resource: ' + resource);
        System.debug('headers: ' + headers);
        System.debug('body: ' + body);
        try {
            string apiBase = getApiBase(api);
            string apiPath = getApiPath(api);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:' + apiBase + '/' + apiPath + resource);
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
            System.debug('AwsApiCall restPostGetBodyAsBlob res' + res);

            if (res.getStatusCode() != 200) {
                System.debug('AwsApiCall restPostGetBodyAsBlob res.getStatusCode() error: ' + res.getStatusCode());
                System.debug('AwsApiCall restPostGetBodyAsBlob res' + res);
                throw new CalloutException('Response not success:- ' + res.getStatusCode()  + ':' + res.getStatus());
            }
            return res.getBodyAsBlob();
        } catch (Exception e) {  // https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_exception_methods.htm
            System.debug('AwsApiCall restPostGetBodyAsBlob error');
            throw new CalloutException(e.getMessage());

            // https://salesforce.stackexchange.com/questions/49823/test-a-catch-block-for-callout-exception
        }
    }

    /**
    * Returns the api base
    * @param apiName The name as in the ApiConfigurations table
    */
    @AuraEnabled
    public static string getApiBase(String apiName){
        try {
            return ApiConfigurationBuilder.getApiBaseToString(apiName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * Returns the api path
    * @param apiName The name as in the ApiConfigurations table
    */
    @AuraEnabled
    public static string getApiPath(String apiName){
        try {
            return ApiConfigurationBuilder.getApiPathToString(apiName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
  
}