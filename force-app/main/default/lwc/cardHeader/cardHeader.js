import { LightningElement, api } from 'lwc';

export default class CardHeader extends LightningElement {
    @api title
    @api iconName
    @api iconSrc
    @api actions = []

    handleOnActionClick(event) {
        this.dispatchEvent(new CustomEvent('actionclick', { detail: {eventName: event.currentTarget.dataset.fieldId }}));
    }
}