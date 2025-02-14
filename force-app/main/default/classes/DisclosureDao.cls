public with sharing class DisclosureDao {
    public static Disclosure__c getDisclosureWithAllFields(
        String disclosureIdStr
    ) {
        // Get all of the fields on the object
        Map<String, Schema.SObjectField> fieldMap = Disclosure__c.sObjectType.getDescribe()
            .fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        List<String> lstFieldNames = new List<String>(setFieldNames);
        String qryString =
            'SELECT ' +
            String.join(lstFieldNames, ',') +
            ' FROM Disclosure__c WHERE Id = \'' +
            disclosureIdStr +
            '\'';
        Disclosure__c disclosure = Database.query(qryString);

        return disclosure;
    }

    public static DisclosureSummaryWrapper getDisclosureSummaryWrapperById(
        String disclosureIdStr
    ) {
        Disclosure__c disclosure = getDisclosureWithAllFields(disclosureIdStr);
        Account contact = DisclosureRecordFetch.getContactById(
            disclosure.Submitting_Contact__c
        );
        String disclosureTypeName = Schema.SObjectType.Disclosure__c.getRecordTypeInfosById()
            .get(disclosure.RecordTypeId)
            .getName();

        DisclosureSummaryWrapper summaryWrapper = new DisclosureSummaryWrapper();
        summaryWrapper.disclosure = disclosure;
        summaryWrapper.disclosureTitle = disclosure.Name__c;
        summaryWrapper.disclosureType = disclosureTypeName;
        summaryWrapper.submittingContactFullName = ContactNameUtil.toFullName(
            contact.FirstName,
            contact.MiddleName,
            contact.LastName,
            true
        );
        summaryWrapper.submittedDate = Helpers.formatDate(
            disclosure.Submitted_Date__c,
            'MMM dd, yyyy'
        );

        return summaryWrapper;
    }

    public static DisclosureWrapper getDisclosureWrapperById(
        String disclosureIdStr,
        String inventorIdStr
    ) {
        //https://niksdeveloper.com/salesforce/query-all-fields-in-soql/

        Disclosure__c disclosure = getDisclosureWithAllFields(disclosureIdStr);

        String disclosureRecordType = Schema.SObjectType.Disclosure__c.getRecordTypeInfosById()
            .get(disclosure.RecordTypeId)
            .getDeveloperName();
        String disclosureTypeName = Schema.SObjectType.Disclosure__c.getRecordTypeInfosById()
            .get(disclosure.RecordTypeId)
            .getName();
        System.debug('disclosureRecordType:- ' + disclosureRecordType);

        DisclosureWrapper disclosureWrapper = new DisclosureWrapper();
        DisclosureConditionsWrapper discCond = new DisclosureConditionsWrapper();
        disclosureWrapper.disclosureConditions = discCond;
        disclosureWrapper.disclosureConditions.emptyOrNotAnsweredText = 'Not Answered/Optional Question'; //TODO get this text from the text-api
        disclosureWrapper.recordTypeDeveloperName = disclosureRecordType;
        disclosureWrapper.disclosure = disclosure;
        disclosureWrapper.submittedOnBehalf = Helpers.YesNoFromBoolean(
            disclosureWrapper.disclosure.SubmittedOnBehalf__c
        );
        disclosureWrapper.disclosureConditions.createdDate = disclosureWrapper.disclosure.CreatedDate.format(
            'MM/dd/yyyy'
        );

        disclosureWrapper.disclosureStatus = Helpers.labelFromPicklist(
            disclosureWrapper.disclosure.Status__c,
            DisclosureRecordFetch.getDisclosureStatusPicklist()
        );

        disclosureWrapper.disclosureTitle = disclosure.Name__c;
        disclosureWrapper.disclosureType = disclosureTypeName;
        disclosureWrapper.submittedDate = Helpers.formatDate(
            disclosure.Submitted_Date__c,
            'MMM dd, yyyy'
        );

        if (disclosure.Disclosure_Reason__c != null) {
            List<String> disclosureReasons = disclosure.Disclosure_Reason__c.split(
                ';'
            );
            Map<String, String> disclosureReasonMap = DisclosureRecordFetch.getDisclosureReasonPicklist();
            disclosureWrapper.disclosureReasons = new List<String>();
            for (String disclosureReason : disclosureReasons) {
                disclosureWrapper.disclosureReasons.add(
                    disclosureReasonMap.get(disclosureReason)
                );
            }
        }

        disclosureWrapper.submittingContact = DisclosureRecordFetch.getContactById(
            disclosure.Submitting_Contact__c
        );
        disclosureWrapper.submittingContactFullName = ContactNameUtil.toFullName(
            disclosureWrapper.submittingContact.FirstName,
            disclosureWrapper.submittingContact.MiddleName,
            disclosureWrapper.submittingContact.LastName,
            true
        );
        List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsWithContactByDisclosureId(
            disclosureIdStr
        );
        disclosureWrapper.inventors = new List<DisclosureInventorWrapper>();
        for (DisclosureInventor__c inventor : inventors) {
            DisclosureInventorWrapper discInv = new DisclosureInventorWrapper();
            DisclosureConditionsWrapper discInvCond = new DisclosureConditionsWrapper();
            discInv.inventor = inventor;
            discInv.disclosureConditions = discInvCond;
            inventorMapper(discInv, inventor, disclosureRecordType);

            disclosureWrapper.inventors.add(discInv);

            if (inventorIdStr != null) {
                if (String.valueOf(inventor.Id) == inventorIdStr) {
                    disclosureWrapper.inventor = inventor;
                    disclosureWrapper.disclosureConditions = discInvCond;
                    disclosureWrapper.disclosureConditions.signedByName = 'Not Signed'; // Hack ...
                }
            }
        }

        List<DisclosureExternalFunding__c> externalFunding = DisclosureRecordFetch.getDisclosureExternalFundingByDisclosureId(
            disclosureIdStr
        );

        List<DisclosureExternalFunding__c> externalFundingKC = new List<DisclosureExternalFunding__c>();
        List<DisclosureExternalFunding__c> externalFundingManual = new List<DisclosureExternalFunding__c>();
        for (DisclosureExternalFunding__c externalFund : externalFunding) {
            if (String.isEmpty(externalFund.Manual_Name__c)) {
                externalFundingKC.add(externalFund);
            } else {
                externalFundingManual.add(externalFund);
            }
        }

        if (!externalFundingKC.isEmpty()) {
            disclosureWrapper.externalFundingKC = externalFundingKC;
        }
        if (!externalFundingManual.isEmpty()) {
            disclosureWrapper.externalFundingManual = externalFundingManual;
        }

        disclosureWrapper.internalFunding = DisclosureRecordFetch.getDisclosureInternalFundingByDisclosureId(
            disclosureIdStr
        );
        List<Department_Head__c> departmentHeads = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
            disclosureIdStr
        );
        if (!departmentHeads.isEmpty()) {
            disclosureWrapper.departmentHead = departmentHeads[0];
        }

        disclosureWrapper.commercialInterests = DisclosureRecordFetch.getCommercialInterestsByDisclosureId(
            disclosureIdStr
        );

        if (disclosureRecordType == 'BioTang_Disclosure') {
            disclosureWrapper.biotang = DisclosureRecordFetch.getBioTangByDisclosureId(
                disclosureIdStr
            )[0];
            disclosureWrapper.materials = DisclosureRecordFetch.getLabMaterialsByBioTangId(
                disclosureWrapper.biotang.Id
            );
            String bioTangRecordType = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosById()
                .get(disclosureWrapper.biotang.RecordTypeId)
                .getDeveloperName();
            disclosureWrapper.subTypeDeveloperName = bioTangRecordType;
            disclosureWrapper.disclosureConditions.subTypeName = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosById()
                .get(disclosureWrapper.biotang.RecordTypeId)
                .getName();
            disclosureWrapper.disclosureConditions.inventorTypeName = 'author(s)';
            if (bioTangRecordType == 'cellLine') {
                disclosureWrapper.cellLine = DisclosureRecordFetch.getCellLineByBioTangId(
                    disclosureWrapper.biotang.Id
                )[0];
            }
            if (bioTangRecordType == 'plasmid') {
                disclosureWrapper.plasmid = DisclosureRecordFetch.getPlasmidByBioTangId(
                    disclosureWrapper.biotang.Id
                )[0];
            }
            if (bioTangRecordType == 'otherMaterial') {
                disclosureWrapper.otherMaterial = DisclosureRecordFetch.getOtherMaterialByBioTangId(
                    disclosureWrapper.biotang.Id
                )[0];
            }
            if (bioTangRecordType == 'mouseStrain') {
                disclosureWrapper.isMouseStrain = true;
                disclosureWrapper.mouseStrainWrapper = new MouseStrainWrapper();
                disclosureWrapper.mouseStrainWrapper.mouseStrain = DisclosureRecordFetch.getMouseStrainByBioTangId(
                    disclosureWrapper.biotang.Id
                )[0];
                disclosureWrapper.mouseStrainWrapper.genCrossOther = Helpers.YesNoFromBoolean(
                    disclosureWrapper.mouseStrainWrapper.mouseStrain.Mouse_Gen_Cross_Other__c
                );
            }
            if (bioTangRecordType == 'antibody') {
                disclosureWrapper.isAntibody = true;
                disclosureWrapper.antibodyWrapper = new AntibodyWrapper();
                disclosureWrapper.antibodyWrapper.antibody = DisclosureRecordFetch.getAntibodyByBioTangId(
                    disclosureWrapper.biotang.Id
                )[0];

                List<String> selectedValidApplicationItems = new List<String>();
                if (
                    disclosureWrapper.antibodyWrapper.antibody.antibodyValidApplications__c !=
                    null
                ) {
                    selectedValidApplicationItems = disclosureWrapper.antibodyWrapper.antibody.antibodyValidApplications__c.split(
                        ';'
                    );
                }
                disclosureWrapper.antibodyWrapper.antibodyValidApplications = new List<AntibodyValidApplication>();
                Schema.DescribeFieldResult fieldDetail = Antibody__c.antibodyValidApplications__c.getDescribe();
                List<Schema.PicklistEntry> validApplicationValues = fieldDetail.getPicklistValues();
                for (
                    Schema.PicklistEntry pickListVal : validApplicationValues
                ) {
                    if (
                        selectedValidApplicationItems.contains(
                            pickListVal.getValue()
                        )
                    ) {
                        AntibodyValidApplication antibodyValidApplication = new AntibodyValidApplication(
                            pickListVal.getValue(),
                            'Yes'
                        );
                        disclosureWrapper.antibodyWrapper.antibodyValidApplications.add(
                            antibodyValidApplication
                        );
                    } else {
                        AntibodyValidApplication antibodyValidApplication = new AntibodyValidApplication(
                            pickListVal.getValue(),
                            'No'
                        );
                        disclosureWrapper.antibodyWrapper.antibodyValidApplications.add(
                            antibodyValidApplication
                        );
                    }
                }
            }
            if (disclosureWrapper.biotang.publications__c == 'Yes') {
                disclosureWrapper.hasPublicationLinks = true;
            } else if (disclosureWrapper.biotang.publications__c == 'No') {
                disclosureWrapper.hasPublicationLinks = false;
            }

            if (
                disclosureWrapper.biotang.depositedAtRepository__c == 'No' ||
                disclosureWrapper.biotang.depositedAtRepository__c == 'Unknown'
            ) {
                disclosureWrapper.hasDetails = false;
            } else {
                disclosureWrapper.hasDetails = true;
            }
        }

        if (disclosureRecordType == 'Invention_Disclosure') {
            disclosureWrapper.inventionWrapper = new InventionWrapper();
            Invention_Disclosure__c invention = DisclosureRecordFetch.getInventionByDisclosureId(
                disclosureIdStr
            )[0];
            disclosureWrapper.inventionWrapper.invention = invention;
            disclosureWrapper.disclosureConditions.inventorTypeName = 'inventor(s)';

            disclosureWrapper.inventionWrapper.anticipatedPublicationDisclosure = Helpers.BooleanFromYesNo(
                invention.Disclosure_Anticipated_Publication__c
            );
            disclosureWrapper.inventionWrapper.anticipatedPublicationDisclosureDate = Helpers.formatDate(
                invention.Anticipated_Publication_Disclosure_Date__c,
                'MMM dd, yyyy'
            );
            disclosureWrapper.inventionWrapper.conceptionDate = Helpers.formatDate(
                invention.Conception_Date__c,
                'MMM dd, yyyy'
            );
            disclosureWrapper.inventionWrapper.oralDisclosureDate = Helpers.formatDate(
                invention.Oral_Disclosure_Date__c,
                'MMM dd, yyyy'
            );
            disclosureWrapper.inventionWrapper.oralPresentation = Helpers.BooleanFromYesNo(
                invention.Disclosure_Oral_Presentation__c
            );
            disclosureWrapper.inventionWrapper.partOfThesis = Helpers.BooleanFromYesNo(
                invention.Disclosure_Part_Of_Thesis__c
            );
            disclosureWrapper.inventionWrapper.publicationDate = Helpers.formatDate(
                invention.Publication_Date__c,
                'MMM dd, yyyy'
            );
            disclosureWrapper.inventionWrapper.publishedOrDisclosed = Helpers.BooleanFromYesNo(
                invention.Disclosure_Published_Or_Disclosed__c
            );
            disclosureWrapper.inventionWrapper.reducedToPractice = Helpers.BooleanFromYesNo(
                invention.Disclosure_Reduced_To_Practice__c
            );
            disclosureWrapper.inventionWrapper.reducedToPracticeDate = Helpers.formatDate(
                invention.Reduced_To_Practice_Date__c,
                'MMM dd, yyyy'
            );
            disclosureWrapper.inventionWrapper.thesisHold = Helpers.BooleanFromYesNo(
                invention.Disclosure_Thesis_Hold__c
            );
            disclosureWrapper.inventionWrapper.materialsFromOtherLab = invention.Materials_From_Other_Labs__c;
            disclosureWrapper.inventionWrapper.materialsFurtherComments = invention.materialsFurtherComments__c;

            List<Third_Party_Material__c> materials = DisclosureRecordFetch.getThirdPartyMaterialsByInventionId(
                invention.Id
            );
            if (!materials.isEmpty()) {
                for (Third_Party_Material__c material : materials) {
                    material.How_Was_Material_Obtained__c = Helpers.convertSemicolonToComma(
                        material.How_Was_Material_Obtained__c
                    );
                }
                disclosureWrapper.inventionWrapper.materials = materials;
            }

            List<Thesis__c> thesis = DisclosureRecordFetch.getThesisDetailsByInventionId(
                disclosureWrapper.inventionWrapper.invention.Id
            );
            if (!thesis.isEmpty()) {
                disclosureWrapper.thesis = thesis[0];
                disclosureWrapper.inventionWrapper.thesisDefenseDate = Helpers.formatDate(
                    disclosureWrapper.thesis.Thesis_Defense_Date__c,
                    'MMM dd, yyyy'
                );
                disclosureWrapper.inventionWrapper.thesisSubmittedDate = Helpers.formatDate(
                    disclosureWrapper.thesis.Thesis_Submitted_Date__c,
                    'MMM dd, yyyy'
                );
                disclosureWrapper.inventionWrapper.thesisDegreeDate = Helpers.formatDate(
                    disclosureWrapper.thesis.Thesis_Degree_Date__c,
                    'MMM dd, yyyy'
                );
            }

            if (invention.Type_Of_Presentation__c != null) {
                disclosureWrapper.inventionWrapper.typeOfPresentations = Helpers.labelsFromMultiPicklist(
                    invention.Type_Of_Presentation__c,
                    DisclosureRecordFetch.getInventionDisclosureTypeOfPresentationPicklist()
                );
            }
        }

        if (disclosureRecordType == 'Copyright_Disclosure') {
            disclosureWrapper.copyrightWrapper = new CopyrightWrapper();
            disclosureWrapper.copyrightWrapper.copyright = DisclosureRecordFetch.getCopyrightByDisclosureId(
                disclosureIdStr
            )[0];
            disclosureWrapper.disclosureConditions.inventorTypeName = 'creator(s)';

            disclosureWrapper.copyrightWrapper.creatorsRequestDistributeOpenSource = disclosureWrapper.copyrightWrapper.copyright.Creators_Request_Distrib_Open_Source_YN__c;
            disclosureWrapper.copyrightWrapper.partOfEmployment = disclosureWrapper.copyrightWrapper.copyright.Part_Of_Employment_YN__c;

            disclosureWrapper.openSource = DisclosureRecordFetch.getOpenSourceByCopyrightId(
                disclosureWrapper.copyrightWrapper.copyright.Id
            );
            disclosureWrapper.thirdPartyContent = DisclosureRecordFetch.getThirdPartyContentByCopyrightId(
                disclosureWrapper.copyrightWrapper.copyright.Id
            );

            disclosureWrapper.softwarePubliclyAvailable = new List<String>();
            for (Open_Source__c openSourceItem : disclosureWrapper.openSource) {
                if (openSourceItem.Publicly_Available_Details__c != null) {
                    if (
                        openSourceItem.Publicly_Available_Details__c.length() >
                        0
                    ) {
                        disclosureWrapper.softwarePubliclyAvailable.add(
                            openSourceItem.Publicly_Available_Details__c
                        );
                    }
                }
            }
        }

        if (disclosureRecordType == 'Software_Code_Disclosure') {
            disclosureWrapper.softwareCodeWrapper = new SoftwareCodeWrapper();
            disclosureWrapper.softwareCodeWrapper.softwareCode = DisclosureRecordFetch.getSoftwareCodeByDisclosureId(
                disclosureIdStr
            )[0];
            disclosureWrapper.disclosureConditions.inventorTypeName = 'inventor(s)';

            disclosureWrapper.softwareCodeWrapper.isOpenSource = Helpers.BooleanFromYesNo(
                disclosureWrapper.softwareCodeWrapper.softwareCode.Is_Open_Source_YN__c
            );
            disclosureWrapper.softwareCodeWrapper.partOfEmployment = disclosureWrapper.softwareCodeWrapper.softwareCode.Part_Of_Employment_YN__c;
            disclosureWrapper.softwareCodeWrapper.yearsCodeFirstCreated = disclosureWrapper.softwareCodeWrapper.softwareCode.Years_Code_First_Created__c;
            disclosureWrapper.softwareCodeWrapper.yearsCodeFirstPublished = disclosureWrapper.softwareCodeWrapper.softwareCode.Years_Code_First_Published__c;
            disclosureWrapper.softwareCodeWrapper.useThirdPartyCode = Helpers.BooleanFromYesNo(
                disclosureWrapper.softwareCodeWrapper.softwareCode.Use_Any_Third_Party_Code__c
            );

            disclosureWrapper.openSource = DisclosureRecordFetch.getOpenSourceBySoftwareCodeId(
                disclosureWrapper.softwareCodeWrapper.softwareCode.Id
            );
            disclosureWrapper.thirdPartCode = DisclosureRecordFetch.getThirdPartyCodeBySoftwareCodeId(
                disclosureWrapper.softwareCodeWrapper.softwareCode.Id
            );

            disclosureWrapper.softwareCodeWrapper.sourceOfTrainingData = Helpers.stringFromMultiPicklist(
                disclosureWrapper.softwareCodeWrapper.softwareCode.Source_of_Training_Data__c,
                DisclosureRecordFetch.getSourceOfTrainingDataPicklist()
            );

            disclosureWrapper.softwarePubliclyAvailable = new List<String>();
            for (Open_Source__c openSourceItem : disclosureWrapper.openSource) {
                if (openSourceItem.Publicly_Available_Details__c != null) {
                    if (
                        openSourceItem.Publicly_Available_Details__c.length() >
                        0
                    ) {
                        disclosureWrapper.softwarePubliclyAvailable.add(
                            openSourceItem.Publicly_Available_Details__c
                        );
                    }
                }
            }

            if (
                disclosureWrapper.softwareCodeWrapper.softwareCode.Derivative__c ==
                'Yes, but it’s open source' ||
                disclosureWrapper.softwareCodeWrapper.softwareCode.Derivative__c ==
                'Yes, but it’s from a third-party and it is not open source' ||
                disclosureWrapper.softwareCodeWrapper.softwareCode.Derivative__c ==
                'No' ||
                disclosureWrapper.softwareCodeWrapper.softwareCode.Derivative__c ==
                'Other'
            ) {
                disclosureWrapper.softwareCodeWrapper.softwareDerivativeNonMIT = true;
            }
        }

        String strJSON = JSON.serialize(disclosureWrapper);
        System.debug(strJSON);

        return disclosureWrapper;
    }

    public static DisclosureInventorWrapper getInventorById(
        Id disclosureId,
        Id inventorId
    ) {
        Disclosure__c disclosure = getDisclosureWithAllFields(
            String.valueOf(disclosureId)
        );
        String disclosureRecordType = Schema.SObjectType.Disclosure__c.getRecordTypeInfosById()
            .get(disclosure.RecordTypeId)
            .getDeveloperName();

        DisclosureInventorWrapper disclosureInventorWrapper = new DisclosureInventorWrapper();
        DisclosureConditionsWrapper discCond = new DisclosureConditionsWrapper();
        disclosureInventorWrapper.disclosureConditions = discCond;
        disclosureInventorWrapper.disclosureConditions.emptyOrNotAnsweredText = 'Not Answered/Optional Question'; //TODO get this text from the text-api

        if (disclosureRecordType == 'BioTang_Disclosure') {
            BioTang_Disclosure__c biotang = DisclosureRecordFetch.getBioTangByDisclosureId(
                String.valueOf(disclosureId)
            )[0];
            disclosureInventorWrapper.disclosureConditions.subTypeName = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosById()
                .get(biotang.RecordTypeId)
                .getName();
            disclosureInventorWrapper.disclosureConditions.inventorTypeName = 'author(s)';
        }
        if (disclosureRecordType == 'Invention_Disclosure') {
            disclosureInventorWrapper.disclosureConditions.inventorTypeName = 'inventor(s)';
        }
        if (disclosureRecordType == 'Copyright_Disclosure') {
            disclosureInventorWrapper.disclosureConditions.inventorTypeName = 'creator(s)';
        }
        if (disclosureRecordType == 'Software_Code_Disclosure') {
            disclosureInventorWrapper.disclosureConditions.inventorTypeName = 'inventor(s)';
        }

        List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsWithContactByDisclosureIdInventorId(
            disclosureId,
            inventorId
        );
        if (!inventors.isEmpty()) {
            inventorMapper(
                disclosureInventorWrapper,
                inventors[0],
                disclosureRecordType
            );
            if (disclosure.CreatedDate != null) {
                disclosureInventorWrapper.disclosureConditions.createdDate = disclosure.CreatedDate.format(
                    'MM/dd/yyyy'
                );
            }
        }

        // disclosureInventorWrapper.recipientId = '1';
        // String strJSON = JSON.serialize(disclosureInventorWrapper);
        // System.debug(strJSON);
        return disclosureInventorWrapper;
    }

    private static void inventorMapper(
        DisclosureInventorWrapper disclosureInventorWrapper,
        DisclosureInventor__c inventor,
        String disclosureRecordType
    ) {
        disclosureInventorWrapper.inventor = inventor;
        disclosureInventorWrapper.disclosureConditions.emptyOrNotAnsweredText = 'Not Answered/Optional Question';
        disclosureInventorWrapper.disclosureConditions.isPrimaryInventor = Helpers.YesNoFromBoolean(
            inventor.PrimaryInventor__c
        );
        disclosureInventorWrapper.disclosureConditions.inventorFullName = ContactNameUtil.toFullName(
            inventor.Contact__r.FirstName,
            inventor.Contact__r.MiddleName,
            inventor.Contact__r.LastName,
            true
        );
        disclosureInventorWrapper.disclosureConditions.signedByName = ContactNameUtil.toFullName(
            inventor.Contact__r.FirstName,
            inventor.Contact__r.MiddleName,
            inventor.Contact__r.LastName,
            true
        );
        disclosureInventorWrapper.disclosureConditions.isNonMitSalary = Helpers.IsNonMitSalary(
            inventor.SalaryWages__c
        );
        disclosureInventorWrapper.disclosureConditions.isWorkDoneOutsideMit = Helpers.booleanFromYesNoUnknown(
            inventor.WorkDoneOutsideMIT__c
        );
        disclosureInventorWrapper.disclosureConditions.isPartOfCollaboration = Helpers.booleanFromYesNoUnknown(
            inventor.Collaboration__c
        );
        disclosureInventorWrapper.disclosureConditions.isConsultantOrContract = Helpers.booleanFromYesNoUnknown(
            inventor.ConsultantOrContract__c
        );
        disclosureInventorWrapper.disclosureConditions.fundingThroughDlcs = Helpers.stringFromMultiPicklist(
            inventor.FundingThroughDlc__c,
            DisclosureRecordFetch.getFundingThroughDlcsPicklist()
        );
        disclosureInventorWrapper.disclosureConditions.affiliatedWithOrgsDlcs = Helpers.stringFromMultiPicklist(
            inventor.AffiliatedWithOrgsDlcs__c,
            DisclosureRecordFetch.getAffiliatedWithOrgsDlcsPicklist()
        );
        disclosureInventorWrapper.disclosureConditions.isPartOfClass = Helpers.booleanFromYesNoUnknown(
            inventor.PartOfClass__c
        );
        disclosureInventorWrapper.disclosureConditions.isActiveKerb = Helpers.isActiveKerb(
            inventor.Contact__r.MoiraStatus__pc
        );
        disclosureInventorWrapper.disclosureConditions.createdDate = inventor.Disclosure__r.CreatedDate.format(
            'MM/dd/yyyy'
        );
        disclosureInventorWrapper.disclosureConditions.tenureFromDate = Helpers.formatDate(
            inventor.HHMI_tenure_date_from__c,
            'MMM dd, yyyy'
        );
        disclosureInventorWrapper.disclosureConditions.tenureToDate = Helpers.formatDate(
            inventor.HHMI_tenure_date_to__c,
            'MMM dd, yyyy'
        );
        disclosureInventorWrapper.disclosureConditions.tenureStartDate = Helpers.formatDate(
            inventor.Contact__r.HHMI_Current_Date_From__pc,
            'MMM dd, yyyy'
        );

        if (inventor.Contact__r.VaAppointment__pc == 'Yes') {
            disclosureInventorWrapper.disclosureConditions.hasWOCorDAPwithVA = true;
        } else if (inventor.Contact__r.VaAppointment__pc == 'No') {
            disclosureInventorWrapper.disclosureConditions.hasWOCorDAPwithVA = false;
        }
    }
}