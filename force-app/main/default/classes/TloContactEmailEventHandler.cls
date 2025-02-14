public with sharing class TloContactEmailEventHandler extends TriggerHandler {
    public TloContactEmailEventHandler() {
    }

    public override void afterInsert(
        List<SObject> newRecords,
        Map<ID, SObject> newRecordMap
    ) {
        List<String> futureJsonRecords = new List<String>();

        for (SObject event : newRecords) {
            futureJsonRecords.add(JSON.serialize(event));
        }

        TloContactEmailEventHandler.futureAfterUpdateEvent(futureJsonRecords);
    }

    /**
     * Need to do a callout and can only be done from with in a Future method
     * Methods with the future annotation must be static methods, and can only return a void type.
     * The specified parameters must be primitive data types, arrays of primitive data types, or collections of primitive data types.
     * Methods with the future annotation can’t take sObjects or objects as arguments.
     */
    @Future(callout=true)
    public static void futureAfterUpdateEvent(List<String> newRecordsJson) {
        List<Tlo_Contact_Email_Event__e> newRecords = new List<Tlo_Contact_Email_Event__e>();
        for (String jsonEvent : newRecordsJson) {
            Tlo_Contact_Email_Event__e event = (Tlo_Contact_Email_Event__e) System.JSON.deserialize(
                jsonEvent,
                Tlo_Contact_Email_Event__e.class
            );
            newRecords.add(event);
        }
        TloContactEmailEventHandler handler = new TloContactEmailEventHandler();

        handler.handleOnEmailUpdated(newRecords);
    }

    public void handleOnEmailUpdated(
        List<Tlo_Contact_Email_Event__e> newRecords
    ) {
        List<String> contactIds = new List<String>();
        for (Tlo_Contact_Email_Event__e event : newRecords) {
            if (event.Event_Name__c == 'onEmailUpdated') {
                contactIds.add(event.TloContactId__c);
            }
        }

        List<Account> contactList = DisclosureRecordFetch.getContactsByIds(
            contactIds
        );
        List<Account> contactUpdateList = new List<Account>();

        for (Account accContact : contactList) {
            Boolean invitationCodeNullOrEmpty =
                accContact.InvitationCode__pc == null ||
                accContact.InvitationCode__pc.length() == 0;
            Boolean mitIdNullOrEmpty =
                accContact.MitId__pc == null ||
                accContact.MitId__pc.length() == 0;
            Boolean guestAccountNeededYes =
                accContact.GuestAccountNeeded__pc != null &&
                accContact.GuestAccountNeeded__pc == 'Yes';
            Boolean guestAccountNeededNo =
                accContact.GuestAccountNeeded__pc != null &&
                accContact.GuestAccountNeeded__pc == 'No';
            Boolean isAlumni =
                accContact.IsAlumni__pc != null &&
                accContact.IsAlumni__pc == true;
            Boolean isActiveKerb = Helpers.isActiveKerb(accContact.MoiraStatus__pc);

            if (
                accContact.PersonEmail.endsWith('@alum.mit.edu') ||
                accContact.PersonEmail.endsWith('@mit.edu')
            ) {
                //Nothing to do in guest account, Tlo_Contact__c has been updated
            } else if (guestAccountNeededYes || mitIdNullOrEmpty) {
                //Before Disclosure Approval Changes, no invite code yet
                //Nothing to do, Tlo_Contact__c has been updated
            } else {
                //Request invitecode with existing mitId and new email, will trigger eventbridge event to update InvitationCode__c an send out notification
                //OR
                //Update existing active guest account.

                try {
                    GuestAccount.updateGuestAccount(accContact);
                }catch (GuestAccount.GuestAccountNotFoundException ex) {
                    // Flag GuestAccountNeeded
                    if(!isAlumni && !isActiveKerb) {
                        Account updateContact = new Account(Id = accContact.Id,
                         GuestAccountNeeded__pc = 'Yes'
                         );
                        contactUpdateList.add (updateContact);
                    }
                }
            }

            //TODO:  Send notification if required
            //After Account Activation (Guest Login/Salesforce JIT Provisioning)
            // if (guestAccountNeededNo && invitationCodeNullOrEmpty && !mitIdNullOrEmpty) {
            // }
        }
        if(!contactUpdateList.isEmpty()) {
            update contactUpdateList;
        }
    }
}