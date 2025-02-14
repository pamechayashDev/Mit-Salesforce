@RestResource(urlMapping = '/api/cases/detail/inventors/v1/*')
global class CaseVisibilityInventorsApi {
    public class NoAccountFoundException extends Exception {}

    @HttpGET
    global static void getCaseInventorsByCaseNumber() {
        RestResponse res = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');
        try {
            String caseNumber = RestContext.request.params.get('caseNumber');

            CaseVisibilityDto.InventorsListResponse inventorsResponse = CaseVisibilityDao.getCaseInventorsByCaseNumber(caseNumber);
            String responseBody = JSON.serialize(inventorsResponse, true);

            RestContext.response.StatusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(responseBody);
        } catch(exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new CaseVisibilityCasesApi.ResponseWrapper(ex.getMessage(), 'Failed to Call the service:')));
            HandleLogException.logException(ex);
        }
    }
}