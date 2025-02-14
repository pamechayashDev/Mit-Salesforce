@RestResource(urlMapping='/api/jit/v1/*')
global with sharing class JitApi {
    // A User's username and email address do not have to be the same.
    // The username must be in the form of an email address (i.e. xxxx@xxx.com), but does not have to be a valid email address.
    // The username must be unique across all Salesforce orgs, including trial and Sandbox orgs.
    global static String getUsernameFromWrapper(UserWrapper userRequest) {
        String userName =
            userRequest.mitId +
            '@tlo.edu' +
            userRequest.salesforceEnvUsernameSuffix;
        return userName;
    }

    //https://salesforcecodex.com/salesforce/create-customer-community-user-in-salesforce-apex/
    global static boolean canCreateUser(UserWrapper userRequest) {
        System.debug('userRequest: ' + userRequest);

        String userName = getUsernameFromWrapper(userRequest);
        User[] u = [
            SELECT Id, FirstName, ContactId, Username
            FROM User
            WHERE Username = :userName
            LIMIT 1
        ];

        System.debug('u: ' + u);

        if (u.size() > 0) {
            return false;
        }

        return true;
    }

    private static Account createPersonAccount(UserWrapper userRequest) {
        // it is only likely that a Person Account needs to be created when Touchstone users (ie: active kerb'd people login)
        // guest's will have needed to be added to a Disclosure 1st (even those which where migrated from Forrester) will have had Person Account
        // created with the migration steps

        // If not found, create a new one    and because of the above, we can assume they've logged in via Touchstone and thus have an active kerb
        // extra check added here to check the "idp" used it Touchstone too

        Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Boolean isTouchStone = (userRequest.idp == 'TouchStone');
        String moiraStatus = isTouchStone ? '1' : '';

        Account personAccount = new Account(
            RecordTypeId = personAccRecTypeId,
            LastName = userRequest.lastName,
            FirstName = userRequest.firstName,
            MitId__pc = userRequest.mitId,
            MoiraStatus__pc = moiraStatus, //"idp": "Alumni",   (lincon have special emails too can i use that) "TouchStone"
            PersonEmail = userRequest.email
        );

        insert personAccount;
        System.debug('Attempted Person Account creation: ' + personAccount.Id);

        return personAccount;
    }

    private static Id handlePersonAccount(UserWrapper userRequest) {
        System.debug(' ------------- JitApi handlePersonAccount -------------');
        System.debug('JitApi handleUser userRequest: ' + userRequest);

        Account personAccount;
        try {
            // Check if a Person Account already exists for this user
            personAccount = [
                SELECT
                    Id,
                    FirstName,
                    LastName,
                    PersonEmail,
                    MitId__pc,
                    MoiraStatus__pc,
                    InvitationCode__pc,
                    OwnerId
                FROM Account
                WHERE MitId__pc = :userRequest.mitId AND IsPersonAccount = TRUE
                LIMIT 1
            ];

            // Check if a Person Account has the required fields
            Boolean hasChanged = false;
            if (
                (personAccount.FirstName == null ||
                personAccount.LastName == null) ||
                (personAccount.FirstName != userRequest.firstName ||
                personAccount.LastName != userRequest.lastName)
            ) {
                hasChanged = true;
                personAccount.FirstName = userRequest.firstName;
                personAccount.LastName = userRequest.lastName;
            }

            if (personAccount.PersonEmail == null) {
                hasChanged = true;
                personAccount.PersonEmail = userRequest.email;
            }

            // Invitation Code is not needed anymore
            if (personAccount.InvitationCode__pc != null) {
                hasChanged = true;
                personAccount.InvitationCode__pc = null;
            }

            // Change owner to current user
            if (personAccount.OwnerId != System.userInfo.getUserId()) {
                hasChanged = true;
                personAccount.OwnerId = System.userInfo.getUserId();
            }

            if (hasChanged) {
                update personAccount;
            }
        } catch (System.QueryException e) {
            personAccount = createPersonAccount(userRequest);
        }

        if (personAccount != null) {
            System.debug(
                'Attempted Person Account creation: ' + personAccount.Id
            );
        }

        return personAccount.Id;
    }

    @HttpPost
    global static UserResponseWrapper createUser() {
        RestRequest req = RestContext.request;
        RestResponse rep = RestContext.response;

        UserWrapper userRequest = new UserWrapper();
        userRequest = (UserWrapper) System.JSON.deserialize(
            req.requestBody.toString(),
            UserWrapper.class
        );
        System.debug('wrpData: ' + userRequest);

        // Check if username already exsists
        if (!JitApi.canCreateUser(userRequest)) {
            String userName = getUsernameFromWrapper(userRequest);
            User u = [
                SELECT Id, FirstName, ContactId, Username, isActive
                FROM User
                WHERE username = :userName
                LIMIT 1
            ];

            UserResponseWrapper existingUserResponse = new UserResponseWrapper();
            existingUserResponse.sfId = u.Id;
            existingUserResponse.username = u.Username;

            handlePersonAccount(userRequest);

            return existingUserResponse;
        } else {
            // create user.
            Id accountID = handlePersonAccount(userRequest);
            Account personAccount = [
                SELECT PersonContactId
                FROM Account
                WHERE Id = :accountID
                LIMIT 1
            ];
            Id personContactId = personAccount.PersonContactId;

            String profileName = ShirleyConstants.COMMUNITY_PROFILE_NAME;
            Profile p = [SELECT Id FROM profile WHERE name = :profileName];

            User u = new User();
            u.Email = userRequest.email;
            u.Username = getUsernameFromWrapper(userRequest);
            u.LastName = userRequest.lastName;
            u.FirstName = userRequest.firstName;
            u.ContactId = personContactId; //https://salesforce.stackexchange.com/questions/107335/no-access-to-portal

            String alias = '';
            if (u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            if (alias.length() > 5) {
                alias = alias.substring(0, 5);
            }

            u.Alias = alias;
            u.Languagelocalekey = UserInfo.getLocale();
            u.Localesidkey = UserInfo.getLocale();
            u.EmailEncodingKey = 'UTF-8';
            u.TimeZoneSidKey = defaultCommunityUserTimeZone();
            u.ProfileId = p.Id;

            insert u;
            System.debug('Attempted User creation: ' + u.Id);
            Id uID = u.Id;

            UserResponseWrapper newUserResponse = new UserResponseWrapper();
            newUserResponse.sfId = u.Id;
            newUserResponse.username = u.Username;

            return newUserResponse;
        }
    }

    @TestVisible
    private static String defaultCommunityUserTimeZone() {
        Organization org = [
            SELECT Id, TimeZoneSidKey
            FROM Organization
            LIMIT 1
        ];
        return org.TimeZoneSidKey;
    }
}