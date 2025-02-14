/**
 * Created by Andreas du Preez on 2024/03/04.
 */

import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import PFA_SVG_ICON from '@salesforce/resourceUrl/partner_fund_allocation_svg';
import { closeTab, getAllTabInfo, setTabIcon, setTabLabel } from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const PFA_ICON_SVG_ID = 'pfa_icon';
const CRDR_ROYALTY_INCOME_TAB = 'CRDR_Royalty_Income_Breakdown_Tab';

export default class crdrIncomeBreakdownTab extends NavigationMixin(LightningElement) {
    crdrRecordId;
    crdrLabel;
    agreementRecIdStr;
    agrName;
    caseAgrIncome;
    agrCasePct;

    @wire(CurrentPageReference) pageRef(pageRef) {
        if (pageRef) {
            this.crdrRecordId = pageRef.state.c__crdrRecordId;
            this.crdrLabel = pageRef.state.c__crdrLabel;
            this.agreementRecIdStr = pageRef.state.c__agreementRecIdStr;
            this.agrName = pageRef.state.c__agrName;
            this.caseAgrIncome = pageRef.state.c__caseAgrIncome;
            this.agrCasePct = pageRef.state.c__agrCasePct;
        }

        // Close tab if record id is missing and show toast.
        // Set tab label and icon if record id is present
        getAllTabInfo().then((tabs) => {
            tabs.forEach((tab) => {
                if (tab?.pageReference?.attributes?.apiName === CRDR_ROYALTY_INCOME_TAB)
                    if (!tab?.pageReference?.state?.c__crdrRecordId) {
                        this.closeTabAndShowMissingRecordIdToast(tab.tabId);
                    } else {
                        this.setTabLabelAndIcon(tab.tabId);
                    }

                tab.subtabs.forEach((subtab) => {
                    if (subtab?.pageReference?.attributes?.apiName === CRDR_ROYALTY_INCOME_TAB)
                        if (!subtab?.pageReference?.state?.c__crdrRecordId) {
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
                title: 'Missing Case CRDR Record Id',
                message: 'Open the Royalty Income Breakdown from a Case CRDR record'
            })
        );
    }

    setTabLabelAndIcon(tabId) {
        setTabLabel(tabId, 'Royalty Income Breakdown');
        setTabIcon(tabId, ` `);
    }

    // Getters
    get partnerFundAllocationIconUrl() {
        return `${PFA_SVG_ICON}#${PFA_ICON_SVG_ID}`;
    }
}