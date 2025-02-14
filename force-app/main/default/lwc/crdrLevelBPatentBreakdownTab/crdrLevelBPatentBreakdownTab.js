/**
 * Created by Andreas du Preez on 2024/03/05.
 */

import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import PFA_SVG_ICON from '@salesforce/resourceUrl/partner_fund_allocation_svg';
import { closeTab, getAllTabInfo, setTabIcon, setTabLabel } from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const PFA_ICON_SVG_ID = 'pfa_icon';
const CRDR_PATENT_BREAKDOWN_TAB = 'CRDR_Patent_Breakdown_Tab';

export default class crdrLevelBPatentBreakdownTab extends NavigationMixin(LightningElement) {
    caseRecordId;
    crdrLabel;

    @wire(CurrentPageReference) pageRef(pageRef) {
        if (pageRef) {
            this.caseRecordId = pageRef.state.c__caseRecordId;
            this.crdrLabel = pageRef.state.c__crdrLabel;
        }

        // Close tab if record id is missing and show toast.
        // Set tab label and icon if record id is present
        getAllTabInfo().then((tabs) => {
            tabs.forEach((tab) => {
                if (tab?.pageReference?.attributes?.apiName === CRDR_PATENT_BREAKDOWN_TAB)
                    if (!tab?.pageReference?.state?.c__caseRecordId) {
                        this.closeTabAndShowMissingRecordIdToast(tab.tabId);
                    } else {
                        this.setTabLabelAndIcon(tab.tabId);
                    }

                tab.subtabs.forEach((subtab) => {
                    if (subtab?.pageReference?.attributes?.apiName === CRDR_PATENT_BREAKDOWN_TAB)
                        if (!subtab?.pageReference?.state?.c__caseRecordId) {
                            this.closeTabAndShowMissingRecordIdToast(subtab.tabId);
                        } else {
                            this.setTabLabelAndIcon(subtab.tabId);
                        }
                });
            });
        });
    }

    // Helper functions
    closeTabAndShowMissingRecordIdToast(tabId) {
        closeTab(tabId);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Missing Case Record Id',
                message: 'Open the Patent Breakdown from a Case CRDR record'
            })
        );
    }

    setTabLabelAndIcon(tabId) {
        setTabLabel(tabId, 'Patent Breakdown');
        setTabIcon(tabId, ` `);
    }

    // Getters
    get partnerFundAllocationIconUrl() {
        return `${PFA_SVG_ICON}#${PFA_ICON_SVG_ID}`;
    }
}