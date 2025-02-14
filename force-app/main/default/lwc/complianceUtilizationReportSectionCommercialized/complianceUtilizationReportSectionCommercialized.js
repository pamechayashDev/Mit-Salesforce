/**
 * Created by Andreas du Preez on 2024/11/12.
 * This LWC is for the Compliance Utilization Report Commercialized Products Section.
 * This section is responsible for the Manufacturing Commercialized Products, Licensees, Manufacturers, and Locations.
 * This is a 4 level deep nested structure. The structure is as follows:
 * - Manufacturing Commercialized Products
 *  - Licensees
 *   - Manufacturers
 *    - Locations
 *  To keep track of the nested structure, each object has a localId property that is used to identify the record.
 *  This localId is sent from the HTML as a data attribute, to identify the object in the hierarchy to be inserted, edited or deleted.
 */

import { api, LightningElement, track } from "lwc";
import TIME_ZONE from "@salesforce/i18n/timeZone";
import { showConfirmationDialog } from "c/utils";

const ACTIONS = [
    { label: "Edit", name: "editLocation" },
    { label: "Delete", name: "deleteLocation" }
];
const PRODUCTLOCATIONCOLUMNS = [
    {
        label: "Country",
        fieldName: "CountryName",
        type: "Text",
        sortable: true, hideDefaultActions: true
    },
    {
        label: "State",
        fieldName: "StateName",
        type: "Text",
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    }
];
const PRODUCTLOCATIONDOECOLUMNS = [
    {
        label: "First Date of Manufacturing",
        fieldName: "First_Date__c",
        type: "date",
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            timeZone: TIME_ZONE
        },
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    },
    {
        label: "Type of Manufacturing Quantity",
        fieldName: "First_Date_Type__c",
        type: "Text",
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    },
    {
        label: "Quantity of Products Manufactured",
        fieldName: "Product_Quantity__c",
        type: "Text",
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    }
];

export default class ComplianceUtilizationReportSectionCommercialized extends LightningElement {
    @api id;
    @api utilizationReport;
    @api
    get licensees() {
        return this._licensees;
    }

    set licensees(value) {
        this._licensees = value;
        if (this._manufacturingCommProdsRecords) {
            this.populateDisplayLabels();
        }
    }

    @api
    get manufacturingCommProds() {
        return this._manufacturingCommProds;
    }

    set manufacturingCommProds(value) {
        this._manufacturingCommProdsRecords = JSON.parse(JSON.stringify(value.records));
        this.assignLocalId(this._manufacturingCommProdsRecords);
        this.activeManufacturingCommProdsSections = value.openSections;

        // Populate the display labels for the records only once
        if (Object.keys(this.countryPicklistValueMap).length === 0 || Object.keys(this.statePicklistValueMap).length) {
            this._productLocationDescribe = value.productLocationObjectDescribe;
            this.countryPicklistValueMap = this._productLocationDescribe?.Country__c?.picklistValues.reduce((ac, a) => ({
                ...ac,
                [a.value]: a.label
            }), {});
            this.statePicklistValueMap = this._productLocationDescribe?.State__c?.picklistValues.reduce((ac, a) => ({
                ...ac,
                [a.value]: a.label
            }), {});
        }

        this.populateDisplayLabels();
        this.dataHasLoaded = true;
    }

    @api readOnlyMode;
    @api allowEditMode;

    @api verifyValidity() {
        let fieldsValidity = [];
        this.template.querySelectorAll("c-compliance-utilization-report-field-input").forEach(field => {
            fieldsValidity.push(field.verifyValidity());
        });

        return fieldsValidity;
    }

    // ----------- Temp Related Objects ------------
    @track _manufacturingCommProdsRecords = [];
    _manufacturingCommProdsRecordsToDelete = [];
    _productLocationDescribe = {};
    _licensees = [];

    _tempCommProductRecord = {};
    _tempProductLicenseeRecord = {};
    _tempLicenseeManufacturerRecord = {};
    @track _tempManufacturerLocationRecord = {};

