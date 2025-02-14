public with sharing class BellNotification implements Notification {
    
    public String title; 
    public String body; 
    public Id targetId; 
    public Id assignedToId;
    public User actionedBy;

    public static List<Notification> convertTasksToBellNotifications(List<Task> tasks) {
        List<Notification> bellNotifications = new List<BellNotification>();
        for(Task tsk : tasks) {
            BellNotification bellNotification = new BellNotification();
            
            bellNotification.title = 'Task Completed';
            bellNotification.body = tsk.Subject;
            bellNotification.targetId = tsk.Id;
            bellNotification.assignedToId = tsk.CreatedById;
            
            bellNotifications.add(bellNotification);
        }

        return bellNotifications;
    }
}