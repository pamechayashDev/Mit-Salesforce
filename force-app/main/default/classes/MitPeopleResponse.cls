public class MitPeopleResponse extends PeopleSearchApiDto {
    public List<person> people { get; set; }
    public class person {
        public String mitId { get; set; }
        public String krbName { get; set; }
        public String legalFirstName { get; set; }
        public String legalMiddleName { get; set; }
        public String preferredName { get; set; }
        public String legalLastName { get; set; }
        public String dobDay { get; set; }
        public String dobMonth { get; set; }
        public Boolean affiliate { get; set; }
        public Boolean student { get; set; }
        public Boolean staff { get; set; }
        public Boolean alumni { get; set; }
        public Boolean gradStudent { get; set; }
        public String OdlcName { get; set; }
        public String jobTitle { get; set; }
        public String mitEmail { get; set; }
        public String nonMitEmail { get; set; }
        public String alumniEmail { get; set; }
        public String mitHrOrgUnitId { get; set; }
        public String institution { get; set; }
        public String mitIdCreationDate { get; set; }
        public String mitIdObsolete { get; set; }
        public String alumniRecordTypeCode { get; set; }
        public String alumniRecordTypeName { get; set; }
        public Boolean alumniCanLogin { get; set; }
        public Boolean deceased { get; set; }
        public String kerbCreationDate { get; set; }
        public String scopedUserId { get; set; }
        public String homeAddressCity { get; set; }
        public String homeAddressStreet1 { get; set; }
        public String homeAddressStateCode { get; set; }
        public String homeAddressZip { get; set; }
    }
}