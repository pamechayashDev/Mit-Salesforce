public class IEdisonApiMock  implements HttpCalloutMock {
    
    
    public HTTPResponse respond(HTTPRequest req) {       
        // ====== Mock for POSTS's
        if (req.getMethod() == 'POST' 
                && req.getEndpoint().containsignorecase('utilizations')
                && req.getEndpoint().containsignorecase('error400')) { 
            String responseStr = '{"responseCode":400,"message":"Invalid form-data content","errors":[{"code":"400","field":"reportingYear","message":"Reporting Year (YYYY) * value is required."}]}';
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseStr);
            res.setStatusCode(400);
            
            return res;
        }
        if (req.getMethod() == 'POST' 
                && req.getEndpoint().containsignorecase('utilizations')
                && req.getEndpoint().containsignorecase('error401')) { 
            String responseStr = '{"message":"Access Denied","timestamp":"2022-06-10T09:58:10.534055700"}';
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseStr);
            res.setStatusCode(401);
            
            return res;
        }
        if (req.getMethod() == 'POST' 
                && req.getEndpoint().containsignorecase('utilizations')
                && req.getEndpoint().containsignorecase('create')) { 

            String responseStr = '{"inventionReportNumber":"0820102-15-0070","granteeOrganizationName":"STANFORD UNIVERSITY","inventionTitle":"Multiplexed in vivo DNA parsing and stitching","primaryAgency":"National Institutes of Health","inventionReportDate":"01/30/2022","titleElectDate":"01/30/2022","reportingYear":2023,"latestStageDev":"Commercialized","firstCommercialSaleYear":2023,"totalIncome":50000,"exclusiveLicensesOptions":2,"nonExclusiveLicensesOptions":2,"smallBusinessLicensesOptions":10,"totalGrossSales":0,"isUSManufacturingRequired1":"Y","isUSManufacturingRequired2":"N","isUSManufacturingRequired3":"Y","notes":"new utilization notes","exclusiveLicensees":["John Wick","Peter Griffin"],"nonExclusiveLicensees":["John Wick","James Doe"],"newUsJobs":100,"newUsCompanies":500,"manufacturingCommProds":[{"productName":"widgets","naicsCode":"ABC123","licensees":[{"licenseeName":"James Doe","manufacturers":[{"manufacturerName":"IBM","productLocation":[{"state":"MARYLAND","country":"UNITED STATES"}]}]},{"licenseeName":"John Wick","manufacturers":[{"manufacturerName":"Intel","productLocation":[{"state":"","country":"CHINA"},{"state":"MARYLAND","country":"UNITED STATES"}]},{"manufacturerName":"IBM","productLocation":[{"state":"FLORIDA","country":"UNITED STATES"}]}]}]},{"productName":"gadgets","licensees":[{"licenseeName":"John Wick","manufacturers":[{"manufacturerName":"Apple","productLocation":[{"state":"TEXAS","country":"UNITED STATES"}]}]},{"licenseeName":"STANFORD UNIVERSITY","manufacturers":[{"manufacturerName":"Google","productLocation":[{"state":"COLORADO","country":"UNITED STATES"}]}]}]}],"commercialProds":[{"commercialName":"nih prods","fdaApprovalNumber":"1234","publicInd":"Yes","govtReviewStatus":"Approved","fdaApprovalType":"Medical Device"}],"licensees":[{"id":9268,"licenseeName":"LicenseeA","exclusiveCount":87,"nonExclusiveCount":45,"smallBusiness":true},{"id":9269,"licenseeName":"LicenseeB","exclusiveCount":15,"nonExclusiveCount":0,"smallBusiness":false},{"id":9270,"licenseeName":"LicenseeD","exclusiveCount":15,"nonExclusiveCount":0,"smallBusiness":false},{"id":9271,"licenseeName":"LicenseeC","exclusiveCount":15,"nonExclusiveCount":0,"smallBusiness":false},{"id":9272,"licenseeName":"LicenseeE","exclusiveCount":0,"nonExclusiveCount":12,"smallBusiness":false}],"createdDate":"08/11/2023"}';
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseStr);
            res.setStatusCode(201);
            
            return res;
        }
        if (req.getMethod() == 'POST' 
                && req.getEndpoint().containsignorecase('utilizations')
                && req.getEndpoint().containsignorecase('update')) { 

            String responseStr = '{"inventionReportNumber":"0820102-15-0070","granteeOrganizationName":"STANFORD UNIVERSITY","inventionTitle":"Multiplexed in vivo DNA parsing and stitching","primaryAgency":"National Institutes of Health","inventionReportDate":"01/30/2022","titleElectDate":"01/30/2022","reportingYear":2023,"latestStageDev":"Commercialized","firstCommercialSaleYear":2023,"totalIncome":50000,"exclusiveLicensesOptions":2,"nonExclusiveLicensesOptions":2,"smallBusinessLicensesOptions":10,"totalGrossSales":0,"isUSManufacturingRequired1":"Y","isUSManufacturingRequired2":"N","isUSManufacturingRequired3":"Y","notes":"new utilization notes","exclusiveLicensees":["John Wick","Peter Griffin"],"nonExclusiveLicensees":["John Wick","James Doe"],"newUsJobs":100,"newUsCompanies":500,"manufacturingCommProds":[{"productName":"motherboards","naicsCode":"ABC123","licensees":[{"licenseeName":"James Doe","manufacturers":[{"manufacturerName":"IBM","productLocation":[{"state":"MARYLAND","country":"UNITED STATES"}]}]},{"licenseeName":"John Wick","manufacturers":[{"manufacturerName":"Intel","productLocation":[{"state":"","country":"CHINA"},{"state":"MARYLAND","country":"UNITED STATES"}]},{"manufacturerName":"IBM","productLocation":[{"state":"FLORIDA","country":"UNITED STATES"}]}]}]},{"productName":"gadgets","licensees":[{"licenseeName":"STANFORD UNIVERSITY","manufacturers":[{"manufacturerName":"Google","productLocation":[{"state":"COLORADO","country":"UNITED STATES"}]}]},{"licenseeName":"John Wick","manufacturers":[{"manufacturerName":"Apple","productLocation":[{"state":"TEXAS","country":"UNITED STATES"}]}]}]}],"commercialProds":[{"commercialName":"nih prods","fdaApprovalNumber":"431","publicInd":"Yes","govtReviewStatus":"Pending","fdaApprovalType":"Biologic"}],"licensees":[{"id":9268,"licenseeName":"LicenseeA","exclusiveCount":87,"nonExclusiveCount":45,"smallBusiness":true},{"id":9269,"licenseeName":"STANFORD UNIVERSITY","exclusiveCount":15,"nonExclusiveCount":0,"smallBusiness":false},{"id":9270,"licenseeName":"LicenseeD","exclusiveCount":15,"nonExclusiveCount":0,"smallBusiness":false},{"id":9271,"licenseeName":"LicenseeC","exclusiveCount":15,"nonExclusiveCount":0,"smallBusiness":false},{"id":9272,"licenseeName":"LicenseeE","exclusiveCount":0,"nonExclusiveCount":12,"smallBusiness":false}],"createdDate":"08/11/2023","lastUpdatedDate":"08/11/2023"}';
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseStr);
            res.setStatusCode(201);
            
            return res;
        }
        if (req.getMethod() == 'POST' 
                && req.getEndpoint().containsignorecase('utilizations')
                && req.getEndpoint().containsignorecase('search')) { 

            String responseStr = '{"utilizations":[{"inventionReportNumber":"0820102-15-0070","granteeOrganizationName":"STANFORD UNIVERSITY","inventionTitle":"Multiplexed in vivo DNA parsing and stitching","primaryAgency":"National Institutes of Health","inventionReportDate":"01/30/2022","titleElectDate":"01/30/2022","reportingYear":2023,"latestStageDev":"Commercialized","firstCommercialSaleYear":2023,"totalIncome":50000,"exclusiveLicensesOptions":2,"nonExclusiveLicensesOptions":2,"smallBusinessLicensesOptions":10,"totalGrossSales":0,"isUSManufacturingRequired1":"Y","isUSManufacturingRequired2":"N","isUSManufacturingRequired3":"Y","commercializationPlanId": 1,"notes":"new utilization notes","exclusiveLicensees":["John Wick","Peter Griffin"],"nonExclusiveLicensees":["James Doe","John Wick"],"newUsJobs":100,"newUsCompanies":500,"manufacturingCommProds":[{"productName":"gadgets","licensees":[{"licenseeName":"STANFORD UNIVERSITY","manufacturers":[{"manufacturerName":"Google","productLocation":[{"state":"COLORADO","country":"UNITED STATES"}]}]},{"licenseeName":"John Wick","manufacturers":[{"manufacturerName":"Apple","productLocation":[{"state":"TEXAS","country":"UNITED STATES"}]}]}]},{"productName":"motherboards","naicsCode":"ABC123","licensees":[{"licenseeName":"James Doe","manufacturers":[{"manufacturerName":"IBM","productLocation":[{"state":"MARYLAND","country":"UNITED STATES"}]}]},{"licenseeName":"John Wick","manufacturers":[{"manufacturerName":"Intel","productLocation":[{"state":"MARYLAND","country":"UNITED STATES"},{"state":"","country":"CHINA"}]},{"manufacturerName":"IBM","productLocation":[{"state":"FLORIDA","country":"UNITED STATES"}]}]}]}],"commercialProds":[{"commercialName":"nih prods","fdaApprovalNumber":"431","publicInd":"Yes","govtReviewStatus":"Pending","fdaApprovalType":"Biologic"}],"licensees":[{"id":9268,"licenseeName":"John Wick","exclusiveCount":87,"nonExclusiveCount":45,"smallBusiness":true},{"id":9269,"licenseeName":"STANFORD UNIVERSITY","exclusiveCount":15,"nonExclusiveCount":0,"smallBusiness":false},{"id":9270,"licenseeName":"LicenseeD","exclusiveCount":15,"nonExclusiveCount":0,"smallBusiness":false},{"id":9271,"licenseeName":"James Doe","exclusiveCount":15,"nonExclusiveCount":0,"smallBusiness":false},{"id":9272,"licenseeName":"LicenseeE","exclusiveCount":0,"nonExclusiveCount":12,"smallBusiness":false}],"createdDate":"08/11/2023","lastUpdatedDate":"08/11/2023"}],"totalRecords":1,"limit":100,"offset":0}';
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseStr);
            res.setStatusCode(200);
            
            return res;
        }
        if (req.getMethod() == 'POST' 
                && req.getEndpoint().containsignorecase('inventions')
                && req.getEndpoint().containsignorecase('search')) { 

            String responseStr = '{"inventions":[{"id":490047,"granteeOrganizationName":"UNIVOFMARYLAND,COLLEGEPARK","institutionCode":"0820102","dunsNumber":"790934285","inventionTitle":"TheCyberSupplyChainRiskManagementPortal","inventionDocketNumber":"11353","doesNumber":"","parentInventionNumber":"","inventionReportDate":"01/29/2015","inventionSubmitDate":"07/28/2017","reportingOverdue":false,"domesticManufactureWaiver":false,"doeWaiver":"","isExceptionCircumstanceDetermination":false,"keywords":[],"inventionReportNumber":"0820102-15-0070","inventors":[{"id":490047,"firstName":"Sandor","lastName":"Boyson","fedEmployee":false,"middleInitial":"","fedAgency":""},{"id":490048,"firstName":"Holly","lastName":"Mann","fedEmployee":false,"middleInitial":"","fedAgency":""},{"id":490049,"firstName":"Hart","lastName":"Rossman","fedEmployee":false,"middleInitial":"","fedAgency":""}],"primaryAgency":"NationalInstituteofStandardsandTechnology","fundingAgreements":[{"id":245047,"agreementType":"","agency":"NationalInstituteofStandardsandTechnology","grantNumber":"60NANB14D279","awardType":""}],"subContractInfos":[],"inventionStatus":{"titleElectionStatus": "Elect to Retain Title","notElectTitleReason": "ASSIGN TO OTHER PARTY"},"explanatoryNotes":[{"id":490047,"note":"By:DAUERBACH_EDIOn:2017-07-28IattemptedtoreportthisInventiontoiEdisonin2015butwasunabletoduetoaglitchiniEdisonsoIreportedit(aswellasthereleaseofPatentrights)directlytotheGrantsOfficerandGrantsSpecialistlistedontheawarddocumenton11/11/2015."}],"governmentNotes":[]}],"totalRecords":1,"limit":100,"offset":0}';
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseStr);
            res.setStatusCode(200);
            
            return res;
        }
        if (req.getMethod() == 'GET' 
                && req.getEndpoint().containsignorecase('cases')
                && req.getEndpoint().containsignorecase('compliance')
                && req.getEndpoint().containsignorecase('utilization')
                && req.getEndpoint().containsignorecase('11353')) { 
            System.debug('Mock: /cases/compliance/utilization');
            String responseStr = '{"results":[{"latestStageDev":"Commercialized","firstCommercialSaleYear":"2008","exclusiveLicensesOptions":1,"nonExclusiveLicensesOptions":0,"exclusiveLicensesNames":"XtalicCorporation","smallBusinessLicensesOptions":1,"licNamesAndCounts":"XtalicCorporation,1,0,1","totalIncome":422085.7936,"royaltiesOnSales":45000,"otherIncomeAndEquity":5000,"message":"Success","status":"SUCCESS","caseRecid":10856,"caseNumber":"11353","caseStatus":"Active","caseOfficerId":"NFRA","caseOfficerMitId":"925924697","caseOfficerName":"NestorFranco","caseOfficerEmail":"nefranco@mit.edu"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseStr);
            res.setStatusCode(200);
            
            return res;
        }    
        if (req.getMethod() == 'GET' 
                && req.getEndpoint().containsignorecase('cases')
                && req.getEndpoint().containsignorecase('compliance')
                && req.getEndpoint().containsignorecase('utilization')) { 
            System.debug('Mock: /cases/compliance/utilization');
            String responseStr = '{"results":[{"latestStageDev":"Commercialized","firstCommercialSaleYear":"2008","exclusiveLicensesOptions":1,"nonExclusiveLicensesOptions":0,"exclusiveLicensesNames":"XtalicCorporation","smallBusinessLicensesOptions":1,"licNamesAndCounts":"XtalicCorporation,1,0,1","totalIncome":422085.7936,"royaltiesOnSales":45000,"otherIncomeAndEquity":5000,"message":"Success","status":"SUCCESS","caseRecid":10856,"caseNumber":"11353T","caseStatus":"Active","caseOfficerId":"NFRA","caseOfficerMitId":"925924697","caseOfficerName":"NestorFranco","caseOfficerEmail":"nefranco@mit.edu"},{"latestStageDev":"NotLicensed","exclusiveLicensesOptions":0,"nonExclusiveLicensesOptions":0,"smallBusinessLicensesOptions":0,"message":"Success","status":"SUCCESS","caseRecid":19251,"caseNumber":"19133X","caseStatus":"Closed","caseOfficerId":"ZAMM","caseOfficerMitId":"913510012","caseOfficerName":"DeirdreZammit","caseOfficerEmail":"zammit@mit.edu"},{"responseCode":400,"message":"CaseNumber:fdfdf:ErrorfindingcaseRecid","errors":[{"code":"400","field":"caseNumber","message":"CaseNumber:fdfdf:ErrorfindingcaseRecid"}]}]}';
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseStr);
            res.setStatusCode(200);
            
            return res;
        }

        if (req.getEndpoint().containsignorecase('api/disclosure-doc-gen/v1') || req.getEndpoint().containsignorecase('pdf-generator-v1/generate/from-html') ) {
            PdfGeneratorApiMock pdfMock = new PdfGeneratorApiMock();
            return pdfMock.respond(req);
        }
        
        return null;
    }
}