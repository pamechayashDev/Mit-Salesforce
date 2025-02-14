import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getAntibodyApplicationsPicklist from '@salesforce/apex/DisclosureRecordFetch.getAntibodyApplicationsPicklist';
import getAntibodyByBioTangId from '@salesforce/apex/DisclosureRecordFetch.getAntibodyByBioTangId';
import { getBioTangData } from 'c/utils';

import { DISCLOSURE_FIELDS, DOCUMENT_CLASSIFICATIONS } from 'c/utils';
import getMouseStrainByBioTangId from "@salesforce/apex/DisclosureRecordFetch.getMouseStrainByBioTangId"

import Disclosure_Documents_Header_PublicationsManuscripts from '@salesforce/label/c.Disclosure_Documents_Header_PublicationsManuscripts';

export default class BioTangDetailsTab extends NavigationMixin(LightningElement) {
    @api recordId;

    disclosureData;
    @track recordData;

    CLABEL__PubMan = Disclosure_Documents_Header_PublicationsManuscripts;

    //stores the data for the related info for the antibody
    antibodyDetails = {};
    //stores the picklist values for the antibody applications
    antibodyValidAppPicklist = {};
    //stores the list of all the applications that are picked for the antibody
    antibodyValidApplications = [];

    //this stores a list of all the applications that are picked for the antibody
    //stores the key for it and then if it is checked or not
    generatedList = [];

    maintenanceAndBreeding = ''

    hasShipper = false;
    loadingShipper = true;
    loadingAntibodyDetails = true;

    get allAccordionSections() {
        return [
            'antobodyValidations',
            this.recordData.RecordType.DeveloperName,
            'distributionShipping',
        ]
    }

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        // this.reset();
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);

            this.disclosureData = data;
            this.recordData = await getBioTangData(this.recordId);

            if (this.recordData.RecordType.DeveloperName === 'mouseStrain') {
                this.getMouseStrainDetails();
            }

            if (this.isAntibody) {
                this.fetchAntiBodyDetails();
            }

            if (this.recordData.MIT_Shipper_Acc__r) {
                this.hasShipper = true;
            } else if (this.recordData.MIT_Shipper_Acc__r === undefined) {
                this.hasShipper = false;
            }

            this.loadingShipper = false;

        } else if (error) {
            console.log(error)
            console.log(error.body.message)
        }
    }

    getMouseStrainDetails() {
        getMouseStrainByBioTangId({ biotangId: this.recordData.Id }).then(result => {
            if (result.length > 0) {
                this.maintenanceAndBreeding = result[0].maintenanceAndBreeding__c;
            }
        }).catch(error => {
            console.error(error);
        }
        )
    }

    get displayRecordName() {
        return `${this.recordData.RecordType.Name} Details`;
    }

    get isMouseStrain() {
        return this.recordData.RecordType.DeveloperName === "mouseStrain";
    }

    get isAntibody() {
        return this.recordData.RecordType.DeveloperName === "antibody";
    }

    get isCellLine() {
        return this.recordData.RecordType.DeveloperName === "cellLine";
    }

    get documentQueryType() {
        return DOCUMENT_CLASSIFICATIONS.PUBLICATION_MANUSCRIPTS;
    }

    get docCardTitle() {
        return this.CLABEL__PubMan;
    }

    async fetchAntiBodyDetails() {
        this.loadingAntibodyDetails = true;
        try {
            const response = await getAntibodyByBioTangId({ biotangId: this.recordData.Id });
            if (response.length > 0) {
                this.antibodyDetails = response[0];

                //this function retrieves the picklist values for the antibody applications
                const picklistValues = await getAntibodyApplicationsPicklist();
                this.antibodyValidAppPicklist = picklistValues;

                //this data is retrieved as a string with ; as the delimiter
                //we split it and store it as an array
                this.antibodyValidApplications = this.antibodyDetails.antibodyValidApplications__c.split(';');

                //now we generate the object that is necessary to pass to the HTML that generates the respective checked items
                this.compareLists(Object.keys(picklistValues), this.antibodyValidApplications);
            }

        } catch (error) {
            console.log(error);
        }
        this.loadingAntibodyDetails = false;
    }

    //this function generates an object of arrays that contains the key and if it is checked or not
    compareLists(fullList, checkList) {
        const list = fullList.map(key => ({ key, value: checkList.includes(key) }));
        this.generatedList = list;
    }

    //this function conditionally renders the antibody Other details section
    get renderAntibodyOtherDetails() {
        if (!this.antibodyDetails?.antibodyValidApplications__c) return false;
        if (this.antibodyDetails?.antibodyValidApplications__c.includes('Other')) return true;
        return false;
    }

    get antibodyOtherDetails() {
        return this.antibodyDetails?.antibodyValidAppOther__c || '';
    }

    navigateToShipperDetails(event) {
        event.preventDefault();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordData.MIT_Shipper_Acc__r.Id,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }
}