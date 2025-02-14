public with sharing class IEdisonServiceReportToRequest {
    public static void mapReportToUtilizationRequest (Utilization_Report__c report, IEdisonUtilizationRequest request) {
        //Always submit the Forrester value for these fields
        report.First_Commercial_Year_of_Sale__c = report.Forrester_First_Commercial_Year_of_Sale__c;
        report.Total_Income__c = report.Forrester_Summarized_Agreement_Income__c;

        request.inventionReportNumber = report.Invention_Report_Number__c;
        request.reportingYear = integer.valueof(report.Reporting_Year__c);
        request.latestStageDev = report.Latest_Stage_of_Development__c;
                
        if (report.Invention_Report_Date__c != null) {
            if (String.isNotBlank(report.First_Commercial_Year_of_Sale__c)) {
                if (Integer.valueOf(report.First_Commercial_Year_of_Sale__c) < report.Invention_Report_Date__c.year() - 5) {
                    report.First_Commercial_Year_of_Sale__c = String.valueOf(report.Invention_Report_Date__c.year() - 5);
                } 
            }
        }

        if (report.First_Commercial_Year_of_Sale__c != null) {
            request.firstCommercialSaleYear = Integer.valueOf(report.First_Commercial_Year_of_Sale__c);
        }

        request.totalIncome = report.Total_Income__c;
        if (report.New_Us_Jobs__c != null) {
            request.newUsJobs = report.New_Us_Jobs__c.intValue();
        }
        if (report.New_Us_Companies__c != null) {
            request.newUsCompanies = report.New_Us_Companies__c.intValue();
        }
        request.notes = report.Notes__c;

        request.commercialProds = getIEdisonCommercialProds(report.Id);

        request.manufacturingCommProds = getIEdisonManufacturingCommProds(report.Id);

        request.licensees = getIEdisonLicensees(report.Id);

        if (String.isNotBlank(report.Commercialization_Plan_Id__c)) {
            request.commercializationPlanId = Integer.valueOf(report.Commercialization_Plan_Id__c);
        }

        request.isUSManufacturingRequired1 = report.Is_US_Manufacturing_Required_1__c;
        request.isUSManufacturingRequired2 = report.Is_US_Manufacturing_Required_2__c;
        request.isUSManufacturingRequired3 = report.Is_US_Manufacturing_Required_3__c;
    }

    public static List<IEdisonCommercialProds> getIEdisonCommercialProds(Id parentId) {
        List<IEdisonCommercialProds> commercialProds = new List<IEdisonCommercialProds>();
        List<Utilization_Commercial_Prods__c> recordsCommercialProds = [SELECT Id, Commercial_Name__c, Fda_Approval_Number__c, Fda_Approval_Type__c, Govt_Review_Status__c, Public_Ind__c FROM Utilization_Commercial_Prods__c WHERE Utilization_Report__c = :parentId];
        if (recordsCommercialProds.size() > 0) {
            for (Utilization_Commercial_Prods__c record : recordsCommercialProds) {
                IEdisonCommercialProds commercialProd = new IEdisonCommercialProds();
                commercialProd.commercialName = record.Commercial_Name__c;
                commercialProd.fdaApprovalNumber = record.Fda_Approval_Number__c;
                commercialProd.fdaApprovalType = record.Fda_Approval_Type__c;
                commercialProd.govtReviewStatus = record.Govt_Review_Status__c;
                commercialProd.publicInd = record.Public_Ind__c;
                commercialProds.Add(commercialProd);
            }
        }
        return commercialProds;
    }

    public static List<IEdisonManufacturingCommProds> getIEdisonManufacturingCommProds(Id parentId) {
        List<Utilization_Manufacturing_Comm_Prod__c> recordsManufacturingCommProds = [SELECT Id, Product_Name__c, Naics_Code__c FROM Utilization_Manufacturing_Comm_Prod__c WHERE Utilization_Report__c = :parentId];
        List<IEdisonManufacturingCommProds> manufacturingCommProds = new List<IEdisonManufacturingCommProds>();
        if (recordsManufacturingCommProds.size() > 0) {
            for (Utilization_Manufacturing_Comm_Prod__c record : recordsManufacturingCommProds) {
                IEdisonManufacturingCommProds manufacturingCommProd = new IEdisonManufacturingCommProds();
                manufacturingCommProd.productName = record.Product_Name__c;
                manufacturingCommProd.naicsCode = record.Naics_Code__c;
                manufacturingCommProd.licensees = getIEdisonLicenseeCommProds(record.Id);
                manufacturingCommProds.Add(manufacturingCommProd);
            }
        }
        return manufacturingCommProds;
    }

    public static List<IEdisonLicenceeManCommProds> getIEdisonLicenseeCommProds(Id parentId) {
        List<Utilization_Licensee_Man_Comm_Prod__c> recordsLicenseeManCommProds = [SELECT Id, Utilization_Licensee__c, Utilization_Licensee__r.Licensee_Name__c FROM Utilization_Licensee_Man_Comm_Prod__c WHERE Utilization_Manufacturing_Comm_Prod__c = :parentId];
        List<IEdisonLicenceeManCommProds> licensees = new List<IEdisonLicenceeManCommProds>();
        if (recordsLicenseeManCommProds.size() > 0) {
            for (Utilization_Licensee_Man_Comm_Prod__c record : recordsLicenseeManCommProds) {
                IEdisonLicenceeManCommProds licensee = new IEdisonLicenceeManCommProds();
                licensee.licenseeName = record.Utilization_Licensee__r.Licensee_Name__c;
                licensee.manufacturers = getIEdisonManufacturers(record.Id);
                licensees.add(licensee);
            }
        }
        return licensees;
    }

    public static List<IEdisonManufacturers> getIEdisonManufacturers(Id parentId) {
        List<Utilization_Manufacturers__c> recordsManufactures = [SELECT Id, Manufacturer_Name__c FROM Utilization_Manufacturers__c WHERE Utilization_Licensee_Man_Comm_Prod__c = :parentId];
        List<IEdisonManufacturers> manufactures = new List<IEdisonManufacturers>();
        if (recordsManufactures.size() > 0) {
            for (Utilization_Manufacturers__c record : recordsManufactures) {
                IEdisonManufacturers manufacturer = new IEdisonManufacturers();
                manufacturer.manufacturerName = record.Manufacturer_Name__c;
                manufacturer.productLocation = getIEdisonProductLocations(record.Id);
                manufactures.add(manufacturer);
            }
        }
        return manufactures;
    }

    public static List<IEdisonProductLocation> getIEdisonProductLocations(Id parentId) {
        Schema.DescribeFieldResult describeCountry = Utilization_Product_Location__c.Country__c.getDescribe();
        Map<String, String> countryMap = new Map<String, String>();
        for(PicklistEntry picklistEntry : describeCountry.getPicklistValues()) {
            countryMap.put(picklistEntry.getValue(), picklistEntry.getLabel());
        }

        Schema.DescribeFieldResult describeState = Utilization_Product_Location__c.State__c.getDescribe();
        Map<String, String> stateMap = new Map<String, String>();
        for(PicklistEntry picklistEntry : describeState.getPicklistValues()) {
            stateMap.put(picklistEntry.getValue(), picklistEntry.getLabel());
        }

        List<Utilization_Product_Location__c> recordsProductLocations = [SELECT Id, Country__c, First_Date__c, First_Date_Type__c, Product_Quantity__c, State__c FROM Utilization_Product_Location__c WHERE Utilization_Manufacturer__c = :parentId];
        List<IEdisonProductLocation> productLocations = new List<IEdisonProductLocation>();
        if (recordsProductLocations.size() > 0) {
            for (Utilization_Product_Location__c record : recordsProductLocations) {
                IEdisonProductLocation productLocation = new IEdisonProductLocation();
                productLocation.country = countryMap.get(record.Country__c);
                if (record.First_Date__c != null) {
                    productLocation.firstDate = DateToIEdisonString(record.First_Date__c);
                }
                productLocation.firstDateType = record.First_Date_Type__c;
                if (record.Product_Quantity__c != null) {
                    productLocation.productQuantity = record.Product_Quantity__c.intValue();
                }
                productLocation.state =  stateMap.get(record.State__c);
                productLocations.add(productLocation);
            }
        }
        return productLocations;
    }

    public static List<IEdisonLicensees> getIEdisonLicensees(Id parentId) {
        List<Utilization_Licensee__c> recordsLicensees = [SELECT Id, Licensee_Name__c, Exclusive_Count__c, Non_Exclusive_Count__c, Small_Business__c FROM Utilization_Licensee__c WHERE Utilization_Report__c = :parentId];
        List<IEdisonLicensees> licensees = new List<IEdisonLicensees>();
        if (recordsLicensees.size() > 0) {
            for (Utilization_Licensee__c record : recordsLicensees) {
                IEdisonLicensees licensee = new IEdisonLicensees();
                licensee.licenseeName = record.Licensee_Name__c;
                if (record.Exclusive_Count__c != null) {
                    licensee.exclusiveCount = record.Exclusive_Count__c.intValue();
                }
                if (record.Non_Exclusive_Count__c != null) {
                    licensee.nonExclusiveCount = record.Non_Exclusive_Count__c.intValue();
                }
                licensee.smallBusiness = record.Small_Business__c;
                licensees.add(licensee);
            }
        }
        return licensees;
    }

    public static String DateToIEdisonString(Date input) {
        DateTime dt = DateTime.newInstance(input.year(), input.month(), input.day());
        return dt.format('MM/dd/yyyy');
    }
}