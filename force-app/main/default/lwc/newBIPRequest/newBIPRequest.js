import { LightningElement, track,wire } from "lwc";
import getApexData from '@salesforce/apex/BipRequestController.createBIPReq';
import uploadFile from '@salesforce/apex/BipRequestController.uploadFile';
import getResponse from '@salesforce/apex/BipRequestController.getResponse';
import createAdditionalBips from '@salesforce/apex/BipRequestController.createAdditionalBips'
import { jitGetCreateContact } from 'c/utils';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import search from '@salesforce/apex/BipRequestController.search';
import queryCases from '@salesforce/apex/QueryQueueable.queryCases'
import CATEGORY_FIELD from '@salesforce/schema/BIP_Request__c.Category__c';
import getResponseForAccountCreations from '@salesforce/apex/BipRequestController.getResponseForAccountCreations'
import { getFocusedTabInfo, closeTab, setTabLabel, setTabIcon, getAllTabInfo } from "lightning/platformWorkspaceApi";
import { NavigationMixin } from "lightning/navigation";

const BIP_REQUEST_OBJECT = 'BIP_Request__c';
const NEW_BIP_LIGHTNING_TAB_NAME = 'New_BIP';
const TAB_LABEL = 'New BIP Request';

export default class Request extends NavigationMixin(LightningElement) {
    proposal = '';
    fileData = null;
    showDropdown = false;
    additionalPiString='';
    recordSuccess = false;
    ccEmail = '';
    additionalAccData = {};

    successData = 'Record Created Successfully!';
    recordFailed = false;
    failedData = '';
    showPrimaryPiDropdown = false;
    showDropdownAdditionalPi = false;
   @track additionalPiList = [];
    @track proposalNumberPills = [


    ];
    accountRes = {};
    additionalPiAccountRes = {};
    primaryPiMitIdsKC = [];
    bipString = '';
    primaryPiAccountNamesKC = [];
    additionalPis = [];
    additionalAccountResponses = {};
    requestor = '';
    @track recordItems = [];
    @track PrimaryPiRecordItems = [];
    selectedAcc = '';
    @track additionalItems = [];
    primaryPiAccountRes = {};
    requestType = 'Standard';
    dueDate = '';
    projectDescription = '';
    comments = '';
    recordType = '';
    accmit = {};
    category = '';
    BipPis = [];
    responseResults = [];
    searchedString = '';
    searchedItem = '';
    spinnerActive = false;
    requestorAccData = {};
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
    //  accountNumber = '';
    mitId = '1';
    isLoading = false;
    @track items = [];
    searchTimeout;
    selectedPropNumber = '';
    categoryOptions=[];
    recordTypeID='012E20000065HHnIAM';
    @track ccEmailsList = [
    ];
    data = [];

    ProposalNumberMapping = {};

