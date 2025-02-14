public abstract  class ForresterDto  {
    public static final String SALARY_WAGES_MIT = 'MIT';
    public static final String SALARY_WAGES_NON_MIT = 'Non-MIT';
    public static final String SALARY_WAGES_BOTH = 'Both';

    public String user;

    public class AdditionalInformationDto {
        public String salaryOrWages;
        public String salaryOrWagesDetail; // description: Required for NonMit and Both
        public String workAtMit;
        public String workAtOtherInstitution;
        public String workAtOtherInstitutionMoreDetail; // Required for Yes
        public String wasResearchAsPartOfCollaboration;
        public String wasResearchAsPartOfCollaborationMoreDetail; // Required for Yes
        public String wasResearchAsPerformedByConsultant;
        public String wasResearchAsPerformedByConsultantMoreDetail; // Required for Yes
        public List<String>fundingDlc; // ["CENTER_BITS_ATOMS", "MEDIA_LAB", "LINCOLN_LAB"]
        // Center of Bits and Atoms(Medial Lab), Media Lab, Lincoln Lab
        public List<String>affiliationOptions; // ["WYSS_INSTITUTE", "WHITEHEAD", "BROAD_INSTITUTE", "SMART", "IMES"]
        // Wyss Institute, Whitehead, Broad Institute, Singapore-MIT Alliance for Research and Technology, Institute for Medical Engineering and Sciences
        public String additionalSponsoredResearchOrFundingSources;
        public String conceivedDuringCourseWork;
        public String conceivedDuringCourseWorkMoreDetail; // Required for Yes
        public String thirdPartyMaterialsOrDatasets;
        public String additionalComments;
    }

    public class InventorDto {
        public String mitId;
        public String inventorName;
        public String legalGivenName;
        public String legalMiddleName;
        public String legalLastName;
        public String email;
        public Boolean hhmi;
        public Boolean signedDisclosureFlag;
        public String signedDisclosureComment;
        public Boolean govEmployeeStatusFlag;
        public Boolean atMitAtTheTimeOfInvention;
        public String alternatePhone;
        public String alternateEmail;
        public String alternateAddress;
        public String alternateAddressCity;
        public String alternateAddressState;
        public String alternateAddressZipcode;
        public String alternateAddressCountry;
        public String countryCitizenship;
        public Boolean submitOnBehalfOf;
        public AdditionalInformationDto additionalInformation;
        public Boolean primaryContact;
        public String institution;
        public String institutionCode;
        public String oldEmail;
        public String birthday;
        public String position;
        public String department;
    }


    // Get TLO License Officer
    public abstract class PageableDto {
        public Integer totalItems;
        public Integer totalPages;
        public Integer currentPage;
    }

    public class TloCaseOfficerDto {
        public String mitId;
        public String officerId;
        public String name;
        public String email;
    }

    public class TloCaseDto {
        public Integer externalId;
        public String caseNumber;
        public String caseSuffix;
        public String caseStatus;
        public TloCaseOfficerDto caseOfficer;
    }

    public class TloLicenseOfficerDto extends PageableDto {
        public List<TloCaseDto> results;
    }

    public class UtilizationListDto {
        public List<UtilizationDto> results;
    }
    public class UtilizationErrorDto {
        public String code;
        public String field;
        public String message;
    }

    public class UtilizationDto {
        public String latestStageDev;
        public String firstCommercialSaleYear;
        public Integer exclusiveLicensesOptions;
        public Integer nonExclusiveLicensesOptions;
        public String exclusiveLicensesNames;
        public String nonExclusiveLicensesNames;
        public Integer smallBusinessLicensesOptions;
        public String licNamesAndCounts;
        public Double totalIncome;
        public String message;
        public String status;
        public Integer caseRecid;
        public String caseNumber;
        public String caseStatus;
        public String caseOfficerId;
        public String caseOfficerMitId;
        public String caseOfficerName;
        public String caseOfficerEmail;
        public Integer responseCode;
        public List<UtilizationErrorDto> errors;
        public Double royaltiesOnSales;
        public Double otherIncomeAndEquity;
    }
}