import { LightningElement,track,wire,api } from 'lwc';
import getNotifications from '@salesforce/apex/UPPNotificationController.getUserNotifications';

export default class UppNotificationsTable extends LightningElement {
  @api from;
 
    @track notifications = [];
    isModalOpen=false;
    @track selectedNotification = null;
    columns = [
        { label: 'Business Area', fieldName: 'Business_Area__c', type: 'text' },
        { label: 'Subject', fieldName: 'Subject__c', type: 'button', typeAttributes: { label: { fieldName: 'Subject__c' }, variant: 'base' } },
        { label: 'Sent', fieldName: 'Sent__c', type: 'date' },
        { label: 'Conversation', fieldName: 'Conversation__c', type: 'text' },
        { label: 'User', fieldName: 'UserName', type: 'text', cellAttributes: { class: 'slds-text-title_caps' } }
    ];


  connectedCallback(){
    getNotifications().then(data=>{
        if (data) {
            let notifications = this.from =='parent' ? data.slice(0, 3): data ;
            this.notifications =  notifications.map(notification => ({
                ...notification,
                UserName: notification.User__r ? notification.User__r.Name : 'N/A'
            }));
        }
    }).catch(error=>{
        console.error('Error retrieving notifications', error);
    })
  }
    handleSubjectClick(event) {
        const notificationId = event.currentTarget.dataset.id;
        this.selectedNotification = this.notifications.find(notif => notif.Id === notificationId);
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedNotification = null;
    }
    handleRowAction(event) {
        const notificationId = event.detail.row.Id;
        if (!notificationId) {
            return;
        }
        this.selectedNotification = this.notifications.find(notif => notif.Id === notificationId) || null;
        if (this.selectedNotification) {
            this.isModalOpen = true;
        }
    }

}