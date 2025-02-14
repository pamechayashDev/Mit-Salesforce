import { api } from 'lwc';
import LightningModal from 'lightning/modal';

// https://www.salesforcecodecrack.com/2023/01/dynamic-popupmodal-using-lightning.html
export default class CrdrIncomeBreakdownModal extends LightningModal {
    @api label;
    @api crdrRecordId; //
    @api agreementRecIdStr; //
    @api agrName;
    @api caseAgrIncome;
    @api agrCasePct;

    handleClickOpenTab(event) {
        this.close('navigateToTab');
    }
}