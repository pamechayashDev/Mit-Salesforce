public with sharing class DisclosureValidation {
    public static final string INITIATOR_ERROR_MSG = 'A disclosure can only be deleted by the Initiator (ie: the person who submitted the disclosure)';
    public static final string DRAFT_ERROR_MSG = 'Only Draft disclosures can be deleted.';

    public static void onBeforeDelete(List<Disclosure__c> disclosures) {
        string uid = userinfo.getUserId();
        System.debug(uid);

        for (Disclosure__c disclosure : disclosures) {
            System.debug(disclosure.Submitting_Contact__c);

            if (
                disclosure.Status__c != null &&
                disclosure.Status__c != 'Draft'
            ) {
                System.debug(DRAFT_ERROR_MSG);
                disclosure.addError(DRAFT_ERROR_MSG);
                //! TODO: This will need to be replaced ASAP
                // }else if (disclosure.Submitting_Contact__c != null && disclosure.Submitting_Contact__c != uid) {
                //     System.debug(INITIATOR_ERROR_MSG);
                //     disclosure.addError(INITIATOR_ERROR_MSG);
            } else {
                System.debug('Successful');
                if (disclosure.Id != null) {
                    if (disclosure.Name__c != 'Test Disclosure Deletion') {
                        List<DisclosureInventor__c> inventorList = DisclosureRecordFetch.getDisclosureInventorByDisclosureId(
                            disclosure.Id
                        );
                        String emailList = '';
                        for (DisclosureInventor__c inventor : inventorList) {
                            if (
                                inventor.PrimaryInventor__c == false &&
                                inventor.Review_Draft_Watcher__c == false
                            ) {
                                continue;
                            }
                            Account contact = DisclosureRecordFetch.getContactById(
                                inventor.Contact__c
                            );
                            if (
                                contact != null &&
                                contact.PersonEmail != null
                            ) {
                                emailList += contact.PersonEmail + ',';
                            } else if (
                                contact != null &&
                                contact.AltEmail__pc != null
                            ) {
                                emailList += contact.AltEmail__pc + ',';
                            }
                        }
                        if (emailList != '') {
                            Map<String, String> variables = new Map<String, String>();
                            variables.put(
                                'disclosure_title',
                                disclosure.Name__c
                            );
                            variables.put('disclosure_name', disclosure.Name);
                            variables.put(
                                'submitter_name',
                                DisclosureRecordFetch.getContactById(
                                        disclosure.Submitting_Contact__c
                                    )
                                    .Name
                            );
                            Notification__c newNotification = NotificationBuilder.buildNotificationEmail(
                                emailList.removeEnd(','),
                                NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_DELETION,
                                variables
                            );

                            insert newNotification;
                        }
                    }
                }
            }
        }
    }

    public static Boolean statusEditableValidation(
        Disclosure__c oldDisclosure
    ) {
        // TODO if (oldDisclosure.Status__c == 'Approved' || oldDisclosure.Status__c == 'Rejected' || oldDisclosure.Status__c == 'Archived'  ) {
        // TODO refactor triggers because in this case:
        // TODO: Disclosure should never be editable by anyone unless its in a Draft status. Other than sys-admin being able to move from Archived to Draft.

        if (
            oldDisclosure.Status__c == 'Rejected' &&
            !PersonAccountMigrationHelpers.isPersonAccountMigrationInProgress() // TODO: Refactor - Remove post AC migration
        ) {
            oldDisclosure.addError(label.Disclosure_Error_Editable_State);
            return false;
        }
        return true;
    }

    public static void onDraftStatusChange(List<Disclosure__c> disclosures) {
        DisclosureValidation.DisclosureContext disclosureContext = DisclosureValidation.getDisclosureContext(
            disclosures
        );
        for (Disclosure__c disclosure : disclosures) {
            onDraftStatusChange(disclosure, disclosureContext);
        }

        onBehalfOfInventorValidation(disclosureContext.disclosureInventorMap);
    }
    private static void onDraftStatusChange(
        Disclosure__c disclosure,
        DisclosureValidation.DisclosureContext disclosureContext
    ) {
        if (disclosure.Status__c != null && disclosure.Status__c != 'Draft') {
            Id recordTypeIdCopyright = disclosureContext.recordTypeIdCopyright;
            Id recordTypeIdSoftware = disclosureContext.recordTypeIdSoftware;

            List<DisclosureInventor__c> inventors = onePrimaryInventorValidation(
                disclosure,
                disclosureContext.disclosureInventorMap.get(disclosure)
            );

            Boolean validateDepartmentHead = false;
            if (
                disclosure.RecordTypeId == recordTypeIdCopyright ||
                disclosure.RecordTypeId == recordTypeIdSoftware
            ) {
                List<Open_Source__c> openSources = disclosureContext.disclosureOpenSourceMap.get(
                    disclosure
                );
                if (
                    !openSources.isEmpty() &&
                    openSources[0].Open_Source_Licensing__c
                ) {
                    // The ERD Intention is a one to one Mapping
                    validateDepartmentHead = true;
                }
            }
            // DEPT HEAD VALIDATIONS
            if (validateDepartmentHead) {
                Department_Head__c departmentHead = oneDepartmentHeadValidation(
                    disclosure,
                    disclosureContext.disclosureDeptHeadMap.get(disclosure)
                );

                for (DisclosureInventor__c inventor : inventors) {
                    if (
                        departmentHead != null &&
                        inventor.Contact__c == departmentHead.Contact__c
                    ) {
                        disclosure.addError(
                            label.Disclosure_Error_Department_Head_Inventor
                        );
                    }
                }

                if (
                    departmentHead != null &&
                    !Helpers.isActiveKerb(
                        departmentHead.Contact__r.MoiraStatus__pc
                    )
                ) {
                    disclosure.addError(
                        label.Disclosure_Error_Department_Head_Non_Staff
                    );
                }
            }

            // PRIMARY INVENTOR VALIDATIONS
            for (DisclosureInventor__c inventor : inventors) {
                if (
                    !Helpers.isActiveKerb(
                        inventor.Contact__r.MoiraStatus__pc
                    ) && inventor.PrimaryInventor__c == true
                ) {
                    disclosure.addError(
                        label.Disclosure_Error_Primary_Inventor_Non_Staff
                    );
                }
            }
        }
    }

    public static List<DisclosureInventor__c> onePrimaryInventorValidation(
        Disclosure__c disclosure,
        List<DisclosureInventor__c> existingInventors
    ) {
        Boolean found = false;
        for (DisclosureInventor__c inventor : existingInventors) {
            if (inventor.PrimaryInventor__c == true) {
                found = true;
            }
        }
        if (!found) {
            if (!System.isBatch())
                disclosure.addError(
                    label.Disclosure_Error_Primary_Inventor_Count
                );
        }
        return existingInventors;
    }

    public static Department_Head__c oneDepartmentHeadValidation(
        Disclosure__c disclosure,
        List<Department_Head__c> existingDepartmentHead
    ) {
        if (existingDepartmentHead.size() == 1) {
            return existingDepartmentHead.get(0);
        } else {
            if (!System.isBatch()) {
                disclosure.addError(
                    label.Disclosure_Error_Department_Head_Count
                );
            }
            return null;
        }
    }

    public static void onBehalfOfInventorValidation(
        Map<Disclosure__c, List<DisclosureInventor__c>> disclosureInventorMap
    ) {
        for (Disclosure__c disclosure : disclosureInventorMap.keySet()) {
            List<DisclosureInventor__c> inventors = disclosureInventorMap.get(
                disclosure
            );
            Id submittingContactId = disclosure.Submitting_Contact__c;

            if (disclosure.SubmittedOnBehalf__c == true) {
                for (DisclosureInventor__c inv : inventors) {
                    if (inv.Contact__c == submittingContactId) {
                        //SOB cannot add themselves as an inventor either
                        disclosure.addError(
                            label.Disclosure_Error_Submitting_OnBehalfOf_Inventor
                        );
                    }
                }
            } else {
                Boolean foundInventor = false;
                for (DisclosureInventor__c inv : inventors) {
                    if (inv.Contact__c == submittingContactId) {
                        foundInventor = true;
                    }
                }
                if (!foundInventor) {
                    disclosure.addError(
                        label.Disclosure_Error_Submitting_Inventor
                    );
                }
            }
        }
    }

    public static boolean onBeforeApproveValidationByDisclosureId(
        Map<Id, Disclosure__c> lookup,
        List<Id> approvedDisclosureIds
    ) {
        // Check if any pending Contact Update Requests exist
        List<TLO_Contact_Update_Request__c> tloContactReqList = [
            SELECT Id, Update_Status__c, Disclosure__c, Contact__r.Name
            FROM TLO_Contact_Update_Request__c
            WHERE
                Disclosure__r.Id IN :approvedDisclosureIds
                AND Update_Status__c = 'Pending'
        ];
        for (TLO_Contact_Update_Request__c cur : tloContactReqList) {
            // Pending Contact Update Request exists, add error
            if (lookup != null) {
                Disclosure__c disclosure = lookup.get(cur.Disclosure__c);
                disclosure.addError(
                    label.PendingContactUpdateReq +
                    ' ' +
                    cur.Contact__r.Name
                );
            } else {
                throw new AuraHandledException(
                    label.PendingContactUpdateReq +
                    ' ' +
                    cur.Contact__r.Name
                );
            }
        }

        // Check if any Disclosure Inventors (Contacts) are missing PersonEmail values
        List<DisclosureInventor__c> inventors = [
            SELECT Id, Contact__r.Name, Disclosure__c
            FROM DisclosureInventor__c
            WHERE
                Disclosure__r.Id IN :approvedDisclosureIds
                AND Contact__r.PersonEmail = NULL
        ];
        for (DisclosureInventor__c inventor : inventors) {
            // Contact does not have an PersonEmail value, throw an error
            if (lookup != null) {
                Disclosure__c disclosure = lookup.get(inventor.Disclosure__c);
                disclosure.addError(
                    label.ChangedContactUpdateReqStatusValidation +
                    ': ' +
                    inventor.Contact__r.Name
                );
            } else {
                throw new AuraHandledexception(
                    label.ChangedContactUpdateReqStatusValidation +
                    ': ' +
                    inventor.Contact__r.Name
                );
            }
        }

        return true;
    }

    @TestVisible
    private static DisclosureContext getDisclosureContext(
        List<Disclosure__c> disclosures
    ) {
        Id recordTypeIdCopyright = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Map<Disclosure__c, List<DisclosureInventor__c>> disclosureInventorMap = new Map<Disclosure__c, List<DisclosureInventor__c>>();
        Map<Disclosure__c, List<Department_Head__c>> disclosureDeptHeadMap = new Map<Disclosure__c, List<Department_Head__c>>();
        Map<Disclosure__c, List<Open_Source__c>> disclosureOpenSourceMap = new Map<Disclosure__c, List<Open_Source__c>>();

        Set<String> disclosureIds = new Set<String>();
        Map<String, Disclosure__c> disclosureMap = new Map<String, Disclosure__c>();

        Boolean queryCopyrightType = false;
        Boolean querySoftwareType = false;

        for (Disclosure__c disclosure : disclosures) {
            disclosureIds.add(disclosure.Id);
            disclosureMap.put(disclosure.Id, disclosure);
            disclosureInventorMap.put(
                disclosure,
                new List<DisclosureInventor__c>()
            );
            disclosureDeptHeadMap.put(
                disclosure,
                new List<Department_Head__c>()
            );
            disclosureOpenSourceMap.put(disclosure, new List<Open_Source__c>());
            if (disclosure.RecordTypeId == recordTypeIdCopyright) {
                queryCopyrightType = true;
            }
            if (disclosure.RecordTypeId == recordTypeIdSoftware) {
                querySoftwareType = true;
            }
        }

        // Inventors
        List<DisclosureInventor__c> inventors = [
            SELECT
                Id,
                PrimaryInventor__c,
                Contact__c,
                Contact__r.MoiraStatus__pc,
                Disclosure__c
            FROM DisclosureInventor__c
            WHERE Disclosure__c IN :disclosureIds
        ];

        for (DisclosureInventor__c inventor : inventors) {
            Disclosure__c contactDisclosure = disclosureMap.get(
                inventor.Disclosure__c
            );
            if (contactDisclosure == null) {
                throw new AuraHandledException('Existing Disclosure not found');
            }
            disclosureInventorMap.get(contactDisclosure).add(inventor);
        }

        // Department head
        List<Department_Head__c> existingDepartmentHeads = [
            SELECT
                Id,
                Contact__c,
                Contact__r.MoiraStatus__pc,
                Delegated_To__r.Contact__r.Id,
                Disclosure__c
            FROM Department_Head__c
            WHERE Disclosure__c IN :disclosureIds AND Delegated_To__c = NULL
        ];
        for (Department_Head__c deptHead : existingDepartmentHeads) {
            Disclosure__c contactDisclosure = disclosureMap.get(
                deptHead.Disclosure__c
            );
            if (contactDisclosure == null) {
                throw new AuraHandledException('Existing Disclosure not found');
            }
            disclosureDeptHeadMap.get(contactDisclosure).add(deptHead);
        }

        // Open_Source__c Software
        if (querySoftwareType) {
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
                Disclosure__c contactDisclosure = disclosureMap.get(
                    sc.Disclosure__c
                );
                if (contactDisclosure == null) {
                    throw new AuraHandledException(
                        'Existing Disclosure not found'
                    );
                }
                for (Open_Source__c opensource : sc.Open_Sources__r) {
                    disclosureOpenSourceMap.get(contactDisclosure)
                        .add(opensource);
                }
            }
        }

        // Open_Source__c Copyright_Disclosure__c
        if (queryCopyrightType) {
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
                Disclosure__c contactDisclosure = disclosureMap.get(
                    cr.Disclosure__c
                );
                if (contactDisclosure == null) {
                    throw new AuraHandledException(
                        'Existing Disclosure not found'
                    );
                }
                for (Open_Source__c opensource : cr.Open_Sources__r) {
                    disclosureOpenSourceMap.get(contactDisclosure)
                        .add(opensource);
                }
            }
        }

        DisclosureContext context = new DisclosureContext();
        context.disclosures = disclosures;
        context.disclosureInventorMap = disclosureInventorMap;
        context.disclosureDeptHeadMap = disclosureDeptHeadMap;
        context.disclosureOpenSourceMap = disclosureOpenSourceMap;
        context.recordTypeIdCopyright = recordTypeIdCopyright;
        context.recordTypeIdSoftware = recordTypeIdSoftware;

        return context;
    }

    @TestVisible
    private class DisclosureContext {
        @TestVisible
        private Id recordTypeIdCopyright;
        @TestVisible
        private Id recordTypeIdSoftware;

        @TestVisible
        private List<Disclosure__c> disclosures;
        @TestVisible
        private Map<Disclosure__c, List<DisclosureInventor__c>> disclosureInventorMap;
        @TestVisible
        private Map<Disclosure__c, List<Department_Head__c>> disclosureDeptHeadMap;
        @TestVisible
        private Map<Disclosure__c, List<Open_Source__c>> disclosureOpenSourceMap;
    }
}