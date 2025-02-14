public with sharing class EmailNotificationStrategy implements NotificationStrategy {

    public EmailNotificationStrategy() {
        System.debug('EmailNotificationStrategy constructor');
    }
    
    // NOTE:- not using EmailTemplate as SF does not allow Related Entity Type to be External Object or Task 
    //     (hence we would not be able to get at any of the fields for either of these)
    // https://trailhead.salesforce.com/trailblazer-community/feed/0D54S00000A8q8KSAR
    //     >> That is correct - Tasks (and Events) -- do not allow access to their related records like normal records do.
    public void send(List<Notification> notifications) {
        System.debug('EmailNotificationStrategy notifications: ' + notifications);
        
        // TODO only send notification to assignee if they have User Preferece        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Integer i = 0; i < notifications.size(); i++) {
            EmailNotification emailNotification = (EmailNotification) notifications.get(i);
            System.debug('EmailNotificationStrategy emailNotification:- ' + emailNotification);

            User assignedTo = emailNotification.assignedTo;     
            User actionedBy = emailNotification.actionedBy;     
            System.debug('EmailNotificationStrategy assignedTo:- ' + assignedTo);

            // Step 1: Create a new Email
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);

            // Step 2: Set list of people who should get the email
            List<String> sendTo = new List<String>();
            sendTo.add(assignedTo.Email);
            mail.setToAddresses(sendTo);

            // Step 3: Set who the email is sent from
            mail.setReplyTo(emailNotification.replyTo);
            mail.setSenderDisplayName(emailNotification.senderDisplayName);
            
            // Step 4. Set email contents - you can use variables!
            mail.setSubject('Task Completed:- ' + emailNotification.subject);
            
            String targetUrl = URL.getSalesforceBaseUrl().toExternalForm() +'/'+ emailNotification.targetId;
            String appReferenceLink = '<a href=' + targetUrl +'>'+ targetUrl +'</a>';
            
            String body = 'To: ' + assignedTo.Name + ', <BR/> <BR/>';
            body += actionedBy.Name + ' has completed the following task:  <BR/>';
            body += 'Subject: ' + emailNotification.Subject + '<BR/>';
            body += emailNotification.variables.get('Related_Type__c') + ': ' + emailNotification.variables.get('Related_To_Name') + '<BR/>';
            body += 'Priority: ' + emailNotification.variables.get('Priority') + '<BR/>';
            body += 'Comments: '+ StringUtils.ifNullReplace(emailNotification.body, '');
            body += + '<BR/><BR/>';
            body += 'For more details, click the following link:' + '<BR/><BR/>';
            body += appReferenceLink;
            mail.setHtmlBody(body);
            
            // Step 5. Add your email to the master list
            mails.add(mail);            
        }

        System.debug('mails.size():- ' + mails.size()); 
        
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(mails);

    }
}