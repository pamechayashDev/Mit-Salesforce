public with sharing class PersonAccountMigrationHelpers {
    public static List<TLO_Contact__c> getUnmigratedTloContacts() {
        return [
            SELECT
                Id,
                MitId__c,
                KerbName__c,
                Address__c,
                City__c,
                State__c,
                Country__c,
                ZipCode__c,
                CountryOfCitizenship__c,
                Birthday__c,
                LegalGivenName__c,
                LegalLastName__c,
                LegalMiddleName__c,
                PreferredName__c,
                Title__c,
                Email__c,
                AltEmail__c,
                AlumniEmail__c,
                OldEmail__c,
                Phone__c,
                AltPhone__c,
                GuestAccountNeeded__c,
                InvitationCode__c,
                MoiraStatus__c,
                Department__c,
                Institution__c,
                InstitutionCode__c,
                IsAlumni__c,
                Government_Agency_Name__c,
                GovernmentEmployeeStatus__c,
                HHMI_Current__c,
                HHMI_Current_Date_From__c,
                VaAppointment__c,
                VaAppointmentDetails__c
            FROM TLO_Contact__c
            WHERE Person_Account__c = NULL
        ];
    }

    public static List<Account> getUnmigratedPersonAccounts() {
        return [
            SELECT Id, Name
            FROM Account
            WHERE TLO_Contact__pc = NULL
        ];
    }

    public static Account createAccountFromTloContact(
        TLO_Contact__c tloContact
    ) {
        // Get Record Type for Person Account
        Id recordTypeIdPersonAccont = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        return new Account(
            // Ids
            TLO_Contact__pc = tloContact.Id,
            RecordTypeId = recordTypeIdPersonAccont,
            MitId__pc = tloContact.MitId__c,
            KerbName__pc = tloContact.KerbName__c,
            // Address
            PersonMailingStreet = tloContact.Address__c,
            PersonMailingCity = tloContact.City__c,
            PersonMailingState = tloContact.State__c,
            PersonMailingCountry = tloContact.Country__c,
            PersonMailingPostalCode = tloContact.ZipCode__c,
            CountryOfCitizenship__pc = tloContact.CountryOfCitizenship__c,
            // Biographic
            PersonBirthdate = tloContact.Birthday__c,
            FirstName = tloContact.LegalGivenName__c,
            LastName = tloContact.LegalLastName__c,
            MiddleName = tloContact.LegalMiddleName__c,
            PreferredName__pc = tloContact.PreferredName__c,
            PersonTitle = tloContact.Title__c,
            // Contact
            PersonEmail = tloContact.Email__c,
            AltEmail__pc = tloContact.AltEmail__c,
            AlumniEmail__pc = tloContact.AlumniEmail__c,
            OldEmail__pc = tloContact.OldEmail__c,
            PersonMobilePhone = tloContact.Phone__c,
            PersonOtherPhone = tloContact.AltPhone__c,
            // Guest Account
            GuestAccountNeeded__pc = tloContact.GuestAccountNeeded__c,
            InvitationCode__pc = tloContact.InvitationCode__c,
            // Org
            MoiraStatus__pc = tloContact.MoiraStatus__c,
            PersonDepartment = tloContact.Department__c,
            Institution__pc = tloContact.Institution__c,
            InstitutionCode__pc = tloContact.InstitutionCode__c,
            IsAlumni__pc = tloContact.IsAlumni__c,
            // Related Institution
            Government_Agency_Name__pc = tloContact.Government_Agency_Name__c,
            GovernmentEmployeeStatus__pc = tloContact.GovernmentEmployeeStatus__c,
            HHMI_Current__pc = tloContact.HHMI_Current__c,
            HHMI_Current_Date_From__pc = tloContact.HHMI_Current_Date_From__c,
            VaAppointment__pc = tloContact.VaAppointment__c,
            VaAppointmentDetails__pc = tloContact.VaAppointmentDetails__c
        );
    }

    public static Boolean isPersonAccountMigrationInProgress() {
        Configurations__c config = Configurations__c.getInstance(
            'personAccountMigrationInProgress'
        );
        if (config != null) {
            String value = config.Value__c != null ? config.Value__c : 'false';
            if (value.equals('true')) {
                return true;
            } else {
                return false;
            }
        }
        return false;
    }

    public static List<Disclosure_Audit_Event__c> auditEventsMigrateUser(
        List<Disclosure_Audit_Event__c> events
    ) {
        // Pattern to find the User ID within the description
        Pattern p = Pattern.compile('(?<=/User/)(.*?)(?=/view)');
        // A set to store unique User Ids found in descriptions
        Set<String> userIds = new Set<String>();

        // Extract User Ids from each event's description
        for (Disclosure_Audit_Event__c event : events) {
            Matcher m = p.matcher(event.Description__c);
            while (m.find()) {
                String contactId = m.group();
                userIds.add(contactId);
            }
        }

        // Query the User records for those IDs to get the Username field
        List<User> users = [
            SELECT Id, Username
            FROM User
            WHERE Id IN :userIds
        ];

        // Get the MitId from the Username (if it exists)
        Map<String, Id> mitIdToUserMap = new Map<String, Id>();

        Pattern mitIdPattern = Pattern.compile('([\\d]{9}(?=\\@))');
        for (User u : users) {
            Matcher mitIdMatcher = mitIdPattern.matcher(u.Username);
            while(mitIdMatcher.find()) {
                mitIdToUserMap.put(mitIdMatcher.group(), u.Id);
            }
        }

        // Get the Account for each MitId
        Map<Id, Id> userToPersonAccountsMap = new Map<Id, Id>();
        for (Account acc : [
            SELECT Id, MitId__pc
            FROM Account
            WHERE MitId__pc IN :mitIdToUserMap.keySet()
        ]) {
            userToPersonAccountsMap.put(mitIdToUserMap.get(acc.MitId__pc), acc.Id);
        }

        // Update the description in each event
        for (Disclosure_Audit_Event__c event : events) {
            Matcher m = p.matcher(event.Description__c);
            String description = event.Description__c;
            boolean hasReplacement = false;

            while (m.find()) {
                String contactId = m.group();
                if (userToPersonAccountsMap.containsKey(contactId)) {
                    Id AccountId = userToPersonAccountsMap.get(contactId);
                    // Construct the replacement string
                    String replacement =
                        '/Account/' +
                        AccountId +
                        '/view';
                    // Replace in the original description
                    description = description.replace(
                        '/User/' +
                        contactId +
                        '/view',
                        replacement
                    );
                    hasReplacement = true;
                }
            }
            // Update the description if there was at least one replacement
            if (hasReplacement) {
                System.debug('Original: ' + event.Description__c);
                System.debug('Replacement: ' + description);
                event.Description__c = description;
            }
        }

        return events;
    }

    public static List<Disclosure_Audit_Event__c> auditEventsMigrateTloContact(
        List<Disclosure_Audit_Event__c> events
    ) {
        // Pattern to find the TLO_Contact__c/r ID within the description
        Pattern p = Pattern.compile('/TLO_Contact__(c|r)/(.*?)/view');
        // A set to store unique TLO_Contact__c IDs found in descriptions
        Set<String> contactIds = new Set<String>();

        // Extract TLO_Contact__c/r IDs from each event's description
        for (Disclosure_Audit_Event__c event : events) {
            Matcher m = p.matcher(event.Description__c);
            while (m.find()) {
                String contactId = m.group(2);
                contactIds.add(contactId);
            }
        }

        // Query the TLO_Contact__c records for those IDs to get the Person_Account__c field
        Map<Id, TLO_Contact__c> contactsMap = new Map<Id, TLO_Contact__c>(
            [
                SELECT Id, Person_Account__c
                FROM TLO_Contact__c
                WHERE Id IN :contactIds
            ]
        );

        // Update the description in each event
        for (Disclosure_Audit_Event__c event : events) {
            Matcher m = p.matcher(event.Description__c);
            String description = event.Description__c;
            boolean hasReplacement = false;

            while (m.find()) {
                String contactId = m.group(2);
                if (contactsMap.containsKey(contactId)) {
                    TLO_Contact__c contact = contactsMap.get(contactId);
                    // Construct the replacement string
                    String replacement =
                        '/Account/' +
                        contact.Person_Account__c +
                        '/view';
                    // Replace in the original description
                    description = description.replace(
                        '/TLO_Contact__' +
                        m.group(1) +
                        '/' +
                        contactId +
                        '/view',
                        replacement
                    );
                    hasReplacement = true;
                }
            }
            // Update the description if there was at least one replacement
            if (hasReplacement) {
                System.debug('Original: ' + event.Description__c);
                System.debug('Replacement: ' + description);
                event.Description__c = description;
            }
        }

        return events;
    }
}