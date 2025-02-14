@isTest
public with sharing class CleanupRecordBatchTest {
    
    @TestSetup
    static void makeData(){
        TestSetup.defaultConfiguration();
    }

   @isTest
   public static void testCleanupRecord() {
        DateTime theDate = DateTime.now().addDays(-365);
        Log_Exception__c log = new Log_Exception__c();
        log.Class_Name__c = '';
        log.Method_Name__c = '';
        insert log;

        Test.setCreatedDate(log.Id, theDate);

        Test.startTest();
            Database.executeBatch(new CleanupRecordBatch('Log_Exception__c', 250, 'Days'), 200);
            CleanupRecordBatchSchedule.scheduleMeForCleanup();
        Test.stopTest();

        // ASSERT
        List<Log_Exception__c> logException = [Select Id From Log_Exception__c];
        System.assertEquals(logException.size(), 0, 'Log Table Should be Empty');
    }

    @isTest
   public static void testCleanupDoesNotRemoveEntriesNewerThan() {
        DateTime theDate = DateTime.now().addDays(-90);
        Log_Exception__c log = new Log_Exception__c();
        log.Class_Name__c = '';
        log.Method_Name__c = '';
        insert log;

        Test.setCreatedDate(log.Id, theDate);

        Test.startTest();
            Database.executeBatch(new CleanupRecordBatch('Log_Exception__c', 180, 'Days'), 200);
            CleanupRecordBatchSchedule.scheduleMeForCleanup();
        Test.stopTest();

        // ASSERT
        List<Log_Exception__c> logException = [Select Id From Log_Exception__c];
        System.assertEquals(logException.size(), 1, 'Log Table Should Not be Empty, log entry not old enough yet');
    }
    
    @isTest
    public static void testCleanupNotificationRecord() {
	DateTime theDate = DateTime.now().addHours(-1100);
        Notification__c notification = new Notification__c();
        notification.To__c = 'testuser@user.com';
        notification.Variables__c = '{"to":"testuser@user.com"}';
        notification.Template__c = 'TestTemplate';
        insert notification;
        Test.setCreatedDate(notification.Id, theDate);

        DateTime newDate = DateTime.now().addHours(-90);
        Notification__c notificationUndelete = new Notification__c();
        notificationUndelete.To__c = 'testuser1@user.com';
        notificationUndelete.Variables__c = '{"to":"testuser1@user.com"}';
        notificationUndelete.Template__c = 'TestTemplate11';
        insert notificationUndelete;
        Test.setCreatedDate(notificationUndelete.Id, newDate);

        Test.startTest();
            Database.executeBatch(new CleanupRecordBatch('Notification__c', 100, 'Hours'), 200);
            CleanupRecordBatchSchedule.scheduleMeForCleanup();
        Test.stopTest();

        // ASSERT
        List<Notification__c> notificationRecord = [SELECT Id FROM Notification__c];
        System.assertEquals(notificationRecord.size(), 1, 'Notification Table only have 1 entry, as 2 created one old enough for deletion and other not');
    }

}