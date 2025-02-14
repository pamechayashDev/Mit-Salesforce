@RestResource(urlMapping = '/api/cases/v1/*')
global class CaseVisibilityCasesApi {
    public class NoAccountFoundException extends Exception {}
    @HttpGET
    global static void getCases() {
        RestResponse res = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');
        try {


            RestRequest req = RestContext.request;

            Integer page = 1;
            Integer pageSize = 200;
            String search = null;
            String filters = null;

            if (req.params != null) {
                search = req.params.get('nameSearch');
                filters = req.params.get('filters');

                String paramPage = req.params.get('page');
                String paramSize = req.params.get('pageSize');

                if (!String.isBlank(paramPage) && !String.isBlank(paramSize)) {
                    page = Integer.valueOf(paramPage);
                    pageSize = Integer.valueOf(paramSize);
                }
            }
            String mitId = getContextMitId();
            CaseVisibilityDto.CaseListResponse casesResponse = CaseVisibilityDao.getCasesByMitId(mitId, search, filters ,pageSize, page);
            String responseBody = JSON.serialize(casesResponse, true);

            RestContext.response.StatusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(responseBody);
        } catch(exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(ex.getMessage(), 'Failed to Call the service:')));
            HandleLogException.logException(ex);
        }
    }

    public static String getContextMitId() {
        RestRequest req = RestContext.request;
        String mitId = null;
        if (req.params != null) {
             String paramMitId = req.params.get('mitId');
             if (!String.isBlank(paramMitId)) {
                mitId = paramMitId;
             }
        }
        // Default, return logged in users mitId
        if (String.isBlank(mitId)) {
            String accountId = AccountUtils.getAccountIdFromCurrentUser();
            List<Account> currentUsers = [
                            SELECT
                                Id,
                                MitId__pc
                            FROM Account
                            WHERE Id = :accountId
                            LIMIT 1
                        ];
            if(currentUsers.isEmpty()) {
                throw new NoAccountFoundException('Account not found for logged in user ');
            }
            Account currentUser = currentUsers[0];
            mitId = currentUser.MitId__pc;
        }
        System.debug(mitId);
        return mitId;

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