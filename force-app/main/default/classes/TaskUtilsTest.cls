@IsTest
public with sharing class TaskUtilsTest {
    
    @IsTest
    static void testGetClosedTaskStatus(){
        Set<String> closedStatusSet = TaskUtils.getTaskCloseStatuses(); 
        System.assert(closedStatusSet.contains('Completed'), 'Completed Task Status Not Found');
    }
}