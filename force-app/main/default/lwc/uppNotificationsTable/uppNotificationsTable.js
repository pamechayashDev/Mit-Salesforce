import { LightningElement,track,wire,api } from 'lwc';
import getNotifications from '@salesforce/apex/UPPNotificationController.getUserNotifications';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class UppNotificationsTable extends LightningElement {
  @api from;
   isParent = false;
    dateFrom = null;
    dateTo = null;
    showArchived = false;
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

    getNotificationData(){
        console.log('showArchived'+this.showArchived);
        getNotifications(
            {
            dateFrom: this.dateFrom,
           dateTo: this.dateTo ,
           showArchived: this.showArchived }
        ).then(data=>{
            if (data) {
                
                let notifications = this.from =='parent' ? data.slice(0, 3): data ;
                this.notifications =  notifications.map(notification => ({
                    ...notification,
                    UserName: notification.User__r ? notification.User__r.Name : 'N/A'
                }));
                console.log(JSON.stringify(data));
            }
        }).catch(error=>{
            console.error('Error retrieving notifications', error);
        })
    }

  connectedCallback(){
    this.isParent =  this.from =='parent' ? true: false; 
   this.getNotificationData();
  }



  handleChange(event) {
    const { name, value, checked } = event.target;
    if (name === 'showArchived') {
        this.showArchived = checked;
 
    }  else if (name === 'dateFrom') {
        const today = new Date().toISOString().split('T')[0];
        value > today ? this.showToast('Error', 'From Date cannot be in the future', 'error'): this.dateFrom = value;
     
    } else {
        this[name] = value;
    }
}



  applyFilters() {
    getNotifications({ 
        dateFrom: this.dateFrom,
       dateTo: this.dateTo ,
       showArchived: this.showArchived}).then(data=>{
        if (data) {
            
            let notifications = this.from =='parent' ? data.slice(0, 3): data ;
            this.notifications =  notifications.map(notification => ({
                ...notification,
                UserName: notification.User__r ? notification.User__r.Name : 'N/A'
            }));
          this.isParent =  this.from =='parent' ? true: false; 
        }
    }).catch(error=>{
        console.error('Error retrieving notifications', error);
    })
}

clearFilters() {
    this.dateFrom = null;
    this.dateTo = null;
    this.showArchived = false;
    this.getNotificationData();
}



    handleSubjectClick(event) {
        const notificationId = event.currentTarget.dataset.id;
        this.selectedNotification = this.notifications.find(notif => notif.Id === notificationId);
        this.isModalOpen = true;
    }

   
    handleRowAction(event) {
        const notificationId = event.detail.row.Id;
        if (!notificationId) {
            console.error("Notification ID is missing");
            return;
        }
        this.selectedNotification = this.notifications.find(notif => notif.Id === notificationId) || null;
        if (this.selectedNotification) {
            this.isModalOpen = true;
        }
    }
    closeModal() {
        this.isModalOpen = false;
        this.selectedNotification = null;
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

}