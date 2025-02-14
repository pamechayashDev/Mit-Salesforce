import { LightningElement, api, track, wire } from 'lwc'
import { getFieldValue, getRecord } from 'lightning/uiRecordApi'
import getIpiaAckByMitId from '@salesforce/apex/IpiaRecordFetch.getIpiaAckByMitId'

export default class IpiaAcknowledgement extends LightningElement {
    @api recordId
    @api mitIdField

    @track error
    @track ipiaAck
    @track noResults = true
    loading = true
    record

    @wire(getRecord, { recordId: '$recordId', fields: '$mitIdField' })
    async handleGetRecord(record) {
        if (record.data) {
            this.record = record
            await this.getIpiaAck()
        }
        if (record.error) {
            this.error = true
        }
    }

    get mitId() {
        if (this.record) {
            return getFieldValue(this.record.data, this.mitIdField)
        }
        return null
    }

    getIpiaAck = async () => {
        this.loading = true
        this.error = false
        this.ipiaAck = null
        this.noResults = true

        try {
            console.log('🆔', this.mitId)
            const res = await getIpiaAckByMitId({ mitid: `${this.mitId}` })
            this.ipiaAck = res
            console.log('📄', this.ipiaAck)

            this.noResults = false
        } catch (error) {
            this.error = true
        } finally {
            this.loading = false
        }
    }
}