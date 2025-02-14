import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getFilesByTypeAndClassification from '@salesforce/apex/FileRepository.getFilesByTypeAndClassification';
import getFileContentVersionsByEntityRecId from '@salesforce/apex/FileRepository.getFileContentVersionsByEntityRecId';
import { getRecord } from 'lightning/uiRecordApi';
import { determineFilterTypeByDocQueryType } from 'c/utils';
import { getDocumentFieldsByRecordTypeAndClassification, getDocumentEntityIdFieldByRecordTypeAndClassification, isEntityIdDocumentByRecordType } from 'c/utils';
import { DOCUMENT_CLASSIFICATIONS, DOCUMENT_FOR_RECORDTYPE } from 'c/utils';
import getThirdPartyCodeFilesByDisclosureId from '@salesforce/apex/FileRepository.getThirdPartyCodeFilesByDisclosureId';
import getThirdPartyContentFilesByDisclosureId from '@salesforce/apex/FileRepository.getThirdPartyContentFilesByDisclosureId';

/**
 * @description This component is used to display the documents associated with a disclosure record.
 * @property {object} disclosureData - The disclosure record data.
 * @property {object} recordData - The record data.
 * @property {string} recordId - The record id.
 * @property {string} documentCardTitle - The title of the document card that is passed through as a html attribute into the component.
 * @property {string} documentQueryType - The document query type that is passed through as a html attribute into the component. This is used to determine which documents to query for. 
 * NOTE: This is based on the values available in the picklist for [Content Version > Document Classification > Picklist Values] in the Object Manager
 * @property {string} recordSubType - The record subtype that is passed through as a html attribute into the component. This is used to determine which child documents to query for
 * NOTE: This is based on the values available in the picklist for [Content Version >  Subtype > Picklist Values] in the Object Manager
 */
export default class DisclosureDocument extends NavigationMixin(LightningElement) {
    @api disclosureData;
    @api recordData;
    @api recordId;
    @api documentCardTitle;
    @api documentQueryType;
    @api parentRecordType;

    disclosureDataFetch = {};

    fileSet = [];
    fileSetCount = '';

    error = false;
    errorMessage = '';

    loading = false;
    noResults = false;
    entityRecId;

    get fields() {
        console.debug('this.parentRecordType', this.parentRecordType)

        return getDocumentFieldsByRecordTypeAndClassification(this.parentRecordType, this.documentQueryType)
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    async handleDisclosure({ error, data }) {
        console.debug('disclosureDocument:handleDisclosure:recordId', this.recordId)
        console.debug('disclosureDocument:handleDisclosure:data', data)
        if (data) {
            this.recordName = data.fields?.Name__c?.value ?? 'Unknown';
            this.entityRecId = getDocumentEntityIdFieldByRecordTypeAndClassification(this.parentRecordType, this.documentQueryType, data);
            if(!this.loading) {
                await this.getFilesForCard()
            }
        } else if (error) {
            console.log(error)
            console.log(error.body.messsage)
        }

    }

    //this determines the record id to query for based on the type of record we are viewing
    determineCollectionId() {
        console.debug('this.disclosureData', this.disclosureData)
        if (this.disclosureData?.apiName === 'Disclosure__c') {
            return this.disclosureData.id
        } else if (!this.disclosureData && this.parentRecordType === 'Disclosure') {
            return this.recordId
        }
        return ''
    }

    //This function helps to determine which set of documents we have to query for.
    //NOTE: This is determined by the Record Types available for the Content Version object.
    determineFileCollection() {
        if (this.disclosureData?.apiName === 'Disclosure__c' || this.parentRecordType === 'Disclosure') {
            return 'Disclosure'
        }
        return this.parentRecordType
    }

    getFilesForCard = async () => {
        this.loading = true;
        this.error = false;
        this.fileSet = [];

        try {

            console.debug('this.documentQueryType', this.documentQueryType)
            console.debug('this.recordId', this.recordId)
            console.debug('this.entityRecId', this.entityRecId)


            if (isEntityIdDocumentByRecordType(this.parentRecordType)) {
                this.fileSet = await getFileContentVersionsByEntityRecId({ entityRecId: this.entityRecId, recordType: this.determineFileCollection(), recordClassification: this.documentQueryType });
            } else if (this.documentQueryType === DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_CODE) {
                this.fileSet = await getThirdPartyCodeFilesByDisclosureId({ disclosureId: this.determineCollectionId() });
            } else if (

                this.documentQueryType === DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_AGREEMENTS
            ) {
                this.fileSet = await getThirdPartyContentFilesByDisclosureId({ disclosureId: this.determineCollectionId() });
            }
            else {
                this.fileSet = await getFilesByTypeAndClassification({ linkedRecId: this.determineCollectionId(), recordType: this.determineFileCollection(), recordClassification: this.documentQueryType });

            }

            this.loading = false;
            this.error = false;

            if (!this.fileSet || this.fileSet.length <= 0) {
                this.noResults = true;
                this.fileSetCount = 0;
                return;
            }
            if (this.fileSet.length > 0) {
                this.fileSetCount = this.fileSet.length > 2 ? '2+' : this.fileSet.length;
                this.fileSet = this.fileSet.slice(0, 2);
                this.noResults = false;
            }

        } catch (error) {
            console.error(error);
            this.error = true;
            this.errorMessage = 'Unable to retrieve files';
            this.loading = false;
        }
    }

    get cardHeaderIcon() {
        if (this.documentQueryType === DOCUMENT_CLASSIFICATIONS.SOFTWARE_CODE || this.documentQueryType === DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_CODE) {
            return 'standard:code_playground'
        }
        return 'standard:document'
    }

    determineCaseTypeEnumDisplay() {
        if (!this.disclosureData) return this.documentQueryType ?? '';
        if (this.disclosureData) {
            switch (this.disclosureData.fields.RecordType.value.fields.DeveloperName.value) {
                case 'BioTang_Disclosure':
                    return DOCUMENT_FOR_RECORDTYPE.BIO_TANG;
                case 'Software_Code_Disclosure':
                    return DOCUMENT_FOR_RECORDTYPE.SOFTWARE_CODE;
                case 'Copyright_Disclosure':
                    return DOCUMENT_FOR_RECORDTYPE.COPYRIGHT;
                case 'Invention_Disclosure':
                    return DOCUMENT_FOR_RECORDTYPE.INVENTION;
                default:
                    return '';
            }
        }
        return this.documentQueryType ?? ''
    }

    navigateToAllFiles() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'All_Documents'
            },
            state: {
                c__id: this.disclosureData ? this.disclosureData.id : this.recordId,
                c__f: determineFilterTypeByDocQueryType(this.documentQueryType),
                c__o: this.disclosureData ? 'Disclosure' :this.parentRecordType,
                c__t: this.determineCaseTypeEnumDisplay()
            }
        });
    }

    connectedCallback() {
        if(this.disclosureData) {
            this.getFilesForCard()
        }
    }
}