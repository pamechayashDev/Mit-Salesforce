@isTest
public class TaskRepositoryTest {

    @isTest
    public static void testGetTaskRecordTypeId() {
        Test.startTest();
        String recordTypeId = TaskRepository.getTaskRecordTypeId();
        Test.stopTest();
        
        System.assertNotEquals(null, recordTypeId, 'Record Type Id should not be null');
    }

    @isTest
    public static void testCreateTaskRecords() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Task task = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Low',
            WhatId = acc.Id,
            OwnerId = UserInfo.getUserId(),
            ActivityDate = Date.today(),
            Description = 'Test Description'
        );
        List<Task> vTaskList = new List<Task>();
        vTaskList.add(task);

        Test.startTest();
        TaskRepository.createTaskRecords(vTaskList);
        List<Task> taskList = TaskRepository.getTaskRecords(acc.Id);
        System.assertEquals(1, taskList.size(), 'Object should have one tasks against it');
        Test.stopTest();
    }
}