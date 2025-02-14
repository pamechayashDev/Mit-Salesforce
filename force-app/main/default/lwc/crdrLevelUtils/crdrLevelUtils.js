import { LightningElement, api } from 'lwc';
import { getFieldDisplayValue, getFieldValue } from "lightning/uiRecordApi";
import PFA_SVG_ICON from "@salesforce/resourceUrl/partner_fund_allocation_svg";
import { formatCurrency } from "c/utils";

const PFA_ICON_SVG_ID = 'pfa_icon';

export default class CrdrLevelUtils extends LightningElement {

    @api crdrFieldNames = {
        YTD_INC_LVL_A: 'Forrester_SHIR_CRDR_VIEW__x.YTD_INC_LVL_A__c', //
        YTD_INC_LVL_B: 'Forrester_SHIR_CRDR_VIEW__x.YTD_INC_LVL_B__c', //
        YTD_INC_LVL_C: 'Forrester_SHIR_CRDR_VIEW__x.YTD_INC_LVL_C__c', //
        YTD_INC_LVL_D: 'Forrester_SHIR_CRDR_VIEW__x.YTD_INC_LVL_D__c', //
        YTD_INC_MIT_NET: 'Forrester_SHIR_CRDR_VIEW__x.YTD_INC_MIT_NET__c', //

        YTD_DEDUCT_LVL_A: 'Forrester_SHIR_CRDR_VIEW__x.YTD_DEDUCT_LVL_A__c', //
        YTD_DEDUCT_LVL_B: 'Forrester_SHIR_CRDR_VIEW__x.YTD_DEDUCT_LVL_B__c', //
        YTD_DEDUCT_LVL_C: 'Forrester_SHIR_CRDR_VIEW__x.YTD_DEDUCT_LVL_C__c',
        YTD_DEDUCT_LVL_D: 'Forrester_SHIR_CRDR_VIEW__x.YTD_DEDUCT_LVL_D__c',

        YTD_DEDUCT_INVENTOR_GRP: 'Forrester_SHIR_CRDR_VIEW__x.YTD_DEDUCT_INVENTOR_GRP__c',   //
        INVENTOR_DEDUCT_PCT: 'Forrester_SHIR_CRDR_VIEW__x.INVENTOR_DEDUCT_PCT__c', //

        ADMIN_DEDUCT_PCT: 'Forrester_SHIR_CRDR_VIEW__x.ADMIN_DEDUCT_PCT__c', //
        ADMIN_DEDUCTION: 'Forrester_SHIR_CRDR_VIEW__x.ADMIN_DEDUCTION__c', //
        ADMIN_DEDUCTION_VIRTUAL: 'Forrester_SHIR_CRDR_VIEW__x.ADMIN_DEDUCTION_VIRTUAL__c', //

        MATTER_RESERVE: 'Forrester_SHIR_CRDR_VIEW__x.MATTER_RESERVE__c', 
        MATTER_RESERVE_INTENDED: 'Forrester_SHIR_CRDR_VIEW__x.MATTER_RESERVE_INTENDED__c', 
        MATTER_WITHHOLDING: 'Forrester_SHIR_CRDR_VIEW__x.MATTER_WITHHOLDING__c', 
        MATTER_WITHHOLDING_BASE: 'Forrester_SHIR_CRDR_VIEW__x.MATTER_WITHHOLDING_BASE__c', 

        RESERVE_PRIOR: 'Forrester_SHIR_CRDR_VIEW__x.RESERVE_PRIOR__c', //
        RESERVE_WITHHOLDING: 'Forrester_SHIR_CRDR_VIEW__x.RESERVE_WITHHOLDING__c', //
        RESERVE_WITHHOLDING_INTENDED: 'Forrester_SHIR_CRDR_VIEW__x.RESERVE_WITHHOLDING_INTENDED__c', //

        DOMESTIC_WITHHOLDING: 'Forrester_SHIR_CRDR_VIEW__x.DOMESTIC_WITHHOLDING__c', //
        DOMESTIC_WITHHOLDING_BASE: 'Forrester_SHIR_CRDR_VIEW__x.DOMESTIC_WITHHOLDING_BASE__c', 
        DOM_PATENT_DEDUCT_PCT: 'Forrester_SHIR_CRDR_VIEW__x.DOM_PATENT_DEDUCT_PCT__c', //
        WITHHOLDING_COSTS_DOMESTIC: 'Forrester_SHIR_CRDR_VIEW__x.WITHHOLDING_COSTS_DOMESTIC__c', //
        WITHHOLDING_PRIOR_DOMESTIC: 'Forrester_SHIR_CRDR_VIEW__x.WITHHOLDING_PRIOR_DOMESTIC__c', //
        WITHHOLDING_REIMB_DOMESTIC: 'Forrester_SHIR_CRDR_VIEW__x.WITHHOLDING_REIMB_DOMESTIC__c', //
        WITHHOLDING_UNREIMB_DOMESTIC: 'Forrester_SHIR_CRDR_VIEW__x.WITHHOLDING_UNREIMB_DOMESTIC__c', //

        FOREIGN_WITHHOLDING: 'Forrester_SHIR_CRDR_VIEW__x.FOREIGN_WITHHOLDING__c',  //
        FOREIGN_WITHHOLDING_BASE: 'Forrester_SHIR_CRDR_VIEW__x.FOREIGN_WITHHOLDING_BASE__c', 
        FOR_PATENT_DEDUCT_PCT: 'Forrester_SHIR_CRDR_VIEW__x.FOR_PATENT_DEDUCT_PCT__c', //
        WITHHOLDING_COSTS_FOREIGN: 'Forrester_SHIR_CRDR_VIEW__x.WITHHOLDING_COSTS_FOREIGN__c', //
        WITHHOLDING_PRIOR_FOREIGN: 'Forrester_SHIR_CRDR_VIEW__x.WITHHOLDING_PRIOR_FOREIGN__c', //        
        WITHHOLDING_REIMB_FOREIGN: 'Forrester_SHIR_CRDR_VIEW__x.WITHHOLDING_REIMB_FOREIGN__c', //        
        WITHHOLDING_UNREIMB_FOREIGN: 'Forrester_SHIR_CRDR_VIEW__x.WITHHOLDING_UNREIMB_FOREIGN__c', // 
    }

