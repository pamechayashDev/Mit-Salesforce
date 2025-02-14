public class TloContactSampleFactory {
    public static void createSampleTloContacts() {
        System.debug('TLO_Contact: existingContact1');
        // The MID Id is an existing value in Forrester.
        TLO_Contact__c existingContact1 = new TLO_Contact__c(
                                Address__c = '244 Wood Street',
                                AltEmail__c = 'sample_jfox@mit.edu',
                                AltPhone__c = '0612345678',
                                Birthday__c = Date.newInstance(2000, 2, 14),
                                City__c = 'Lexington',
                                Country__c = 'United States of America',
                                CountryOfCitizenship__c = 'United States of America',
                                Department__c = 'Lincoln Laboratory',
                                Email__c = 'sample_jfox@mit.edu',
                                GovernmentEmployeeStatus__c = False,
                                HHMI_Current__c = true,
                                HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                                Institution__c = 'Massachusetts Institute of Technology',
                                InstitutionCode__c = '12345',
                                PreferredName__c = 'JJ',
                                LegalGivenName__c = 'John',
                                LegalMiddleName__c = 'M',
                                LegalLastName__c = 'Fox',
                                MitId__c = '900047497',
                                OldEmail__c = null,
                                Phone__c = '0613245672',
                                Title__c = 'Lecturer',
                                State__c = 'PA',
                                VaAppointment__c = 'No',
                                Name = 'John M Fox',
                                ZipCode__c = '19350',
                                InvitationCode__c = '',
                                GuestAccountNeeded__c = 'No',
                                KerbName__c = 'kerb',
                                MoiraStatus__c = '1'
                            );
        insert existingContact1;


        System.debug('TLO_Contact: sampleContact1');
        TLO_Contact__c sampleContact1 = new TLO_Contact__c(
                                Address__c = '244 Wood Street',
                                AltEmail__c = 'tlo@advance.io',
                                AltPhone__c = '0612345678',
                                Birthday__c = Date.newInstance(2000, 2, 14),
                                City__c = 'Lexington',
                                Country__c = 'United States of America',
                                CountryOfCitizenship__c = 'USA',
                                Department__c = 'Lincoln Laboratory',
                                Email__c = 'sample@mit.edu',
                                GovernmentEmployeeStatus__c = False,
                                HHMI_Current__c = true,
                                HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                                Institution__c = 'Massachusetts Institute of Technology',
                                InstitutionCode__c = '12345',
                                PreferredName__c = 'JJ',
                                LegalGivenName__c = 'John',
                                LegalMiddleName__c = 'M',
                                LegalLastName__c = 'Johnson',
                                MitId__c = '12345678',
                                OldEmail__c = 'old@yahoo.com',
                                Phone__c = '0613245672',
                                State__c = 'MA',
                                VaAppointment__c = 'No',
                                Name = 'TLO Contact 1',
                                ZipCode__c = '02421-6426',
                                Title__c = 'Lab X Research Lead',
                                InvitationCode__c = '',
                                GuestAccountNeeded__c = 'No',
                                KerbName__c = 'kerb',
                                MoiraStatus__c = '1'
                            );
        insert sampleContact1;

        System.debug('TLO_Contact: sampleContact2');
        TLO_Contact__c sampleContact2 = new TLO_Contact__c(
                                Address__c = '77 Massachusetts Avenue',
                                AltEmail__c = 'cr7@advance.io',
                                AltPhone__c = '0612345678',
                                Birthday__c = Date.newInstance(1999, 4, 4),
                                City__c = 'Cambridge',
                                Country__c = 'United States of America',
                                CountryOfCitizenship__c = 'USA',
                                Department__c = 'Department of Physics',
                                Email__c = 'cr7@mit.edu',
                                GovernmentEmployeeStatus__c = True,
                                Government_Agency_Name__c = 'U.S. Air Force',
                                HHMI_Current__c = false,
                                HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                                Institution__c = 'Massachusetts Institute of Technology',
                                InstitutionCode__c = '12345',
                                PreferredName__c = 'JJ',
                                LegalGivenName__c = 'Peter',
                                LegalMiddleName__c = 'M',
                                LegalLastName__c = 'Ronaldo',
                                MitId__c = '777777777',
                                OldEmail__c = 'cr7@yahoo.com',
                                Phone__c = '7815551234',
                                State__c = 'MA',
                                VaAppointment__c = 'Yes',
                                VaAppointmentDetails__c = 'Volunteer',
                                Name = 'Peter Ronaldo',
                                ZipCode__c = '02139',
                                Title__c = 'Lab X Research Assistant',
                                InvitationCode__c = '',
                                GuestAccountNeeded__c = 'No',
                                KerbName__c = 'kerb',
                                MoiraStatus__c = '1'
                            );
        insert sampleContact2;

        System.debug('TLO_Contact: sampleNonMitContact');
        TLO_Contact__c sampleNonMitContact = new TLO_Contact__c(
                                Address__c = '77 Massachusetts Avenue',
                                AltEmail__c = 'cr11@advance.io',
                                AltPhone__c = '0612345678',
                                Birthday__c = Date.newInstance(1999, 4, 14),
                                City__c = 'Cambridge',
                                Country__c = 'United States of America',
                                CountryOfCitizenship__c = 'USA',
                                Department__c = 'Department of Physics',
                                Email__c = 'cr11@guest.test',
                                GovernmentEmployeeStatus__c = True,
                                Government_Agency_Name__c = 'U.S. Air Force',
                                HHMI_Current__c = false,
                                HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                                Institution__c = 'Massachusetts Institute of Technology',
                                InstitutionCode__c = '12345',
                                PreferredName__c = 'JJ',
                                LegalGivenName__c = 'Peter',
                                LegalMiddleName__c = 'M',
                                LegalLastName__c = 'Ronaldo',
                                MitId__c = null,
                                OldEmail__c = 'cr11@yahoo.com',
                                Phone__c = '7815551134',
                                State__c = 'MA',
                                VaAppointment__c = 'Yes',
                                VaAppointmentDetails__c = 'Volunteer',
                                Name = 'Joe Ronaldo',
                                ZipCode__c = '02139',
                                Title__c = 'Lecturer',
                                InvitationCode__c = '',
                                KerbName__c = 'kerb',
                                GuestAccountNeeded__c = 'Yes',
                                MoiraStatus__c = '13'
                            );
        insert sampleNonMitContact;

        System.debug('TLO_Contact: sampleNonMitContactwithMitId');
        TLO_Contact__c sampleNonMitContactwithMitId = new TLO_Contact__c(
                                Address__c = '77 Massachusetts Avenue',
                                AltEmail__c = 'cr13@advance.io',
                                AltPhone__c = '0612345678',
                                Birthday__c = Date.newInstance(1999, 4, 14),
                                City__c = 'Cambridge',
                                Country__c = 'United States of America',
                                CountryOfCitizenship__c = 'USA',
                                Department__c = 'Department of Physics',
                                Email__c = 'cr13@guest.test',
                                GovernmentEmployeeStatus__c = True,
                                Government_Agency_Name__c = 'U.S. Air Force',
                                HHMI_Current__c = false,
                                HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                                Institution__c = 'Massachusetts Institute of Technology',
                                InstitutionCode__c = '12345',
                                PreferredName__c = 'JJ',
                                LegalGivenName__c = 'Peter',
                                LegalMiddleName__c = 'M',
                                LegalLastName__c = 'Ronaldo',
                                MitId__c = '968581554',
                                OldEmail__c = 'cr11@yahoo.com',
                                Phone__c = '7815551134',
                                State__c = 'MA',
                                VaAppointment__c = 'Yes',
                                VaAppointmentDetails__c = 'Volunteer',
                                Name = 'Joe Ronaldo',
                                ZipCode__c = '02139',
                                Title__c = 'Lecturer',
                                InvitationCode__c = '',
                                KerbName__c = 'kerb',
                                GuestAccountNeeded__c = 'Yes',
                                MoiraStatus__c = '13'
                            );
        insert sampleNonMitContactwithMitId;

        System.debug('TLO_Contact: departmentHeadContact1');
        TLO_Contact__c departmentHeadContact1 = new TLO_Contact__c(
                                Address__c = '60 Massachusetts Avenue',
                                AltEmail__c = 'cr9@ll.mit.edu',
                                AltPhone__c = '0612345678',
                                Birthday__c = Date.newInstance(1999, 4, 4),
                                City__c = 'Cambridge',
                                Country__c = 'United States of America',
                                CountryOfCitizenship__c = 'USA',
                                Department__c = 'Department of Mathematics',
                                Email__c = 'cr9@mit.edu',
                                GovernmentEmployeeStatus__c = False,
                                HHMI_Current__c = false,
                                HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                                Institution__c = 'Massachusetts Institute of Technology',
                                InstitutionCode__c = '12345',
                                PreferredName__c = 'JJ',
                                LegalGivenName__c = 'Davis',
                                LegalLastName__c = 'Smith',
                                MitId__c = '677777760',
                                OldEmail__c = 'cr9@yahoo.com',
                                Phone__c = '7815551236',
                                State__c = 'MA',
                                VaAppointment__c = 'No',
                                Name = 'TLO Department Head 1',
                                ZipCode__c = '02139',
                                Title__c = 'Head of the Department of Research',
                                InvitationCode__c = '',
                                GuestAccountNeeded__c = 'No',
                                KerbName__c = 'kerb',
                                MoiraStatus__c = '1'
                            );
        insert departmentHeadContact1;

        System.debug('TLO_Contact: departmentHeadContact2');
        TLO_Contact__c departmentHeadContact2 = new TLO_Contact__c(
                                Address__c = '77 Massachusetts Avenue',
                                AltEmail__c = 'cr8@ll.mit.edu',
                                AltPhone__c = '0612345678',
                                Birthday__c = Date.newInstance(1999, 4, 4),
                                City__c = 'Cambridge',
                                Country__c = 'United States of America',
                                CountryOfCitizenship__c = 'USA',
                                Department__c = 'Department of Physics',
                                Email__c = 'cr8@mit.edu',
                                GovernmentEmployeeStatus__c = False,
                                HHMI_Current__c = false,
                                HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                                Institution__c = 'Massachusetts Institute of Technology',
                                InstitutionCode__c = '12345',
                                PreferredName__c = 'JJ',
                                LegalGivenName__c = 'Scott',
                                LegalMiddleName__c = 'M',
                                LegalLastName__c = 'Tiger',
                                MitId__c = '777777778',
                                OldEmail__c = 'cr8@yahoo.com',
                                Phone__c = '7815551235',
                                State__c = 'MA',
                                VaAppointment__c = 'No',
                                Name = 'Scott Tiger',
                                ZipCode__c = '02139',
                                Title__c = 'Head of the School of Development',
                                InvitationCode__c = '',
                                GuestAccountNeeded__c = 'No',
                                KerbName__c = 'kerb',
                                MoiraStatus__c = '1'
                            );
        insert departmentHeadContact2;

        System.debug('TLO_Contact: piContact');
        TLO_Contact__c piContact = new TLO_Contact__c(
                                Address__c = '55 Massachusetts Avenue',
                                AltEmail__c = 'cr10@ll.mit.edu',
                                AltPhone__c = '0612345678',
                                Birthday__c = Date.newInstance(1999, 4, 4),
                                City__c = 'Cambridge',
                                Country__c = 'United States of America',
                                CountryOfCitizenship__c = 'USA',
                                Department__c = 'Technology Licensing Office',
                                Email__c = 'cr10@mit.edu',
                                GovernmentEmployeeStatus__c = False,
                                HHMI_Current__c = false,
                                HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                                Institution__c = 'Massachusetts Institute of Technology',
                                InstitutionCode__c = '12345',
                                PreferredName__c = 'JJ',
                                LegalGivenName__c = 'Marcus',
                                LegalMiddleName__c = 'M',
                                LegalLastName__c = 'Marx',
                                MitId__c = '777777700',
                                OldEmail__c = 'cr10@yahoo.com',
                                Phone__c = '7815551225',
                                State__c = 'MA',
                                VaAppointment__c = 'No',
                                Name = 'Marcus Marx',
                                ZipCode__c = '02139',
                                Title__c = 'Lead Principal Investigator',
                                InvitationCode__c = '',
                                GuestAccountNeeded__c = 'No',
                                KerbName__c = 'kerb',
                                MoiraStatus__c = '1'
                            );
        insert piContact;



    System.debug('TLO_Contact: submittingContact');
    TLO_Contact__c submittingContact = new TLO_Contact__c(
                            Address__c = '55 Massachusetts Avenue',
                            AltEmail__c = 'cr12@ll.mit.edu',
                            AltPhone__c = '0612345678',
                            Birthday__c = Date.newInstance(1999, 4, 4),
                            City__c = 'Cambridge',
                            Country__c = 'United States of America',
                            CountryOfCitizenship__c = 'USA',
                            Department__c = 'Technology Licensing Office',
                            Email__c = 'cr12@mit.edu',
                            GovernmentEmployeeStatus__c = False,
                            HHMI_Current__c = false,
                            HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                            Institution__c = 'Massachusetts Institute of Technology',
                            InstitutionCode__c = '12345',
                            PreferredName__c = 'JJ',
                            LegalGivenName__c = 'Geoff',
                            LegalMiddleName__c = 'M',
                            LegalLastName__c = 'Geoff',
                            MitId__c = '700000001',
                            OldEmail__c = 'cr12@yahoo.com',
                            Phone__c = '7815551325',
                            State__c = 'MA',
                            VaAppointment__c = 'No',
                            Name = 'Geoff Geoff',
                            ZipCode__c = '02139',
                            Title__c = 'Lead Principal Investigator',
                            InvitationCode__c = '',
                            GuestAccountNeeded__c = 'No',
                            KerbName__c = 'kerb',
                            MoiraStatus__c = '1'
                        );
    insert submittingContact;


    System.debug('TLO_Contact: TLO Officer');
    TLO_Officer__c officerContact = new TLO_Officer__c(
                            Email__c = 'cr20@mit.edu',
                            Forrester_OfficerId__c = 'MB',
                            MitId__c = '777773000',
                            Name = 'Mary Baker'

                        );
    insert officerContact;

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
}