    // ----------- UI Properties ------------
    dataHasLoaded = false;
    staticTrue = true;
    staticFalse = false;
    isLoading = false;
    showCommercialProductModal = false;
    showProductLicenseeModal = false;
    showLicenseeManufacturerModal = false;
    showManufacturerLocationModal = false;
    _editCreateOrUpdate = "";
    _editProductLocalId = "";
    _editLicenseeLocalId = "";
    _editManufacturerLocalId = "";
    productLocationColumns = {};
    dropdownClickIsListening = false;
    countrySearchResults;
    stateSearchResults;
    @track countrySelectedSearchResult;
    stateSelectedSearchResult;
    countryPicklistValueMap = {};
    statePicklistValueMap = {};
    activeManufacturingCommProdsSections = [];

    // ----------- Location Table Columns ------------
    // productLocationColumns = PRODUCTLOCATIONCOLUMNS;

    connectedCallback() {
        if (this.isAgencyDOE) {
            this.productLocationColumns = [
                ...PRODUCTLOCATIONCOLUMNS,
                ...PRODUCTLOCATIONDOECOLUMNS,
                ...(this.allowEditMode ? [{ type: "action", typeAttributes: { rowActions: ACTIONS } }] : [])
            ];
        } else {
            this.productLocationColumns = [
                ...PRODUCTLOCATIONCOLUMNS,
                ...(this.allowEditMode ? [{ type: "action", typeAttributes: { rowActions: ACTIONS } }] : [])
            ];
        }
    }

    renderedCallback() {
        if (this.dropdownClickIsListening) return;

        window.addEventListener("click", (event) => {
            this.hideCountryDropdown(event);
            this.hideStateDropdown(event);
        });
        this.dropdownClickIsListening = true;
    }

    // ------------------------------
    // Getters
    // ------------------------------

    get isInputDisabled() {
        return !this.allowEditMode;
    }

    get getModalButtonLabel() {
        if (this._editCreateOrUpdate === "create") {
            return "Add";
        } else if (this._editCreateOrUpdate === "update") {
            return "Update";
        }

        return "Add";
    }

    get getLicenseeOptions() {
        return this.licensees?.records?.map(licensee => ({
            label: licensee.Licensee_Name__c,
            value: licensee.Id
        }));
    }

    get isAgencyDOE() {
        return this.utilizationReport?.funding_agency__c?.value.split(";").some((value) => value.trim() === "DOE");
    }

    get getProductModalHeader() {
        return this._editCreateOrUpdate === "create" ? "Add Manufacturing Commercial Product" : "Edit Manufacturing Commercial Product";
    }

    get getLicenseeModalHeader() {
        return this._editCreateOrUpdate === "create" ? "Add Licensee" : "Edit Licensee";
    }

    get getManufacturerModalHeader() {
        return this._editCreateOrUpdate === "create" ? "Add Manufacturer" : "Edit Manufacturer";
    }

    get getLocationModalHeader() {
        return this._editCreateOrUpdate === "create" ? "Add Location" : "Edit Location";
    }

    get countrySelectedValue() {
        return this.countrySelectedSearchResult?.label ?? null;
    }

    get stateSelectedValue() {
        return this.stateSelectedSearchResult?.label ?? null;
    }

    get isCountryUS() {
        return this._tempManufacturerLocationRecord?.Country__c === "US";
    }

    // ------------------------------
    // Event Handlers
    // ------------------------------
    handleEnableEditMode() {
        this.dispatchEvent(new CustomEvent("enableeditmode"));
    }

    handleValueChange(event) {
        // Currently, only NAICs code is being updated
        // Expand on this to update other fields as well
        let commProd = this._manufacturingCommProdsRecords?.find(record => record?.localId === event.target.dataset.productlocalid);
        commProd.commercialProd.Naics_Code__c = event.detail.value;

        this.updateUtilizationReportSuitCase();
    }

