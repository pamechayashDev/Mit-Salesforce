/**
 * Created by Andreas du Preez on 2024/10/25.
 * This service class acts as a data service for the Compliance Utilization Report component.
 * It is responsible for fetching and saving the Utilization Report record.
 * It also parses the record into a "suitcase" object that is used between the parent and child components.
 * The suitcase object is used to keep track of the Utilization Report record and its related objects.
 * The suitcase object is also used to keep track of the field describe objects and their values.
 *
 * To add a new object to be used in the Utilization Report, add the object's schema to the UTILIZATION_REPORT_OBJECTS array.
 * The fields describe of the new object will automatically be populated in the suitcase object.
 * No business logic should be implemented in this component.
 */

import getUtilizationReportDS from "@salesforce/apex/ComplianceUtilizationReportController.getUtilizationReport";
import saveUtilizationReportDS from "@salesforce/apex/ComplianceUtilizationReportController.saveUtilizationReport";
import UTILIZATION_REPORT__C from "@salesforce/schema/Utilization_Report__c";
import UTILIZATION_REPORT_CONFIG__C from "@salesforce/schema/Utilization_Report_Config__c";
import UTILIZATION_COMMERCIAL_PRODS__C from "@salesforce/schema/Utilization_Commercial_Prods__c";
import UTILIZATION_MANUFACTURING_COMM_PROD__C from "@salesforce/schema/Utilization_Manufacturing_Comm_Prod__c";

import UTILIZATION_LICENSEE__C from "@salesforce/schema/Utilization_Licensee__c";
import UTILIZATION_MANUFACTURERS__C from "@salesforce/schema/Utilization_Manufacturers__c";
import UTILIZATION_PRODUCT_LOCATION__C from "@salesforce/schema/Utilization_Product_Location__c";

// Utilization Report Fields:
import UTILIZATION_REPORT__C_LATEST_STAGE_OF_DEVELOPMENT__C from "@salesforce/schema/Utilization_Report__c.Latest_Stage_of_Development__c";
import UTILIZATION_REPORT__C_COMMERCIALIZATION_PLAN_ID__C from "@salesforce/schema/Utilization_Report__c.Commercialization_Plan_Id__c";
import UTILIZATION_REPORT__C_NOTES__C from "@salesforce/schema/Utilization_Report__c.Notes__c";
import UTILIZATION_REPORT__C_IS_US_MANUFACTURING_REQUIRED_1__C from "@salesforce/schema/Utilization_Report__c.Is_US_Manufacturing_Required_1__c";
import UTILIZATION_REPORT__C_IS_US_MANUFACTURING_REQUIRED_2__C from "@salesforce/schema/Utilization_Report__c.Is_US_Manufacturing_Required_2__c";
import UTILIZATION_REPORT__C_IS_US_MANUFACTURING_REQUIRED_3__C from "@salesforce/schema/Utilization_Report__c.Is_US_Manufacturing_Required_3__c";
import UTILIZATION_REPORT__C_NEW_US_COMPANIES__C from "@salesforce/schema/Utilization_Report__c.New_Us_Companies__c";
import UTILIZATION_REPORT__C_NEW_US_JOBS__C from "@salesforce/schema/Utilization_Report__c.New_Us_Jobs__c";

// Utilization Commercial Prods Fields:
import UTILIZATION_COMMERCIAL_PRODS__C_COMMERCIAL_NAME__C from "@salesforce/schema/Utilization_Commercial_Prods__c.Commercial_Name__c";
import UTILIZATION_COMMERCIAL_PRODS__C_FDA_APPROVAL_NUMBER__C from "@salesforce/schema/Utilization_Commercial_Prods__c.Fda_Approval_Number__c";
import UTILIZATION_COMMERCIAL_PRODS__C_FDA_APPROVAL_TYPE__C from "@salesforce/schema/Utilization_Commercial_Prods__c.Fda_Approval_Type__c";
import UTILIZATION_COMMERCIAL_PRODS__C_GOVT_REVIEW_STATUS__C from "@salesforce/schema/Utilization_Commercial_Prods__c.Govt_Review_Status__c";
import UTILIZATION_COMMERCIAL_PRODS__C_PUBLIC_IND__C from "@salesforce/schema/Utilization_Commercial_Prods__c.Public_Ind__c";
import UTILIZATION_COMMERCIAL_PRODS__C_UTILIZATION_REPORT__C from "@salesforce/schema/Utilization_Commercial_Prods__c.Utilization_Report__c";

