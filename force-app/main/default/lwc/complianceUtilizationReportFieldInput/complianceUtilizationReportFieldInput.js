/**
 * Created by Andreas du Preez on 2024/10/24.
 * This LWC is a reusable component that is used to display a single field of any type, and allow input for the
 * Compliance Utilization Report.
 * It uses @api composition to accept all the required fields for it to function, ideally by using the lwc:spread
 * attribute on the parent. It uses events to communicate with the parent.
 *
 * The component also exposes override properties to allow the parent to override the properties of default field
 * describe properties, for instance the Label field.
 *
 * No business logic should be implemented in this component.
 */

import { api, LightningElement, track } from "lwc";
import TIME_ZONE from "@salesforce/i18n/timeZone";

export default class ComplianceUtilizationReportFieldInput extends LightningElement {

    // Properties
    _label;
    _type;
    @track _value;
    _apiName;
    _readOnly;
    _required;
    _length = 255;
    _picklistValues;
    _fieldPath = '';

    @api
    get label() {
        return this.labelOverride ?? this._label;
    }

    set label(value) {
        this._label = value;
    }

    @api
    get type() {
        return this.typeOverride ?? this._type;
    }

    set type(value) {
        this._type = value;
    }

    @api
    get value() {
        return this.valueOverride ?? this._value;
    }

    set value(value) {
        this._value = value;
    }

    @api
    get apiName() {
        return this.apiNameOverride ?? this._apiName;
    }

    set apiName(value) {
        this._apiName = value;
    }

    @api
    get readOnly() {
        return this.readOnlyOverride ?? this._readOnly;
    }

    set readOnly(value) {
        this._readOnly = value;
    }

    @api
    get required() {
        return this.requiredOverride ?? this._required;
    }

    set required(value) {
        this._required = value;
    }

    @api
    get length() {
        return this.lengthOverride ?? this._length;
    }

    set length(value) {
        this._length = value;
    }

    @api
    get picklistValues() {
        return this.picklistOptionsOverride ?? this._picklistValues;
    }

    set picklistValues(value) {
        this._picklistValues = value;
    }

    @api
    get fieldPath() {
        return this._fieldPath;
    }

    set fieldPath(value) {
        this._fieldPath = value;
    }

    @api readOnlyMode;
    @api labelOverride;
    @api typeOverride;
    @api valueOverride;
    @api apiNameOverride;
    @api readOnlyOverride;
    @api requiredOverride;
    @api lengthOverride;
    @api picklistOptionsOverride;

    @api verifyValidity() {
        return this.readOnly || this.validateFields();
    }

    timeZone = TIME_ZONE;
    ampm = true;
    searchTimer;

    get isStringValue() {
        return this.type === "String";
    }

    get isDateTimeValue() {
        return this.type === "DateTime";
    }

    get isDateValue() {
        return this.type === "Date";
    }

    get isPicklistValue() {
        return this.type === "Picklist";
    }

    get isTextAreaValue() {
        return this.type === "TextArea";
    }

    get isNumber() {
        return this.type === "Double";
    }

    get isEditable() {
        return !this.readOnly;
    }

    get picklistValueLabel() {
        return this._picklistValues.find(picklistValue => picklistValue.value === this.value)?.label;
    }

    validateFields() {
        return [...this.template.querySelectorAll(".input-field")].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
        }, true);
    }

    // Event Handlers:
    handleEnableEditMode() {
        this.dispatchEvent(new CustomEvent("enableeditmode"));
    }

    handleValueChange(event) {
        this._value = event.target.value;

        // If the field is a String or TextArea, we want to debounce the value change event
        if (['String', 'TextArea', 'Double'].includes(this.type)) {
            this.debounce(() => {
                    this.dispatchEvent(new CustomEvent("valuechange", {
                        detail: {
                            value: this._value,
                            fieldPath: this.fieldPath
                        }, bubbles: false, composed: false
                    }));
                },
                200);
        }
        else {
            // If the field is not a String or TextArea, we want to dispatch the value change event immediately
            this.dispatchEvent(new CustomEvent("valuechange", {
                detail: {
                    value: this._value,
                    fieldPath: this.fieldPath
                }, bubbles: false, composed: false
            }));
        }
    }

    debounce(fn, wait) {
        clearTimeout(this.searchTimer);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchTimer = setTimeout(fn, wait);
    }
}