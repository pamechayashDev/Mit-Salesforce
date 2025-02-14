@RestResource(urlMapping = '/api/cases/detail/patents/v1/*')
global class CaseVisibilityPatentsApi {
    public class NoAccountFoundException extends Exception {}
    @HttpGET
    global static void getCasePatentsByCaseNumber() {
        RestResponse res = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');
        try {
            RestRequest req = RestContext.request;

            String caseNumber = RestContext.request.params.get('caseNumber');
            System.debug('caseNumber= '+ caseNumber);

            String mitId = CaseVisibilityCasesApi.getContextMitId();
            CaseVisibilityDto.PatentsListResponse patentsResponse = CaseVisibilityDao.getCasePatentsByCaseNumber(mitId, caseNumber);
            String responseBody = JSON.serialize(patentsResponse, true);

            RestContext.response.StatusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(responseBody);
        } catch(exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new CaseVisibilityCasesApi.ResponseWrapper(ex.getMessage(), 'Failed to Call the service:')));
            HandleLogException.logException(ex);
        }
    }

	
}