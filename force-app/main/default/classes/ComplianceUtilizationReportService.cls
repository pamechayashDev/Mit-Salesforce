/**
 * Created by Andreas du Preez on 2024/11/20.
 */

public without sharing class ComplianceUtilizationReportService {

    public static ComplianceUtilizationReportController.UtilizationReportValidationResult validateComplianceUtilizationReport(Id utilizationReportId) {
        ComplianceUtilizationReportController.UtilizationReportWrapper utilizationReportWrapper = ComplianceUtilizationReportController.getUtilizationReport(utilizationReportId);

        return validateUtilizationReport(utilizationReportWrapper);
    }

    public static Map<Id, ComplianceUtilizationReportController.UtilizationReportValidationResult> validateComplianceUtilizationReports(List<Id> utilizationReportIds) {
        List<ComplianceUtilizationReportController.UtilizationReportWrapper> utilizationReportWrapper = ComplianceUtilizationReportController.getUtilizationReportBulk(utilizationReportIds);
        Map<Id, ComplianceUtilizationReportController.UtilizationReportValidationResult> validationResultMap = new Map<Id, ComplianceUtilizationReportController.UtilizationReportValidationResult>();

        for (ComplianceUtilizationReportController.UtilizationReportWrapper wrapper : utilizationReportWrapper) {
            validationResultMap.put(wrapper.utilizationReport.Id, validateUtilizationReport(wrapper));
        }

        return validationResultMap;
    }

    // Validate Utilization Report
    public static ComplianceUtilizationReportController.UtilizationReportValidationResult validateUtilizationReport(ComplianceUtilizationReportController.UtilizationReportWrapper utilizationReportWrapper) {
        List<String> errorMessages = new List<String>();

        switch on utilizationReportWrapper.utilizationReport.Latest_Stage_of_Development__c {
            when 'Not Licensed' {
                errorMessages.addAll(validateStageOfDevelopmentNotLicensed(utilizationReportWrapper));
            }
            when 'Licensed' {
                errorMessages.addAll(validateStageOfDevelopmentLicensed(utilizationReportWrapper));
            }
            when 'Commercialized' {
                errorMessages.addAll(validateStageOfDevelopmentCommercialized(utilizationReportWrapper));
            }
            when else {
                errorMessages.add('Invalid stage of development<br>');
            }
        }

        if (errorMessages.size() > 0) {
            return new ComplianceUtilizationReportController.UtilizationReportValidationResult(false, errorMessages);
        }

        return new ComplianceUtilizationReportController.UtilizationReportValidationResult(true, null);
    }

    // Validate Not Licensed stage of development
    private static List<String> validateStageOfDevelopmentNotLicensed(ComplianceUtilizationReportController.UtilizationReportWrapper utilizationReportWrapper) {
        List<String> errorMessages = new List<String>();

        // Commercialized Plan ID is required
        if (String.isBlank(utilizationReportWrapper.utilizationReport.Commercialization_Plan_Id__c)) {
            errorMessages.add('Commercialization Plan is required<br>');
        } else {
            // If Commercialization Plan is 'Developing and/ or using this invention for internal purposes only' or 'No current commercialization plan' then Notes is required
            if (utilizationReportWrapper.utilizationReport.Commercialization_Plan_Id__c == '3' || utilizationReportWrapper.utilizationReport.Commercialization_Plan_Id__c == '6') {
                if (utilizationReportWrapper.utilizationReport.Notes__c == null || utilizationReportWrapper.utilizationReport.Notes__c.trim().length() == 0) {
                    errorMessages.add('Notes is required<br>');
                }
            }
        }

        return errorMessages;
    }

    // Validate Licensed stage of development
    private static List<String> validateStageOfDevelopmentLicensed(ComplianceUtilizationReportController.UtilizationReportWrapper utilizationReportWrapper) {
        List<String> errorMessages = new List<String>();

        // 'Is_US_Manufacturing_Required_1__c' and 'Is_US_Manufacturing_Required_2__c' is required
        if (utilizationReportWrapper.utilizationReport.Is_US_Manufacturing_Required_1__c == null || utilizationReportWrapper.utilizationReport.Is_US_Manufacturing_Required_2__c == null) {
            errorMessages.add('Is US Manufacturing Required 1 and 2 is required<br>');
        }

        return errorMessages;
    }

    // Validate Commercialized stage of development
    private static List<String> validateStageOfDevelopmentCommercialized(ComplianceUtilizationReportController.UtilizationReportWrapper utilizationReportWrapper) {
        // Create a Map of Licensee Ids and Licensee Names since the Licensee Name is not available on the Utilization_Licensee__c object
        Map<Id, String> licenseeNames = new Map<Id, String>();
        for (Utilization_Licensee__c licensee : utilizationReportWrapper.licensees) {
            licenseeNames.put(licensee.Id, licensee.Licensee_Name__c);
        }

        List<String> errorMessages = new List<String>();

        // Commercialized Plan ID is required
        if (String.isBlank(utilizationReportWrapper.utilizationReport.Commercialization_Plan_Id__c)) {
            errorMessages.add('Commercialization Plan is required<br>');
        } else {
            // If Commercialization Plan is 'Developing and/ or using this invention for internal purposes only' or 'No current commercialization plan' then Notes is required
            if (utilizationReportWrapper.utilizationReport.Commercialization_Plan_Id__c == '3' || utilizationReportWrapper.utilizationReport.Commercialization_Plan_Id__c == '6') {
                if (utilizationReportWrapper.utilizationReport.Notes__c == null || utilizationReportWrapper.utilizationReport.Notes__c.trim().length() == 0) {
                    errorMessages.add('Notes is required<br>');
                }
            }
        }

        // Is US Manufacturing Required 1, 2 and 3 is required
        if (utilizationReportWrapper.utilizationReport.Is_US_Manufacturing_Required_1__c == null || utilizationReportWrapper.utilizationReport.Is_US_Manufacturing_Required_2__c == null ||
                utilizationReportWrapper.utilizationReport.Is_US_Manufacturing_Required_3__c == null) {
            errorMessages.add('Is US Manufacturing Required 1, 2 and 3 is required<br>');
        }

        Set<String> uniqueProductNames = new Set<String>();
        // At least one Manufacturer Product Location is required if there are any Manufacturing Commercial Products
        for (ComplianceUtilizationReportController.CommProdWrapper commProdWrapper : utilizationReportWrapper.manufacturingCommProds) {
            Set<String> uniqueLicenseeIds = new Set<String>();

            if (uniqueProductNames.contains(commProdWrapper.commercialProd.Product_Name__c)) {
                errorMessages.add('Duplicate Product Name "' + commProdWrapper.commercialProd.Product_Name__c + '"<br>');
            }
            else {
                uniqueProductNames.add(commProdWrapper.commercialProd.Product_Name__c);
            }

            // Temporary Maps to store the missing Manufacturer and Location error messages
            Map<String, List<String>> missingManufacturerForLicenseeString = new Map<String, List<String>>();
            Map<String, List<String>> duplicateLicenseesPerProductString = new Map<String, List<String>>();
            Map<String, List<String>> missingLocationForManufacturerString = new Map<String, List<String>>();

            for (ComplianceUtilizationReportController.LicenseeProductWrapper licenseesProduct : commProdWrapper.licenseesProducts) {

                // Check for duplicate Licensees
                if (uniqueLicenseeIds.contains(licenseesProduct.licenseeProduct.Utilization_Licensee__c)) {
                    if (!duplicateLicenseesPerProductString.containsKey(commProdWrapper.commercialProd.Product_Name__c)) {
                        duplicateLicenseesPerProductString.put(commProdWrapper.commercialProd.Product_Name__c, new List<String>());
                    }
                    if (!duplicateLicenseesPerProductString.get(commProdWrapper.commercialProd.Product_Name__c).contains(licenseesProduct.licenseeProduct.Utilization_Licensee__c)) {
                        duplicateLicenseesPerProductString.get(commProdWrapper.commercialProd.Product_Name__c).add(licenseeNames.get(licenseesProduct.licenseeProduct.Utilization_Licensee__c));
                    }
                } else {
                    uniqueLicenseeIds.add(licenseesProduct.licenseeProduct.Utilization_Licensee__c);
                }

                // At least one Manufacturer is required for all Licensees
                if (licenseesProduct.licenseeManufacturers == null || licenseesProduct.licenseeManufacturers.size() == 0) {
                    if (!missingManufacturerForLicenseeString.containsKey(commProdWrapper.commercialProd.Product_Name__c)) {
                        missingManufacturerForLicenseeString.put(commProdWrapper.commercialProd.Product_Name__c, new List<String>());
                    }
                    missingManufacturerForLicenseeString.get(commProdWrapper.commercialProd.Product_Name__c).add(licenseeNames.get(licenseesProduct.licenseeProduct.Utilization_Licensee__c));
                }
                else {
                    for (ComplianceUtilizationReportController.ManufacturerWrapper manufacturer : licenseesProduct.licenseeManufacturers) {
                        if (manufacturer.manufacturerProductLocations == null || manufacturer.manufacturerProductLocations.size() == 0) {

                            // At least one Location is required for all Manufacturers
                            String commProdAndLicenseeName = commProdWrapper.commercialProd.Product_Name__c + ':::' + licenseeNames.get(licenseesProduct.licenseeProduct.Utilization_Licensee__c);
                            if (!missingLocationForManufacturerString.containsKey(commProdAndLicenseeName)) {
                                missingLocationForManufacturerString.put(commProdAndLicenseeName, new List<String>());
                            }
                            missingLocationForManufacturerString.get(commProdAndLicenseeName).add(manufacturer.manufacturer.Manufacturer_Name__c);
                        } else {
                            // If Funding Agency is DOE then First_Date__c, First_Date_Type__c and Product_Quantity__c is required
                            if (utilizationReportWrapper.utilizationReport.Funding_Agency__c != null && utilizationReportWrapper.utilizationReport.Funding_Agency__c.contains('DOE')) {
                                for (Utilization_Product_Location__c utilizationProductLocation : manufacturer.manufacturerProductLocations) {
                                    if (utilizationProductLocation.First_Date__c == null || utilizationProductLocation.First_Date_Type__c == null || utilizationProductLocation.Product_Quantity__c == null) {
                                        errorMessages.add('If a Funding Agency is DOE then First Date, First Date Type and Product Quantity is required for all Manufacturing Product Locations<br>');
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Add a HTML encoded friendly error message for each duplicate Licensee
            if (duplicateLicenseesPerProductString.size() > 0) {
                for (String productName : duplicateLicenseesPerProductString.keySet()) {
                    String licenseeNamesString = '<b>Product: ' + productName + ' - may not have duplicate Licensees</b><br><ul>';
                    for (String licenseeName : duplicateLicenseesPerProductString.get(productName)) {
                        licenseeNamesString += '<li>' + licenseeName + '</li>';

                        // Remove the duplicate Licensee from the list Licensees with missing Manufacturers
                        while (missingManufacturerForLicenseeString.containsKey(productName) && missingManufacturerForLicenseeString.get(productName).contains(licenseeName)) {
                            missingManufacturerForLicenseeString.get(productName).remove(missingManufacturerForLicenseeString.get(productName).indexOf(licenseeName));
                        }
                    }
                    licenseeNamesString += '</ul>';
                    errorMessages.add(licenseeNamesString);
                }
            }

            // Add a HTML encoded friendly error message for each missing Manufacturer
            if (missingManufacturerForLicenseeString.size() > 0) {
                for (String productName : missingManufacturerForLicenseeString.keySet()) {
                    if (missingManufacturerForLicenseeString.get(productName).size() == 0) {
                        continue;
                    }

                    String licenseeNamesString = '<b>Product: ' + productName + ' - Manufacturers are missing for the following Licensees</b><br><ul>';
                    for (String licenseeName : missingManufacturerForLicenseeString.get(productName)) {
                        licenseeNamesString += '<li>' + licenseeName + '</li>';
                    }
                    licenseeNamesString += '</ul>';
                    errorMessages.add(licenseeNamesString);
                }
            }

            // Add a HTML encoded friendly error message for each missing Manufacturer Location
            if (missingLocationForManufacturerString.size() > 0) {
                for (String commProdLicensee : missingLocationForManufacturerString.keySet()) {
                    List<String> commProdLicenseeSplit = commProdLicensee.split(':::');
                    String locationNamesString = '<b>Product: ' + commProdLicenseeSplit[0] + ', Licensee: ' + commProdLicenseeSplit[1] + ' - Locations are missing for the following Manufacturers</b><br><ul>';
                    for (String locationName : missingLocationForManufacturerString.get(commProdLicensee)) {
                        locationNamesString += '<li>' + locationName + '</li>';
                    }
                    locationNamesString += '</ul>';
                    errorMessages.add(locationNamesString);
                }
            }
        }

        return errorMessages;
    }

    // Save Utilization Report
    public static ComplianceUtilizationReportController.UtilizationReportValidationResult saveUtilizationReport(ComplianceUtilizationReportController.UtilizationReportWrapper utilizationReport) {
        List<Utilization_Commercial_Prods__c> commercialProdsToInsert = new List<Utilization_Commercial_Prods__c>();
        List<Utilization_Commercial_Prods__c> commercialProdsToUpdate = new List<Utilization_Commercial_Prods__c>();
        List<Utilization_Manufacturing_Comm_Prod__c> manufacturingCommProdsToInsert = new List<Utilization_Manufacturing_Comm_Prod__c>();
        List<Utilization_Manufacturing_Comm_Prod__c> manufacturingCommProdsToUpdate = new List<Utilization_Manufacturing_Comm_Prod__c>();
        List<Utilization_Manufacturing_Comm_Prod__c> manufacturingCommProdsToDelete = new List<Utilization_Manufacturing_Comm_Prod__c>();
        List<Utilization_Licensee_Man_Comm_Prod__c> licenseeProductsToInsert = new List<Utilization_Licensee_Man_Comm_Prod__c>();
        List<Utilization_Licensee_Man_Comm_Prod__c> licenseeProductsToUpdate = new List<Utilization_Licensee_Man_Comm_Prod__c>();
        List<Utilization_Licensee_Man_Comm_Prod__c> licenseeProductsToDelete = new List<Utilization_Licensee_Man_Comm_Prod__c>();
        List<Utilization_Manufacturers__c> licenseeManufacturersToInsert = new List<Utilization_Manufacturers__c>();
        List<Utilization_Manufacturers__c> licenseeManufacturersToUpdate = new List<Utilization_Manufacturers__c>();
        List<Utilization_Manufacturers__c> licenseeManufacturersToDelete = new List<Utilization_Manufacturers__c>();
        List<Utilization_Product_Location__c> productLocationsToInsert = new List<Utilization_Product_Location__c>();
        List<Utilization_Product_Location__c> productLocationsToUpdate = new List<Utilization_Product_Location__c>();
        List<Utilization_Product_Location__c> productLocationsToDelete = new List<Utilization_Product_Location__c>();

        update utilizationReport.utilizationReport;

        if (utilizationReport.commercialProds != null) {
            for (Utilization_Commercial_Prods__c prod : utilizationReport.commercialProds) {
                if (prod.Id == null) {
                    prod.Utilization_Report__c = utilizationReport.utilizationReport.Id;
                    commercialProdsToInsert.add(prod);
                } else {
                    commercialProdsToUpdate.add(prod);
                }
            }
        }

        if (!commercialProdsToInsert.isEmpty()) insert commercialProdsToInsert;
        if (!commercialProdsToUpdate.isEmpty()) update commercialProdsToUpdate;
        if (utilizationReport.commercialProdsToDelete != null) {
            delete utilizationReport.commercialProdsToDelete;
            utilizationReport.commercialProdsToDelete = null;
        }

        if (utilizationReport.licensees != null) {
            update utilizationReport.licensees;
        }

        // From here on, we are dealing with the Utilization_Manufacturing_Comm_Prod__c records, which are a 4 level deep hierarchy.
        // We need to insert/update one level at a time, starting from the top level, to ensure that we have the correct parent Ids.
        // After each level iteration, we need to update the parent Ids on the child records, before inserting/updating them.
        // For the sake of readability, the top level is referred to as the 1st level, the second level as the 2nd level, etc.
        // Starting at the 1st level: Utilization_Manufacturing_Comm_Prod__c
        if (utilizationReport.manufacturingCommProds != null) {
            for (ComplianceUtilizationReportController.CommProdWrapper commProdWrapper : utilizationReport.manufacturingCommProds) {
                if (commProdWrapper.commercialProd.Id == null) {
                    manufacturingCommProdsToInsert.add(commProdWrapper.commercialProd);
                } else {
                    manufacturingCommProdsToUpdate.add(commProdWrapper.commercialProd);
                }
            }
        }

        if (utilizationReport.manufacturingCommProdsToDelete != null) {
            for (ComplianceUtilizationReportController.CommProdWrapper commProdWrapper : utilizationReport.manufacturingCommProdsToDelete) {
                if (commProdWrapper.commercialProd.Id != null) {
                    manufacturingCommProdsToDelete.add(commProdWrapper.commercialProd);
                }
            }
        }

        // Insert, update and delete the 1st level: Utilization_Manufacturing_Comm_Prod__c
        if (!manufacturingCommProdsToInsert.isEmpty()) insert manufacturingCommProdsToInsert;
        if (!manufacturingCommProdsToUpdate.isEmpty()) update manufacturingCommProdsToUpdate;
        if (!manufacturingCommProdsToDelete.isEmpty()) delete manufacturingCommProdsToDelete;

        // Next, the 2nd level: Utilization_Licensee_Product__c
        if (utilizationReport.manufacturingCommProds != null) {
            for (ComplianceUtilizationReportController.CommProdWrapper commProdWrapper : utilizationReport.manufacturingCommProds) {
                if (commProdWrapper.licenseesProducts != null) {
                    for (ComplianceUtilizationReportController.LicenseeProductWrapper licenseeProductWrapper : commProdWrapper.licenseesProducts) {
                        if (licenseeProductWrapper.licenseeProduct.Id == null) {
                            licenseeProductWrapper.licenseeProduct.Utilization_Manufacturing_Comm_Prod__c = commProdWrapper.commercialProd.Id;
                            licenseeProductsToInsert.add(licenseeProductWrapper.licenseeProduct);
                        } else {
                            licenseeProductsToUpdate.add(licenseeProductWrapper.licenseeProduct);
                        }
                    }
                }

                if (commProdWrapper.licenseesProductsToDelete != null) {
                    for (ComplianceUtilizationReportController.LicenseeProductWrapper licenseeProductWrapper : commProdWrapper.licenseesProductsToDelete) {
                        if (licenseeProductWrapper.licenseeProduct.Id != null) {
                            licenseeProductsToDelete.add(licenseeProductWrapper.licenseeProduct);
                        }
                    }
                }
            }
        }

        // Insert, update and delete the 2nd level: Utilization_Licensee_Product__c
        if (!licenseeProductsToInsert.isEmpty()) insert licenseeProductsToInsert;
        if (!licenseeProductsToUpdate.isEmpty()) update licenseeProductsToUpdate;
        if (!licenseeProductsToDelete.isEmpty()) delete licenseeProductsToDelete;

        // Next, the 3rd level: Utilization_Manufacturers__c
        if (utilizationReport.manufacturingCommProds != null) {
            for (ComplianceUtilizationReportController.CommProdWrapper commProdWrapper : utilizationReport.manufacturingCommProds) {
                if (commProdWrapper.licenseesProducts != null) {
                    for (ComplianceUtilizationReportController.LicenseeProductWrapper licenseeProductWrapper : commProdWrapper.licenseesProducts) {
                        if (licenseeProductWrapper.licenseeManufacturers != null) {
                            for (ComplianceUtilizationReportController.ManufacturerWrapper manufacturerWrapper : licenseeProductWrapper.licenseeManufacturers) {
                                if (manufacturerWrapper.manufacturer.Id == null) {
                                    manufacturerWrapper.manufacturer.Utilization_Licensee_Man_Comm_Prod__c = licenseeProductWrapper.licenseeProduct.Id;
                                    licenseeManufacturersToInsert.add(manufacturerWrapper.manufacturer);
                                } else {
                                    licenseeManufacturersToUpdate.add(manufacturerWrapper.manufacturer);
                                }
                            }
                        }

                        if (licenseeProductWrapper.licenseeManufacturersToDelete != null) {
                            for (ComplianceUtilizationReportController.ManufacturerWrapper manufacturerWrapper : licenseeProductWrapper.licenseeManufacturersToDelete) {
                                if (manufacturerWrapper.manufacturer.Id != null) {
                                    licenseeManufacturersToDelete.add(manufacturerWrapper.manufacturer);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Insert, update and delete the 3rd level: Utilization_Manufacturers__c
        if (!licenseeManufacturersToInsert.isEmpty()) insert licenseeManufacturersToInsert;
        if (!licenseeManufacturersToUpdate.isEmpty()) update licenseeManufacturersToUpdate;
        if (!licenseeManufacturersToDelete.isEmpty()) delete licenseeManufacturersToDelete;

        // Finally, the 4th level: Utilization_Product_Location__c
        if (utilizationReport.manufacturingCommProds != null) {
            for (ComplianceUtilizationReportController.CommProdWrapper commProdWrapper : utilizationReport.manufacturingCommProds) {
                if (commProdWrapper.licenseesProducts != null) {
                    for (ComplianceUtilizationReportController.LicenseeProductWrapper licenseeProductWrapper : commProdWrapper.licenseesProducts) {
                        if (licenseeProductWrapper.licenseeManufacturers != null) {
                            for (ComplianceUtilizationReportController.ManufacturerWrapper manufacturerWrapper : licenseeProductWrapper.licenseeManufacturers) {
                                if (manufacturerWrapper.manufacturerProductLocations != null) {
                                    for (Utilization_Product_Location__c productLocation : manufacturerWrapper.manufacturerProductLocations) {
                                        if (productLocation.Id == null) {
                                            productLocation.Utilization_Manufacturer__c = manufacturerWrapper.manufacturer.Id;
                                            productLocationsToInsert.add(productLocation);
                                        } else {
                                            productLocationsToUpdate.add(productLocation);
                                        }
                                    }
                                }

                                if (manufacturerWrapper.manufacturerProductLocationsToDelete != null) {
                                    for (Utilization_Product_Location__c productLocation : manufacturerWrapper.manufacturerProductLocationsToDelete) {
                                        if (productLocation.Id != null) {
                                            productLocationsToDelete.add(productLocation);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Insert, update and delete the 4th level: Utilization_Product_Location__c
        if (!productLocationsToInsert.isEmpty()) insert productLocationsToInsert;
        if (!productLocationsToUpdate.isEmpty()) update productLocationsToUpdate;
        if (!productLocationsToDelete.isEmpty()) delete productLocationsToDelete;

        return new ComplianceUtilizationReportController.UtilizationReportValidationResult(true, null);
    }
}