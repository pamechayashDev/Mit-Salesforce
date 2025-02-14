import { LightningElement, api } from 'lwc';
import getCommercialInterestsByDisclosureId from '@salesforce/apex/DisclosureRecordFetch.getCommercialInterestsByDisclosureId';
import { NavigationMixin } from 'lightning/navigation';

export default class CommercialEntitiesCard extends NavigationMixin(LightningElement) {
    @api recordId;

    commercialEntity;
    loading = true;
    loadingError = false;
    noEntities = true;
    entitiesLength = '';

    async getCommercialEntities() {
        this.loading = true;
        try {
            this.loadingError = false;

            const commercialEntities = await getCommercialInterestsByDisclosureId({ disclosureId: this.recordId });
            this.entitiesLength = commercialEntities?.length;

            if (this.entitiesLength > 0) {
                this.noEntities = false;
                this.commercialEntity = commercialEntities[0];
            } 

        } catch (error) {
            this.loadingError = true;
            console.error('Error loading Commercial Entities: ' + error)
        }

        this.loading = false;
    }

    get renderDetails() {
        return !this.loading && !this.loadingError && !this.noEntities;
    }

    get commercialEntitesCount() {
        if (this.entitiesLength === 0) {
            return '(0)';
        }
        if (this.entitiesLength === 1) {
            return '(1)';
        }
        if (this.entitiesLength > 1) {
            return '(1+)';
        }
        return '';
    }

    get companyName() {
        return this.commercialEntity?.Company_Name__c || '';
    }

    get contactName() {
        return this.commercialEntity?.Contact_Name__c || '';
    }

    get contactEmail() {
        return this.commercialEntity?.Contact_Email__c || '';
    }

    connectedCallback() {
        this.getCommercialEntities();
    }

    navigateToAllCommercialEntities() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Disclosure__c',
                relationshipApiName: 'Commercial_Interests__r',
                actionName: 'view'
            },
        });
    }
}