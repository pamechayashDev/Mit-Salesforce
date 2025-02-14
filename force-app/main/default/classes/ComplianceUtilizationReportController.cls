/**
 * Created by Andreas du Preez on 2024/10/28.
 */

public with sharing class ComplianceUtilizationReportController {

    @AuraEnabled
    public static ComplianceUtilizationReportController.UtilizationReportValidationResult validateUtilizationReport(Id recordId) {
        return ComplianceUtilizationReportService.validateComplianceUtilizationReport(recordId);
    }

    @AuraEnabled
    public static UtilizationReportWrapper getUtilizationReport(Id recordId) {
        return getUtilizationReportBulk(new List<Id>{recordId})[0];
    }

    @AuraEnabled
    public static List<UtilizationReportWrapper> getUtilizationReportBulk(List<Id> recordIds) {
        List<UtilizationReportWrapper> UtilizationReportWrappers = new List<UtilizationReportWrapper>();
        Map<Id, List<Utilization_Commercial_Prods__c>> commercialProdsMap = new Map<Id, List<Utilization_Commercial_Prods__c>>();
        Map<Id, List<Utilization_Licensee__c>> licenseeMap = new Map<Id, List<Utilization_Licensee__c>>();
        Map<Id, List<Utilization_Manufacturing_Comm_Prod__c>> manufacturingCommProdMap = new Map<Id, List<Utilization_Manufacturing_Comm_Prod__c>>();

        List<CommProdWrapper> manufacturingCommProdsWrappers = new List<CommProdWrapper>();

        List<Utilization_Report__c> utilizationReports = [
                SELECT
                        Id,
                        Funding_Agency__c,
                        Latest_Stage_of_Development__c,
                        Commercialization_Plan_Id__c,
                        Notes__c,
                        Is_US_Manufacturing_Required_1__c,
                        Is_US_Manufacturing_Required_2__c,
                        Is_US_Manufacturing_Required_3__c,
                        New_Us_Companies__c,
                        New_Us_Jobs__c,
                        Utilization_Report_Status__c
                FROM Utilization_Report__c
                WHERE Id IN :recordIds
        ];

        List<Utilization_Report_Config__c> utilizationReportConfig = [
                SELECT
                        Id,
                        Name,
                        End_Date__c,
                        Fiscal_Year__c,
                        Start_Date__c
                FROM Utilization_Report_Config__c
                LIMIT 1
        ];

        List<Utilization_Commercial_Prods__c> commercialProds = [
                SELECT
                        Id,
                        Name,
                        Commercial_Name__c,
                        Fda_Approval_Number__c,
                        Fda_Approval_Type__c,
                        Govt_Review_Status__c,
                        Public_Ind__c,
                        Utilization_Report__c
                FROM Utilization_Commercial_Prods__c
                WHERE Utilization_Report__c IN :recordIds
        ];

        for (Utilization_Commercial_Prods__c commercialProd : commercialProds) {
            if (!commercialProdsMap.containsKey(commercialProd.Utilization_Report__c)) {
                commercialProdsMap.put(commercialProd.Utilization_Report__c, new List<Utilization_Commercial_Prods__c>());
            }
            commercialProdsMap.get(commercialProd.Utilization_Report__c).add(commercialProd);
        }

        List<Utilization_Licensee__c> licensees = new List<Utilization_Licensee__c>([
                SELECT
                        Id,
                        Licensee_Name__c,
                        Exclusive_Count__c,
                        Non_Exclusive_Count__c,
                        Small_Business__c,
                        Utilization_Report__c
                FROM Utilization_Licensee__c
                WHERE Utilization_Report__c IN :recordIds
        ]);

        for (Utilization_Licensee__c licensee : licensees) {
            if (!licenseeMap.containsKey(licensee.Utilization_Report__c)) {
                licenseeMap.put(licensee.Utilization_Report__c, new List<Utilization_Licensee__c>());
            }
            licenseeMap.get(licensee.Utilization_Report__c).add(licensee);
        }

        List<Utilization_Manufacturing_Comm_Prod__c> manufacturingCommProds = [
                SELECT
                        Id,
                        Product_Name__c,
                        Naics_Code__c,
                        Utilization_Report__c,
                        (
                                SELECT
                                        Id,
                                        Utilization_Licensee__c,
                                        Utilization_Manufacturing_Comm_Prod__c,
                                        (
                                                SELECT
                                                        Id,
                                                        Manufacturer_Name__c,
                                                        (
                                                                SELECT
                                                                        Id,
                                                                        Country__c,
                                                                        First_Date__c,
                                                                        First_Date_Type__c,
                                                                        State__c,
                                                                        Product_Quantity__c,
                                                                        Utilization_Manufacturer__c
                                                                FROM Utilization_Product_Locations__r
                                                        )
                                                FROM Utilization_Licensee_Man_Comm_Prods__r
                                        )
                                FROM Utilization_Manufacturing_Comm_Prods__r
                        )
                FROM Utilization_Manufacturing_Comm_Prod__c
                WHERE Utilization_Report__c IN :recordIds
        ];

        for (Utilization_Manufacturing_Comm_Prod__c manufacturingCommProd : manufacturingCommProds) {
            if (!manufacturingCommProdMap.containsKey(manufacturingCommProd.Utilization_Report__c)) {
                manufacturingCommProdMap.put(manufacturingCommProd.Utilization_Report__c, new List<Utilization_Manufacturing_Comm_Prod__c>());
            }
            manufacturingCommProdMap.get(manufacturingCommProd.Utilization_Report__c).add(manufacturingCommProd);
        }

        // Create UtilizationReportWrapper objects
        for (Utilization_Report__c utilizationReport : utilizationReports) {
            if (manufacturingCommProdMap.size() > 0) {
                for (Utilization_Manufacturing_Comm_Prod__c manufacturingCommProd : manufacturingCommProdMap.get(utilizationReport.Id)) {
                    CommProdWrapper commProdWrapper = new CommProdWrapper();

                    List<LicenseeProductWrapper> licenseeProductWrappers = new List<LicenseeProductWrapper>();
                    for (Utilization_Licensee_Man_Comm_Prod__c licenseeProduct : manufacturingCommProd.Utilization_Manufacturing_Comm_Prods__r) {
                        LicenseeProductWrapper licenseeProductWrapper = new LicenseeProductWrapper();

                        List<ManufacturerWrapper> manufacturerWrappers = new List<ManufacturerWrapper>();
                        for (Utilization_Manufacturers__c manufacturer : licenseeProduct.Utilization_Licensee_Man_Comm_Prods__r) {
                            ManufacturerWrapper manufacturerWrapper = new ManufacturerWrapper();

                            Utilization_Manufacturers__c manufacturerCopy = new Utilization_Manufacturers__c(Id = manufacturer.Id, Manufacturer_Name__c = manufacturer.Manufacturer_Name__c);
                            manufacturerWrapper.manufacturer = manufacturerCopy;
                            manufacturerWrapper.manufacturerProductLocations = manufacturer.Utilization_Product_Locations__r;
                            manufacturerWrappers.add(manufacturerWrapper);
                        }

                        Utilization_Licensee_Man_Comm_Prod__c licenseeProductCopy = new Utilization_Licensee_Man_Comm_Prod__c(Id = licenseeProduct.Id, Utilization_Licensee__c = licenseeProduct.Utilization_Licensee__c, Utilization_Manufacturing_Comm_Prod__c = licenseeProduct.Utilization_Manufacturing_Comm_Prod__c);
                        licenseeProductWrapper.licenseeProduct = licenseeProductCopy;
                        licenseeProductWrapper.licenseeManufacturers = manufacturerWrappers;
                        licenseeProductWrappers.add(licenseeProductWrapper);
                    }

                    Utilization_Manufacturing_Comm_Prod__c manufacturingCommProdCopy = new Utilization_Manufacturing_Comm_Prod__c(Id = manufacturingCommProd.Id, Product_Name__c = manufacturingCommProd.Product_Name__c, Naics_Code__c = manufacturingCommProd.Naics_Code__c, Utilization_Report__c = manufacturingCommProd.Utilization_Report__c);
                    commProdWrapper.commercialProd = manufacturingCommProdCopy;
                    commProdWrapper.licenseesProducts = licenseeProductWrappers;
                    manufacturingCommProdsWrappers.add(commProdWrapper);
                }
            }

            UtilizationReportWrapper utilizationReportWrapper = new UtilizationReportWrapper(utilizationReport,
                    utilizationReportConfig.size() == 1 ? utilizationReportConfig[0] : null,
                    commercialProdsMap.containsKey(utilizationReport.Id) ? commercialProdsMap.get(utilizationReport.Id) : new List<Utilization_Commercial_Prods__c>(),
                    licenseeMap.containsKey(utilizationReport.Id) ? licenseeMap.get(utilizationReport.Id): new List<Utilization_Licensee__c>(),
                    manufacturingCommProdsWrappers);

            UtilizationReportWrappers.add(utilizationReportWrapper);
        }

        return UtilizationReportWrappers;
    }

    @AuraEnabled
    public static ComplianceUtilizationReportController.UtilizationReportValidationResult saveUtilizationReport(UtilizationReportWrapper utilizationReport, Boolean doValidation) {
        if (utilizationReport.utilizationReport.Utilization_Report_Status__c == 'In Progress') {
            List<String> errorMessages = new List<String>();
            errorMessages.add('Utilization report in progress of being submitted');
            return new ComplianceUtilizationReportController.UtilizationReportValidationResult(false, errorMessages);
        }

        if (doValidation) {
            ComplianceUtilizationReportController.UtilizationReportValidationResult validationResult = ComplianceUtilizationReportService.validateUtilizationReport(utilizationReport);
            if (!validationResult.isValid) {
                return validationResult;
            }
        }

        if (utilizationReport.utilizationReport.Utilization_Report_Status__c == 'Completed' || utilizationReport.utilizationReport.Utilization_Report_Status__c == 'Error') {
            utilizationReport.utilizationReport.Utilization_Report_Status__c = 'New';
        }
        
        return ComplianceUtilizationReportService.saveUtilizationReport(utilizationReport);
    }

    @AuraEnabled(cacheable=true)
    public static List<Utilization_Report__c> getUtilizationReports(Id forresterCaseId) {
        // Retrieve CASE_RECID__c from Forrester_Case__x where Id matches the provided caseId
        Forrester_Case__x forresterCase = [
                SELECT CASE_RECID__c
                FROM Forrester_Case__x
                WHERE Id = :forresterCaseId
                LIMIT 1
        ];
        // Query Utilization_Report__c records where Case matches CASE_RECID__c
        return [
                SELECT Id, Name, Utilization_Report_Status__c, CreatedDate,
                        Reporting_Year__c, Invention_Report_Number__c
                FROM Utilization_Report__c
                WHERE Case_RecId__c = :forresterCase.CASE_RECID__c
        ];
    }


    // ------------------------------
    // Wrapper classes
    // ------------------------------
    public class UtilizationReportWrapper {
        public UtilizationReportWrapper() {
            this.commercialProds = new List<Utilization_Commercial_Prods__c>();
            this.commercialProdsToDelete = new List<Utilization_Commercial_Prods__c>();
            this.licensees = new List<Utilization_Licensee__c>();
            this.manufacturingCommProds = new List<CommProdWrapper>();
            this.manufacturingCommProdsToDelete = new List<CommProdWrapper>();
        }

        public UtilizationReportWrapper(Utilization_Report__c utilizationReport,
                Utilization_Report_Config__c utilizationReportConfig,
                List<Utilization_Commercial_Prods__c> commercialProds,
                List<Utilization_Licensee__c> licensees,
                List<CommProdWrapper> manufacturingCommProds
        ) {
            this.utilizationReport = utilizationReport;
            this.utilizationReportConfig = utilizationReportConfig;
            this.commercialProds = commercialProds;
            this.licensees = licensees;
            this.manufacturingCommProds = manufacturingCommProds;
        }

        @AuraEnabled
        public Utilization_Report__c utilizationReport { get; set; }
        @AuraEnabled
        public Utilization_Report_Config__c utilizationReportConfig { get; set; }
        @AuraEnabled
        public List<Utilization_Commercial_Prods__c> commercialProds { get; set; }
        @AuraEnabled
        public List<Utilization_Commercial_Prods__c> commercialProdsToDelete { get; set; }
        @AuraEnabled
        public List<Utilization_Licensee__c> licensees { get; set; }
        @AuraEnabled
        public List<CommProdWrapper> manufacturingCommProds { get; set; }
        @AuraEnabled
        public List<CommProdWrapper> manufacturingCommProdsToDelete { get; set; }
    }

    public class CommProdWrapper {
        public CommProdWrapper() {
            this.licenseesProducts = new List<LicenseeProductWrapper>();
            this.licenseesProductsToDelete = new List<LicenseeProductWrapper>();
        }
        public CommProdWrapper(Utilization_Manufacturing_Comm_Prod__c commercialProd, List<LicenseeProductWrapper> licenseesProducts, List<LicenseeProductWrapper> licenseesProductsToDelete) {
            this.commercialProd = commercialProd;
            this.licenseesProducts = licenseesProducts;
            this.licenseesProductsToDelete = licenseesProductsToDelete;
        }

        @AuraEnabled
        public Utilization_Manufacturing_Comm_Prod__c commercialProd { get; set; }
        @AuraEnabled
        public List<LicenseeProductWrapper> licenseesProducts { get; set; }
        @AuraEnabled
        public List<LicenseeProductWrapper> licenseesProductsToDelete { get; set; }
    }

    public class LicenseeProductWrapper {
        public LicenseeProductWrapper() {
            this.licenseeManufacturers = new List<ManufacturerWrapper>();
            this.licenseeManufacturersToDelete = new List<ManufacturerWrapper>();
        }
        public LicenseeProductWrapper(Utilization_Licensee_Man_Comm_Prod__c licenseeProduct, List<ManufacturerWrapper> licenseeManufacturers, List<ManufacturerWrapper> licenseeManufacturersToDelete) {
            this.licenseeProduct = licenseeProduct;
            this.licenseeManufacturers = licenseeManufacturers;
            this.licenseeManufacturersToDelete = licenseeManufacturersToDelete;
        }

        @AuraEnabled
        public Utilization_Licensee_Man_Comm_Prod__c licenseeProduct { get; set; }
        @AuraEnabled
        public List<ManufacturerWrapper> licenseeManufacturers { get; set; }
        @AuraEnabled
        public List<ManufacturerWrapper> licenseeManufacturersToDelete { get; set; }
    }

    public class ManufacturerWrapper {
        public ManufacturerWrapper() {
            this.manufacturerProductLocations = new List<Utilization_Product_Location__c>();
            this.manufacturerProductLocationsToDelete = new List<Utilization_Product_Location__c>();
        }
        public ManufacturerWrapper(Utilization_Manufacturers__c manufacturer, List<Utilization_Product_Location__c> manufacturerProductLocations, List<Utilization_Product_Location__c> manufacturerProductLocationsToDelete) {
            this.manufacturer = manufacturer;
            this.manufacturerProductLocations = manufacturerProductLocations;
            this.manufacturerProductLocationsToDelete = manufacturerProductLocationsToDelete;
        }

        @AuraEnabled
        public Utilization_Manufacturers__c manufacturer { get; set; }
        @AuraEnabled
        public List<Utilization_Product_Location__c> manufacturerProductLocations { get; set; }
        @AuraEnabled
        public List<Utilization_Product_Location__c> manufacturerProductLocationsToDelete { get; set; }
    }

    public class UtilizationReportValidationResult {
        public UtilizationReportValidationResult(Boolean isValid, List<String> errorMessage) {
            this.isValid = isValid;
            this.errorMessages = errorMessage;
        }
        @AuraEnabled
        public Boolean isValid { get; set; }
        @AuraEnabled
        public List<String> errorMessages { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<Forrester_Case__x> getCasesRelatedToUtilizationReport(Id utilizationReportId) {
        try {
            // Retrieve the Case_RecId__c from the provided Utilization_Report__c record
            Utilization_Report__c utilizationReport = [
                SELECT Case_RecId__c
                FROM Utilization_Report__c
                WHERE Id = :utilizationReportId
                LIMIT 1
            ];

            // Ensure Case_RecId__c is not null
            if (utilizationReport == null || utilizationReport.Case_RecId__c == null) {
                return new List<Forrester_Case__x>();
            }

            // Query all Forrester_Case__x records where CASE_RECID__c matches the Utilization Report's Case_RecId__c
            String recId = utilizationReport.Case_RecId__c;

                // Query all Forrester_Case__x records where CASE_RECID__c matches the Utilization Report's Case_RecId__c
                List<Forrester_Case__x> cases = [
                    SELECT Id, CASE_RECID__c, STATUS__c, DISCLOSURE_TITLE__c, CONTRACT_CASE_NUM__c,
                    OWNERSHIP_TYPE__c, OPEN_DATE__c, CLOSE_DATE__c, CASE_TYPE__c, TLO_NAME__c
                    FROM Forrester_Case__x
                    WHERE CASE_RECID__c = :recId
                ];

            return cases != null ? cases : new List<Forrester_Case__x>();
        } catch (Exception e) {
            // Log the exception and throw a meaningful message back to the client
            throw new AuraHandledException('An error occurred while fetching cases: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalCasesForUtilizationReports() {
        try {
            // Query all Utilization Reports meeting the criteria
            List<Utilization_Report__c> utilizationReports = [
                SELECT Case_RecId__c
                FROM Utilization_Report__c
                WHERE Case_RecId__c != null 
                AND Utilization_Report_Status__c = 'Include for Utilization'
            ];
    
            // Extract unique Case_RecId__c values into a Set
            Set<String> caseRecIds = new Set<String>();
            for (Utilization_Report__c report : utilizationReports) {
                caseRecIds.add(report.Case_RecId__c);
            }
    
            // If no Case_RecId__c values are found, return 0
            if (caseRecIds.isEmpty()) {
                return 0;
            }
    
            // Query Forrester_Case__x records matching the Case_RecId__c values
            Integer caseCount = [
                SELECT COUNT()
                FROM Forrester_Case__x
                WHERE CASE_RECID__c IN :caseRecIds
            ];
    
            // Return the total count
            return caseCount;
    
        } catch (Exception e) {
            // Log the exception and throw a meaningful message back to the client
            System.debug('Error fetching case count: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while counting cases: ' + e.getMessage());
        }
    }
    


    @AuraEnabled
    public static String executeUtilizationReportBatch() {
        try {
            CreateUtilizationReportJob utilizationReportJob = new CreateUtilizationReportJob();
            Database.executeBatch(utilizationReportJob, 20);
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException('Error submitting cases: ' + e.getMessage());
        }
    }

}