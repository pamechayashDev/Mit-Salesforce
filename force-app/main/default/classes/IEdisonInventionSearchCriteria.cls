/*
 * IEdison API
 * No description provided (generated by Openapi Generator https://github.com/openapitools/openapi-generator)
 *
 * The version of the OpenAPI document: 1.0.0
 * 
 *
 * NOTE: This class is auto generated by the OAS code generator program.
 * https://github.com/OpenAPITools/openapi-generator
 * Do not edit the class manually.
 */

/**
 * IEdisonInventionSearchCriteria
 */
public class IEdisonInventionSearchCriteria implements OAS.MappedProperties {
    /**
     * Get r_limit
     * @return r_limit
     */
    public Integer r_limit { get; set; }

    /**
     * Get offset
     * @return offset
     */
    public Integer offset { get; set; }

    /**
     * Get inventionReportNumber
     * @return inventionReportNumber
     */
    public String inventionReportNumber { get; set; }

    /**
     * Get inventionDocketNumber
     * @return inventionDocketNumber
     */
    public String inventionDocketNumber { get; set; }

    /**
     * Get grantContractNumber
     * @return grantContractNumber
     */
    public String grantContractNumber { get; set; }

    /**
     * Get inventorFirstName
     * @return inventorFirstName
     */
    public String inventorFirstName { get; set; }

    /**
     * Get inventorLastName
     * @return inventorLastName
     */
    public String inventorLastName { get; set; }

    /**
     * Get primaryAgency
     * @return primaryAgency
     */
    public String primaryAgency { get; set; }

    /**
     * Get granteeOrganizationName
     * @return granteeOrganizationName
     */
    public String granteeOrganizationName { get; set; }

    /**
     * Get titleElectionStatus
     * @return titleElectionStatus
     */
    public List<String> titleElectionStatus { get; set; }

    /**
     * Get inventionTitle
     * @return inventionTitle
     */
    public String inventionTitle { get; set; }

    /**
     * Get inventionReportDateFrom
     * @return inventionReportDateFrom
     */
    public String inventionReportDateFrom { get; set; }

    /**
     * Get inventionReportDateTo
     * @return inventionReportDateTo
     */
    public String inventionReportDateTo { get; set; }

    /**
     * Get inventionKeyword
     * @return inventionKeyword
     */
    public String inventionKeyword { get; set; }

    /**
     * Get doeWaiver
     * @return doeWaiver
     */
    public String doeWaiver { get; set; }

    /**
     * Get governmentCounsel
     * @return governmentCounsel
     */
    public String governmentCounsel { get; set; }

    /**
     * Get governmentStaff
     * @return governmentStaff
     */
    public String governmentStaff { get; set; }

    /**
     * Get lastUpdatedFrom
     * @return lastUpdatedFrom
     */
    public String lastUpdatedFrom { get; set; }

    /**
     * Get lastUpdatedTo
     * @return lastUpdatedTo
     */
    public String lastUpdatedTo { get; set; }

    private static final Map<String, String> propertyMappings = new Map<String, String>{
        'limit' => 'r_limit'
    };

    public Map<String, String> getPropertyMappings() {
        return propertyMappings;
    }

    public IEdisonInventionSearchCriteria() {
        titleElectionStatus = new List<String>();
    }

    public static IEdisonInventionSearchCriteria getExample() {
        IEdisonInventionSearchCriteria inventionSearchCriteria = new IEdisonInventionSearchCriteria();
          inventionSearchCriteria.r_limit = 0;
          inventionSearchCriteria.offset = 0;
          inventionSearchCriteria.inventionReportNumber = '';
          inventionSearchCriteria.inventionDocketNumber = '';
          inventionSearchCriteria.grantContractNumber = '';
          inventionSearchCriteria.inventorFirstName = '';
          inventionSearchCriteria.inventorLastName = '';
          inventionSearchCriteria.primaryAgency = '';
          inventionSearchCriteria.granteeOrganizationName = '';
          inventionSearchCriteria.titleElectionStatus = new List<String>{''};
          inventionSearchCriteria.inventionTitle = '';
          inventionSearchCriteria.inventionReportDateFrom = '';
          inventionSearchCriteria.inventionReportDateTo = '';
          inventionSearchCriteria.inventionKeyword = '';
          inventionSearchCriteria.doeWaiver = '';
          inventionSearchCriteria.governmentCounsel = '';
          inventionSearchCriteria.governmentStaff = '';
          inventionSearchCriteria.lastUpdatedFrom = '';
          inventionSearchCriteria.lastUpdatedTo = '';
        return inventionSearchCriteria;
    }

