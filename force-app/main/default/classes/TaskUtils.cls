public with sharing class TaskUtils {
    
    public static Set<String> getTaskCloseStatuses() {
        List<String> completeStatusApiName = new List<String> { 'Completed' };
        List<TaskStatus> closedStatusList = [SELECT ApiName, IsClosed FROM TaskStatus WHERE IsClosed = true];
        for(TaskStatus status : closedStatusList) {
            completeStatusApiName.add(closedStatusList[0].ApiName);
        }
        Set<String> closedStatusSet = new Set<String>();
        for(String ts : completeStatusApiName){ closedStatusSet.add(ts); }

        return closedStatusSet;
    }
}