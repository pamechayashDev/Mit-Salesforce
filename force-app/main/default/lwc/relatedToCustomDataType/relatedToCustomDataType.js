import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    {
        label: 'ID',
        fieldName: 'labelUrl',
        initialWidth: 100,
        type: 'url',
        typeAttributes: { label: { fieldName: 'label' } },
        sortable: true,
    },
    {
        label: 'Name',
        sortable: true,
        fieldName: 'descriptionUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'description' } },
    }
];

export default class RelatedToCustomDataType extends NavigationMixin(LightningElement) {
    columns = columns;
    totalNumber;
    @api relatedTo;
    @api recordUrl;
    @api recordTypeName;
    @api relatedToData;
    relatedData;
    sortDirection = 'asc';
    loading = true;
    noFiles = false;
    loadError = false;
    showNewTaskModal = false;

    connectedCallback() {
        this.loading = true;
        this.relatedData = [];
        this.loadError = false;
        this.noFiles = false;
        try {
            if (this.relatedToData.length > 1) {
                this.totalNumber = '+' + (this.relatedToData.length - 1);
            } else {
                this.totalNumber = 0;
            }

            const labelUrls = this.relatedToData.map(item => this.navigateToSObjectUrl(item.recordId));
            const descriptionUrls = this.relatedToData.map(item => this.navigateToSObjectUrl(item.recordId));

            for (let i = 0; i < this.relatedToData.length; i++) {
                const labelUrl = labelUrls[i];
                const descriptionUrl = descriptionUrls[i];

                this.relatedData.push({
                    labelUrl: labelUrl,
                    label: this.relatedToData[i].label,
                    descriptionUrl: descriptionUrl,
                    description: this.relatedToData[i].description,
                });
            }

            if (this.relatedData.length === 0) {
                this.noFiles = true;
            }

            this.loading = false;
        } catch (error) {
            console.error(`%c [ERROR]`, `color: red`, error);
            this.loadError = true;
            this.totalNumber = 0;
            this.loading = false;
        }
    }

    handleTotalRelatedToCount() {
        this.showNewTaskModal = true;
    }

    handleClose() {
        this.showNewTaskModal = false;
    }

    // This sorts the names of the files when the user clicks on the column header
    onHandleSort(event) {
        let { fieldName: sortedBy, sortDirection } = event.detail;
        const tempSorting = [...this.relatedData];

        // Sort function
        const sortByField = (a, b) => {
            let valueA = a[sortedBy] || '';
            let valueB = b[sortedBy] || '';

            // Implement your custom sorting logic here
            if (sortDirection === 'asc') {
                return valueA.localeCompare(valueB);
            } else {
                return valueB.localeCompare(valueA);
            }
        };

        // Sort the data
        tempSorting.sort(sortByField);

        // Update component state
        this.relatedData = tempSorting;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    // Function to generate the URL for file preview
    async navigateToPreviewFileUrl(id) {
        const url = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: id
            }
        });
        return url;
    }

    async navigateToSObjectUrl(recordId) {
        const url = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view',
            },
        });
        return url;
    }

    get documentCardTitleWithCount() {
        let titlePrefix = 'Related To - ';
        let typeName = this.recordTypeName;

        if (typeName !== 'CRDR' && typeName !== 'Case') {
            typeName = 'Agreements';
        }

        return titlePrefix + typeName + ' (' + this.relatedData.length + ')';
    }

    get datatableHeight() {
        if (this.relatedData.length >= 8) {
            return 'height: 250px;';
        }

        return 'height: 100%';
    }
}