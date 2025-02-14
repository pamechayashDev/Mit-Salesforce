public with sharing class DisclosureRecordFetch {
    @AuraEnabled(cacheable=true)
    public static User getUserInformationbyId(String userId) {
        Id castedId = Id.valueOf(userId);
        User userInfo = [
            SELECT Id, Name, Email, FirstName, LastName
            FROM User
            WHERE Id = :castedId
        ];

        return userInfo;
    }

    @AuraEnabled(cacheable=false)
    public static Disclosure__c getDisclosureById(String disclosureId) {
        Id castedId = Id.valueOf(disclosureId);
        Disclosure__c disclosure = [
            SELECT Id, Name__c, Name, Case_Number__c, RecordTypeId, Status__c
            FROM Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure;
    }

    public static List<Disclosure__c> getDisclosuresByIds(
        Set<String> disclosureIds
    ) {
        List<Disclosure__c> disclosures = [
            SELECT
                Id,
                Name,
                Name__c,
                SubmittedOnBehalf__c,
                Submitting_Contact__c,
                Submitting_Contact__r.Name,
                Submitting_Contact__r.PersonEmail,
                Submitting_Contact__r.AltEmail__pc,
                TLO_License_Officer__c,
                TLO_License_Officer__r.Id,
                TLO_License_Officer__r.Name,
                TLO_License_Officer__r.Email__c,
                TLO_License_Officer__r.MitId__c,
                Status__c,
                Submitted_Date__c,
                RecordType.Name,
                RecordTypeId,
                Rejected_By__c,
                Rejection_Reason__c,
                Case_Number__c,
                All_Inventors_Signed__c,
                Unsigned_Inventors_Count__c,
                Inventors_Count__c,
                Signing_Envelop_Id__c
            FROM Disclosure__c
            WHERE Id IN :(disclosureIds)
        ];
        return disclosures;
    }

    /**
     * Get a map of Disclosure details, keyed by Id, from a list of Disclosure
     * Inventors
     * @param inventors List of Disclosure Inventors to be processed
     */
    public static Map<Id, Disclosure__c> getDisclosuresByInventors(
        List<DisclosureInventor__c> inventors
    ) {
        // Get Disclosure Ids from Inventors
        Set<Id> discIds = new Set<Id>();
        for (DisclosureInventor__c inventor : inventors) {
            discIds.add(inventor.Disclosure__c);
        }

        List<Disclosure__c> disclosures = [
            SELECT Id, Name__c, Name, Case_Number__c, RecordTypeId, Status__c
            FROM Disclosure__c
            WHERE Id = :discIds
        ];

        Map<Id, Disclosure__c> disclosureMap = new Map<Id, Disclosure__c>(
            disclosures
        );

        return disclosureMap;
    }

    public static List<Disclosure__c> getDisclosuresByExternalId(
        Set<String> externalIds
    ) {
        List<Disclosure__c> disclosures = [
            SELECT
                Id,
                Name,
                Name__c,
                SubmittedOnBehalf__c,
                Submitting_Contact__c,
                Submitting_Contact__r.Name,
                Submitting_Contact__r.PersonEmail,
                Submitting_Contact__r.AltEmail__pc,
                Status__c,
                Submitted_Date__c,
                RecordType.Name,
                RecordTypeId,
                Rejected_By__c,
                Rejection_Reason__c,
                Case_Number__c,
                All_Inventors_Signed__c,
                Unsigned_Inventors_Count__c,
                External_ID__c,
                TLO_License_Officer__c
            FROM Disclosure__c
            WHERE External_ID__c IN :(externalIds)
        ];
        return disclosures;
    }

    @AuraEnabled(cacheable=false)
    public static List<Invention_Disclosure__c> getInventionByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        Disclosure__c disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Anticipated_Publication_Comment__c,
                        Disclosure_Anticipated_Publication__c,
                        Anticipated_Publication_Disclosure_Date__c,
                        Conception_Comment__c,
                        Conception_Date__c,
                        CreatedById,
                        First_Oral_Disclosure_Comment__c,
                        First_Publication_Comment__c,
                        Invention_Categorization__c,
                        Materials_From_Other_Labs__c,
                        materialsFurtherComments__c,
                        LastModifiedById,
                        Oral_Disclosure_Date__c,
                        Disclosure_Oral_Presentation__c,
                        Disclosure_Part_Of_Thesis__c,
                        Publication_Date__c,
                        Disclosure_Published_Or_Disclosed__c,
                        Disclosure_Reduced_To_Practice__c,
                        Reduced_To_Practice_Comment__c,
                        Reduced_To_Practice_Date__c,
                        Thesis_Count__c,
                        Disclosure_Thesis_Hold__c,
                        Type_Of_Presentation__c
                    FROM Invention_Disclosures__r
                )
            FROM Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure.Invention_Disclosures__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Thesis__c> getThesisDetailsByInventionId(
        String inventionId
    ) {
        Id castedId = Id.valueOf(inventionId);
        Invention_Disclosure__c disclosure = [
            SELECT
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Thesis_Defense_Date__c,
                        Thesis_Degree_Date__c,
                        Thesis_Submitted_Date__c,
                        Thesis_Comment__c,
                        Thesis_Type__c,
                        Name_of_Student__c
                    FROM Theses__r
                )
            FROM Invention_Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure.Theses__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Third_Party_Material__c> getThirdPartyMaterialByInventionId(
        String inventionId
    ) {
        Id castedId = Id.valueOf(inventionId);
        Invention_Disclosure__c disclosure = [
            SELECT
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Invention_Disclosure__c,
                        How_Was_Material_Obtained__c,
                        Source__c,
                        Material_Obtained_Comment__c
                    FROM Third_Party_Material__r
                )
            FROM Invention_Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure.Third_Party_Material__r;
    }

    @AuraEnabled(cacheable=true)
    public static List<BioTang_Disclosure__c> getBioTangByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        Disclosure__c disclosure = [
            SELECT
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        depositAndDistribution__c,
                        depositedAtRepository__c,
                        frequencyOfRequests__c,
                        materialsFromOtherLabs__c,
                        materialsFurtherComments__c,
                        publications__c,
                        publicationsLinkToRef__c,
                        repositoryDetails__c,
                        wasDevAsPartOfCollaboration__c,
                        Collaborators_Detail__c,
                        RecordType.Name,
                        RecordType.DeveloperName,
                        MIT_Shipper_Acc__r.Name,
                        MIT_Shipper_Acc__r.MitId__pc,
                        MIT_Shipper_Acc__r.PersonEmail,
                        MIT_Shipper_Acc__r.PersonTitle,
                        MIT_Shipper_Acc__r.PersonDepartment,
                        MIT_Point_of_Contact_Acc__r.Name,
                        MIT_Point_of_Contact_Acc__r.MitId__pc,
                        MIT_Point_of_Contact_Acc__r.PersonEmail,
                        MIT_Point_of_Contact_Acc__r.PersonTitle,
                        MIT_Point_of_Contact_Acc__r.PersonDepartment
                    FROM BioTang_Disclosure__r
                )
            FROM Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure.BioTang_Disclosure__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Copyright_Disclosure__c> getCopyrightByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        Disclosure__c disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Creators_Request_Distrib_Open_Source_YN__c,
                        Incorporate_Third_Party_Content__c,
                        Part_Of_Employment_YN__c,
                        Years_Code_First_Created__c,
                        Years_Code_First_Published__c,
                        Copyright_Categorization__c,
                        MIT_Point_of_Contact_Acc__r.Name,
                        MIT_Point_of_Contact_Acc__r.MitId__pc,
                        MIT_Point_of_Contact_Acc__r.PersonEmail,
                        MIT_Point_of_Contact_Acc__r.PersonTitle,
                        MIT_Point_of_Contact_Acc__r.PersonDepartment
                    FROM Copyright_Disclosures__r
                )
            FROM Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure.Copyright_Disclosures__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Software_Code_Disclosure__c> getSoftwareCodeByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        Disclosure__c disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Is_Open_Source_YN__c,
                        Part_Of_Employment_YN__c,
                        Open_Source_Comment__c,
                        Existing_Disclosure_Comment__c,
                        Years_Code_First_Created__c,
                        Years_Code_First_Published__c,
                        Encompass_AI_Or_Machine_Learning__c,
                        Algorithm_or_Patentable_Invention__c,
                        Derivative__c,
                        Software_Categorization__c,
                        Source_of_Training_Data__c,
                        Source_of_Training_Details__c,
                        Use_Any_Third_Party_Code__c
                    FROM Software_Code_Disclosures__r
                )
            FROM Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure.Software_Code_Disclosures__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Open_Source__c> getOpenSourceBySoftwareCodeId(
        String softwareDisclosureId
    ) {
        Id castedId = Id.valueOf(softwareDisclosureId);
        List<Software_Code_Disclosure__c> disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Open_Source_Licensing_Type__c,
                        Open_Source_Licensing__c,
                        Open_Source_Other_Comments__c,
                        Publicly_Available_Details__c
                    FROM Open_Sources__r
                )
            FROM Software_Code_Disclosure__c
            WHERE Id = :castedId
        ];
        if (!disclosure.isEmpty()) {
            return disclosure[0].Open_Sources__r;
        } else {
            return new List<Open_Source__c>();
        }
    }

    @AuraEnabled(cacheable=false)
    public static Map<Id, List<Open_Source__c>> getSoftwareOpenSourceByDisclosureIds(
        List<Id> disclosureIds
    ) {
        Map<Id, List<Open_Source__c>> disclosureOpenSourceMap = new Map<Id, List<Open_Source__c>>();
        for (Id d : disclosureIds) {
            disclosureOpenSourceMap.put(d, new List<Open_Source__c>());
        }
        List<Software_Code_Disclosure__c> disclosureSoftware = [
            SELECT
                Id,
                Name,
                Disclosure__c,
                (
                    SELECT
                        Id,
                        Name,
                        Open_Source_Licensing_Type__c,
                        Open_Source_Licensing__c,
                        Open_Source_Other_Comments__c,
                        Publicly_Available_Details__c
                    FROM Open_Sources__r
                )
            FROM Software_Code_Disclosure__c
            WHERE Disclosure__c IN :disclosureIds
        ];

        for (Software_Code_Disclosure__c sc : disclosureSoftware) {
            for (Open_Source__c opensource : sc.Open_Sources__r) {
                disclosureOpenSourceMap.get(sc.Disclosure__c).add(opensource);
            }
        }
        return disclosureOpenSourceMap;
    }

    @AuraEnabled(cacheable=false)
    public static Map<Id, List<Open_Source__c>> getCopyrightOpenSourceByDisclosureIds(
        List<Id> disclosureIds
    ) {
        Map<Id, List<Open_Source__c>> disclosureOpenSourceMap = new Map<Id, List<Open_Source__c>>();
        for (Id d : disclosureIds) {
            disclosureOpenSourceMap.put(d, new List<Open_Source__c>());
        }
        List<Copyright_Disclosure__c> disclosureCopyright = [
            SELECT
                Id,
                Name,
                Disclosure__c,
                (
                    SELECT
                        Id,
                        Name,
                        Open_Source_Licensing_Type__c,
                        Open_Source_Licensing__c,
                        Open_Source_Other_Comments__c
                    FROM Open_Sources__r
                )
            FROM Copyright_Disclosure__c
            WHERE Disclosure__c IN :disclosureIds
        ];

        for (Copyright_Disclosure__c cr : disclosureCopyright) {
            for (Open_Source__c opensource : cr.Open_Sources__r) {
                disclosureOpenSourceMap.get(cr.Disclosure__c).add(opensource);
            }
        }

        return disclosureOpenSourceMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Third_Party_Code__c> getThirdPartyCodeBySoftwareCodeId(
        String softwareDisclosureId
    ) {
        Id castedId = Id.valueOf(softwareDisclosureId);
        List<Software_Code_Disclosure__c> disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Is_Code_Available_On_Web__c,
                        License_Type__c,
                        Web_Page_Third_Party_License__c,
                        Web_Page_To_Download_Code__c
                    FROM Third_Party_Code__r
                )
            FROM Software_Code_Disclosure__c
            WHERE Id = :castedId
        ];
        if (!disclosure.isEmpty()) {
            return disclosure[0].Third_Party_Code__r;
        } else {
            return new List<Third_Party_Code__c>();
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Open_Source__c> getOpenSourceByCopyrightId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        List<Copyright_Disclosure__c> disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Open_Source_Licensing_Type__c,
                        Open_Source_Licensing__c,
                        Open_Source_Other_Comments__c,
                        Publicly_Available_Details__c
                    FROM Open_Sources__r
                )
            FROM Copyright_Disclosure__c
            WHERE Id = :castedId
        ];
        if (!disclosure.isEmpty()) {
            return disclosure[0].Open_Sources__r;
        } else {
            return new List<Open_Source__c>();
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Third_Party_Content__c> getThirdPartyContentByCopyrightId(
        String copyrightId
    ) {
        Id castedId = Id.valueOf(copyrightId);
        List<Copyright_Disclosure__c> disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Attachment_Comment__c,
                        Agreement__c,
                        Source__c
                    FROM Third_Party_Contents__r
                )
            FROM Copyright_Disclosure__c
            WHERE Id = :castedId
        ];
        if (!disclosure.isEmpty()) {
            return disclosure[0].Third_Party_Contents__r;
        } else {
            return new List<Third_Party_Content__c>();
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Third_Party_Code__c> getThirdPartyCodeByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        List<Software_Code_Disclosure__c> disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Is_Code_Available_On_Web__c,
                        License_Type__c,
                        Software_Code_Disclosure__c,
                        Web_Page_Third_Party_License__c,
                        Web_Page_To_Download_Code__c
                    FROM Third_Party_Code__r
                )
            FROM Software_Code_Disclosure__c
            WHERE Disclosure__c = :castedId
        ];
        if (!disclosure.isEmpty()) {
            return disclosure[0].Third_Party_Code__r;
        } else {
            return new List<Third_Party_Code__c>();
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Third_Party_Content__c> getThirdPartyContentByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        List<Copyright_Disclosure__c> disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Attachment_Comment__c,
                        Agreement__c,
                        Source__c
                    FROM Third_Party_Contents__r
                )
            FROM Copyright_Disclosure__c
            WHERE Disclosure__c = :castedId
        ];
        if (!disclosure.isEmpty()) {
            return disclosure[0].Third_Party_Contents__r;
        } else {
            return new List<Third_Party_Content__c>();
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<DisclosureInternalFunding__c> getDisclosureInternalFundingByDisclosureId(
        String disclosureId
    ) {
        try {
            Id castedId = Id.valueOf(disclosureId);
            Disclosure__c disclosure = [
                SELECT
                    Name,
                    (
                        SELECT
                            CostObjectKnown__c,
                            CostObjectNumber__c,
                            FundingDetails__c
                        FROM DisclosureInternalFunding__r
                        LIMIT 200
                    )
                FROM Disclosure__c
                WHERE Id = :castedId
            ];

            return disclosure.DisclosureInternalFunding__r;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<DisclosureExternalFunding__c> getDisclosureExternalFundingByDisclosureId(
        String disclosureId
    ) {
        try {
            Id castedId = Id.valueOf(disclosureId);
            Disclosure__c disclosure = [
                SELECT
                    Name,
                    (
                        SELECT
                            GrantOrContactNumber__c,
                            Award_Id__c,
                            Award_Title__c,
                            Manual_Name__c,
                            PI_Acc__c,
                            PI_Acc__r.Name,
                            Sponsor_Code__c,
                            Sponsor_Name__c
                        FROM DisclosureExternalFunding__r
                        LIMIT 200
                    )
                FROM Disclosure__c
                WHERE Id = :castedId
            ];

            return disclosure.DisclosureExternalFunding__r;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Commercial_Interest__c> getCommercialInterestsByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        Disclosure__c disclosure = [
            SELECT
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        Company_Name__c,
                        Contact_Email__c,
                        Contact_Name__c
                    FROM Commercial_Interests__r
                )
            FROM Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure.Commercial_Interests__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Lab_Materials__c> getLabMaterialsByBioTangId(
        String biotangId
    ) {
        Id castedId = Id.valueOf(biotangId);
        BioTang_Disclosure__c biotang = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        How_Was_Material_Obtained__c,
                        Material_Obtained_Other_Desc__c,
                        Source__c
                    FROM Lab_Materials__r
                )
            FROM BioTang_Disclosure__c
            WHERE Id = :castedId
        ];

        return biotang.Lab_Materials__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Third_Party_Material__c> getThirdPartyMaterialsByInventionId(
        String inventionId
    ) {
        Id castedId = Id.valueOf(inventionId);
        Invention_Disclosure__c invention = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        How_Was_Material_Obtained__c,
                        Material_Obtained_Comment__c,
                        Source__c
                    FROM Third_Party_Material__r
                )
            FROM Invention_Disclosure__c
            WHERE Id = :castedId
        ];

        return invention.Third_Party_Material__r;
    }

    /**
     * Get a list of Department Head objects (with related object details)
     * @param departmentHeadIds List of Department Head Object Ids to retrieve
     */
    public static List<Department_Head__c> getDepartmentHeadsByIds(
        Set<String> departmentHeadIds
    ) {
        List<Department_Head__c> depHeadList = [
            SELECT
                Id,
                Comment__c,
                Disclosure__c,
                Delegated_To__c,
                Delegated_To__r.Name,
                Delegated_To__r.Contact__c,
                Delegated_To__r.Contact__r.Id,
                Delegated_To__r.Contact__r.Name,
                Disclosure__r.Id,
                Disclosure__r.Name,
                Disclosure__r.Name__c,
                Disclosure__r.RecordTypeId,
                Disclosure__r.RecordType.Name,
                Disclosure__r.Status__c,
                Signed_Date__c,
                Contact__c,
                Contact__r.Name,
                Contact__r.PersonEmail,
                Contact__r.PersonDepartment,
                Contact__r.PreferredName__pc,
                Contact__r.FirstName,
                Contact__r.MiddleName,
                Contact__r.LastName,
                Contact__r.MitId__pc
            FROM Department_Head__c
            WHERE Id IN :(departmentHeadIds)
        ];
        return depHeadList;
    }

    @AuraEnabled(cacheable=false)
    public static List<Department_Head__c> getDepartmentHeadByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        /*
        Get the Department Head that Does not have an Delegate_To set. The child element in the chain.
        */
        List<Department_Head__c> departmentHead = [
            SELECT
                Id,
                Disclosure__c,
                Signed_Date__c,
                Contact__r.Name,
                Contact__r.PersonDepartment,
                Contact__r.MitId__pc,
                Contact__r.PersonTitle,
                Contact__r.PersonEmail,
                Comment__c,
                Delegated_To__c
            FROM Department_Head__c
            WHERE Disclosure__c = :castedId AND Delegated_To__c = NULL
        ];

        return departmentHead;
    }

    @AuraEnabled(cacheable=true)
    public static List<Mouse_Strain__c> getMouseStrainByBioTangId(
        String biotangId
    ) {
        Id castedId = Id.valueOf(biotangId);
        BioTang_Disclosure__c biotang = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        maintenanceAndBreeding__c,
                        Mouse_Gen_Cross_Other__c,
                        Mouse_Strain_Gen_Details__c
                    FROM Mouse_Strain__r
                )
            FROM BioTang_Disclosure__c
            WHERE Id = :castedId
        ];

        return biotang.Mouse_Strain__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Antibody__c> getAntibodyByBioTangId(String biotangId) {
        Id castedId = Id.valueOf(biotangId);
        BioTang_Disclosure__c biotang = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        antibodyValidApplications__c,
                        antibodyValidAppOther__c,
                        isPurificationRequired__c
                    FROM Antibody__r
                )
            FROM BioTang_Disclosure__c
            WHERE Id = :castedId
        ];

        return biotang.Antibody__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Cell_Line__c> getCellLineByBioTangId(String biotangId) {
        Id castedId = Id.valueOf(biotangId);
        BioTang_Disclosure__c biotang = [
            SELECT
                Id,
                Name,
                (
                    SELECT Id, Name
                    FROM Cell_Line__r
                )
            FROM BioTang_Disclosure__c
            WHERE Id = :castedId
        ];

        return biotang.Cell_Line__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Plasmid__c> getPlasmidByBioTangId(String biotangId) {
        Id castedId = Id.valueOf(biotangId);
        BioTang_Disclosure__c biotang = [
            SELECT
                Id,
                Name,
                (
                    SELECT Id, Name
                    FROM Plasmid__r
                )
            FROM BioTang_Disclosure__c
            WHERE Id = :castedId
        ];

        return biotang.Plasmid__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<Other_Material__c> getOtherMaterialByBioTangId(
        String biotangId
    ) {
        Id castedId = Id.valueOf(biotangId);
        BioTang_Disclosure__c biotang = [
            SELECT
                Id,
                Name,
                (
                    SELECT Id, Name
                    FROM Other_Material__r
                )
            FROM BioTang_Disclosure__c
            WHERE Id = :castedId
        ];

        return biotang.Other_Material__r;
    }

    public static List<Department_Head__c> getDepartmentHeadByDisclosureIds(
        Set<String> disclosureIdss
    ) {
        List<Department_Head__c> departmentHead = [
            SELECT
                Id,
                Disclosure__c,
                Disclosure__r.Id,
                Signed_Date__c,
                Contact__r.Name,
                Contact__r.PersonDepartment,
                Contact__r.MitId__pc,
                Contact__r.PersonTitle,
                Contact__r.PersonEmail,
                Delegated_To__c
            FROM Department_Head__c
            WHERE Disclosure__c = :disclosureIdss AND Delegated_To__c = NULL
        ];

        return departmentHead;
    }

    public static List<DisclosureInventor__c> getDisclosureInventorsByDisclosureIds(
        Set<String> disclosureIds
    ) {
        List<DisclosureInventor__c> disInventor = [
            SELECT
                Id,
                Disclosure__c,
                PrimaryInventor__c,
                Signed_Disclosure_Date__c,
                Signed_Status__c,
                Review_Draft_Watcher__c,
                Contact__c,
                Contact__r.Id,
                Contact__r.PersonEmail,
                Contact__r.Name,
                Contact__r.InvitationCode__pc,
                Contact__r.MoiraStatus__pc,
                Contact__r.IsAlumni__pc,
                Disclosure__r.Id,
                Disclosure__r.Name,
                Disclosure__r.Name__c,
                Disclosure__r.SubmittedOnBehalf__c,
                Disclosure__r.Submitting_Contact__c,
                Disclosure__r.Submitting_Contact__r.Name,
                Disclosure__r.Submitting_Contact__r.PersonEmail,
                Disclosure__r.Submitting_Contact__r.AltEmail__pc,
                Disclosure__r.Status__c,
                Disclosure__r.Submitted_Date__c,
                Disclosure__r.RecordType.Name,
                Disclosure__r.RecordTypeId,
                Disclosure__r.Rejected_By__c,
                Disclosure__r.Rejection_Reason__c,
                Disclosure__r.Case_Number__c,
                Disclosure__r.All_Inventors_Signed__c,
                Disclosure__r.Inventors_Count__c,
                Disclosure__r.Signing_Envelop_Id__c
            FROM DisclosureInventor__c
            WHERE Disclosure__c IN :(disclosureIds)
        ];

        return disInventor;
    }

    @AuraEnabled(cacheable=false)
    public static List<DisclosureInventor__c> getDisclosureInventorsByIds(
        List<Id> disclosureInventorIds
    ) {
        List<DisclosureInventor__c> inventorList = [
            SELECT
                Id,
                PrimaryInventor__c,
                Signed_Disclosure_Date__c,
                Signed_Status__c,
                Review_Draft_Watcher__c,
                Contact__c,
                Contact__r.FirstName,
                Contact__r.GuestAccountNeeded__pc,
                Contact__r.InvitationCode__pc,
                Contact__r.LastName,
                Contact__r.MiddleName,
                Contact__r.MitId__pc,
                Contact__r.MoiraStatus__pc,
                Contact__r.IsAlumni__pc,
                Contact__r.Name,
                Contact__r.PersonEmail,
                Contact__r.PersonMobilePhone,
                Disclosure__c,
                Disclosure__r.All_Inventors_Signed__c,
                Disclosure__r.Case_Number__c,
                Disclosure__r.Id,
                Disclosure__r.Name__c,
                Disclosure__r.Name,
                Disclosure__r.RecordType.Name,
                Disclosure__r.RecordTypeId,
                Disclosure__r.Rejected_By__c,
                Disclosure__r.Rejection_Reason__c,
                Disclosure__r.Status__c,
                Disclosure__r.Submitted_Date__c,
                Disclosure__r.SubmittedOnBehalf__c,
                Disclosure__r.Submitting_Contact__c,
                Disclosure__r.Submitting_Contact__r.AltEmail__pc,
                Disclosure__r.Submitting_Contact__r.Name,
                Disclosure__r.Submitting_Contact__r.PersonEmail
            FROM DisclosureInventor__c
            WHERE Id IN :(disclosureInventorIds)
        ];
        return inventorList;
    }

    @AuraEnabled(cacheable=false)
    public static List<DisclosureInventor__c> getDisclosureInventorsWithContactByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        Disclosure__c disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        AdditionalComments__c,
                        AdditionalSponsorsOrFunding__c,
                        AffiliatedWithOrgsDlcs__c,
                        Collaboration__c,
                        CollaborationDetails__c,
                        ConsultantOrContract__c,
                        ConsultantOrContractDetails__c,
                        FundingThroughDlc__c,
                        HHMI_At_Time_of_Invention__c,
                        HHMI_tenure_date_from__c,
                        HHMI_tenure_date_to__c,
                        MitAtTimeOfInvention__c,
                        PartOfClass__c,
                        PartOfClassDetails__c,
                        PrimaryInventor__c,
                        Review_Draft_Watcher__c,
                        SalaryWages__c,
                        SalaryWagesDetails__c,
                        Signed_Disclosure_Date__c,
                        Signed_Status__c,
                        ThirdPartyMaterials__c,
                        WorkDoneAtMIT__c,
                        WorkDoneOutsideMIT__c,
                        WorkDoneOutsideMITDetails__c,
                        Disclosure__c,
                        Disclosure__r.CreatedDate,
                        Disclosure__r.Id,
                        Disclosure__r.Name__c,
                        Disclosure__r.Name,
                        Disclosure__r.RecordType.Name,
                        Disclosure__r.Status__c,
                        Disclosure__r.Submitting_Contact__c,
                        Disclosure__r.Submitting_Contact__r.Name,
                        Disclosure__r.Submitting_Contact__r.PersonEmail,
                        Contact__r.AltEmail__pc,
                        Contact__r.CountryOfCitizenship__pc,
                        Contact__r.FirstName,
                        Contact__r.Government_Agency_Name__pc,
                        Contact__r.GovernmentEmployeeStatus__pc,
                        Contact__r.GuestAccountNeeded__pc,
                        Contact__r.HHMI_Current__pc,
                        Contact__r.HHMI_Current_Date_From__pc,
                        Contact__r.Institution__pc,
                        Contact__r.InstitutionCode__pc,
                        Contact__r.InvitationCode__pc,
                        Contact__r.KerbName__pc,
                        Contact__r.LastName,
                        Contact__r.MiddleName,
                        Contact__r.MitId__pc,
                        Contact__r.MoiraStatus__pc,
                        Contact__r.IsAlumni__pc,
                        Contact__r.Name,
                        Contact__r.OldEmail__pc,
                        Contact__r.PersonBirthdate,
                        Contact__r.PersonDepartment,
                        Contact__r.PersonEmail,
                        Contact__r.PersonMailingCity,
                        Contact__r.PersonMailingCountry,
                        Contact__r.PersonMailingPostalCode,
                        Contact__r.PersonMailingState,
                        Contact__r.PersonMailingStreet,
                        Contact__r.PersonOtherPhone,
                        Contact__r.PersonTitle,
                        Contact__r.PersonMobilePhone,
                        Contact__r.PreferredName__pc,
                        Contact__r.VaAppointment__pc,
                        Contact__r.VaAppointmentDetails__pc
                    FROM Inventors__r
                )
            FROM Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure.Inventors__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<DisclosureInventor__c> getDisclosureInventorsWithContactByDisclosureIdInventorId(
        Id disclosureId,
        Id inventorId
    ) {
        Disclosure__c disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        AdditionalComments__c,
                        AdditionalSponsorsOrFunding__c,
                        AffiliatedWithOrgsDlcs__c,
                        Collaboration__c,
                        CollaborationDetails__c,
                        ConsultantOrContract__c,
                        ConsultantOrContractDetails__c,
                        FundingThroughDlc__c,
                        HHMI_At_Time_of_Invention__c,
                        HHMI_tenure_date_from__c,
                        HHMI_tenure_date_to__c,
                        Inventor_Added_to_DocuSign_Envelope__c,
                        MitAtTimeOfInvention__c,
                        PartOfClass__c,
                        PartOfClassDetails__c,
                        PrimaryInventor__c,
                        Review_Draft_Watcher__c,
                        SalaryWages__c,
                        SalaryWagesDetails__c,
                        Signed_Status__c,
                        ThirdPartyMaterials__c,
                        WorkDoneAtMIT__c,
                        WorkDoneOutsideMIT__c,
                        WorkDoneOutsideMITDetails__c,
                        Disclosure__c,
                        Disclosure__r.CreatedDate,
                        Contact__r.AltEmail__pc,
                        Contact__r.CountryOfCitizenship__pc,
                        Contact__r.Government_Agency_Name__pc,
                        Contact__r.GovernmentEmployeeStatus__pc,
                        Contact__r.GuestAccountNeeded__pc,
                        Contact__r.HHMI_Current__pc,
                        Contact__r.HHMI_Current_Date_From__pc,
                        Contact__r.Institution__pc,
                        Contact__r.InstitutionCode__pc,
                        Contact__r.InvitationCode__pc,
                        Contact__r.KerbName__pc,
                        Contact__r.FirstName,
                        Contact__r.LastName,
                        Contact__r.MiddleName,
                        Contact__r.MitId__pc,
                        Contact__r.MoiraStatus__pc,
                        Contact__r.IsAlumni__pc,
                        Contact__r.Name,
                        Contact__r.OldEmail__pc,
                        Contact__r.PersonBirthdate,
                        Contact__r.PersonDepartment,
                        Contact__r.PersonEmail,
                        Contact__r.PersonMailingCity,
                        Contact__r.PersonMailingCountry,
                        Contact__r.PersonMailingPostalCode,
                        Contact__r.PersonMailingState,
                        Contact__r.PersonMailingStreet,
                        Contact__r.PersonOtherPhone,
                        Contact__r.PersonTitle,
                        Contact__r.PersonMobilePhone,
                        Contact__r.PreferredName__pc,
                        Contact__r.VaAppointment__pc,
                        Contact__r.VaAppointmentDetails__pc
                    FROM Inventors__r
                    WHERE Id = :inventorId
                )
            FROM Disclosure__c
            WHERE Id = :disclosureId
        ];

        return disclosure.Inventors__r;
    }

    @AuraEnabled(cacheable=false)
    public static List<DisclosureInventor__c> getDisclosureInventorByDisclosureId(
        String disclosureId
    ) {
        Id castedId = Id.valueOf(disclosureId);
        Disclosure__c disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Name,
                        AdditionalComments__c,
                        AdditionalSponsorsOrFunding__c,
                        AffiliatedWithOrgsDlcs__c,
                        Collaboration__c,
                        CollaborationDetails__c,
                        ConsultantOrContract__c,
                        ConsultantOrContractDetails__c,
                        Contact__c,
                        Disclosure__c,
                        Disclosure__r.SubmittedOnBehalf__c,
                        Disclosure__r.Submitting_Contact__c,
                        FundingThroughDlc__c,
                        HHMI_At_Time_of_Invention__c,
                        HHMI_tenure_date_from__c,
                        HHMI_tenure_date_to__c,
                        MitAtTimeOfInvention__c,
                        PartOfClass__c,
                        PartOfClassDetails__c,
                        PrimaryInventor__c,
                        Review_Draft_Watcher__c,
                        SalaryWages__c,
                        SalaryWagesDetails__c,
                        Signed_Disclosure_Date__c,
                        Signed_Status__c,
                        ThirdPartyMaterials__c,
                        WorkDoneAtMIT__c,
                        WorkDoneOutsideMIT__c,
                        WorkDoneOutsideMITDetails__c
                    FROM Inventors__r
                )
            FROM Disclosure__c
            WHERE Id = :castedId
        ];

        return disclosure.Inventors__r;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getDisclosureInventorAffiliatedPicklist() {
        List<Schema.PicklistEntry> values = DisclosureInventor__c.AffiliatedWithOrgsDlcs__c.getDescribe()
            .getPicklistValues();
        Map<String, String> statusApiToLabelMap = new Map<String, String>();
        for (Schema.PicklistEntry sp : values) {
            statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
        }
        return statusApiToLabelMap;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getDisclosureInventorFundingDlcPicklist() {
        List<Schema.PicklistEntry> values = DisclosureInventor__c.FundingThroughDlc__c.getDescribe()
            .getPicklistValues();
        Map<String, String> statusApiToLabelMap = new Map<String, String>();
        for (Schema.PicklistEntry sp : values) {
            statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
        }
        return statusApiToLabelMap;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getAntibodyApplicationsPicklist() {
        List<Schema.PicklistEntry> values = Antibody__c.antibodyValidApplications__c.getDescribe()
            .getPicklistValues();
        Map<String, String> validApplicationsPicklist = new Map<String, String>();
        for (Schema.PicklistEntry validApp : values) {
            validApplicationsPicklist.put(
                validApp.getValue(),
                validApp.getLabel()
            );
        }
        return validApplicationsPicklist;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getDisclosureReasonPicklist() {
        List<Schema.PicklistEntry> values = Disclosure__c.Disclosure_Reason__c.getDescribe()
            .getPicklistValues();
        Map<String, String> disclosureObjectivePicklist = new Map<String, String>();
        for (Schema.PicklistEntry validApp : values) {
            disclosureObjectivePicklist.put(
                validApp.getValue(),
                validApp.getLabel()
            );
        }
        return disclosureObjectivePicklist;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getDisclosureStatusPicklist() {
        List<Schema.PicklistEntry> values = Disclosure__c.Status__c.getDescribe()
            .getPicklistValues();
        Map<String, String> disclosureObjectivePicklist = new Map<String, String>();
        for (Schema.PicklistEntry validApp : values) {
            disclosureObjectivePicklist.put(
                validApp.getValue(),
                validApp.getLabel()
            );
        }
        return disclosureObjectivePicklist;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getAffiliatedWithOrgsDlcsPicklist() {
        List<Schema.PicklistEntry> values = DisclosureInventor__c.AffiliatedWithOrgsDlcs__c.getDescribe()
            .getPicklistValues();
        Map<String, String> affiliatedWithOrgsDlcsPicklist = new Map<String, String>();
        for (Schema.PicklistEntry validApp : values) {
            affiliatedWithOrgsDlcsPicklist.put(
                validApp.getValue(),
                validApp.getLabel()
            );
        }
        return affiliatedWithOrgsDlcsPicklist;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getSourceOfTrainingDataPicklist() {
        List<Schema.PicklistEntry> values = Software_Code_Disclosure__c.Source_of_Training_Data__c.getDescribe()
            .getPicklistValues();
        Map<String, String> getSourceOfTrainingDataPicklist = new Map<String, String>();
        for (Schema.PicklistEntry validApp : values) {
            getSourceOfTrainingDataPicklist.put(
                validApp.getValue(),
                validApp.getLabel()
            );
        }
        return getSourceOfTrainingDataPicklist;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getFundingThroughDlcsPicklist() {
        List<Schema.PicklistEntry> values = DisclosureInventor__c.FundingThroughDlc__c.getDescribe()
            .getPicklistValues();
        Map<String, String> fundingThroughDlcsPicklist = new Map<String, String>();
        for (Schema.PicklistEntry validApp : values) {
            fundingThroughDlcsPicklist.put(
                validApp.getValue(),
                validApp.getLabel()
            );
        }
        return fundingThroughDlcsPicklist;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getInventionDisclosureTypeOfPresentationPicklist() {
        List<Schema.PicklistEntry> values = Invention_Disclosure__c.Type_Of_Presentation__c.getDescribe()
            .getPicklistValues();
        Map<String, String> pickList = new Map<String, String>();
        for (Schema.PicklistEntry validApp : values) {
            pickList.put(validApp.getValue(), validApp.getLabel());
        }
        return pickList;
    }

    @AuraEnabled(cacheable=false)
    public static Account getContactByMitId(String mitId) {
        System.debug('mitId');
        System.debug(mitId);
        Set<String> mitIds = new Set<String>();
        mitIds.add(mitId);
        List<Account> contacts = getContactsByMitIds(mitIds);
        System.debug('contacts');
        System.debug(contacts);
        return (!contacts.isEmpty()) ? contacts[0] : null;
    }

    public static List<TLO_Officer__c> getTLOOfficersByMitIds(
        Set<String> mitIds
    ) {
        List<TLO_Officer__c> tloOfficers = [
            SELECT Id, Name, Email__c, Forrester_OfficerId__c, MitId__c
            FROM TLO_Officer__c
            WHERE MitId__c IN :mitIds
        ];

        return tloOfficers;
    }

    public static List<TLO_Officer__c> getTLOOfficersByForresterIds(
        Set<String> forresterIds
    ) {
        List<TLO_Officer__c> tloOfficers = [
            SELECT Id, Name, Email__c, Forrester_OfficerId__c, MitId__c
            FROM TLO_Officer__c
            WHERE Forrester_OfficerId__c IN :forresterIds
        ];

        return tloOfficers;
    }

    public static List<Account> getContactsByMitIds(Set<String> mitIds) {
        List<Account> contacts = [
            SELECT
                Id,
                Name,
                AltEmail__pc,
                FirstName,
                Government_Agency_Name__pc,
                GovernmentEmployeeStatus__pc,
                HHMI_Current__pc,
                Institution__pc,
                InstitutionCode__pc,
                InvitationCode__pc,
                IsAlumni__pc,
                KerbName__pc,
                LastName,
                MiddleName,
                MitId__pc,
                MoiraStatus__pc,
                OldEmail__pc,
                PersonBirthdate,
                PersonDepartment,
                PersonEmail,
                PersonMobilePhone,
                PersonOtherPhone,
                PersonTitle,
                PreferredName__pc
            FROM Account
            WHERE MitId__pc IN :mitIds AND IsPersonAccount = TRUE
        ];

        return contacts;
    }

    @AuraEnabled(cacheable=false)
    public static List<TLO_Officer__c> getTLOOfficersByIds(
        List<String> tloIds
    ) {
        List<TLO_Officer__c> tloContacts = [
            SELECT Id, Name, Email__c, Forrester_OfficerId__c, MitId__c
            FROM TLO_Officer__c
            WHERE Id IN :tloIds
        ];

        return tloContacts;
    }

    public static Map<Account, Id> getContactDisclosureMapByInventors(
        List<DisclosureInventor__c> inventors
    ) {
        // Get Contact Ids
        List<String> contactIds = new List<String>();
        for (DisclosureInventor__c inventor : inventors) {
            contactIds.add(inventor.Contact__c);
        }

        // Get Contact objects
        Map<Id, Account> contactMap = new Map<Id, Account>(
            getContactsByIds(contactIds)
        );

        // Create and populate map
        Map<Account, Id> contactDisclosureMap = new Map<Account, Id>();
        for (DisclosureInventor__c inventor : inventors) {
            contactDisclosureMap.put(
                contactMap.get(inventor.Contact__c),
                inventor.Disclosure__c
            );
        }

        return contactDisclosureMap;
    }

    // TODO: Remove once files utilizing this has been refactored.
    @AuraEnabled(cacheable=false)
    public static List<TLO_Contact__c> getTLOContactsByIds(
        List<String> tloIds
    ) {
        List<TLO_Contact__c> tloContacts = [
            SELECT
                Id,
                Name,
                Address__c,
                AltEmail__c,
                AltPhone__c,
                Birthday__c,
                City__c,
                Country__c,
                CountryOfCitizenship__c,
                Department__c,
                Email__c,
                GovernmentEmployeeStatus__c,
                HHMI_Current__c,
                Government_Agency_Name__c,
                HHMI_Current_Date_From__c,
                Institution__c,
                InstitutionCode__c,
                IsAlumni__c,
                PreferredName__c,
                LegalGivenName__c,
                LegalMiddleName__c,
                LegalLastName__c,
                MitId__c,
                OldEmail__c,
                Phone__c,
                State__c,
                Title__c,
                VaAppointment__c,
                VaAppointmentDetails__c,
                ZipCode__c,
                InvitationCode__c,
                GuestAccountNeeded__c,
                KerbName__c,
                MoiraStatus__c
            FROM TLO_Contact__c
            WHERE Id IN :tloIds
        ];

        return tloContacts;
    }

    @AuraEnabled(cacheable=false)
    public static List<Account> getContactsByIds(List<String> ids) {
        List<Account> contacts = [
            SELECT
                AltEmail__pc,
                CountryOfCitizenship__pc,
                FirstName,
                Government_Agency_Name__pc,
                GovernmentEmployeeStatus__pc,
                GuestAccountNeeded__pc,
                HHMI_Current__pc,
                HHMI_Current_Date_From__pc,
                Id,
                Institution__pc,
                InstitutionCode__pc,
                InvitationCode__pc,
                IsAlumni__pc,
                KerbName__pc,
                LastName,
                MiddleName,
                MitId__pc,
                MoiraStatus__pc,
                Name,
                OldEmail__pc,
                PersonBirthdate,
                PersonDepartment,
                PersonEmail,
                PersonMailingStreet,
                PersonMailingCity,
                PersonMailingCountry,
                PersonMailingPostalCode,
                PersonMailingState,
                PersonMobilePhone,
                PersonOtherPhone,
                PersonTitle,
                PreferredName__pc,
                VaAppointment__pc,
                VaAppointmentDetails__pc
            FROM Account
            WHERE Id IN :ids
        ];

        return contacts;
    }

    // TODO: Remove once files utilizing this has been refactored.
    @AuraEnabled(cacheable=false)
    public static TLO_Contact__c getTLOContactById(String tloId) {
        List<String> tloIds = new List<String>();
        tloIds.add(tloId);
        List<TLO_Contact__c> tloContacts = getTLOContactsByIds(tloIds);
        return (!tloContacts.isEmpty()) ? tloContacts[0] : null;
    }

    @AuraEnabled(cacheable=false)
    public static Account getContactById(String id) {
        List<String> ids = new List<String>();
        ids.add(id);
        List<Account> contacts = getContactsByIds(ids);
        return (!contacts.isEmpty()) ? contacts[0] : null;
    }

    @AuraEnabled(cacheable=false)
    public static TLO_Officer__c getTLOOfficerById(String tloId) {
        List<String> tloIds = new List<String>();
        tloIds.add(tloId);
        List<TLO_Officer__c> tloContacts = getTLOOfficersByIds(tloIds);
        return (!tloContacts.isEmpty()) ? tloContacts[0] : null;
    }

    @AuraEnabled(cacheable=false)
    public static List<Disclosure_Audit_Event__c> getDisclosureAuditEventsByDisclosureId(
        String disclosureId
    ) {
        Id castId = Id.valueOf(disclosureId);
        Disclosure__c disclosure = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Description__c,
                        CreatedById,
                        Name,
                        Event_Date__c,
                        Subject__c,
                        RecordTypeId
                    FROM Disclosure_Audit_Events__r
                )
            FROM Disclosure__c
            WHERE Id = :castId
        ];

        return disclosure.Disclosure_Audit_Events__r;
    }

    @AuraEnabled
    public static string getRecordTypeNameByAuditEventTypeId(
        id auditEventTypeId
    ) {
        RecordType recordType = [
            SELECT Id, Name
            FROM RecordType
            WHERE Id = :auditEventTypeId
        ];
        return recordType.Name;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getThirdPartyCodeFilesByDisclosureId(
        String disclosureId
    ) {
        if (disclosureId == null) {
            return null;
        }
        List<Id> thirdPartyIds = new List<Id>();
        List<Third_Party_Code__c> partyCodes = getThirdPartyCodeByDisclosureId(
            disclosureId
        );
        for (Third_Party_Code__c key : partyCodes) {
            thirdPartyIds.add(key.Id);
        }
        if (thirdPartyIds.size() > 0) {
            return getFilesByIdsAndType(thirdPartyIds, 'Disclosure');
        }

        return null;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getThirdPartyContentFilesByDisclosureId(
        String disclosureId
    ) {
        if (disclosureId == null) {
            return null;
        }
        List<Id> thirdPartyIds = new List<Id>();
        List<Third_Party_Content__c> licenseAgreements = getThirdPartyContentByDisclosureId(
            disclosureId
        );
        for (Third_Party_Content__c key : licenseAgreements) {
            thirdPartyIds.add(key.Id);
        }
        if (thirdPartyIds.size() > 0) {
            return getFilesByIdsAndType(thirdPartyIds, 'Disclosure');
        }

        return null;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getFilesByIdsAndType(
        List<String> linkedRecIds,
        String recordType
    ) {
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get(recordType)
            .getRecordTypeId();
        List<ContentDocumentLink> cdlList = [
            SELECT
                ContentDocumentId,
                LinkedEntityId,
                ContentDocument.Title,
                ContentDocument.FileExtension,
                ContentDocument.FileType,
                ContentDocument.ContentSize,
                ContentDocument.CreatedDate
            FROM ContentDocumentLink
            WHERE
                LinkedEntityId = :linkedRecIds
                AND ContentDocumentId IN (
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE RecordTypeId = :recordTypeId
                )
        ];
        return cdlList;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getFilesByType(
        String linkedRecId,
        String recordType
    ) {
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get(recordType)
            .getRecordTypeId();
        List<ContentDocumentLink> cdlList = [
            SELECT
                ContentDocumentId,
                LinkedEntityId,
                ContentDocument.Title,
                ContentDocument.FileExtension,
                ContentDocument.FileType,
                ContentDocument.ContentSize,
                ContentDocument.CreatedDate
            FROM ContentDocumentLink
            WHERE
                LinkedEntityId = :linkedRecId
                AND ContentDocumentId IN (
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE RecordTypeId = :recordTypeId
                )
        ];
        return cdlList;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getFilesByTypeAndClassification(
        String linkedRecId,
        String recordType,
        String recordClassification
    ) {
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get(recordType)
            .getRecordTypeId();
        List<ContentDocumentLink> cdlList = [
            SELECT
                ContentDocumentId,
                LinkedEntityId,
                ContentDocument.Title,
                ContentDocument.FileExtension,
                ContentDocument.FileType,
                ContentDocument.ContentSize,
                ContentDocument.CreatedDate
            FROM ContentDocumentLink
            WHERE
                LinkedEntityId = :linkedRecId
                AND ContentDocumentId IN (
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE
                        RecordTypeId = :recordTypeId
                        AND Document_Classification__c = :recordClassification
                )
        ];
        return cdlList;
    }

    @AuraEnabled
    // The size of the document in bytes.
    // Exclude the Blob to prevent 'Query of LOB fields caused heap usage to exceed limit'
    public static List<ContentVersion> getFileContentVersionsByDocumentIds(
        List<Id> contentDocumentIds
    ) {
        List<ContentVersion> cvList = [
            SELECT
                ContentDocumentId,
                ContentSize,
                CreatedDate,
                Description,
                Document_Classification__c,
                FileExtension,
                FileType,
                Title,
                RecordType.Name,
                ContentModifiedDate,
                VersionNumber
            FROM ContentVersion
            WHERE isLatest = TRUE AND ContentDocumentId IN :contentDocumentIds
        ];
        return cvList;
    }

    @AuraEnabled(cacheable=false)
    public static Boolean onBeforeApproveValidationByDisclosureId(String id) {
        List<Id> approvedDisclosureIds = new List<Id>();
        approvedDisclosureIds.add(id);

        List<DisclosureInventor__c> disInventors = DisclosureRecordFetch.getDisclosureInventorsWithContactByDisclosureId(
            id
        );
        for (DisclosureInventor__c inventor : disInventors) {
            Boolean inventorMadeSigningDecision = (inventor.Signed_Status__c !=
            null &&
            inventor.Signed_Status__c != 'Pending');

            Boolean isSubmittingInventor =
                inventor.Disclosure__r.Submitting_Contact__c ==
                inventor.Contact__c;

            if (isSubmittingInventor && !inventorMadeSigningDecision) {
                throw new AuraHandledException(
                    label.OnApprovePrimaryInventorSignedValidation +
                    ': ' +
                    inventor.Contact__r.Name
                );
            }
        }

        Map<Id, Disclosure__c> disclosureLookup = null;
        return DisclosureValidation.onBeforeApproveValidationByDisclosureId(
            disclosureLookup,
            approvedDisclosureIds
        );
    }

    @AuraEnabled(cacheable=false)
    public static TLO_Contact_Update_Request__c rejectTLOContactUpdateRequestById(
        String id
    ) {
        return changeStatusTLOContactUpdateRequestById(id, 'Rejected');
    }

    @AuraEnabled(cacheable=false)
    public static TLO_Contact_Update_Request__c markCompleteTLOContactUpdateRequestById(
        String id
    ) {
        return changeStatusTLOContactUpdateRequestById(id, 'Completed');
    }

    @AuraEnabled(cacheable=false)
    public static TLO_Contact_Update_Request__c changeStatusTLOContactUpdateRequestById(
        String id,
        String status
    ) {
        TLO_Contact_Update_Request__C cur = [
            SELECT Id, Update_Status__c
            FROM TLO_Contact_Update_Request__c
            WHERE Id = :id
            LIMIT 1
        ];

        cur.Update_Status__c = status;
        update cur;

        return cur;
    }

    @AuraEnabled(cacheable=false)
    public static Disclosure__c getDisclosureByCaseRecId(String caseRecId) {
       List<Disclosure__c> disclosures = [ SELECT External_ID__c,
                                CreatedById,
                                Case_Number__c,
                                Status__c,
                                Stage__c,
                                Name,
                                Name__c,
                                Description__c,
                                Funding_Details__c,
                                RecordType.DeveloperName,
                                SubmittedOnBehalf__c,
                                Disclosure_Reason__c,
                                Disclosure_Reason_Comment__c,
                                TLO_License_Officer__c,
                                CreatedDate,
                                LastModifiedDate
                                FROM Disclosure__c
                                WHERE Case_RecId__c = :caseRecId
            LIMIT 1
        ];
        if (disclosures.size() > 0) {
            return disclosures[0];
        }
        return null;
    }
}