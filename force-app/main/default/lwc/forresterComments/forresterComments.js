import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getExternalComments from '@salesforce/apex/ExternalObjectRepository.getExternalComments';
import { getRecord } from 'lightning/uiRecordApi';
import { closeTab, getAllTabInfo, setTabIcon, setTabLabel } from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';

const FORRESTER_COMMENTS_TAB = 'All_Forrester_Comments';

export default class ForresterComments extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName; // e.g. Forrester_SHIR_AGREEMENT_VIEW__x
    @api objectApiField; // e.g. AGREEMENT_RECID__c
    @api externalCommentTableName; // picklist from datasource 'AGREEMENT'
    @api externalCommentContextName; // picklist from datasource 'ADMIN', 'COLLECTIONS'

    entityRecId

    timeZone = TIME_ZONE
    viewingAll = false; // Flag for Currently viewing LWC in Tab.
    loading = true;
    error = false;
    data = [];
    displayList = [];

    dataSize = 0 // All Items
    displayCount = 3 // Items to display in compact view

    activeSections = ['Other'];

    get fields () {
        return [`${this.objectApiName}.${this.objectApiField}`]
    }

    @wire(CurrentPageReference) pageRef(pageRef) {
        if (pageRef?.type !== 'standard__recordPage') {
            console.debug('ForresterComments pageRef:', pageRef)
            this.recordId = pageRef.state.c__id;
            this.objectApiName = pageRef.state.c__o;
            this.objectApiField = pageRef.state.c__f;
            this.externalCommentTableName = pageRef.state.c__tbl;
            this.externalCommentContextName = pageRef.state.c__ctx;

            this.viewingAll = true;
            console.debug('ForresterComments recordId:', this.recordId)
            console.debug('ForresterComments objectApiName:', this.objectApiName)
            console.debug('ForresterComments objectApiField:', this.objectApiField)

            // Only show if pageRef is not Standard Record Page
            // Close tab if record id is missing and show toast.
            // Set tab label and icon if record id is present
            getAllTabInfo().then((tabs) => {
                tabs.forEach((tab) => {
                    if (tab?.pageReference?.attributes?.apiName === FORRESTER_COMMENTS_TAB)
                        if (!tab?.pageReference?.state?.c__id) {
                            this.closeTabAndShowMissingRecordIdToast(tab.tabId);
                        } else {
                            this.setTabLabelAndIcon(tab.tabId);
                        }

                    tab.subtabs.forEach((subtab) => {
                        if (subtab?.pageReference?.attributes?.apiName === FORRESTER_COMMENTS_TAB)
                            if (!subtab?.pageReference?.state?.c__id) {
                                this.closeTabAndShowMissingRecordIdToast(subtab.tabId);
                            } else {
                                this.setTabLabelAndIcon(subtab.tabId);
                            }
                    });
                });
            });
        }
    }

    //this is used to retrieve the entityRecId of the record
    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    async handleLoadData({ error, data }) {
        if (data) {
            this.entityRecId = data.fields[this.objectApiField]?.value ;
            this.getComments()

        } else if (error) {
            this.loading = false;
            this.error = true;
            console.log(error)
            console.log(error.body.messsage)
        }
    }

    getComments(){
        getExternalComments({
            sourceRecId: this.entityRecId,
            table: this.externalCommentTableName,
            context: this.externalCommentContextName
        })
            .then(records => {
                console.log('comments :',records);
                this.loading = false;
                this.buildDisplayList(records);
            })
            .catch(error => {
                console.error('Error getting comments:', error);
                this.loading = false;
                this.error = true;
            });

    }


    buildDisplayList(records) {
        const groupMap = new Map()
        let cnt = 0;
        records.forEach(record => {
            console.log('comments.record :',record);
            const key = record.COMMENT_SEQ__c
            console.log('comments.key :',key);
            if (record.COMMENT_TEXT__c !== undefined) {

                // Build display Content and Concat all the comments with the same SEQ number, the list should be sorted on COMMENT_EXT__c on DB level
                if (!groupMap.has(key)) {
                    cnt++
                    let text = record.COMMENT_TEXT__c
                    text = this.replaceNewLine(text)
                    const comment = {
                        CreatedDate: record.ADD_DATE__c,
                        ModifiedDate: record.MOD_DATE__c,
                        CreatedByName: record.ADD_USER__c,
                        Title: `Comment ${cnt}`,
                        Content: text,
                        Index: cnt
                    }
                    groupMap.set(key, comment)
                } else {
                    const comment = groupMap.get(key)
                    let text = `${comment.Content}\n${record.COMMENT_TEXT__c}`;
                    text = this.replaceNewLine(text)
                    comment.Content = text
                    groupMap.set(key, comment)
                }
            }
        })
        console.log('comments.groupMap :',groupMap);
        let temp = Array.from(groupMap.values())
        temp = temp.sort((a,b) => a.Index - b.Index)
        this.data = temp;
        this.dataSize = this.data.length

        if (this.viewingAll) {
            this.displayList = this.data;
        }else {
            this.displayList = [...this.data].splice(0, this.displayCount);
        }
    }

    // Helper functions
    get title() {
        if (this.externalCommentTableName == 'AGREEMENT') {
            if (this.externalCommentContextName == 'ADMIN') {
                return 'Admin Comments'
            }
        }
        return 'Comments'
    }
    // Show the number of items in the displayList. Postfix with (n+)
    get displayCountLabel() {
        if (this.dataSize === undefined || this.displayCount === undefined) {
            return 0
        }else  if (this.dataSize > this.displayCount && !this.viewingAll) {
            return `${this.displayCount}+`
        }else {
            return this.dataSize
        }
    }


    // RichText does not show linebreaks
    replaceNewLine(text) {
        if (text === undefined) {
            return text;
        }
        return text.replace(/(\r\n|\r|\n)/g, '<br>');
    }

    setTabLabelAndIcon(tabId) {
        setTabLabel(tabId, 'Comments');
        setTabIcon(tabId, ` `);
    }

    closeTabAndShowMissingRecordIdToast(tabId) {
        closeTab(tabId);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Missing Record Id',
                message: 'Open the Comments from a Related record'
            })
        );
    }

    // Will show THIS Lwc in a new Tab.
    handleGotoViewAll() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: FORRESTER_COMMENTS_TAB
            },
            state: {
                c__id: this.recordId,
                c__o: this.objectApiName,
                c__f: this.objectApiField,
                c__tbl: this.externalCommentTableName,
                c__ctx: this.externalCommentContextName
            }
        });
    }

}