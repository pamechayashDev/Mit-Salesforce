@isTest
global class MockBIPUtilsPeopleSearch implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"people":[{ "student":null,"staff":true,"scopedUserId":"ebj@mit.edu","preferredName":"Eran","OdlcName":null,"nonMitEmail":null,"mitIdObsolete":"N","mitIdCreationDate":"Fri Jun 07 2024 14:24:59 GMT+0000 (Coordinated Universal Time)","mitId":"900047159","mitHrOrgUnitId":"10000273","mitEmail":"ebj@mit.edu","legalMiddleName":null,"legalLastName":"Ben-Joseph","legalFirstName":"Eran","krbName":"ebj","kerbCreationDate":"2011-03-28T21:19:33.000Z","jobTitle":"Professor","institution":null,"homeAddressZip":null,"homeAddressStreet1":null,"homeAddressStateCode":null,"homeAddressCity":null,"gradStudent":null,"dobMonth":"08","dobDay":"10","deceased":false,"alumniRecordTypeName":null,"alumniRecordTypeCode":null,"affiliate":false}]}');
        return res;
    }
    
}