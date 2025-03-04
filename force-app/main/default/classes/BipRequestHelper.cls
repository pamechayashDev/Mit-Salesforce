public class BipRequestHelper {

    public static void afterBipRequestUpdate(Map<Id, Object> newMap,  Map<Id, Object> oldMap){
        
        Set<String> recIds = new Set<String>();
        for(String vNewBipID : newMap.keySet()){
            BIP_Request__c vNewBip = (BIP_Request__c)newMap.get(vNewBipID);
            BIP_Request__c vOldBip = (BIP_Request__c)oldMap.get(vNewBipID); 
            if(vNewBip.Status__c != vOldBip.Status__c){
                recIds.add(vNewBip.Id);
            }
        }

        Map<Id,BIP_Request__c> vBipMap= new Map<Id,BIP_Request__c>([Select Id, Account_Number__c,Status__c, Owner.Email , email_CCs__c, Requestor_Name__c, Primary_PI__c, Proposal_Number__c, Request_Type__c, Due_Date__c, Comments__c, Requestor_Department__c, Requestor_Email__c, Primary_PI_Lookup__c, Primary_PI_Lookup__r.PersonEmail,  Primary_PI_Lookup__r.PersonContactId ,Project_Title__c , (SELECT Id, Status__c, Role__c, TLO_Officer_Name__c, CreatedBy.Name ,CreatedBy.Email ,PI__c, PI__r.Id , PI__r.Name,PI__r.PersonEmail FROM BIP_PIs__r), (SELECT Case__c FROM BIP_Case_Junctions__r )  From BIP_Request__c Where Id IN :recIds]);
        // Query for the Org-Wide Email Address
        OrgWideEmailAddress[] orgWideEmailAddresses = [
            SELECT Id, Address
            FROM OrgWideEmailAddress
            WHERE DisplayName = 'BIP Notifications'
            LIMIT 1
        ];
        EmailTemplate template = [
            SELECT Id, Name, DeveloperName, Body
            FROM EmailTemplate
            WHERE DeveloperName = 'Send_BIP_Request'
            LIMIT 1
        ];

        List<SendEmailController.emailWrapper> vEmailLIst = new List<SendEmailController.emailWrapper>();
        for(BIP_Request__c bip : vBipMap.values()){
            SendEmailController.emailWrapper vEmail = new SendEmailController.emailWrapper();
            vEmail.emailBody = emailBody(bip);
            vEmail.emailSubject = 'Status Changed';
            vEmail.emailTo = bip.Primary_PI_Lookup__r.PersonEmail;
            vEmail.emailCC = bip.email_CCs__c;
            vEmail.whatId=bip.Id;
            //vEmail.templaiteId = template.Id;
            vEmail.orgWideEmail = orgWideEmailAddresses[0];
            vEmailLIst.add(vEmail);
        }

        SendEmailController.sendEmail(vEmailLIst);
        
    }

    public static String emailBody(BIP_Request__c request) {
        // Initialize the email body string
        String emailBody = '';

        // Concatenate each field and its value to the email body string
        emailBody += 'Account Number: ' + request.Account_Number__c + '\n';
        emailBody += 'Status: ' + request.Status__c + '\n';
        emailBody += 'Owner Email: ' + (request.Owner != null ? request.Owner.Email : '') + '\n';
        emailBody += 'CC Emails: ' + request.email_CCs__c + '\n';
        emailBody += 'Requestor Name: ' + request.Requestor_Name__c + '\n';
        emailBody += 'Primary PI: ' + request.Primary_PI__c + '\n';
        emailBody += 'Proposal Number: ' + request.Proposal_Number__c + '\n';
        emailBody += 'Request Type: ' + request.Request_Type__c + '\n';
        emailBody += 'Due Date: ' + request.Due_Date__c + '\n';
        emailBody += 'Comments: ' + request.Comments__c + '\n';
        emailBody += 'Requestor Department: ' + request.Requestor_Department__c + '\n';
        emailBody += 'Requestor Email: ' + request.Requestor_Email__c + '\n';
        emailBody += 'Primary PI Email: ' + (request.Primary_PI_Lookup__r != null ? request.Primary_PI_Lookup__r.PersonEmail : '') + '\n';
        emailBody += 'Primary PI Contact ID: ' + (request.Primary_PI_Lookup__r != null ? request.Primary_PI_Lookup__r.PersonContactId : '') + '\n';
        emailBody += 'Project Title: ' + request.Project_Title__c + '\n';

        // If there are related BIP_PIs records
        if (request.BIP_PIs__r != null) {
            for (BIP_PI__c pi : request.BIP_PIs__r) {
                emailBody += '--- PI Details ---\n';
                emailBody += 'PI Status: ' + pi.Status__c + '\n';
                emailBody += 'PI Role: ' + pi.Role__c + '\n';
                emailBody += 'TLO Officer Name: ' + pi.TLO_Officer_Name__c + '\n';
                emailBody += 'PI Name: ' + (pi.PI__r != null ? pi.PI__r.Name : '') + '\n';
                emailBody += 'PI Email: ' + (pi.PI__r != null ? pi.PI__r.PersonEmail : '') + '\n';
                emailBody += 'Created By: ' + pi.CreatedBy.Name + '\n';
                emailBody += 'Creator Email: ' + pi.CreatedBy.Email + '\n';
                emailBody += '\n';
            }
        }

        emailBody += '\n\n'; // Separate each BIP_Request record with an extra newline
    

        // Return the full string
        return emailBody;
    }
    
}