    public Boolean equals(Object obj) {
        if (obj instanceof IEdisonInventionSearchCriteria) {           
            IEdisonInventionSearchCriteria inventionSearchCriteria = (IEdisonInventionSearchCriteria) obj;
            return this.r_limit == inventionSearchCriteria.r_limit
                && this.offset == inventionSearchCriteria.offset
                && this.inventionReportNumber == inventionSearchCriteria.inventionReportNumber
                && this.inventionDocketNumber == inventionSearchCriteria.inventionDocketNumber
                && this.grantContractNumber == inventionSearchCriteria.grantContractNumber
                && this.inventorFirstName == inventionSearchCriteria.inventorFirstName
                && this.inventorLastName == inventionSearchCriteria.inventorLastName
                && this.primaryAgency == inventionSearchCriteria.primaryAgency
                && this.granteeOrganizationName == inventionSearchCriteria.granteeOrganizationName
                && this.titleElectionStatus == inventionSearchCriteria.titleElectionStatus
                && this.inventionTitle == inventionSearchCriteria.inventionTitle
                && this.inventionReportDateFrom == inventionSearchCriteria.inventionReportDateFrom
                && this.inventionReportDateTo == inventionSearchCriteria.inventionReportDateTo
                && this.inventionKeyword == inventionSearchCriteria.inventionKeyword
                && this.doeWaiver == inventionSearchCriteria.doeWaiver
                && this.governmentCounsel == inventionSearchCriteria.governmentCounsel
                && this.governmentStaff == inventionSearchCriteria.governmentStaff
                && this.lastUpdatedFrom == inventionSearchCriteria.lastUpdatedFrom
                && this.lastUpdatedTo == inventionSearchCriteria.lastUpdatedTo;
        }
        return false;
    }

    public Integer hashCode() {
        Integer hashCode = 43;
        hashCode = (17 * hashCode) + (r_limit == null ? 0 : System.hashCode(r_limit));
        hashCode = (17 * hashCode) + (offset == null ? 0 : System.hashCode(offset));
        hashCode = (17 * hashCode) + (inventionReportNumber == null ? 0 : System.hashCode(inventionReportNumber));
        hashCode = (17 * hashCode) + (inventionDocketNumber == null ? 0 : System.hashCode(inventionDocketNumber));
        hashCode = (17 * hashCode) + (grantContractNumber == null ? 0 : System.hashCode(grantContractNumber));
        hashCode = (17 * hashCode) + (inventorFirstName == null ? 0 : System.hashCode(inventorFirstName));
        hashCode = (17 * hashCode) + (inventorLastName == null ? 0 : System.hashCode(inventorLastName));
        hashCode = (17 * hashCode) + (primaryAgency == null ? 0 : System.hashCode(primaryAgency));
        hashCode = (17 * hashCode) + (granteeOrganizationName == null ? 0 : System.hashCode(granteeOrganizationName));
        hashCode = (17 * hashCode) + (titleElectionStatus == null ? 0 : System.hashCode(titleElectionStatus));
        hashCode = (17 * hashCode) + (inventionTitle == null ? 0 : System.hashCode(inventionTitle));
        hashCode = (17 * hashCode) + (inventionReportDateFrom == null ? 0 : System.hashCode(inventionReportDateFrom));
        hashCode = (17 * hashCode) + (inventionReportDateTo == null ? 0 : System.hashCode(inventionReportDateTo));
        hashCode = (17 * hashCode) + (inventionKeyword == null ? 0 : System.hashCode(inventionKeyword));
        hashCode = (17 * hashCode) + (doeWaiver == null ? 0 : System.hashCode(doeWaiver));
        hashCode = (17 * hashCode) + (governmentCounsel == null ? 0 : System.hashCode(governmentCounsel));
        hashCode = (17 * hashCode) + (governmentStaff == null ? 0 : System.hashCode(governmentStaff));
        hashCode = (17 * hashCode) + (lastUpdatedFrom == null ? 0 : System.hashCode(lastUpdatedFrom));
        hashCode = (17 * hashCode) + (lastUpdatedTo == null ? 0 : System.hashCode(lastUpdatedTo));
        return hashCode;
    }
}