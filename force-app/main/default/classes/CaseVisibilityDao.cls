public with sharing class CaseVisibilityDao {
    public class InvalidParameterException extends Exception {}
    public class NotFoundException extends Exception {}

    private static Forrester_Case__x getForresterCaseByCaseNumber(String mitId, String caseNumber) {
         List<Forrester_Case__x> cases = ExternalObjectQuery.records(
                                 [select Id,
                                        CASE_RECID__c,
                                        CONTRACT_CASE_NUM__c,
                                        SORT_ORDER__c,
                                        CASE_SUFFIX__c,
                                        CASE_TYPE__c,
                                        OWNERSHIP_TYPE__c,
                                        JOINT_OWNER_MULTI_LN__c,
                                        JOINT_OWNER_SINGLE_LN__c,
                                        DISCLOSURE_TITLE__c,
                                        STATUS__c,
                                        CASE_STATUS__c,
                                        OPEN_DATE__c,
                                        CONCEPTION_DATE__c,
                                        TLO_ID__c,
                                        TLO_EMAIL__c,
                                        TLO_NAME__c,
                                        TLO_MIT_ID__c,
                                        CASE_SPONSOR_NAMES__c
                                    FROM Forrester_Case__x
                                    WHERE
                                    CONTRACT_CASE_NUM__c = :caseNumber
                                    LIMIT 1
                                ]
                        );
        Set<String> caseRecIds = new Set<String>();
        for(Forrester_Case__x dbCase :cases) {
            caseRecIds.add(dbCase.CASE_RECID__c);
        }

        List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x> caseInventors = ExternalObjectQuery.records(
                        [select Id, CASE_RECID__c from Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x
                                WHERE MIT_ID__c = :mitId
                                AND CASE_RECID__c IN :caseRecIds
                        ]);
        if (caseInventors.isEmpty()) {
            // User is not allowed to view the case detail
            throw new NotFoundException('No caseNumber: ['+ caseNumber +'] found for logged in Inventor MIT_ID [' + mitId + ']');
        }
        Forrester_Case__x dbCase = cases[0];
        return dbCase;
    }

    public static CaseVisibilityDto.CaseDetailResponse getInventorCaseDetailByCaseNumber(String mitId, String caseNumber) {

        Forrester_Case__x dbCase = getForresterCaseByCaseNumber(mitId, caseNumber);
        CaseVisibilityDto.CaseDetailResponse caseDetail = forresterCaseDetailMapper(dbCase);

        return caseDetail;
    }

    private static String getSoqlFilters(String filterString) {
        if (String.isBlank(filterString)) {
            return '';
        }
        // Map to translate DAO to SF fields
        Map<String, String> fieldMap = new Map<String, String>{
            'caseType' => 'CASE_TYPE__c',
            'caseStatus' => 'CASE_STATUS__c',
            'openDate' => 'OPEN_DATE__c'
        };
        // Map to translate operation symbols to SOQL operators
        Map<String, String> operatorMap = new Map<String, String>{
            ':' => '=',
            '!' => '!=',
            '>' => '>',
            '<' => '<',
            '~' => 'LIKE'
        };

        // Split the search parameter into individual filters
        List<String> filters = filterString.split(',');

        // Prepare list to store SOQL-compatible filter strings
        List<String> soqlFilters = new List<String>();

        for (String filter : filters) {
            // Split each filter into key, operation, and value
            List<String> parts = filter.split('[:!><~]', 2); // Split at the first operation character
            if (parts.size() != 2) {
                continue; // Skip invalid filters
            }

            String key = parts[0].trim();
            String valueAndOperator = filter.substring(key.length(), filter.length()).trim();
            String operationSymbol = valueAndOperator.substring(0, 1); // The operator symbol
            String value = valueAndOperator.substring(1).trim();

            if(!fieldMap.containsKey(key)) {
                continue; // Skip invalid key
            }
            // Validate and translate operation symbol
            if (!operatorMap.containsKey(operationSymbol)) {
                continue; // Skip invalid operators
            }

            String translatedOperator = operatorMap.get(operationSymbol);

            // Escape single quotes in value and add quotes if necessary
            value = String.escapeSingleQuotes(value);
            if (translatedOperator == 'LIKE') {
                value = '\'%' + value + '%\'';
            } else {
                value = '\'' + value + '\'';
            }

            // Append the filter to the list
            String sfField = fieldMap.get(key);

            if(sfField == 'OPEN_DATE__c') {
                value = value.replace('\'','');
            }
            soqlFilters.add(sfField + ' ' + translatedOperator + ' ' + value);
        }
        if(!soqlFilters.isEmpty()) {
            // Construct the WHERE clause
            String whereClause = String.join(soqlFilters, ' AND ');

            return ' AND (  '
                   +  whereClause
                   + ') ';
        }
        return '';

    }

    public static CaseVisibilityDto.CaseListResponse getCasesByMitId(String mitId, String searchString, String filterString ,Integer pageSize, Integer page) {
        if (pageSize < 1 || page < 1) {
            throw new InvalidParameterException('Current Page or Page Size should be greater than 0');
        }

        //Integer limitSize = pageSize;
        //Integer offsetSize = (page - 1) * pageSize;
        //' LIMIT :limitSize OFFSET :offsetSize'; //TODO, this would be the best solution, the IN clause using OData does not make it possible

        Integer batchSize = 50;
        List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x> caseInventors = ExternalObjectQuery.records(
                                            [select Id, CASE_RECID__c from Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x
                                                WHERE MIT_ID__c = :mitId ]
                                            );
        List<String> externalObjRecIds = new List<String>();
        Set<String> caseRecIds = new Set<String>();
        for(Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x caseInventor :caseInventors) {
            caseRecIds.add(caseInventor.CASE_RECID__c);
        }
        String searchFilter = '';
        if (String.isNotBlank(searchString)) {
            searchFilter = ' AND (  '
                + ' DISCLOSURE_TITLE__c LIKE \'%' + searchString + '%\' '
                + ' or CONTRACT_CASE_NUM__c LIKE \'%' + searchString + '%\' '
                + ') ';
        }

        if (String.isNotBlank(filterString)) {
            searchFilter += getSoqlFilters(filterString);
        }

        String theExternalObjectQuery = 'SELECT CONTRACT_CASE_NUM__c, '
                                                + ' SORT_ORDER__c, '
                                                + ' CASE_SUFFIX__c, '
                                                + ' CASE_TYPE__c, '
                                                + ' OWNERSHIP_TYPE__c, '
                                                + ' DISCLOSURE_TITLE__c, '
                                                + ' STATUS__c, '
                                                + ' CASE_STATUS__c, '
                                                + ' OPEN_DATE__c, '
                                                + ' CONCEPTION_DATE__c '
                                                + ' FROM Forrester_Case__x '
                                                + ' WHERE CASE_RECID__c In :batchFilter '
                                                + ' AND ( '
                                                + '     IS_PATENT__c = TRUE '
                                                + '     OR IS_DESIGN_PATENT__c = TRUE '
                                                + '     OR IS_TRADEMARK__c = TRUE '
                                                + '     OR IS_COPYRIGHT_SW__c = TRUE '
                                                + '     OR IS_COPYRIGHT_MASKWORKS__c = TRUE '
                                                + '     OR IS_COPYRIGHT_OTHER__c = TRUE '
                                                + '     OR IS_TANGIBLE_BIOLOGICAL__c = TRUE '
                                                + '     OR IS_TANGIBLE_OTHER__c = TRUE '
                                                + '   ) '
                                                + ' AND (NOT DISCLOSURE_TITLE__c  LIKE \'Equity%\') '
                                                + ' AND (NOT DISCLOSURE_TITLE__c  LIKE \'DUPLICATE%\') '
                                                + ' AND (NOT DISCLOSURE_TITLE__c  LIKE \'Duplicate%\') '
                                                + ' AND (NOT DISCLOSURE_TITLE__c  LIKE \'Revenue%\' ) '
                                                + ' AND (NOT CONTRACT_CASE_NUM__c like \'%Z%\' ) '
                                                + ' AND STATUS__c NOT IN (\'Work In Process\')' //TODO Dont show WIP
                                                + searchFilter
                                                + ' order by SORT_ORDER__c LIMIT 2000';

        System.debug('theExternalObjectQuery>>' + theExternalObjectQuery);
        List<Forrester_Case__x> forresterCase = ExternalObjectQuery.records(
                                                    ExternalObjectRepository.fetchExternalQueryByExternalRecIds(new List<String>(caseRecIds), theExternalObjectQuery, batchSize)
                                                    );

        return caseListingMapper(forresterCase, pageSize, page);
     }


     public static CaseVisibilityDto.CaseListResponse caseListingMapper(List<Forrester_Case__x> forresterCases, Integer pageSize, Integer page) {
        CaseVisibilityDto.CaseListResponse caseList = new CaseVisibilityDto.CaseListResponse();
        // Set total items and pages
        Integer totalItems = forresterCases.size();
        Integer totalPages = (totalItems + pageSize - 1) / pageSize; // Calculate total pages (rounding up)

        caseList.totalItems = totalItems;
        caseList.totalPages = totalPages;
        caseList.currentPage = page;

        // Ensure the page number is within range
        if (page < 1 || page > totalPages) {
            return caseList;
        }

        // Calculate start and end indices for slicing the list
        Integer startIndex = (page - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, totalItems);

        // Extract only the cases for the current page
        // Create a sublist manually
        List<Forrester_Case__x> pagedCases = new List<Forrester_Case__x>();
        for (Integer i = startIndex; i < endIndex; i++) {
            pagedCases.add(forresterCases[i]);
        }

        for (Forrester_Case__x dbCase : pagedCases) {
            caseList.results.add(forresterCaseMapper(dbCase));
        }

        String strJSON = JSON.serialize(caseList);
        System.debug(caseList);
        return caseList;
     }

    public static CaseVisibilityDto.CaseDetailResponse forresterCaseMapper(Forrester_Case__x dbCase) {
        CaseVisibilityDto.CaseDetailResponse caseResponse = new CaseVisibilityDto.CaseDetailResponse();
        caseResponse.caseNumber = dbCase.CONTRACT_CASE_NUM__c;
        caseResponse.caseSortOrder = dbCase.SORT_ORDER__c;
        caseResponse.caseSuffix = dbCase.CASE_SUFFIX__c;
        caseResponse.ownershipType = dbCase.OWNERSHIP_TYPE__c;
        caseResponse.caseType = CaseVisibilityDto.CaseTypeEnum.valueOf(dbCase.CASE_TYPE__c);
        caseResponse.caseTitle = dbCase.DISCLOSURE_TITLE__c;
        caseResponse.caseStatus = dbCase.CASE_STATUS__c;
        caseResponse.openDate = dbCase.OPEN_DATE__c;
        caseResponse.conceptionDate = dbCase.CONCEPTION_DATE__c;
        return caseResponse;
    }

    public static CaseVisibilityDto.CaseDetailResponse forresterCaseDetailMapper(Forrester_Case__x dbCase) {
        CaseVisibilityDto.CaseDetailResponse caseDetail = new CaseVisibilityDto.CaseDetailResponse();
        caseDetail = (CaseVisibilityDto.CaseDetailResponse) forresterCaseMapper(dbCase);

        CaseVisibilityDto.MitPersonResponse tloOfficer = new CaseVisibilityDto.MitPersonResponse();
        tloOfficer.mitId = dbCase.TLO_MIT_ID__c;
        tloOfficer.name = dbCase.TLO_NAME__c;
        tloOfficer.email = dbCase.TLO_EMAIL__c;
        caseDetail.caseOfficer = tloOfficer;

        if(!String.isBlank(dbCase.CASE_SPONSOR_NAMES__c)) {
            List<String> sponsorNames = dbCase.CASE_SPONSOR_NAMES__c.split(';');
            caseDetail.sponsorNames = new List<String>();
            for(String sponsorName : sponsorNames) {
                caseDetail.sponsorNames.add(sponsorName.trim());
                caseDetail.sponsorNames.sort();
            }
        }

        caseDetail.jointOwnerMultiLine = dbCase.JOINT_OWNER_MULTI_LN__c;
        caseDetail.jointOwnerSingleLine = dbCase.JOINT_OWNER_SINGLE_LN__c;

        return caseDetail;
    }

    public static CaseVisibilityDto.PatentsListResponse getCasePatentsByCaseNumber(String mitId, String caseNumber) {
        CaseVisibilityDto.PatentsListResponse patentList = new CaseVisibilityDto.PatentsListResponse();

        List<Forrester_SHIR_CASE_IP_VIEW__x> caseIps = ExternalObjectQuery.records([ select Id,
                                                            SERIAL_NUM__c,
                                                            FILE_DATE__c,
                                                            IP_STATUS_DESCRIPTION__c,
                                                            IP_TYPE_DESCRIPTION__c,
                                                            PATENT_NUM__c,
                                                            PATENT_ISSUED_DATE__c,
                                                            PUB_NUMBER__c,
                                                            COUNTRY_CODE__c,
                                                            COUNTRY_NAME__c,
                                                            DESIGNATED_COUNTRIES__c
                                                        from Forrester_SHIR_CASE_IP_VIEW__x
                                                        where CONTRACT_CASE_NUM__c = :caseNumber
                                                        ]);
        for (Forrester_SHIR_CASE_IP_VIEW__x dbPatent : caseIps) {
            patentList.results.add(forresterPatentMapper(dbPatent));
        }

        String strJSON = JSON.serialize(patentList);
        System.debug(patentList);
        return patentList;
    }

    public static CaseVisibilityDto.InventorsListResponse getCaseInventorsByCaseNumber(String caseNumber) {
        CaseVisibilityDto.InventorsListResponse inventorList = new CaseVisibilityDto.InventorsListResponse();

        List<Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x> caseIps = ExternalObjectQuery.records([ SELECT Id,
                MIT_ID__c,
                INVENTOR_NAME__c,
                PREFERRED_EMAIL__c,
                IS_PRIMARY_PI__c
        FROM Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x
        WHERE CONTRACT_CASE_NUM__c = :caseNumber
        ]);
        for (Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x dbInventor : caseIps) {
            inventorList.results.add(forresterInventorMapper(dbInventor));
        }

        System.debug(inventorList);
        return inventorList;
    }

    public static CaseVisibilityDto.PatentDetailResponse forresterPatentMapper(Forrester_SHIR_CASE_IP_VIEW__x dbPatent) {
        CaseVisibilityDto.PatentDetailResponse patentResponse = new CaseVisibilityDto.PatentDetailResponse();
        patentResponse.serialNumber = dbPatent.SERIAL_NUM__c;
        patentResponse.patentType = dbPatent.IP_TYPE_DESCRIPTION__c;
        patentResponse.status = dbPatent.IP_STATUS_DESCRIPTION__c;
        patentResponse.patentNumber = dbPatent.PATENT_NUM__c;
        patentResponse.publicationNumber = dbPatent.PUB_NUMBER__c;
        patentResponse.fileDate = dbPatent.FILE_DATE__c;
        patentResponse.patentIssueDate = dbPatent.PATENT_ISSUED_DATE__c;
        patentResponse.country = null;


        if(!String.isBlank(dbPatent.COUNTRY_CODE__c) || !String.isBlank(dbPatent.COUNTRY_NAME__c) ) {
            CaseVisibilityDto.CountryResponse country = new CaseVisibilityDto.CountryResponse();
            country.code = dbPatent.COUNTRY_CODE__c;
            country.name = dbPatent.COUNTRY_NAME__c;
            patentResponse.country = country;
        }


        List<CaseVisibilityDto.CountryResponse> designatedCountries;
        if(!String.isBlank(dbPatent.DESIGNATED_COUNTRIES__c)) {
            String countries = dbPatent.DESIGNATED_COUNTRIES__c;
            countries = countries.replace(',', ';');
            List<String> countryCodes = countries.split(';'); // TODO The Data contains a mixture of Codes and Names
            patentResponse.designatedCountries = new List<CaseVisibilityDto.CountryResponse>();
            for(String countryCode : countryCodes) {
                CaseVisibilityDto.CountryResponse country = new CaseVisibilityDto.CountryResponse();
                country.code = countryCode.trim();
                country.name = null; // TODO get the name of the Designated Country
                // TODO Skip bad country code for example 'N/A'
                patentResponse.designatedCountries.add(country);
            }
        }
        return patentResponse;

    }

    public static CaseVisibilityDto.InventorDetailResponse forresterInventorMapper(Forrester_SHIR_CASE_INVENTOR_SHARE_VI__x dbInventor) {
        CaseVisibilityDto.InventorDetailResponse inventorResponse = new CaseVisibilityDto.InventorDetailResponse();
        inventorResponse.mitId = dbInventor.MIT_ID__c;
        inventorResponse.name = dbInventor.INVENTOR_NAME__c;
        inventorResponse.email = dbInventor.PREFERRED_EMAIL__c;
        inventorResponse.isPrimaryPI = dbInventor.IS_PRIMARY_PI__c;

        return inventorResponse;
    }
}