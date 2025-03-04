public with sharing class SendEmailController {
    public static void sendEmail(
        List<emailWrapper> vWrapperList) 
        {
            BipEmailNotifications__c settings = BipEmailNotifications__c.getOrgDefaults();

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            for(emailWrapper vEmail : vWrapperList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(vEmail.orgWideEmail.Id);
                if (settings != null && !settings.Enabled__c) {
                    email.setSubject(vEmail.emailSubject=' TEST');
                    // Custom setting is disabled, reroute email
                    if (vEmail.templaiteId != null) {
                        email.setTemplateId(vEmail.templaiteId);
                        email.setWhatId(vEmail.whatId);
                        email.setTargetObjectId(settings.targetObjectId__c);
                        email.setSaveAsActivity(false); // Optionally save as Activity
                    } else {    
                        email.setToAddresses(new List<String>{settings.ToEmail__c});
                        String body = vEmail.emailBody;
                        body = body+'Original To: ' + vEmail.emailTo + '\nOriginal From: ' + vEmail.orgWideEmail + '\nCCs: ' + vEmail.emailCC+ ',';
                        email.setPlainTextBody(body);
                    }                    
                } else {
                    // Custom setting is enabled, use the original recipients
                    email.setSubject(vEmail.emailSubject);
                    if (vEmail.templaiteId != null) {
                        email.setTemplateId(vEmail.templaiteId);
                        email.setWhatId(vEmail.whatId);
                        email.setTargetObjectId(vEmail.targetId);
                    } else {    
                        email.setToAddresses(new List<String>{vEmail.emailTo});
                        email.setPlainTextBody(vEmail.emailBody);
                    }
                    if (vEmail.emailCC != null) {
                        email.setCCAddresses(vEmail.emailCC.split(','));
                    }
                    //String urlString = URL.getOrgDomainURL().toExternalForm() + '/' + bip.Id;
                }
                emails.add(email);
            }
            try {
                if(emails.size() > 0){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                    system.debug('send email results: '+results);
                }
            } catch (Exception ex) {
                throw new AuraHandledException('Error while sending email: ' + ex.getMessage());
            }
    }
    public class emailWrapper {
        public String emailBody;
        public String emailSubject;
        public String emailTo;
        public String emailCC;
        public Id templaiteId;
        public Id whatId;
        public Id targetId;
        public OrgWideEmailAddress orgWideEmail;
    }
}