// Utilization Licensee Fields:
import UTILIZATION_LICENSEE__C_EXCLUSIVE_COUNT__C from "@salesforce/schema/Utilization_Licensee__c.Exclusive_Count__c";
import UTILIZATION_LICENSEE__C_NON_EXCLUSIVE_COUNT__C from "@salesforce/schema/Utilization_Licensee__c.Non_Exclusive_Count__c";
import UTILIZATION_LICENSEE__C_SMALL_BUSINESS__C from "@salesforce/schema/Utilization_Licensee__c.Small_Business__c";
import UTILIZATION_LICENSEE__C_UTILIZATION_REPORT__C from "@salesforce/schema/Utilization_Licensee__c.Utilization_Report__c";

// Utilization Product Location Fields:
import UTILIZATION_PRODUCT_LOCATION__C_COUNTRY__C from "@salesforce/schema/Utilization_Product_Location__c.Country__c";
import UTILIZATION_PRODUCT_LOCATION__C_FIRST_DATE_TYPE__C from "@salesforce/schema/Utilization_Product_Location__c.First_Date_Type__c";
import UTILIZATION_PRODUCT_LOCATION__C_PRODUCT_QUANTITY__C from "@salesforce/schema/Utilization_Product_Location__c.Product_Quantity__c";
import UTILIZATION_PRODUCT_LOCATION__C_STATE__C from "@salesforce/schema/Utilization_Product_Location__c.State__c";

const UTILIZATION_REPORT_OBJECTS = [UTILIZATION_REPORT__C,
    UTILIZATION_REPORT_CONFIG__C,
    UTILIZATION_COMMERCIAL_PRODS__C,
    UTILIZATION_MANUFACTURING_COMM_PROD__C,
    UTILIZATION_LICENSEE__C,
    UTILIZATION_MANUFACTURERS__C,
    UTILIZATION_PRODUCT_LOCATION__C
];
const UTILIZATION_REPORT_FIELDS = [
    UTILIZATION_REPORT__C_LATEST_STAGE_OF_DEVELOPMENT__C,
    UTILIZATION_REPORT__C_COMMERCIALIZATION_PLAN_ID__C,
    UTILIZATION_REPORT__C_NOTES__C,
    UTILIZATION_REPORT__C_IS_US_MANUFACTURING_REQUIRED_1__C,
    UTILIZATION_REPORT__C_IS_US_MANUFACTURING_REQUIRED_2__C,
    UTILIZATION_REPORT__C_IS_US_MANUFACTURING_REQUIRED_3__C,
    UTILIZATION_REPORT__C_NEW_US_COMPANIES__C,
    UTILIZATION_REPORT__C_NEW_US_JOBS__C
];
const UTILIZATION_COMMERCIAL_PRODS_FIELDS = [
    UTILIZATION_COMMERCIAL_PRODS__C_COMMERCIAL_NAME__C,
    UTILIZATION_COMMERCIAL_PRODS__C_FDA_APPROVAL_NUMBER__C,
    UTILIZATION_COMMERCIAL_PRODS__C_FDA_APPROVAL_TYPE__C,
    UTILIZATION_COMMERCIAL_PRODS__C_GOVT_REVIEW_STATUS__C,
    UTILIZATION_COMMERCIAL_PRODS__C_PUBLIC_IND__C,
    UTILIZATION_COMMERCIAL_PRODS__C_UTILIZATION_REPORT__C
];
const UTILIZATION_LICENSEE_COUNT_FIELDS = [
    UTILIZATION_LICENSEE__C_EXCLUSIVE_COUNT__C,
    UTILIZATION_LICENSEE__C_NON_EXCLUSIVE_COUNT__C,
    UTILIZATION_LICENSEE__C_SMALL_BUSINESS__C,
    UTILIZATION_LICENSEE__C_UTILIZATION_REPORT__C
];

const UTILIZATION_PRODUCT_LOCATION_FIELDS = [
    UTILIZATION_PRODUCT_LOCATION__C_COUNTRY__C,
    UTILIZATION_PRODUCT_LOCATION__C_FIRST_DATE_TYPE__C,
    UTILIZATION_PRODUCT_LOCATION__C_PRODUCT_QUANTITY__C,
    UTILIZATION_PRODUCT_LOCATION__C_STATE__C
];


