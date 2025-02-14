public with sharing class DisclosureInventorTriggerHandler {
    public static void onBeforeInsert(
        List<DisclosureInventor__c> disInventors
    ) {
        validateDisclosureInventor(disInventors);
        validationQuestion(disInventors);
        validateInventorEmail(disInventors);
        for (DisclosureInventor__c disinv : disInventors) {
            // EMPTY IF ANSWER MIT
            if (disinv.SalaryWages__c == 'MIT') {
                disinv.SalaryWagesDetails__c = '';
            }
        }
        assignIPIALookup(disInventors);
    }

    public static void onBeforeUpdate(
        List<DisclosureInventor__c> disInventors,
        Map<Id, DisclosureInventor__c> oldDisInventors
    ) {
        validationQuestion(disInventors);
        validateInventorEmail(disInventors);

        for (DisclosureInventor__c disinv : disInventors) {
            // Map DocuSign Recipient Statuses (ie: Inventor Signed Status on DocuSign to Salesforce Object)
            if (disinv.DocuSign_Recipient_StatusCode__c == 'Completed') {
                disinv.Signed_Status__c = 'Yes';
            }

            if (disinv.Signed_Status__c == 'Opted Out') {
                disinv.Signed_Disclosure_Date__c = Datetime.now();
            }

            // EMPTY IF ANSWER MIT
            if (disinv.SalaryWages__c == 'MIT') {
                disinv.SalaryWagesDetails__c = '';
            }

            // EMPTY IF ANSWER NO
            if (disinv.WorkDoneOutsideMIT__c == 'No') {
                disinv.WorkDoneOutsideMITDetails__c = '';
            }

            if (disinv.Collaboration__c == 'No') {
                disinv.CollaborationDetails__c = '';
            }

            if (disinv.ConsultantOrContract__c == 'No') {
                disinv.ConsultantOrContractDetails__c = '';
            }

            if (disinv.PartOfClass__c == 'No') {
                disinv.PartOfClassDetails__c = '';
            }

            // FIXME: Can this be removed?
            // 3170 Changes
            if (!disinv.Currently_affiliated_with_HHMI__c) {
                //Below Field Cannot be updated Because its a formula field
                //disinv.Current_date_of_Tenure_from__c = null;
            }

            if (!disinv.HHMI_At_Time_of_Invention__c) {
                disinv.HHMI_tenure_date_from__c = null;
                disinv.HHMI_tenure_date_to__c = null;
            }
        }
    }

    public static void onAfterInsert(
        List<DisclosureInventor__c> disclosureInventorList
    ) {
        // Add "Sign Disclosure" actions where necessary
        initInventorSignAction(disclosureInventorList);

        List<String> disclosureInventorIds = new List<String>();

        for (DisclosureInventor__c disinv : disclosureInventorList) {
            disclosureInventorIds.add(disinv.Id);
        }

        if (disclosureInventorIds != null && !disclosureInventorIds.isEmpty()) {
            List<DisclosureInventor__c> inventorList = DisclosureRecordFetch.getDisclosureInventorsByIds(
                disclosureInventorIds
            );

            // Replacing DisclosureInventorNotification onApprovedInventorAdded
            DisclosureInventorEventProducer.onApprovedInventorAdded(
                inventorList
            );
        }
    }

    public static void onBeforeDelete(
        List<DisclosureInventor__c> disclosureInventorList
    ) {
        List<String> disclosureInventorId = new List<String>();

        for (DisclosureInventor__c disinv : disclosureInventorList) {
            disclosureInventorId.add(disinv.Id);
        }

        if (!disclosureInventorId.isEmpty()) {
            List<DisclosureInventor__c> inventorList = DisclosureRecordFetch.getDisclosureInventorsByIds(
                disclosureInventorId
            );
            DisclosureInventorNotification.onInventorDeleted(inventorList);
        }
    }

    public static void onAfterUpdate(
        List<DisclosureInventor__c> currDisclosureInventorList,
        Map<Id, DisclosureInventor__c> oldDisclosureInventorList
    ) {
        List<String> disclosureInventorIds = new List<String>();
        Set<String> signedInventorIds = new Set<String>();
        Set<String> optedOutInventorIds = new Set<String>();

        for (DisclosureInventor__c currInventor : currDisclosureInventorList) {
            disclosureInventorIds.add(currInventor.Id);

            DisclosureInventor__c prevInventor = (oldDisclosureInventorList !=
                null &&
                oldDisclosureInventorList.get(currInventor.Id) != null)
                ? oldDisclosureInventorList.get(currInventor.Id)
                : null;
            String newSignedStatus = currInventor.Signed_Status__c;
            String prevSignedStatus = prevInventor != null
                ? prevInventor.Signed_Status__c
                : null;
            Boolean inventorMadeSigningDecision = (newSignedStatus == 'Yes' ||
            newSignedStatus == 'Opted Out');

            // If the inventor has just signed (or opted out) the Disclosure
            if (
                inventorMadeSigningDecision &&
                newSignedStatus != prevSignedStatus
            ) {
                signedInventorIds.add(currInventor.Id);
            }
        }

        if (!signedInventorIds.isEmpty()) {
            List<DisclosureInventor__c> signedInventorDetails = [
                SELECT
                    Id,
                    AdditionalComments__c,
                    Contact__r.Name,
                    Contact__r.PersonEmail,
                    Disclosure__r.Case_Number__c,
                    Disclosure__r.Name__c,
                    Disclosure__r.Name,
                    Disclosure__r.SubmittedOnBehalf__c,
                    Disclosure__r.Submitting_Contact__r.Name,
                    Disclosure__r.Submitting_Contact__c,
                    Disclosure_Title__c,
                    Inventor_Name__c,
                    Signed_Comment__c,
                    Signed_Status__c,
                    Title__c,
                    Contact__c
                FROM DisclosureInventor__c
                WHERE Id IN :(signedInventorIds)
            ];

            DisclosureOpsNotification.sendNotificationEachSignedInventor(
                signedInventorDetails
            );

            DisclosureCreateAuditEvent.createInventorSignatureAudit(
                signedInventorDetails
            );

            ContactActionHandler.completeSignDisclosureActions(
                signedInventorDetails
            );

            DisclosureInventorSignedHandler.handleInventorSigned(
                signedInventorDetails
            );
        }

        if (disclosureInventorIds != null && !disclosureInventorIds.isEmpty()) {
            List<DisclosureInventor__c> queryInventors = DisclosureRecordFetch.getDisclosureInventorsByIds(
                disclosureInventorIds
            );
            DisclosureInventorNotification.onPrimaryInventorRemoved(
                queryInventors,
                oldDisclosureInventorList
            );
        }
    }

    /**
     * Create "Sign Disclosure" actions for inventors where applicable
     * @param disclosureInventorList List of Disclosure Inventors to be processed
     */
    public static void initInventorSignAction(
        List<DisclosureInventor__c> disclosureInventorList
    ) {
        // Lists to be used
        List<DisclosureInventor__c> inventorProcessList = new List<DisclosureInventor__c>();
        Map<Id, Disclosure__c> disclosureMap = DisclosureRecordFetch.getDisclosuresByInventors(
            disclosureInventorList
        );

        // Loop over Disclosure Inventors
        for (DisclosureInventor__c inventor : disclosureInventorList) {
            // If the inventor has not signed, but the Disclosure is "Approved" or "Inventor Submitted"...
            String status = disclosureMap.get(inventor.Disclosure__c).Status__c;

            if (
                inventor.Signed_Status__c != 'Yes' &&
                (status == 'Approved' ||
                status == 'Inventor Submitted')
            ) {
                // Add to list
                inventorProcessList.add(inventor);
            }
        }

        // Process lists
        if (!inventorProcessList.isEmpty()) {
            ContactActionHandler.initDisclosureContactAction(
                inventorProcessList,
                ContactActionHandler.recordTypeIdSignDisclosure
            );
        }
    }

    public static void validateDisclosureInventor(
        List<DisclosureInventor__c> disinventor
    ) {
        Set<String> contactIds = new Set<String>();
        Set<String> disclosureIds = new Set<String>();
        Set<String> inventorIds = new Set<String>();

        for (DisclosureInventor__c inventor : disinventor) {
            contactIds.add(inventor.Contact__c);
            disclosureIds.add(inventor.Disclosure__c);
            inventorIds.add(inventor.Id);
        }

        if (!contactIds.isEmpty() && !disclosureIds.isEmpty()) {
            List<DisclosureInventor__c> existingInventors = [
                SELECT Id, Contact__c, Disclosure__c
                FROM DisclosureInventor__c
                WHERE
                    Contact__c IN :contactIds
                    AND Disclosure__c IN :disclosureIds
                    AND Id NOT IN :(inventorIds)
            ];

            List<Department_Head__c> existingDepartmentHeads = [
                SELECT Id, Contact__c, Disclosure__c
                FROM Department_Head__c
                WHERE
                    Contact__c IN :contactIds
                    AND Disclosure__c IN :disclosureIds
                    AND Id NOT IN :(inventorIds)
            ];

            if (existingInventors != null && !existingInventors.isEmpty()) {
                for (DisclosureInventor__c inventor : disinventor) {
                    inventor.addError(
                        label.Disclosure_Error_Duplicate_Inventor
                    );
                }
            }

            if (
                existingDepartmentHeads != null &&
                !existingDepartmentHeads.isEmpty()
            ) {
                for (DisclosureInventor__c inventor : disinventor) {
                    inventor.addError(
                        label.Disclosure_Error_Unique_TLO_Contact
                    );
                }
            }
        }
    }

    private static void validateInventorEmail(
        List<DisclosureInventor__c> disInventors
    ) {
        // Only run email validations if...
        if (
            !PersonAccountMigrationHelpers.isPersonAccountMigrationInProgress() && // TODO: Refactor - Remove post AC migration
            UserInfo.getProfileId() != ShirleyConstants.COMMUNITY_PROFILE_ID && // the current user is not a community user (i.e. Native App user)
            UserInfo.getProfileId() != ShirleyConstants.INTEGRATION_PROFILE_ID // the current user is not an Integration user
        ) {
            // Get list of Contacts
            List<Id> contactIds = new List<Id>();

            for (DisclosureInventor__c disInventor : disInventors) {
                contactIds.add(disInventor.Contact__c);
            }

            List<Account> contacts = [
                SELECT Id, PersonEmail, MoiraStatus__pc, IsAlumni__pc
                FROM Account
                WHERE Id IN :contactIds AND IsPersonAccount = TRUE
            ];

            Map<Id, Account> contactsMap = new Map<Id, Account>(contacts);

            // For each inventor
            for (DisclosureInventor__c disInventor : disInventors) {
                // If matching contact is has an inactive kerb and is not Alumni, the email cannot end in mit.edu
                Account contact = contactsMap.get(disInventor.Contact__c);

                if (
                    (!Helpers.isActiveKerb(contact.MoiraStatus__pc) && // Inactive kerb
                    (contact.IsAlumni__pc != true)) && // Not Alumni
                    (contact.PersonEmail != null &&
                    contact.PersonEmail.endsWith('mit.edu'))
                ) {
                    disInventor.addError(Label.GuestEmailAddressValidation);
                }
            }
        }
    }

    public static void validationQuestion(
        List<DisclosureInventor__c> disinventor
    ) {
        for (DisclosureInventor__c disinv : disinventor) {
            if (
                disinv.WorkDoneOutsideMIT__c == 'Yes' &&
                disinv.WorkDoneOutsideMITDetails__c == null
            ) {
                disinv.addError(Label.MIT_WorkOutside);
            }

            if (
                disinv.Collaboration__c == 'Yes' &&
                disinv.CollaborationDetails__c == null
            ) {
                disinv.addError(Label.MIT_CollaborationDetails);
            }

            if (
                disinv.ConsultantOrContract__c == 'Yes' &&
                disinv.ConsultantOrContractDetails__c == null
            ) {
                disinv.addError(Label.MIT_ConsultantOrContractDetails);
            }

            if (
                disinv.PartOfClass__c == 'Yes' &&
                disinv.PartOfClassDetails__c == null
            ) {
                disinv.addError(Label.MIT_PartofClassDetails);
            }
        }
    }

    /**
     * Assign the IPIA Lookup to the Disclosure Inventor
     * @param disclosureInventors List of Disclosure Inventors
     * @return List of Disclosure Inventors with the IPIA Lookup assigned
     */
    @TestVisible
    private static List<DisclosureInventor__c> assignIPIALookup(List<DisclosureInventor__c> disclosureInventors) {
        // Since the Contact__r field is not populated in the trigger context, we need to query the Contacts
        List<Id> contactIds = new List<Id>();
        for (DisclosureInventor__c disinv : disclosureInventors) {
            contactIds.add(disinv.Contact__c);
        }

        Map<Id, Account> contacts = new Map<Id, Account>([SELECT Id, MitId__pc FROM Account WHERE Id IN :contactIds]);

        // Assign the Contact__r field with the populated MitId__pc field
        for (DisclosureInventor__c disinv : disclosureInventors) {
            if (contacts.containsKey(disinv.Contact__c)) {
                disinv.Contact__r = contacts.get(disinv.Contact__c);
            }
        }

        return DisclosureInventorService.linkDisclosureInventorToIPIARecords(disclosureInventors);
    }
}