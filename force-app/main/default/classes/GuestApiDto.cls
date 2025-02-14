public abstract class GuestApiDto  {

    public abstract class GuestAccountInfo {
        public String firstName;
        public String middleName;
        public String lastName;
        public String email;
        public String telephone;
    }

    public abstract class AccountDto  extends GuestAccountInfo {
        public String mitId;
    }


    public class InviteCodeRequest extends AccountDto {
    }

    public class InviteCodeResponse {
        public String mitId;
        public String inviteCode;
        public String systemName;
        public String validUntil;
        public String email;
        public String message;
    }

    public class GuestAccountInfoWithMitIdResponse extends GuestAccountInfo {
        public String status;
        public String mitId;
        public String scopedUserId;
        public String message;
    }

    public class UserDetails {
        public String institution;
        public String institutionCode;
        public String altEmail;
    }

    public class GuestAccountUpdateRequest extends GuestAccountInfo
    {
        public String status;
        public UserDetails userDetails;
    }   

}