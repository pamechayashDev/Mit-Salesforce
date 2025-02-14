public abstract class CaseVisibilityDto  {

    public enum CaseTypeEnum {
            BioTang,
            Invention,
            Software,
            Copyright
    }

    public virtual class CaseListResponse extends PageableDto {
        public List<CaseResponse> results { get; set; }
        public CaseListResponse() {
             results = new List<CaseResponse>();
        }
    }

    public virtual class CaseResponse {
        public String caseNumber;
        public String caseSortOrder;
        public String caseSuffix;
        public String caseStatus;
        public Date openDate;
        public DateTime conceptionDate;
        public CaseTypeEnum caseType;
        public String caseTitle;
        public String ownershipType;
    }

   public virtual class CaseDetailResponse extends CaseResponse {
        public MitPersonResponse caseOfficer;
        public String jointOwnerMultiLine;
        public String jointOwnerSingleLine;
        public List<String> sponsorNames;
    }

   public virtual class MitPersonResponse {
        public String mitId;
        public String name;
        public String email;
    }

    public virtual class PatentsListResponse {
        public List<PatentDetailResponse> results { get; set; }
        public PatentsListResponse() {
             results = new List<PatentDetailResponse>();
        }
    }

   public virtual class CountryResponse {
        public String code;
        public String name;
    }
   public virtual class PatentDetailResponse {

        public String serialNumber;
        public DateTime fileDate;
        public String patentType;
        public String status;
        public String patentNumber;
        public DateTime patentIssueDate;
        public String publicationNumber;
        public CountryResponse country;
        public List<CountryResponse> designatedCountries;
    }


    public abstract class PageableDto {
        public Integer totalItems;
        public Integer totalPages;
        public Integer currentPage;
    }

    public virtual class InventorsListResponse {
        public List<InventorDetailResponse> results { get; set; }
        public InventorsListResponse() {
            results = new List<InventorDetailResponse>();
        }
    }

    public virtual class InventorDetailResponse {
        public String mitId;
        public String name;
        public String email;
        public Boolean isPrimaryPI;
    }
}