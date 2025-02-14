public class ContactSampleDataFactory {
    public static void createSampleContacts() {
        System.debug('Contact: Existing Contact 1');
        // The MID Id is an existing value in Forrester.
        Account existingContact1 = new Account(
            // Name = 'John M Fox',
            AltEmail__pc = 'sample_jfox@mit.edu',
            CountryOfCitizenship__pc = 'United States of America',
            FirstName = 'John',
            GovernmentEmployeeStatus__pc = false,
            GuestAccountNeeded__pc = 'No',
            HHMI_Current__pc = true,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Fox',
            MiddleName = 'M',
            MitId__pc = '900047497',
            MoiraStatus__pc = '1',
            OldEmail__pc = null,
            PersonBirthdate = Date.newInstance(2000, 2, 14),
            PersonDepartment = 'Lincoln Laboratory',
            PersonEmail = 'sample_jfox@mit.edu',
            PersonMailingStreet = '244 Wood Street',
            PersonMailingCity = 'Lexington',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '19350',
            PersonMailingState = 'PA',
            PersonOtherPhone = '0612345678',
            PersonTitle = 'Lecturer',
            PersonMobilePhone = '0613245672',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'No'
        );
        insert existingContact1;

        System.debug('Contact: Sample Contact 1');
        Account sampleContact1 = new Account(
            // Name = 'TLO Contact 1',
            AltEmail__pc = 'tlo@advance.io',
            CountryOfCitizenship__pc = 'USA',
            FirstName = 'John',
            GovernmentEmployeeStatus__pc = false,
            GuestAccountNeeded__pc = 'No',
            HHMI_Current__pc = true,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Johnson',
            MiddleName = 'M',
            MitId__pc = '12345678',
            MoiraStatus__pc = '1',
            OldEmail__pc = 'old@yahoo.com',
            PersonBirthdate = Date.newInstance(2000, 2, 14),
            PersonDepartment = 'Lincoln Laboratory',
            PersonEmail = 'sample@mit.edu',
            PersonMailingCity = 'Lexington',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02421-6426',
            PersonMailingState = 'MA',
            PersonMailingStreet = '244 Wood Street',
            PersonOtherPhone = '0612345678',
            PersonTitle = 'Lab X Research Lead',
            PersonMobilePhone = '0613245672',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'No'
        );
        insert sampleContact1;

        System.debug('Contact: Sample Contact 2');
        Account sampleContact2 = new Account(
            // Name = 'Peter Ronaldo',
            AltEmail__pc = 'cr7@advance.io',
            CountryOfCitizenship__pc = 'USA',
            FirstName = 'Peter',
            Government_Agency_Name__pc = 'U.S. Air Force',
            GovernmentEmployeeStatus__pc = true,
            GuestAccountNeeded__pc = 'No',
            HHMI_Current__pc = false,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Ronaldo',
            MiddleName = 'M',
            MitId__pc = '777777777',
            MoiraStatus__pc = '1',
            OldEmail__pc = 'cr7@yahoo.com',
            PersonBirthdate = Date.newInstance(1999, 4, 4),
            PersonDepartment = 'Department of Physics',
            PersonEmail = 'cr7@mit.edu',
            PersonMailingStreet = '77 Massachusetts Avenue',
            PersonMailingCity = 'Cambridge',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02139',
            PersonMailingState = 'MA',
            PersonOtherPhone = '0612345678',
            PersonTitle = 'Lab X Research Assistant',
            PersonMobilePhone = '7815551234',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'Yes',
            VaAppointmentDetails__pc = 'Volunteer'
        );
        insert sampleContact2;

        System.debug('Contact: Sample NonMit Contact');
        Account sampleNonMitContact = new Account(
            // Name = 'Joe Ronaldo',
            AltEmail__pc = 'cr11@advance.io',
            CountryOfCitizenship__pc = 'USA',
            FirstName = 'Peter',
            Government_Agency_Name__pc = 'U.S. Air Force',
            GovernmentEmployeeStatus__pc = true,
            GuestAccountNeeded__pc = 'Yes',
            HHMI_Current__pc = false,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Ronaldo',
            MiddleName = 'M',
            MitId__pc = null,
            MoiraStatus__pc = '13',
            OldEmail__pc = 'cr11@yahoo.com',
            PersonBirthdate = Date.newInstance(1999, 4, 14),
            PersonDepartment = 'Department of Physics',
            PersonEmail = 'cr11@guest.test',
            PersonMailingStreet = '77 Massachusetts Avenue',
            PersonMailingCity = 'Cambridge',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02139',
            PersonMailingState = 'MA',
            PersonOtherPhone = '0612345678',
            PersonTitle = 'Lecturer',
            PersonMobilePhone = '7815551134',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'Yes',
            VaAppointmentDetails__pc = 'Volunteer'
        );
        insert sampleNonMitContact;

        System.debug('Contact: Sample NonMit Contact with MitId');
        Account sampleNonMitContactwithMitId = new Account(
            // Name = 'Joe Ronaldo',
            AltEmail__pc = 'cr13@advance.io',
            CountryOfCitizenship__pc = 'USA',
            FirstName = 'Peter',
            Government_Agency_Name__pc = 'U.S. Air Force',
            GovernmentEmployeeStatus__pc = true,
            GuestAccountNeeded__pc = 'Yes',
            HHMI_Current__pc = false,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Ronaldo',
            MiddleName = 'M',
            MitId__pc = '968581554',
            MoiraStatus__pc = '13',
            OldEmail__pc = 'cr11@yahoo.com',
            PersonBirthdate = Date.newInstance(1999, 4, 14),
            PersonDepartment = 'Department of Physics',
            PersonEmail = 'cr13@guest.test',
            PersonMailingStreet = '77 Massachusetts Avenue',
            PersonMailingCity = 'Cambridge',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02139',
            PersonMailingState = 'MA',
            PersonOtherPhone = '0612345678',
            PersonTitle = 'Lecturer',
            PersonMobilePhone = '7815551134',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'Yes',
            VaAppointmentDetails__pc = 'Volunteer'
        );
        insert sampleNonMitContactwithMitId;

        System.debug('Contact: Department Head Contact1');
        Account departmentHeadContact1 = new Account(
            // Name = 'TLO Department Head 1',
            AltEmail__pc = 'cr9@ll.mit.edu',
            CountryOfCitizenship__pc = 'USA',
            FirstName = 'Davis',
            GovernmentEmployeeStatus__pc = false,
            GuestAccountNeeded__pc = 'No',
            HHMI_Current__pc = false,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Smith',
            MitId__pc = '677777760',
            MoiraStatus__pc = '1',
            OldEmail__pc = 'cr9@yahoo.com',
            PersonBirthdate = Date.newInstance(1999, 4, 4),
            PersonDepartment = 'Department of Mathematics',
            PersonEmail = 'cr9@mit.edu',
            PersonMailingStreet = '60 Massachusetts Avenue',
            PersonMailingCity = 'Cambridge',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02139',
            PersonMailingState = 'MA',
            PersonOtherPhone = '0612345678',
            PersonTitle = 'Head of the Department of Research',
            PersonMobilePhone = '7815551236',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'No'
        );
        insert departmentHeadContact1;

        System.debug('Contact: Department Head Contact2');
        Account departmentHeadContact2 = new Account(
            // Name = 'Scott Tiger',
            AltEmail__pc = 'cr8@ll.mit.edu',
            CountryOfCitizenship__pc = 'USA',
            FirstName = 'Scott',
            GovernmentEmployeeStatus__pc = false,
            GuestAccountNeeded__pc = 'No',
            HHMI_Current__pc = false,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Tiger',
            MiddleName = 'M',
            MitId__pc = '777777778',
            MoiraStatus__pc = '1',
            OldEmail__pc = 'cr8@yahoo.com',
            PersonBirthdate = Date.newInstance(1999, 4, 4),
            PersonDepartment = 'Department of Physics',
            PersonEmail = 'cr8@mit.edu',
            PersonMailingStreet = '77 Massachusetts Avenue',
            PersonMailingCity = 'Cambridge',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02139',
            PersonMailingState = 'MA',
            PersonOtherPhone = '0612345678',
            PersonTitle = 'Head of the School of Development',
            PersonMobilePhone = '7815551235',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'No'
        );
        insert departmentHeadContact2;

        System.debug('TLO_Contact: piContact');
        Account piContact = new Account(
            // Name = 'Marcus Marx',
            AltEmail__pc = 'cr10@ll.mit.edu',
            CountryOfCitizenship__pc = 'USA',
            FirstName = 'Marcus',
            GovernmentEmployeeStatus__pc = false,
            GuestAccountNeeded__pc = 'No',
            HHMI_Current__pc = false,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Marx',
            MiddleName = 'M',
            MitId__pc = '777777700',
            MoiraStatus__pc = '1',
            OldEmail__pc = 'cr10@yahoo.com',
            PersonBirthdate = Date.newInstance(1999, 4, 4),
            PersonDepartment = 'Technology Licensing Office',
            PersonEmail = 'cr10@mit.edu',
            PersonMailingCity = 'Cambridge',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02139',
            PersonMailingState = 'MA',
            PersonMailingStreet = '55 Massachusetts Avenue',
            PersonOtherPhone = '0612345678',
            PersonTitle = 'Lead Principal Investigator',
            PersonMobilePhone = '7815551225',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'No'
        );
        insert piContact;

        System.debug('Contact: Submitting Contact');
        Account submittingContact = new Account(
            // Name = 'Geoff Geoff',
            AltEmail__pc = 'cr12@ll.mit.edu',
            CountryOfCitizenship__pc = 'USA',
            FirstName = 'Geoff',
            GovernmentEmployeeStatus__pc = false,
            GuestAccountNeeded__pc = 'No',
            HHMI_Current__pc = false,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Geoff',
            MiddleName = 'M',
            MitId__pc = '700000001',
            MoiraStatus__pc = '1',
            OldEmail__pc = 'cr12@yahoo.com',
            PersonBirthdate = Date.newInstance(1999, 4, 4),
            PersonDepartment = 'Technology Licensing Office',
            PersonEmail = 'cr12@mit.edu',
            PersonMailingCity = 'Cambridge',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02139',
            PersonMailingState = 'MA',
            PersonMailingStreet = '55 Massachusetts Avenue',
            PersonOtherPhone = '0612345678',
            PersonTitle = 'Lead Principal Investigator',
            PersonMobilePhone = '7815551325',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'No'
        );

        insert submittingContact;

        // TODO: Refactor with TLO_Officer__c
        System.debug('TLO_Contact: TLO Officer');
        TLO_Officer__c officerContact = new TLO_Officer__c(
            Email__c = 'cr20@mit.edu',
            Forrester_OfficerId__c = 'MB',
            MitId__c = '777773000',
            Name = 'Mary Baker'
        );
        insert officerContact;

        // TODO: Refactor with TLO_Officer__c
        // Name will be equal to OfficerId
        System.debug('TLO_Contact: TLO Officer with no Name');
        TLO_Officer__c officerNoName = new TLO_Officer__c(
            Email__c = 'cr22@mit.edu',
            Forrester_OfficerId__c = 'SAN',
            MitId__c = '777774001',
            Name = 'SAN'
        );
        insert officerNoName;
    }
     public static void createSampleQAContacts() {
        System.debug('Contact: Sample NonMit Contact with MitId and QA Okta Email');
        Account sampleNonMitContactwithMitId = new Account(
        // Name = 'Joe Ronaldo',
        AltEmail__pc = 'cr13@advance.io',
        CountryOfCitizenship__pc = 'USA',
        FirstName = 'Peter',
        Government_Agency_Name__pc = 'U.S. Air Force',
        GovernmentEmployeeStatus__pc = true,
        GuestAccountNeeded__pc = 'Yes',
        HHMI_Current__pc = false,
        HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
        Institution__pc = 'Massachusetts Institute of Technology',
        InstitutionCode__pc = '12345',
        InvitationCode__pc = '',
        KerbName__pc = 'kerb',
        LastName = 'Ronaldo',
        MiddleName = 'M',
        MitId__pc = '968581554',
        MoiraStatus__pc = '13',
        OldEmail__pc = 'cr11@yahoo.com',
        PersonBirthdate = Date.newInstance(1999, 4, 14),
        PersonDepartment = 'Department of Physics',
        PersonEmail = 'cr13+test@guest.test',
        PersonMailingStreet = '77 Massachusetts Avenue',
        PersonMailingCity = 'Cambridge',
        PersonMailingCountry = 'United States of America',
        PersonMailingPostalCode = '02139',
        PersonMailingState = 'MA',
        PersonOtherPhone = '0612345678',
        PersonTitle = 'Lecturer',
        PersonMobilePhone = '7815551134',
        PreferredName__pc = 'JJ',
        VaAppointment__pc = 'Yes',
        VaAppointmentDetails__pc = 'Volunteer'
        );
        insert sampleNonMitContactwithMitId;
     }

     // Using people search to view a contact
     public static Account createJITContactManual() {

        Account sample = new Account(
             AltEmail__pc = 'ben@utexas.edu',
             FirstName = 'Ben' ,
             GuestAccountNeeded__pc = 'No',
             IsAlumni__pc = false,
             KerbName__pc = 'ben',
             LastName = 'Dell',
             MitId__pc = '914138251',
             MoiraStatus__pc = '10',
             PersonEmail = 'ben@mit.edu',
             PersonOtherPhone =  '7815551134',
             PreferredName__pc = 'Benjamin'
             );
        insert sample;
        return sample;

     }

}