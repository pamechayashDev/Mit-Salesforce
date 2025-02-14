/**
 * Created by Andreas du Preez on 2024/07/31.
 */

import LightningDatatable from "lightning/datatable";
import customUrlOrTextType from "./customUrlOrTextType.html";

export default class PersonIpiaListDatatable extends LightningDatatable {
    static customTypes = {
        customUrlOrTextType: {
            template: customUrlOrTextType,
            standardCellLayout: true,
            typeAttributes: ["isUrl", "value", "target", "label"],
        }
        // Other custom types here
    };
}