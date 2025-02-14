import { LightningElement, api } from 'lwc'

export default class ErrorPopover extends LightningElement {
    @api show
    @api errors
    @api errorMessage

    hasRendered = false

    connectedCallback() {
        if (!this.hasRendered) {
            if (this.errors) {
                console.log('🔴 Errors', this.errors)
            }
            this.hasRendered = true
        }
    }

    get errorMessages() {
        return this.errors.map((error, index) => {
            return { index: index, error: error }
        })
    }

    get showErrors() {
        return this.errors && this.errors.length > 0 ? true : false
    }

    closePopover() {
        // this.show = false
        this.dispatchEvent(new CustomEvent('close', {}))
    }
}