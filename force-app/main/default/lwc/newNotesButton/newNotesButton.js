import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import createRecord from '@salesforce/apex/CreateNoteRecord.createRecord';
import updateContentNote from '@salesforce/apex/CreateNoteRecord.updateContentNote';
import deleteContentNote from '@salesforce/apex/CreateNoteRecord.deleteContentNote';
import getContainerObjectId from '@salesforce/apex/ExternalObjectRepository.getContainerObjectId';
import getNoteRecords from '@salesforce/apex/CreateNoteRecord.getNoteRecords';
import getNoteRecordTypeId from '@salesforce/apex/CreateNoteRecord.getNoteRecordTypeId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import NoteLevel from '@salesforce/schema/ContentVersion.Note_level__c';

const columns = [
    { label: 'Title', fieldName: 'noteLink', type: 'url',
    typeAttributes: { label: { fieldName: 'Title' }, target: '_blank' }},
    { label: 'Content', fieldName: 'Content', type: 'richText'}
];

const CASE_CRDR__c_FIELDS = ['CASE_CRDR__c.Status__c'];

export default class NewNotesButton extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api externalObjRecIdFieldName;
    @api matchingContainerObject;
    @api containerObjRecIdFieldName;
    
    containerObjectId;
    loading = true;
    notesModal = false;
    hasRecords = false;
    statusNotFinalized = false;
    data = [];
    noteDisplayList = [];
    columns = columns;
    error;
    noteRecdTypeId;
    noteLevels;
    validity = true;
    disabled = true;
    isSectionExpanded = true;
    activeSectionsMessage = '';
    @track activeSections = [];
    @track note = { 
        sobjectType: 'ContentVersion',
        Title: '',
        VersionData: '',
        Note_level__c: ''
    };
    base_URL;
    @track isEditMode = false;
    selectedNoteId;

    allowedFormats = [
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'clean',
        'table',
        'header'
    ];

    connectedCallback(){
        this.base_URL = window.location.origin;
    }

    @wire(getContainerObjectId, {
        externalObjRecId: '$recordId',
        externalObjApiName: '$objectApiName',
        externalObjRecIdFieldName: '$externalObjRecIdFieldName',
        matchingContainerObject: '$matchingContainerObject',
        containerObjRecIdFieldName:'$containerObjRecIdFieldName'
    })
    handleLoadData(result) {
        const { data, error } = result;
        if (data) {
            this.containerObjectId = data.Id;
            this.getNotes();
            this.loading = false;
        }
        if (error) {
            console.error(error);
            this.loading = false;
        }
    }

    @wire(getRecord, { recordId: '$containerObjectId', fields: CASE_CRDR__c_FIELDS })
    handleCRDR(wireResult) {
        const { data, error } = wireResult;
        this.getCaseCRDRRecordResult = wireResult;

        if (data) {
            this.statusNotFinalized = (data?.fields?.Status__c?.value ?? '') !== 'FINALIZED';
        } else if (error) {
            console.error(error);
            this.showToast('Error retrieving Status', JSON.stringify(error), 'error');
        }
    }

    async handleNewNotesQuickAction() {
        this.notesModal = true;
        this.isEditMode = false;
        this.updateCreateButtonState();
    }

    // Add a new method to handle edit mode
    handleEditNoteClick(event) {
        this.selectedNoteId = event.target.dataset.id;
        this.isEditMode = true;
        this.notesModal = true;
        this.updateCreateButtonState();
        // Populate modal fields with selected note's data
        const selectedNote = this.data.find(note => note.Id === this.selectedNoteId);
        if (selectedNote) {
            this.note = {
                Id: selectedNote.Id,
                Title: selectedNote.Title,
                VersionData: selectedNote.Content,
                Note_level__c: selectedNote.noteLevel,
                isOwner: selectedNote.isOwner
            };
        }
    }

    @wire(getNoteRecordTypeId, {}) 
    noteRecordTypeId({ error, data }) {
        if (data) {
            this.noteRecdTypeId = data;
        } else if (error) {
            this.error = error ;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$noteRecdTypeId', 
        fieldApiName: NoteLevel 
    }) 
    noteLevelOptions({ data, error }) {
        if (data) {
            this.noteLevels = data.values;
        }
        if (error) {
            console.error(error);
        }
    }

    handleNoteLevelChange(event){
        this.note.Note_level__c = event.target.value;
        this.updateCreateButtonState();
    }

    handleTitleChange(event) {
        this.note.Title = event.target.value;
        this.updateCreateButtonState();
    }

    handleContentChange(event) {
        this.note.VersionData = event.target.value;
        this.updateCreateButtonState();
    }

    updateCreateButtonState() {
        this.disabled = !this.note.VersionData || !this.note.Title || !this.note.Note_level__c;
    }


    getNotes(){
        getNoteRecords({
            PrentId: this.containerObjectId
        })
        .then(records => {
            records = JSON.parse(JSON.stringify(records));
            records.forEach(res => {
                res.noteLink = '/' + res.Id;
                res.userLink = '/' + res.CreatedById;
                res.Content = res.Content.replace(/<img[^>]*>/g,"");
            });
            this.data = records;
            this.hasRecords = this.data.length > 0;
            // Sort the list based on noteLevel
            this.noteDisplayList = this.data
            .sort((a, b) => {
                if (!a.noteLevel) return 1; // Move undefined values to the end
                if (!b.noteLevel) return -1; // Move undefined values to the end
                if (a.noteLevel === 'General') return -1;
                if (b.noteLevel === 'General') return 1;
                return a.noteLevel.localeCompare(b.noteLevel);
            });
    
            this.activeSections = this.noteDisplayList.map(item => item.noteLevel);
    
            // Stop spinner if there's no data
            if (this.data.length === 0) {
                this.loading = false;
            }
        })
        .catch(error => {
            console.error('Error getting notes:', error);
            // Stop spinner if there's an error
            this.loading = false;
        });
    }
    

    // Method to display toast message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Refactored create() method
    create() {
        if (!this.note.VersionData) {
            this.validity = false;
        } else {
            this.validity = true;
            this.disabled = true;
            // Escape some characters:
            this.escapeSpecialCharacters();

            if (this.isEditMode) {
                this.disabled = false;
                // Update existing record
                updateContentNote({contentNoteId : this.note.Id, title: this.note.Title, contentBase64: btoa(this.note.VersionData), notelevel: this.note.Note_level__c})
                    .then(() => {
                        this.showToast('Success', 'Note updated successfully', 'success');
                        this.closeModal();
                        this.getNotes();
                    })
                    .catch(error => {
                        this.showToast('Error', error.body.message, 'error');
                    });
            } else {
                // Create new record
                const noteContentVersion = {
                    sobjectType: this.note.sobjectType,
                    Title: this.note.Title,
                    VersionData: btoa(this.note.VersionData), //base 64 encoded.
                    Note_level__c: this.note.Note_level__c
                }
                createRecord({
                    nt: noteContentVersion,
                    PrentId: this.containerObjectId
                })
                .then(() => {
                    this.showToast('Success', 'Note created successfully', 'success');
                    this.closeModal();
                    this.getNotes();
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                });
            }
        }
    }

    deleteNote(){
        if (this.note.Id) {
            deleteContentNote({contentNoteId : this.note.Id})
                .then(() => {
                    this.showToast('Success', 'Note deleted successfully', 'success');
                    this.closeModal();
                    this.getNotes();
                })
                .catch(error => {
                    console.error('Error deleting note:', error);
                    this.showToast('Error', error.body.message, 'error');
                });
        }
    }

    closeModal() {
        this.notesModal = false;
        this.resetFields();
        this.isEditMode = false; // Reset edit mode
    }

    resetFields() {
        this.note = { 
            sobjectType: 'ContentVersion',
            Title: '',
            VersionData: '',
            Note_level__c: ''
        };
    }

    get dataCount() {
        return this.data.length > 0;
    }

    get noteTitleWithCount() {
        return `Notes (${this.data.length})`;
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        this.activeSectionsMessage = openSections.length === 0 ? 'All sections are closed' : `Open sections: ${openSections.join(', ')}`;
    }

    get modalHeader() {
        return this.isEditMode ? 'Edit Note' : 'New Note';
    }
    
    get createButtonLabel() {
        return this.isEditMode ? 'Save' : 'Create';
    }

    // Method to retrieve notes based on visibility
    getDisplayedNotes() {
        return this.noteDisplayList;
    }

    get showDeleteButton() {
        return this.note.isOwner;
    }

    // Updated method to display grouped notes based on visibility
    get groupedNoteDisplayList() {
        let groupedNotes = {};
        let displayedNotes = this.getDisplayedNotes();
        
        displayedNotes.forEach(item => {
            if (!groupedNotes[item.noteLevel]) {
                groupedNotes[item.noteLevel] = [];
            }
            groupedNotes[item.noteLevel].push(item);
        });

        return Object.keys(groupedNotes).map(noteLevel => {
            return { 
                noteLevel: noteLevel, 
                notes: groupedNotes[noteLevel].filter(item => displayedNotes.includes(item)).sort((a, b) => {
                    return b.CreatedDate.localeCompare(a.CreatedDate);
                })
             };
        });
    }

    escapeSpecialCharacters(){
        this.note.VersionData = this.note.VersionData
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/’/g, '&#8217;'); //&#39;
    }
}