    updateUtilizationReportSuitCase() {
        this.dispatchEvent(new CustomEvent("handlereplacesuitcaseobject", {
            detail: {
                object: this._manufacturingCommProdsRecords,
                path: "manufacturingCommProds"
            }, bubbles: true, composed: false
        }));
    }

    handleSectionToggle(event) {
        this.dispatchEvent(new CustomEvent("manufacturingcommprodopensectionchange", {
            detail: {
                openSections: event.detail.openSections,
            }, bubbles: true, composed: false
        }));
    }


    // ------------------------------
    // Value Change Handlers
    // ------------------------------
    handleCommercialProductChange(event) {
        this._tempCommProductRecord.Product_Name__c = event.target.value;
        this._tempCommProductRecord.HeaderProductName = `Manufacturing Product: ${event.target.value}`;
    }

    handleNaicsCodeChange(event) {
        this._tempCommProductRecord.Naics_Code__c = event.target.value;
    }

    handleLicenseeModalSelectionChange(event) {
        this._tempProductLicenseeRecord.Licensee_Name = this.licensees.records
            ?.find(licensee => licensee.Id === event.detail.value).Licensee_Name__c;

        this._tempProductLicenseeRecord.licenseeProduct.Utilization_Licensee__c = event.detail.value;
    }

    handleManufacturerNameChange(event) {
        this._tempLicenseeManufacturerRecord.manufacturer.Manufacturer_Name__c = event.target.value;
    }

    handleManufacturerLocationCountryChange(event) {
        this._tempManufacturerLocationRecord.Country__c = event.target.value;
    }

    handleManufacturerLocationStateChange(event) {
        this._tempManufacturerLocationRecord.State__c = event.target.value;
    }

    handleManufacturerLocationFirstDateChange(event) {
        this._tempManufacturerLocationRecord.First_Date__c = event.target.value;
    }

    handleManufacturerLocationFirstDateTypeChange(event) {
        this._tempManufacturerLocationRecord.First_Date_Type__c = event.target.value;
    }

    handleManufacturerLocationProductQuantityChange(event) {
        this._tempManufacturerLocationRecord.Product_Quantity__c = event.target.value;
    }

    // ------------------------------
    // Licensee (lowes level in hierarchy) Row Action Handlers
    // ------------------------------
    async handleRowAction(event) {
        this.dispatchEvent(new CustomEvent("enableeditmode"));
        const action = event.detail.action;
        const row = event.detail.row;

        this._editProductLocalId = event.target.dataset.productlocalid;
        this._editLicenseeLocalId = event.target.dataset.licenseelocalid;
        this._editManufacturerLocalId = event.target.dataset.manufacturerlocalid;

        let tempManufacturerLocationRecord = this._manufacturingCommProdsRecords
            ?.find(record => record?.localId === this._editProductLocalId).licenseesProducts
            ?.find(licensee => licensee.localId === this._editLicenseeLocalId).licenseeManufacturers
            ?.find(manufacturer => manufacturer.localId === this._editManufacturerLocalId);

        switch (action.name) {
            case "editLocation":
                this._tempManufacturerLocationRecord = row;
                this.countrySelectedSearchResult = {
                    value: row.Country__c,
                    label: this.countryPicklistValueMap[row.Country__c]
                };
                if (Object.prototype.hasOwnProperty.call(this.statePicklistValueMap, row.State__c)) {
                    this.stateSelectedSearchResult = {
                        value: row.State__c,
                        label: this.statePicklistValueMap[row.State__c]
                    };
                } else {
                    this.stateSelectedSearchResult = {
                        value: row.State__c,
                        label: row.State__c
                    };
                }

                this._editCreateOrUpdate = "update";
                this.showManufacturerLocationModal = true;
                break;
            case "deleteLocation":
                if (await showConfirmationDialog('Confirm Delete', `Are you sure you want to delete this Location?`, 'warning')) {
                    if (row.Id) {
                        if (!tempManufacturerLocationRecord.manufacturerProductLocationsToDelete) {
                            tempManufacturerLocationRecord.manufacturerProductLocationsToDelete = [];
                        }
                        tempManufacturerLocationRecord.manufacturerProductLocationsToDelete.push(row);
                    }

                    tempManufacturerLocationRecord.manufacturerProductLocations = tempManufacturerLocationRecord.manufacturerProductLocations.filter(location => location.Id !== row.Id);

                    this.updateUtilizationReportSuitCase();
                }
                break;
            default:
        }
    }

