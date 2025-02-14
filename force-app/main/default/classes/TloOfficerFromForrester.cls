public class TloOfficerFromForrester implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public static string LAST_SYNC_DATE_CONFIG = 'batchJobTloOfficerLastSuccessSyncDate';
    public static string CALLOUT_PAGE_SIZE_CONFIG = 'calloutPageablePageSize';

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('TloOfficerFromForrester:start');
        return Database.getQueryLocator([Select Id, Name, Value__c From Configurations__c
                                         where Name = :LAST_SYNC_DATE_CONFIG]);
    }
   

    public void execute(Database.BatchableContext bc, List<Configurations__c> scope){
        
        try {
            System.debug('TloOfficerFromForrester:scope ' + scope.size() );
            Integer pageSize = Integer.ValueOf(pageSize());
            Integer page = 0;
            ForresterDto.TloLicenseOfficerDto pageableDto = null;
            Date lastSyncDate = getLastSyncDate(scope[0].Value__c);

            // read all the change, can not mix transactions and callouts. Need to read all the callout values first.
            List<ForresterDto.TloLicenseOfficerDto> buffer = new List<ForresterDto.TloLicenseOfficerDto>();
            do {
                page++;
                pageableDto = getNextPage(page, pageSize, lastSyncDate);

                if(pageableDto == null || pageableDto.results == null || pageableDto.results.isEmpty()) {
                    // No more results
                    break;
                }else {
                    buffer.add(pageableDto);
                }

            } while (pageableDto != null && pageableDto.currentPage != pageableDto.totalPages && pageableDto.totalItems > 0 );

            // process the changes
            for (ForresterDto.TloLicenseOfficerDto officerDto : buffer) {
                processPage(officerDto);
            }    
            

        } catch(exception ex) {
            HandleLogException.logException(ex);
            String msg = ex.getMessage();
            System.debug('Error: Tlo Officer Batch ' + msg ) ; 
        }
    }

    public void finish(Database.BatchableContext bc){
        
        Configurations__c config = Configurations__c.getInstance(LAST_SYNC_DATE_CONFIG);
        config.Value__c = Helpers.formatDate(DateTime.now());
        update config;
    }

    private ForresterDto.TloLicenseOfficerDto getNextPage(Integer page, Integer pageSize, Date lastSyncDate) {
       
        String startDate = Helpers.formatDate(lastSyncDate);
        String endDate = Helpers.formatDate(DateTime.now());

        // Sync all the changes from the last sync date up to the end of today
        String queryParams = getQueryParams(page, pageSize, startDate, endDate );

        String apiName = 'forresterApi';
        String endpoints = '/disclosures/licensing-officer/updated?' + queryParams;
        System.debug('Calling end point ' + endpoints );

        String response = AwsApiCall.restGet(apiName, endpoints);
        if(response == null || response.length() == 0 ) {
            System.debug('Tlo Officer Batch response is empty ');
            return null;
        } else {
            System.debug('Tlo Officer Batch response ' + response );
        }
        ForresterDto.TloLicenseOfficerDto respObj = (ForresterDto.TloLicenseOfficerDto)JSON.deserialize(response, ForresterDto.TloLicenseOfficerDto.class);
        return respObj;
    }

    private void processPage(ForresterDto.TloLicenseOfficerDto pageableDto) {

        Map<String, Disclosure__c>  disclosureMap = getDisclosuresByExternalIds(pageableDto);
        Map<String, TLO_Officer__c> tloContactMap = getTloOfficersByForresterId(pageableDto);

        List<TLO_Officer__c> createContacts = new List<TLO_Officer__c>();
        List<Disclosure__c> updateDisclosures = new List<Disclosure__c>();

        if(pageableDto.results == null || pageableDto.results.isEmpty()) {
            return;
        }
        // Create missing TLO Contacts for TLO Officers
        for (ForresterDto.TloCaseDto tloCase : pageableDto.results) {
            if (tloCase == null) {
                continue;
            }
            System.debug('tloCase.externalId ' + tloCase.externalId);

            String externalId = String.valueOf(tloCase.externalId); 
            String officerId = tloCase.caseOfficer.officerId;

            // TLO Officers share email address for example 'tlo-tech@mit.edu'
            // Not all TLO Officers have mitIds
            if(officerId == null) {
                continue;
            }

            Disclosure__c disclosure = disclosureMap.get(externalId);
            TLO_Officer__c contact = tloContactMap.get(officerId);
            if(disclosure == null) {
                continue;
            }

            if(contact == null) {
                String tloOfficerName = tloCase.caseOfficer.name != null ? tloCase.caseOfficer.name : tloCase.caseOfficer.officerId ;
                TLO_Officer__c tloOfficer = new TLO_Officer__c(
                    Email__c = tloCase.caseOfficer.email,
                    Forrester_OfficerId__c = tloCase.caseOfficer.officerId,
                    MitId__c = tloCase.caseOfficer.mitId,
                    Name = tloOfficerName
                    );
                createContacts.add(tloOfficer);
                tloContactMap.put(tloCase.caseOfficer.officerId, tloOfficer);
            }

        }

        if(!createContacts.isEmpty()) {
            insert createContacts;
        }

        // Assign TLO Officer to existing Disclosure
        for (ForresterDto.TloCaseDto tloCase : pageableDto.results) {
            
            String externalId = String.valueOf(tloCase.externalId);
            String officerId = tloCase.caseOfficer.officerId;

            if(officerId == null) {
                continue;
            }

            Disclosure__c disclosure = disclosureMap.get(externalId);
            TLO_Officer__c contact = tloContactMap.get(officerId);
            if(disclosure == null) {
                continue;
            }

            if(contact != null && disclosure.TLO_License_Officer__c != contact.Id) {
                disclosure.TLO_License_Officer__c = contact.Id;
                updateDisclosures.add(disclosure);
            }

        }

        if(!updateDisclosures.isEmpty()) {
            update updateDisclosures;
        }



    }

    private Map<String, Disclosure__c> getDisclosuresByExternalIds(ForresterDto.TloLicenseOfficerDto pageableDto) {
        Set<String> externalIds = new Set<String>();
        Map<String, Disclosure__c> response = new Map<String, Disclosure__c>();

        if (pageableDto.results == null) {
            return response;
        }
        for (ForresterDto.TloCaseDto tloCase : pageableDto.results) {
            // Salesforce use negative external ids, Mendix used positive external ids 
            if (tloCase.externalId < 0) {
                externalIds.add(String.valueOf(tloCase.externalId));
            }
        }
        
        
        for(Disclosure__c disclosure :DisclosureRecordFetch.getDisclosuresByExternalId(externalIds)) {
            response.put(disclosure.External_ID__c, disclosure);
        }
        return response;
    }

    private Map<String, TLO_Officer__c> getTloOfficersByForresterId(ForresterDto.TloLicenseOfficerDto pageableDto) {
        Set<String> forresterIds = new Set<String>();
        for (ForresterDto.TloCaseDto tloCase : pageableDto.results) {
            if( tloCase.caseOfficer != null && tloCase.caseOfficer.officerId != null) {
                forresterIds.add(tloCase.caseOfficer.officerId);
            }
        }
        
        Map<String, TLO_Officer__c> response = new Map<String, TLO_Officer__c>();
        
        for(TLO_Officer__c contact : DisclosureRecordFetch.getTLOOfficersByForresterIds(forresterIds)) {
             if(contact.Forrester_OfficerId__c != null) {
                response.put(contact.Forrester_OfficerId__c, contact);
             }
        }

        return response;
    }

    private Date getLastSyncDate(String dateString) {
        Date lastSyncDate = Date.valueOf(dateString);
            
        if (lastSyncDate >= Date.today()) {
            lastSyncDate = Date.today().addDays(-1);
        }
        return lastSyncDate;
    }


    private String getQueryParams(Integer page, Integer pageSize, String startDate, String endDate) {
        return 'page=' + page + '&pageSize=' + pageSize + '&start=' + startDate + '&end=' + endDate ;
    }


    private static String pageSize() {
        try{
            return ConfigurationBuilder.getConfigurationToString(CALLOUT_PAGE_SIZE_CONFIG);
        } catch(Exception ex) {
            return '1000';
        }
    }

}