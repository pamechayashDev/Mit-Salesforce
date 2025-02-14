/**
 * Functions to be used in the creation of Sample Data 
 */
public with sharing class SampleDataFactory {

    public static TLO_Officer__c createTLOOfficer(String officerId, String name, String mitId) {
        TLO_Officer__c officer = new TLO_Officer__c(
                                Name = 'TLO Officer '+ name,
                                Email__c = name + '_tlo_sample@mit.edu',
                                Forrester_OfficerId__c = officerId,
                                MitId__c = mitId
                                );
         insert officer;
         return officer;
    }

    public static Account createContact(String name, Boolean mitInventor, String mitId) {
        Account sampleContact = new Account(
            // Record Type
            RecordTypeId = ShirleyConstants.PERSON_ACCOUNT_RECORD_TYPE_ID,
            // Address Info
            PersonMailingStreet = '244 Wood Street',
            PersonMailingCity = 'Lexington',
            PersonMailingState = 'MA',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02421-6426',
            // Biographic Info
            MitId__pc = mitId,
            KerbName__pc = 'kerb',
            MoiraStatus__pc = mitInventor ? '1' : '3',
            PreferredName__pc = 'JJ',
            FirstName = name,
            MiddleName = name,
            LastName = name,
            PersonTitle = 'Prof',
            PersonBirthdate = Date.newInstance(2000, 2, 14),
            CountryOfCitizenship__pc = 'USA',
            // Contact Info
            PersonEmail = name + (mitInventor ? '_sample@mit.edu' : '_sample@external.com'),
            AltEmail__pc = name + (mitInventor ? '_sample@ll.mit.edu' : '_sample@external.com'),
            OldEmail__pc = 'old@yahoo.com',
            PersonMobilePhone = '0613245672',
            PersonOtherPhone = '0612345678',
            // Misc
            PersonDepartment = 'Computer Science',
            Government_Agency_Name__pc = 'Federal Bureau of Investigation',
            GovernmentEmployeeStatus__pc = False,
            GuestAccountNeeded__pc = 'No',
            HHMI_Current__pc = true,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '824',
            InvitationCode__pc = '',
            VaAppointment__pc = 'No'
        );
        insert sampleContact;
        return sampleContact;
    }

    public static TLO_Contact__c createTLOContact(String name, Boolean mitInventor, String mitId) {
        TLO_Contact__c sampleContact = new TLO_Contact__c(
                                Address__c = '244 Wood Street',
                                AltEmail__c = name + (mitInventor ? '_sample@ll.mit.edu' : '_sample@external.com'),
                                AltPhone__c = '0612345678',
                                Birthday__c = Date.newInstance(2000, 2, 14),
                                City__c = 'Lexington',
                                Country__c = 'United States of America',
                                CountryOfCitizenship__c = 'USA',
                                Department__c = 'Computer Science',
                                Email__c = name + (mitInventor ? '_sample@mit.edu' : '_sample@external.com'),
                                GovernmentEmployeeStatus__c = False,
                                Government_Agency_Name__c = 'Federal Bureau of Investigation',
                                HHMI_Current__c = true,
                                HHMI_Current_Date_From__c = Date.newInstance(2023, 2, 14),
                                Institution__c = 'Massachusetts Institute of Technology',
                                InstitutionCode__c = '824',
                                PreferredName__c = 'JJ',
                                LegalGivenName__c = name,
                                LegalMiddleName__c = name,
                                LegalLastName__c = name,
                                MitId__c = mitId,
                                OldEmail__c = 'old@yahoo.com',
                                Phone__c = '0613245672',
                                State__c = 'MA',
                                Title__c = 'Prof',
                                VaAppointment__c = 'No',
                                Name = 'TLO Contact '+ name,
                                ZipCode__c = '02421-6426',
                                InvitationCode__c = '',
                                GuestAccountNeeded__c = 'No',
                                KerbName__c = 'kerb',
                                MoiraStatus__c = mitInventor ? '1' : '3'
                            );
        insert sampleContact;
        return sampleContact;
    }

    /**
    * Disclosure Inventor creation to be used throughout
    */
    public static DisclosureInventor__c createInventor(Disclosure__c disclosure, Boolean primary, Account contact) {
        DisclosureInventor__c sampleInventor1 = new DisclosureInventor__c(
                                    MitAtTimeOfInvention__c = true,
                                    PrimaryInventor__c = primary,
                                    Signed_Status__c = 'Pending',
                                    Signed_Disclosure_Date__c = null,
                                    Submitter_Marked_Inventor_As_HHMI__c = true,
                                    HHMI_At_Time_of_Invention__c = true,
                                    HHMI_tenure_date_from__c = Date.newInstance(2023, 2, 14),
                                    HHMI_tenure_date_to__c = Date.newInstance(2023, 2, 14),
                                    Contact__c = contact.Id,
                                    Disclosure__c = disclosure.Id
                                );
        insert sampleInventor1;
        return sampleInventor1;
    }
    
     /**
        * Disclosure Inventor add additional questions
        */
    public static void addInventorExtraQuestion(DisclosureInventor__c disclosureInventor){

           List<DisclosureInventor__c> result = DisclosureRecordFetch.getDisclosureInventorByDisclosureId(disclosureInventor.Disclosure__c);
           List<DisclosureInventor__c> updateList = new List<DisclosureInventor__c>();
            for (DisclosureInventor__c inventor : result) {
                if (inventor.Id == disclosureInventor.Id ){

                     inventor.SalaryWages__c = 'MIT';
                     inventor.SalaryWagesDetails__c = 'SalaryWagesDetails 1';
                     inventor.WorkDoneAtMIT__c = 'Yes';
                     inventor.WorkDoneOutsideMIT__c = 'Yes';
                     inventor.WorkDoneOutsideMITDetails__c = 'WorkDoneOutsideMITDetails 1';
                     inventor.Collaboration__c = 'Yes';
                     inventor.CollaborationDetails__c = 'CollaborationDetails 1';
                     inventor.ConsultantOrContract__c = 'Yes';
                     inventor.ConsultantOrContractDetails__c = 'ConsultantOrContractDetails 1';
                     inventor.FundingThroughDlc__c = 'BitsAndAtoms';
                     inventor.AffiliatedWithOrgsDlcs__c = 'Wyss;Whitehead';
                     inventor.AdditionalSponsorsOrFunding__c = 'AdditionalSponsorsOrFunding 1';
                     inventor.PartOfClass__c = 'Yes';
                     inventor.PartOfClassDetails__c = 'PartOfClassDetails 1';
                     inventor.ThirdPartyMaterials__c = 'ThirdPartyMaterials 1';
                     inventor.AdditionalComments__c = 'AdditionalComments 1';
                     updateList.add(inventor);
                }
            }
            update updateList;
    }

    /**
    * Disclosure creation function
    */ 
    public static Disclosure__c createDisclosure(Id recordTypeId, String name, String status, Account submittingContact) {
        Disclosure__c sampleDisclosure = new Disclosure__c(
                                        Name__c = name,
                                        RecordTypeId = recordTypeId,
                                        Description__c = 'This is a sample disclosure object',
                                        Funding_Details__c = 'Funding details',
                                        Status__c = status,
                                        SubmittedOnBehalf__c = false,
                                        Submitted_Date__c =  Date.valueOf('2023-03-15'),
                                        Submitting_Contact__c = submittingContact.Id,
                                        Disclosure_Reason__c = 'StartupCompany;ComplyWithObligations',
                                        Disclosure_Reason_Comment__c = 'N/A'
                                    );
        insert sampleDisclosure;
        return sampleDisclosure;
    }

    /**
    * Disclosure Submitting On Behalf Of creation function
    */ 
    public static Disclosure__c createDisclosureSOB(Id recordTypeId, String name, String status, Account submittingContact) {
        Disclosure__c sampleDisclosure = new Disclosure__c(
                                        Name__c = name,
                                        RecordTypeId = recordTypeId,
                                        Description__c = 'This is a sample disclosure object-SOB',
                                        Funding_Details__c = 'Funding details',
                                        Status__c = status,
                                        SubmittedOnBehalf__c = true,
                                        Submitted_Date__c =  Date.valueOf('2023-04-03'),
                                        Submitting_Contact__c = submittingContact.Id,
                                        Disclosure_Reason__c = 'Other',
                                        Disclosure_Reason_Comment__c = 'Reason Other Comment'
                                    );
        insert sampleDisclosure;
        return sampleDisclosure;
    }

    /**
    * BioTang object creation
    */
    public static BioTang_Disclosure__c createBioTang(String name, Disclosure__c disclosure, Id recordTypeId, Account piContact, Account mitShipper) {
        BioTang_Disclosure__c sampleBio = new BioTang_Disclosure__c(
                                Name = name,
                                Disclosure__c = disclosure.Id,
                                Collaborators_Detail__c = 'Collaborators Detail',
                                depositAndDistribution__c = 'Deposit and Distribution',
                                depositedAtRepository__c = 'Unknown',
                                frequencyOfRequests__c = 27,
                                materialsFromOtherLabs__c = 'Yes',
                                materialsFurtherComments__c = 'Comments about materials',
                                MIT_Point_of_Contact_Acc__c = piContact.Id,
                                MIT_Shipper_Acc__c = mitShipper.Id,
                                publications__c = 'Yes',
                                publicationsLinkToRef__c = 'www.google.com',
                                RecordTypeId = recordTypeId,
                                repositoryDetails__c = 'Details about the repository',
                                wasDevAsPartOfCollaboration__c = 'Unknown'
                            );
        insert sampleBio;
        return sampleBio;
    }

    /**
    * Cell Line object creation
    */
    public static void createCellLine(String name, BioTang_Disclosure__c biotang) {
        Cell_Line__c cellSample = new Cell_Line__c(
                                Name = name,
                                bioTangDisclosure__c = biotang.Id
                            );
        
        insert cellSample;
    }

    /**
    * Mouse Strain object creation
    */
    public static void createMouseStrain(String name, BioTang_Disclosure__c biotang) {
        Mouse_Strain__c mouseSample = new Mouse_Strain__c(
                                Name = name,
                                bioTangDisclosure__c = biotang.Id,
                                maintenanceAndBreeding__c = 'Maintenance and Breeding',
                                Mouse_Gen_Cross_Other__c = true,
                                Mouse_Strain_Gen_Details__c = 'Details about mouse gen'
                            );
        
        insert mouseSample;
    }

    /**
    * Other Material object creation
    */
    public static void createOtherMaterial(String name, BioTang_Disclosure__c biotang) {
        Other_Material__c otherSample = new Other_Material__c(
                                Name = name,
                                bioTangDisclosure__c = biotang.Id
                            );
        
        insert otherSample;
    }

    /**
    * Antibody object creation
    */
    public static void createAntibody(String name, BioTang_Disclosure__c biotang) {
        Antibody__c otherSample = new Antibody__c(
                                Name = name,
                                bioTangDisclosure__c = biotang.Id,
                                antibodyValidApplications__c = 'Immunohistochemistry;Immunoprecipitation;Western Blotting',
                                antibodyValidAppOther__c = 'Other app',
                                isPurificationRequired__c = 'Unknown'
                            );
        
        insert otherSample;
    }

    /**
    * Plasmid object creation
    */
    public static void createPlasmid(String name, BioTang_Disclosure__c biotang) {
        Plasmid__c plasmidSample = new Plasmid__c(
                                Name = name,
                                bioTangDisclosure__c = biotang.Id
                            );
        
        insert plasmidSample;
    }

    /**
    * Lab materials object creation
    */
    public static void createLabMaterials(String name, BioTang_Disclosure__c biotang) {
        Lab_Materials__c labSample = new Lab_Materials__c(
                                Name = name,
                                BioTang_Disclosure__c = biotang.Id,
                                How_Was_Material_Obtained__c = 'MTA',
                                Material_Obtained_Other_Desc__c = 'Material obtained other description',
                                Source__c = 'Source'
                            );
        
        insert labSample;
    }

    /**
    * Invention Disclosure object creation
    */
    public static Invention_Disclosure__c createInvention(String name, Disclosure__c disclosure) {
        Invention_Disclosure__c sampleInvention = new Invention_Disclosure__c(
                                Disclosure_Anticipated_Publication__c = 'Yes',
                                Anticipated_Publication_Comment__c = 'Anticipated publication comment',
                                Anticipated_Publication_Disclosure_Date__c = Date.newInstance(2022, 8, 14),
                                Conception_Comment__c = 'Comment about conception',
                                Conception_Date__c =  Date.newInstance(2022, 3, 3),
                                Disclosure__c = disclosure.Id,
                                First_Oral_Disclosure_Comment__c = 'First oral disclosure comment',
                                First_Publication_Comment__c = 'First publication comment',
                                Name = name,
                                Oral_Disclosure_Date__c = Date.newInstance(2007, 2, 2),
                                Disclosure_Oral_Presentation__c = 'Yes',
                                Disclosure_Part_Of_Thesis__c = 'Yes',
                                Publication_Date__c = Date.newInstance(2009, 2, 2),
                                Disclosure_Published_Or_Disclosed__c = 'Yes',
                                Disclosure_Reduced_To_Practice__c = 'Yes',
                                Reduced_To_Practice_Comment__c = 'Comment about reduced to practice',
                                Reduced_To_Practice_Date__c = Date.newInstance(2004, 5, 5),
                                Disclosure_Thesis_Hold__c = 'Yes',
                                Type_Of_Presentation__c = 'Written Materials;Oral Disclosure',
                                Invention_Categorization__c = 'Invention category',
                                Materials_From_Other_Labs__c = 'Yes',
                                materialsFurtherComments__c = 'Comments about materials'
                            );
        insert sampleInvention;
        return sampleInvention;
    }

    /**
    * Thesis Disclosure object creation
    */
    public static void createThesis(String name, Invention_Disclosure__c invention) {
        Thesis__c thesisSample = new Thesis__c(
                                Invention_Disclosure__c = invention.Id,
                                Thesis_Comment__c = 'Comments about a Thesis',
                                Thesis_Defense_Date__c = Date.newInstance(2024, 1, 1),
                                Thesis_Degree_Date__c = Date.newInstance(2020, 1, 1),
                                Name = name,
                                Thesis_Submitted_Date__c = Date.newInstance(2020, 7, 7),
                                Thesis_Type__c = 'Masters',
                                Name_of_Student__c = 'Thesis von Student'
        );

        insert thesisSample;
    }

    /**
    * Invention Disclosure Third Party Material creation
    * Comments are mandatory unless no materials used
    */
    public static void createThirdPartyMaterial(String comments, Invention_Disclosure__c invention) {
        Third_Party_Material__c material = new Third_Party_Material__c(
                                Invention_Disclosure__c = invention.Id,
                                How_Was_Material_Obtained__c = 'MTA',
                                Source__c = 'MIT',
                                Name = 'Third party material Name',
                                Material_Obtained_Comment__c = comments

        );

        insert material;
    }



    /**
    * Software Code Disclosure object creation
    */
    public static Software_Code_Disclosure__c createSoftwareCode(String name, Disclosure__c disclosure) {
        Software_Code_Disclosure__c sampleSoftware = new Software_Code_Disclosure__c(
                                Disclosure__c = disclosure.Id,
                                Is_Open_Source_YN__c = 'Yes',
                                Part_Of_Employment_YN__c = 'Yes',
                                Open_Source_Comment__c = 'Open Source In what manner do you plan to release and/or distribute this software',
                                Name = name,
                                Existing_Disclosure_Comment__c = 'This is a comment about existing disclosure',
                                Years_Code_First_Created__c = '2020, 2021',
                                Years_Code_First_Published__c = '2020, 2021',
                                Encompass_AI_Or_Machine_Learning__c = 'Yes',
                                Algorithm_or_Patentable_Invention__c = 'Yes',
                                Derivative__c = 'Yes, internally developed and MIT-owned',
                                Software_Categorization__c = 'Software_ categorization',
                                Source_of_Training_Data__c = 'Our own;Public source;Other',
                                Source_of_Training_Details__c = 'Source of training details',
                                Use_Any_Third_Party_Code__c = 'Yes'
        );

        insert sampleSoftware;
        return sampleSoftware;
    }

    /**
    * Copyright Disclosure object creation
    */
    public static Copyright_Disclosure__c createCopyright(String name, Disclosure__c disclosure, Account piContact) {
        Copyright_Disclosure__c sampleCopyright = new Copyright_Disclosure__c (
                                Name = name.abbreviate(79),
                                Creators_Request_Distrib_Open_Source_YN__c = 'Yes',
                                Incorporate_Third_Party_Content__c = 'Yes',
                                MIT_Point_of_Contact_Acc__c = (piContact != null) ? piContact.Id : null,
                                Disclosure__c = disclosure.Id,
                                Copyright_Categorization__c = 'Sample Data Categorization',
                                Part_Of_Employment_YN__c = 'Yes',
                                Years_Code_First_Created__c = '2022, 2023',
                                Years_Code_First_Published__c = '2022, 2023'
        );

        insert sampleCopyright;
        return sampleCopyright;
    }

    /**
    * Open Source object creation.
    */
    public static Open_Source__c createOpenSource(String name, Copyright_Disclosure__c copyright, Software_Code_Disclosure__c software) {
        Id recordTypeId;
        if (copyright != null) {
            recordTypeId = Schema.SObjectType.Open_Source__c.getRecordTypeInfosByDeveloperName().get('Copyright_Disclosure').getRecordTypeId();
        }else {
            recordTypeId = Schema.SObjectType.Open_Source__c.getRecordTypeInfosByDeveloperName().get('Software_Code_Disclosure').getRecordTypeId();
        }

        Open_Source__c sampleOpenSource = new Open_Source__c(
                                Copyright_Disclosure__c = (copyright != null) ? copyright.Id : null,
                                Open_Source_Licensing_Type__c = 'Other',
                                RecordTypeId = recordTypeId,
                                Open_Source_Licensing__c = true,
                                Name = name,
                                Open_Source_Other_Comments__c = 'Other comments about open source',
                                Publicly_Available_Details__c = 'Publicly available details',
                                Software_Code_Disclosure__c = (software != null) ? software.Id : null
        );

        insert sampleOpenSource;
        return sampleOpenSource;
    }

    /**
    * Third Party Code object creation
    */
    public static Third_Party_Code__c createThirdPartyCode(String name, Software_Code_Disclosure__c software) {
        Third_Party_Code__c sampleThirdParty = new Third_Party_Code__c(
                                Is_Code_Available_On_Web__c = true,
                                License_Type__c = 'Motorcycle License',
                                Software_Code_Disclosure__c = software.Id,
                                Name = name,
                                Web_Page_Third_Party_License__c = 'Web page third party license',
                                Web_Page_To_Download_Code__c = 'www.google.com'
        );

        insert sampleThirdParty;
        return sampleThirdParty;
    }

    /**
    * Third Party Content object creation
    */
    public static Third_Party_Content__c createThirdPartyContent(String name, Copyright_Disclosure__c copyright) {
        Third_Party_Content__c sampleThirdParty = new Third_Party_Content__c(
                                Copyright_Disclosure__c = copyright.Id,
                                Name = name,
                                Attachment_Comment__c = 'Attachment Comment',
                                Source__c = 'Source'
        );

        insert sampleThirdParty;
        return sampleThirdParty;
    }

    /**
    * Department Head object creation
    */
    public static Department_Head__c createDepartmentHead(Disclosure__c disclosure, Account sampleContact){
        Department_Head__c depHead = new Department_Head__c(
                            Disclosure__c = disclosure.Id,
                            Signed_Date__c = Date.newInstance(2020, 7, 7),
                            Contact__c = sampleContact.Id
        );

        insert depHead;
        return depHead;
    }

    /**
    * Disclosure External Funding object creation
    */
    public static void createDisclosureExternalFunding(Disclosure__c disclosure, String grantNum, String ospAwardId, Account pi, String sponsor) {
        if (pi == null) {
            pi = createContact('John', true, '987123654');
        }
        DisclosureExternalFunding__c funding = new DisclosureExternalFunding__c(
            Disclosure__c = disclosure.Id,
            GrantOrContactNumber__c = grantNum,
            Award_Id__c = ospAwardId,
            Award_Title__c = 'Sample Award',
            Manual_Name__c = 'Manual Name',
            PI_Acc__c = pi.Id,
            Sponsor_Code__c = sponsor,
            Sponsor_Name__c = 'Sample Sponsor'
        );

        insert funding;
    }

    /**
    * Disclosure Internal Funding object creation
    */
    public static void createDisclosureInternalFunding(Disclosure__c disclosure, String costObjectKnown, String costObjectNumber, String fundingDetails) {
        if(String.isNotEmpty(costObjectNumber) && costObjectNumber.length() > 7) {
            costObjectNumber = costObjectNumber.substring(0, 7);
        }
        DisclosureInternalFunding__c funding = new DisclosureInternalFunding__c(
            Disclosure__c = disclosure.Id,
            CostObjectKnown__c = costObjectKnown,
            CostObjectNumber__c = costObjectNumber,
            FundingDetails__c = fundingDetails
        );
        insert funding;
    }

    public static void createCommercialInterest(Disclosure__c disclosure){
        Commercial_Interest__c commInt = new Commercial_Interest__c(
                            Company_Name__c = 'Advance',
                            Contact_Email__c = 'cr7@gmail.com',
                            Contact_Name__c = 'Cristiano Ronaldo',
                            Disclosure__c = disclosure.Id
        );

        insert commInt;
    }


    public static void updateFile(String subTypeClassification, String fileName, String fileType ,String linkedEntityId) {
    Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Disclosure').getRecordTypeId();

     List<ContentDocumentLink> documentLinks = [SELECT  LinkedEntityId , ContentDocumentId FROM  ContentDocumentLink
            WHERE LinkedEntityId = :linkedEntityId
            AND ContentDocumentId IN (SELECT ContentDocumentId FROM ContentVersion WHERE PathOnClient = :fileName )
            ];
     if( documentLinks.size() == 1 ){
        ContentDocumentLink documentLink = documentLinks.get(0);

        String textFilesContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, Lorem ipsum dolor sit amet, consectetur adipiscing elit!';
        String pdfFileContent = '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YW5zcGFyZW5jeS9DUy9EZXZpY2VSR0IvSSB0cnVlPj4vQ29udGVudHMgMiAwIFI+PgplbmRvYmoKCjQgMCBvYmoKPDwvVHlwZS9QYWdlcwovUmVzb3VyY2VzIDExIDAgUgovTWVkaWFCb3hbIDAgMCA1OTUgODQxIF0KL0tpZHNbIDEgMCBSIF0KL0NvdW50IDE+PgplbmRvYmoKCjEyIDAgb2JqCjw8L1R5cGUvQ2F0YWxvZy9QYWdlcyA0IDAgUgovT3BlbkFjdGlvblsxIDAgUiAvWFlaIG51bGwgbnVsbCAwXQovTGFuZyhlbi1aQSkKPj4KZW5kb2JqCgoxMyAwIG9iago8PC9DcmVhdG9yPEZFRkYwMDU3MDA3MjAwNjkwMDc0MDA2NTAwNzI+Ci9Qcm9kdWNlcjxGRUZGMDA0QzAwNjkwMDYyMDA3MjAwNjUwMDRGMDA2NjAwNjYwMDY5MDA2MzAwNjUwMDIwMDAzNjAwMkUwMDM0PgovQ3JlYXRpb25EYXRlKEQ6MjAyMjExMzAxMzAxMzUrMDInMDAnKT4+CmVuZG9iagoKeHJlZgowIDE0CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwNzA4OSAwMDAwMCBuIAowMDAwMDAwMDE5IDAwMDAwIG4gCjAwMDAwMDAyMTkgMDAwMDAgbiAKMDAwMDAwNzI1OCAwMDAwMCBuIAowMDAwMDAwMjM5IDAwMDAwIG4gCjAwMDAwMDYyMzEgMDAwMDAgbiAKMDAwMDAwNjI1MiAwMDAwMCBuIAowMDAwMDA2NDQ3IDAwMDAwIG4gCjAwMDAwMDY3OTQgMDAwMDAgbiAKMDAwMDAwNzAwMiAwMDAwMCBuIAowMDAwMDA3MDM0IDAwMDAwIG4gCjAwMDAwMDczNTcgMDAwMDAgbiAKMDAwMDAwNzQ1NCAwMDAwMCBuIAp0cmFpbGVyCjw8L1NpemUgMTQvUm9vdCAxMiAwIFIKL0luZm8gMTMgMCBSCi9JRCBbIDwzNTE0QjVBOTlCOTk5N0Q2MUE0NjMxOUE1RkE2ODI3RD4KPDM1MTRCNUE5OUI5OTk3RDYxQTQ2MzE5QTVGQTY4MjdEPiBdCi9Eb2NDaGVja3N1bSAvNDBENkEzRTlDQjQ4QjgxRkQ3MEI0RUFEMDY3NDZDOTQKPj4Kc3RhcnR4cmVmCjc2MjkKJSVFT0YK';
        String docxFileContent = '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';
        ContentVersion conVer = new ContentVersion();
        conVer.Title = 'Testing Files Update ' + fileName; // Display name of the files
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = fileName;
        conVer.RecordTypeId = recordTypeId;
        conVer.Document_Classification__c = subTypeClassification;
        conVer.ContentDocumentId = documentLink.ContentDocumentId; // Use the same ContentDocumentId
        if (fileType == 'docx') {
           conVer.VersionData = EncodingUtil.base64Decode(docxFileContent);
        } else if (fileType == 'txt') {
           // The files name, extension is very important here which will help the file in preview.
          conVer.VersionData = Blob.valueOf(textFilesContent); // converting your binary string to Blog
        }else {
          conVer.VersionData = EncodingUtil.base64Decode(pdfFileContent);
        }
        insert conVer;  //Insert ContentVersion

        ContentVersion updatedVersion = [SELECT VersionNumber FROM ContentVersion WHERE Id = :conVer.Id];
        System.debug('Updated Version Number:' + updatedVersion.VersionNumber);

     }
    }
    public static void insertFile(String subTypeClassification,String fileName, String fileType ,String linkedEntityId){

        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Disclosure').getRecordTypeId();

        String textFilesContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
        String pdfFileContent = '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NTI4XS9Hcm91cDw8L1MvVHJhbnNwYXJlbmN5L0NTL0RldmljZVJHQi9JIHRydWU+Pi9Db250ZW50cyAyIDAgUj4+CmVuZG9iagoKMTcgMCBvYmoKPDwvQ291bnQgMS9GaXJzdCAxOCAwIFIvTGFzdCAxOCAwIFIKPj4KZW5kb2JqCgoxOCAwIG9iago8PC9Db3VudCAwL1RpdGxlPEZFRkYwMDU0MDA2ODAwNjUwMDIwMDA3MzAwNzQwMDYxMDA2RTAwNjQwMDYxMDA3MjAwNjQwMDIwMDA0QzAwNkYwMDcyMDA2NTAwNkQwMDIwMDA0OTAwNzAwMDczMDA3NTAwNkQwMDIwMDA3MDAwNjEwMDczMDA3MzAwNjEwMDY3MDA2NT4KL0Rlc3RbMSAwIFIvWFlaIDU2LjcgNzY0LjM4OSAwXS9QYXJlbnQgMTcgMCBSPj4KZW5kb2JqCgo0IDAgb2JqCjw8L1R5cGUvUGFnZXMKL1Jlc291cmNlcyAxNiAwIFIKL01lZGlhQm94WyAwIDAgNTk1IDg0MSBdCi9LaWRzWyAxIDAgUiBdCi9Db3VudCAxPj4KZW5kb2JqCgoxOSAwIG9iago8PC9UeXBlL0NhdGFsb2cvUGFnZXMgNCAwIFIKL09wZW5BY3Rpb25bMSAwIFIgL1hZWiBudWxsIG51bGwgMF0KL091dGxpbmVzIDE3IDAgUgovTGFuZyhlbi1aQSkKPj4KZW5kb2JqCgoyMCAwIG9iago8PC9DcmVhdG9yPEZFRkYwMDU3MDA3MjAwNjkwMDc0MDA2NTAwNzI+Ci9Qcm9kdWNlcjxGRUZGMDA0QzAwNjkwMDYyMDA3MjAwNjUwMDRGMDA2NjAwNjYwMDY5MDA2MzAwNjUwMDIwMDAzNjAwMkUwMDM0PgovQ3JlYXRpb25EYXRlKEQ6MjAyMjExMjkxNjAzNTQrMDInMDAnKT4+CmVuZG9iagoKeHJlZgowIDIxCjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAxNzkwNiAwMDAwMCBuIAowMDAwMDAwMDE5IDAwMDAwIG4gCjAwMDAwMDA3NzIgMDAwMDAgbiAKMDAwMDAxODM0NyAwMDAwMCBuIAowMDAwMDAwNzkyIDAwMDAwIG4gCjAwMDAwMDk0MzEgMDAwMDAgbiAKMDAwMDAwOTQ1MiAwMDAwMCBuIAowMDAwMDA5NjQ3IDAwMDAwIG4gCjAwMDAwMTAwNjQgMDAwMDAgbiAKMDAwMDAxMDMzNiAwMDAwMCBuIAowMDAwMDE2OTc2IDAwMDAwIG4gCjAwMDAwMTY5OTggMDAwMDAgbiAKMDAwMDAxNzIwMiAwMDAwMCBuIAowMDAwMDE3NTczIDAwMDAwIG4gCjAwMDAwMTc4MDkgMDAwMDAgbiAKMDAwMDAxNzg1MSAwMDAwMCBuIAowMDAwMDE4MDc1IDAwMDAwIG4gCjAwMDAwMTgxMzEgMDAwMDAgbiAKMDAwMDAxODQ0NiAwMDAwMCBuIAowMDAwMDE4NTYwIDAwMDAwIG4gCnRyYWlsZXIKPDwvU2l6ZSAyMS9Sb290IDE5IDAgUgovSW5mbyAyMCAwIFIKL0lEIFsgPEUwNUIwMjI1MkFFQkU0ODcxODdDOTgzN0U2MUNBQ0M4Pgo8RTA1QjAyMjUyQUVCRTQ4NzE4N0M5ODM3RTYxQ0FDQzg+IF0KL0RvY0NoZWNrc3VtIC9GQkUzMDA1NjM4M0EzMzY2NTkzMDM0NDg0Njc0MUE5Qgo+PgpzdGFydHhyZWYKMTg3MzUKJSVFT0YK';
        String docxFileContent = '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';
        String signedPdfFileContent = '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YW5zcGFyZW5jeS9DUy9EZXZpY2VSR0IvSSB0cnVlPj4vQ29udGVudHMgMiAwIFI+PgplbmRvYmoKCjQgMCBvYmoKPDwvVHlwZS9QYWdlcwovUmVzb3VyY2VzIDExIDAgUgovTWVkaWFCb3hbIDAgMCA1OTUgODQxIF0KL0tpZHNbIDEgMCBSIF0KL0NvdW50IDE+PgplbmRvYmoKCjEyIDAgb2JqCjw8L1R5cGUvQ2F0YWxvZy9QYWdlcyA0IDAgUgovT3BlbkFjdGlvblsxIDAgUiAvWFlaIG51bGwgbnVsbCAwXQovTGFuZyhlbi1aQSkKPj4KZW5kb2JqCgoxMyAwIG9iago8PC9DcmVhdG9yPEZFRkYwMDU3MDA3MjAwNjkwMDc0MDA2NTAwNzI+Ci9Qcm9kdWNlcjxGRUZGMDA0QzAwNjkwMDYyMDA3MjAwNjUwMDRGMDA2NjAwNjYwMDY5MDA2MzAwNjUwMDIwMDAzNjAwMkUwMDM0PgovQ3JlYXRpb25EYXRlKEQ6MjAyMjExMzAxMzAxMzUrMDInMDAnKT4+CmVuZG9iagoKeHJlZgowIDE0CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwNzA4OSAwMDAwMCBuIAowMDAwMDAwMDE5IDAwMDAwIG4gCjAwMDAwMDAyMTkgMDAwMDAgbiAKMDAwMDAwNzI1OCAwMDAwMCBuIAowMDAwMDAwMjM5IDAwMDAwIG4gCjAwMDAwMDYyMzEgMDAwMDAgbiAKMDAwMDAwNjI1MiAwMDAwMCBuIAowMDAwMDA2NDQ3IDAwMDAwIG4gCjAwMDAwMDY3OTQgMDAwMDAgbiAKMDAwMDAwNzAwMiAwMDAwMCBuIAowMDAwMDA3MDM0IDAwMDAwIG4gCjAwMDAwMDczNTcgMDAwMDAgbiAKMDAwMDAwNzQ1NCAwMDAwMCBuIAp0cmFpbGVyCjw8L1NpemUgMTQvUm9vdCAxMiAwIFIKL0luZm8gMTMgMCBSCi9JRCBbIDwzNTE0QjVBOTlCOTk5N0Q2MUE0NjMxOUE1RkE2ODI3RD4KPDM1MTRCNUE5OUI5OTk3RDYxQTQ2MzE5QTVGQTY4MjdEPiBdCi9Eb2NDaGVja3N1bSAvNDBENkEzRTlDQjQ4QjgxRkQ3MEI0RUFEMDY3NDZDOTQKPj4Kc3RhcnR4cmVmCjc2MjkKJSVFT0YK';

        ContentVersion conVer = new ContentVersion();
        conVer.Title = 'Testing Files ' + fileName; // Display name of the files
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = fileName;
        conVer.RecordTypeId = recordTypeId;
        conVer.Document_Classification__c = subTypeClassification;
        if (fileType == 'docx') {
            conVer.VersionData = EncodingUtil.base64Decode(docxFileContent);
        } else if (fileType == 'txt') {
           // The files name, extension is very important here which will help the file in preview.
          conVer.VersionData = Blob.valueOf(textFilesContent); // converting your binary string to Blog
        } else {
            if (subTypeClassification == ContentVersionClassification.SIGNED_DISCLOSURE ) {
                conVer.VersionData = EncodingUtil.base64Decode(signedPdfFileContent);
            } else {
                conVer.VersionData = EncodingUtil.base64Decode(pdfFileContent);
            }
        }
        insert conVer;    //Insert ContentVersion

        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.LinkedEntityId = linkedEntityId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
    }


    public static void createTechnicalDocument(String recordSubTypeClassification, String fileName,String fileType , Disclosure__c disclosure) {
       insertFile(recordSubTypeClassification,fileName,fileType, disclosure.Id);
    }

    public static void updateTechnicalDocument(String recordSubTypeClassification, String fileName, String fileType,  Disclosure__c disclosure) {

       updateFile(recordSubTypeClassification,fileName,fileType, disclosure.Id);
    }

    public static void createBioTangDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'BioTang_Disclosure' LIMIT 1];
        
        if(docTemplates.size() == 0) { // only create teh template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = 'BioTang_Disclosure';

            docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Disclosure PDF</title><meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"><meta name="Cache-Control" content="no-cache, no-store, must-revalidate"><meta name="Pragma" content="no-cache"><meta name="Expires" content="0"><link rel="shortcut icon" href="favicon.ico"><style></style></head><body><div class="main-view"><div class="nav-container"><table class="main-content"><tr><td><table class="main-content"><tr><td><img width="170px" src="data:image/png;base64,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4JdfsI/sueNF+IXwL+A1r4K8XpFPCmrzfEH4r+LBHHcWstnMI9P8beO/EelRs9vNInmJYrIrESqyyojqAfftABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAfn5+0J/wAnV/Ar/sDad/6nlpT6fP8AQD9A6QBQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQB5F4v+C3hPxt498K/EXV7vXYtd8H20NrpcFheWUOmSRwarHrCG9t5tOubiVzdRqrGK7gBhygUOfMoA9doAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoAKACgAoA/9k="></td></tr></table></td></tr></table></div><div class="sub-content"><table><tr><td class="main-heading">Biological and Tangible Property Disclosure - {{subTypeName}}</td></tr><tr><td class="italic">By initializing below, all inventors/authors certify that the description of this technology/copyright is accurate and complete and includes all relevant material associated with this technology and that no details of the technology/copyright as currently understood are omitted.</td></tr></table></div><div class="info-container"><table><tr><th class="info-name" style="width:50%">Submitted By</th><th class="info-name" style="width:50%">Submitted on behalf of an inventor</th></tr><tr><td class="info-value" style="width:50%">{{submittingContact.LegalGivenName__c}} {{submittingContact.LegalMiddleName__c}} {{submittingContact.LegalLastName__c}}</td><td class="info-value" style="width:50%">{{submittedOnBehalf}}</td></tr></table><table><tr><th class="info-name">Status</th></tr><tr><td class="info-value">{{disclosure.Status__c}}</td></tr></table><table><tr><th class="info-name">Title</th></tr><tr><td class="info-value">{{disclosure.Name__c}}</td></tr></table><table><tr><th class="info-name">Description</th></tr><tr><td class="info-value">{{disclosure.Description__c}}</td></tr></table></div><div class="info-container"><div style="page-break-inside:avoid!important"><div class="sub-heading" style="text-align:left">MIT Point of Contact</div><table class="bordered-table"><tr><th class="info-name">Name</th><th class="info-name">Position</th><th class="info-name">Department</th><th class="info-name">Email</th></tr><tr><td class="info-value">{{biotang.MIT_Point_of_Contact_Acc__r.Name}}</td><td class="info-value">{{biotang.MIT_Point_of_Contact_Acc__r.PersonTitle}}</td><td class="info-value">{{biotang.MIT_Point_of_Contact_Acc__r.PersonDepartment}}</td><td class="info-value">{{biotang.MIT_Point_of_Contact_Acc__r.PersonEmail}}</td></tr></table><hr></div><div style="page-break-inside:avoid!important"><div class="sub-heading" style="text-align:left;text-transform:uppercase;font-weight:400">Materials</div><table class="no-border-table"><tr><th class="info-name">Does the {{subTypeName}} contain or incorporate material(s) that were (i) obtained from another lab (either at MIT or another institution without an MTA) and or (ii) purchased?{{#if isMouseStrain}} Was this Mouse Strain generated by cross-breeding of existing strains?{{/if}}</th></tr><tr><td class="info-value">{{biotang.materialsFromOtherLabs__c}}</td></tr></table><table class="no-border-table"><tr><th class="info-name">Comments/details</th></tr><tr><td class="info-value">{{biotang.materialsFurtherComments__c}}</td></tr></table>{{#if isMouseStrain}}<table class="no-border-table"><tr><th class="info-name">Was this Mouse Strain generated by crosssing with another Mouse/Mice?</th></tr><tr><td class="info-value">{{mouseStrainWrapper.genCrossOther}}</td></tr></table><table class="no-border-table"><tr><th class="info-name">Details regarding the development</th></tr><tr><td class="info-value">{{mouseStrainWrapper.mouseStrain.Mouse_Strain_Gen_Details__c}}</td></tr></table>{{/if}}<div class="sub-heading" style="text-align:left">Material</div><table class="bordered-table"><tr><th class="info-name">Name</th><th class="info-name">Source</th><th class="info-name">Obtained by</th><th class="info-name">Other Description</th></tr>{{#each materials}}<tr><td class="info-value">{{Name}}</td><td class="info-value">{{Source__c}}</td><td class="info-value">{{How_Was_Material_Obtained__c}}</td><td class="info-value">{{Material_Obtained_Other_Desc__c}}</td></tr>{{/each}}</table><hr></div><div style="page-break-inside:avoid!important"><div class="sub-heading" style="text-align:left;text-transform:uppercase;font-weight:400">Disclosure</div>{{#if isAntibody}}<div class="sub-heading" style="text-align:left">Antibody Details</div><table class="bordered-table"><tr><th class="info-name" style="width:75%">Validated Applications</th><th class="info-name" style="width:25%">Yes/No</th></tr>{{#each antibodyWrapper.antibodyValidApplications}}<tr><td class="info-value" style="width:75%">{{apiName}}</td><td class="info-value" style="width:25%">{{value}}</td></tr>{{/each}}</table><br><table class="no-border-table"><tr><th class="info-name">Other Description</th></tr><tr><td class="info-value">{{antibodyWrapper.antibody.antibodyValidAppOther__c}}</td></tr></table>{{/if}} {{#if isMouseStrain}}<table class="no-border-table"><tr><th class="info-name">Maintenance and Breeding details</th></tr><tr><td class="info-value">{{mouseStrainWrapper.mouseStrain.maintenanceAndBreeding__c}}</td></tr></table>{{/if}}<table class="no-border-table"><tr><th class="info-name">Average Frequency of Request(s) per month</th></tr><tr><td class="info-value">{{biotang.frequencyOfRequests__c}}</td></tr></table>{{#if isAntibody}}<table class="no-border-table"><tr><th class="info-name">Is purification required</th></tr><tr><td class="info-value">{{antibodyWrapper.antibody.isPurificationRequired__c}}</td></tr></table>{{/if}}<table class="no-border-table"><tr><th class="info-name">Publication(s)</th></tr><tr><td class="info-value">{{biotang.publications__c}}</td></tr></table><table class="no-border-table"><tr><th class="info-name">Provided links to references if no uploads are available:</th></tr><tr><td class="info-value">{{biotang.publicationsLinkToRef__c}}</td></tr></table><hr></div><div style="page-break-inside:avoid!important">{{#if hasShipper}}<div class="sub-heading" style="text-align:left">Distribution/Shipping</div><table class="no-border-table"><tr><th class="info-name">Has the {{subTypeName}} been deposited at any repository(ies)?</th></tr><tr><td class="info-value">{{biotang.depositedAtRepository__c}}</td></tr></table><table class="no-border-table"><tr><th class="info-name">Details</th></tr><tr><td class="info-value">{{biotang.repositoryDetails__c}}</td></tr></table><table class="no-border-table"><tr><th class="info-name">Deposit and Distribution details</th></tr><tr><td class="info-value">{{biotang.depositAndDistribution__c}}</td></tr></table><div class="sub-heading" style="text-align:left">MIT Shipper</div><table class="bordered-table"><tr><th class="info-name">Name</th><th class="info-name">Position</th><th class="info-name">Department</th><th class="info-name">Email</th></tr><tr><td class="info-value">{{biotang.MIT_Shipper_Acc__r.Name}}</td><td class="info-value">{{biotang.MIT_Shipper_Acc__r.PersonTitle}}</td><td class="info-value">{{biotang.MIT_Shipper_Acc__r.PersonDepartment}}</td><td class="info-value">{{biotang.MIT_Shipper_Acc__r.PersonEmail}}</td></tr></table><hr>{{/if}}</div><div style="page-break-inside:avoid!important"><div class="sub-heading" style="text-align:left;text-transform:uppercase;font-weight:400">INVENTORS AND AUTHORS</div><table class="bordered-table"><tr><th class="info-name">Name</th><th class="info-name">Position</th><th class="info-name">Department</th><th class="info-name">Institution</th><th class="info-name">Primary</th></tr>{{#each inventors}}<tr><td class="info-value">{{inventor.Contact__r.Name}}</td><td class="info-value">{{inventor.Contact__r.PersonTitle}}</td><td class="info-value">{{inventor.Contact__r.PersonDepartment}}</td><td class="info-value">{{inventor.Contact__r.Institution__pc}}</td><td class="info-value">{{isPrimaryInventor}}</td></tr>{{/each}}</table><hr></div><div style="page-break-inside:avoid!important"><div class="sub-heading" style="text-align:left;text-transform:uppercase;font-weight:400">FUNDING</div><div class="sub-heading" style="text-align:left">External Funding/Sponsorship Sources</div><table class="bordered-table"><tr><th class="info-name">Award Account Number</th><th class="info-name">Award Title</th><th class="info-name">Sponsor</th><th class="info-name">PI</th></tr>{{#each externalFunding}}<tr><td class="info-value">{{Award_Id__c}}</td><td class="info-value">{{Award_Title__c}}</td><td class="info-value">{{Sponsor_Name__c}}</td><td class="info-value">{{PI_Acc__r.Name}}</td></tr>{{/each}}</table><br><div class="sub-heading" style="text-align:left">Internal MIT Funds</div><table class="bordered-table"><tr><th class="info-name">Cost Object Number Known</th><th class="info-name">Cost Object Number</th><th class="info-name">Funding Details</th></tr>{{#each internalFunding}}<tr><td class="info-value">{{CostObjectKnown__c}}</td><td class="info-value">{{CostObjectNumber__c}}</td><td class="info-value">{{FundingDetails__c}}</td></tr>{{/each}}</table><br><table class="no-border-table"><tr><th class="info-name">Further comments/details</th></tr><tr><td class="info-value">{{disclosure.Funding_Details__c}}</td></tr></table><table class="no-border-table"><tr><th class="info-name">Was the {{subTypeName}} developed as part of a collaboration?</th></tr><tr><td class="info-value">{{biotang.wasDevAsPartOfCollaboration__c}}</td></tr></table><table class="no-border-table"><tr><th class="info-name">Details about the researchers and/or respective institution(s) with which you may have collaborated with.</th></tr><tr><td class="info-value">{{biotang.Collaborators_Detail__c}}</td></tr></table><hr></div><div style="page-break-inside:avoid!important"><div class="sub-heading" style="text-align:left;text-transform:uppercase;font-weight:400">Commercialization</div><table class="bordered-table"><tr><th class="info-name">Company Name</th><th class="info-name">Contact name</th><th class="info-name">Contact email</th></tr>{{#each commercialInterests}}<tr><td class="info-value">{{Company_Name__c}}</td><td class="info-value">{{Contact_Name__c}}</td><td class="info-value">{{Contact_Email__c}}</td></tr>{{/each}}</table><br></div></div></div><div id="Inventor"></div><span style="color:#fff">**DocuSign_hidden**</span></body></html>';
            insert docTemplate;
         }
     }

    public static void createInventorDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'Inventor' LIMIT 1];

        if(docTemplates.size() == 0) { // only create teh template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = 'Inventor';

            docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Disclosure PDF</title><meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"><meta name="Cache-Control" content="no-cache, no-store, must-revalidate"><meta name="Pragma" content="no-cache"><meta name="Expires" content="0"><link rel="shortcut icon" href="favicon.ico"><style></style></head><body>{{#if inventor}}<div class="main-view">{{#inventor}}<div class="nav-container"></div><div style="page-break-inside:avoid!important"><div class="sub-content"><table><tr><td class="sub-heading" style="text-align:left;text-transform:uppercase">ADDITIONAL INVESTIGATOR DISCLOSURE DETAILS</td></tr></table></div><div class="info-container"><table><tr><th class="info-name">1. Give details on who pays your salary/wages</th></tr><tr><td class="info-value">{{SalaryWages__c}}</td></tr></table><table><tr><th class="info-name">1a. Give details on who pays your salary/wages</th></tr><tr><td class="info-value">{{SalaryWagesDetails__c}}</td></tr></table><table><tr><th class="info-name">2. Did you perform any of the relevant work at MIT?</th></tr><tr><td class="info-value">{{WorkDoneAtMIT__c}}</td></tr></table><table><tr><th class="info-name">3. Did you perform any of the relevant work at another institution or company?</th></tr><tr><td class="info-value">{{WorkDoneOutsideMIT__c}}</td></tr></table><table><tr><th class="info-name">3a. Please specify where the work was done.</th></tr><tr><td class="info-value">{{WorkDoneOutsideMITDetails__c}}</td></tr></table><table><tr><th class="info-name">4. Was the research part of a collaboration with another institution or company?</th></tr><tr><td class="info-value">{{Collaboration__c}}</td></tr></table><table><tr><th class="info-name">4a. Please specify the other institution or company?</th></tr><tr><td class="info-value">{{CollaborationDetails__c}}</td></tr></table><table><tr><th class="info-name">5. Was research performed by consultant or contract research organization?</th></tr><tr><td class="info-value">{{ConsultantOrContract__c}}</td></tr></table><table><tr><th class="info-name">5a. Who performed this research?</th></tr><tr><td class="info-value">{{ConsultantOrContractDetails__c}}</td></tr></table><table><tr><th class="info-name">6. Did you receive funding through any of these DLC\'s?</th></tr><tr><td class="info-value">{{FundingThroughDlc__c}}</td></tr></table><table><tr><th class="info-name">7. Were you affiliated with any of the following organizations or DLCS at the time the invention was made?</th></tr><tr><td class="info-value">{{AffiliatedWithOrgsDlcs__c}}</td></tr></table><table><tr><th class="info-name">7a. Please list any additional applicable sponsored research agreements or funding sources not listed elsewhere this disclosure. (eg: fellowship or gifts)?</th></tr><tr><td class="info-value">{{AdditionalSponsorsOrFunding__c}}</td></tr></table><table><tr><th class="info-name">8. Was this work conceived as part of a class taken at MIT?</th></tr><tr><td class="info-value">{{PartOfClass__c}}</td></tr></table><table><tr><th class="info-name">9. Please specify the course?</th></tr><tr><td class="info-value">{{PartOfClassDetails__c}}</td></tr></table><table><tr><th class="info-name">10. Please list any other applicable third party materials or datasets used in the development of the invention?</tr><tr><td class="info-value">{{ThirdPartyMaterials__c}}</td></tr></table><table><tr><th class="info-name">11. Additional Comments</th></tr><tr><td class="info-value">{{AdditionalComments__c}}</td></tr></table></div></div><div class="info-container"><div style="page-break-inside:avoid!important"><table><tr><th class="sub-heading" style="font-weight:400;text-transform:uppercase">Account Information</th></tr></table><table><tr><th class="info-name">Contact Details</th></tr><tr><td class="info-value">Phone: {{Contact__r.PersonMobilePhone}}</td></tr><tr><td class="info-value">Email: {{Contact__r.PersonEmail}}</td></tr></table><table><tr><th class="info-name">Address</th></tr><tr><td class="info-value" style="padding-top:2px;padding-bottom:2px">{{Contact__r.PersonMailingStreet}}</td></tr><tr><td class="info-value" style="padding-top:2px;padding-bottom:2px">{{Contact__r.PersonMailingCity}}</td></tr><tr><td class="info-value" style="padding-top:2px;padding-bottom:2px">{{Contact__r.PersonMailingState}}</td></tr><tr><td class="info-value" style="padding-top:2px;padding-bottom:2px">{{Contact__r.PersonMailingPostalCode}}</td></tr><tr><td class="info-value" style="padding-top:2px;padding-bottom:2px">{{Contact__r.PersonMailingCountry}}</td></tr></table><table><tr><th class="info-name">Citizenship</th></tr><tr><td class="info-value" style="padding-top:2px;padding-bottom:2px">{{Contact__r.CountryOfCitizenship__pc}}</td></tr>{{#if Contact__r.Government_Agency_Name__pc}}<tr><td class="info-value" style="padding-top:2px;padding-bottom:2px">Goverment Agency: {{Contact__r.Government_Agency_Name__pc}}</td></tr>{{/if}}</table><table><tr><td><hr></td></tr></table></div></div>{{/inventor}}<div class="info-container"><div style="page-break-inside:avoid!important"><table><tr><td class="info-value">I {{inventor.Contact__r.FirstName}} {{inventor.Contact__r.MiddleName}} {{inventor.Contact__r.LastName}}, hereby assign all rights, title and interest to this Biological & Tangible Property Disclosure to MIT and agree to execute all documents as requested, assigning to MIT our rights in any copyright and/or patent application filed on this Biological & Tangible Property Disclosure, and to cooperate with the MIT Technology Licensing Office (the "TLO") in the protection of this Biological & Tangible Property Disclosure. MIT will share any royalty income derived from the Biological & Tangible Property Disclosure with the author(s) according to its standard policies, as may be updated from time to time.</td></tr></table><table><tr><td class="page-signature"></td><td class="page-signature-spacing"></td><td class="page-signature"></td><td class="page-signature-spacing"></td><td class="page-signature"></td></tr><tr><td class="info-value" style="color:#fff"><span>**signature_{{recipientId}}**</span></td><td class="info-value"></td><td class="info-value" style="color:#fff"><span>**signature_{{recipientId}}_initials**</span></td><td class="info-value"></td><td class="info-value" style="color:#fff"><span>**signature_{{recipientId}}_dateSigned**</span></td></tr><tr class="page-signature-low"><td class="page-signature-low"><hr></td><td class="page-signature-low"></td><td class="page-signature-low"><hr></td><td class="page-signature-low"></td><td class="page-signature-low"><hr></td></tr><tr><td class="info-name-signature">Signature</td><td></td><td class="info-name-signature">Initials</td><td></td><td class="info-name-signature">Date Signed</td></tr></table><table><tr><th class="info-name"></th></tr><tr><td><span class="info-name-signature">Signed By&nbsp&nbsp</span>{{signedByName}}</td></tr></table></div></div></div>{{/if}}</body></html>';

            insert docTemplate;
        }
    }


    public static void createUtilizationDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c
        where Template_Key__c in(
            'Cover_Page_Utilization_Report',
            'Not_Licensed_Utilization_Report',
            'Licensed_Utilization_Report',
            'Commercialized_Utilization_Report'
        )
        ];
        List<Document_Template__c> insertList = new List<Document_Template__c>();
        if(docTemplates.size() == 0) {
            insertList.add(getUtilizationTemplate('Cover_Page_Utilization_Report'));
            insertList.add(getUtilizationTemplate('Not_Licensed_Utilization_Report'));
            insertList.add(getUtilizationTemplate('Licensed_Utilization_Report'));
            insertList.add(getUtilizationTemplate('Commercialized_Utilization_Report'));
            insert insertList;
        }

    }

    private static Document_Template__c getUtilizationTemplate(String key) {
        Document_Template__c docTemplate = new Document_Template__c();
        docTemplate.Template_Key__c = key ;

        docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html><html></html>';

        return docTemplate;

    }


    public static void createCoverPageDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = :DocumentGenerationService.coverPage() LIMIT 1];

        if(docTemplates.size() == 0) { // only create teh template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = DocumentGenerationService.coverPage();

            docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Invention Disclosure PDF</title><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"> <meta name="Cache-Control" content="no-cache, no-store, must-revalidate"> <meta name="Pragma" content="no-cache"><meta name="Expires" content="0"> <link rel="shortcut icon" href="favicon.ico"><style>.red-text{color: #fe3c52; }</style></head><body><div class="main-view"><div class="info-container"><table class="main-content"><tr> <td> <table class="main-content"><tr> <td> <img width="170px" src=""> </td></tr></table></td></tr></table><div class="sub-content"><table><br><tr><td class="main-heading">Invention Disclosure Form</td></tr><tr><th class="info-name">Human Computer Interaction A</th></tr></table></div><br><br><table><tr><th><span class="info-name" style="padding-bottom: 6px;">Sumitted By&nbsp;</span><span class="info-value" style="padding-bottom: 6px;">{{submittingContactFullName}}</span></th></tr><tr><th><span class="info-name" style="padding-bottom: 6px;">Sumitted Date&nbsp;</span><span class="info-value" style="padding-bottom: 6px;">{{submittedDate}}</span></th></tr><tr><th><span class="info-name" style="padding-bottom: 6px;">Case No&nbsp;</span><span class="info-value" style="padding-bottom: 6px;">{{disclosure.Case_Number__c}}</span></th></tr></table><table><tr><td class="red-text text-uppercase" style="text-align:right">CONFIDENTIAL</td></tr></table></div></div></body></html>';

            insert docTemplate;
        }
    }


    public static void createInventionDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'Invention_Disclosure' LIMIT 1];

        if(docTemplates.size() == 0) { // only create teh template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = 'Invention_Disclosure';

            docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html>' +
            '<html>' +
            '<head>' +
                '<meta charset="UTF-8">' +
                '<title>Disclosure PDF</title>' +
                '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">' +
                '<meta name="Cache-Control" content="no-cache, no-store, must-revalidate">' +
                '<meta name="Pragma" content="no-cache">' +
                '<meta name="Expires" content="0">' +
                '<link rel="shortcut icon" href="favicon.ico">' +
                '<style>' +
                    '.main-view {' +
                        'height: 80px;' +
                        'margin: auto;' +
                        'text-align: center;' +
                        'width: 1024px;' +
                        'margin: auto;' +
                    '}' +

                    '.location-name {' +
                        'color: #e7edec;' +
                        'font-size: 14px;' +
                        'font-family: "adelle-sans", sans-serif;' +
                        'font-weight: bold;' +
                    '}' +

                    '.location-info {' +
                        'color: #ffffff;' +
                        'font-size: 14px;' +
                        'font-family: "adelle-sans", sans-serif;' +
                    '}' +

                    '.info-name {' +
                        'color: #000000;' +
                        'font-size: 14px;' +
                        'font-family: "adelle-sans", sans-serif;' +
                    '}' +

                    '.info-value {' +
                        'color: #000000;' +
                        'font-size: 14px;' +
                        'font-family: "adelle-sans", sans-serif;' +
                        'font-weight: bold;' +
                    '}' +

                    '.info-result {' +
                        'text-align: center;' +
                    '}' +

                    '.info-result-left {' +
                        'text-align: center;' +
                        'color: #184c4f;' +
                        'font-size: 22px;' +
                        'font-family: "adelle-sans", sans-serif;' +
                        'font-weight: bold;' +
                    '}' +

                    '.info-result-right {' +
                        'text-align: center;' +
                        'color: #184c4f;' +
                        'font-size: 22px;' +
                        'font-family: "adelle-sans", sans-serif;' +
                    '}' +

                    '.info-result-bottom {' +
                        'text-align: left;' +
                        'color: #000000;' +
                        'font-size: 16pt;' +
                        'font-family: "adelle-sans", sans-serif;' +
                        'font-weight: bold;' +
                    '}' +

                    '.info-result-top {' +
                        'text-align: left;' +
                        'color: #184c4f;' +
                        'font-size: 16pt;' +
                        'font-family: "adelle-sans", sans-serif;' +
                        'font-weight: bold;' +
                    '}' +

                    '.nav-container {' +
                        'background-color: #000000;' +
                    '}' +

                    '.info-container {' +
                        'background-color: #e7edec;' +
                        'padding-top: 30px;' +
                        'padding-bottom: 30px;' +
                        'margin-bottom: 10px;' +
                    '}' +

                    '.main-content {' +
                        'margin: auto;' +
                        'width: 100%;' +
                        'color: #000000;' +
                        'align-content: left;' +
                        'align-items: left;' +
                    '}' +

                    '.page-content {' +
                        'display: flex;' +
                        'align-content: center;' +
                        'align-items: center;' +
                        'height: 15cm;' +
                        'background-color: #ffffff;' +
                        'font-family:Arial, Helvetica, sans-serif;' +
                        'padding: 50px;' +
                        'margin: auto;' +
                        'color: #000000;' +
                        'width:15cm;' +
                        'text-align:left;' +
                        'border-top-left-radius: 0px;' +
                        'border-top-right-radius: 0px;' +
                        'border-bottom-right-radius: 0px;' +
                        'border-bottom-left-radius: 0px;' +
                    '}' +

                    '.page-content table thead th{ border-top:2px solid #000;border-bottom:2px solid #000;}' +
                    '.card-header{' +
                        'display: flex;' +
                    '}' +
                    '.name-bar-values{display:flex;align-items: flex-start;' +
                        'flex-wrap: nowrap;}' +
                    '.name-bar-values div{width: 40%;}' +
                    '.name-bar-labels{display:flex;align-items: flex-start;' +
                        'flex-wrap: nowrap;border-top:1px solid #000;}' +
                    '.name-bar-labels div{width:40%;}' +


                    '.detail-bar-values{display:flex;align-items: flex-start;' +
                        'flex-wrap: nowrap;}' +
                    '.detail-bar-values div{width: 50%;}' +
                    '.detail-bar-labels{display:flex;align-items: flex-start;' +
                        'flex-wrap: nowrap;border-top:1px solid #000;}' +
                    '.detail-bar-labels div{width:50%;}' +

                    '.page-result {' +
                        'margin: auto;' +
                        'padding: 15px;' +
                        'border-width: 1px 1px 1px 1px;' +
                        'border-style: dashed;' +
                        'border-color: #000000;' +
                        'background-color: #ffffff;' +
                        'color: #000000;' +
                        'font-size:10px;' +

                    '}' +
                    '.page-result h1{' +
                        'margin-top:0rem;' +
                        'margin-bottom:0rem;' +
                        'font-weight:normal;' +
                    '}' +

                    '.page-signature {' +
                        'margin: auto;' +
                        'padding: 0px;' +
                        'height: 200px;' +
                        'width: 700px;' +
                        'border-width: 0px 0px 0px 0px;' +
                        'background-color: #ffffff;' +
                        'color: #000000;' +
                    '}' +

                    '.proof-img {' +
                        'object-fit: contain;' +
                        'max-width:550px;' +
                        'max-height:550px;' +
                        'width: auto;' +
                        'height: auto;' +
                    '}' +

                    'label {' +
                        'color: #ffffff;' +
                        'font-size: 40px;' +
                        'font-family: "adelle-sans", sans-serif;' +
                        'position: relative;' +
                    '}' +

                    'table {' +
                        'width: 100%;' +
                    '}' +

                    'th, td {' +
                        'text-align: left;' +
                        'border: 0px none #ff00ff;' +
                        'border-collapse: collapse;' +
                    '}' +

                '</style>' +
            '</head>' +
            '<body>' +
            '<div class="main-view">' +
                '<div class="nav-container">' +
                    '<div class="main-content">' +
                        '<table>' +
                            '<tr>' +
                                '<td>' +
                                    '<table>' +
                                        '<tr>' +
                                            '<td>' +
                                                '<img src="data:image/png;base64,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">' +
                                            '</td>' +

                                        '</tr>' +
                                    '</table>' +
                                '</td>' +
                            '</tr>' +

                        '</table>' +
                    '</div>' +
                '</div>' +
                '<div class="info-container">' +
                    '<table>' +
                        '<tr>' +
                            '<td style="width: 4%;" >' +
                                '<div class="info-name">' + '</div>' +
                            '</td>' +
                            '<td style="width: 13%;" >' +
                                '<div class="info-name"> Disclosure ID:</div>' +
                            '</td>' +
                            '<td style="width: 19%;">' +
                                '<div class="info-value">{{disclosure.Name}}</div>' +
                            '</td>' +
                            '<td style="width: 13%;">' +
                                '<div class="info-name">Case Number:</div>' +
                            '</td>' +
                            '<td style="width: 19%;">' +
                                '<div class="info-value">{{disclosure.Case_Number__c}}</div>' +
                            '</td>' +
                            '<td style="width: 13%;">' +
                                '<div class="info-name"></div>' +
                            '</td>' +
                            '<td style="width: 19%;">' +
                                '<div class="info-value"></div>' +
                            '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '<td>' +
                                '<div class="info-name"></div>' +
                            '</td>' +
                            '<td>' +
                                '<div class="info-name">Disclosure Title:</div>' +
                            '</td>' +
                            '<td colspan="5">' +
                                '<div class="info-value">{{disclosure.Name__c}}</div>' +
                            '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '<td colspan="7"></td>' +
                        '</tr>' +

                    '</table>' +
                    '<br><br>' +

                    '<div style="text-align: left;;">Inventors</div>' +
                    '<table>' +
                        '<tr>' +
                            '<th style="width: 4%;">' +
                                '<div class="info-name"></div>' +
                            '</th>' +
                            '<th style="width: 13%;" >' +
                                '<div class="info-name">Inventor Name</div>' +
                            '</th>' +
                            '<th style="width: 19%;">' +
                                '<div class="info-value">Mit At Time Of Invention</div>' +
                            '</th>' +
                            '<th style="width: 13%;">' +
                                '<div class="info-name">Primary Inventor</div>' +
                            '</th>' +
                            '<th style="width: 19%;">' +
                                '<div class="info-value">Signed Disclosure</div>' +
                            '</th>' +
                            '<th style="width: 13%;">' +
                                '<div class="info-name">MIT ID</div>' +
                            '</th>' +
                            '<th style="width: 19%;">' +
                                '<div class="info-value"></div>' +
                            '</th>' +
                        '</tr>' +
                        '{{#each inventors}}' +
                        '<tr>' +
                            '<td>' +
                                '<div class="info-name"></div>' +
                            '</td>' +
                            '<td>' +
                                '<div class="info-name">{{Contact__r.FirstName}} {{Contact__r.MiddleName}} {{Contact__r.LastName}}</div>' +
                            '</td>' +
                            '<td>' +
                                '<div class="info-name">{{MitAtTimeOfInvention__c}}</div>' +
                            '</td>' +
                            '<td>' +
                                '<div class="info-name">{{PrimaryInventor__c}}</div>' +
                            '</td>' +
                            '<td>' +
                                '<div class="info-name">{{Signed_Status__c}}</div>' +
                            '</td>' +
                            '<td>' +
                                '<div class="info-name">{{Contact__r.MitId__pc}}</div>' +
                            '</td>' +
                            '<td>' +
                                '<div class="info-name"></div>' +
                            '</td>' +
                        '</tr>' +
                        '{{/each}}' +
                    '</table>' +
                    '<br><br>' +
                '</div>' +
            '</div>' +
            '<div id="Inventor"></div>' +
            '</body>' +
            '</html>';

            insert docTemplate;
        }
    }

    public static void createCopyrightDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'Copyright_Disclosure' LIMIT 1];
        if(docTemplates.size() == 0) { // only create teh template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = 'Copyright_Disclosure';

            docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html>' +
            '<html>' +
            '<head>' +
                '<meta charset="UTF-8">' +
                '<title>Disclosure PDF</title>' +
                '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">' +
                '<meta name="Cache-Control" content="no-cache, no-store, must-revalidate">' +
                '<meta name="Pragma" content="no-cache">' +
                '<meta name="Expires" content="0">' +
                '<link rel="shortcut icon" href="favicon.ico">' +
                '<style></style>' +
            '</head>' +
            '<body>' +
            '<div id="Inventor"></div>' +
            '</body>' +
            '</html>';

            insert docTemplate;
        }
    }

    public static void createSoftwareCodeDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'Software_Code_Disclosure' LIMIT 1];
        if(docTemplates.size() == 0) { // only create teh template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = 'Software_Code_Disclosure';

            docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html>' +
            '<html>' +
            '<head>' +
                '<meta charset="UTF-8">' +
                '<title>Disclosure PDF</title>' +
                '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">' +
                '<meta name="Cache-Control" content="no-cache, no-store, must-revalidate">' +
                '<meta name="Pragma" content="no-cache">' +
                '<meta name="Expires" content="0">' +
                '<link rel="shortcut icon" href="favicon.ico">' +
                '<style>' +
                    '.main-view {' +
                        'height: 80px;' +
                        'margin: auto;' +
                        'text-align: center;' +
                        'width: 1024px;' +
                '</style>' +
            '</head>' +
            '<body>' +
            '<div id="Inventor"></div>' +
            '</body>' +
            '</html>';

            insert docTemplate;
        }
    }


    public static void createFooterDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'footer' LIMIT 1];
        if(docTemplates.size() == 0) { // only create teh template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = 'footer';

            docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html><html lang="en"><head><meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"><meta name="Cache-Control" content="no-cache, no-store, must-revalidate"><meta name="Pragma" content="no-cache"><meta name="Expires" content="0"><title>Disclosure_Footer</title><style>.footer{width:100%;font-family:"Open Sans",sans-serif;font-size:10px;font-weight:600}.red-text{color:#fe3c52}td{padding-top:0;padding-right:10px;padding-bottom:0;padding-left:10px}</style></head><body><table class="footer"><tr><td>Submitted Date: {{submittedDate}}<td><td class="red-text text-uppercase" style="text-align:right">CONFIDENTIAL</td></tr></table></body></html>';

            insert docTemplate;
        }
    }

    public static void createCoverPageFooterDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'cover_page_footer' LIMIT 1];
        if(docTemplates.size() == 0) { // only create teh template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = DocumentGenerationService.coverPage() + '_footer';

            docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html><html lang="en"><head><meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"><meta name="Cache-Control" content="no-cache, no-store, must-revalidate"><meta name="Pragma" content="no-cache"><meta name="Expires" content="0"><title>Disclosure_Footer</title><style>.footer{width:100%;font-family:"Open Sans",sans-serif;font-size:10px;font-weight:600}.red-text{color:#fe3c52}td{padding-top:0;padding-right:10px;padding-bottom:0;padding-left:10px}</style></head><body><table class="footer"><tr><td>Submitted Date: {{submittedDate}}<td><td class="red-text text-uppercase" style="text-align:right">CONFIDENTIAL</td></tr></table></body></html>';

            insert docTemplate;
        }
    }

    public static void createCrdrCoverPageDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'Cover_Page_CRDRNotes' LIMIT 1];
        if(docTemplates.size() == 0) { // only create the template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = 'Cover_Page_CRDRNotes';

            docTemplate.Raw_HTML_Tempalte__c = '<!DOCTYPE html><html><body><div class="main-view" style="page-break-after: always !important;"><div class="info-container"><table class="main-content"><tr><td><table class="main-content"><br><tr><td> <img width="170px" src="data:image/png;base64,iVBORw0="></td></tr></table></td></tr></table><div class="sub-content"><table><br><tr><th class="main-heading" style="text-align:left; font-weight: normal;">Case Royalty Distribution Report</th></tr></table></div><table class="no-border-table"><tr><th><span class="info-name" style="padding-bottom: 6px;">FY:&nbsp;</span><span class="info-name" style="padding-bottom: 6px; font-weight: normal;">{{financialYear}}</span></th></tr></table><table class="no-border-table"><tr><th><span class="info-name" style="padding-bottom: 6px;">{{caseNumber}}&nbsp;-&nbsp;</span><span class="info-value" style="padding-bottom: 6px; font-weight: normal;">{{disclosureTitle}}</span></th></tr></table><table class="no-border-table"> <br><br><br><tr><td>&nbsp;</td></tr></table><div class="sub-content"><div id="ContentPage"><div class="info-name" style="text-align:left; padding-bottom: 6px; font-weight: bold;">NOTES:</div>border-table"><tr><th><span class="info-name" style="padding-bottom: 6px;">{{title}}</span></th></tr></table><table class="no-border-table"><tr><th><span class="info-value" style="padding-bottom: 6px;">{{createdDate}}&nbsp;by</span><span class="info-name" style="padding-bottom: 6px; font-weight: normal;">{{createdBy}}</span></th></tr></table><div style="text-align:left;">{{{text}}}</div></div><br/>{{/each}}{{/if}}</div></div></div></div></body></html>';

            insert docTemplate;
        }
    }

    public static void createStyleDocumentTemplate() {
        List<Document_Template__c> docTemplates = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'style' LIMIT 1];
        if(docTemplates.size() == 0) { // only create teh template if it does not exist yet
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Template_Key__c = 'style';

            docTemplate.Raw_HTML_Tempalte__c = '<style>@page{margin-top:5mm;margin-bottom:15mm;margin-left:5mm;margin-right:5mm}@media print{.main-view,body{margin:0!important;padding-bottom:10mm!important;width:200mm!important;overflow:hidden!important}}.main-view{margin:auto;text-align:center;width:190mm;margin:auto;background-color:#fff;font-family:"Open Sans",sans-serif}.nav-container{background-color:#fff;padding:20px}.sub-content{padding:0 20px 20px 20px}.info-container{background-color:#fff;padding:0 20px 20px 20px}.main-heading{font-weight:700;font-size:16px;color:#000}.sub-heading{font-size:12px;font-weight:600;padding-bottom:10px;color:#000}.bordered-table{width:100%;border-collapse:separate;margin-top:.1em;border-spacing:0;border:1px solid #d1d1d1;border-radius:3px}.bordered-table td,.bordered-table th{padding:3px;border-bottom:1px solid #d1d1d1;border-right:1px solid #d1d1d1;border-top-width:0!important;border-left-width:0!important}.bordered-table tr:last-child td{border-bottom:0}.bordered-table td:last-child{border-right:0}.bordered-table th:last-child{border-right:0}.bordered-table td:first-child{width:25%}.bordered-table,.bordered-table tr td,.bordered-table tr th{page-break-inside:avoid!important}table,tbody,td,tfoot,th,thead,tr{page-break-inside:avoid!important}hr{border:.5px solid #d1d1d1}.no-border-table th{padding:5px 0 0 0}.no-border-table td{padding:0}.italic{font-weight:400;font-size:10px;font-style:italic;line-height:14px}th,th .info-name{font-weight:600!important;font-size:12px;color:#000}td{color:#4f4f4f;font-size:12px;font-weight:400;border-spacing:0}.info-name{font-size:12px;font-weight:400}.info-value{color:#4f4f4f;font-size:12px;font-weight:400}.info-result{text-align:center}.info-result-left{text-align:center;color:#184c4f;font-size:22px;font-family:adelle-sans,sans-serif;font-weight:700}.info-result-right{text-align:center;color:#184c4f;font-size:22px;font-family:adelle-sans,sans-serif}.info-result-bottom{text-align:left;color:#000;font-size:16pt;font-family:adelle-sans,sans-serif;font-weight:700}.info-result-top{text-align:left;color:#184c4f;font-size:16pt;font-family:adelle-sans,sans-serif;font-weight:700}.main-content{width:100%;align-items:center;align-content:center;display:inline}.page-content{display:flex;align-content:center;align-items:center;height:15cm;background-color:#fff;padding:50px;margin:auto;color:#000;width:15cm;text-align:left;border-top-left-radius:0;border-top-right-radius:0;border-bottom-right-radius:0;border-bottom-left-radius:0}.page-content table thead th{border-top:2px solid #000;border-bottom:2px solid #000}.card-header{display:flex}.name-bar-values{display:flex;align-items:flex-start;flex-wrap:nowrap}.name-bar-values div{width:40%}.name-bar-labels{display:flex;align-items:flex-start;flex-wrap:nowrap;border-top:1px solid #000}.name-bar-labels div{width:40%}.detail-bar-values{display:flex;align-items:flex-start;flex-wrap:nowrap}.detail-bar-values div{width:50%}.detail-bar-labels{display:flex;align-items:flex-start;flex-wrap:nowrap;border-top:1px solid #000}.detail-bar-labels div{width:50%}.page-result{margin:auto;padding:15px;border-width:1px 1px 1px 1px;border-style:dashed;border-color:#000;background-color:#fff;color:#000;font-size:10px}.page-result h1{margin-top:0;margin-bottom:0;font-weight:400}.page-signature{padding:0,;height:75px;width:500px;border-width:0;background-color:#fff;color:#fff}.page-signature-spacing{padding:0,;height:75px;width:60px;border-width:0;background-color:#fff;color:#000}.page-signature-low{height:4px;font-size:1px}.proof-img{object-fit:contain;max-width:550px;max-height:550px;width:auto;height:auto}label{color:#fff;font-size:40px;font-family:adelle-sans,sans-serif;position:relative}table{width:100%}td,th{text-align:left;border-collapse:collapse;border-spacing:0}th{padding:5px 5px 0 0}td{padding:0 5px 0 0}</style>';

            insert docTemplate;
        }
    }
        
    public static void createThirdPartyContentDocument(String recordSubTypeClassification, String fileName,String fileType , Third_Party_Content__c thirdPartyContent) {
       insertFile(recordSubTypeClassification,fileName,fileType, thirdPartyContent.Id);
    }

    public static void createThirdPartyCodeDocument(String recordSubTypeClassification, String fileName,String fileType , Third_Party_Code__c thirdPartyCode) {
       insertFile(recordSubTypeClassification,fileName,fileType, thirdPartyCode.Id);
    }



    // Called from build code
    public static void ensureRole() {
        if (UserInfo.getUserRoleId() == null) {
            // Avoid "portal account owner must have a role" error' +
            //Customer User Enabler' +

            List<UserRole> customerEnablerRoles = [SELECT Id, Name, ParentRoleId, RollupDescription, DeveloperName FROM UserRole where DeveloperName = 'Customer_User_Enabler'];
            if( customerEnablerRoles.size() == 1 ){
                update new User(Id = UserInfo.getUserId(), UserRoleId = customerEnablerRoles[0].Id);
            }else {
                UserRole ur = new UserRole(DeveloperName = 'PortalAccountOwnerRole', Name = 'Portal Account Owner Role');
                insert ur;
                update new User(Id = UserInfo.getUserId(), UserRoleId = ur.Id);
            }
        }
    }

    /**
    * Utilization Report object creation
    */
    public static Utilization_Report__c createUtilizationReport(String reportNumber, String docketNumber, Integer reportYear, String status)  {
        Utilization_Report__c utilizationSample = new Utilization_Report__c(
                                Invention_Report_Number__c = reportNumber,
                                Invention_Docket_Number__c = docketNumber,
                                Reporting_Year__c = reportYear.toString(),
                                Utilization_Report_Status__c = status
                            );
        
        insert utilizationSample;
        return utilizationSample;
    }

    /**
    * Utilization Report object wwith error creation
    */
    public static Utilization_Report__c createUtilizationReportWithError(String reportNumber, String docketNumber, Integer reportYear)  {
        Utilization_Report__c utilizationSample = new Utilization_Report__c(
                                Invention_Report_Number__c = reportNumber,
                                Invention_Docket_Number__c = docketNumber,
                                Reporting_Year__c = reportYear.toString(),
                                Utilization_Report_Status__c = 'Error',
                                Error_Messages__c = '{"responseCode":400,"message":"CaseNumber:4911501-55-0001:Error finding caseRecid","errors":[{"message":"CaseNumber:4911501-55-0001:Error finding caseRecid","field":"caseNumber","code":"400"}]}'
                            );
        
        insert utilizationSample;
        return utilizationSample;
    }

      /**
    * Utilization Report object creation
    */
    public static Utilization_Report__c createUtilizationReportForSubmit(String reportNumber, String docketNumber, Integer reportYear, String status)  {
        
        Utilization_Report__c utilizationSample = new Utilization_Report__c(
                                Invention_Report_Number__c = reportNumber,
                                Invention_Docket_Number__c = docketNumber,
                                Reporting_Year__c = reportYear.toString(),
                                Latest_Stage_of_Development__c = 'Not Licensed',
                                First_Commercial_Year_of_Sale__c = '2008',
                                Total_Income__c = 100000.00,
                                New_Us_Jobs__c  = 1,
                                New_Us_Companies__c = 2,
                                Notes__c= 'note1',
                                Commercialization_Plan_Id__c = '1',
                                Is_US_Manufacturing_Required_1__c = 'N',
                                Is_US_Manufacturing_Required_2__c = 'N',
                                Is_US_Manufacturing_Required_3__c = 'N',
                                Utilization_Report_Status__c = status
                                
                            );
        
        insert utilizationSample;

        // Utilization_Report__c utilizationReport = [
        //     SELECT
        //         Id,
        //         Reporting_Year__c,
        //         Invention_Docket_Number__c,
        //         Invention_Report_Number__c,
        //         Latest_Stage_of_Development__c,
        //         First_Commercial_Year_of_Sale__c,
        //         Total_Income__c,
        //         New_Us_Jobs__c,
        //         New_Us_Companies__c,
        //         Notes__c,
        //         Commercialization_Plan_Id__c,
        //         Is_US_Manufacturing_Required_1__c,
        //         Is_US_Manufacturing_Required_2__c,
        //         Is_US_Manufacturing_Required_3__c
        //     FROM Utilization_Report__c
        //     WHERE Reporting_Year__c = '2024' AND Invention_Docket_Number__c = '18436'
        //     LIMIT 1
        // ];

        // IEdisonService iEdisonService = new IEdisonService();
        // IEdisonUtilizationResponse response = iEdisonService.createUtilization(utilizationReport.Id);


        Utilization_Licensee__c licensee1 = new Utilization_Licensee__c(
            Utilization_Report__c = utilizationSample.Id,
            Licensee_Name__c = 'Test licensee 1',
            Forrester_Licensee_Name__c = 'F Test licensee 1',
            Exclusive_Count__c = 1,
            Non_Exclusive_Count__c = 0,
            Small_Business__c  = false
        );
        insert licensee1;

        Utilization_Licensee__c licensee2 = new Utilization_Licensee__c(
            Utilization_Report__c = utilizationSample.Id,
            Licensee_Name__c = 'Test licensee 2',
            Forrester_Licensee_Name__c = 'F Test licensee 2',
            Exclusive_Count__c = 0,
            Non_Exclusive_Count__c = 1,
            Small_Business__c  = true
        );
        insert licensee2;

        Utilization_Commercial_Prods__c commercialProd1 = new Utilization_Commercial_Prods__c(
            Utilization_Report__c = utilizationSample.Id,
            Commercial_Name__c = 'NIH Product A',
            Fda_Approval_Number__c =  'GHD56',
            Fda_Approval_Type__c = 'Medical Device',
            Govt_Review_Status__c = 'Approved',
            Public_Ind__c = 'Yes'
        );
        insert commercialProd1;

        Utilization_Manufacturing_Comm_Prod__c manufacturingCommProd1 = new Utilization_Manufacturing_Comm_Prod__c(
            Utilization_Report__c = utilizationSample.Id,
            Product_Name__c = 'Processor',
            Naics_Code__c = 'ABC123'
        );
        insert manufacturingCommProd1;

        Utilization_Licensee_Man_Comm_Prod__c licenseeManCommProd1 = new Utilization_Licensee_Man_Comm_Prod__c(
            Utilization_Manufacturing_Comm_Prod__c = manufacturingCommProd1.Id,
            Utilization_Licensee__c = licensee1.Id
        );
        insert licenseeManCommProd1;


        Utilization_Manufacturers__c manufacturer1 = new Utilization_Manufacturers__c(
            Utilization_Licensee_Man_Comm_Prod__c = licenseeManCommProd1.Id,
            Manufacturer_Name__c = 'Test Maufacturer1'
        );
        insert manufacturer1;

        Utilization_Product_Location__c productLocation1 =  new Utilization_Product_Location__c(
            Utilization_Manufacturer__c = manufacturer1.Id,
            Country__c = 'US',
            State__c = 'MD',
            First_Date__c =  Date.newInstance(2000, 2, 14),
            First_Date_Type__c = 'Expected',
            Product_Quantity__c = 101
        );
        insert productLocation1;

        return utilizationSample;
    }

    public static Utilization_Report_Config__c createUtilizationReportConfig(String fiscalYear, String startDate, String endDate, String agreementTypes)  {
        Utilization_Report_Config__c utilizationReportConfigSample = new Utilization_Report_Config__c(
                                Fiscal_Year__c = fiscalYear,
                                Start_Date__c = Date.valueOf(startDate),
                                End_Date__c = Date.valueOf(endDate),
                                Agreement_Types__c = agreementTypes
                            );
        
        insert utilizationReportConfigSample;
        return utilizationReportConfigSample;
    }
    
}