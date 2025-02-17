import { LightningElement, track, wire } from "lwc";
import getApexData from '@salesforce/apex/BipRequestController.createBIPReq';
import uploadFileInBipRequest from '@salesforce/apex/BipRequestController.uploadFileInBipRequest';
import getKualiResponseByProposalId from '@salesforce/apex/BipRequestController.getKualiResponseByProposalId';
import createBipPis from '@salesforce/apex/BipRequestController.createBipPis';
import { jitGetCreateContact } from 'c/utils';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import searchAccounts from '@salesforce/apex/BipRequestController.searchAccounts';
import queryCases from '@salesforce/apex/BipCreateCaseJunction.queryCases'
import CATEGORY_FIELD from '@salesforce/schema/BIP_Request__c.Category__c';
import getResponseForAccountCreations from '@salesforce/apex/BipRequestController.getResponseForAccountCreations'
import { getFocusedTabInfo, closeTab, setTabLabel, setTabIcon, getAllTabInfo } from "lightning/platformWorkspaceApi";
import { NavigationMixin } from "lightning/navigation";

const BIP_REQUEST_OBJECT = 'BIP_Request__c';
const NEW_BIP_LIGHTNING_TAB_NAME = 'New_BIP';
const TAB_LABEL = 'New BIP Request';

export default class Request extends NavigationMixin(LightningElement) {
    fileData = null;
    showRequestorItemDropdown = false;
    recordSuccess = false;
    ccEmail = '';
    additionalAccountData = {};

    successData = 'Record Created Successfully!';
    recordFailed = false;
    failedData = '';
    showPrimaryPiDropdown = false;
    showDropdownAdditionalPi = false;
    @track additionalPiList = [];
    additionalAccountMapping = {};
    primaryPiMitIdsKC = [];
    bipString = '';
    additionalPis = [];
    additionalAccountResponses = {};
    requestor = '';
    @track requestorRecordItems = [];
    @track primaryPiRecordItems = [];
    selectedAccountForRequestor = '';
    @track additionalItems = [];
    primaryPiAccountRes = {};
    requestType = 'Standard';
    dueDate = '';
    accountMitMapping = {};
    category = '';
    bipPis = [];
    proposalResponseResults = [];
    requestorSearchedString = '';
    searchedAdditionalPiItem = '';
    selectedPrimaryPiAcc = '';
    requestorAccountData = {};
    recordTypeSelected = '';
    recordTypeSelectionVisible = true;
    deatailSectionVisible = false;
    nextDisabled = true;
    isNonKCPraposal = false;
    primaryPi = '';
    isPillVisible = true;
    sponsor = '';
    isFieldValuesRecieved = true;
    ospContact = '';
    projectTitle = '';
    primaryPiLookup = '';
    isLoading = false;
    @track fileItems = [];
    searchTimeout;
    selectedPropNumber = '';
    categoryOptions = [];
    recordTypeID = '';
    @track ccEmailsList = [
    ];
    ccData = [];
    nonKCProposalRecordTypeId = '';
    kcProposalRecordTypeId = '';
    ProposalNumberMapping = {};
    showProposalDropdown = '';
    searchedProposalValue = '';
    @track proposalRecords = [];

