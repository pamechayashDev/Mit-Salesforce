public with sharing class SendEmailController {
    @AuraEnabled
    public static string sendEmail(
        String recId,
        String templateId,
        String toEmail,
        Boolean bodyChanged,
        String changedBody,
        List<String> ccEmails,
        String PersonContactId,
        Boolean isPrimaryPiLookupNull,
        Boolean byStatusChange
    ) {
        try {
            system.debug('inside send Email');
            EmailTemplate  template;
            if(templateId!='NA'){
              template = [SELECT  Subject from EmailTemplate WHERE Id = :templateId  LIMIT 1];
            }
            BIP_request__c bip = [Select Name ,email_CCs__c, Status__c from Bip_Request__c where Id = :recId Limit 1];
      
            system.debug('bodyChanged--:'+bodyChanged);
            if (isPrimaryPiLookupNull) {
                System.debug('Missing Primary PI');
                return 'Missing Primary PI';
            }

            System.debug('inside method');
            System.debug(recId + '-' + templateId + '-+' + toEmail + '-' + ccEmails + '-' + PersonContactId);

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(byStatusChange==true){
               String urlString = URL.getOrgDomainURL().toExternalForm() + '/' + recId;
                String body= String.format('Record URL : {0}\nBIP Number : {1}\nNew Status : {2}',new List<String>{ urlString ,bip.Name, bip.Status__c});

                System.debug('URL----------'+URL.getOrgDomainURL().toExternalForm() + '/' + recId);
                email.setSubject('Status Changed');
                email.setPlainTextBody(body);
              }
              else if(bodyChanged==false){
            email.setTemplateId(templateId);
            email.setTargetObjectId(PersonContactId);
          }
        else{
            email.setSubject(template.Subject);
            email.setPlainTextBody(changedBody);
          }
        
       
            System.debug('cc----Emailss' + ccEmails);



            if (ccEmails != null && ccEmails.size() > 0) {
                email.setCCAddresses(ccEmails);
            }
            List<String> toEmails = new List<String>{ toEmail };
                system.debug('toEmails---==='+toEmails);
            email.setToAddresses(toEmails);
            email.setWhatId(recId);
          
          
            System.debug(json.serializePretty('EMAIL---++++++++ '+email));  
        
           // email.setSaveAsActivity();
              
            // Query for the Org-Wide Email Address
            OrgWideEmailAddress[] orgWideEmailAddresses = [
                SELECT Id, Address
                FROM OrgWideEmailAddress
                WHERE DisplayName = 'TLO BIP Request'
                LIMIT 1
            ];
            
             
                if (!orgWideEmailAddresses.isEmpty()) {
                    email.setOrgWideEmailAddressId(orgWideEmailAddresses[0].Id);
                    
                } else {
                    System.debug('No Org-Wide Email Address found.');
                    return 'No Org-Wide Email Address found';
                }

            emails.add(email);
            System.debug(json.serializePretty(emails));

            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
             system.debug('send');
            Boolean noError = true;
            for(Messaging.SendEmailResult res:results){
                if(!res.isSuccess()){
                    noError= false;
                }
            }
            system.debug('noError--'+noError);
            system.debug('status Change:'+   byStatusChange);
        
            if(noError && !byStatusChange){
                system.debug('inside');
              
                  bip.email_CCs__c = string.join(ccEmails,',');
               bip.Status__c = 'Assigned to PI';
            system.debug('updating status');
              update bip;   
            }
    

        } catch (Exception ex) {
            throw new AuraHandledException('Error while sending email: ' + ex.getMessage());
        }
 
        return 'success';
    }
}