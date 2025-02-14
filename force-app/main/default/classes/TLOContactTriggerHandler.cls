public class TLOContactTriggerHandler {
    public static void onBeforeInsert(List<TLO_Contact__c> tloContactList) {
        for (TLO_Contact__c tloContact : tloContactList) {
            if (
                tloContact.GovernmentEmployeeStatus__c &&
                String.isEmpty(tloContact.Government_Agency_Name__c)
            ) {
                tloContact.Government_Agency_Name__c.addError(
                    Label.TLO_GovAgency
                );
            }
            if (
                tloContact.VaAppointment__c == 'Yes' &&
                String.isEmpty(tloContact.VaAppointmentDetails__c)
            ) {
                tloContact.Government_Agency_Name__c.addError(
                    Label.TLOContact_VAAppt
                );
            }
            if (!tloContact.GovernmentEmployeeStatus__c) {
                tloContact.Government_Agency_Name__c = null;
            }
            if (tloContact.VaAppointment__c == 'No') {
                tloContact.VaAppointmentDetails__c = null;
            }
        }
    }
    public static void onBeforeUpdate(
        List<TLO_Contact__c> tloContactList,
        Map<Id, TLO_Contact__c> oldTloContact
    ) {
        // Update Name
        for (TLO_Contact__c contact : tloContactList) {
            contact.Name = Helpers.getDisplayName(
                contact.PreferredName__c,
                contact.LegalGivenName__c,
                contact.LegalMiddleName__c,
                contact.LegalLastName__c
            );
        }

        // Only run email validations if...
        if (
            UserInfo.getProfileId() !=
            ShirleyConstants.COMMUNITY_PROFILE_ID && // the current user is not a community user (i.e. Native App user)
            UserInfo.getProfileId() != ShirleyConstants.INTEGRATION_PROFILE_ID // the current user is not an Integration user
        ) {
            for (TLO_Contact__c tloContact : tloContactList) {
                TLO_Contact__c prevTloContact = (oldTloContact != null &&
                    oldTloContact.get(tloContact.Id) != null)
                    ? oldTloContact.get(tloContact.Id)
                    : null;

                // TLO Contact has an Active Kerb or is Alumni
                if (
                    Helpers.isActiveKerb(tloContact.MoiraStatus__c) || // Active Kerb
                    tloContact.IsAlumni__c == true // Alumni
                ) {
                    // Email__c cannot be updated for TLO Contacts with active kerbs
                    if (tloContact.Email__c != prevTloContact.Email__c) {
                        // Email__c has been changed
                        tloContact.Email__c.addError(
                            Label.ChangedEmailAddressForActiveKerbValidation
                        );
                    }
                    // AltEmail__c cannot be updated for TLO Contacts with active kerbs
                    if (tloContact.AltEmail__c != prevTloContact.AltEmail__c) {
                        // AltEmail__c has been changed
                        tloContact.AltEmail__c.addError(
                            Label.ChangedAltEmailAddressForActiveKerbValidation
                        );
                    }
                }
                // Email__c and AltEmail__c cannot end in mit.edu for Guests or TLO Contacts with inactive kerbs
                if (
                    !PersonAccountMigrationHelpers.isPersonAccountMigrationInProgress() && // TODO: Refactor - Remove post AC migration
                    !Helpers.isActiveKerb(tloContact.MoiraStatus__c) && // Inactive Kerb
                    tloContact.IsAlumni__c != true // Not Alumni
                ) {
                    if (
                        tloContact.Email__c != null &&
                        tloContact.Email__c.endsWith('mit.edu')
                    ) {
                        tloContact.Email__c.addError(
                            Label.GuestEmailAddressValidation
                        );
                    }
                    if (
                        tloContact.AltEmail__c != null &&
                        tloContact.AltEmail__c.endsWith('mit.edu')
                    ) {
                        tloContact.AltEmail__c.addError(
                            Label.GuestAltEmailAddressValidation
                        );
                    }
                }
            }
        }
    }

    public static void onAfterInsert(List<TLO_Contact__c> tloContactList) {
    }

    public static void onAfterUpdate(
        List<TLO_Contact__c> currTloContactList,
        Map<Id, TLO_Contact__c> oldTloContactList
    ) {
        List<TLO_Contact__c> tloContactChangedList = new List<TLO_Contact__c>();
        for (TLO_Contact__c currTloContact : currTloContactList) {
            TLO_Contact__c prevTloContact = (oldTloContactList != null &&
                oldTloContactList.get(currTloContact.Id) != null)
                ? oldTloContactList.get(currTloContact.Id)
                : null;

            if (
                currTloContact.Email__c != null &&
                prevTloContact.Email__c != null
            ) {
                if (currTloContact.Email__c != prevTloContact.Email__c) {
                    tloContactChangedList.add(currTloContact);
                }
            }
        }
        if (!tloContactChangedList.isEmpty()) {
            Map<String, String> contactMap = updateContacts(
                tloContactChangedList
            );
            updateUsers(contactMap);
            // NOTE: Method signature has changed to account not tlo contact
            // TloContactEmailEventProducer.onTloContactEmailChanged(tloContactChangedList);
        }
    }

    public static Map<String, String> updateContacts(
        List<TLO_Contact__c> tloContactList
    ) {
        List<Contact> contacts = new List<Contact>();
        Set<String> mitIds = new Set<String>();
        for (TLO_Contact__c tloContact : tloContactList) {
            mitIds.add(tloContact.MitId__c);
        }
        contacts = [
            SELECT Id, Email, FirstName, MiddleName, LastName, MitId__c
            FROM Contact
            WHERE MitId__c IN :(mitIds)
        ];

        Map<String, String> contactMap = new Map<String, String>();
        if (contacts != null && !contacts.isEmpty()) {
            for (Contact contact : contacts) {
                for (TLO_Contact__c tloContact : tloContactList) {
                    if (tloContact.MitId__c == contact.MitId__c) {
                        contact.Email = tloContact.Email__c;
                        contactMap.put(contact.Id, tloContact.Email__c);
                        break;
                    }
                }
            }
            update contacts;
        }
        return contactMap;
    }

    public static void updateUsers(Map<String, String> contactMap) {
        List<User> users = new List<User>();
        users = [
            SELECT Id, Email, FirstName, MiddleName, LastName, ContactId
            FROM User
            WHERE ContactId IN :(contactMap.keySet())
        ];

        if (users != null && !users.isEmpty()) {
            for (User user : users) {
                user.Email = contactMap.get(user.ContactId);
            }
            update users;
        }
    }
}