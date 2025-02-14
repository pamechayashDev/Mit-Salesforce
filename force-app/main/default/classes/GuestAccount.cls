public with sharing class GuestAccount {
    public static final String GUEST_API = 'guestAccountApi';
    public class GuestAccountNotFoundException extends Exception {}

    @TestVisible
    private static String orgEnvironment {
        get {
            if (orgEnvironment == null) {
                orgEnvironment = 'PROD';
                Organization org = [Select Id, Name, IsSandbox from Organization];
                System.debug('Organization isSandbox ' + org.IsSandbox);
                // Ensure that we cannot override PROD value from Configuration settings
                if(org.IsSandbox || Test.isRunningTest()){
                    Configurations__c config = Configurations__c.getInstance('orgEnvironment');
                    if (config != null) {
                        orgEnvironment = config.Value__c;
                    } else {
                        orgEnvironment = 'DEV';
                    }
                }
            }
            return orgEnvironment;
        }
        set;
    }

    public class AccountDataWrapper {
        @AuraEnabled public String status;
        @AuraEnabled public List<InviteCode> inviteCodes;
    }

    public class InviteCode {
        @AuraEnabled public String systemName;
        @AuraEnabled public String inviteCode;
        @AuraEnabled public String validUntil;
        @AuraEnabled public String email;
    }

    @AuraEnabled(cacheable=true)
    public static AccountDataWrapper getGuestAccountStatus(String email) {

        String urlEncodedEmail = EncodingUtil.urlEncode(email, 'UTF-8');

        String endPointAccountStatus = '/account-status?email=' + urlEncodedEmail;
        String endPointInviteCode = '/invite-codes?email=' + urlEncodedEmail;

        List<Integer> validSuccessStatuses = new List<Integer>{ 200, 201 };
        Map<string, string> headerData = new Map<String, String>();
        headerData.put('Content-Type', 'application/json;charset=UTF-8');
        headerData.put('X-System-Name', 'TLO');

        String jsonAccountStatusBody = AwsApiCall.restGetWithHeaders(GUEST_API, endPointAccountStatus, headerData, validSuccessStatuses);
        String jsonInviteCodesBody = AwsApiCall.restGetWithHeaders(GUEST_API, endPointInviteCode, headerData, validSuccessStatuses);

        AccountDataWrapper result = new AccountDataWrapper();

        // Parse the account status
        if (!String.isEmpty(jsonAccountStatusBody)) {
            Map<String, Object> accountStatusMap = (Map<String, Object>) JSON.deserializeUntyped(jsonAccountStatusBody);
            result.status = (String) accountStatusMap.get('status');
        }
        // Parse the invite codes
        if (!String.isEmpty(jsonInviteCodesBody)) {
            Map<String, Object> inviteCodesMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInviteCodesBody);
            result.inviteCodes = new List<InviteCode>();

            if (inviteCodesMap.containsKey('inviteCodes')) {
                List<Object> inviteCodesList = (List<Object>) inviteCodesMap.get('inviteCodes');
                for (Object obj : inviteCodesList) {
                    Map<String, Object> inviteCodeMap = (Map<String, Object>) obj;
                    InviteCode inviteCode = new InviteCode();
                    inviteCode.systemName = (String) inviteCodeMap.get('systemName');
                    inviteCode.inviteCode = (String) inviteCodeMap.get('inviteCode');
                    inviteCode.validUntil = (String) inviteCodeMap.get('validUntil');
                    inviteCode.email = (String) inviteCodeMap.get('email');
                    result.inviteCodes.add(inviteCode);
                }
            }
        }

        return result;
    }


    @Future(callout=true)
    public static void futureCreateGuestAccounts(String disclosureId) {
        createGuestAccounts(disclosureId);
    }

    @AuraEnabled
    public static List<Account> createGuestAccounts(String disclosureId) {
        List<Account> updateGuestAccounts = new List<Account>();

        List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsWithContactByDisclosureId(
            disclosureId
        );
        for (DisclosureInventor__c inventor : inventors) {
            Account contact = inventor.Contact__r;
            Boolean guestAccountNeeded =
                contact.GuestAccountNeeded__pc == 'Yes';
            Boolean invitationCodeNullOrEmpty =
                contact.InvitationCode__pc == null ||
                contact.InvitationCode__pc.length() == 0;
            Boolean isAlumni =
                contact.IsAlumni__pc != null &&
                contact.IsAlumni__pc == true;
            Boolean isActiveKerb = Helpers.isActiveKerb(contact.MoiraStatus__pc);
            Boolean createInviteCode = guestAccountNeeded || (!isAlumni && !isActiveKerb);
            Boolean guestAccountStatusExist = createInviteCode? guestAccountStatusExist(contact) : true;
            if (invitationCodeNullOrEmpty && createInviteCode && !guestAccountStatusExist) {
                GuestAccountBuilder builder = new GuestAccountBuilder()
                    .createInviteCode(contact);

                Account updateContact = builder.build();
                if (updateContact != null) {
                    updateContact.GuestAccountNeeded__pc = 'No';
                    updateGuestAccounts.add(updateContact);
                }
            }
        }
        if (!updateGuestAccounts.isEmpty()) {
            update updateGuestAccounts;
        }
        return updateGuestAccounts;
    }

    public static List<Account> createGuestAccountByInventorIds(
        List<String> disclosureInventorIds
    ) {
        List<Account> updateGuestAccounts = new List<Account>();

        List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsByIds(
            disclosureInventorIds
        );
        for (DisclosureInventor__c inventor : inventors) {
            Account contact = inventor.Contact__r;
            Boolean guestAccountNeeded =
                contact.GuestAccountNeeded__pc == 'Yes';
            Boolean invitationCodeNullOrEmpty =
                contact.InvitationCode__pc == null ||
                contact.InvitationCode__pc.length() == 0;
            if (invitationCodeNullOrEmpty && guestAccountNeeded) {
                GuestAccountBuilder builder = new GuestAccountBuilder()
                    .createInviteCode(contact);

                Account updateContact = builder.build();
                if (updateContact != null) {
                    updateContact.GuestAccountNeeded__pc = 'No';
                    updateGuestAccounts.add(updateContact);
                }
            }
        }
        if (!updateGuestAccounts.isEmpty()) {
            update updateGuestAccounts;
        }
        return updateGuestAccounts;
    }


    public static Boolean guestAccountStatusExist(Account accContact) {

        try {
            if (accContact.MitId__pc != null) {
                GuestAccountBuilder builder = new GuestAccountBuilder()
                    .getGuestAccountInfo(accContact.MitId__pc);
                if (builder.status == 'INVITED' || builder.status == 'ACTIVE') {
                    return true;
                }
            }
        } catch (GuestAccountNotFoundException ex) {
            // Ignore and allow default return
        }

        return false;
    }

    public static void updateGuestAccount(Account accContact) {
        GuestAccountBuilder builder = new GuestAccountBuilder()
            .getGuestAccountInfo(accContact.MitId__pc);
        if (builder.status == 'INVITED') {
            //request invite code for new email address only if the previous email was invited
            builder.createInviteCode(accContact);
        } else if (builder.status == 'ACTIVE') {
            //update guest account only for active accounts
            builder.updateGuestAccount(accContact);
        } else {
            throw new GuestAccountNotFoundException(
                'Account not in ACTIVE or INVITED state, unable to change email'
            );
        }
    }

    public static Boolean isValidContact(Account contact) {
        Boolean guestAccountNeeded = contact.GuestAccountNeeded__pc == 'Yes';
        Boolean invitationCodeNullOrEmpty = contact.InvitationCode__pc == null || contact.InvitationCode__pc.length() == 0;
        // JIT People Demographic search will not be able to view search results for inactive kerb users
        String email = contact.PersonEmail != null ? contact.PersonEmail : '';
        Boolean isMitEmail = Helpers.isMitEmailAddress(email);

        if (invitationCodeNullOrEmpty && guestAccountNeeded && !isMitEmail) {
            return isValidEmail(contact.PersonEmail);
        }
        return true;
    }
    public static Boolean isValidEmail(String email) {
         if (email == null) {
            // We only want to validate if the email exist
            return true;
         }
         String validation = sandboxEmailValidation(email);
         if (validation == 'Success') {
            return true;
         }
         return false;
    }
    @AuraEnabled(cacheable=true)
    public static String getSandboxJITEmail(String email) {
        String jitEmail = email;
        if(String.isBlank(email)) {
            return email;
        }
        Boolean isMitEmail = Helpers.isMitEmailAddress(email);
        Boolean isSandboxEnvironment = orgEnvironment != 'PROD';
        if (isSandboxEnvironment && !isValidEmail(email) && !isMitEmail) {
              Boolean isDevEnvironment = orgEnvironment == 'DEV';
              Boolean isQaEnvironment = orgEnvironment == 'QA';
              if (isDevEnvironment) {
                jitEmail = email.replace('@', '+dev@');
              }
              if (isQaEnvironment) {
                jitEmail = email.replace('@', '+test@');
              }
        }
        return jitEmail;
    }

    @AuraEnabled(cacheable=true)
    public static String sandboxEmailValidation(String email) {
        String message = 'Success';
        String faultDev = Label.GuestSandboxDevEmailAddressValidation + ' [' + email + ']';
        String faultQA = Label.GuestSandboxQAEmailAddressValidation + ' [' + email + ']';
        Boolean isMitEmail = Helpers.isMitEmailAddress(email);

        Boolean isSandboxEnvironment = orgEnvironment != 'PROD';
        Boolean isDevEnvironment = orgEnvironment == 'DEV';
        Boolean isQaEnvironment = orgEnvironment == 'QA';
        if (isSandboxEnvironment) {
            if (isMitEmail) {
                return Label.GuestEmailAddressValidation;
            }
            Boolean devExist = isDevEnvironment && matchDevEmailKeyword(email);
            Boolean qaExist = isQaEnvironment && matchQAEmailKeyword(email);
            Boolean foundMatch = devExist || qaExist;
            if (!foundMatch) {
               return isQaEnvironment? faultQA :faultDev;
            }
        }
        return message;
    }

    private static Boolean matchDevEmailKeyword(String emailParam) {
       // Guest API Validation rule
       // email.split('@')[0].endsWith('+dev')
       // email.split('@')[0].match(/\+dev\.\w+$/)

       String userName = emailParam.split('@')[0];

       List<Pattern> patterns = new List<Pattern>();
       patterns.add(Pattern.compile('.*\\+dev\\.\\w+$'));
       patterns.add(Pattern.compile('.*\\+dev$'));

       for(Pattern myPattern : patterns) {
            Matcher myMatcher = myPattern.matcher(userName);
            if (myMatcher.matches()) {
                return true;
            }
       }
       return false;
    }

    private static Boolean matchQAEmailKeyword(String emailParam) {
        // Guest API Validation rule
        // email.split('@')[0].endsWith('+test')
        // email.split('@')[0].match(/\+test\.\w+$/)
 
        String userName = emailParam.split('@')[0];
 
        List<Pattern> patterns = new List<Pattern>();
        patterns.add(Pattern.compile('.*\\+test\\.\\w+$'));
        patterns.add(Pattern.compile('.*\\+test$'));
 
        for(Pattern myPattern : patterns) {
             Matcher myMatcher = myPattern.matcher(userName);
             if (myMatcher.matches()) {
                 return true;
             }
        }
        return false;
     }



    public class GuestAccountBuilder {
        Account updateContact;
        String scopedUserId;
        String status;
        List<Integer> validSuccessStatuses = new List<Integer>{ 200, 201 };

        public GuestAccountBuilder createInviteCode(Account contact) {
            if (updateContact == null) {
                updateContact = new Account();
                updateContact.Id = contact.Id;
            }

            String endpoints = '/invite-codes';
            Map<string, string> headerData = new Map<String, String>();
            headerData.put('Content-Type', 'application/json;charset=UTF-8');
            headerData.put('X-System-Name', 'TLO');
            GuestApiDto.InviteCodeRequest request = new GuestApiDto.InviteCodeRequest();
            request.firstName = contact.FirstName;
            request.middleName = contact.MiddleName;
            request.lastName = contact.LastName;
            request.email = contact.PersonEmail;
            if (contact.PersonMobilePhone != null) {
                request.telephone = contact.PersonMobilePhone;
            } else {
                request.telephone = '';
            }
            request.mitId = contact.MitId__pc; // This could be null

            String jsonBody = AwsApiCall.restPostSuccess(
                GUEST_API,
                endpoints,
                headerData,
                JSON.serialize(request, true),
                validSuccessStatuses
            );
            System.debug('restPostSuccess' + jsonBody);

            if (jsonBody == null || jsonBody.length() == 0) {
                throw new CalloutException(
                    'Call to GuestAccount failed, response is empty'
                );
            }

            GuestApiDto.InviteCodeResponse respObj = (GuestApiDto.InviteCodeResponse) JSON.deserialize(
                jsonBody,
                GuestApiDto.InviteCodeResponse.class
            );
            if (respObj.message != null) {
                throw new CalloutException(
                    'Call to GuestAccount failed ' + respObj.message
                );
            }

            if (respObj.mitId == null) {
                throw new CalloutException(
                    'Call to GuestAccount failed missing MitId'
                );
            }

            updateContact.InvitationCode__pc = respObj.inviteCode;
            updateContact.MitId__pc = respObj.mitId;
            return this;
        }

        public GuestAccountBuilder getGuestAccountInfo(String mitId) {
            String endpoints = '/guest-accounts';
            mitId = EncodingUtil.urlEncode(mitId, 'UTF-8');
            endpoints += '?mitid=' + mitId;

            String response = AwsApiCall.restGet(GUEST_API, endpoints);
            if (response == null || response.length() == 0) {
                throw new CalloutException(
                    'Call to GuestAccount /guest-accounts failed, response is empty '
                );
            } else {
                System.debug(
                    'Call to GuestAccount /guest-accounts response ' + response
                );
            }

            GuestApiDto.GuestAccountInfoWithMitIdResponse respObj = (GuestApiDto.GuestAccountInfoWithMitIdResponse) JSON.deserialize(
                response,
                GuestApiDto.GuestAccountInfoWithMitIdResponse.class
            );
            
            if (respObj.message != null) {
                if (respObj.message.contains('Not Found')) {
                    throw new GuestAccountNotFoundException(
                        'Guest account not found for MitId: ' + mitId
                    );
                } else {
                    System.debug('🐞 ~ GuestAccountBuilder ~ getGuestAccountInfo ~ response:' + respObj);
                    throw new CalloutException(
                        'Call to GuestAccount failed for MitId: ' + mitId + ', Response message: ' + respObj.message
                    );
                }
            }

            if (respObj.scopedUserId == null) {
                throw new CalloutException(
                    'Call to GuestAccount failed, missing scopedUserId for MitId: ' + mitId
                );
            }

            scopedUserId = respObj.scopedUserId;
            status = respObj.status;
            return this;
        }

        public GuestAccountBuilder updateGuestAccount(Account contact) {
            String endpoints = '/guest-accounts/' + scopedUserId;
            Map<string, string> headerData = new Map<String, String>();
            headerData.put('Content-Type', 'application/json;charset=UTF-8');
            headerData.put('X-System-Name', 'TLO');
            GuestApiDto.GuestAccountUpdateRequest request = new GuestApiDto.GuestAccountUpdateRequest();
            request.firstName = contact.FirstName;
            request.middleName = contact.MiddleName;
            request.lastName = contact.LastName;
            request.email = contact.PersonEmail;
            if (contact.PersonMobilePhone != null) {
                request.telephone = contact.PersonMobilePhone;
            } else {
                request.telephone = '';
            }
            request.status = 'ACTIVE';
            request.userDetails = new GuestApiDto.UserDetails();
            request.userDetails.institution = contact.Institution__pc;
            request.userDetails.institutionCode = contact.InstitutionCode__pc;
            request.userDetails.altEmail = contact.AltEmail__pc;
            System.debug(JSON.serialize(request, true));

            String jsonBody = AwsApiCall.restPut(
                GUEST_API,
                endpoints,
                headerData,
                JSON.serialize(request, true)
            );
            System.debug('restPostSuccess' + jsonBody);

            if (jsonBody == null || jsonBody.length() == 0) {
                throw new CalloutException(
                    'Call to GuestAccount  /guest-accounts failed, response is empty'
                );
            }

            GuestApiDto.GuestAccountInfoWithMitIdResponse respObj = (GuestApiDto.GuestAccountInfoWithMitIdResponse) JSON.deserialize(
                jsonBody,
                GuestApiDto.GuestAccountInfoWithMitIdResponse.class
            );
            if (respObj.message != null) {
                throw new CalloutException(
                    'Call to GuestAccount failed ' + respObj.message
                );
            }

            if (respObj.mitId == null) {
                throw new CalloutException(
                    'Call to GuestAccount failed missing MitId'
                );
            }
            return this;
        }

        public Account build() {
            return updateContact;
        }
    }
}