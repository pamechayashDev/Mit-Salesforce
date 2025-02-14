import { LightningElement, api, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { ACCOUNT_FIELDS, determineActiveStatus, peopleSearchWithSource } from "c/utils";
import updateContactFields from '@salesforce/apex/UpdateRecordHelper.updateContactFields';
import getGuestAccountStatus from '@salesforce/apex/GuestAccount.getGuestAccountStatus';
import TIME_ZONE from '@salesforce/i18n/timeZone';

const CONTACT_REC_ID = 'Account.Contact_Recid__pc';

export default class ContactMitInformation extends LightningElement {
    @api recordId;
    @api mitIdField;
    @api label;

    timezone = TIME_ZONE;
    hourSet = false;
    guestAccountStatusDataProcessed = {};
    error;

    open = true;
    record;
    loading = true;

    fields = {};

    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    async handleGetRecord(record) {
        if (record.data) {
            this.record = record;
            console.log('this.record', JSON.parse(JSON.stringify(this.record)));
            await this.getPeopleSearchFields().then(() => {
                this.loading = false;
            });

            // If record was found, update TLO Contact Moira Status
            if (this.fields) {
                this.updateContact();
            }
        } else if (record.error) {
            console.error(record.error);
            this.error = true;
        }
    }

    get mitId() {
        return this.record ? getFieldValue(this.record.data, this.mitIdField) : null;
    }

    get contactRecId() {
        return this.record ? getFieldValue(this.record.data, CONTACT_REC_ID) : null;
    }

    get hasInactiveEmail() {
        return this.fields.inactiveEmail ? true : false;
    }

    get kerbStatus() {
        return this.fields.krbName ? this.fields.kerbStatus : null;
    }

    get guestAccountStatus() {
        return 'Status Options: Active (Invitation code already used) or Invited (Invitation code details available)';
    }

    clearFields() {
        this.fields = {};
    }

    async getPeopleSearchFields() {
        this.clearFields();
        if (this.mitId) {
            let { searchResults, error } = await peopleSearchWithSource(this.mitId);

            if (searchResults && searchResults.length > 0) {
                this.fields = searchResults[0];  // if guest true

                if (this.fields.guest === true ) {
                    try {
                        const guestAccountStatusData = await getGuestAccountStatus({ email: searchResults[0].email });

                        if (guestAccountStatusData) {
                            this.guestAccountStatusDataProcessed = {
                                status: guestAccountStatusData.status
                            };
                        }


                        if (guestAccountStatusData?.inviteCodes || guestAccountStatusData?.inviteCodes.length === 0) {
                            // only check TLO invite codes & get the last validUntil from list
                            const inviteCodeData = guestAccountStatusData.inviteCodes
                                .filter((row) => row.systemName === 'TLO')
                                .sort((a, b) => {
                                    return b.validUntil.localeCompare(a.validUntil);
                                })[0];
                            
                            const validUntilDate = new Date(inviteCodeData.validUntil);
                            const isValid = validUntilDate && validUntilDate >= new Date();

                            this.guestAccountStatusDataProcessed = { 
                                ...this.guestAccountStatusDataProcessed, 
                                email: inviteCodeData.email,
                                inviteCode: inviteCodeData.inviteCode,
                                systemName: inviteCodeData.systemName,
                                validUntil: inviteCodeData.validUntil,
                                guestAccountInvitationCodeValid: isValid
                            };
                        } else {
                            console.error('Unexpected accountStatusData structure:', guestAccountStatusData);
                        }                        
                    } catch (error) {
                        console.error('Error fetching account status data:', error);
                    }
                }

                this.fields.inactiveEmail =
                    determineActiveStatus(this.fields.moiraStatus) === 'Active'
                        ? null
                        : this.fields.mitEmail;
            }

            if (error) {
                console.error(error);
                this.error = true;
            }
        }
    }

    updateContact() {
        try {
            updateContactFields({
                id: this.recordId,
                moiraStatus: this.fields.moiraStatus ?? '',
                isAlumni: this.fields.alumni ?? false
            });
        } catch (e) {
            console.error(e);
            this.error = true;
        }
    }

    get sectionClass() {
        return this.open ? 'slds-section slds-is-open' : 'slds-section';
    }

    get isInvited() {
        return this.guestAccountStatusDataProcessed.status === 'INVITED' ? true : false;
    }

    handleSectionClick() {
        this.open = !this.open;
    }
}