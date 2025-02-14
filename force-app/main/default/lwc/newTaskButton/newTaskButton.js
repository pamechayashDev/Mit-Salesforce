import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getContainerObjectId from '@salesforce/apex/ExternalObjectRepository.getContainerObjectId'

export default class NewTaskButton extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;

    @api externalObjRecIdFieldName;
    @api matchingContainerObject;
    @api containerObjRecIdFieldName;

    containerObjectId;
    loading = true;
    
    @wire(getContainerObjectId, {
        externalObjRecId: '$recordId',
        externalObjApiName: '$objectApiName',
        externalObjRecIdFieldName: '$externalObjRecIdFieldName',
        matchingContainerObject: '$matchingContainerObject',
        containerObjRecIdFieldName:'$containerObjRecIdFieldName'
    })
    async handleLoadData({data, error}) {
        if (data) {
            this.containerObjectId = data.Id;
            this.loading = false;
        }
        if (error) {
            console.error(error);
        }
    }

    // https://sfwiseguys.wordpress.com/2020/11/15/lwc-navigation/
    // https://developer.salesforce.com/docs/platform/lwc/guide/use-navigate-page-types.html
    // https://developer.salesforce.com/docs/platform/lwc/guide/use-navigate.html
    // https://medium.com/@sendtosachin27/navigation-in-lwc-34c58c3eb5c4
    

    // https://www.linkedin.com/pulse/invoking-standardcustom-quick-actionsaction-layout-editor-godara/
    async handleNewTaskQuickAction() {
        const defaultValues = encodeDefaultFieldValues({
            Status: 'Not Started',
            Normal: 'Normal'
        });
        
        this[NavigationMixin.Navigate]({
            type: "standard__quickAction",
            attributes: {
                apiName: 'Global.NewTaskTwo'
            },
            state: {
                objectApiName: this.matchingContainerObject,
                recordId: this.containerObjectId,
                defaultFieldValues: defaultValues
            }
        });
    }
}