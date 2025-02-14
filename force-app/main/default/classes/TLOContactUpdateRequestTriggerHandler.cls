public class TLOContactUpdateRequestTriggerHandler {
    /**
     * Trigger handler for TLO_Contact_Update_Request__c before update events
     * @param tloContactUpdateRequestList List of new TLO_Contact_Update_Request__c objects to be processed
     */
    public static void onBeforeUpdate(
        List<TLO_Contact_Update_Request__c> tloContactUpdateRequestList
    ) {
        validateStatusChange(tloContactUpdateRequestList);
    }

    /**
     * Validate an TLO_Contact_Update_Request__c object
     * @param tloContactUpdateRequestList List of TLO_Contact_Update_Request__c objects to be processed
     */
    private static void validateStatusChange(
        List<TLO_Contact_Update_Request__c> tloContactUpdateRequestList
    ) {
        Set<Id> contactIds = new Set<Id>();
        for (
            TLO_Contact_Update_Request__c tloCur : tloContactUpdateRequestList
        ) {
            contactIds.add(tloCur.Contact__c);
        }

        List<Account> contactList = [
            SELECT Id, MoiraStatus__pc, PersonEmail, Institution__pc
            FROM Account
            WHERE Id = :contactIds AND IsPersonAccount = TRUE
        ];
        Map<Id, Account> contactLookup = new Map<Id, Account>(contactList);

        for (
            TLO_Contact_Update_Request__c contactUpReq : tloContactUpdateRequestList
        ) {
            if (contactUpReq.Update_Status__c != 'Pending') {
                if (String.isBlank(contactUpReq.Current_Email__c)) {
                    contactUpReq.Current_Email__c.addError(
                        label.ChangedContactUpdateReqStatusValidation
                    );
                }

                if (String.isBlank(contactUpReq.Current_Institution__c)) {
                    contactUpReq.Current_Institution__c.addError(
                        label.ChangedContactUpdateReqStatusInstitutionValidation
                    );
                }

                //TODO do we need to do the query & check contact itself if there are formula fields on this object back to the contact already?
                Account contact = contactLookup.get(contactUpReq.Contact__c);
                if (contact.PersonEmail != null) {
                    Boolean contactContainsMitEmail = Helpers.isMitEmailAddress(
                        contact.PersonEmail
                    );
                    if (
                        !Helpers.isActiveKerb(contact.MoiraStatus__pc) &&
                        contactContainsMitEmail
                    ) {
                        contactUpReq.Update_Status__c.addError(
                            label.ChangedContactUpdateReqEmailValidation
                        );
                    }
                }
            }
        }
    }
}