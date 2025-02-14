public with sharing class PersonAccountTriggerHandler {
    public static void onBeforeInsert(List<Account> personAccountList) {
        for (Account personAccount : personAccountList) {
            if (
                personAccount.GovernmentEmployeeStatus__pc &&
                String.isEmpty(personAccount.Government_Agency_Name__pc)
            ) {
                personAccount.Government_Agency_Name__pc.addError(
                    Label.TLO_GovAgency
                );
            }
            if (
                personAccount.VaAppointment__pc == 'Yes' &&
                String.isEmpty(personAccount.VaAppointmentDetails__pc)
            ) {
                personAccount.Government_Agency_Name__pc.addError(
                    Label.TLOContact_VAAppt
                );
            }
            if (!personAccount.GovernmentEmployeeStatus__pc) {
                personAccount.Government_Agency_Name__pc = null;
            }
            if (personAccount.VaAppointment__pc == 'No') {
                personAccount.VaAppointmentDetails__pc = null;
            }
            //
            Boolean inactiveKerbAndNotAlumni = !Helpers.isActiveKerb(personAccount.MoiraStatus__pc) && personAccount.IsAlumni__pc != true;
            if (inactiveKerbAndNotAlumni && !GuestAccount.isValidContact(personAccount)) {
            	 personAccount.addError(Label.GuestSandboxEmailAddressValidation + ' ' + personAccount.PersonEmail);
            }
        }
    }

    public static void onBeforeUpdate(
        List<Account> personAccountList,
        Map<Id, Account> oldPersonAccount
    ) {
        // Only run email validations if...
        if (
            UserInfo.getProfileId() !=
            ShirleyConstants.COMMUNITY_PROFILE_ID && // the current user is not a community user (i.e. Native App user)
            UserInfo.getProfileId() != ShirleyConstants.INTEGRATION_PROFILE_ID // the current user is not an Integration user
        ) {
            personAccountList = emailValidation(
                personAccountList,
                oldPersonAccount
            );
        }
    }

    public static List<Account> emailValidation(
        List<Account> personAccountList,
        Map<Id, Account> oldPersonAccount
    ) {
        List<Account> validatedPersonAccounts = new List<Account>();
        for (Account personAccount : personAccountList) {
            Account prevPersonAccount = (oldPersonAccount != null &&
                oldPersonAccount.get(personAccount.Id) != null)
                ? oldPersonAccount.get(personAccount.Id)
                : null;

            // Person Account has an Active Kerb or is Alumni
            if (
                Helpers.isActiveKerb(personAccount.MoiraStatus__pc) || // Active Kerb
                personAccount.IsAlumni__pc == true // Alumni
            ) {
                // PersonEmail cannot be updated for Person Accounts with active kerbs
                if (
                    personAccount.PersonEmail != prevPersonAccount.PersonEmail
                ) {
                    // PersonEmail has been changed
                    personAccount.PersonEmail.addError(
                        Label.ChangedEmailAddressForActiveKerbValidation
                    );
                }
                // AltEmail__pc cannot be updated for Person Accounts with active kerbs
                if (
                    personAccount.AltEmail__pc != prevPersonAccount.AltEmail__pc
                ) {
                    // AltEmail__pc has been changed
                    personAccount.AltEmail__pc.addError(
                        Label.ChangedAltEmailAddressForActiveKerbValidation
                    );
                }
            }
            // PersonEmail and AltEmail__pc cannot end in mit.edu for Guests or Person Accounts with inactive kerbs
            if (
                !Helpers.isActiveKerb(personAccount.MoiraStatus__pc) && // Inactive Kerb
                personAccount.IsAlumni__pc != true // Not Alumni
            ) {
                if (
                    personAccount.PersonEmail != null &&
                    personAccount.PersonEmail.endsWith('mit.edu')
                ) {
                    personAccount.PersonEmail.addError(
                        Label.GuestEmailAddressValidation
                    );
                }
                if (
                    personAccount.AltEmail__pc != null &&
                    personAccount.AltEmail__pc.endsWith('mit.edu')
                ) {
                    personAccount.AltEmail__pc.addError(
                        Label.GuestAltEmailAddressValidation
                    );
                }
                if (!GuestAccount.isValidContact(personAccount)) {
                    personAccount.addError(Label.GuestSandboxEmailAddressValidation + ' ' + personAccount.PersonEmail);
                }
            }
            validatedPersonAccounts.add(personAccount);
        }
        return validatedPersonAccounts;
    }

    public static void onAfterUpdate(
        List<Account> currPersonAccountList,
        Map<Id, Account> oldPersonAccountList
    ) {
        List<Account> personAccountChangeList = new List<Account>();
        for (Account curPersonAccount : currPersonAccountList) {
            Account prevPersonAccount = (oldPersonAccountList != null &&
                oldPersonAccountList.get(curPersonAccount.Id) != null)
                ? oldPersonAccountList.get(curPersonAccount.Id)
                : null;

            if (
                curPersonAccount.PersonEmail != null &&
                prevPersonAccount.PersonEmail != null
            ) {
                if (
                    curPersonAccount.PersonEmail !=
                    prevPersonAccount.PersonEmail
                ) {
                    personAccountChangeList.add(curPersonAccount);
                }
            }
        }

        if (!personAccountChangeList.isEmpty()) {
            Map<String, String> personAccountMap = new Map<String, String>();
            for (Account personAccount : personAccountChangeList) {
                personAccountMap.put(
                    personAccount.Id,
                    personAccount.PersonEmail
                );
            }
            UserController.updateUsers(personAccountMap);
            TloContactEmailEventProducer.onTloContactEmailChanged(
                personAccountChangeList
            );
        }
    }
}