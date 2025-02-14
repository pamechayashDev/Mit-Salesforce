public with sharing class IEdisonService {
    public static final String IEDISON_API = 'iedisonApi';
    public static final String FORRESTER_API = 'forresterApi';
    private Map<string, string> headers = new Map<String, String>();

    public IEdisonService() {
        headers.put('Content-Type', 'application/json;charset=UTF-8');
    }

    /**
     * Update Utilization Report Status
     * @param id The Id of the record to be updated
     * @param status The new Utilization Report Status
     */
    @AuraEnabled
    public static String updateUtilizationReportStatus(String id, String status ) {
        Utilization_Report__c current = [SELECT 
                Id, 
                Utilization_Report_Status__c,
                Error_Messages__c
            FROM Utilization_Report__c
            WHERE Id = :id LIMIT 1];

        try {
            current.Utilization_Report_Status__c = status;
            update current;
            return 'Success';
        } catch (exception ex) {
            current.Utilization_Report_Status__c = 'Error';
            IEdisonErrorResponse errorResponse = IEdisonService.FormulateError(ex);
            current.Error_Messages__c = JSON.serialize(errorResponse, true);
            update current;
            return 'Error';
        }
    }

    /**
     * Submit Utilization Report
     * @param id The Id of the record to be submitted
     */
    @AuraEnabled
    public static String submitUtilizationReport(String id) {
        IEdisonService iEdisonService = new IEdisonService();
        Utilization_Report__c current = [SELECT 
                Id, 
                Name,
                Invention_Docket_Number__c,
                Invention_Report_Number__c,
                Reporting_Year__c,
                Latest_Stage_of_Development__c,
                Utilization_Report_Status__c,
                Utilization_Report_Title__c,
                First_Commercial_Year_of_Sale__c,
                Total_Income__c,
                New_Us_Jobs__c,
                New_Us_Companies__c,
                Notes__c,
                Commercialization_Plan_Id__c,
                Is_US_Manufacturing_Required_1__c,
                Is_US_Manufacturing_Required_2__c,
                Is_US_Manufacturing_Required_3__c,
                Error_Messages__c
            FROM Utilization_Report__c
            WHERE Id = :id LIMIT 1];
        try {
            current.Utilization_Submitted_Date__c = Date.today();
            current.Utilization_Report_Status__c = 'In Progress';
            current.Error_Messages__c = '';
            IEdisonUtilizationSearchResponse existingReport = iEdisonService.searchUtilization(1, 0, current.Invention_Report_Number__c, '', new List<String>(), integer.valueof(current.Reporting_Year__c), '');
            Map<Integer, Object> response;
            if (existingReport.totalRecords > 0) {
                response = iEdisonService.updateUtilization(current.Id);
            } else {
                response = iEdisonService.createUtilization(current.Id);
            }

            if (response.get(400) != null) {
                current.Utilization_Report_Status__c = 'Error';
                current.Error_Messages__c = JSON.serialize(response.get(400), true);
                update current;
                return 'Error';
            } else {
                current.Utilization_Report_Status__c = 'Completed';
                iEdisonService.mapUtilizationToReport(current, (IEdisonUtilizationResponse)response.get(201));

                // Submission is Successful, generate the document
                insert generateUtilizationDocument(current);

                update current;
                return 'Success';
            }
        } catch (exception ex) {
            current.Utilization_Report_Status__c = 'Error';
            IEdisonErrorResponse errorResponse = FormulateError(ex);
            current.Error_Messages__c = JSON.serialize(errorResponse, true);
            update current;
            return 'Error';
        }
    }

    /**
     * Update Forrested data when details page loads
     * @param id The Id of the record to be submitted
     */
    @AuraEnabled
    public static String updateForresterDataReport(String id) {
        IEdisonService iEdisonService = new IEdisonService();
        
        Utilization_Report__c orig = [SELECT 
                Id, 
                Name, 
                Invention_Report_Number__c,
                Invention_Docket_Number__c,
                Reporting_Year__c,
                Latest_Stage_of_Development__c,
                Utilization_Report_Status__c,
                First_Commercial_Year_of_Sale__c,
                Total_Income__c,
                New_Us_Jobs__c,
                New_Us_Companies__c,
                Notes__c,
                Commercialization_Plan_Id__c,
                Is_US_Manufacturing_Required_1__c,
                Is_US_Manufacturing_Required_2__c,
                Is_US_Manufacturing_Required_3__c,
                Error_Messages__c,
                Forrester_Latest_Stage_of_Development__c,
                Forrester_First_Commercial_Year_of_Sale__c,
                Forrester_Summarized_Agreement_Income__c,
                Forrester_Royalties_on_Sales__c,
                Forrester_Other_Income_and_Equity__c,
                Case_RecId__c,
                Case_RecId_ExternalId__c,
                Exclusive_Licenses_Name__c,
                Non_Exclusive_Licenses_Name__c,
                Small_Business_Licenses_Name__c,
                Forrester_Exclusive_Optionee_Name__c,
                Forrester_Non_Exclusive_Optionee_Name__c,
                Forrester_Small_Business_Optionee_Name__c
            FROM Utilization_Report__c
            WHERE Id = :id LIMIT 1];

        Utilization_Report__c current = [SELECT 
                Id, 
                Name, 
                Invention_Report_Number__c,
                Invention_Docket_Number__c,
                Reporting_Year__c,
                Latest_Stage_of_Development__c,
                Utilization_Report_Status__c,
                First_Commercial_Year_of_Sale__c,
                Total_Income__c,
                New_Us_Jobs__c,
                New_Us_Companies__c,
                Notes__c,
                Commercialization_Plan_Id__c,
                Is_US_Manufacturing_Required_1__c,
                Is_US_Manufacturing_Required_2__c,
                Is_US_Manufacturing_Required_3__c,
                Error_Messages__c,
                Forrester_Latest_Stage_of_Development__c,
                Forrester_First_Commercial_Year_of_Sale__c,
                Forrester_Summarized_Agreement_Income__c,
                Forrester_Royalties_on_Sales__c,
                Forrester_Other_Income_and_Equity__c,
                Case_RecId__c,
                Case_RecId_ExternalId__c,
                Exclusive_Licenses_Name__c,
                Non_Exclusive_Licenses_Name__c,
                Small_Business_Licenses_Name__c,
                Forrester_Exclusive_Optionee_Name__c,
                Forrester_Non_Exclusive_Optionee_Name__c,
                Forrester_Small_Business_Optionee_Name__c
            FROM Utilization_Report__c
            WHERE Id = :id LIMIT 1];

        Utilization_Report_Config__c fyConfig = [
            SELECT
                Name,
                Fiscal_Year__c,
                Start_Date__c,
                End_Date__c,
                Agreement_Types__c
            FROM Utilization_Report_Config__c
            WHERE Fiscal_Year__c = :current.Reporting_Year__c
            ORDER BY Fiscal_Year__c DESC, LastModifiedDate DESC
            LIMIT 1];

        try {

            //Do not update data when Utilization report in progress of being submitted
            if (current.Utilization_Report_Status__c == 'In Progress') {
                return 'Success';
            }

            List<String> caseNumberList = new List<String>();
            caseNumberList.add(current.Invention_Docket_Number__c);
            ForresterDto.UtilizationListDto forresterUtilizationData = iEdisonService.getForresterUtilizationData(caseNumberList, Helpers.formatDate(fyConfig.Start_Date__c), Helpers.formatDate(fyConfig.End_Date__c), fyConfig.Agreement_Types__c);
            if (forresterUtilizationData == null) {
                throw new CalloutException(
                   'Error finding Forrester utilization data for case number ' + current.Invention_Docket_Number__c);
            }
            if (forresterUtilizationData.results == null) {
                throw new CalloutException(
                    'Error finding Forrester utilization data for case number ' + current.Invention_Docket_Number__c);
            }
            if (forresterUtilizationData.results.size() != 1) {
                throw new CalloutException(
                   'Error finding Forrester utilization data for case number ' + current.Invention_Docket_Number__c);
            }
            ForresterDto.UtilizationDto utilizationDto = forresterUtilizationData.results[0];
            if (utilizationDto.status == 'SUCCESS') {
                iEdisonService.mapForresterUtilizationToReport(current, utilizationDto);
                IEdisonServiceResponseToReport.mergeForresterLicenseeNameAndCounts(current, utilizationDto);

                current.Exclusive_Licenses_Name__c = '';
                current.Non_Exclusive_Licenses_Name__c = '';
                current.Small_Business_Licenses_Name__c = '';
                current.Forrester_Exclusive_Optionee_Name__c = '';
                current.Forrester_Non_Exclusive_Optionee_Name__c = '';
                current.Forrester_Small_Business_Optionee_Name__c = '';
                List<Utilization_Licensee__c> items = [
                    SELECT Id,
                    Licensee_Name__c,
                    Forrester_Licensee_Name__c,
                    Exclusive_Count__c,
                    Non_Exclusive_Count__c,
                    Small_Business__c
                    FROM Utilization_Licensee__c
                    WHERE Utilization_Report__c = :id
                ];
                for (Utilization_Licensee__c item : items) {
                    IEdisonServiceResponseToReport.putReportLicenseeNameAndCounts(item, current);
                    IEdisonServiceResponseToReport.putReportForresterLicenseeNameAndCounts(item, current);
                }

                if (
                    ((orig.Forrester_Latest_Stage_of_Development__c ?? '') != (current.Forrester_Latest_Stage_of_Development__c ?? '')) ||
                    ((orig.Forrester_First_Commercial_Year_of_Sale__c ?? '') != (current.Forrester_First_Commercial_Year_of_Sale__c ?? '')) ||
                    ((orig.Forrester_Summarized_Agreement_Income__c ?? 0) != (current.Forrester_Summarized_Agreement_Income__c ?? 0)) ||
                    ((orig.Forrester_Royalties_on_Sales__c ?? 0) != (current.Forrester_Royalties_on_Sales__c ?? 0)) ||
                    ((orig.Forrester_Other_Income_and_Equity__c  ?? 0) != (current.Forrester_Other_Income_and_Equity__c ?? 0)) ||
                    ((orig.Case_RecId__c ?? '') != (current.Case_RecId__c ?? '')) ||
                    ((orig.Case_RecId_ExternalId__c ?? '') != (current.Case_RecId_ExternalId__c ?? '')) ||
                    ((orig.Exclusive_Licenses_Name__c ?? '') != (current.Exclusive_Licenses_Name__c ?? '')) ||
                    ((orig.Non_Exclusive_Licenses_Name__c ?? '') != (current.Non_Exclusive_Licenses_Name__c ?? '')) ||
                    ((orig.Small_Business_Licenses_Name__c ?? '') != (current.Small_Business_Licenses_Name__c ?? '')) ||
                    ((orig.Forrester_Exclusive_Optionee_Name__c ?? '') != (current.Forrester_Exclusive_Optionee_Name__c ?? '')) ||
                    ((orig.Forrester_Non_Exclusive_Optionee_Name__c ?? '') != (current.Forrester_Non_Exclusive_Optionee_Name__c ?? '')) ||
                    ((orig.Forrester_Small_Business_Optionee_Name__c ?? '') != (current.Forrester_Small_Business_Optionee_Name__c ?? ''))) 
                {
                     update current;
                }
                return 'Success';
            } else {
                current.Utilization_Report_Status__c = 'Error';
                if (utilizationDto.responseCode == 400 ) {
                    current.Error_Messages__c = JSON.serialize(utilizationDto, true);
                }
                update current;
                return 'Error';
            }

        } catch (exception ex) {
            current.Utilization_Report_Status__c = 'Error';
            IEdisonErrorResponse errorResponse = FormulateError(ex);
            current.Error_Messages__c = JSON.serialize(errorResponse, true);
            update current;
            return 'Error';
        }
    }

    public static IEdisonErrorResponse FormulateError(Exception ex) {
        IEdisonErrorResponse errorResponse = new IEdisonErrorResponse();
        errorResponse.message = ex.getMessage();
        errorResponse.errors = new List<IEdisonError>();
        IEdisonError error = new IEdisonError();
        String message = ex.getMessage();
        System.debug('FormulateError:-' + ex.getTypeName());
        if (ex.getTypeName() == 'System.CalloutException' && message.contains('(') && message.contains(')') && message.contains(':')) {
            message = message.substringBefore(':');
        } else {
            message = 'Something went wrong. If this problem persists please contact your administrator.';
        }

        error.message = message;
        errorResponse.errors.add(error);
        return errorResponse;
    }

    public static ContentVersion generateUtilizationDocument(Utilization_Report__c utilizationReport) {

        Integer documentCount = [
            SELECT COUNT()
            FROM ContentDocumentLink WHERE  LinkedEntityId = :utilizationReport.Id
        ];
        documentCount++;
        String suffix = ' - v' + documentCount;
        String title = utilizationReport.Utilization_Report_Title__c ;
        title = title.removeEndIgnoreCase('-').trim();
        title = title + suffix + '.pdf';

        String base64Pdf = DocumentGenerationService.getUtilizationReportPdfFileAsBase64String(utilizationReport.Id);
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Compliance').getRecordTypeId();
        ContentVersion conVer = new ContentVersion();
        conVer.Title = title;
        conVer.ContentLocation = 'S';
        conVer.FirstPublishLocationId = utilizationReport.Id;
        conVer.PathOnClient = title;
        conVer.RecordTypeId = recordTypeId;
        conVer.Document_Classification__c = 'Original_Document';
        conVer.Entity_Sub_Type__c = 'Utilization_Report';
        conVer.VersionData = EncodingUtil.base64Decode(base64Pdf);
        return conVer;
    }

    public IEdisonInventionSearchResponse searchInvention(
        Integer r_limit,
        Integer offset,
        String inventionReportNumber,
        String  inventionDocketNumber,
        List<String> titleElectionStatus,
        String inventionTitle,
        String granteeOrganizationName
    ) {
        IEdisonInventionSearchRequest search = this.buildInventionSearch(r_limit, offset, inventionReportNumber, inventionDocketNumber, titleElectionStatus, inventionTitle, granteeOrganizationName);

        List<Integer> validSuccessStatuses = new List<Integer> {200};
    
        String body = JSON.serialize(search, true);
        body = body.replaceAll('"r_limit"', '"limit"');
        System.debug('search:- ' + body);

        String searchInvention = AwsApiCall.restPostSuccess(
            IEDISON_API,
            '/inventions/search',
            headers,
            body,
            validSuccessStatuses
        );
        System.debug('searchInvention: ' + searchInvention);

        IEdisonInventionSearchResponse response = (IEdisonInventionSearchResponse) System.JSON.deserialize(
            searchInvention.replaceAll('"limit"', '"r_limit"'),
            IEdisonInventionSearchResponse.class
        );

        System.debug('response:- ' + JSON.serialize(response, true));
        return response;
    }


    public Map<Integer, Object> createUtilization(
        Id reportId
    ) {
        Utilization_Report__c utilizationReport = [
                SELECT
                    Id,
                    Reporting_Year__c,
                    Invention_Docket_Number__c,
                    Invention_Report_Number__c,
                    Latest_Stage_of_Development__c,
                    First_Commercial_Year_of_Sale__c,
                    Total_Income__c,
                    New_Us_Jobs__c,
                    New_Us_Companies__c,
                    Notes__c,
                    Commercialization_Plan_Id__c,
                    Is_US_Manufacturing_Required_1__c,
                    Is_US_Manufacturing_Required_2__c,
                    Is_US_Manufacturing_Required_3__c,
                    Invention_Report_Date__c,
                    Forrester_First_Commercial_Year_of_Sale__c,
                    Forrester_Summarized_Agreement_Income__c
                FROM Utilization_Report__c
                WHERE Id = :reportId
                LIMIT 1
            ];
        IEdisonUtilizationRequest request = this.buildUtilizationRequest(
            utilizationReport
        );

        System.debug('request:- ' + JSON.serialize(request, true));
        List<Integer> validSuccessStatuses = new List<Integer> {201, 400};
        String createdUtilization = AwsApiCall.restPostSuccess(
            IEDISON_API,
            '/utilizations/create',
            headers,
            JSON.serialize(request, true),
            validSuccessStatuses
        );
        System.debug('createdUtilization: ' + createdUtilization);

        Map<Integer, Object> response = new Map<Integer, Object>();
        if (createdUtilization.contains('responseCode') && createdUtilization.contains('400')) {
            IEdisonErrorResponse errorResponse = (IEdisonErrorResponse) System.JSON.deserialize(
                createdUtilization,
                IEdisonErrorResponse.class
            );
            System.debug('errorResponse:- ' + JSON.serialize(errorResponse, true));
            response.put(400, errorResponse);
        } else {
            IEdisonUtilizationResponse utilResponse = (IEdisonUtilizationResponse) System.JSON.deserialize(
                createdUtilization,
                IEdisonUtilizationResponse.class
            );
            System.debug('utilResponse:- ' + JSON.serialize(utilResponse, true));
            response.put(201, utilResponse);
        }
        return response;
    }

    public Map<Integer, Object> updateUtilization(
        Id reportId
    ) {
        Utilization_Report__c utilizationReport = [
                SELECT
                    Id,
                    Reporting_Year__c,
                    Invention_Docket_Number__c,
                    Invention_Report_Number__c,
                    Latest_Stage_of_Development__c,
                    First_Commercial_Year_of_Sale__c,
                    Total_Income__c,
                    New_Us_Jobs__c,
                    New_Us_Companies__c,
                    Notes__c,
                    Commercialization_Plan_Id__c,
                    Is_US_Manufacturing_Required_1__c,
                    Is_US_Manufacturing_Required_2__c,
                    Is_US_Manufacturing_Required_3__c,
                    Invention_Report_Date__c,
                    Forrester_First_Commercial_Year_of_Sale__c,
                    Forrester_Summarized_Agreement_Income__c
                FROM Utilization_Report__c
                WHERE Id = :reportId
                LIMIT 1
            ];
        IEdisonUtilizationRequest request = this.buildUtilizationRequest(
            utilizationReport
        );

        System.debug('request:- ' + JSON.serialize(request, true));
        List<Integer> validSuccessStatuses = new List<Integer> {201, 400};
        String updatedUtilization = AwsApiCall.restPostSuccess(
            IEDISON_API,
            '/utilizations/update',
            headers,
            JSON.serialize(request, true),
            validSuccessStatuses
        );
        System.debug('updatedUtilization: ' + updatedUtilization);

        Map<Integer, Object> response = new Map<Integer, Object>();
        if (updatedUtilization.contains('responseCode') && updatedUtilization.contains('400')) {
            IEdisonErrorResponse errorResponse = (IEdisonErrorResponse) System.JSON.deserialize(
                updatedUtilization,
                IEdisonErrorResponse.class
            );
            System.debug('errorResponse:- ' + JSON.serialize(errorResponse, true));
            response.put(400, errorResponse);
        } else {
            IEdisonUtilizationResponse utilResponse = (IEdisonUtilizationResponse) System.JSON.deserialize(
                updatedUtilization,
                IEdisonUtilizationResponse.class
            );
            System.debug('utilResponse:- ' + JSON.serialize(utilResponse, true));
            response.put(201, utilResponse);
        }
        return response;
    }

    public IEdisonUtilizationSearchResponse searchUtilization(
        Integer r_limit,
        Integer offset,
        String inventionReportNumber,
        String  inventionDocketNumber,
        List<String> titleElectionStatus,
        Integer fiscalYear,
        String inventionTitle
    ) {
        IEdisonUtilizationSearchRequest search = this.buildUtilizationSearch(r_limit, offset, inventionReportNumber, inventionDocketNumber, titleElectionStatus, fiscalYear, inventionTitle);

        List<Integer> validSuccessStatuses = new List<Integer> {200};
        
        String body = JSON.serialize(search, true);
        body = body.replaceAll('"r_limit"', '"limit"');
        System.debug('search:- ' + body);

        String searchUtilization = AwsApiCall.restPostSuccess(
            IEDISON_API,
            '/utilizations/search',
            headers,
            body,
            validSuccessStatuses
        );
        System.debug('searchUtilization: ' + searchUtilization);

        IEdisonUtilizationSearchResponse response = (IEdisonUtilizationSearchResponse) System.JSON.deserialize(
            searchUtilization.replaceAll('"limit"', '"r_limit"'),
            IEdisonUtilizationSearchResponse.class
        );

        System.debug('response:- ' + JSON.serialize(response, true));
        return response;
    }

    @TestVisible
    private IEdisonUtilizationRequest buildUtilizationRequest(
        Utilization_Report__c utilizationReport
    ) {
        IEdisonUtilizationRequest request = new IEdisonUtilizationRequest();
        IEdisonServiceReportToRequest.mapReportToUtilizationRequest(utilizationReport, request);
        System.debug('request: ' + JSON.serialize(request, true));

        return request;
    }

    @TestVisible
    private IEdisonUtilizationSearchRequest buildUtilizationSearch(
        Integer r_limit,
        Integer offset,
        String inventionReportNumber,
        String  inventionDocketNumber,
        List<String> titleElectionStatus,
        Integer fiscalYear,
        String inventionTitle
    ) {
        IEdisonUtilizationSearchRequest request = new IEdisonUtilizationSearchRequest();
        request.r_limit = r_limit;
        request.offset = offset;
        request.inventionReportNumber = inventionReportNumber;
        request.inventionDocketNumber = inventionDocketNumber;
        request.titleElectionStatus = titleElectionStatus;
        request.fiscalYear = fiscalYear;
        request.inventionTitle = inventionTitle;

        System.debug('request: ' + JSON.serialize(request, true));

        return request;
    }

    @TestVisible
    private IEdisonInventionSearchRequest buildInventionSearch(
        Integer r_limit,
        Integer offset,
        String inventionReportNumber,
        String  inventionDocketNumber,
        List<String> titleElectionStatus,
        String inventionTitle,
        String granteeOrganizationName
    ) {

        IEdisonInventionSearchRequest request = new IEdisonInventionSearchRequest();

        IEdisonInventionSearchCriteria criteria = new IEdisonInventionSearchCriteria();
        criteria.r_limit = r_limit;
        criteria.offset = offset;
        criteria.inventionReportNumber = inventionReportNumber;
        criteria.inventionDocketNumber = inventionDocketNumber;
        criteria.titleElectionStatus = titleElectionStatus;
        criteria.inventionTitle = inventionTitle;
        criteria.granteeOrganizationName = granteeOrganizationName;
        
        request.inventionSearchCriteria = criteria;
        System.debug('request: ' + JSON.serialize(request, true));

        return request;
    }

    public ForresterDto.UtilizationListDto getForresterUtilizationData(
        List<String> caseNumbers,
        String fyStart,
        String fyEnd,
        String agreementTypes
    ) {
        String queryParamCaseNumbers = '';
        for (String caseNumber : caseNumbers) {
            if (queryParamCaseNumbers.length() == 0) {
                queryParamCaseNumbers = caseNumber.removeEndIgnoreCase('L'); // Lincoln Lab captured inventiondocket number with added 'L' in iEdison 
            } else {
                queryParamCaseNumbers = queryParamCaseNumbers + ',' + caseNumber.removeEndIgnoreCase('L');
            }
        }
        String queryParams = getQueryParams(queryParamCaseNumbers, fyStart, fyEnd, agreementTypes );
        String endpoints =  '/cases/compliance/utilization?' + queryParams;
        System.debug('Calling end point ' + endpoints );

        String response = AwsApiCall.restGet(FORRESTER_API, endpoints);
        if(response == null || response.length() == 0) {
            System.debug('Forrester Utilization data response is empty ');
            return null;
        } else {
            System.debug('Forrester Utilization data response ' + response );
        }
        ForresterDto.UtilizationListDto respObj = (ForresterDto.UtilizationListDto)JSON.deserialize(response, ForresterDto.UtilizationListDto.class);
        if(respObj.results == null || respObj.results.size() == 0) {
            System.debug('Forrester Utilization data response is empty ');
            return null;
        } else {
            if(respObj.results == null) {
                System.debug('Forrester Utilization results are empty ');
                return null;
            }
        }
        return respObj;
    }

    private String getQueryParams(String caseNumbers, String fyStart, String fyEnd, String agreementTypes) {
        return 'fyStart=' + fyStart + '&fyEnd=' + fyEnd + '&agreementTypes=' + agreementTypes.replace(';', ',') + '&caseNumbers=' + EncodingUtil.urlEncode(caseNumbers.replace(';', ','), 'UTF-8');
    }

    public String fundingToSeparatedString(List<IEdisonFundingAgreement> objects,  String fieldName) {
        List<String> values = new List<String>();
        if (fieldName == 'agency') {
            for(IEdisonFundingAgreement item : objects) {
                String fieldValue = item.agency.toString();
                values.add(fieldValue);
            }
        }
        if (fieldName == 'grantNumber') {
            for(IEdisonFundingAgreement item : objects) {
                String fieldValue = item.grantNumber.toString();
                values.add(fieldValue);
            }
        }
        return String.join(values,';');
    }

    

    public void mapInventionToReport(Utilization_Report__c report, IEdisonInventionResponse invention) {
        report.DOE_S_number__c = invention.doesNumber;
        report.Election_Status__c = invention.inventionStatus.titleElectionStatus;
        report.Funding_Agency__c = this.fundingToSeparatedString(invention.fundingAgreements, 'agency');
        report.Funding_Grant_Number__c = this.fundingToSeparatedString(invention.fundingAgreements, 'grantNumber');
        report.Grantee_Organization_Name__c = invention.granteeOrganizationName;
        report.Invention_Docket_Number__c = invention.inventionDocketNumber;
        if (String.isNotBlank(invention.inventionReportDate)) {
            report.Invention_Report_Date__c = IEdisonServiceResponseToReport.iEdisonStringToDate(invention.inventionReportDate);
            if (String.isNotBlank(report.First_Commercial_Year_of_Sale__c)) {
                if (Integer.valueOf(report.First_Commercial_Year_of_Sale__c) < report.Invention_Report_Date__c.year() - 5) {
                    report.First_Commercial_Year_of_Sale__c = String.valueOf(report.Invention_Report_Date__c.year() - 5);
                } 
            }
        }
        report.Invention_Report_Number__c = invention.inventionReportNumber;
        report.Invention_Title__c = invention.inventionTitle; 
        report.Primary_Agency__c = invention.primaryAgency; 
        if (String.isNotBlank(invention.inventionStatus.titleElectionDate)) {
            report.Title_Election_Date__c = IEdisonServiceResponseToReport.iEdisonStringToDate(invention.inventionStatus.titleElectionDate);
        }       
    }

    // This will populate field on container creation and when the details page is loaded
    public void mapForresterUtilizationToReport(Utilization_Report__c report, ForresterDto.UtilizationDto forresterUtilizationData) {
        report.Forrester_Latest_Stage_of_Development__c = forresterUtilizationData.latestStageDev;

        if (String.isNotBlank(forresterUtilizationData.firstCommercialSaleYear)) {
            report.Forrester_First_Commercial_Year_of_Sale__c = String.valueOf(forresterUtilizationData.firstCommercialSaleYear);
        } else  {
            report.Forrester_First_Commercial_Year_of_Sale__c = '';
        }

        report.Forrester_Summarized_Agreement_Income__c = forresterUtilizationData.totalIncome ?? 0.0; 
        report.Forrester_Royalties_on_Sales__c = forresterUtilizationData.royaltiesOnSales ?? 0.0;
        report.Forrester_Other_Income_and_Equity__c = forresterUtilizationData.otherIncomeAndEquity ?? 0.0;

        report.Case_RecId__c = forresterUtilizationData.caseRecid.toString();
        report.Case_RecId_ExternalId__c = forresterUtilizationData.caseRecid.toString() + '-' + report.Reporting_Year__c.toString();
    }

    public void mapInitialForresterUtilizationToReport(Utilization_Report__c report, ForresterDto.UtilizationDto forresterUtilizationData) {
        report.Latest_Stage_of_Development__c = forresterUtilizationData.latestStageDev;
        report.Total_Income__c = forresterUtilizationData.totalIncome ?? 0.0;

        if (String.isNotBlank(forresterUtilizationData.firstCommercialSaleYear)) {
            report.First_Commercial_Year_of_Sale__c = String.valueOf(forresterUtilizationData.firstCommercialSaleYear);
        } else  {
            report.First_Commercial_Year_of_Sale__c = '';
        }

        if (report.Invention_Report_Date__c != null) {
            if (String.isNotBlank(report.First_Commercial_Year_of_Sale__c)) {
                if (Integer.valueOf(report.First_Commercial_Year_of_Sale__c) < report.Invention_Report_Date__c.year() - 5) {
                    report.First_Commercial_Year_of_Sale__c = String.valueOf(report.Invention_Report_Date__c.year() - 5);
                } 
            }
        }
    }

    public void mapPreviousYearUtilizationToReport(Utilization_Report__c report, IEdisonUtilizationResponse previousYearUtilization) {
        // if (previousYearUtilization != null) {
        //     report.New_Us_Companies__c = previousYearUtilization.newUsCompanies;
        //     report.New_Us_Jobs__c = previousYearUtilization.newUsJobs;
        // }
    }

    public void mapUtilizationToReport(Utilization_Report__c report, IEdisonUtilizationResponse utilization) {
        if (utilization != null) {               
            if (String.isNotBlank(utilization.createdDate)) { 
                report.Utilization_Created_Date__c = IEdisonServiceResponseToReport.iEdisonStringToDate(utilization.createdDate);
            }
            if (String.isNotBlank(utilization.lastUpdatedDate)) {
                report.Utilization_Updated_Date__c = IEdisonServiceResponseToReport.iEdisonStringToDate(utilization.lastUpdatedDate);
            }

            report.First_Commercial_Year_of_Sale__c = String.valueOf(utilization.firstCommercialSaleYear);

            report.Total_Income__c = utilization.totalIncome ?? 0.0;
        }
    }

    public List<Utilization_Licensee__c> mapInitalLicenseeNameAndCounts(Utilization_Report__c report,  ForresterDto.UtilizationDto forresterUtilizationData) {
        List<Utilization_Licensee__c> insertList = new List<Utilization_Licensee__c>();
        if (forresterUtilizationData.licNamesAndCounts != null) {
            List<String> licNamesAndCounts = forresterUtilizationData.licNamesAndCounts.split(',');
            if (licNamesAndCounts.size() > 0) {
                Utilization_Licensee__c item;
                for (Integer i = 0; i < licNamesAndCounts.size(); i++) {
                    if (Math.mod(i, 4) == 0) {
                        item = new Utilization_Licensee__c();
                        item.Utilization_Report__c = report.Id;
                        item.Licensee_Name__c = licNamesAndCounts[i].replace('%2c', ',');
                        item.Forrester_Licensee_Name__c = licNamesAndCounts[i].replace('%2c', ',');
                    }
                    else if (Math.mod(i, 4) == 1) {
                        item.Exclusive_Count__c = Integer.valueOf(licNamesAndCounts[i]);
                    }
                    else if (Math.mod(i, 4) == 2) {
                        item.Non_Exclusive_Count__c = Integer.valueOf(licNamesAndCounts[i]);
                    }
                    else if (Math.mod(i, 4) == 3) {
                        item.Small_Business__c = Integer.valueOf(licNamesAndCounts[i]) > 0;
                        insertList.add(item);
                        IEdisonServiceResponseToReport.putReportLicenseeNameAndCounts(item, report);
                        IEdisonServiceResponseToReport.putReportForresterLicenseeNameAndCounts(item, report);
                    }
                }
                
            }
        }

        return insertList;
    }
}