    @api
    set crdr(value) {
        if (this._crdr !== value) {
            this._crdr = value;
        }
    }
    get crdr() {
        return this._crdr;
    }

    _crdr;
    
    get ytdIncLvlA() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_INC_LVL_A);
    }

    get ytdIncLvlB() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_INC_LVL_B);
    }

    get ytdIncLvlC() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_INC_LVL_C);
    }

    get ytdIncLvlC1() {   
        return formatCurrency(getFieldValue(this._crdr, this.crdrFieldNames.YTD_INC_LVL_C) - getFieldValue(this._crdr, this.crdrFieldNames.YTD_DEDUCT_LVL_C), true);
    }    

    get ytdIncLvlD() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_INC_LVL_D);
    }

    get ytdIncMitNet() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_INC_MIT_NET);
    }




    get ytdDeductLvlA() {
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_DEDUCT_LVL_A);
    }

    get ytdDeductLvlB() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_DEDUCT_LVL_B);
    }
    get ytdDeductLvlC() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_DEDUCT_LVL_C);
    }
    get ytdDeductLvlD() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_DEDUCT_LVL_D);
    }

    get ytdDeductInventorGrp() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.YTD_DEDUCT_INVENTOR_GRP);
    }
    get inventorDeductPct() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.INVENTOR_DEDUCT_PCT) ?? getFieldValue(this._crdr, this.crdrFieldNames.INVENTOR_DEDUCT_PCT);
    }
    

    get matterReserve() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.MATTER_RESERVE);
    }
    get matterReserveIntended() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.MATTER_RESERVE_INTENDED);
    }
    get matterWithholding() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.MATTER_WITHHOLDING);
    }
    get matterWithholdingBase() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.MATTER_WITHHOLDING_BASE);
    }
    
        
    
    get reserveWithholding() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.RESERVE_WITHHOLDING);
    }
    get domesticWithholding() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.DOMESTIC_WITHHOLDING);
    }
    get domesticWithholdingBase() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.DOMESTIC_WITHHOLDING_BASE);
    }
    get foreignWithholding() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.FOREIGN_WITHHOLDING);
    }
    get foreignWithholdingBase() {        
        return getFieldDisplayValue(this._crdr, this.crdrFieldNames.FOREIGN_WITHHOLDING_BASE);
    }

    get partnerFundAllocationIconUrl() {
        return `${PFA_SVG_ICON}#${PFA_ICON_SVG_ID}`;
    }
}