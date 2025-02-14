import { LightningElement, api } from 'lwc';
import getRecordTypeNameByAuditEventTypeId from "@salesforce/apex/DisclosureRecordFetch.getRecordTypeNameByAuditEventTypeId";
import TIME_ZONE from '@salesforce/i18n/timeZone';

//these are the Record Types defined in the Object for the Disclosure Audit Event
const EventSubjectEnums = {
    Approval: 'Approval',
    Delegation: 'Delegation',
    Endorsing: 'InventorSubmitted',
    Rejection: 'Rejection',
    Signing: 'Signing',
    PendingDepartmentApproval: 'PendingDepartmentApproval',
    Archived: 'Archived',
    Unarchived: 'Unarchived'
}

export default class AuditEventHistoryItem extends LightningElement {
    @api historyItem;
    @api historiesLength;
    @api idx;
    timeZone = TIME_ZONE;

    historyItemType = null;

    properItem = false;

    async connectedCallback() {
        if (this.historyItem) {
            this.properItem = true;
            this.historyItemType = await getRecordTypeNameByAuditEventTypeId({ auditEventTypeId: this.historyItem.RecordTypeId })

        } else {
            this.properItem = false;
        }
    }


    get determineTimelineClass() {
        let timelineStyle = 'slds-timeline__item_expandable'
        if (!this.historyItemType) return timelineStyle;
        switch (this.historyItemType) {
            case EventSubjectEnums.Signing:
                timelineStyle += ' timeline_signing';
                break;
            case EventSubjectEnums.Endorsing:
                timelineStyle += ' timeline_signing';
                break;
            case EventSubjectEnums.Approval:
                timelineStyle += ' timeline_approval';
                break;
            case EventSubjectEnums.Rejection:
                timelineStyle += ' timeline_rejection';
                break;
            case EventSubjectEnums.Delegation:
                timelineStyle += ' timeline_delegation';
                break;
            case EventSubjectEnums.PendingDepartmentApproval:
                timelineStyle += ' timeline_signing';
                break;
            case EventSubjectEnums.Archived:
                timelineStyle += ' timeline_archive';
                break;
            case EventSubjectEnums.Unarchived:
                timelineStyle += ' timeline_unarchived';
                break;
            default:
                break;
        }

        return this.historiesLength === this.idx ? timelineStyle + ' timeline_last' : timelineStyle;
    }

    get determineTimelineIcon() {
        let timelineIcon;
        if (!this.historyItemType) return timelineIcon;

        switch (this.historyItemType) {
            case EventSubjectEnums.Signing:
                timelineIcon = 'standard:task';
                break;
            case EventSubjectEnums.Endorsing:
                timelineIcon = 'standard:task';
                break;
            case EventSubjectEnums.Approval:
                timelineIcon = 'standard:task';
                break;
            case EventSubjectEnums.Rejection:
                timelineIcon = 'standard:first_non_empty';
                break;
            case EventSubjectEnums.Delegation:
                timelineIcon = 'standard:product_request_line_item';
                break;
            case EventSubjectEnums.PendingDepartmentApproval:
                timelineIcon = 'standard:approval';
                break;
            case EventSubjectEnums.Archived:
                timelineIcon = 'standard:waits';
                break;
            case EventSubjectEnums.Unarchived:
                timelineIcon = 'standard:approval';
                break;
            default:
                timelineIcon = 'standard:dataset';
                break;
        }
        return timelineIcon;
    }
}