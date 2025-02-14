/**
 * Created by Andreas du Preez on 2024/12/13.
 */

import { api, LightningElement } from "lwc";

// The states below should match the states in the design file in the Datasource property
// TODO: Add more states as needed
// https://www.lightningdesignsystem.com/components/illustration/
const NO_ACCESS_2 = "No Access 2";

export default class Illustration extends LightningElement {

    @api displayMessage;
    @api stateType;

    get isStateNoAccess2() {
        return this.stateType === NO_ACCESS_2;
    }
}