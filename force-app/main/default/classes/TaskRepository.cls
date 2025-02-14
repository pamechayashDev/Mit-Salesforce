public class TaskRepository {

    @AuraEnabled
    public static List<Task> getTaskRecords(Id PrentId) {
        return [SELECT Id, Subject, Status, Owner.Name, ActivityDate, Description, Priority, CreatedDate FROM Task WHERE WhatId = :PrentId];
    }

    @AuraEnabled(Cacheable=true)
    public static String getTaskRecordTypeId() {
        return Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CRDR').getRecordTypeId();
    }

    @AuraEnabled
    public static String createTaskRecords (List<Task> tasklist) {
        try {
            if(tasklist != null && tasklist.size() > 0) {
                List<Task> taskToInsert = new List<Task>();
                for(Task task : tasklist) {
                    Task newTask = new Task();
                    newTask.Subject = task.Subject;
                    newTask.ActivityDate = task.ActivityDate;
                    newTask.Description = task.Description; 
                    newTask.Priority = task.Priority;
                    newTask.Status = task.Status;
                    newTask.WhatId = task.WhatId;
                    newTask.OwnerId = task.OwnerId;
                    newTask.Related_Type__c = task.Related_Type__c;
                    taskToInsert.add(newTask);
                }
                insert taskToInsert;
                return 'Success';
            } else {
                throw new AuraHandledException('Task list is empty.');
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error creating task records: ' + ex.getMessage());
        }
    }

}