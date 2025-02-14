public class containerObjectRepository {
    @AuraEnabled(cacheable=true)
    public static string getExternalCRDRRecordId(string containerId){
        list<Case_CRDR__c> crdr = [SELECT Id,ExternalCaseCRDRId__c From Case_CRDR__c Where Id = :containerId limit 1];
        String externalCRDRId = '';
        if(crdr.size()>0){
            String ExternalCaseCRDRId  = crdr[0].ExternalCaseCRDRId__c;
        	list<Forrester_SHIR_CRDR_VIEW__x> externalCRDR = [SELECT Id,CASE_CRDR_RECID__c From Forrester_SHIR_CRDR_VIEW__x Where CASE_CRDR_RECID__c = :ExternalCaseCRDRId limit 1];
        	externalCRDRId = externalCRDR[0].Id;
        }
        return externalCRDRId;
    }

}