/**
 * Created by Andreas du Preez on 2024/03/05.
 */
import { api } from 'lwc';
import LightningModal from 'lightning/modal';

// https://www.salesforcecodecrack.com/2023/01/dynamic-popupmodal-using-lightning.html
export default class crdrLevelBPatentBreakdownModal extends LightningModal {
    @api label;
    @api caseRecId;

    handleClickOpenTab(event) {
        this.closeModal('navigateToTab');
    }

    handleOpenAgreement(event) {
        this.closeModal('navigateToAgreement', event.detail.recordId);
    }

    closeModal(action, recordId) {
        this.close({
            action: action,
            recordId: recordId
        })
    }
}