class ComplianceUtilizationReportDataService {

    static objectDescribes = [];
    static picklistValues = {};

    static allDataFetched() {
        return !!(this.picklistValues[UTILIZATION_REPORT__C.objectApiName] &&
            this.picklistValues[UTILIZATION_COMMERCIAL_PRODS__C.objectApiName] &&
            this.picklistValues[UTILIZATION_MANUFACTURING_COMM_PROD__C.objectApiName] &&
            this.picklistValues[UTILIZATION_PRODUCT_LOCATION__C.objectApiName] &&
            this.objectDescribes.length > 0);
    }

    // This method fetches the Utilization Report record from Salesforce
    static getUtilizationReport(recordId) {
        return getUtilizationReportDS({ recordId: recordId })
            .then(result => {
                console.log("Fetched Utilization Report Objects => ", JSON.parse(JSON.stringify(result)));
                return result;
            })
            .catch(error => {
                console.error("Error Fetching Utilization Report  => ", error);
                return error;
            });
    }

    // This method saves the Utilization Report record to Salesforce
    static saveUtilizationReport(record, doValidation) {
        let utilizationReportSuitcaseToSave = JSON.parse(JSON.stringify(record));
        utilizationReportSuitcaseToSave.utilizationReport = this.replaceObjectValuesWithSimpleValues(utilizationReportSuitcaseToSave.utilizationReport, UTILIZATION_REPORT__C.objectApiName);
        utilizationReportSuitcaseToSave.utilizationReportConfig = this.replaceObjectValuesWithSimpleValues(utilizationReportSuitcaseToSave.utilizationReportConfig, UTILIZATION_REPORT_CONFIG__C.objectApiName);
        utilizationReportSuitcaseToSave.commercialProds = this.replaceRelatedObjectsLListValuesWithSimpleValues(utilizationReportSuitcaseToSave.commercialProds);
        utilizationReportSuitcaseToSave.manufacturingCommProds = utilizationReportSuitcaseToSave.manufacturingCommProds?.records;
        if (utilizationReportSuitcaseToSave.manufacturingCommProdsToDelete) {
            utilizationReportSuitcaseToSave.manufacturingCommProdsToDelete = utilizationReportSuitcaseToSave.manufacturingCommProdsToDelete?.records;

            utilizationReportSuitcaseToSave.manufacturingCommProdsToDelete?.records?.forEach(manufacturingCommProduct => {
                if (manufacturingCommProduct.licenseesProducts?.length > 0) {
                    if (!manufacturingCommProduct.licenseesProductsToDelete) {
                        manufacturingCommProduct.licenseesProductsToDelete = [];
                    }
                    manufacturingCommProduct.licenseesProductsToDelete.concat(manufacturingCommProduct.licenseesProducts);
                }
                manufacturingCommProduct.licenseesProducts?.forEach(licenseeProduct => {
                    if (licenseeProduct.licenseeManufacturers?.length > 0) {
                        if (!licenseeProduct.licenseeManufacturersToDelete) {
                            licenseeProduct.licenseeManufacturersToDelete = [];
                        }
                        licenseeProduct.licenseeManufacturersToDelete?.concat(licenseeProduct.licenseeManufacturers);
                    }
                });

            });
        }
        utilizationReportSuitcaseToSave.licensees = utilizationReportSuitcaseToSave.licensees?.records;

        console.log("Utilization Report Suitcase To Save => ", JSON.parse(JSON.stringify(utilizationReportSuitcaseToSave)));
        return saveUtilizationReportDS({ utilizationReport: utilizationReportSuitcaseToSave, doValidation: doValidation })
            .then(saveResult => {
                console.log("Utilization Report Save Result => ", JSON.parse(JSON.stringify(saveResult)));
                return saveResult;
            })
            .catch(error => {
                console.error("Utilization Report Save Error => ", error);
                throw error;
            });
    }

