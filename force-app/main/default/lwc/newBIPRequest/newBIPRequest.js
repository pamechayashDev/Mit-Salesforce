import { LightningElement, track, wire } from "lwc";
import getApexData from '@salesforce/apex/BipRequestController.createBIPReq';
import getKualiResponseByProposalId from '@salesforce/apex/BipRequestController.getKualiResponseByProposalId';
import { jitGetCreateContact, peopleSearch } from 'c/utils';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CATEGORY_FIELD from '@salesforce/schema/BIP_Request__c.Category__c';
import { getFocusedTabInfo, closeTab, setTabLabel, setTabIcon, getAllTabInfo, openTab } from "lightning/platformWorkspaceApi";
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
    selectedAdditionalAccountMapping = {};
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
            this.categoryOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
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
        this.additionalPis = [];
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
            let accountResult = await jitGetCreateContact(this.requestorAccountData[this.selectedAccountForRequestor]);
            this.requestor = JSON.parse(JSON.stringify(accountResult)).data.Id;

        }

        if (this.isNonKCPraposal) {
            if (this.selectedPrimaryPiAcc != '') {
                let accountResult = await jitGetCreateContact(this.primaryPiAccountRes[this.selectedPrimaryPiAcc]);
                this.primaryPiLookup = JSON.parse(JSON.stringify(accountResult)).data.Id;
            }
        }
        if (this.primaryPiMitIdsKC.length > 0) {

            let methodResponse = await peopleSearch(this.primaryPiMitIdsKC[0].mitId);

            let accountResult = await jitGetCreateContact(methodResponse['searchResults'][0]);
            this.primaryPiLookup = JSON.parse(JSON.stringify(accountResult)).data.Id;

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


        if (this.additionalPis.length > 0) {
            for (let i = 0; i < this.additionalPis.length; i++) {
                let response = this.selectedAdditionalAccountMapping[this.additionalPis[i].mitId];
                let accRes = await jitGetCreateContact(response);
                this.additionalAccountResponses[response['mitId']] = JSON.parse(JSON.stringify(accRes)).data.Id
            }
        }

        for (let i = 0; i < this.bipPis.length; i++) {
            let personResponsebyMit = await peopleSearch(this.bipPis[i].mitId);
            if (personResponsebyMit['searchResults'].length != 0) {
                let accountResult = await jitGetCreateContact(personResponsebyMit['searchResults'][0]);
                this.accountMitMapping[personResponsebyMit['searchResults'][0].mitId] = JSON.parse(JSON.stringify(accountResult)).data.Id;
            }
        }

        let allBipPis = [...this.additionalPis, ...this.bipPis];
        let allAccountData = { ...this.additionalAccountResponses, ...this.accountMitMapping };
        let base64 = '';
        let filename = '';
        if (this.fileData != null) {
            base64 = this.fileData.base64;
            filename = this.fileData.filename;
        }
        getApexData({
            bipRequest: bipObj,
            recordType: this.recordTypeSelected,
            bipPis: allBipPis,
            accountData: allAccountData,
            fileBase64: base64,
            fileName: filename
        })
            .then(async saveBipResult => {

                if (saveBipResult) {
                    this.isLoading = false;
                    this.recordSuccess = true;
                    //  Close the tab and navigate to the record page
                    getFocusedTabInfo().then((tabInfo) => {
                        let closeTabId = tabInfo.tabId;
                        openTab({ recordId: saveBipResult, focus: true }).then(() => {
                            closeTab(closeTabId);
                        }).catch(error => {
                            console.error('Error opening or closing tab:', error);
                        });
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
        if (this.requestorSearchedString.length > 2) {
            this.isLoading = true;
            this.requestorRecordItems = [];


            peopleSearch(this.requestorSearchedString).then(requestorResponse => {
                let mapSize = 0;
                this.requestorAccountData = requestorResponse['searchResults'].reduce((modified, obj) => {
                    modified[obj.mitId] = obj;
                    return modified;
                }, {});
                for (const key in this.requestorAccountData) {
                    mapSize = mapSize + 1;
                    if (!this.requestorRecordItems.includes({ label: this.requestorAccountData[key]['name'], value: key })) {
                        let personDescription = this.requestorAccountData[key]['email'] ?? '' + (this.requestorAccountData[key]['personTitle']?.length > 0 ? ' • ' + this.requestorAccountData[key]['personTitle'] : '') + (this.requestorAccountData[key]['personDepartment']?.length > 0 ? ', ' + this.requestorAccountData[key]['personDepartment'] : '');
                        this.requestorRecordItems.push({ label: this.requestorAccountData[key]['name'], value: key, personDescription: personDescription });
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
            this.requestorSearchedString = this.requestorAccountData[mitID].name;
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

        if (this.searchedPrimaryPiString.length > 2) {
            this.isLoading = true;
            this.primaryPiRecordItems = [];
            peopleSearch(this.searchedPrimaryPiString).then(primaryPiSearchResponse => {
                let mapSize = 0;
                this.primaryPiAccountRes = primaryPiSearchResponse['searchResults'].reduce((modified, obj) => {
                    modified[obj.mitId] = obj;
                    return modified;
                }, {});
                for (const key in this.primaryPiAccountRes) {
                    mapSize = mapSize + 1;
                    //    if (!this.primaryPiRecordItems.includes({ label: this.primaryPiAccountRes[key]['name'], value: key })) {
                    let personDescription = this.primaryPiAccountRes[key]['email'] ?? '' + (this.primaryPiAccountRes[key]['personTitle']?.length > 0 ? ' • ' + this.primaryPiAccountRes[key]['personTitle'] : '') + (this.primaryPiAccountRes[key]['personDepartment']?.length > 0 ? ', ' + this.primaryPiAccountRes[key]['personDepartment'] : '');
                    this.primaryPiRecordItems.push({ label: this.primaryPiAccountRes[key]['name'], value: key, personDescription: personDescription });
                    // }
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
            this.searchedPrimaryPiString = this.primaryPiAccountRes[mitID].name;
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

        if (this.searchedAdditionalPiItem.length > 2) {

            this.isLoading = true;
            this.additionalItems = [];


            peopleSearch(this.searchedAdditionalPiItem).then(accountSearchedResponse => {
                let mapSize = 0;
                this.additionalAccountMapping = accountSearchedResponse['searchResults'].reduce((modified, obj) => {
                    modified[obj.mitId] = obj;
                    return modified;
                }, {});

                for (const key in this.additionalAccountMapping) {
                    mapSize = mapSize + 1;
                    if (!this.additionalItems.includes({ label: this.additionalAccountMapping[key]['name'], value: key })) {
                        let personDescription = this.additionalAccountMapping[key]['email'] ?? '' + (this.additionalAccountMapping[key]['personTitle']?.length > 0 ? ' • ' + this.additionalAccountMapping[key]['personTitle'] : '') + (this.additionalAccountMapping[key]['personDepartment']?.length > 0 ? ', ' + this.additionalAccountMapping[key]['personDepartment'] : '');
                        this.additionalItems.push({ label: this.additionalAccountMapping[key]['name'], value: key, personDescription: personDescription });
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
        this.selectedAdditionalAccountMapping.splice(index, 1);
        this.additionalPiList.splice(index, 1);
        this.isPillVisible = this.additionalPiList.length == 0 ? false : true;
    }


    handleAdditionalItemClick(event) {

        let mitID;


        const element = event.target.closest('[data-id]');
        if (element) {
            const dataId = element.getAttribute('data-id');
            mitID = dataId;
            this.additionalPis.push({ 'mitId': mitID });
            this.searchedAdditionalPiItem = this.additionalAccountMapping[mitID].name;
            this.selectedAdditionalAccountMapping[mitID] = this.additionalAccountMapping[mitID];
            let found = false;
            for (let i = 0; i < this.additionalPiList.length; i++) {
                if (this.additionalPiList[i].label == this.searchedAdditionalPiItem) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                this.additionalPiList.push({
                    label: this.searchedAdditionalPiItem
                }
                );
            }
            this.isPillVisible = this.additionalPiList.length == 0 ? false : true;
            this.searchedAdditionalPiItem = '';
        }
        this.showDropdownAdditionalPi = false;

    }

    setTabLabelAndIcon(tabId) {
        setTabLabel(tabId, TAB_LABEL);
        setTabIcon(tabId, ``);
    }

}