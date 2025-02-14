public with sharing class EdisonInventionSearchJob implements Queueable, Database.AllowsCallouts  {
    private Boolean onlyErrorItems;
    
    public EdisonInventionSearchJob(Boolean onlyErrors) {
        onlyErrorItems = onlyErrors;
    }

    public void start(QueueableContext ctx) {
        System.debug('EdisonInventionSearchJob:start ' + ctx.getJobId());
    }

    public void execute(QueueableContext ctx) {
        IEdisonService iEdisonService = new IEdisonService();
        Integer batchSize = 100;
        Integer r_limit = 100;
        Integer offset  = 0;
        Integer totalRecords = 0;
        IEdisonInventionSearchResponse responseInvention;
        IEdisonUtilizationSearchResponse responseCurrentYearUtilization;
        IEdisonUtilizationSearchResponse responsePreviousYearUtilization;
        List<IEdisonInventionResponse> inventions = new List<IEdisonInventionResponse>();
        List<ForresterDto.UtilizationDto> forresterUtilizations = new List <ForresterDto.UtilizationDto>();
        List<IEdisonUtilizationResponse> currentYearUtilizations = new List<IEdisonUtilizationResponse>();
        List<IEdisonUtilizationResponse> previousYearUtilizations = new List<IEdisonUtilizationResponse>();
        List<Utilization_Report__c> insertList = new List<Utilization_Report__c>();
        List<Utilization_Report__c> updateList = new List<Utilization_Report__c>();
        List<Utilization_Licensee__c> insertLicenseeList = new List<Utilization_Licensee__c>();
        List<String> inventionReportNumbers = new List<String>();
        List<String> inventionDocketNumbers = new List<String>();
        List<String> forresterUtilizationsCaseNumbers = new List<String>();
        List<String> currentYearUtilizationReportNumbers = new List<String>();
        List<String> previousYearUtilizationReportNumbers = new List<String>();
        List<String> titleElectionStatus = new List<String>();
        List<Exception> exceptions =  new List<Exception>();
        titleElectionStatus.add('Elect to Retain Title');
        titleElectionStatus.add('Designated as Unpatented Biological Material or Research Tool');
        String granteeOrganizationName  = 'MASSACHUSETTS INSTITUTE OF TECHNOLOGY';
        try {

            Utilization_Report_Config__c  fyConfig = [
                SELECT
                    Name,
                    Fiscal_Year__c,
                    Start_Date__c,
                    End_Date__c,
                    Agreement_Types__c
                FROM Utilization_Report_Config__c
                ORDER BY Fiscal_Year__c DESC , LastModifiedDate DESC
                LIMIT 1
            ];

            List<String>  existingReportNumbers = new List<String>();
            Map<String,Id>  existingReportIds = new Map<String,Id>();
            List<SObject> repNumbers;
            if (onlyErrorItems) {
                repNumbers = new Map<String,SObject> (
                    [
                    SELECT Id, Invention_Report_Number__c
                    FROM Utilization_Report__c
                    WHERE Reporting_Year__c = :fyConfig.Fiscal_Year__c
                    AND Case_RecId__c = '' and Utilization_Report_Status__c = 'Error'
                    ORDER BY LastModifiedDate
                    LIMIT :batchSize 
                    ]
                ).values();
            } else {
                repNumbers = new Map<String,SObject> (
                    [
                    SELECT Id, Invention_Report_Number__c
                    FROM Utilization_Report__c
                    WHERE Reporting_Year__c = :fyConfig.Fiscal_Year__c
                    ]
                ).values();
            }
            for(SObject item : repNumbers) {
                String repNumber = (String)item.get('Invention_Report_Number__c');
                Id reportId = (Id)item.get('Id');
                existingReportNumbers.Add(repNumber);
                existingReportIds.put(repNumber, reportId);
            }

            offset = 0;
            do {
                responseInvention = iEdisonService.searchInvention(r_limit, offset, '', '', titleElectionStatus, '', granteeOrganizationName);
                offset = offset + 1;
                totalRecords = r_limit * offset;
                
                for (IEdisonInventionResponse invention : responseInvention.inventions) {
                    if (onlyErrorItems) {
                        if (existingReportNumbers.contains(invention.inventionReportNumber)) {
                            inventions.add(invention);
                            inventionReportNumbers.add(invention.inventionReportNumber);
                            inventionDocketNumbers.add(invention.inventionDocketNumber);
                        }
                    } else {
                        if (!existingReportNumbers.contains(invention.inventionReportNumber)) {
                            inventions.add(invention);
                            inventionReportNumbers.add(invention.inventionReportNumber);
                            inventionDocketNumbers.add(invention.inventionDocketNumber);
                        }
                    }
                    if (inventions.size() >= batchSize) {
                        break;
                    }
                }
            }   
            while (totalRecords < responseInvention.totalRecords && inventions.size() < batchSize );
            System.debug('inventionReportNumbers:' + JSON.serialize(inventionReportNumbers));

            totalRecords = 0;
            List<String> queryParamCaseNumbers = new List<String>();
            do {
                queryParamCaseNumbers.clear();
                for (Integer i = totalRecords; i < inventionDocketNumbers.size(); i++) {
                    totalRecords = totalRecords + 1;
                    String inventionDocketNumber = inventionDocketNumbers[i];
                    if (queryParamCaseNumbers.size() < 25) {
                        queryParamCaseNumbers.add(inventionDocketNumber);
                    } else {
                        break;
                    }
                }
                if (queryParamCaseNumbers.size() > 0) {
                    ForresterDto.UtilizationListDto utilizationData = iEdisonService.getForresterUtilizationData(queryParamCaseNumbers, Helpers.formatDate(fyConfig.Start_Date__c), Helpers.formatDate(fyConfig.End_Date__c), fyConfig.Agreement_Types__c);
                    if (utilizationData == null) {
                        break;
                    }
                    if (utilizationData.results == null) {
                        break;
                    }
                    if (utilizationData.results.size() == 0) {
                        break;
                    }
                    forresterUtilizations.addAll(utilizationData.results);
                    for (ForresterDto.UtilizationDto utilizationDto : utilizationData.results) {
                        if ( utilizationDto.caseNumber != null) {
                            forresterUtilizationsCaseNumbers.add(StringUtils.removeNonNumericCharacters(utilizationDto.caseNumber));
                        } else {
                            //Error
                            forresterUtilizationsCaseNumbers.add(IEdisonServiceResponseToReport.GetCaseNumberFromError(utilizationDto.message));
                        }
                    }
                }
            }
            while (totalRecords <  inventionDocketNumbers.size());
 
            offset = 0;
            do {
                responseCurrentYearUtilization = iEdisonService.searchUtilization(r_limit, offset, '', '', new List<String>(), Integer.valueOf(fyConfig.Fiscal_Year__c), '');
                offset = offset + 1;
                totalRecords = r_limit * offset;
                currentYearUtilizations.addAll(responseCurrentYearUtilization.utilizations);
                for (IEdisonUtilizationResponse utilization : responseCurrentYearUtilization.utilizations) {
                    currentYearUtilizationReportNumbers.add(utilization.inventionReportNumber);
                }
            }   
            while (totalRecords < responseCurrentYearUtilization.totalRecords);
            System.debug('currentYearUtilizationReportNumbers:' + JSON.serialize(currentYearUtilizationReportNumbers));

            //Removed as no data from previous reports are required
            // offset = 0;
            // do {
            //     responsePreviousYearUtilization = iEdisonService.searchUtilization(r_limit, offset, '', '', new List<String>(), Integer.valueOf(fyConfig.Fiscal_Year__c) - 1, '');
            //     offset = offset + 1;
            //     totalRecords = r_limit * offset;
            //     previousYearUtilizations.addAll(responsePreviousYearUtilization.utilizations);
            //     for (IEdisonUtilizationResponse utilization : responsePreviousYearUtilization.utilizations) {
            //         previousYearUtilizationReportNumbers.add(utilization.inventionReportNumber);
            //     }
            // }   
            // while (totalRecords < responsePreviousYearUtilization.totalRecords);
            // System.debug('previousYearUtilizationReportNumbers:' + JSON.serialize(previousYearUtilizationReportNumbers));
           
            if (!inventions.isEmpty()) {
                System.debug('inventions_size:-' + inventions.size().toString());
                for (IEdisonInventionResponse invention : inventions) {
                    System.debug('invention:' + JSON.serialize(invention));
                    try {
                        Utilization_Report__c report = new Utilization_Report__c();
                        if (onlyErrorItems) {
                            if (existingReportIds.containsKey(invention.inventionReportNumber)) {
                            Id reportId = existingReportIds.get(invention.inventionReportNumber);
                            report = [SELECT 
                                    Id, 
                                    Name,
                                    Invention_Docket_Number__c,
                                    Invention_Report_Number__c,
                                    Invention_Report_Date__c,
                                    Invention_Title__c,
                                    Reporting_Year__c,
                                    Latest_Stage_of_Development__c,
                                    Forrester_Latest_Stage_of_Development__c,
                                    Utilization_Report_Status__c,
                                    Utilization_Report_Title__c,
                                    First_Commercial_Year_of_Sale__c,
                                    Forrester_First_Commercial_Year_of_Sale__c,
                                    Total_Income__c,
                                    New_Us_Jobs__c,
                                    New_Us_Companies__c,
                                    Notes__c,
                                    Commercialization_Plan_Id__c,
                                    Is_US_Manufacturing_Required_1__c,
                                    Is_US_Manufacturing_Required_2__c,
                                    Is_US_Manufacturing_Required_3__c,
                                    Error_Messages__c,
                                    Case_RecId__c,
                                    Case_RecId_ExternalId__c,
                                    DOE_S_number__c,
                                    Election_Status__c,
                                    Exclusive_Licenses_Name__c,
                                    Forrester_Exclusive_Optionee_Name__c,
                                    Forrester_Non_Exclusive_Optionee_Name__c,
                                    Forrester_Small_Business_Optionee_Name__c,
                                    Forrester_Other_Income_and_Equity__c,
                                    Forrester_Royalties_on_Sales__c,
                                    Forrester_Summarized_Agreement_Income__c,
                                    Funding_Agency__c,
                                    Funding_Grant_Number__c,
                                    Grantee_Organization_Name__c,
                                    Non_Exclusive_Licenses_Name__c,
                                    Primary_Agency__c,
                                    Product_Name__c,
                                    Small_Business_Licenses_Name__c,
                                    Title_Election_Date__c,
                                    Utilization_Created_Date__c,
                                    Utilization_Submitted_Date__c,
                                    Utilization_Updated_Date__c
                                FROM Utilization_Report__c
                                WHERE Id = :reportId LIMIT 1];
                            }
                        }
                        report.Utilization_Report_Status__c = 'New';
                        report.Error_Messages__c = '';
                        report.Reporting_Year__c = fyConfig.Fiscal_Year__c;

                        Integer listIndex = 0;

                        //Removed as no data from previous reports are required
                        // listIndex = previousYearUtilizationReportNumbers.indexOf(invention.inventionReportNumber);
                        // if (listIndex >= 0) {
                        //     IEdisonUtilizationResponse  previousYearUtilization = previousYearUtilizations.get(listIndex);
                        //     iEdisonService.mapPreviousYearUtilizationToReport(report, previousYearUtilization);
                        // }

                        listIndex = currentYearUtilizationReportNumbers.indexOf(invention.inventionReportNumber);
                        if (listIndex >= 0) {
                            IEdisonUtilizationResponse  currentYearUtilization =  currentYearUtilizations.get(listIndex);
                            if (currentYearUtilization != null) {
                                report.Utilization_Report_Status__c = 'Completed';
                            }
                        }

                        listIndex = forresterUtilizationsCaseNumbers.indexOf(invention.inventionDocketNumber.removeEndIgnoreCase('L'));
                        if (listIndex >= 0) {
                            ForresterDto.UtilizationDto forresterUtilization =  forresterUtilizations.get(listIndex);
                            if (forresterUtilization.status == 'SUCCESS') {
                                iEdisonService.mapForresterUtilizationToReport(report, forresterUtilization);
                                if (report.Utilization_Report_Status__c != 'Completed') {
                                    iEdisonService.mapInitialForresterUtilizationToReport(report, forresterUtilization);
                                }
                            } else {
                                report.Utilization_Report_Status__c = 'Error';
                                if (forresterUtilization.responseCode == 400 ) {
                                    report.Error_Messages__c = JSON.serialize(forresterUtilization, true);
                                }
                            }
                        } else {
                            if (report.Utilization_Report_Status__c != 'Completed') {
                                report.Utilization_Report_Status__c = 'Error';
                            }
                        }

                        iEdisonService.mapInventionToReport(report, invention);
                        
                        insertList.add(report);
                        if (insertList.size() >= batchSize) {
                            break;
                        }
                    } catch (Exception e) {
                        System.debug('inner:-' + e.getMessage());
                        exceptions.add(e);
                        
                    }
                }

                if (insertList.size() > 0) {
                    // Save the parent objects
                    if (onlyErrorItems) {
                        //preivous error items already exist, thus always just update
                        update insertList;
                    } else {
                        insert insertList; 
                    }
                    System.debug('insertList:' + JSON.serialize(insertList));

                    //Add the children
                    for (Utilization_Report__c report : insertList) {
                        Integer listIndex;
                        listIndex = forresterUtilizationsCaseNumbers.indexOf(report.Invention_Docket_Number__c.removeEndIgnoreCase('L'));
                        if (listIndex >= 0) {
                            updateList.Add(report);
                            ForresterDto.UtilizationDto forresterUtilization =  forresterUtilizations.get(listIndex);
                            if (report.Utilization_Report_Status__c != 'Completed') {
                                List<Utilization_Licensee__c> licenseeList =  iEdisonService.mapInitalLicenseeNameAndCounts(report, forresterUtilization);                     
                                insertLicenseeList.addAll(licenseeList);
                            } 
                        }
                    }
                }

                if (insertLicenseeList.size() > 0) {
                    insert insertLicenseeList;
                }
                if (updateList.size() > 0) {
                    update updateList;
                }

                // Update from already captured reports in iEdison
                for (Utilization_Report__c report : insertList) {
                    Integer forresterlistIndex;
                    ForresterDto.UtilizationDto forresterUtilization = null;
                    forresterlistIndex = forresterUtilizationsCaseNumbers.indexOf(report.Invention_Docket_Number__c.removeEndIgnoreCase('L'));
                    if (forresterlistIndex >= 0) {
                        forresterUtilization =  forresterUtilizations.get(forresterlistIndex);
                    }
                    Integer listIndex;
                    if (report.Utilization_Report_Status__c == 'Completed') {
                        listIndex = currentYearUtilizationReportNumbers.indexOf(report.Invention_Report_Number__c);
                        if (listIndex >= 0) {
                            IEdisonUtilizationResponse  currentYearUtilization =  currentYearUtilizations.get(listIndex);
                            if (currentYearUtilization != null) {
                                IEdisonServiceResponseToReport.mapUtilizationResponseToReport(report, currentYearUtilization, forresterUtilization);
                            }
                        }
                    }
                }
            }
 
            for (Exception e : exceptions) {
                HandleLogException.logException(e);
            }

        } catch (Exception e) {
            System.debug(e.getMessage());
            HandleLogException.logException(e);
        }
    }
}