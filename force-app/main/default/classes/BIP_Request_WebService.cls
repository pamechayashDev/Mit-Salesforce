@RestResource(urlMapping='/getBIPRequests')
global without sharing class BIP_Request_WebService {

    global class ResponseWrapper {
        public String status;
        public String error;
        public Integer totalItems;
        public Integer totalPages;
        public Integer currentPage;
        public List<BIPRequest> bipRequests=new List<BIPRequest>();
        public List<BIPRequestList> bipRequestList=new List<BIPRequestList>();
    }

    @HttpPost
    global static ResponseWrapper handleRequest() {
        ResponseWrapper response = new ResponseWrapper();
        try {
            Map<String, Object> payload = parseRequest();
            String vType = (String) payload.get('Type');
            validateParameter(vType, 'Type');

            switch on vType {
                when 'BIPList' {
                    return queryData(payload);
                }
                when 'BIPApprove' {
                    return handleBIPApprove(payload);
                }when 'BIPDetails' {
                    return handleBIPDetails(payload);
                }
                when else {
                    return setErrorResponse(response, 'Invalid Type specified.');
                }
            }
        } catch (Exception e) {
            System.debug('Error processing request: ' + e.getMessage());
            return setErrorResponse(response, e.getMessage());
        }
    }

    private static ResponseWrapper queryData(Map<String, Object> payload) {
        String mitId = (String) payload.get('MITID');
        validateParameter(mitId, 'MITID');
        
        ResponseWrapper response = new ResponseWrapper();
        String vType = (String) payload.get('Type');

        String queryString;
        queryString = ' SELECT BIP_Request__c, Id, ' +
                      '   BIP_Request__r.Status__c, BIP_Request__r.Proposal_Number__c, BIP_Request__r.Project_Title__c, BIP_Request__r.Name, ' +
                      '   BIP_Request__r.Primary_PI_Lookup__r.Name, BIP_Request__r.Primary_PI_Lookup__r.MitId__pc, ' +
                      '   BIP_Request__r.Due_Date__c, BIP_Request__r.Is_Due_Date_Approaching__c' +
                      ' FROM BIP_PI__c' +
                      ' WHERE PI_MIT_ID__c = :mitId ' +
                      ' AND BIP_Request__r.Status__c not in (\'Request Received\', \'Assigned to TLO\') '; //PI's only see BIP are moving into/past 'Assigned to PI'
        
        //Add Filters
        String status = (String) payload.get('Status');
        if (status != null && !status.endsWithIgnoreCase('ALL')) {
            if (status.toLowerCase() == 'open') {
                status = 'Assigned to PI';
            } else if (status.toLowerCase() == 'responded') {
                status = 'PI Review Complete';
            } else if (status.toLowerCase() == 'completed') {
                status = 'Complete';
            }
            queryString += ' AND BIP_Request__r.Status__c = :status ';
        }

        String searchString = (String) payload.get('SearchString');
        if (searchString != null) {
            searchString = '%' + searchString + '%';

            String additionalConditions = ' OR BIP_Request__r.Proposal_Number__c LIKE :searchString';
            additionalConditions += ' OR BIP_Request__r.Project_Title__c LIKE :searchString';
            additionalConditions += ' OR BIP_Request__r.Name  LIKE :searchString';

            queryString += ' AND (' + additionalConditions.substring(4) + ')'; // remove the first " OR " and wrap with parentheses
        }
        
        System.debug(queryString);

        List<BIP_PI__c> vBipPiList = Database.query(queryString);

        // Get page number from payload, default to 1 if not specified or null
        Integer page = (payload.get('page') != null) ? (Integer) payload.get('page') : 1;

        // Get page size from payload, default to 10 if not specified or null
        Integer pageSize = (payload.get('pageSize') != null) ? (Integer) payload.get('pageSize') : 10;

        // Set total items from the size of your list
        response.totalItems = vBipPiList.size();

        // Calculate the total number of pages needed
        response.totalPages = (Integer)Math.ceil((Decimal)response.totalItems / pageSize);

        // Set the current page, ensure it does not exceed total pages
        response.currentPage = Math.min(page, response.totalPages);
        if(response.currentPage < page) {
            response.status = 'Error';
            response.error = 'Current page is greater than total pages';
            return response;
        }

        // Calculate starting index for the current page
        Integer startIndex = (response.currentPage - 1) * pageSize;
        // Calculate the end index for the current page
        Integer endIndex = Math.min(startIndex + pageSize - 1, response.totalItems - 1);

        // Loop through the subset of list that corresponds to the current page
        for (Integer i = startIndex; i <= endIndex; i++) {           
            response.bipRequestList.add(new BIPRequestList(vBipPiList[i]));            
        }
        // Set the response status
        response.status = 'Success';
        return response;
    }

    private static ResponseWrapper handleBIPDetails(Map<String, Object> payload) {
        String mitId = (String) payload.get('MITID');
        String bipId = (String) payload.get('BIPID');
        validateParameter(mitId, 'MITID');  // TODO we should be checking that this mitId is listed as a PI on the BIP Request (bipId)
        validateParameter(bipId, 'BIPID');
        
        ResponseWrapper response = new ResponseWrapper();
        
        BIP_Request__c vBipRequestDetails = [SELECT Id, Name, Status__c, Project_Title__c, Decision__c, 
                                Due_Date__c, Is_Due_Date_Approaching__c, Proposal_Number__c, 
                                Primary_PI_Lookup__r.Name, Primary_PI_Lookup__r.MitId__pc, 
                                TLO_Officer_Name__c, TLO_Officer_Email__c, TLO_Officer_MIT_ID__c,
                                Comments__c, Lead_Unit_ID__c, Lead_Unit_Nam__c, Proposal_Start_Date__c, Proposal_End_Date__c, 
                                Sponsor_Type__c, Proposal_Activity_Type__c, Proposal_Deadline_Date__c, 
                                    (SELECT BIP_Request__c, Id, Name, PI__c, PI__r.MitId__pc, PI__r.Name, PI_MIT_ID__c, 
                                        Role__c, Status__c, TLO_Officer_Email__c, TLO_Officer_MIT_ID__c, TLO_Officer_Name__c 
                                     FROM BIP_Pis__r
                                    ) 
                                FROM BIP_Request__c
                                WHERE Name = :bipId ];    
        
        response.bipRequests.add(new BIPRequest(vBipRequestDetails));
        
        // Set the response status
        response.status = 'Success';
        return response;
    }

    private static ResponseWrapper handleBIPApprove(Map<String, Object> payload) {
        String bipRequestId = (String) payload.get('BIPRequestId');
        String approved = (String) payload.get('Approved');
        validateParameter(bipRequestId, 'BIPRequestId');
        validateParameter(approved, 'Approved');
        BIP_Request__c requestToUpdate = [SELECT Id, Approved__c FROM BIP_Request__c WHERE Name = :bipRequestId LIMIT 1];
        if (approved.toLowerCase() == 'yes') {
            requestToUpdate.Approved__c = true;
        } else {
            requestToUpdate.Approved__c = false;
        }
        if (requestToUpdate != null) {
            update requestToUpdate;
        }
        ResponseWrapper response = new ResponseWrapper();
        response.status = 'Success';
        return response;
    }

    private static ResponseWrapper setErrorResponse(ResponseWrapper response, String errorMessage) {
        response.status = 'Error';
        response.error = errorMessage;
        return response;
    }


    global class BIPRequest {
        public String bipId;
        public String status;
        public String title;
        public String decision;
        public Date dueDate;
        public Boolean isDueDateApproaching;
        public String proposalNumber;
        public String primaryPIName;
        public String primaryPIMitId;
        public String tloOfficerName;
        public String tloOfficerEmail;
        public String tloOfficerMITId;
        public String comments;
        public String leadUnitId;
        public String leadUnitName;
        public Date proposalStartDate;
        public Date proposalEndDate;
        public Date deadlineDate;
        public String sponsorType;
        public String activityType;
        public List<AdditionalPIInfo> additionalPIs;
    
        public BIPRequest(BIP_Request__c vBipRequest) {
            this.bipId = vBipRequest.Name;
            this.status = vBipRequest.Status__c;
            this.title = vBipRequest.Project_Title__c;
            this.decision = vBipRequest.Decision__c;
            this.dueDate = vBipRequest.Due_Date__c;
            this.isDueDateApproaching = vBipRequest.Is_Due_Date_Approaching__c;
            this.proposalNumber = vBipRequest.Proposal_Number__c;
            this.primaryPIName = vBipRequest.Primary_PI_Lookup__r.Name;
            this.primaryPIMitId = vBipRequest.Primary_PI_Lookup__r.MitId__pc;
            this.tloOfficerName = vBipRequest.TLO_Officer_Name__c;
            this.tloOfficerEmail = vBipRequest.TLO_Officer_Email__c;
            this.tloOfficerMITId = vBipRequest.TLO_Officer_MIT_ID__c;
            this.comments = vBipRequest.Comments__c;
            this.leadUnitId = vBipRequest.Lead_Unit_ID__c;
            this.leadUnitName = vBipRequest.Lead_Unit_Nam__c;
            this.proposalStartDate = vBipRequest.Proposal_Start_Date__c;
            this.proposalStartDate = vBipRequest.Proposal_Start_Date__c;
            this.proposalEndDate = vBipRequest.Proposal_End_Date__c;
            this.deadlineDate = vBipRequest.Proposal_Deadline_Date__c;
            this.sponsorType = vBipRequest.Sponsor_Type__c;
            this.activityType = vBipRequest.Proposal_Activity_Type__c;
            this.additionalPIs = new List<AdditionalPIInfo>();
            if(vBipRequest.BIP_Pis__r != null) {
                for (BIP_PI__c vBIPPI : vBipRequest.BIP_Pis__r) {
                    AdditionalPIInfo piInfo = new AdditionalPIInfo();
                    piInfo.piId = vBIPPI.Id;
                    piInfo.piName = vBIPPI.PI__r.Name;
                    piInfo.piMitId = vBIPPI.PI__r.MitId__pc;
                    piInfo.tloOfficerName=vBIPPI.TLO_Officer_Name__c;
                    piInfo.tloOfficerMIDID=vBIPPI.TLO_Officer_MIT_ID__c;
                    piInfo.tloOfficerEmail=vBIPPI.TLO_Officer_Email__c;
                    piInfo.role=vBIPPI.Role__c;
                    piInfo.status=vBIPPI.Status__c;
                    additionalPIs.add(piInfo);
                }
            }
        }
    }
    global class BIPRequestList {
        public String bipId;
        public String status;
        public String title;
        public Date dueDate;
        public Boolean isDueDateApproaching;
        public String proposalNumber;
        public String primaryPIName;
        public String primaryPIMitId;

        public BIPRequestList(BIP_PI__c vBipRequest) {
            this.bipId = vBipRequest.BIP_Request__r.Name;
            this.status = vBipRequest.BIP_Request__r.Status__c;
            this.title = vBipRequest.BIP_Request__r.Project_Title__c;
            this.dueDate = vBipRequest.BIP_Request__r.Due_Date__c;
            this.isDueDateApproaching = vBipRequest.BIP_Request__r.Is_Due_Date_Approaching__c;
            this.proposalNumber = vBipRequest.BIP_Request__r.Proposal_Number__c;
            this.primaryPIName = vBipRequest.BIP_Request__r.Primary_PI_Lookup__r.Name;
            this.primaryPIMitId = vBipRequest.BIP_Request__r.Primary_PI_Lookup__r.MitId__pc;
        }
    }
    public class AdditionalPIInfo {
        public String piId;
        public String piName;
        public String piMitId;
        public String tloOfficerName;
        public String tloOfficerMIDID;
        public String tloOfficerEmail;
        public String role;
        public String status;
    }
    
    private static Map<String, Object> parseRequest() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        return (Map<String, Object>) JSON.deserializeUntyped(requestBody);
    }

    private static void validateParameter(String param, String paramName) {
        if (String.isEmpty(param)) {
            throw new IllegalArgumentException(paramName + ' cannot be null or empty.');
        }
    }
    
}