public with sharing class SendEmailJob implements Queueable, Database.AllowsCallouts  {

    public final Id notificationId;

    public SendEmailJob(Id notificationId) {
        this.notificationId = notificationId;
    }

    public List<Notification__c> start(QueueableContext ctx) {
        System.debug('SendEmailJob:start ' + ctx.getJobId());
        // Ensure we still have a Pending Notification.
        return [ SELECT To__c, BCC__c, CC__c, Template__c, Variables__c, Status__c, Failure_Count__c
                                         FROM Notification__c
                                         WHERE Status__c = 'Pending' AND Id = :notificationId  ];

    }

    public void execute(QueueableContext ctx) {
         List<Notification__c> scope = start(ctx);

         try {
            if(scope != null && !scope.isEmpty()) {
                // You have uncommitted work pending. Please commit or rollback before calling out
                Notification__c notification = scope[0];
                Email.sendEmail(notification.To__c.split(','), notification.Template__c,
                                NotificationBuilder.deserializeVariables(notification.Variables__c),
                                (notification.CC__c != null) ? notification.CC__c.split(',') : null,
                                (notification.BCC__c != null) ?  notification.BCC__c.split(',') : null,
                                notification.Id);
            }
        } catch (Exception e) {
            Configurations__c config = Configurations__c.getInstance('Notification_Retry');
            if(config != null) {
                Integer count = config.Value__c != null ? Integer.valueOf(config.Value__c) : 0;
                Notification__c notification = scope[0];
                if (notification.Failure_Count__c < count) {
                    update new Notification__c(Id = notification.Id, Failure_Count__c = (notification.Failure_Count__c + 1));
                } else {
                    update new Notification__c(Id = notification.Id, Status__c = 'Failed');
                }
            }
        }
    }

}