    @wire(getPicklistValues, { recordTypeId: '$recordTypeID', fieldApiName: CATEGORY_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) {
            console.log('isNonKC'+this.isNonKCPraposal);
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
        for (let i = 0; i < this.BipPis.length; i++) {
            if (!!this.BipPis[i].personRole && this.BipPis[i].personRole == 'PI') {
                this.primaryPiMitIdsKC.push({ mitId: this.BipPis[i].mitId });
                this.primaryPi = this.BipPis[i].personName;


            }
            if (!(!!this.BipPis[i].personRole) || this.BipPis[i].personRole != 'PI') {
                bipNameList.push(this.BipPis[i].personName);
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
        this.mitId = '';
    }

    handleItemRemoveFile() {
        if (this.items.length != 0) {
            this.items.pop();
            this.fileData = null;
        }

    }

    handleCCEmailChange(event) {
        this.ccEmail = event.detail.value;
    }
    handleItemRemoveCC(event) {
        let index = event.detail.index;
        this.ccEmailsList.splice(index, 1);
        this.data.splice(index, 1);
    }
    handleOnBlurCC(event) {
        let val = this.ccEmail;
        console.log(val);
        this.ccEmailsList.push({
            label: val
        });
        this.data.push(val);
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

    handleChange(event) {

        //clearing all inputs
        this.searchedProposalValue = '';
        this.primaryPi = '';
        this.sponsor = '';
        this.projectTitle = '';
        this.ospContact = '';
        //  this.mitId='';
        this.requestor = '';
        this.requestType = 'Standard';
        this.dueDate = '';
        this.projectDescription = '';
        this.fileData = null;
        this.items = [];
        this.comments = '';
        this.responseResults = [];
        this.searchedPrimaryPiString = '';
        this.proposalNumberPills = [];
        this.showDropdown = false;
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
        this.recordTypeID = this.isNonKCPraposal ? '012E20000065HHpIAM':'012E20000065HHnIAM';
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

        if (this.selectedAcc != '') {
            if (this.requestorAccData[this.selectedAcc]['from'] == 'GetPerson') {
                this.requestor = this.requestorAccData[this.selectedAcc]['Id'];
            }
            else {
                let accountResult = await jitGetCreateContact(this.requestorAccData[this.selectedAcc]['apiResponse']);
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
        if (this.data.length != 0) {
            ccCorrespondence = this.data.join(',');
        }
        if (this.selectedPropNumber == '' && this.responseResults.length > 1) {
            this.searchedProposalValue = '';
        }

        var bipObj = {
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
        console.log('bipObj'+ JSON.stringify(bipObj));
        getApexData({
            bipRequest: bipObj,
            recordType: this.recordTypeSelected
        })
            .then(async result => {
                console.log('result--' + result);

             
                if (result) {
                    this.isLoading = false;
                

                 

                    if (this.additionalPis.length > 0) {

             


                        for (let i = 0; i < this.additionalPis.length; i++) {

                            console.log('additionalPis[i].mitId--'+this.additionalPis[i].mitId);
                            let response = this.additionalAccData[this.additionalPis[i].mitId];

                         console.log('response--'+JSON.stringify(response));
  
                            if (response['from'] == 'GetPerson') {

                                this.additionalAccountResponses[response['MitId']] = response['Id'];

                                console.log('res[key][\'MitId\']---' + response['MitId']);
                                console.log('res[key][\'MitId\']---' + response['Id']);

                            }
                            else {


                                let accRes = await jitGetCreateContact(response['apiResponse']);
                                let accountId = JSON.parse(JSON.stringify(accRes)).data.Id
                                console.log('accountId---' + JSON.stringify(accountId));
                                this.additionalAccountResponses[response['MitId']] = accountId;


                            }

                        }
                        console.log('additionalAccountResponses==',JSON.stringify(this.additionalAccountResponses));
                        console.log('additionalPis==',JSON.stringify(this.additionalPis));
            
        
                     let  additionalBipRes  = await  createAdditionalBips({ bipPis: this.additionalPis, bipReqId: result, accountData: this.additionalAccountResponses });
                     console.log(additionalBipRes);
                    }
                    console.log('BipPis--' + this.BipPis.length)
                    getResponseForAccountCreations({ bipPis: this.BipPis }).then(async Methodresponse => {
                        for (let i = 0; i < this.BipPis.length; i++) {
                            let accountResult = await jitGetCreateContact(Methodresponse[i][0][0]);
                            console.log('MIT--' + Methodresponse[i][1]);
                            console.log('MIT--' + JSON.stringify(Methodresponse[i][0]));
                            this.accmit[Methodresponse[i][1]] = JSON.parse(JSON.stringify(accountResult)).data.Id;
                            console.log('this.accmit---' + this.accmit);
                        }
                        console.log('this.this.BipPis---' + JSON.stringify(this.BipPis));
                      let responseData = await  createAdditionalBips({ bipPis: this.BipPis, bipReqId: result, accountData: this.accmit });
                           
                      console.log('response--___+++++' + responseData)
                
                    

                        queryCases({recId: result}).then(queryResponse => {

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
                                recordId: result,
                                objectApiName: BIP_REQUEST_OBJECT,
                                actionName: 'view'
                            },
                        });
                    });
                }

                if (this.fileData) {
                    const { base64, filename } = this.fileData;
                    uploadFile({ base64, filename, result }).then(res => {
                        console.log(res);
                        this.fileData = null;
                    }).catch(e => {
                        console.log('fileerror-' + e);
                    });
                }
                

            }).catch(e => {
                console.log('error=====');
                this.recordFailed = true;
                this.failedData = 'Can\'t Save The Record';
            });


        console.log('this.primaryPiLookup', this.primaryPiLookup);
        // Add logic for saving data
        console.log('created    ==');



    }

    // Handle Cancel button click
    handlePrevious() {
        this.recordTypeSelected = '';
        this.isNonKCPraposal = false;
        this.recordTypeSelectionVisible = true;
        this.deatailSectionVisible = false;
    }
    isSelected = false;
    handleClick() {
        this.isSelected = !this.isSelected;
    }
    handleFilesChange(event) {


        if (event.target.files.length != 0) {

            const file = event.target.files[0];
            var reader = new FileReader();
            reader.onload = () => {
                var base64 = reader.result.split(',')[1]

                this.fileData = {
                    'filename': file.name,
                    'base64': base64,
                };
                this.items.push({

                    label: file.name,

                }
                )
                console.log(this.fileData);
            }
            reader.readAsDataURL(file)
        }




    }
    handleAlertClose() {
        this.recordFailed = false;
    }
    handleSearchChange(event) {
        const searchValue = event.target.value;

        // Clear any previously set timeout
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout);
        }

        // Set a new timeout to delay search execution
        this.searchTimeout = setTimeout(() => {
            this.executeSearch(searchValue);
        }, 1000);


    }
    executeSearch(searchValue) {
        this.showDropdownAdditionalPi = false;
        this.recordItems = [];

        this.searchedString = searchValue;
        if (this.searchedString == '') {
            this.recordItems = [];
            this.showDropdown = false;
        }
        if (this.searchedString.length > 1) {
            this.isLoading = true;
            this.recordItems = [];
            search({ searchParam: this.searchedString }).then(res => {
                console.log('resultss', res.size);
                let mapSize = 0;
                for (const key in res) {
                    mapSize = mapSize + 1;
                    this.requestorAccData = res;

                    if (!this.recordItems.includes({ label: res[key]['Name'], value: key })) {
                        let personDescription = res[key]['personEmail'] ?? '' + (res[key]['personTitle']?.length > 0 ? ' • ' + res[key]['personTitle'] : '') + (res[key]['personDepartment']?.length > 0 ? ', ' + res[key]['personDepartment'] : '');
                        this.recordItems.push({ label: res[key]['Name'], value: key, fromPersonAccounts: res[key]['from'] === 'GetPerson', personDescription: personDescription });
                    }
                }

                if (mapSize > 0) {
                    this.showDropdown = true;
                }
                else {
                    this.showDropdown = false;
                }
                this.isLoading = false;
            })
        }
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
                this.executeSearchInProposalNumber(searchValue);
            }, 1000);
        }
    }

    showProposalDropdown = '';
    searchedProposalValue = '';
    @track proposalRecords = [];
    selectedPropNumber = '';
    executeSearchInProposalNumber(searchedProposalNumber) {
        this.showDropdownAdditionalPi = false;
        this.showDropdown = false;
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
            getResponse({ proposalId: this.searchedProposalValue }).then(res => {
                if (res.results != undefined) {
                    this.responseResults = res.results;

                    for (let i = 0; i < res.results.length; i++) {
                        let num = res.results[i].proposalNumber;
                        this.proposalRecords.push({
                            label: num, value: num, title: res.results[i].title
                        })
                        this.ProposalNumberMapping[num] = res.results[i];

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

                this.BipPis = this.ProposalNumberMapping[this.selectedPropNumber].people;

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
            this.exePrimaryPiSearch(searchValue);
        }, 1000);
    }

    exePrimaryPiSearch(searchValue) {
        this.PrimaryPiRecordItems = [];
        this.showPrimaryPiDropdown = false;
        this.searchedPrimaryPiString = searchValue;

        if (this.searchedPrimaryPiString == '') {
            this.PrimaryPiRecordItems = [];
            this.showPrimaryPiDropdown = false;
        }

        if (this.searchedPrimaryPiString.length > 1) {
            this.isLoading = true;
            this.PrimaryPiRecordItems = [];
            search({ searchParam: this.searchedPrimaryPiString }).then(res => {
                let mapSize = 0;
                for (const key in res) {
                    mapSize = mapSize + 1;
                    this.primaryPiAccountRes = res;
                    if (!this.PrimaryPiRecordItems.includes({ label: res[key]['Name'], value: key })) {
                        let personDescription = res[key]['personEmail'] ?? '' + (res[key]['personTitle']?.length > 0 ? ' • ' + res[key]['personTitle'] : '') + (res[key]['personDepartment']?.length > 0 ? ', ' + res[key]['personDepartment'] : '');
                        this.PrimaryPiRecordItems.push({ label: res[key]['Name'], value: key, fromPersonAccounts: res[key]['from'] === 'GetPerson', personDescription: personDescription });
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

    handleItemRemove(event) {
        let index = event.detail.index;
        this.selectedAdditionalAccount.splice(index, 1);
        this.additionalPis.splice(index, 1);
        this.additionalPiList.splice(index, 1);
         this.isPillVisible=this.additionalPiList.length==0?false:true;

    }
    handleAdditionalPiSearchChange(event) {


        const searchValue = event.target.value;

        // Clear any previously set timeout
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout);
        }

        // Set a new timeout to delay search execution
        this.searchTimeout = setTimeout(() => {
            this.exeSearch(searchValue);
        }, 1000); 

    }

    exeSearch(searchValue){
        this.showDropdown = false;
        this.showPrimaryPiDropdown = false;
        this.showProposalDropdown=false;

        this.additionalItems =[];

        this.searchedItem = searchValue;
        if (this.searchedItem == '') {
            this.additionalItems = [];
            this.showDropdownAdditionalPi = false;
        }

        if (this.searchedItem.length > 1) {

            this.isLoading = true;
            this.additionalItems = [];
            search({ searchParam: this.searchedItem }).then(async res => {
                this.accountRes = res;
                let mapSize = 0;
                for (const key in res) {
                    mapSize = mapSize + 1;
                    this.additionalAccData[res[key]['MitId']]=res[key];   
                    if (!this.additionalItems.includes({ label: res[key]['Name'], value: key })) {
                        let personDescription = res[key]['personEmail'] ?? '' + (res[key]['personTitle']?.length > 0 ? ' • ' + res[key]['personTitle'] : '') + (res[key]['personDepartment']?.length > 0 ? ', ' + res[key]['personDepartment'] : '');
                        this.additionalItems.push({ label: res[key]['Name'], value: key, fromPersonAccounts: res[key]['from'] === 'GetPerson', personDescription: personDescription });
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
    selectedPrimaryPiAcc = '';
    primaryPiAccountNames = [];
    handlePrimaryPiItemClick(event) {

        let mitID;

        const element = event.target.closest('[data-id]');
        if (element) {
            const dataId = element.getAttribute('data-id');
            mitID = dataId;
            this.selectedPrimaryPiAcc = mitID;
            this.searchedPrimaryPiString = this.primaryPiAccountRes[mitID].Name;
            this.primaryPiAccountNames.push(this.searchedPrimaryPiString);
            console.log(this.primaryPiAccountRes[mitID].from);
            console.log(this.primaryPiAccountRes[mitID]);

        }


        //   this.selectedAcc = this.accountRes[];
        this.showPrimaryPiDropdown = false;
    }



    selectedAdditionalAccount = [];
    handleAdditionalItemClick(event) {
        console.log('called');
        
        let mitID;


        const element = event.target.closest('[data-id]');
        if (element) {
            const dataId = element.getAttribute('data-id');
            mitID = dataId;
           this.additionalPis.push({'mitId':mitID});
           console.log( this.additionalPis);
           this.selectedAdditionalAccount.push(mitID);
            this.searchedItem = this.accountRes[mitID].Name;



           let found=false;
           for(let i=0;i< this.additionalPiList.length;i++){
           if(this.additionalPiList[i].label ==  this.searchedItem){
            found=true;
            break;
           }
           }

           console.log('found',found);
           if(!found){
            console.log({label: this.searchedItem});
            this.additionalPiList.push({
                 label: this.searchedItem}
            );
           
           }
          
        this.isPillVisible=this.additionalPiList.length==0?false:true;
       // this.data.push(val);
        this.searchedItem = '';
         

        }
        console.log('log-'+JSON.stringify(this.additionalPiList));

        //   this.selectedAcc = this.accountRes[];
        this.showDropdownAdditionalPi = false;

    }



    handleItemClick(event) {
        let mitID;

        const element = event.target.closest('[data-id]');
        if (element) {
            const dataId = element.getAttribute('data-id');
            mitID = dataId;
            this.selectedAcc = mitID;
            this.searchedString = this.requestorAccData[mitID].Name;
        }
        this.showDropdown = false;
    }

    setTabLabelAndIcon(tabId) {
        setTabLabel(tabId, TAB_LABEL);
        setTabIcon(tabId, ``);
    }

}