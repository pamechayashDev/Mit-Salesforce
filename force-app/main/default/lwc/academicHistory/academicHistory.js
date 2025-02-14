import { LightningElement, api, wire, track } from 'lwc'
import restGet from '@salesforce/apex/AwsApiCall.restGet'
import { NavigationMixin } from 'lightning/navigation'
import { getFieldValue, getRecord } from 'lightning/uiRecordApi'
import MIT_Academic_History from '@salesforce/label/c.MIT_Academic_History'
import globalStyles from '@salesforce/resourceUrl/globalStyles'
import { loadStyle } from 'lightning/platformResourceLoader'
import { invokeWorkspaceAPI } from 'c/workspaceApiUtils'
import { HISTORY_ACCOUNT_FIELDS } from 'c/utils'

export default class AcademicHistory extends NavigationMixin(LightningElement) {
    @api recordId
    @api mitIdField

    @track error
    @track dynamicProfile
    @track profile = []
    @track noResults = false
    loading = true
    profileAmt = 0
    record

    MIT_Academic_History = MIT_Academic_History

    @wire(getRecord, { recordId: '$recordId', fields: HISTORY_ACCOUNT_FIELDS })
    async handleGetRecord(record) {
        if (record.data) {
            this.record = record
            await this.getAcademicHist()
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

    getAcademicHist = async () => {
        this.loading = true
        this.error = false
        this.profile = []
        this.noResults = false
        this.profileAmt = 0
        try {
            const apiName = 'academicHistoryApi'
            const res = await restGet({
                api: apiName,
                resource: `/histories/${this.mitId}`
            })
            if (res) {
                this.profile = JSON.parse(res)
                if (this.profile.message) {
                    console.error(this.profile.message)
                    this.error = true
                } else if (this.profile.length === 0) {
                    this.noResults = true
                } else {
                    this.profileAmt =
                        this.profile.length > 3 ? '3+' : this.profile.length
                }
            }
        } catch (error) {
            console.error(error)
            this.loading = false
            this.profile = []
            this.error = true
        } finally {
            this.loading = false
        }
    }

    navigateToAll() {
        invokeWorkspaceAPI('isConsoleNavigation').then((isConsole) => {
            if (isConsole) {
                invokeWorkspaceAPI('getFocusedTabInfo').then((focusedTab) => {
                    invokeWorkspaceAPI('openSubtab', {
                        parentTabId: focusedTab.tabId,
                        pageReference: {
                            type: 'standard__navItemPage',
                            attributes: {
                                apiName: 'MIT_Academic_History'
                            },
                            state: {
                                c__name: this.record.data.fields.Name.value,
                                c__url: window.location.href,
                                c__mitid: this.mitId,
                                c__personDetailsTabId: focusedTab.tabId
                            }
                        }
                    }).then((tabId) => {
                        invokeWorkspaceAPI('setTabLabel', {
                            tabId: tabId,
                            label: 'Academic History'
                        })

                        invokeWorkspaceAPI('setTabIcon', {
                            tabId: tabId,
                            icon: 'standard:education',
                            iconAlt: 'Academic History'
                        })
                    })
                })
            }
        })
    }

    connectedCallback() {
        loadStyle(this, globalStyles)
    }
}