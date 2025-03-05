import { LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class UppNotifications extends NavigationMixin(LightningElement) {
  
    navigateToAllNotifications() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'All_Upp_Notifications' 
            },
            state: {
                fromViewAll: 'true'
            }
        });
    }
}