import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import msgService from "@salesforce/messageChannel/crdrStatusChange__c";
import { publish, MessageContext } from 'lightning/messageService';
import getContainerObjectId from '@salesforce/apex/ExternalObjectRepository.getContainerObjectId';
import getTaskRecords from '@salesforce/apex/TaskRepository.getTaskRecords';
import createTaskRecords from '@salesforce/apex/TaskRepository.createTaskRecords';
import getTaskRecordTypeId from '@salesforce/apex/TaskRepository.getTaskRecordTypeId';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Priority from '@salesforce/schema/Task.Priority';
import Status from '@salesforce/schema/Task.Status';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';

const columns = [
    { label: 'Subject', fieldName: 'taskLink', type: 'url',
    typeAttributes: { label: { fieldName: 'Subject' }, target: '_blank' },initialWidth: 100},
    { label: 'Status', fieldName: 'Status', wrapText: true, initialWidth: 85},
    { label: 'Assigned To', fieldName: 'AssignedTo'},
    { label: 'Due Date',fieldName: 'ActivityDate'}
];
const thisCmpMsgServiceOrigin = 'crdrAuditHistory';
const CRDR_FIELDS = ['Forrester_SHIR_CRDR_VIEW__x.FY__c'];

export default class NewTaskButton extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api externalObjRecIdFieldName;
    @api matchingContainerObject;
    @api containerObjRecIdFieldName;
    containerObjectId;
    ExternalCaseCRDRId;
    containerRcdName;
    currentUserName
    loading = true;
    taskModal = false;
    hasUpcomingRecordsRecords = false;
    hasCompletedRecords = false;
    showUpcomingOverdue = true;
    showCompleted = false;
    priorityOptions = [];
    statusOptions = [];
    upcomingTaskData = [];
    completedTaskData = [];
    upcomingDisplayList = [];
    completedDisplayList = [];
    taskRecdTypeId;
    columns = columns;
    error;
    @track userId = Id;
    @track task = {
        sobjectType: 'Task',
        Subject: '',
        ActivityDate: '',
        Description: '',
        Priority: 'Normal',
        Status: 'Not Started',
        WhatId: '',
        OwnerId: Id,
        Related_Type__c: 'CRDR'
    };
    timeZone = TIME_ZONE;
    @track defaultValue = [{id: Id, title: this.currentUserName, subtitle: ""}];
    showNewTaskButton = false;

    // Wire functions
    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.defaultValue = [{id: Id, title: this.currentUserName, subtitle: ""}];
        } else if (error) {
            this.error = error ;
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: CRDR_FIELDS })
    async getCRDR({ error, data }) {
        if (data) {
            this.showNewTaskButton = !(data.fields.FY__c?.value < '2024');
        }
        if (error) {
            console.error(error);
        }
    }

    @wire(getTaskRecordTypeId,{}) 
    taskRecordTypeId({error, data}) {
        if (data) {
            this.taskRecdTypeId = data;

        } else if (error) {
            this.error = error ;
        }
    }


    @wire(getPicklistValues, {
        recordTypeId: '$taskRecdTypeId', 
        fieldApiName: Priority 
    }) priorityTypeOptions({data, error}) {
        if (data) {
            this.priorityOptions = data.values;
        }
        if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$taskRecdTypeId', 
        fieldApiName: Status 
    }) statusTypeOptions({data, error}) {
        if (data) {
            this.statusOptions = data.values;
        }
        if (error) {
            console.error(error);
        }
    }
    
    @wire(getContainerObjectId, {
        externalObjRecId: '$recordId',
        externalObjApiName: '$objectApiName',
        externalObjRecIdFieldName: '$externalObjRecIdFieldName',
        matchingContainerObject: '$matchingContainerObject',
        containerObjRecIdFieldName:'$containerObjRecIdFieldName'
    })
    async handleLoadData({data, error}) {
        if (data) {
            this.containerObjectId = data.Id;
            this.ExternalCaseCRDRId = data.ExternalCaseCRDRId__c;
            this.containerRcdName = data.Name;
            this.loading = false;
            this.getTasks();
        }
        if (error) {
            console.error(error);
        }
    }

    @wire(MessageContext)
    messageContext;

    async handleNewTaskQuickAction() {
        this.taskModal = true;
    }
    handleSubjectChange(event){
        this.task.Subject = event.target.value;
    }
    handleDueDateChange(event){
        this.task.ActivityDate = event.target.value;
    }
    handleCommentChange(event){
        this.task.Description = event.target.value;
    }
    handlePriorityChange(event){
        this.task.Priority = event.target.value;
    }
    handleStatusChange(event){
        this.task.Status = event.target.value;
    }
    handleSelected(event) {
        if(Object.keys(event.detail).length > 0){
            this.task.OwnerId = event.detail[0].id;
        }
    }

    toggleActivity(event) {
        const expId = event.currentTarget.dataset.id;
        this.template.querySelector(`[data-id="${expId}"]`).classList.toggle('slds-is-open');
        if (this.template.querySelector(`[data-recordid="${expId}"]`).iconName === 'utility:chevronright') {
            this.template.querySelector(`[data-recordid="${expId}"]`).iconName = 'utility:chevrondown';
        } else {
            this.template.querySelector(`[data-recordid="${expId}"]`).iconName = 'utility:chevronright';
        }
    }

    closeModal() {
        this.taskModal = false;
        this.resetFields();
    }
    resetFields() {
        this.task = { 
            sobjectType: 'Task',
            Subject: '',
            ActivityDate: '',
            Description: '',
            Priority: 'Normal',
            Status: 'Not Started',
            WhatId: this.containerObjectId,
            OwnerId: Id,
            Related_Type__c: 'CRDR'
        };
    }

    getTasks(){
        let tempUpcomingTasks = [];
        let tempCompletedTasks = [];
        getTaskRecords({
            PrentId: this.containerObjectId
        })
        .then(records => {
            records.forEach(res => {
                res.taskLink = '/' + res.Id;
                res.AssignedTo = res.Owner.Name;
                res.ownerLink = '/' + res.OwnerId;
                res.showPriorityFlag = res.Priority === 'High';
                if(res.Description != null){
                    res._children = [];
                    res._children.push({Status:res.Description});
                }

                let today = new Date().toLocaleString('en-US', { timeZone: this.timeZone });
                const activityDate = new Date(res.ActivityDate + ' 23:59:00 EST').toLocaleString('en-US', { timeZone: this.timeZone });

                if(new Date(today) > new Date(activityDate) && res.Status !== 'Completed'){
                    res.dateClass = 'slds-timeline__date red-color';
                }
                else{
                    res.dateClass = 'slds-timeline__date black-color';
                }

                if (res.Status === 'Completed') {
                    tempCompletedTasks.push(res);
                }
                else {
                    tempUpcomingTasks.push(res);
                }
            });

            tempUpcomingTasks.sort((a, b) => new Date(a.ActivityDate ?? a.CreatedDate) - new Date(b.ActivityDate ?? b.CreatedDate));
            tempCompletedTasks.sort((a, b) => new Date(a.ActivityDate ?? a.CreatedDate) - new Date(b.ActivityDate ?? b.CreatedDate));
            this.upcomingTaskData = tempUpcomingTasks;
            this.completedTaskData = tempCompletedTasks;
            if(this.upcomingTaskData.length > 0){
                this.hasUpcomingRecordsRecords = true;
            }
            if(this.completedTaskData.length > 0){
                this.hasCompletedRecords = true;
            }
            this.upcomingDisplayList = [...this.upcomingTaskData].splice(0,3);
            this.completedDisplayList = [...this.completedTaskData].splice(0,3);
        })
        .catch(error => {
            console.error('Error getting tasks:', error);
        });
    }

    create() {
        if (!this.task.Subject) {
            this.template.querySelector('[data-id="subject-input"]').reportValidity();
            return;
        }

        this.task.WhatId = this.containerObjectId;
        createTaskRecords({
            tasklist: [this.task]
        })
        .then(() => {
            this.task = { 
                sobjectType: 'Task',
                Subject: '',
                ActivityDate: '',
                Description: '',
                Priority: 'Normal',
                Status: 'Not Started',
                WhatId: this.containerObjectId,
                OwnerId: Id,
                Related_Type__c: 'CRDR'
            };

            const event = new ShowToastEvent({
                title: 'Your Task was created',
                message: '',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.getTasks();
            this.publishTaskAddedMessage();
        })
        .catch(error => {
            console.error('Error creating note:', error);
        });

        this.closeModal();
    }

    // Event Handlers
    handleGotoRelatedList(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Task',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent' 
            }
        });
    }

    handleUpcomingOverdueClick() {
        this.showUpcomingOverdue = !this.showUpcomingOverdue;
    }

    handleCompletedClick() {
        this.showCompleted = !this.showCompleted;
    }

    handleRefreshClick() {
        this.getTasks();
    }

    handleShowMoreUpcoming() {
        this.upcomingDisplayList = this.upcomingTaskData;
    }

    handleShowMoreCompleted() {
        this.completedDisplayList = this.completedTaskData;
    }

    publishTaskAddedMessage() {
        publish(this.messageContext, msgService, {
            origin: thisCmpMsgServiceOrigin,
            statusChanged: false,
            caseCrdrId: this.recordId
        });
    }

    // Getters
    get getUpcomingOverdueIcon() {
        return this.showUpcomingOverdue ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get getCompletedIcon() {
        return this.showCompleted ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get hasMoreUpcomingToShow() {
        return this.upcomingTaskData.length > 3 && this.upcomingDisplayList.length !== this.upcomingTaskData.length;
    }

    get hasMoreCompletedToShow() {
        return this.completedTaskData.length > 3 && this.completedDisplayList.length !== this.completedTaskData.length;
    }
}