    // This method parses the Utilization Report record objects into a suitcase object
    static parseRecordToSuitcase(record) {
        let tempUtilizationReportSuitCase = JSON.parse(JSON.stringify(record));

        // Prepare Utilization Report Suitcase:
        // TODO: Make this recursive so that related objects are also populated instead of calling each object separately
        this.populateEmptyKeys(tempUtilizationReportSuitCase.utilizationReport, UTILIZATION_REPORT_FIELDS);
        this.replaceSimpleValuesWithObject(tempUtilizationReportSuitCase.utilizationReport, UTILIZATION_REPORT__C.objectApiName);
        this.replaceSimpleValuesWithObject(tempUtilizationReportSuitCase.utilizationReportConfig, UTILIZATION_REPORT_CONFIG__C.objectApiName);

        // Populate Utilization Report Fields:
        tempUtilizationReportSuitCase.utilizationReport = this.keysToLowerCase(tempUtilizationReportSuitCase.utilizationReport);
        tempUtilizationReportSuitCase.utilizationReportConfig = this.keysToLowerCase(tempUtilizationReportSuitCase.utilizationReportConfig);
        tempUtilizationReportSuitCase.utilizationReport = this.populatePicklistValues(tempUtilizationReportSuitCase.utilizationReport, UTILIZATION_REPORT__C.objectApiName);

        // Populate related objects in suitcase
        // Utilization Commercial Prods:
        tempUtilizationReportSuitCase.commercialProds = this.replaceRelatedObjectsListValuesWithObject(tempUtilizationReportSuitCase.commercialProds);
        this.populateEmptyKeys(tempUtilizationReportSuitCase.commercialProds.objectDescribe, UTILIZATION_COMMERCIAL_PRODS_FIELDS);
        this.replaceSimpleValuesWithObject(tempUtilizationReportSuitCase.commercialProds.objectDescribe, UTILIZATION_COMMERCIAL_PRODS__C.objectApiName);
        tempUtilizationReportSuitCase.commercialProds.objectDescribe = this.populatePicklistValues(tempUtilizationReportSuitCase.commercialProds?.objectDescribe, UTILIZATION_COMMERCIAL_PRODS__C.objectApiName);

        // Licensees:
        tempUtilizationReportSuitCase.licensees = this.replaceRelatedObjectsListValuesWithObject(tempUtilizationReportSuitCase.licensees);
        this.populateEmptyKeys(tempUtilizationReportSuitCase.licensees.objectDescribe, UTILIZATION_LICENSEE_COUNT_FIELDS);
        this.replaceSimpleValuesWithObject(tempUtilizationReportSuitCase.licensees.objectDescribe, UTILIZATION_LICENSEE__C.objectApiName);
        tempUtilizationReportSuitCase.licensees.objectDescribe = this.populatePicklistValues(tempUtilizationReportSuitCase.licensees?.objectDescribe, UTILIZATION_LICENSEE__C.objectApiName);

        // Manufacturing Commercial Products:
        tempUtilizationReportSuitCase.manufacturingCommProds = {
            productLocationObjectDescribe: {},
                records: tempUtilizationReportSuitCase.manufacturingCommProds
            };
        this.populateEmptyKeys(tempUtilizationReportSuitCase.manufacturingCommProds.productLocationObjectDescribe, UTILIZATION_PRODUCT_LOCATION_FIELDS);
        this.replaceSimpleValuesWithObject(tempUtilizationReportSuitCase.manufacturingCommProds.productLocationObjectDescribe, UTILIZATION_PRODUCT_LOCATION__C.objectApiName);
        tempUtilizationReportSuitCase.manufacturingCommProds.productLocationObjectDescribe = this.populatePicklistValues(tempUtilizationReportSuitCase.manufacturingCommProds?.productLocationObjectDescribe, UTILIZATION_PRODUCT_LOCATION__C.objectApiName);


        this.addPathField(tempUtilizationReportSuitCase);

        console.log("Utilization Report Suitcase => ", JSON.parse(JSON.stringify(tempUtilizationReportSuitCase)));
        return tempUtilizationReportSuitCase;
    }

    // Helper function to replace each object's field values with simple type values so that the Apex method can parse
    // the objects
    static replaceObjectValuesWithSimpleValues(obj) {
        // Iterate over the properties of the object
        for (const key in obj) {
            if (Object.prototype.hasOwnProperty.call(obj, key)) {
                if (typeof obj[key] === "object" && obj[key] !== null && "value" in obj[key]) {
                    // Replace object with its "value" field
                    // obj[key].apiName = obj[key].value;
                    let tempKey = key;
                    obj[obj[key].apiName] = obj[key].value;
                    delete obj[tempKey];

                } else if (typeof obj[key] === "object" && obj[key] !== null) {
                    // Recursively call the function for nested objects
                    this.replaceObjectValuesWithSimpleValues(obj[key]);
                }
            }
        }
        return obj;
    }