    // ------------------------------
    // Show/Hide Modal Functions
    // ------------------------------
    handleAddCommercialProductModalCancel(event) {
        this.showCommercialProductModal = false;
        this.clearEditFields();
    }

    handleShowAddCommercialProductModal() {
        this.handleEnableEditMode();
        this._tempCommProductRecord = {
            commercialProd: {},
            licenseesProducts: []
        };
        this._editCreateOrUpdate = "create";
        this.showCommercialProductModal = true;
    }

    handleShowEditCommercialProductModal(event) {
        this.handleEnableEditMode();
        let tempRecord = this._manufacturingCommProdsRecords
            ?.find(record => record?.localId === event.target?.dataset?.localid).commercialProd;
        this._editLocalId = event.target?.dataset?.localid;
        this._tempCommProductRecord = JSON.parse(JSON.stringify(tempRecord));
        this._editCreateOrUpdate = "update";
        this.showCommercialProductModal = true;
    }

    handleShowAddLicenseeModal(event) {
        this.handleEnableEditMode();
        this._editProductLocalId = event.target?.dataset?.productlocalid;
        this._tempProductLicenseeRecord = {
            Licensee_Name: "",
            licenseeProduct: {},
            licenseeManufacturers: []
        };
        this._editCreateOrUpdate = "create";
        this.showProductLicenseeModal = true;
    }

    handleShowAddLicenseeManufacturerModal(event) {
        this.handleEnableEditMode();
        this._editProductLocalId = event.target?.dataset?.productlocalid;
        this._editLicenseeLocalId = event.target?.dataset?.licenseelocalid;
        this._tempLicenseeManufacturerRecord = {
            manufacturer: {},
            manufacturerProductLocations: []
        };
        this._editCreateOrUpdate = "create";
        this.showLicenseeManufacturerModal = true;
    }

    handleShowAddManufacturerLocationModal(event) {
        this.handleEnableEditMode();
        this._editProductLocalId = event.target?.dataset?.productlocalid;
        this._editLicenseeLocalId = event.target?.dataset?.licenseelocalid;
        this._editManufacturerLocalId = event.target?.dataset?.manufacturerlocalid;

        this._tempLicenseeManufacturerRecord = {
            Country__c: "",
            State__c: "",
            First_Date__c: "",
            First_Date_Type__c: "",
            Product_Quantity__c: ""
        };
        this._editCreateOrUpdate = "create";
        this.showManufacturerLocationModal = true;
    }

    handleShowEditLicenseeModal(event) {
        this.handleEnableEditMode();
        this._editProductLocalId = event.target?.dataset?.licenseelocalid;

        this._tempProductLicenseeRecord = this._manufacturingCommProdsRecords
            ?.find(record => record?.localId === event.target?.dataset?.productlocalid).licenseesProducts
            ?.find(licensee => licensee.localId === event.target?.dataset?.licenseelocalid);

        this._editCreateOrUpdate = "update";
        this.showProductLicenseeModal = true;
    }

    handleShowEditLicenseeManufacturerModal(event) {
        this.handleEnableEditMode();
        this._editProductLocalId = event.target?.dataset?.productlocalid;
        this._editLicenseeLocalId = event.target?.dataset?.licenseelocalid;
        this._editManufacturerLocalId = event.target?.dataset?.manufacturerlocalid;

        this._tempLicenseeManufacturerRecord = this._manufacturingCommProdsRecords
            ?.find(record => record?.localId === this._editProductLocalId).licenseesProducts
            ?.find(licensee => licensee.localId === this._editLicenseeLocalId).licenseeManufacturers
            ?.find(manufacturer => manufacturer.localId === this._editManufacturerLocalId);

        this._editCreateOrUpdate = "update";
        this.showLicenseeManufacturerModal = true;
    }

