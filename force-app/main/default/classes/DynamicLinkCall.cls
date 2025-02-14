public with sharing class DynamicLinkCall {
    @AuraEnabled
    public static string generateDynamicLinkForDisclosureId(Id disclosureId) {
        Firebase__c firebaseDetails = Firebase__c.getInstance();
        System.debug(firebaseDetails.Dynamic_Link_URL__c);
        String body = '{"longDynamicLink": "https://research.atlas-apps.link/?link=https://research.atlas-apps.link/tlo-disclosure?id={'+disclosureId+'}"}';
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(firebaseDetails.Dynamic_Link_URL__c);
            req.setMethod('POST');
            req.setTimeout(30000);
            req.setBody(body);
            // Set Headers
            for (string key : headers.keySet()) {
                string value = headers.get(key);
                req.setHeader(key, value);
            }

            System.debug(req);

            // Get response
            HttpResponse res = http.send(req);
            System.debug(res.getBody());
            Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            System.debug('shortlink: '+response.get('shortLink'));
            return JSON.serialize(response.get('shortLink'));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}