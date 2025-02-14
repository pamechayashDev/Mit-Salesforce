// https://animeshgaitonde.medium.com/a-deep-dive-into-the-strategy-design-pattern-5723eb3937b4
// https://www.learncsdesign.com/learn-the-decorator-design-pattern/

public interface NotificationStrategy {
    
    void send(List<Notification> notifications);
}