    handleAddProductLicenseeModalCancel(event) {
        this.showProductLicenseeModal = false;
        this.clearEditFields();
    }

    handleAddLicenseeManufacturerModalCancel(event) {
        this.showLicenseeManufacturerModal = false;
        this.clearEditFields();
    }

    handleAddManufacturerLocationCancel(event) {
        this.showManufacturerLocationModal = false;
        this.clearEditFields();
    }

    // ------------------------------
    // Modal Add/Edit Record Handlers
    // ------------------------------
    handleAddEditCommercialProduct(event) {
        let nameInput = this.template.querySelector(".product-name-input");
        let inputValid = true;

        if (this._tempCommProductRecord?.Product_Name__c === undefined || this._tempCommProductRecord?.Product_Name__c?.trim() === "") {
            nameInput.reportValidity();
            inputValid = false;
        }

        // Check if the Product Name is unique
        let nameInputUnique = true;
        this._manufacturingCommProdsRecords.forEach(record => {
            if (this._editCreateOrUpdate === "create") {
                if (record.commercialProd.Product_Name__c?.trim() === this._tempCommProductRecord?.Product_Name__c?.trim()) {
                    nameInputUnique = false;
                }
            }
            else {
                if (record.commercialProd.Product_Name__c?.trim() === this._tempCommProductRecord?.Product_Name__c?.trim() && record.localId !== this._editLocalId) {
                    nameInputUnique = false;
                }
            }
        });

        if (!nameInputUnique) {
            nameInput.setCustomValidity("Product Name already exists.");
            inputValid = false;
        } else {
            nameInput.setCustomValidity("");
        }

        if (!inputValid) {
            nameInput.reportValidity();
        }


        // If the input is valid, add the new record to the list
        if (inputValid) {
            if (this._editCreateOrUpdate === "create") {
                let tempNewRecord = {
                    commercialProd: {
                        Product_Name__c: this._tempCommProductRecord.Product_Name__c.trim(),
                        HeaderProductName: this._tempCommProductRecord.HeaderProductName.trim(),
                        Naics_Code__c: this._tempCommProductRecord.Naics_Code__c,
                        Utilization_Report__c: this.utilizationReport.id.value
                    },
                    licenseesProducts: [],
                    localId: Math.random().toString(36).substring(7)
                };
                this._manufacturingCommProdsRecords.push(tempNewRecord);
            }
            else {
                let tempRecord = this._manufacturingCommProdsRecords.find(record => record.localId === this._editLocalId);
                tempRecord.commercialProd.Product_Name__c = this._tempCommProductRecord.Product_Name__c.trim();
                tempRecord.commercialProd.HeaderProductName = this._tempCommProductRecord.HeaderProductName.trim();
                tempRecord.commercialProd.Naics_Code__c = this._tempCommProductRecord.Naics_Code__c
            }

            // Send the updated records to the parent to update the suitcase
            this.updateUtilizationReportSuitCase();
            this.clearEditFields();
            this.showCommercialProductModal = false;
        }
    }