    static replaceRelatedObjectsLListValuesWithSimpleValues(obj) {
        obj = obj.records;
        return obj;
    }

    // Helper function to get the child object name from a relationship field
    static getObjectNameFromRelationshipField(objectName, fieldRelationshipName) {
        try {
            return this.objectDescribes.find(obj => obj.apiName === objectName).childRelationships.find(field => field.relationshipName === fieldRelationshipName).childObjectApiName;
        } catch (e) {
            console.error("Error getting child object name. Forgot to import the Objects Schema?", e);
            return null;
        }
    }

    // Helper function to get the field describe for a given object's field
    // This is necessary to get the field's label, type, required and read only properties
    static getFieldDescribe(objectName, fieldName) {
        try {
            return this.objectDescribes.find(obj => obj.apiName === objectName).fields[fieldName];
        } catch (e) {
            console.error("Error getting field describe. Forgot to import the Objects Schema?", e);
            return null;
        }
    }

    // Helper function to generate a field describe object
    static generateFieldDescribeObject(objectName, fieldName, value) {
        const fieldDescribe = this.getFieldDescribe(objectName, fieldName);
        return {
            generated: true,
            value: value,
            apiName: fieldDescribe.apiName,
            label: fieldDescribe.label,
            type: fieldDescribe.dataType,
            required: fieldDescribe.required,
            readOnly: !fieldDescribe.updateable,
            length: fieldDescribe.dataType === 'Double' ? fieldDescribe.precision : fieldDescribe.length,
        };
    }

    // Helper function to populate all missing object's fields with empty keys because if a field is NULL/blank it will
    // not be returned in the initial record fetch from the getUtilizationReport method
    static populateEmptyKeys(targetObj, sourceObjFields) {
        sourceObjFields.forEach(field => {
            if (!Object.prototype.hasOwnProperty.call(targetObj, field.fieldApiName)) {
                targetObj[field.fieldApiName] = "";
            }
        })
    }

    // Helper function to replace an object's fields with an object that contains the field describe object
    static replaceSimpleValuesWithObject(obj, objectName) {
        // Helper function to check if a value is a simple type
        const isSimpleType = value => ["string", "number", "boolean"].includes(typeof value);

        // Iterate over the properties of the object
        for (const key in obj) {
            if (Object.prototype.hasOwnProperty.call(obj, key)) {
                if (isSimpleType(obj[key])) {
                    // Replace simple values with an object
                    obj[key] = this.generateFieldDescribeObject(objectName, key, obj[key]);
                } else if (typeof obj[key] === "object" && obj[key] !== null) {
                    // Determine the object name for nested objects
                    let nestedObjectName = Array.isArray(obj[key]) ? this.getObjectNameFromRelationshipField(objectName, key) : objectName;
                    // Recursively call the function for nested objects
                    this.replaceSimpleValuesWithObject(obj[key], nestedObjectName);
                }
            }
        }
        return obj;
    }

    // Helper function to replace
    static replaceRelatedObjectsListValuesWithObject(obj) {
        let tempRecordList = obj;
        obj = {
            objectDescribe: {},
            records: tempRecordList
        }

        return obj;
    }

    // Helper function to convert all object fields keys to lower case
    // This is necessary because of the way LWC handles @api properties' names' case sensitivity
    static keysToLowerCase(obj) {
        if ((typeof obj !== "object" || obj === null) || (Object.prototype.hasOwnProperty.call(obj, "generated"))) {
            return obj;
        }

        if (Array.isArray(obj)) {
            return obj.map(item => this.keysToLowerCase(item));
        }

        return Object.keys(obj).reduce((acc, key) => {
            const lowerKey = key.toLowerCase();
            acc[lowerKey] = this.keysToLowerCase(obj[key]);
            return acc;
        }, {});
    }

    // Helper function to populate allowed picklist values for picklist fields
    static populatePicklistValues(obj, objectName) {
        // Iterate over the properties of the object
        for (const key in obj) {
            if (Object.prototype.hasOwnProperty.call(obj, key)) {
                if (obj[key].type === "Picklist") {
                    // Append picklist values to the object
                    obj[key] = {
                        ...obj[key],
                        picklistValues: this.picklistValues[objectName][Object.keys(this.picklistValues[objectName]).find((field) => field.toLowerCase() === key.toLowerCase())].values
                    };
                } else if (typeof obj[key] === "object" && obj[key] !== null) {
                    // Recursively call the function for nested objects
                    this.populatePicklistValues(obj[key], objectName);
                }
            }
        }
        return obj;
    }

