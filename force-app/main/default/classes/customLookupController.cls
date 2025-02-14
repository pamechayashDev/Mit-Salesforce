public with sharing class customLookupController {
    
    @AuraEnabled
    public static List<LookupSearchResult> searchLookupRecords(String searchTerm, List<String> selectedIds,String sObjectName, String field, String subField,Integer maxResults, String iconName) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String strQuery = '';
        if(sObjectName == 'User'){
            strQuery = 'SELECT Id, '+field + (String.isNotBlank(subField) ? ' ,'+subField : '')+' FROM '+sObjectName;
        	strQuery += ' WHERE '+field+' LIKE \'' + searchTerm + '%\' AND (NOT Profile.Name like \'%Community%\') AND (NOT Profile.Name like \'%Portal user%\') AND IsActive = true AND';  
        	strQuery += ' Id NOT IN :selectedIds ORDER BY '+field+' LIMIT :maxResults';
        }
        else{
            strQuery = 'SELECT Id, '+field + (String.isNotBlank(subField) ? ' ,'+subField : '')+' FROM '+sObjectName;
        	strQuery += ' WHERE '+field+' LIKE \'' + searchTerm + '%\' AND ';  
        	strQuery += ' Id NOT IN :selectedIds ORDER BY '+field+' LIMIT :maxResults';
        }
        
        List<sObject> searchResults = Database.query(strQuery); 
        
        if(searchResults != NUll && !searchResults.isEmpty()){
            for(sObject sObj : searchResults){
                LookupSearchResult res = new LookupSearchResult();
                res.Id = sObj.Id;
                res.title = String.valueOf(sObj.get(field));
                if(String.isNotBlank(subField) && sObj.get(subField) != NULL){
                    res.subtitle = String.valueOf(sObj.get(subField));
                }else{
                    res.subtitle = sObjectName;
                }
                res.iconName = iconName;
                results.add(res);
            } 
        }
        
        if(sObjectName == 'User'){
            String Query = 'SELECT Id, '+field + (String.isNotBlank(subField) ? ' ,'+subField : '')+' FROM Group';
        	Query += ' WHERE '+field+' LIKE \'' + searchTerm + '%\' AND ';  
        	Query += ' Id NOT IN :selectedIds ORDER BY '+field+' LIMIT :maxResults';
            
            List<sObject> searchResults2 = Database.query(Query);
            
            if(searchResults2 != NUll && !searchResults2.isEmpty()){
                for(sObject sObj : searchResults2){
                    LookupSearchResult res = new LookupSearchResult();
                    res.Id = sObj.Id;
                    res.title = String.valueOf(sObj.get(field));
                    if(String.isNotBlank(subField) && sObj.get(subField) != NULL){
                        res.subtitle = String.valueOf(sObj.get(subField));
                    }else{
                        res.subtitle = 'Queue';
                    }
                    res.iconName = 'standard:queue';
                    results.add(res);
                } 
        	}
        }
        
        return results;        
    }
    
    @AuraEnabled
    public static LookupSearchResult getRecentlyCreatedRecord(String sObjectName, String recordId, String field, String subField) {
        LookupSearchResult result = new LookupSearchResult();
        String strQuery = 'SELECT Id, '+field + (String.isNotBlank(subField) ? ' ,'+subField : '')+' FROM '+sObjectName +' WHERE Id =:recordId LIMIT 1';
        List<sObject> searchResults = Database.query(strQuery);   
        if(searchResults != NUll && !searchResults.isEmpty()){
            sObject sObj = searchResults.get(0);
            LookupSearchResult res = new LookupSearchResult();
            result.Id = sObj.Id;
            result.title = String.valueOf(sObj.get(field));
            if(String.isNotBlank(subField) && sObj.get(subField) != NULL){
                result.subtitle = String.valueOf(sObj.get(subField));
            }else{
                result.subtitle = sObjectName;
            }
        }
        return result;        
    }
    
    public class LookupSearchResult {
        @AuraEnabled public Id id{get;set;}
        @AuraEnabled public String title{get;set;}
        @AuraEnabled public String subtitle{get;set;}
        @AuraEnabled public String iconName{get;set;}
    }
}