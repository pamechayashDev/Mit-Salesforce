@RestResource(urlMapping = '/api/organizations/v1/*')
global class GetOrganizationDataRestServices {
    
    @HttpGET
    global static void getOrganizationData() {
        RestResponse res = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');
        try {
            RestRequest req = RestContext.request;
            String orgId = '';
            String page = '';
            String nameSearch = '';
            String pageSize = '';
            String apiPath = ApiConfigurationBuilder.getApiPathToString('forresterApi');
            String resource = apiPath + '/organizations';
            if(req.params != null && !req.params.isEmpty()) {
                nameSearch = req.params.get('nameSearch');
                nameSearch = EncodingUtil.urlEncode(nameSearch, 'UTF-8');
                if(String.isNotEmpty(nameSearch)) {
                    resource += '?nameSearch='+nameSearch;
                }
                
                page = req.params.get('page');
                if(String.isNotEmpty(page)) {
                    if(resource.contains('?')) {
                        resource += '&page='+page;
                    }
                    else {
                        resource += '?page='+page;
                    }
                }
                
                pageSize = req.params.get('pageSize');
                if(String.isNotEmpty(pageSize)) {
                    if(resource.contains('?')) {
                        resource += '&pageSize='+pageSize;
                    }
                    else {
                        resource += '?pageSize='+pageSize;
                    }
                }
            }
            HttpRequest request = new HttpRequest();
            String apiBase = ApiConfigurationBuilder.getApiBaseToString('forresterApi');
            request.setEndpoint('callout:' + apiBase + '/' + resource);
            request.setMethod('GET');
            request.setTimeout(30000);
            request.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HttpResponse response = http.send(request);
            String responseBody = response.getBody();
            system.debug(responseBody);
            RestContext.response.StatusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(responseBody);
        } catch(exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(ex.getMessage(), 'Failed to Call the service:')));
            HandleLogException.logException(ex);
        }
    }
    
    global class ResponseWrapper {
        public String message;
        public Object body;
        global ResponseWrapper(String message, string body) {
            this.message = message;
            this.body = body;
        }
    }
	
}