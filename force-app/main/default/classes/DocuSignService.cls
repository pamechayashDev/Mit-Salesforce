//** TODO Important: We recommend against including documents because they make the POST messages to your listener very large.
/* Consider using the eSignature API to retrieve envelope documents when needed instead.
 Also note that you might not receive the documents if authentication is enabled on the envelope. Learn more. */

// https://developers.docusign.com/docs/esign-rest-api/esign101/concepts/embedding/
// https://stackoverflow.com/questions/61934459/docusign-can-you-hide-recipient-signatures-from-other-parties
// https://developers.docusign.com/docs/esign-rest-api/esign101/concepts/tabs/auto-place/
// https://docusigncommunity.force.com/s/document-item?language=en_US&bundleId=vbw1648698462634&topicId=rvg1644270913133.html&_LANG=enus

// https://www.docusign.com/blog/developers/common-api-tasks-adding-recipient-to-flight-envelope
// A complete envelope is done, finished, and cannot be modified. So we have to ensure our envelope is not complete.
public with sharing class DocuSignService {
    private static final String DISCLOSURE_DOCUMENT_ID = '1';
    private static final String SUMMARY_DOC_INFO_DOCUMENT_ID = '2';

    private String accountId = '';
    private String docuSignTemplateId = '';

    private Map<string, string> headers = new Map<String, String>();
    Map<string, string> lockHeaders = new Map<String, String>();
    DocuSignEnvelopeApi docuSignApi = new DocuSignEnvelopeApi();

    public DocuSignService() {
        headers.put('Content-Type', 'application/json;charset=UTF-8');
        lockHeaders = headers;

        DocuSign_Settings__c docuSignSettings = DocuSign_Settings__c.getInstance();
        System.debug(
            'docuSignSettings.DocuSign_Account_Id__c: ' +
            docuSignSettings.DocuSign_Account_Id__c
        );
        System.debug(
            'docuSignSettings.DocuSign_Disclosure_Signing_TemplateId__c: ' +
            docuSignSettings.DocuSign_Disclosure_Signing_TemplateId__c
        );

        accountId = docuSignSettings.DocuSign_Account_Id__c;
        docuSignTemplateId = docuSignSettings.DocuSign_Disclosure_Signing_TemplateId__c;
    }

    public String createEnvelopeForDisclosure(
        String disclosureIdStr,
        Blob disclosureFinalDocCvBlob,
        DisclosureWrapper disclosureWrapper
    ) {
        //a. Create Envelope in Draft Stage (This will create the envelope and assign an Envelope ID but won’t actually send it)
        EnvelopeDefinition envelope = this.buildEnvelopeDefinition(
            disclosureFinalDocCvBlob,
            disclosureWrapper
        );

        System.debug('envelope:- ' + JSON.serialize(envelope, true));
        String createEnvRes = DocuSignApiCall.restPost(
            'accounts/' +
            accountId +
            '/envelopes',
            headers,
            JSON.serialize(envelope, true)
        ); //TODO failed DocuSign did not fail job here?
        System.debug('createEnvRes: ' + createEnvRes);

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
            createEnvRes
        );
        String envelopeId = String.valueOf(response.get('envelopeId'));
        System.debug('envelopeId: ' + envelopeId);

        return envelopeId;
    }

    public void updateEnvelopeForDisclosure(
        String envelopeId,
        Blob disclosureFinalDocCvBlob,
        DisclosureWrapper disclosureWrapper
    ) {
        EnvelopeDefinition envelope = this.buildEnvelopeDefinition(
            disclosureFinalDocCvBlob,
            disclosureWrapper
        );

        // LOCK DocuSign envelope
        Lock lockRequest = new Lock();
        lockRequest.lockDurationInSeconds = '60';
        lockRequest.lockedByApp = 'TLO';
        lockRequest.lockType = 'edit';
        String lockResponse = DocuSignApiCall.restPost(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/lock',
            headers,
            JSON.serialize(lockRequest, true)
        );
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
            lockResponse
        );
        String lockToken = String.valueOf(response.get('lockToken'));

        UnLock unlock = new UnLock();
        unlock.lockDurationInSeconds = '600';
        unlock.lockToken = lockToken;
        lockHeaders.put('X-DocuSign-Edit', JSON.serialize(unlock, true));

        System.debug('envelope:- ' + JSON.serialize(envelope, true));
        String updateEnvRes = DocuSignApiCall.restPut(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/documents',
            lockHeaders,
            JSON.serialize(envelope, true)
        ); //TODO failed DocuSign did not fail job here?
        System.debug('updateEnvRes: ' + updateEnvRes);

        // un-LOCK DocuSign envelope
        String unlockResponse = DocuSignApiCall.restDelete(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/lock',
            lockHeaders
        );
        System.debug('unlockResponse: ' + unlockResponse);
    }

    @TestVisible
    private EnvelopeDefinition buildEnvelopeDefinition(
        Blob disclosureFinalDocCvBlob,
        DisclosureWrapper disclosureWrapper
    ) {
        String emailSubject = 'DocuSign_' + disclosureWrapper.disclosure.Name;

        EnvelopeDefinition envelope = new EnvelopeDefinition();
        envelope.emailSubject = emailSubject;
        envelope.status = 'sent';
        envelope.enforceSignerVisibility = true;
        Notification notification = new Notification();
        notification.useAccountDefaults = true;
        envelope.notification = notification;
        //Add Salesforce Source Record to the mix, otherwise dynamic Custom Fields will not work:
        CustomTextField customTextField = new CustomTextField();
        customTextField.fieldId = '1';
        customTextField.name = 'DSFSSourceObjectId';
        customTextField.show = 'false';
        customTextField.value = disclosureWrapper.disclosure.Id;

        CustomTextFields customFields = new CustomTextFields();
        customFields.textCustomFields = new List<CustomTextField>{
            customTextField
        };
        envelope.customFields = customFields;

        Document document = new Document();
        document.documentId = DISCLOSURE_DOCUMENT_ID;
        document.display = 'inline';
        document.name = emailSubject + '.pdf';
        document.documentBase64 = EncodingUtil.base64Encode(
            disclosureFinalDocCvBlob
        );

        List<Document> documents = new List<Document>();
        documents.add(document);
        envelope.documents = documents;

        List<Recipient> signers = new List<Recipient>();
        // TLOS-3429 removing adding of inventors as Recipient(s) to the DocuSign envelop as some don't have mitId's yet
        // we have another change which will add Recipient(s) when they come to sign disclosure which should account for this

        signers.add(createDummyRecipient());

        envelope.recipients = new Recipients();
        envelope.recipients.signers = signers;
        System.debug('signers: ' + JSON.serialize(signers, true));

        return envelope;
    }

    // We need to have a dummy Inventor that will never sign inorder to keep the Envelope in a open state, to be able to add Inventors at any stage
    private Recipient createDummyRecipient() {
        String dummyInventorId = 'a0D52000005nm3XEAQx';
        Integer recipientId = 50;
        Recipient r = new Recipient();
        r.clientUserId = dummyInventorId;
        r.customFields = new List<String>{ String.valueOf(dummyInventorId) };
        r.email = 'dummy@test.com';
        r.recipientId = String.valueOf(recipientId);
        r.routingOrder = '1';
        r.name = 'Dummy Inventor';

        // have to add tabs for Dummy Inventor even tho they will never sign. As DocuSign Document Visability does not allow for Freeform signing
        // not added tabs for a Recipient essentially attempts to allow them to have Freeform Signing.
        DisclosureInventor__c inventor = null;
        Tabs tabs = this.createTabsForInventor(recipientId, inventor);
        r.tabs = tabs;
        return r;
    }

    // NOTE this can only be done if (unsignedInventorCnt < inventorCount) .:. we've added a dummy Recipient to DocuSign envelope
    private RecipientsResponse addRecipientToDisclosureEnvelope(
        String envelopeId,
        String disclosureIdStr,
        DisclosureInventor__c inventor,
        Integer mitIdAsRecipientId
    ) {
        List<Recipient> signers = new List<Recipient>();

        Recipient r = new Recipient();
        r.clientUserId = inventor.Id;
        r.customFields = new List<String>{ String.valueOf(inventor.Id) };
        r.email = inventor.Contact__r.PersonEmail;
        r.recipientId = String.valueOf(mitIdAsRecipientId);
        r.routingOrder = '1';
        r.name = ContactNameUtil.toFullName(
            inventor.Contact__r.FirstName,
            inventor.Contact__r.MiddleName,
            inventor.Contact__r.LastName,
            true
        );

        Recipients recipients = new Recipients();
        recipients.signers = new List<Recipient>{ r };
        String recipientsStr = DocuSignApiCall.restPost(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/recipients',
            headers,
            JSON.serialize(recipients, true)
        );
        System.debug(
            'add to existing envelope recipientsStr: ' +
            JSON.serialize(recipientsStr, true)
        );
        System.debug(
            'JSON.deserialize(recipientsStr, RecipientsResponse.class): ' +
            JSON.deserialize(recipientsStr, RecipientsResponse.class)
        );

        RecipientsResponse recipientsResponse = (RecipientsResponse) JSON.deserialize(
            recipientsStr,
            RecipientsResponse.class
        );
        System.debug('recipients: ' + recipientsResponse);
        System.debug('recipients.signers: ' + recipientsResponse.signers);
        return recipientsResponse;
    }

    public class NoEnvelopIdException extends Exception {
    }
    public String generateEmbeddedSigningUrl(
        String disclosureIdStr,
        String returnUrl,
        String inventorId
    ) {
        System.debug('#disclosureIdStr: ' + disclosureIdStr);
        System.debug('#returnUrl: ' + returnUrl);
        System.debug('#inventorId: ' + inventorId);

        String embeddedSigningUrlResponse = '';

        try {
            Disclosure__c disclosure = [
                SELECT
                    Id,
                    Name,
                    Signing_Envelop_Id__c,
                    Last_Modified_at_time_of_Signing_Request__c,
                    LastModifiedDate
                FROM Disclosure__c
                WHERE Id = :disclosureIdStr
            ];

            Boolean disclosureHasEnvelopeId =
                disclosure.Signing_Envelop_Id__c != null;
            System.debug(
                '#disclosureHasEnvelopeId: ' + disclosureHasEnvelopeId
            );

            if (!disclosureHasEnvelopeId) {
                throw new NoEnvelopIdException(
                    'Disclosure has no EnvelopId set'
                );
            }

            Id disId = Id.valueOf(disclosureIdStr);
            Id invId = Id.valueOf(inventorId);
            DisclosureInventorWrapper disInvWrapper = DisclosureDao.getInventorById(
                disId,
                invId
            );
            DisclosureInventor__c disinv = disInvWrapper.inventor;

            //get recipientId for the inventorId from DocuSign envenlop
            System.debug(
                'disclosure.Signing_Envelop_Id__c:- ' +
                disclosure.Signing_Envelop_Id__c
            );
            System.debug('inventorId:- ' + inventorId);

            String recipientId = disinv.Contact__r.MitId__pc;
            System.debug('recipientId:- ' + recipientId);

            String inventorsDocBase64Pdf = this.generateInventorsDoc(
                recipientId,
                disInvWrapper
            );

            // Note: When adding or modifying documents for an in-process envelope, DocuSign recommends locking the envelope prior to making any changes.
            // LOCK DocuSign envelope
            Lock lockRequest = new Lock();
            lockRequest.lockDurationInSeconds = '60';
            lockRequest.lockedByApp = 'TLO';
            lockRequest.lockType = 'edit';
            String lockResponse = DocuSignApiCall.restPost(
                'accounts/' +
                accountId +
                '/envelopes/' +
                disclosure.Signing_Envelop_Id__c +
                '/lock',
                headers,
                JSON.serialize(lockRequest, true)
            );
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
                lockResponse
            );
            String lockToken = String.valueOf(response.get('lockToken'));

            UnLock unlock = new UnLock();
            unlock.lockDurationInSeconds = '600';
            unlock.lockToken = lockToken;
            lockHeaders.put('X-DocuSign-Edit', JSON.serialize(unlock, true));

            //add additional document to the DocuSign envelope for Inventor with their answers & account info.
            this.addInventorDocToEnvelope(
                disclosure.Signing_Envelop_Id__c,
                recipientId,
                inventorsDocBase64Pdf
            );

            // Only add recipient & signing tabs (for signing places on the document) if not already added to the DocuSign envelope
            // [can only be done after doc is added]
            // if added more than once - document ends up with duplicate signing blocks 2 signer
            if (!disinv.Inventor_Added_to_DocuSign_Envelope__c) {
                RecipientsResponse recipients = this.addRecipientToDisclosureEnvelope(
                    disclosure.Signing_Envelop_Id__c,
                    disclosureIdStr,
                    disinv,
                    Integer.valueOf(recipientId)
                );

                this.createRecipientTabForInventor(
                    disclosure.Signing_Envelop_Id__c,
                    recipientId,
                    disinv
                );
            }

            // un-LOCK DocuSign envelope
            String unlockResponse = DocuSignApiCall.restDelete(
                'accounts/' +
                accountId +
                '/envelopes/' +
                disclosure.Signing_Envelop_Id__c +
                '/lock',
                lockHeaders
            );
            System.debug('unlockResponse: ' + unlockResponse);

            // generate signing url for the recipient
            // NOTE: Recipient information must match embedded recipient info we used to create the envelope, for which we need the userId that is only
            // possible to get by calling the recipients endpoint again :-(
            RecipientResponse recipient = this.getRecipientForInventorId(
                disclosure.Signing_Envelop_Id__c,
                invId
            );
            String inventorSigningUrlResponse = this.createInventorSigningUrl(
                disclosure.Signing_Envelop_Id__c,
                returnUrl,
                disinv,
                recipient
            );
            System.debug(
                'inventorSigningUrlResponse: ' + inventorSigningUrlResponse
            );

            embeddedSigningUrlResponse = inventorSigningUrlResponse;
            System.debug(
                'embeddedSigningUrlResponse: ' + embeddedSigningUrlResponse
            );

            System.debug('disinv update start');
            disinv.Inventor_Added_to_DocuSign_Envelope__c = true;
            update disinv;
            System.debug('disinv update end');
        } catch (Exception e) {
            //Set boolean to true to catch exception being thrown
            System.debug(
                LoggingLevel.ERROR,
                'e.getMessage():- ' + e.getMessage()
            );
            throw e;
        }

        return embeddedSigningUrlResponse;
    }

    public void addSummaryInfoDocument(String disclosureIdStr) {
        System.debug('#disclosureIdStr: ' + disclosureIdStr);
        String documentId = SUMMARY_DOC_INFO_DOCUMENT_ID;

        try {
            Disclosure__c disclosure = [
                SELECT
                    Id,
                    Name,
                    Signing_Envelop_Id__c,
                    Last_Modified_at_time_of_Signing_Request__c,
                    LastModifiedDate
                FROM Disclosure__c
                WHERE Id = :disclosureIdStr
            ];

            List<DisclosureInventor__c> disclosureInventors = [
                SELECT
                    Id,
                    Inventor_Added_to_DocuSign_Envelope__c,
                    Contact__r.MitId__pc
                FROM DisclosureInventor__c
                WHERE
                    Disclosure__c = :disclosureIdStr
                    AND Inventor_Added_to_DocuSign_Envelope__c = TRUE
            ];

            Boolean disclosureHasEnvelopeId =
                disclosure.Signing_Envelop_Id__c != null;
            System.debug(
                '#disclosureHasEnvelopeId: ' + disclosureHasEnvelopeId
            );

            if (!disclosureHasEnvelopeId) {
                throw new NoEnvelopIdException(
                    'Disclosure has no EnvelopId set'
                );
            }

            Id disId = Id.valueOf(disclosureIdStr);

            DisclosureSummaryWrapper disWrapper = DisclosureDao.getDisclosureSummaryWrapperById(
                disId
            );

            System.debug(
                'disclosure.Signing_Envelop_Id__c:- ' +
                disclosure.Signing_Envelop_Id__c
            );

            String summaryDocBase64Pdf = this.generateSummaryInfoDocument(
                disWrapper
            );

            // Note: When adding or modifying documents for an in-process envelope, DocuSign recommends locking the envelope prior to making any changes.
            // LOCK DocuSign envelope
            Lock lockRequest = new Lock();
            lockRequest.lockDurationInSeconds = '60';
            lockRequest.lockedByApp = 'TLO';
            lockRequest.lockType = 'edit';
            String lockResponse = DocuSignApiCall.restPost(
                'accounts/' +
                accountId +
                '/envelopes/' +
                disclosure.Signing_Envelop_Id__c +
                '/lock',
                headers,
                JSON.serialize(lockRequest, true)
            );
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
                lockResponse
            );
            String lockToken = String.valueOf(response.get('lockToken'));

            UnLock unlock = new UnLock();
            unlock.lockDurationInSeconds = '600';
            unlock.lockToken = lockToken;
            lockHeaders.put('X-DocuSign-Edit', JSON.serialize(unlock, true));

            //add additional Summary document cover page info to the DocuSign envelope
            this.addSummaryDocToEnvelope(
                disclosure.Signing_Envelop_Id__c,
                documentId,
                summaryDocBase64Pdf
            );
            this.reorderDocumentsEnvelope(
                disclosureInventors,
                disclosure.Signing_Envelop_Id__c
            );

            // un-LOCK DocuSign envelope
            String unlockResponse = DocuSignApiCall.restDelete(
                'accounts/' +
                accountId +
                '/envelopes/' +
                disclosure.Signing_Envelop_Id__c +
                '/lock',
                lockHeaders
            );
            System.debug('unlockResponse: ' + unlockResponse);
        } catch (Exception e) {
            //Set boolean to true to catch exception being thrown
            System.debug(
                LoggingLevel.ERROR,
                'e.getMessage():- ' + e.getMessage()
            );
            throw e;
        }
    }

    public String getInventorSignedStatus(
        String disclosureIdStr,
        String inventorId
    ) {
        Disclosure__c disclosure = [
            SELECT Id, Signing_Envelop_Id__c
            FROM Disclosure__c
            WHERE Id = :disclosureIdStr
        ];

        String envelopeId = disclosure.Signing_Envelop_Id__c;
        try {
            RecipientResponse recipient = this.getRecipientForInventorId(
                envelopeId,
                inventorId
            );
            System.debug('DocuSignService recipient:- ' + recipient);

            return recipient.status;
        } catch (DocuSignIntegrationException ex) {
            // The recipient does not exist, Recipients only gets added when they request signing DocumentGenerateEmbeddedSigningAPI
            return 'Unknown';
        }
    }

    public Boolean hasAnInventorSigned(String envelopeId) {
        DocuSignService docuSignService = new DocuSignService();
        DocuSignService.RecipientsResponse recipientsResponse = docuSignService.getRecipientsForEnvelopeId(
            envelopeId
        );
        DocuSignService.RecipientResponse[] signers = recipientsResponse.signers;

        Boolean hasAnInventorSigned = false;
        for (DocuSignService.RecipientResponse recipient : signers) {
            if (recipient.Status == 'Completed') {
                hasAnInventorSigned = true;
                break;
            }
        }

        return hasAnInventorSigned;
    }

    public Blob getDocumentForInventor(
        String disclosureIdStr,
        String inventorId
    ) {
        DisclosureInventor__c disclosureInventor = [
            SELECT
                Id,
                Disclosure__r.Id,
                Disclosure__r.Signing_Envelop_Id__c,
                Inventor_Added_to_DocuSign_Envelope__c,
                Contact__r.MitId__pc
            FROM DisclosureInventor__c
            WHERE Disclosure__r.Id = :disclosureIdStr AND Id = :inventorId
        ];

        String envelopeId = disclosureInventor.Disclosure__r.Signing_Envelop_Id__c;
        String recipientId = disclosureInventor.Contact__r.MitId__pc;

        return this.docuSignApi.getDocumentByRecipientId(
            envelopeId,
            recipientId
        );
    }

    public Blob getDisclosureDocument(String disclosureIdStr) {
        Disclosure__c disclosure = [
            SELECT Id, Signing_Envelop_Id__c
            FROM Disclosure__c
            WHERE Id = :disclosureIdStr
        ];

        String envelopeId = disclosure.Signing_Envelop_Id__c;

        return this.docuSignApi.getDocumentByEnvelopeId(envelopeId);
    }

    private String generateInventorsDoc(
        String recipientId,
        DisclosureInventorWrapper disclosureInventorWrapper
    ) {
        disclosureInventorWrapper.disclosureConditions.recipientId = recipientId;
        Boolean includeCoverPage = false;
        String base64Pdf = DocumentGenerationService.generate(
            'Inventor',
            disclosureInventorWrapper,
            includeCoverPage
        );
        return base64Pdf;
    }

    private String generateSummaryInfoDocument(
        DisclosureSummaryWrapper disclosureWrapper
    ) {
        Boolean includeCoverPage = false;
        String base64Pdf = DocumentGenerationService.generate(
            DocumentGenerationService.coverPage(),
            disclosureWrapper,
            includeCoverPage
        );
        return base64Pdf;
    }

    /**
     * Create embedded signing URL using - Matching userId and clientUserId
     * NOT: Matching email, user name, and clientUserId
     *   as the recipients (users, could have changed these details eg: Someone getting Married surname changes, or even they change their email address)
     * Some more details at:     //https://www.docusign.com/blog/developers/deep-dive-the-embedded-signing-recipient-view
     * */
    private String createInventorSigningUrl(
        String envelopeId,
        String returnUrl,
        DisclosureInventor__c disinv,
        RecipientResponse recipient
    ) {
        RecipientView recipientView = new RecipientView();
        recipientView.returnUrl = returnUrl;
        recipientView.authenticationMethod = 'none';
        recipientView.userId = recipient.userId;
        recipientView.clientUserId = disinv.Id;
        recipientView.recipientId = recipient.recipientId;

        System.debug('tabs: ' + JSON.serialize(recipientView, true));
        String embeddedSigningUrlResponse = DocuSignApiCall.restPost(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/views/recipient',
            headers,
            JSON.serialize(recipientView, true)
        );
        System.debug(
            'embeddedSigningUrlResponse: ' + embeddedSigningUrlResponse
        );

        return embeddedSigningUrlResponse;
    }

    private void createRecipientTabForInventor(
        String envelopeId,
        String recipientId,
        DisclosureInventor__c inventor
    ) {
        Tabs tabs = this.createTabsForInventor(
            Integer.valueOf(recipientId),
            inventor
        );

        String respons = DocuSignApiCall.restPost(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/recipients/' +
            recipientId +
            '/tabs',
            lockHeaders,
            JSON.serialize(tabs, true)
        );
        System.debug('createSignerRes: ' + respons);
    }

    private Tabs createTabsForInventor(
        Integer i,
        DisclosureInventor__c disclosureInventor
    ) {
        Tabs tabs = new Tabs();
        tabs.signHereTabs = new List<Tab>();
        tabs.initialHereTabs = new List<Tab>();
        tabs.dateSignedTabs = new List<Tab>();
        tabs.textTabs = new List<Tab>();

        Tab signHereTab = new Tab();
        signHereTab.anchorString = '**signature_' + i + '**';
        signHereTab.anchorYOffset = '-5';
        tabs.signHereTabs.add(signHereTab);

        Tab initialTab = new Tab();
        initialTab.anchorString = '**signature_' + i + '_initials**';
        tabs.initialHereTabs.add(initialTab);

        Tab dateSignedTab = new Tab();
        dateSignedTab.anchorString = '**signature_' + i + '_dateSigned**';
        dateSignedTab.bold = 'true';
        tabs.dateSignedTabs.add(dateSignedTab);

        Tab hiddenTextTab = new Tab();
        hiddenTextTab.anchorString = '**DocuSign_hidden**';
        hiddenTextTab.value = '.';
        hiddenTextTab.fontColor = 'White';
        hiddenTextTab.fontSize = 'Size7';
        tabs.textTabs.add(hiddenTextTab);

        System.debug('tabs: ' + JSON.serialize(tabs, true));

        return tabs;
    }

    private void addDisclosureIdCustomFieldsToEnv(
        String envelopeId,
        String disclosureIdStr
    ) {
        //Add Salesforce Source Record to the mix, otherwise dynamic Custom Fields will not work:
        CustomTextField customTextField = new CustomTextField();
        customTextField.fieldId = '1';
        customTextField.name = 'DSFSSourceObjectId';
        customTextField.show = 'false';
        customTextField.value = disclosureIdStr;

        List<CustomTextField> customFields = new List<CustomTextField>();
        customFields.add(customTextField);

        CustomTextFields customTextFields = new CustomTextFields();
        customTextFields.textCustomFields = customFields;
        String sfCustomDataFieldRes = DocuSignApiCall.restPost(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/custom_fields',
            headers,
            JSON.serialize(customTextFields, true)
        );
        System.debug('sfCustomDataFieldRes: ' + sfCustomDataFieldRes);
    }

    public RecipientsResponse getRecipientsForEnvelopeId(String envelopeId) {
        String recipientsStr = DocuSignApiCall.restGet(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/recipients',
            headers
        );
        System.debug('recipientsStr: ' + JSON.serialize(recipientsStr, true));
        System.debug(
            'JSON.deserialize(recipientsStr, Recipients.class): ' +
            JSON.deserialize(recipientsStr, Recipients.class)
        );

        RecipientsResponse recipients = (RecipientsResponse) JSON.deserialize(
            recipientsStr,
            RecipientsResponse.class
        );
        System.debug('recipients: ' + recipients);
        System.debug('recipients.signers: ' + recipients.signers);

        return recipients;
    }

    public class DocuSignIntegrationException extends Exception {
    }
    @TestVisible
    private RecipientResponse getRecipientForInventorId(
        String envelopeId,
        String inventorId
    ) {
        String recipientsStr = DocuSignApiCall.restGet(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/recipients',
            headers
        );
        System.debug('recipientsStr: ' + JSON.serialize(recipientsStr, true));
        System.debug(
            'JSON.deserialize(recipientsStr, Recipients.class): ' +
            JSON.deserialize(recipientsStr, Recipients.class)
        );

        RecipientsResponse recipients = (RecipientsResponse) JSON.deserialize(
            recipientsStr,
            RecipientsResponse.class
        );
        System.debug('recipients: ' + recipients);
        System.debug('recipients.signers: ' + recipients.signers);

        for (RecipientResponse recipient : recipients.signers) {
            if (recipient.clientUserId == inventorId) {
                System.debug('recipient: ' + recipient);
                return recipient;
            }
        }
        throw new DocuSignIntegrationException(
            'DocuSign recipient.clientUserId not found on Envelope. '
        );
    }

    // TLOS-3800 Backward compatible with DocumentIds already created
    private String generateDocumentId(String recipientId) {
        return String.valueOf(Integer.valueOf(recipientId) + 1);
    }

    // Adds one or more documents to an existing envelope. The tabs of the original document will be applied to the new document.
    private void addInventorDocToEnvelope(
        String envelopeId,
        String recipientId,
        String base64Pdf
    ) {
        String inventorDocName = 'InventorDoc_' + recipientId + '.pdf';
        String documentId = generateDocumentId(recipientId);
        addDocToEnvelope(inventorDocName, envelopeId, documentId, base64Pdf);
    }

    // Adds one or more documents to an existing envelope. The tabs of the original document will be applied to the new document.
    private void addSummaryDocToEnvelope(
        String envelopeId,
        String documentId,
        String base64Pdf
    ) {
        String inventorDocName = 'SummaryInfoDoc' + documentId + '.pdf';
        addDocToEnvelope(inventorDocName, envelopeId, documentId, base64Pdf);
    }

    // Adds one or more documents to an existing envelope. The tabs of the original document will be applied to the new document.
    private void addDocToEnvelope(
        String inventorDocName,
        String envelopeId,
        String documentId,
        String base64Pdf
    ) {
        //b. Add/Update the additional document(s) 2 Envelope
        Documents docs = new Documents();

        Document document = new Document();
        document.documentId = documentId;
        document.display = 'inline';
        document.name = inventorDocName;
        document.documentBase64 = base64Pdf;

        List<Document> documents = new List<Document>();
        documents.add(document);
        docs.documents = documents;
        String addDocRes = DocuSignApiCall.restPut(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/documents',
            lockHeaders,
            JSON.serialize(docs, true)
        );
        System.debug('addDocRes: ' + addDocRes);
    }

    // Reorder the document. It works even though it throws an error. It could be logged as an issue from DocuSign and come up in reports.
    // There is already a document that was signed.
    // Details": {
    //     "errorCode": "DOCUMENT_UPDATE_NOT_ALLOWED",
    //     "message": "Signer recipient statuses must be one of AutoResponded, Created, Delivered, Sent."
    private void reorderDocumentsEnvelope(
        List<DisclosureInventor__c> disclosureInventors,
        String envelopeId
    ) {
        Integer order = 0;
        Documents docs = new Documents();
        List<Document> documents = new List<Document>();

        // Summary Document Info need to be first
        Document summaryDocument = new Document();
        summaryDocument.documentId = SUMMARY_DOC_INFO_DOCUMENT_ID;
        summaryDocument.order = String.valueOf(++order);
        documents.add(summaryDocument);

        Document discDocument = new Document();
        discDocument.documentId = DISCLOSURE_DOCUMENT_ID;
        discDocument.order = String.valueOf(++order);
        documents.add(discDocument);

        if (disclosureInventors != null) {
            for (DisclosureInventor__c disInv : disclosureInventors) {
                String recipientId = disInv.Contact__r.MitId__pc;
                Document recipientDocument = new Document();
                recipientDocument.documentId = generateDocumentId(recipientId);
                recipientDocument.order = String.valueOf(++order);
                documents.add(recipientDocument);
            }
        }

        docs.documents = documents;

        String addDocRes = DocuSignApiCall.restPut(
            'accounts/' +
            accountId +
            '/envelopes/' +
            envelopeId +
            '/documents',
            lockHeaders,
            JSON.serialize(docs, true)
        );
        System.debug('addDocRes: ' + addDocRes);
    }

    //======================= DocuSign MODEL DEFINITION,
    // these classes match the DocuSign RestAPI spec's (not all fields have been included for every object)
    // only those that we need at this point in time. Included as inner class's so that they are not used anywhere else in this project.
    //=======================
    @TestVisible
    private class EnvelopeDefinition {
        private String templateId;
        private String status;
        @TestVisible
        private String emailSubject;
        @TestVisible
        private Notification notification;
        private Boolean enforceSignerVisibility;
        private Document[] documents;
        private Recipients recipients;
        public CustomTextFields customFields;
    }

    private class CustomTextFields {
        private CustomTextField[] textCustomFields;
    }

    private class CustomTextField {
        private String fieldId;
        private String name;
        private String show;
        private String required;
        private String value;
    }

    // By default, requests to sign or view expire 120 days after sending the envelope, to allow Account Defaults to override this value it need to be set explicitly
    // https://www.docusign.com/blog/developers/default-api-reminder-and-expiration-settings
    // https://support.docusign.com/s/document-item?language=en_US&bundleId=pik1583277475390&topicId=onc1583277380729.html&_LANG=enus
    private class Notification {
        @TestVisible
        private Boolean useAccountDefaults; // NOTE: we only support true currently
    }

    private class Documents {
        private Document[] documents;
    }

    private class Document {
        private String documentId;
        private String name;
        private String order;
        private String display;
        private String documentBase64;
    }

    private class Recipients {
        private Recipient[] signers;
    }

    private class Recipient {
        private String email;
        private String name;
        private String recipientId;
        private String routingOrder;
        private String clientUserId;
        private String[] customFields; // NOTE: this can only be an array of 3, DocuSign maps this to CustomField1, CustomField2 and CustomField3
        private Tabs tabs;
    }

    private class Tabs {
        private Tab[] signHereTabs;
        private Tab[] initialHereTabs;
        private Tab[] dateSignedTabs;
        private Tab[] textTabs;
    }

    private class Tab {
        private String anchorString;
        private String value;

        private String anchorUnits;
        private String anchorXOffset;
        private String anchorYOffset;

        private String fontColor;
        private String fontSize;
        private String bold;
    }

    private class RecipientView {
        private String returnUrl;
        private String authenticationMethod;
        private String userId;
        private String clientUserId;
        private String recipientId;
    }

    public class Lock {
        public String lockDurationInSeconds;
        public String lockedByApp;
        public String lockType;
    }

    public class UnLock {
        public String lockToken;
        public String lockDurationInSeconds;
    }

    public class RecipientsResponse {
        public RecipientResponse[] signers;
    }

    public class RecipientResponse {
        public String recipientId;
        public String userId;
        public String clientUserId;
        public String status;
    }
}