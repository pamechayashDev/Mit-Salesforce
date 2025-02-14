public with sharing class BellNotificationStrategy implements NotificationStrategy {

    @TestVisible
    private static Double sendCounter = 0 ;

    public BellNotificationStrategy() {
        System.debug('BellNotificationStrategy constructor');
    }

    private void incrementCounter() {
        if (Test.isRunningTest()) {
            sendCounter++;
        }
    }

    public void send(List<Notification> notifications) {
        System.debug('BellNotificationStrategy notifications: ' + notifications);

        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName = 'TLO_Notifications'];


        for (Integer i = 0; i < notifications.size(); i++) {
            
            BellNotification bellNotification = (BellNotification) notifications.get(i);
            System.debug('BellNotificationStrategy bellNotification: ' + bellNotification);        
                                                                                           
            // Create a new custom notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        
            // Set the contents for the notification
            notification.setTitle(bellNotification.title);
            notification.setBody(bellNotification.body);
                
            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(bellNotification.targetId);
                        
            Set<String> addressee = new Set<String>();
            addressee.add(bellNotification.assignedToId);
                        
            // Actually send the notification
            try {
                incrementCounter();
                System.debug('BellNotificationStrategy addressee: ' + addressee);
                notification.send(addressee);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }
    }
}