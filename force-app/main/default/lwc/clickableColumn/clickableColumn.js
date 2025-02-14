import { LightningElement, track, wire,api } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import columnClickMessageChannel from '@salesforce/messageChannel/customTableColumnAction__c';
import { RefreshEvent } from 'lightning/refresh';
export default class ClickableColumn extends LightningElement {

    @wire(MessageContext)
    messageContext;
    @api label;
    @api iconName;
    @api set param(value) {
        console.debug('clickableColumn value', value);
        this.value = value
    }
    get param() {
        return this.value;
    }

    handleClickAction(event) {
        const filters = {
            selectedRecord: this.value
        };
        console.debug('handleClickAction:', filters)
        this.dispatchEvent(new RefreshEvent());
        publish(this.messageContext, columnClickMessageChannel, filters);
    }
}