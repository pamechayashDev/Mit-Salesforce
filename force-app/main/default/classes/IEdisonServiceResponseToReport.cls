public with sharing class IEdisonServiceResponseToReport {
    public static void mapUtilizationResponseToReport (Utilization_Report__c report, IEdisonUtilizationResponse response, ForresterDto.UtilizationDto forresterUtilization) {
        deleteChildRecords(report.Id); 
        
        if (String.isNotBlank(response.createdDate)) {
            report.Utilization_Created_Date__c = IEdisonServiceResponseToReport.iEdisonStringToDate(response.createdDate);
        } else {
            report.Utilization_Created_Date__c = null;
        }
        if (String.isNotBlank(response.lastUpdatedDate)) {
            report.Utilization_Updated_Date__c = IEdisonServiceResponseToReport.iEdisonStringToDate(response.lastUpdatedDate);
        } else {
            report.Utilization_Updated_Date__c = null;
        }

        report.Reporting_Year__c = response.reportingYear.toString();
        if (response.latestStageDev == 'Not Licensed or Commercialized') {
            response.latestStageDev = 'Not Licensed';
        }
        report.Latest_Stage_of_Development__c = response.latestStageDev;
        report.First_Commercial_Year_of_Sale__c =  String.valueOf(response.firstCommercialSaleYear);
        report.Total_Income__c= response.totalIncome ?? 0.0;
        report.New_Us_Jobs__c = response.newUsJobs;
        report.New_Us_Companies__c = response.newUsCompanies;
        report.Notes__c = response.notes;

        putIEdisonCommercialProds(response.commercialProds, report);
        List<Utilization_Licensee__c> licensees = putIEdisonLicensees(response.licensees, report);
        putIEdisonManufacturingCommProds(response.manufacturingCommProds, report.Id, licensees);

        if (response.commercializationPlanId > 0) {
            report.Commercialization_Plan_Id__c = response.commercializationPlanId.toString();
        }

        report.Is_US_Manufacturing_Required_1__c = response.isUSManufacturingRequired1;
        report.Is_US_Manufacturing_Required_2__c = response.isUSManufacturingRequired2;
        report.Is_US_Manufacturing_Required_3__c = response.isUSManufacturingRequired3;

        if (forresterUtilization != null) {
            if (forresterUtilization.status == 'SUCCESS') {
                mergeForresterLicenseeNameAndCounts(report, forresterUtilization);
            }
        }

        List<Utilization_Licensee__c> items = [
            SELECT Id,
            Licensee_Name__c,
            Forrester_Licensee_Name__c,
            Exclusive_Count__c,
            Non_Exclusive_Count__c,
            Small_Business__c
            FROM Utilization_Licensee__c
            WHERE Utilization_Report__c = :report.Id
        ];
        for (Utilization_Licensee__c item : items) {
            putReportLicenseeNameAndCounts(item, report);
            putReportForresterLicenseeNameAndCounts(item, report);
        }

        update report;
    }


    public static void deleteChildRecords(Id reportId) {
        deleteCommercialProds(reportId);
        deleteManufactoringCommProds(reportId);
        deleteLicencees(reportId);
    }

    public static void deleteCommercialProds(Id reportId) {
        List<Utilization_Commercial_Prods__c> records = [
            SELECT Id
            FROM Utilization_Commercial_Prods__c
            WHERE Utilization_Report__c = :reportId
        ];
        delete records;
    }



    public static void deleteManufactoringCommProds(Id reportId) {
        List<Utilization_Manufacturing_Comm_Prod__c> records = getManufactoringCommProds(reportId);
        List<Id> recordIds = new List<id>();
        for (Utilization_Manufacturing_Comm_Prod__c record : records) {
            recordIds.add(record.Id);
        }
        deleteLicenseeManCommProds(recordIds);
        delete records;
    }

    
    public static void deleteLicenseeManCommProds( List<Id> manufactoringCommProdIds) {
        List<Utilization_Licensee_Man_Comm_Prod__c> records = getLicenceeManCommProds(manufactoringCommProdIds);
        List<Id> recordIds = new List<id>();
        for (Utilization_Licensee_Man_Comm_Prod__c record : records) {
            recordIds.add(record.Id);
        }
        deleteManufacturers(recordIds);
        delete records;
    }

    public static void deleteManufacturers( List<Id> licenseeManCommProdIds) {
        List<Utilization_Manufacturers__c> records = getManufacturers(licenseeManCommProdIds);
        List<Id> recordIds = new List<id>();
        for (Utilization_Manufacturers__c record : records) {
            recordIds.add(record.Id);
        }
        deleteProductLocations(recordIds);
        delete records;
    }

    public static void deleteProductLocations( List<Id> manufacturerIds) {
        List<Utilization_Product_Location__c> records = [
            SELECT Id
            FROM Utilization_Product_Location__c
            WHERE Utilization_Manufacturer__c IN :manufacturerIds
        ];
        delete records;
    }

    public static void deleteLicencees(Id reportId) {
        List<Utilization_Licensee__c> records = [
            SELECT Id
            FROM Utilization_Licensee__c
            WHERE Utilization_Report__c = :reportId
        ];
        delete records;
    }

    public static List<Utilization_Manufacturing_Comm_Prod__c> getManufactoringCommProds(Id reportId) {
        List<Utilization_Manufacturing_Comm_Prod__c> records = [
            SELECT Id
            FROM Utilization_Manufacturing_Comm_Prod__c
            WHERE Utilization_Report__c = :reportId
        ];
        return records;
    }

    public static List<Utilization_Manufacturing_Comm_Prod__c> getManufactoringCommProdsFromLicensee(List<Utilization_Licensee_Man_Comm_Prod__c> licManCommProdList) {
        List<Id> recordIds = new List<Id>();
        for (Utilization_Licensee_Man_Comm_Prod__c licManCommProd : licManCommProdList) {
            recordIds.add(licManCommProd.Utilization_Manufacturing_Comm_Prod__c);
        }
        List<Utilization_Manufacturing_Comm_Prod__c> records = [
            SELECT Id
            FROM Utilization_Manufacturing_Comm_Prod__c
            WHERE Id IN :recordIds
        ];
        return records;
    }

    public static List<Utilization_Licensee_Man_Comm_Prod__c> getLicenceeManCommProds(List<Id> manufacturinCommProdIds) {
        List<Utilization_Licensee_Man_Comm_Prod__c> records = [
            SELECT Id
            FROM Utilization_Licensee_Man_Comm_Prod__c
            WHERE Utilization_Manufacturing_Comm_Prod__c IN :manufacturinCommProdIds
        ];
        return records;
    }

    public static List<Utilization_Licensee_Man_Comm_Prod__c> getLicenceeManCommProdsFromLicensees(List<Id> licenseeIds) {
        List<Utilization_Licensee_Man_Comm_Prod__c> records = [
            SELECT 
                Id,
                Utilization_Manufacturing_Comm_Prod__c
            FROM Utilization_Licensee_Man_Comm_Prod__c
            WHERE Utilization_Licensee__c IN :licenseeIds
        ];
        return records;
    }

    public static List<Utilization_Manufacturers__c> getManufacturers(List<Id> licenceeManCommProdIds) {
        List<Utilization_Manufacturers__c> records = [
            SELECT Id
            FROM Utilization_Manufacturers__c
            WHERE Utilization_Licensee_Man_Comm_Prod__c IN :licenceeManCommProdIds
        ];
        return records;
    }

    
    public static void putIEdisonCommercialProds(List<IEdisonCommercialProds> commercialProds, Utilization_Report__c report) {
        Id parentId = report.Id;
        List<Utilization_Commercial_Prods__c> insertList = new List<Utilization_Commercial_Prods__c>();
        if (commercialProds != null) {
            for (Integer i = 0; i < commercialProds.size(); i++) {
                Utilization_Commercial_Prods__c item = new Utilization_Commercial_Prods__c();
                item.Utilization_Report__c = parentId;
                item.Commercial_Name__c = commercialProds[i].commercialName;
                item.Fda_Approval_Number__c = commercialProds[i].fdaApprovalNumber;
                item.Fda_Approval_Type__c = commercialProds[i].fdaApprovalType;
                item.Govt_Review_Status__c = commercialProds[i].govtReviewStatus;
                item.Public_Ind__c = commercialProds[i].publicInd;
                insertList.add(item);
                putReportCommercialProdNames(item, report);
            }
        }
        insert insertList;
    }

    public static List<Utilization_Licensee__c> putIEdisonLicensees(List<IEdisonLicensees> licensees, Utilization_Report__c report) {
        Id parentId = report.Id;
        List<Utilization_Licensee__c> insertList = new List<Utilization_Licensee__c>();
        if (licensees != null) {
            for (Integer i = 0; i < licensees.size(); i++) {
                Utilization_Licensee__c item = new Utilization_Licensee__c();
                item.Utilization_Report__c = parentId;
                item.Licensee_Name__c = licensees[i].licenseeName;
                item.Exclusive_Count__c = licensees[i].exclusiveCount;
                item.Non_Exclusive_Count__c = licensees[i].nonExclusiveCount;
                item.Small_Business__c = licensees[i].smallBusiness;
                insertList.add(item);
            }
        }
        insert insertList;
        return insertList;
    }

    public static void putIEdisonManufacturingCommProds(List<IEdisonManufacturingCommProds> manufacturingCommProds, Id parentId, List<Utilization_Licensee__c> licensees){
        if (manufacturingCommProds != null) {
            for (Integer i = 0; i < manufacturingCommProds.size(); i++) {
                Utilization_Manufacturing_Comm_Prod__c item = new Utilization_Manufacturing_Comm_Prod__c();
                item.Utilization_Report__c = parentId;
                item.Product_Name__c = manufacturingCommProds[i].productName;
                item.Naics_Code__c = manufacturingCommProds[i].naicsCode;
                insert item;

                putIEdisonLicenseeManCommProds(manufacturingCommProds[i].licensees, item.Id, licensees);
            }
        }
    }

    public static void putIEdisonLicenseeManCommProds(List<IEdisonLicenceeManCommProds> licenseeManCommProds, Id manufacturingCommProdId, List<Utilization_Licensee__c> licensees){
        if (licenseeManCommProds != null) {
            for (Integer i = 0; i < licenseeManCommProds.size(); i++) {
                Utilization_Licensee_Man_Comm_Prod__c item = new Utilization_Licensee_Man_Comm_Prod__c();

                Id licenseeId;
                for (Utilization_Licensee__c licensee : licensees) {
                    if (licensee.Licensee_Name__c == licenseeManCommProds[i].licenseeName) {
                        licenseeId = licensee.Id;
                        break;
                    }
                }

                item.Utilization_Licensee__c = licenseeId;
                item.Utilization_Manufacturing_Comm_Prod__c = manufacturingCommProdId;
                insert item;
                
                putIEdisonManufacturers(licenseeManCommProds[i].manufacturers, item.Id);
            }
        }
    }

    public static void putIEdisonManufacturers(List<IEdisonManufacturers> manufacturers, Id parentId) {
        if (manufacturers != null) {
            for (Integer i = 0; i < manufacturers.size(); i++) {
                Utilization_Manufacturers__c item = new Utilization_Manufacturers__c();
                item.Utilization_Licensee_Man_Comm_Prod__c = parentId;
                item.Manufacturer_Name__c = manufacturers[i].manufacturerName;
                insert item;
                
                putIEdisonProductLocations(manufacturers[i].productLocation, item.Id);
            }
        }

    }

    public static void putIEdisonProductLocations(List<IEdisonProductLocation> productLocations, Id parentId) {
        Schema.DescribeFieldResult describeCountry = Utilization_Product_Location__c.Country__c.getDescribe();
        Map<String, String> countryMap = new Map<String, String>();
        for(PicklistEntry picklistEntry : describeCountry.getPicklistValues()) {
            countryMap.put(picklistEntry.getLabel().toUpperCase(), picklistEntry.getValue());
        }

        Schema.DescribeFieldResult describeState = Utilization_Product_Location__c.State__c.getDescribe();
        Map<String, String> stateMap = new Map<String, String>();
        for(PicklistEntry picklistEntry : describeState.getPicklistValues()) {
            stateMap.put(picklistEntry.getLabel().toUpperCase(), picklistEntry.getValue());
        }

        List<Utilization_Product_Location__c> insertList = new List<Utilization_Product_Location__c>();
        if (productLocations != null) {
            for (Integer i = 0; i < productLocations.size(); i++) {
                Utilization_Product_Location__c item = new Utilization_Product_Location__c();
                item.Utilization_Manufacturer__c = parentId;
                if (!String.isblank(productLocations[i].country)) {
                    item.Country__c = countryMap.get(productLocations[i].country.toUpperCase());
                }
                if (!String.isBlank(productLocations[i].firstDate)) {
                    item.First_Date__c = IEdisonServiceResponseToReport.iEdisonStringToDate(productLocations[i].firstDate);
                }
                item.First_Date_Type__c = productLocations[i].firstDateType;
                item.Product_Quantity__c = productLocations[i].productQuantity;
                if (!String.isblank(productLocations[i].state)) {
                    item.State__c = stateMap.get(productLocations[i].state.toUpperCase());
                }
                insertList.add(item);
            }
        }
        insert insertList;
    }
   
    public static Date iEdisonStringToDate(String input) {
        List<String> intemList = input.split('/');
        Integer month = Integer.valueOf(intemList[0]);
        Integer day = Integer.valueOf(intemList[1]);
        Integer year = Integer.valueOf(intemList[2]);
        return Date.newInstance(
            year, month, day
        );
    }

    public static string GetCaseNumberFromError(String input) {
        List<String> intemList = input.split(':');
        if (intemList.size() >= 2) {
            if (intemList[0] == 'CaseNumber') {
                return intemList[1];
            }
        }
        return null;
    }

    public static void putReportCommercialProdNames(Utilization_Commercial_Prods__c item, Utilization_Report__c report) {
        report.Product_Name__c = appendProductName(
            report.Product_Name__c, item.Commercial_Name__c);
    }

    public static string appendProductName(String productNames, String productName) {
        if (!String.isblank(productNames)) {
            productNames = productNames + ',';
        } else {
            productNames = ''; 
        }
        productNames = productNames + productName;
        return productNames;
    }

    public static void putReportLicenseeNameAndCounts(Utilization_Licensee__c item, Utilization_Report__c report) {
        if (item.Exclusive_Count__c > 0) {
            report.Exclusive_Licenses_Name__c = appendLicenseeNameAndCount(
                report.Exclusive_Licenses_Name__c, item.Licensee_Name__c , item.Exclusive_Count__c.intValue());
        }
        if (item.Non_Exclusive_Count__c > 0) {
            report.Non_Exclusive_Licenses_Name__c = appendLicenseeNameAndCount(
                report.Non_Exclusive_Licenses_Name__c, item.Licensee_Name__c , item.Non_Exclusive_Count__c.intValue());
        }
        if (item.Small_Business__c) {
            report.Small_Business_Licenses_Name__c = appendLicenseeName(
                 report.Small_Business_Licenses_Name__c, item.Licensee_Name__c);
        }
    }

    public static void putReportForresterLicenseeNameAndCounts(Utilization_Licensee__c item, Utilization_Report__c report) {
        if (item.Exclusive_Count__c > 0) {
            report.Forrester_Exclusive_Optionee_Name__c = appendLicenseeNameAndCount(
                report.Forrester_Exclusive_Optionee_Name__c, item.Forrester_Licensee_Name__c , item.Exclusive_Count__c.intValue());
        }
        if (item.Non_Exclusive_Count__c > 0) {
            report.Forrester_Non_Exclusive_Optionee_Name__c = appendLicenseeNameAndCount(
                report.Forrester_Non_Exclusive_Optionee_Name__c, item.Forrester_Licensee_Name__c , item.Non_Exclusive_Count__c.intValue());
        }
        if (item.Small_Business__c) {
            report.Forrester_Small_Business_Optionee_Name__c = appendLicenseeName(
                 report.Forrester_Small_Business_Optionee_Name__c, item.Forrester_Licensee_Name__c);
        }
    }


    public static string appendLicenseeNameAndCount(String licenseeNames, String licenseeName, Integer count) {
        if (!String.isblank(licenseeNames)) {
            licenseeNames = licenseeNames + '; ';
        } else {
            licenseeNames = ''; 
        }
        licenseeNames = licenseeNames + licenseeName + '[' + String.valueOf(count) + ']';
        return licenseeNames;
    }

    public static string appendLicenseeName(String licenseeNames, String licenseeName) {
        if (!String.isblank(licenseeNames)) {
            licenseeNames = licenseeNames + '; ';
        } else {
            licenseeNames = ''; 
        }
        licenseeNames = licenseeNames + licenseeName;
        return licenseeNames;
    }

    public static void mergeForresterLicenseeNameAndCounts(Utilization_Report__c report, ForresterDto.UtilizationDto forresterUtilizationData) {
        Map<string, Utilization_Licensee__c> forresterList = new Map<string, Utilization_Licensee__c>();
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
                        forresterList.put(item.Licensee_Name__c, item);
                    }
                }
            }
        }

        List<Utilization_Licensee__c> updateList = new List<Utilization_Licensee__c>();
        List<Utilization_Licensee__c> deleteList = new List<Utilization_Licensee__c>(); 
        List<Id> deleteIdList = new List<Id>(); 
        List<Utilization_Licensee__c> existingLicensees = [SELECT Id, Forrester_Licensee_Name__c, Licensee_Name__c, Exclusive_Count__c, Non_Exclusive_Count__c, Small_Business__c FROM Utilization_Licensee__c WHERE Utilization_Report__c = :report.Id];
        if (existingLicensees.size() > 0) {
            String key = '';
            for (Utilization_Licensee__c record : existingLicensees) {
                key = '';
                if (!String.isblank(record.Forrester_Licensee_Name__c)) {
                    key = record.Forrester_Licensee_Name__c;
                } else {
                    key = record.Licensee_Name__c;
                }
                if (forresterList.containsKey(key)) {
                    Utilization_Licensee__c forresterItem = forresterList.get(key);
                    record.Forrester_Licensee_Name__c = key;
                    record.Exclusive_Count__c =  forresterItem.Exclusive_Count__c;
                    record.Non_Exclusive_Count__c =  forresterItem.Non_Exclusive_Count__c;
                    record.Small_Business__c =  forresterItem.Small_Business__c;
                    updateList.Add(record);
                    forresterList.remove(record.Forrester_Licensee_Name__c);
                } else {
                    deleteList.Add(record);
                    deleteIdList.Add(record.Id);
                }
            }
        }

        //Insert the remaining
        List<Utilization_Licensee__c> insertList = new List<Utilization_Licensee__c>();
        Set <String> keySet = new Set<String>();
        keySet = forresterList.keySet();
        for (String key : keySet) {
            Utilization_Licensee__c item = forresterList.get(key);
            insertList.Add(item);
        }

        if (deleteList.size() > 0) {
            List<Utilization_Licensee_Man_Comm_Prod__c> licManCommProdList = IEdisonServiceResponseToReport.getLicenceeManCommProdsFromLicensees(deleteIdList);
            List<Utilization_Manufacturing_Comm_Prod__c> manCommProdList = IEdisonServiceResponseToReport.getManufactoringCommProdsFromLicensee(licManCommProdList);
            List<Id> manCommProdIdList = new List<id>();
            for (Utilization_Manufacturing_Comm_Prod__c manCommProd : manCommProdList) {
                manCommProdIdList.add(manCommProd.Id);
            }
            IEdisonServiceResponseToReport.deleteLicenseeManCommProds(manCommProdIdList);
            delete manCommProdList;
            delete deleteList;
        }
        if (updateList.size() > 0) {
            update updateList;
        }
        if (insertList.size() > 0) {
            insert insertList;
        }   
    }
}