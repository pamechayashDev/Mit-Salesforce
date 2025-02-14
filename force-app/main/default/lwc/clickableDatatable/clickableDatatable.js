import LightningDatatable from 'lightning/datatable';
import onclickRow from './clickableDatatable.html';
export default class ClickableDatatable extends LightningDatatable {
    static customTypes = {
        clickrow: {
            template: onclickRow,
            typeAttributes: ['label', 'iconName'],
        }
    };

}