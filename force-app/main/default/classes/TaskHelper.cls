/**
 * Created by Andreas du Preez on 2024/03/20.
 */

public with sharing class TaskHelper {

    @AuraEnabled
    public static Id createTask(String whatId, String subject, String relatedSObjectAPIName, String priority, String status, String comment, String ownerId, String groupDeveloperName, String groupType){
        Id relatedOwnerId = ownerId != null ? ownerId : getGroupId(groupDeveloperName, groupType);

        SObjectType sObjectType = Schema.getGlobalDescribe().get(relatedSObjectAPIName);
        String relatedType = sObjectType.getDescribe().label;

        Task task = new Task();
        task.WhatId = whatId;
        task.Subject = subject;
        task.Related_Type__c = relatedType;
        task.Priority = priority;
        task.Status = status;
        task.Description = comment;

        if(relatedOwnerId != null) {
            task.OwnerId = relatedOwnerId;
        }

        insert task;
        return task.Id;
    }

    private static Id getGroupId(String groupName, String groupType){
        List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName =: groupName AND Type =: groupType];

        if(groups.size() == 1){
            return groups[0].Id;
        }

        return null;
    }
}