    // Helper function to add a field path to each field in the object
    // This is necessary to keep track of the field's path in the object in order to update the field's value
    static addPathField(obj, currentPath = '') {
        if (typeof obj !== 'object' || obj === null) {
            return;
        }

        for (const key in obj) {
            if (Object.prototype.hasOwnProperty.call(obj, key)) {
                const newPath = currentPath ? `${currentPath}.${key}` : key;
                if (typeof obj[key] === 'object' && obj[key] !== null) {
                    this.addPathField(obj[key], newPath);
                    if (Object.prototype.hasOwnProperty.call(obj[key], "generated")) {
                        obj[key].fieldPath = newPath;
                    }
                }
            }
        }
    }

    // Helper function to update a field's value in the suitcase object
    static updateValueByPath(obj, path, newValue) {
        path.split(".").reduce((acc, part) => acc && acc[part], obj).value = newValue;
    }

    static handleLatestStageOfDevelopmentChange(suitcase, newStage) {
        suitcase.utilizationReport.latest_stage_of_development__c.value = newStage;

        if (newStage === 'Not Licensed') {
            if (suitcase.utilizationReport.is_us_manufacturing_required_1__c) {
                suitcase.utilizationReport.is_us_manufacturing_required_1__c.value = null;
            }
            if (suitcase.utilizationReport.is_us_manufacturing_required_2__c) {
                suitcase.utilizationReport.is_us_manufacturing_required_2__c.value = null;
            }
            if (suitcase.utilizationReport.is_us_manufacturing_required_3__c) {
                suitcase.utilizationReport.is_us_manufacturing_required_3__c.value = null;
            }

            if (suitcase.manufacturingCommProds?.records.length > 0) {
                if (suitcase.manufacturingCommProdsToDelete?.records?.length > 0) {
                    suitcase.manufacturingCommProdsToDelete.records.concat(suitcase.manufacturingCommProds.records);
                }
                else {
                    suitcase.manufacturingCommProdsToDelete = { records : suitcase.manufacturingCommProds.records };
                }
                suitcase.manufacturingCommProds.records = [];
            }
        }
        else if (newStage === 'Licensed' || newStage === 'Commercialized') {
            if (suitcase.utilizationReport.commercialization_plan_id__c) {
                suitcase.utilizationReport.commercialization_plan_id__c.value = null;
            }

            // Clear out the manufacturing commercial products if the stage of development is changed to Licensed since
            // the questions change although the same field is used.
            if (suitcase.utilizationReport.is_us_manufacturing_required_1__c) {
                suitcase.utilizationReport.is_us_manufacturing_required_1__c.value = null;
            }
            if (suitcase.utilizationReport.is_us_manufacturing_required_2__c) {
                suitcase.utilizationReport.is_us_manufacturing_required_2__c.value = null;
            }
            if (suitcase.utilizationReport.is_us_manufacturing_required_3__c) {
                suitcase.utilizationReport.is_us_manufacturing_required_3__c.value = null;
            }

            if (newStage === 'Licensed') {
                if (suitcase.manufacturingCommProds?.records.length > 0) {
                    if (suitcase.manufacturingCommProdsToDelete?.records?.length > 0) {
                        suitcase.manufacturingCommProdsToDelete.records.concat(suitcase.manufacturingCommProds.records);
                    }
                    else {
                        suitcase.manufacturingCommProdsToDelete = { records : suitcase.manufacturingCommProds.records };
                    }
                    suitcase.manufacturingCommProds.records = [];
                }
            }
        }

        return suitcase;
    }
}

export {
    ComplianceUtilizationReportDataService,
    UTILIZATION_REPORT__C,
    UTILIZATION_REPORT_CONFIG__C,
    UTILIZATION_COMMERCIAL_PRODS__C,
    UTILIZATION_REPORT_OBJECTS,
    UTILIZATION_MANUFACTURING_COMM_PROD__C,
    UTILIZATION_LICENSEE__C,
    UTILIZATION_MANUFACTURERS__C,
    UTILIZATION_PRODUCT_LOCATION__C
};