    @wire(getObjectInfo, { objectApiName: 'BIP_Request__c' })
    wiredRecordTypeFunction({ error, data }) {
        if (data) {
            let objArray = data.recordTypeInfos;
            for (let i in objArray) {
                if (objArray[i].name == "KC Proposal") {
                    this.kcProposalRecordTypeId = objArray[i].recordTypeId;
                }

                if (objArray[i].name == "Non-KC Proposal") {
                    this.nonKCProposalRecordTypeId = objArray[i].recordTypeId;
                }
            }
            this.recordTypeID = this.kcProposalRecordTypeId;

        } else if (error) {
            console.log(JSON.stringify(error));
        }
    };
    @wire(getPicklistValues, { recordTypeId: '$recordTypeID', fieldApiName: CATEGORY_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) {
            console.log('isNonKC' + this.isNonKCPraposal);
            this.categoryOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
            console.log(this.categoryOptions);
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }
    checkAndAssignPI() {
        let bipNameList = [];
        for (let i = 0; i < this.bipPis.length; i++) {
            if (!!this.bipPis[i].personRole && this.bipPis[i].personRole == 'PI') {
                this.primaryPiMitIdsKC.push({ mitId: this.bipPis[i].mitId });
                this.primaryPi = this.bipPis[i].personName;
            }
            if (!(!!this.bipPis[i].personRole) || this.bipPis[i].personRole != 'PI') {
                bipNameList.push(this.bipPis[i].personName);
            }
        }
        this.bipString = bipNameList.join(',');
    }
    handleCategoryChange(event) {
        this.category = event.detail.value;
    }
    clearProposalNumberFields() {
        this.primaryPi = '';
        this.sponsor = '';
        this.projectTitle = '';
        this.ospContact = '';
        this.bipString = '';
    }

    handleItemRemoveFile() {
        if (this.fileItems.length != 0) {
            this.fileItems.pop();
            this.fileData = null;
        }
    }

    handleCCEmailChange(event) {
        this.ccEmail = event.detail.value;
    }
    handleItemRemoveCC(event) {
        let index = event.detail.index;
        this.ccEmailsList.splice(index, 1);
        this.ccData.splice(index, 1);
    }
    handleOnBlurCC(event) {
        let ccVal = this.ccEmail;
        console.log(ccVal);
        this.ccEmailsList.push({
            label: ccVal
        });
        this.ccData.push(ccVal);
        this.ccEmail = '';
    }

    personAccountfilter = {
        criteria: [
            {
                fieldPath: 'RecordType.Name',
                operator: 'eq',
                value: 'Person Account',
            },
        ],
    };
    sponserAccountfilter = {
        criteria: [
            {
                fieldPath: 'RecordType.Name',
                operator: 'eq',
                value: 'Sponsor, KC',
            },
            {
                fieldPath: 'RecordType.Name',
                operator: 'eq',
                value: 'Sponsor, Non-KC',
            },
        ],
        filterLogic: '1 OR 2',
    };

    connectedCallback() {
        // Format the date as YYYY-MM-DD (Salesforce Date Format)
        // Set the tab label and icon
        getAllTabInfo().then((tabs) => {
            tabs.forEach((tab) => {
                if (tab?.pageReference?.attributes?.apiName === NEW_BIP_LIGHTNING_TAB_NAME)
                    this.setTabLabelAndIcon(tab.tabId);
                // Set the tab label and icon for subtabs
                tab.subtabs.forEach((subtab) => {
                    if (subtab?.pageReference?.attributes?.apiName === NEW_BIP_LIGHTNING_TAB_NAME)
                        this.setTabLabelAndIcon(subtab.tabId);
                });
            });
        });
    }


    handleClose() {
        this.recordTypeSelectionVisible = false;
        this.isLoading = false;

        // Close this tab and navigate back to Recent BIP Requests
        getFocusedTabInfo().then((tabInfo) => {
            closeTab(tabInfo.tabId);

            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: BIP_REQUEST_OBJECT,
                    actionName: "list"
                },
                state: {
                    filterName: "Recent"
                },
            });
        });
    }
    // Options for the Request Type radio group
    requestTypeOptions = [
        { label: 'Standard', value: 'Standard' },
        { label: 'Expedited', value: 'Expedited' },
    ];

    // Options for the Request Type
    recordTypeOptions = [
        { label: 'KC Proposal', value: 'KC Proposal' },
        { label: 'Non-KC Proposal', value: 'Non-KC Proposal' },
    ];

    handleRecordTypeChange(event) {
        //clearing all inputs
        this.searchedProposalValue = '';
        this.primaryPi = '';
        this.sponsor = '';
        this.projectTitle = '';
        this.ospContact = '';
        this.ccEmailsList = [];
        this.requestor = '';
        this.requestorSearchedString = '';
        this.requestType = 'Standard';
        this.dueDate = '';
        this.fileData = null;
        this.fileItems = [];
        this.comments = '';
        this.proposalResponseResults = [];
        this.searchedPrimaryPiString = '';
        this.showRequestorItemDropdown = false;
        this.showDropdownAdditionalPi = false;
        this.showPrimaryPiDropdown = false;
        this.recordTypeSelected = event.target.value;
        this.nextDisabled = false;
        if (this.recordTypeSelected == 'Non-KC Proposal') {
            this.isNonKCPraposal = true;
        }
    }

    handleNext() {
        this.recordTypeSelectionVisible = false;
        this.deatailSectionVisible = true;
        let dateString = new Date();
        dateString.setDate(dateString.getDate() + 21); // Add 3 Weeks
        this.dueDate = dateString.toISOString().split('T')[0];
        this.recordTypeID = this.isNonKCPraposal ? this.nonKCProposalRecordTypeId : this.kcProposalRecordTypeId;
    }

    // Handle input field changes
    handleInputChange(event) {
        const field = event.target.label.toLowerCase().replace(' ', '');
        this[field] = event.target.value;
    }

    // Handle request type change
    handleRequestTypeChange(event) {
        let dateString = new Date();
        this.requestType = event.detail.value;
        if (this.requestType == 'Standard') {
            dateString.setDate(dateString.getDate() + 21); // Add 3 Weeks
        }
        else if (this.requestType == 'Expedited') {
            dateString.setDate(dateString.getDate() + 7); // Add 1 Week
        }
        this.dueDate = dateString.toISOString().split('T')[0];
    }
    handleProjectTitleChange(event) {
        this.projectTitle = event.target.value;
    }
    handleSponsorChange(event) {
        this.sponsor = event.target.value;
    }
    handleOspContactChange(event) {
        this.ospContact = event.target.value;
    }
    // Handle Save button click
    async handleSave() {
        this.isLoading = true;
        if (this.selectedAccountForRequestor != '') {
            if (this.requestorAccountData[this.selectedAccountForRequestor]['from'] == 'GetPerson') {
                this.requestor = this.requestorAccountData[this.selectedAccountForRequestor]['Id'];
            }
            else {
                let accountResult = await jitGetCreateContact(this.requestorAccountData[this.selectedAccountForRequestor]['apiResponse']);
                this.requestor = JSON.parse(JSON.stringify(accountResult)).data.Id;
            }
        }

        if (this.isNonKCPraposal) {
            if (this.selectedPrimaryPiAcc != '') {
                if (this.primaryPiAccountRes[this.selectedPrimaryPiAcc]['from'] == 'GetPerson') {
                    this.primaryPiLookup = this.primaryPiAccountRes[this.selectedPrimaryPiAcc]['Id'];
                }
                else {
                    let accountResult = await jitGetCreateContact(this.primaryPiAccountRes[this.selectedPrimaryPiAcc]['apiResponse']);
                    this.primaryPiLookup = JSON.parse(JSON.stringify(accountResult)).data.Id;
                }

            }
        }
        if (this.primaryPiMitIdsKC.length > 0) {
            let Methodresponse = await getResponseForAccountCreations({ bipPis: this.primaryPiMitIdsKC });

            if (!!Methodresponse[0]) {
                let accountResult = await jitGetCreateContact(Methodresponse[0][0][0]);
                this.primaryPiLookup = JSON.parse(JSON.stringify(accountResult)).data.Id;
            }
        }
        if (this.isNonKCPraposal) {
            this.primaryPi = this.searchedPrimaryPiString;
        }
        if (this.duedate == undefined) {
            this.duedate = this.dueDate;
        }
        let ccCorrespondence = 'NA';
        if (this.ccData.length != 0) {
            ccCorrespondence = this.ccData.join(',');
        }
        if (this.selectedPropNumber == '' && this.proposalResponseResults.length > 1) {
            this.searchedProposalValue = '';
        }

        let bipObj = {
            Primary_PI__c: this.primaryPi,
            Category__c: this.category,
            Sponsor_Name_Text__c: this.sponsor,
            //ospContact: this.ospcontact,
            proposal: this.searchedProposalValue,
            Requestor_Name__c: this.requestor,
            Proposal_Number__c: this.searchedProposalValue,
            OSP_Contact__c: (this.ospContact).toString(),
            Request_Type__c: this.requestType,
            Due_Date__c: this.duedate,
            Project_Description__c: this.projectdescription,
            Project_Title__c: this.projectTitle,
            Comments__c: this.comments,
            email_CCs__c: ccCorrespondence == 'NA' ? '' : ccCorrespondence,
            Primary_PI_Lookup__c: this.primaryPiLookup
        };

        getApexData({
            bipRequest: bipObj,
            recordType: this.recordTypeSelected
        })
            .then(async saveBipResult => {



                if (saveBipResult) {
                    this.isLoading = false;
                    if (this.additionalPis.length > 0) {
                        for (let i = 0; i < this.additionalPis.length; i++) {
                            let response = this.additionalAccountData[this.additionalPis[i].mitId];
                            if (response['from'] == 'GetPerson') {
                                this.additionalAccountResponses[response['MitId']] = response['Id'];
                            }
                            else {
                                let accRes = await jitGetCreateContact(response['apiResponse']);
                                this.additionalAccountResponses[response['MitId']] = JSON.parse(JSON.stringify(accRes)).data.Id
                            }
                        }
                        let additionalBipResponse = await createBipPis({ bipPis: this.additionalPis, bipReqId: saveBipResult, accountData: this.additionalAccountResponses });
                        console.log(additionalBipResponse);
                    }
                    getResponseForAccountCreations({ bipPis: this.bipPis }).then(async Methodresponse => {
                        for (let i = 0; i < this.bipPis.length; i++) {
                            let accountResult = await jitGetCreateContact(Methodresponse[i][0][0]);
                            this.accountMitMapping[Methodresponse[i][1]] = JSON.parse(JSON.stringify(accountResult)).data.Id;
                        }
                        console.log('this.accountMitMapping' + JSON.stringify(this.accountMitMapping));
                        let responseData = await createBipPis({ bipPis: this.bipPis, bipReqId: saveBipResult, accountData: this.accountMitMapping });
                        console.log('response-' + responseData)
                        queryCases({ recId: saveBipResult }).then(queryResponse => {
                            console.log('response---' + queryResponse);
                        })
                    }).catch(ee => {
                        console.log('err in getResponseForAccountCreations' + ee);
                    });
                    this.recordSuccess = true;

                    //  Close the tab and navigate to the record page
                    getFocusedTabInfo().then((tabInfo) => {
                        closeTab(tabInfo.tabId);
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: saveBipResult,
                                objectApiName: BIP_REQUEST_OBJECT,
                                actionName: 'view'
                            },
                        });
                    });
                }
                if (this.fileData) {
                    const { base64, filename } = this.fileData;
                    uploadFileInBipRequest({ base64, filename, saveBipResult }).then(fileSaveResult => {
                        console.log(fileSaveResult);
                        this.fileData = null;
                    }).catch(e => {
                        console.log('fileerror-' + e);
                    });
                }

            }).catch(e => {
                this.recordFailed = true;
                this.failedData = 'Can\'t Save The Record';
            });
    }

    // Handle Cancel button click
    handlePrevious() {
        this.recordTypeSelected = '';
        this.isNonKCPraposal = false;
        this.recordTypeSelectionVisible = true;
        this.deatailSectionVisible = false;
    }

    handleFilesChange(event) {
        if (event.target.files.length != 0) {

            const file = event.target.files[0];
            var reader = new FileReader();
            reader.onload = () => {
                var base64 = reader.result.split(',')[1];
                this.fileData = {
                    'filename': file.name,
                    'base64': base64,
                };
                this.fileItems.push({
                    label: file.name,
                }
                );
            }
            reader.readAsDataURL(file)
        }
    }

    handleAlertClose() {
        this.recordFailed = false;
    }
    handleRequestorSearchChange(event) {
        const searchValue = event.target.value;

        // Clear any previously set timeout
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout);
        }

        // Set a new timeout to delay search execution
        this.searchTimeout = setTimeout(() => {
            this.requestorSearch(searchValue);
        }, 1000);
    }


    requestorSearch(searchValue) {
        this.showDropdownAdditionalPi = false;
        this.requestorRecordItems = [];

        this.requestorSearchedString = searchValue;
        if (this.requestorSearchedString == '') {
            this.requestorRecordItems = [];
            this.showRequestorItemDropdown = false;
        }
        if (this.requestorSearchedString.length > 1) {
            this.isLoading = true;
            this.requestorRecordItems = [];
            searchAccounts({ searchParam: this.requestorSearchedString }).then(requestorResponse => {

                let mapSize = 0;
                for (const key in requestorResponse) {
                    mapSize = mapSize + 1;
                    this.requestorAccountData = requestorResponse;

                    if (!this.requestorRecordItems.includes({ label: requestorResponse[key]['Name'], value: key })) {
                        let personDescription = requestorResponse[key]['personEmail'] ?? '' + (requestorResponse[key]['personTitle']?.length > 0 ? ' • ' + requestorResponse[key]['personTitle'] : '') + (requestorResponse[key]['personDepartment']?.length > 0 ? ', ' + requestorResponse[key]['personDepartment'] : '');
                        this.requestorRecordItems.push({ label: requestorResponse[key]['Name'], value: key, fromPersonAccounts: requestorResponse[key]['from'] === 'GetPerson', personDescription: personDescription });
                    }
                }

                if (mapSize > 0) {
                    this.showRequestorItemDropdown = true;
                }
                else {
                    this.showRequestorItemDropdown = false;
                }
                this.isLoading = false;
            })
        }
    }

    handleRequestorItemClick(event) {
        let mitID;
        const element = event.target.closest('[data-id]');
        if (element) {
            const dataId = element.getAttribute('data-id');
            mitID = dataId;
            this.selectedAccountForRequestor = mitID;
            this.requestorSearchedString = this.requestorAccountData[mitID].Name;
        }
        this.showRequestorItemDropdown = false;
    }

    handleSearchChangeInProposalNumber(event) {


        const searchValue = event.target.value;
        // Clear any previously set timeout
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout);
        }

        // Set a new timeout to delay search execution
        this.searchedProposalValue = searchValue;
        if (!this.isNonKCPraposal) {
            this.searchTimeout = setTimeout(() => {
                this.searchInProposalNumber(searchValue);
            }, 1000);
        }
    }


    searchInProposalNumber(searchedProposalNumber) {
        this.showDropdownAdditionalPi = false;
        this.showRequestorItemDropdown = false;
        this.showPrimaryPiDropdown = false;

        this.proposalRecords = [];


        if (this.searchedProposalValue == '') {
            this.proposalRecords = [];
            this.showProposalDropdown = false;

        }
        if (this.searchedProposalValue.length > 2) {

            this.isLoading = true;
            this.proposalRecords = [];
            this.isLoading = true;
            getKualiResponseByProposalId({ proposalId: this.searchedProposalValue }).then(ResponseByProposalId => {
                if (ResponseByProposalId.results != undefined) {
                    this.proposalResponseResults = ResponseByProposalId.results;

                    for (let i = 0; i < ResponseByProposalId.results.length; i++) {
                        let num = ResponseByProposalId.results[i].proposalNumber;
                        this.proposalRecords.push({
                            label: num, value: num, title: ResponseByProposalId.results[i].title
                        })
                        this.ProposalNumberMapping[num] = ResponseByProposalId.results[i];

                    }
                    this.showProposalDropdown = true;
                }
                this.isLoading = false;
            }).catch(err => {
                this.recordFailed = true;
                this.clearProposalNumberFields();
                this.failedData = 'Provide Correct Proposal Number';
            }
            )
        }
        else {
            this.clearProposalNumberFields();
        }
    }

    handleProposalNumberClick(event) {
        const element = event.target.closest('[data-id]');
        if (element) {
            const dataId = element.getAttribute('data-id');
            this.selectedPropNumber = dataId;
            this.searchedProposalValue = dataId;
            if (this.selectedPropNumber != '') {
                let sponsorName = this.ProposalNumberMapping[this.selectedPropNumber].sponsorName;
                let title = this.ProposalNumberMapping[this.selectedPropNumber].title;
                this.sponsor = sponsorName == undefined ? '' : sponsorName;
                this.projectTitle = title == undefined ? '' : title;

                this.bipPis = this.ProposalNumberMapping[this.selectedPropNumber].people;
            }
            this.showProposalDropdown = false;
            this.checkAndAssignPI();
        }
    }


    handlePrimaryPiSearchChange(event) {
        const searchValue = event.target.value;

        // Clear any previously set timeout
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout);
        }

        // Set a new timeout to delay search execution
        this.searchTimeout = setTimeout(() => {
            this.primaryPiSearch(searchValue);
        }, 1000);
    }

    primaryPiSearch(searchValue) {
        this.primaryPiRecordItems = [];
        this.showPrimaryPiDropdown = false;
        this.searchedPrimaryPiString = searchValue;

        if (this.searchedPrimaryPiString == '') {
            this.primaryPiRecordItems = [];
            this.showPrimaryPiDropdown = false;
        }

        if (this.searchedPrimaryPiString.length > 1) {
            this.isLoading = true;
            this.primaryPiRecordItems = [];
            searchAccounts({ searchParam: this.searchedPrimaryPiString }).then(primaryPiSearchResponse => {
                let mapSize = 0;
                for (const key in primaryPiSearchResponse) {
                    mapSize = mapSize + 1;
                    this.primaryPiAccountRes = primaryPiSearchResponse;
                    if (!this.primaryPiRecordItems.includes({ label: primaryPiSearchResponse[key]['Name'], value: key })) {
                        let personDescription = primaryPiSearchResponse[key]['personEmail'] ?? '' + (primaryPiSearchResponse[key]['personTitle']?.length > 0 ? ' • ' + primaryPiSearchResponse[key]['personTitle'] : '') + (primaryPiSearchResponse[key]['personDepartment']?.length > 0 ? ', ' + primaryPiSearchResponse[key]['personDepartment'] : '');
                        this.primaryPiRecordItems.push({ label: primaryPiSearchResponse[key]['Name'], value: key, fromPersonAccounts: primaryPiSearchResponse[key]['from'] === 'GetPerson', personDescription: personDescription });
                    }
                }
                if (mapSize > 0) {
                    this.showPrimaryPiDropdown = true;
                }
                else {
                    this.showPrimaryPiDropdown = false;
                }
                this.isLoading = false;
            })
        }
    }

    handlePrimaryPiItemClick(event) {

        let mitID;
        const element = event.target.closest('[data-id]');
        if (element) {
            const dataId = element.getAttribute('data-id');
            mitID = dataId;
            this.selectedPrimaryPiAcc = mitID;
            this.searchedPrimaryPiString = this.primaryPiAccountRes[mitID].Name;
        }
        this.showPrimaryPiDropdown = false;
    }




    handleAdditionalPiSearchChange(event) {
        const searchValue = event.target.value;

        // Clear any previously set timeout
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout);
        }

        // Set a new timeout to delay search execution
        this.searchTimeout = setTimeout(() => {
            this.additionalPiSearch(searchValue);
        }, 1000);

    }

    additionalPiSearch(searchValue) {
        this.showRequestorItemDropdown = false;
        this.showPrimaryPiDropdown = false;
        this.showProposalDropdown = false;

        this.additionalItems = [];

        this.searchedAdditionalPiItem = searchValue;
        if (this.searchedAdditionalPiItem == '') {
            this.additionalItems = [];
            this.showDropdownAdditionalPi = false;
        }

        if (this.searchedAdditionalPiItem.length > 1) {

            this.isLoading = true;
            this.additionalItems = [];
            searchAccounts({ searchParam: this.searchedAdditionalPiItem }).then(async accountSearchedResponse => {
                this.additionalAccountMapping = accountSearchedResponse;
                let mapSize = 0;
                for (const key in accountSearchedResponse) {
                    mapSize = mapSize + 1;
                    this.additionalAccountData[accountSearchedResponse[key]['MitId']] = accountSearchedResponse[key];
                    if (!this.additionalItems.includes({ label: accountSearchedResponse[key]['Name'], value: key })) {
                        let personDescription = accountSearchedResponse[key]['personEmail'] ?? '' + (accountSearchedResponse[key]['personTitle']?.length > 0 ? ' • ' + accountSearchedResponse[key]['personTitle'] : '') + (accountSearchedResponse[key]['personDepartment']?.length > 0 ? ', ' + accountSearchedResponse[key]['personDepartment'] : '');
                        this.additionalItems.push({ label: accountSearchedResponse[key]['Name'], value: key, fromPersonAccounts: accountSearchedResponse[key]['from'] === 'GetPerson', personDescription: personDescription });
                    }
                }

                if (mapSize > 0) {
                    this.showDropdownAdditionalPi = true;
                }
                else {
                    this.showDropdownAdditionalPi = false;
                }
                this.isLoading = false;
            })
        }
    }


    handleAdditionalPiItemRemove(event) {
        let index = event.detail.index;
        this.additionalPis.splice(index, 1);
        this.additionalPiList.splice(index, 1);
        this.isPillVisible = this.additionalPiList.length == 0 ? false : true;
    }


    handleAdditionalItemClick(event) {
        console.log('called');

        let mitID;


        const element = event.target.closest('[data-id]');
        if (element) {
            const dataId = element.getAttribute('data-id');
            mitID = dataId;
            this.additionalPis.push({ 'mitId': mitID });
            this.searchedAdditionalPiItem = this.additionalAccountMapping[mitID].Name;
            let found = false;
            for (let i = 0; i < this.additionalPiList.length; i++) {
                if (this.additionalPiList[i].label == this.searchedAdditionalPiItem) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                console.log({ label: this.searchedAdditionalPiItem });
                this.additionalPiList.push({
                    label: this.searchedAdditionalPiItem
                }
                );
            }
            this.isPillVisible = this.additionalPiList.length == 0 ? false : true;
            this.searchedAdditionalPiItem = '';
        }
        console.log('log-' + JSON.stringify(this.additionalPiList));
        this.showDropdownAdditionalPi = false;

    }





    setTabLabelAndIcon(tabId) {
        setTabLabel(tabId, TAB_LABEL);
        setTabIcon(tabId, ``);
    }

}