    handleAddEditProductLicensee(event) {
        let inputValid = [...this.template.querySelectorAll(".licensee-modal-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);

        if (inputValid) {
            if (this._editCreateOrUpdate === "create") {
                this._tempProductLicenseeRecord.licenseeManufacturers = [];
                this._tempProductLicenseeRecord.localId = Math.random().toString(36).substring(7);

                this._manufacturingCommProdsRecords
                    ?.find(licensee => licensee.localId === this._editProductLocalId).licenseesProducts
                    ?.push(this._tempProductLicenseeRecord);
            }

            // Send the updated records to the parent to update the suitcase
            this.updateUtilizationReportSuitCase();
            this.clearEditFields();
            this.showProductLicenseeModal = false;
        }
    }

    handleAddEditLicenseeManufacturer(event) {
        let inputValid = [...this.template.querySelectorAll(".manufacturer-modal-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);

        if (inputValid) {
            if (this._editCreateOrUpdate === "create") {
                this._tempLicenseeManufacturerRecord.manufacturerProductLocations = [];
                this._tempLicenseeManufacturerRecord.localId = Math.random().toString(36).substring(7);

                this._manufacturingCommProdsRecords
                    ?.find(licensee => licensee.localId === this._editProductLocalId).licenseesProducts
                    ?.find(licensee => licensee.localId === this._editLicenseeLocalId).licenseeManufacturers
                    ?.push(this._tempLicenseeManufacturerRecord);
            }

            // Send the updated records to the parent to update the suitcase
            this.updateUtilizationReportSuitCase();
            this.clearEditFields();
            this.showLicenseeManufacturerModal = false;
        }
    }

    handleAddEditManufacturerLocation(event) {
        if (this.validateLocationFields()) {
            const manufacturer = this._manufacturingCommProdsRecords
                ?.find(product => product.localId === this._editProductLocalId).licenseesProducts
                ?.find(licensee => licensee.localId === this._editLicenseeLocalId).licenseeManufacturers
                ?.find(manufacturerRecord => manufacturerRecord.localId === this._editManufacturerLocalId);

            if (this._editCreateOrUpdate === "create") {
                this._tempManufacturerLocationRecord.Utilization_Manufacturer__c = manufacturer?.manufacturer.Id;
                this._tempManufacturerLocationRecord.CountryName = this.countryPicklistValueMap[this._tempManufacturerLocationRecord.Country__c] ?? this._tempManufacturerLocationRecord.Country__c;
                this._tempManufacturerLocationRecord.StateName = this.statePicklistValueMap[this._tempManufacturerLocationRecord.State__c] ?? this._tempManufacturerLocationRecord.State__c;
                this._tempManufacturerLocationRecord.localId = Math.random().toString(36).substring(7);
                manufacturer.manufacturerProductLocations = [
                    ...manufacturer.manufacturerProductLocations,
                    this._tempManufacturerLocationRecord
                ];
            } else if (this._editCreateOrUpdate === "update") {
                this._tempManufacturerLocationRecord.CountryName = this.countryPicklistValueMap[this._tempManufacturerLocationRecord.Country__c] ?? this._tempManufacturerLocationRecord.Country__c;
                this._tempManufacturerLocationRecord.StateName = this.statePicklistValueMap[this._tempManufacturerLocationRecord.State__c] ?? this._tempManufacturerLocationRecord.State__c;

                manufacturer.manufacturerProductLocations = [
                    ...manufacturer.manufacturerProductLocations
                ];
            }

            // Send the updated records to the parent to update the suitcase
            this.updateUtilizationReportSuitCase();
            this.clearEditFields();
            this.showManufacturerLocationModal = false;
        }
    }

    validateLocationFields() {
        let fieldsValidity = [];
        this.template.querySelectorAll(".location-modal-input-field").forEach(field => {
            fieldsValidity.push(field.reportValidity());
        });

        // If Country is US, then a valid State needs to be selected:
        if (this._tempManufacturerLocationRecord.Country__c === 'US') {
            let stateInput = this.template.querySelector(".state-input");

            if (!this.statePicklistValueMap[this._tempManufacturerLocationRecord.State__c]) {
                stateInput.setCustomValidity("Invalid State for Country US.");
                fieldsValidity.push(stateInput.reportValidity());
            }
            else {
                stateInput.setCustomValidity('');
                fieldsValidity.push(stateInput.reportValidity());
            }
        }
        return !fieldsValidity.includes(false);
    }

    // ------------------------------
    // Delete Record Handlers
    // ------------------------------
    async handleDeleteCommercialProduct(event) {
        let productLocalId = event.target.dataset.productlocalid;
        this.commercialProdToDelete = this._manufacturingCommProdsRecords
            ?.find(record => record.localId === productLocalId);

        if (await showConfirmationDialog('Confirm Delete', `Are you sure you want to delete Manufacturing Product "${this.commercialProdToDelete.commercialProd.Product_Name__c}"?`, 'warning')) {
            this.handleEnableEditMode();

            this._manufacturingCommProdsRecordsToDelete
                ?.push(this.commercialProdToDelete);
            this._manufacturingCommProdsRecords = this._manufacturingCommProdsRecords
                ?.filter(record => record.localId !== productLocalId);

            // Send the Suitcase without the deleted records to the parent
            this.updateUtilizationReportSuitCase();

            // Send the deleted Manufacturing Commercial Product to the parent
            this.dispatchEvent(new CustomEvent("handlereplacesuitcaseobject", {
                detail: {
                    object: this._manufacturingCommProdsRecordsToDelete,
                    path: "manufacturingCommProdsToDelete"
                }, bubbles: true, composed: false
            }));
        }
    }

    async handleDeleteLicensee(event) {
        let productLocalId = event.target.dataset.productlocalid;
        let parentRecord = this._manufacturingCommProdsRecords?.find(record => record?.localId === productLocalId);
        let licenseeLocalId = event.target.dataset.licenseelocalid;
        let licenseeRecord = parentRecord.licenseesProducts.find(licensee => licensee.localId === licenseeLocalId);

        if (await showConfirmationDialog('Confirm Delete', `Are you sure you want to remove Licensee "${licenseeRecord.Licensee_Name}" from Product "${parentRecord.commercialProd.Product_Name__c}"?`, 'warning')) {
            this.handleEnableEditMode();

            if (!parentRecord.licenseesProductsToDelete) {
                parentRecord.licenseesProductsToDelete = [];
            }
            parentRecord.licenseesProductsToDelete?.push(licenseeRecord);
            parentRecord.licenseesProducts = parentRecord.licenseesProducts.filter(licensee => licensee.localId !== licenseeLocalId);

            // Send the updated records to the parent to update the suitcase
            this.updateUtilizationReportSuitCase();
        }
    }

    async handleDeleteManufacturer(event) {
        let productLocalId = event.target.dataset.productlocalid;
        let licenseeLocalId = event.target.dataset.licenseelocalid;
        let manufacturerLocalId = event.target.dataset.manufacturerlocalid;

        let parentRecord = this._manufacturingCommProdsRecords
            ?.find(record => record?.localId === productLocalId).licenseesProducts
            ?.find(licensee => licensee.localId === licenseeLocalId);
        let manufacturerRecord = parentRecord.licenseeManufacturers.find(manufacturer => manufacturer.localId === manufacturerLocalId);

        if (await showConfirmationDialog('Confirm Delete', `Are you sure you want to delete Manufacturer "${manufacturerRecord.manufacturer.Manufacturer_Name__c}" from Licensee "${parentRecord.Licensee_Name}"?`, 'warning')) {
            this.handleEnableEditMode();
            if (!parentRecord.licenseeManufacturersToDelete) {
                parentRecord.licenseeManufacturersToDelete = [];
            }
            parentRecord.licenseeManufacturersToDelete.push(manufacturerRecord);
            parentRecord.licenseeManufacturers = parentRecord.licenseeManufacturers.filter(manufacturer => manufacturer.localId !== manufacturerLocalId);

            // Send the updated records to the parent to update the suitcase
            this.updateUtilizationReportSuitCase();
        }
    }


    // ------------------------------
    // Helper Methods
    // ------------------------------
    clearEditFields() {
        this._tempCommProductRecord = {};
        this._tempProductLicenseeRecord = {};
        this._tempLicenseeManufacturerRecord = {};
        this._tempManufacturerLocationRecord = {};
        this.countrySelectedSearchResult = null;
        this.stateSelectedSearchResult = null;
        this._editCreateOrUpdate = "";
        this._editProductLocalId = "";
        this._editLicenseeLocalId = "";
        this._editManufacturerLocalId = "";
    }

    validateFields() {
        return [...this.template.querySelectorAll(".input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);
    }

    assignLocalId(obj) {
        if (Array.isArray(obj)) {
            obj.forEach(item => this.assignLocalId(item));
        } else if (typeof obj === "object" && obj !== null) {
            obj.localId = Math.random().toString(36).substring(7);
            for (const key in obj) {
                if (Object.prototype.hasOwnProperty.call(obj, key)) {
                    this.assignLocalId(obj[key]);
                }
            }
        }
    }

    populateDisplayLabels() {
        this._manufacturingCommProdsRecords.forEach(commProduct => {
            commProduct.commercialProd.HeaderProductName = `Manufacturing Product: ${commProduct.commercialProd.Product_Name__c}`;

            commProduct?.licenseesProducts?.forEach(licensee => {
                licensee.Licensee_Name = this.licensees?.records
                    ?.find(licenseeCount => licenseeCount.Id === licensee.licenseeProduct?.Utilization_Licensee__c).Licensee_Name__c;

                licensee.licenseeManufacturers.forEach(manufacturer => {
                    manufacturer.manufacturerProductLocations.forEach(location => {
                        location.CountryName = this.countryPicklistValueMap[location.Country__c] ?? location.Country__c;
                        location.StateName = this.statePicklistValueMap[location.State__c] ?? location.State__c;
                    })
                });
            });
        });
    }

    /**
     * This function compares the name of the component (`cmpName`) with the name of the clicked element (`clickedElementSrcName`).
     * If the clicked element is outside the component, the dropdown (search results) is hidden by calling `clearSearchResults()`.
     *
     * - `cmpName` is the tag name of the host element of this component (e.g., 'C-SEARCHABLE-COMBOBOX').
     * - `clickedElementSrcName` is the tag name of the element that was clicked on the page.
     * - `isClickedOutside` is a boolean that is true if the clicked element is outside the component.
     */
    hideCountryDropdown(event) {
        const cmpName = this.template.host.tagName;
        const clickedElementSrcName = event.target.tagName;
        const isClickedOutside = cmpName !== clickedElementSrcName;
        if (this.countrySearchResults && isClickedOutside) {
            this.clearCountrySearchResults();
        }
    }

    hideStateDropdown(event) {
        const cmpName = this.template.host.tagName;
        const clickedElementSrcName = event.target.tagName;
        const isClickedOutside = cmpName !== clickedElementSrcName;
        if (this.stateSearchResults && isClickedOutside) {
            this.clearStateSearchResults();
        }
    }

    countrySearch(event) {
        const input = event.detail.value.toLowerCase();
        this.countrySearchResults = this._productLocationDescribe.Country__c.picklistValues.filter((pickListOption) =>
            pickListOption.label.toLowerCase().includes(input)
        );
    }

    stateSearch(event) {
        const input = event.detail.value.toLowerCase();
        this.stateSearchResults = this._productLocationDescribe.State__c.picklistValues.filter((pickListOption) =>
            pickListOption.label.toLowerCase().includes(input)
        );
        this._tempManufacturerLocationRecord.State__c = '';
    }

    selectCountrySearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;
        this.countrySelectedSearchResult = this.countrySearchResults.find(
            (pickListOption) => pickListOption.value === selectedValue
        );
        this._tempManufacturerLocationRecord.Country__c = this.countrySelectedSearchResult.value;
    }

    selectStateSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;
        this.stateSelectedSearchResult = this.stateSearchResults.find(
            (pickListOption) => pickListOption.value === selectedValue
        );
        this._tempManufacturerLocationRecord.State__c = this.stateSelectedSearchResult.value;
        this.clearStateSearchResults();
    }

    clearCountrySearchResults() {
        this.countrySearchResults = null;
    }

    clearStateSearchResults() {
        this.stateSearchResults = null;
    }
}