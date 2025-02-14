public class DisclosureInventorSignedToForrester implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public class ForresterCalloutException extends Exception {}
    public Database.QueryLocator start(Database.BatchableContext bc){
        Integer retryCount = Integer.ValueOf(retryCount());
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Has_Processed__c,
                    Retry_Count__c,
                    Record_Id__c,
                    sObject_Name__c,
                    Job_Name__c
                FROM Async_Request__c
                WHERE
                    Has_Processed__c = FALSE
                    AND Retry_Count__c < :retryCount
                    AND sObject_Name__c = 'DisclosureInventor__c'
                    AND (Job_Name__c = 'InventorSignedDisclosureToForresterJob'
                    OR Job_Name__c = 'InventorAddedToApprovedDisclosureToForresterJob')
                ORDER BY Job_Name__c
            ]
        );
        // Order by Job Name to add new inventors first.
    }
    public static DisclosureInventor__c getDisclosureInventorById(
        String RecordId
    ) {
        DisclosureInventor__c disinv = [
            SELECT
                Id,
                PrimaryInventor__c,
                Signed_Status__c,
                Signed_Disclosure_Date__c,
                Signed_Comment__c,
                MitAtTimeOfInvention__c,
                Contact__c,
                Disclosure__r.SubmittedOnBehalf__c,
                Disclosure__r.Case_Number__c,
                //Extra Questions
                SalaryWages__c,
                SalaryWagesDetails__c,
                AdditionalComments__c,
                AdditionalSponsorsOrFunding__c,
                CollaborationDetails__c,
                ConsultantOrContractDetails__c,
                PartOfClassDetails__c,
                WorkDoneOutsideMIT__c,
                WorkDoneOutsideMITDetails__c,
                toLabel(FundingThroughDlc__c),
                Contact__r.FirstName,
                Contact__r.MiddleName,
                Contact__r.LastName,
                toLabel(AffiliatedWithOrgsDlcs__c),
                ConsultantOrContract__c,
                WorkDoneAtMIT__c,
                Collaboration__c,
                PartOfClass__c,
                Contact__r.Name,
                ThirdPartyMaterials__c
            FROM DisclosureInventor__c
            WHERE Id = :RecordId
        ];
        return disinv;
    }
    public void execute(
        Database.BatchableContext bc,
        List<Async_Request__c> scope
    ) {
        try {
            Async_Request__c async = scope[0];
            if (scope != null && async != null && async.Record_Id__c != null) {
                Map<String, String> headers = new Map<String, String>();

                DisclosureInventor__c disinv = getDisclosureInventorById(
                    async.Record_Id__c
                );
                Account tloContact = DisclosureRecordFetch.getContactById(
                    disinv.Contact__c
                );

                headers.put('Content-Type', 'application/json');
                String apiName = 'forresterApi';
                String endpoints =
                    '/disclosures/' +
                    disinv.Disclosure__r.Case_Number__c +
                    '';
                String response = null;
                Boolean includeExtraQuestions = true;
                if (
                    async.Job_Name__c ==
                    'InventorAddedToApprovedDisclosureToForresterJob'
                ) {
                    includeExtraQuestions = false; // Inventor need to answer it first
                    response = AwsApiCall.restPost(
                        apiName,
                        endpoints,
                        headers,
                        prepareJSONRequestBody(
                            disinv,
                            tloContact,
                            includeExtraQuestions
                        )
                    );
                } else {
                    response = AwsApiCall.restPatch(
                        apiName,
                        endpoints,
                        headers,
                        prepareJSONRequestBody(
                            disinv,
                            tloContact,
                            includeExtraQuestions
                        )
                    );
                }
                System.debug('Signed Disclosure Batch response ' + response);
                Map<String, Object> respObj = (Map<String, Object>) JSON.deserializeUntyped(
                    response
                );
                if (String.valueOf(respObj.get('status')) == 'SUCCESS') {
                    async.Has_Processed__c = true;
                } else {
                    Integer count = Integer.valueOf(async.Retry_Count__c);
                    async.Retry_Count__c = count + 1;
                    async.Has_Processed__c = false;
                }
                update async;

                if(async.Has_Processed__c == false) {
                    // log exception only after the retry count is updated
                    String message = respObj.get('message') != null ? String.valueOf(respObj.get('message')) : '';
                    throw new ForresterCalloutException('Unable to update Forrester: retry count ['+ async.Retry_Count__c +'] ' + message);
                }

            }
        } catch (exception ex) {
            HandleLogException.logException(ex);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    public static String prepareJSONRequestBody(
        DisclosureInventor__c disinv,
        Account tloContact,
        Boolean includeExtraQuestions
    ) {
        ForresterDto.InventorDto inventor = new ForresterDto.InventorDto();
        inventor.mitId = tloContact.MitId__pc;
        inventor.inventorName = ContactNameUtil.toFullName(
            tloContact.FirstName,
            tloContact.MiddleName,
            tloContact.LastName,
            true
        );
        inventor.legalGivenName = tloContact.FirstName;
        inventor.legalMiddleName = tloContact.MiddleName;
        inventor.legalLastName = tloContact.Lastname;
        inventor.email = tloContact.PersonEmail;
        inventor.oldEmail = null; //old email only used to change email, It should only be used once
        inventor.hhmi = tloContact.HHMI_Current__pc;
        inventor.signedDisclosureComment = disinv.Signed_Comment__c;
        inventor.signedDisclosureFlag = Helpers.signedStatusBoolean(
            disinv.Signed_Status__c
        );
        inventor.govEmployeeStatusFlag = tloContact.GovernmentEmployeeStatus__pc;
        inventor.atMitAtTheTimeOfInvention = disinv.MitAtTimeOfInvention__c;
        inventor.alternatePhone = tloContact.PersonMobilePhone;
        inventor.alternateEmail = tloContact.AltEmail__pc;
        inventor.alternateAddress = tloContact.PersonMailingStreet;
        inventor.alternateAddressCity = tloContact.PersonMailingCity;
        inventor.alternateAddressState = tloContact.PersonMailingState;
        inventor.alternateAddressZipcode = tloContact.PersonMailingPostalCode;
        inventor.alternateAddressCountry = tloContact.PersonMailingCountry;
        inventor.countryCitizenship = tloContact.CountryOfCitizenship__pc;
        inventor.submitOnBehalfOf = false; // False by default SOB does not automatically get added as inventor and cannot add themselves as an inventor either
        inventor.primaryContact = disinv.PrimaryInventor__c;
        inventor.institution = tloContact.Institution__pc;
        inventor.institutionCode = tloContact.InstitutionCode__pc;
        inventor.birthday = Helpers.birthDayFromValue(
            tloContact.PersonBirthdate
        );
        inventor.position = tloContact.PersonTitle;
        inventor.department = tloContact.PersonDepartment;
        if (includeExtraQuestions) {
            ForresterDto.AdditionalInformationDto extraInfo = mapAdditionalInformation(
                disinv
            );
            if (JSON.serialize(extraInfo, true) != '{}') {
                inventor.additionalInformation = extraInfo;
            }
        }

        List<ForresterDto.InventorDto> inventors = new List<ForresterDto.InventorDto>();
        inventors.add(inventor);
        PatchDisclosureDto jsonBody = new PatchDisclosureDto();
        jsonBody.user = Label.MIT_ForresterUser;
        jsonBody.inventors = inventors;

        Boolean suppressApexObjectNulls = true;
        return JSON.serialize(jsonBody, suppressApexObjectNulls);
    }

    private static ForresterDto.AdditionalInformationDto mapAdditionalInformation(
        DisclosureInventor__c disinv
    ) {
        ForresterDto.AdditionalInformationDto additionalInformation = new ForresterDto.AdditionalInformationDto();
        additionalInformation.salaryOrWages = disinv.SalaryWages__c;
        additionalInformation.salaryOrWagesDetail = disinv.SalaryWagesDetails__c;
        additionalInformation.workAtMit = disinv.WorkDoneAtMIT__c;
        additionalInformation.workAtOtherInstitution = disinv.WorkDoneOutsideMIT__c;
        additionalInformation.workAtOtherInstitutionMoreDetail = disinv.WorkDoneOutsideMITDetails__c;
        additionalInformation.wasResearchAsPartOfCollaboration = disinv.Collaboration__c;
        additionalInformation.wasResearchAsPartOfCollaborationMoreDetail = disinv.CollaborationDetails__c;
        additionalInformation.wasResearchAsPerformedByConsultant = disinv.ConsultantOrContract__c;
        additionalInformation.wasResearchAsPerformedByConsultantMoreDetail = disinv.ConsultantOrContractDetails__c;
        if (disinv.FundingThroughDlc__c != null) {
            additionalInformation.fundingDlc = new List<String>{
                disinv.FundingThroughDlc__c
            };
        }
        if (disinv.AffiliatedWithOrgsDlcs__c != null) {
            additionalInformation.affiliationOptions = new List<String>{
                disinv.AffiliatedWithOrgsDlcs__c
            };
        }
        additionalInformation.additionalSponsoredResearchOrFundingSources = disinv.AdditionalSponsorsOrFunding__c;
        additionalInformation.conceivedDuringCourseWork = disinv.PartOfClass__c;
        additionalInformation.conceivedDuringCourseWorkMoreDetail = disinv.PartOfClassDetails__c;
        additionalInformation.thirdPartyMaterialsOrDatasets = disinv.ThirdPartyMaterials__c;
        additionalInformation.additionalComments = disinv.AdditionalComments__c;
        return additionalInformation;
    }

    private static String retryCount() {
        return ConfigurationBuilder.getConfigurationToString(
            'batchJobMaxNumberOfRetry'
        );
    }
}