import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createTaskRecords from '@salesforce/apex/TaskRepository.createTaskRecords';
import getCRDRRecord from '@salesforce/apex/ExternalObjectRepository.getContainerObjectsByExternalRecid';
import getTaskRecordTypeId from '@salesforce/apex/TaskRepository.getTaskRecordTypeId';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Priority from '@salesforce/schema/Task.Priority';
import Status from '@salesforce/schema/Task.Status';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameField from '@salesforce/schema/User.Name';


export default class CreateTaskForList extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api externalObjRecIdFieldName;
    @api matchingContainerObject;
    @api containerObjRecIdFieldName;
    @api listViewIds;
    containerObjectId;
    currentUserName;
    loading = true;
    priorityOptions = [];
    statusOptions = [];
    data = [];
    taskRecdTypeId;
    error;
    @track defaultCRDRValues = [];
    @track defaultValue = [{ id: Id, title: this.currentUserName, subtitle: '' }];
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

    @track type='success';
    @track message;
    @track showToastBar = false;
    autoCloseTime = 3000;
    variant;


    connectedCallback() {
        if (this.listViewIds) {
            let tempDefaultCRDRValues = [];
            getCRDRRecord({
                externalObjRecIds: this.listViewIds,
                externalObjApiName: 'Forrester_SHIR_CRDR_VIEW__x',
                externalObjRecIdFieldName: 'CASE_CRDR_RECID__c',
                matchingContainerObject: 'Case_CRDR__c',
                containerObjRecIdFieldName: 'ExternalCaseCRDRId__c'
            })
                .then((result) => {
                    result.forEach(res => {
                        tempDefaultCRDRValues.push({ id: res.Id, title: res.Name, subtitle: '' });
                    });
                    this.defaultCRDRValues = tempDefaultCRDRValues;
                    console.log('this.defaultCRDRValues', JSON.parse(JSON.stringify(this.defaultCRDRValues)));
                })
                .catch((error) => {
                    this.error = error;
                    console.error('Error retrieving CRDR Record --->', JSON.parse(JSON.stringify(error)));
                });
        }
    }

    // Wire methods
    @wire(getRecord, { recordId: Id, fields: [UserNameField] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.defaultValue = [{ id: Id, title: this.currentUserName, subtitle: '' }];
        } else if (error) {
            this.error = error;
            console.error('Error retrieving current User --->', JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getTaskRecordTypeId, {})
    taskRecordTypeId({ error, data }) {
        if (data) {
            this.taskRecdTypeId = data;
        } else if (error) {
            this.error = error;
            console.error('Error retrieving current record type Id --->', JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$taskRecdTypeId',
        fieldApiName: Priority
    }) priorityTypeOptions({ data, error }) {
        if (data) {
            this.priorityOptions = data.values;
        }
        if (error) {
            console.error('Error retrieving Priority Options picklist values --->', JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$taskRecdTypeId',
        fieldApiName: Status
    }) statusTypeOptions({ data, error }) {
        if (data) {
            this.statusOptions = data.values;
        }
        if (error) {
            console.error('Error retrieving Status Options picklist values --->', JSON.parse(JSON.stringify(error)));
        }
    }

    // Event handlers
    handleSubjectChange(event) {
        this.task.Subject = event.target.value;
    }

    handleDueDateChange(event) {
        this.task.ActivityDate = event.target.value;
    }

    handleCommentChange(event) {
        this.task.Description = event.target.value;
    }

    handlePriorityChange(event) {
        this.task.Priority = event.target.value;
    }

    handleStatusChange(event) {
        this.task.Status = event.target.value;
    }

    handleSelected(event) {
        if (Object.keys(event.detail).length > 0) {
            this.task.OwnerId = event.detail[0].id;
        }
    }

    handleSelectedCRDR(event) {
        if (Object.keys(event.detail).length > 0) {
            this.defaultCRDRValues = event.detail;
        }
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

    async createTasks(){
        let tasksToCreate = [];
        this.defaultCRDRValues.forEach(res => {
            tasksToCreate.push({ ...this.task, WhatId: res.id });
        });
        const result = await createTaskRecords({
            tasklist: tasksToCreate
        });

        if(result === 'Success'){
            this.variant ="success";
            this.showToast('success','Your Tasks were created','3000');
        }else{
            this.variant ="error";
            this.showToast('error','Failed to create Tasks','3000');
            console.error('Error creating note:', JSON.stringify(result));
        }

    }


    showToast(type, message,time) {
        this.type = type;
        this.message = message;
        this.autoCloseTime=time;
        this.showToastBar = true;
        if(type === 'success'){
            setTimeout(() => {
                this.closeModal();
            }, this.autoCloseTime);
        }else{
            setTimeout(() => {
            }, this.autoCloseTime);
        }

    }


    closeModal() {
        this.resetFields();
        window.history.back();
    }

    get getIconName() {
  
      return this.variant === "success" ? "utility:success" : "utility:error";
    }

    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-m-right_small slds-no-flex slds-align-top';
    }
 
    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }
}