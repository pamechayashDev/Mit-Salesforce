import { api, LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

const FILE_ICON_ENUMS = {
    pdf: "pdf",
    docx: "docx",
    doc: "doc",
    zip: "zip",
    gz: "gz",
    ppt: "ppt",
    pptx: "pptx",
    pptm: "pptm",
    txt: "txt",
    tex: "tex",
    latex: "latex",
    xls: "xls",
    xlsm: "xlsm",
    xlsx: "xlsx",
    mp3: "mp3",
    mp4: "mp4",
    wav: "wav",
    svg: "svg",
    csv: "csv",
    html: "html",
    htm: "htm",
    bsv: "bsv",
    py: "py",
    c: "c",
};

export default class DocumentDetailsItem extends NavigationMixin(
    LightningElement
) {
    @api file;

    navigateToPreviewFile(event) {
        console.log(event.currentTarget.dataset.id);
        const datasetId = event.currentTarget?.dataset?.id ?? undefined
        const contentDocumentId = (datasetId !== undefined && datasetId !== '')? event.currentTarget.dataset.id : this.fileId
        console.debug('contentDocumentId', contentDocumentId);
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "filePreview"
            },
            state: {
                selectedRecordId: contentDocumentId //your ContentDocumentId here
            }
        });
    }

    get fileIcon() {
        if (!this.file) return "doctype:attachment";

        switch (this.file?.ContentDocument?.FileExtension) {
            case FILE_ICON_ENUMS.pdf:
                return "doctype:pdf";
            case FILE_ICON_ENUMS.docx:
                return "doctype:word";
            case FILE_ICON_ENUMS.doc:
                return "doctype:word";
            case FILE_ICON_ENUMS.zip:
                return "doctype:zip";
            case FILE_ICON_ENUMS.gz:
                return "doctype:zip";
            case FILE_ICON_ENUMS.ppt:
                return "doctype:ppt";
            case FILE_ICON_ENUMS.pptx:
                return "doctype:ppt";
            case FILE_ICON_ENUMS.pptm:
                return "doctype:ppt";
            case FILE_ICON_ENUMS.txt:
                return "doctype:txt";
            case FILE_ICON_ENUMS.tex:
                return "doctype:txt";
            case FILE_ICON_ENUMS.latex:
                return "doctype:txt";
            case FILE_ICON_ENUMS.xls:
                return "doctype:excel";
            case FILE_ICON_ENUMS.xlsm:
                return "doctype:excel";
            case FILE_ICON_ENUMS.xlsx:
                return "doctype:excel";
            case FILE_ICON_ENUMS.mp3:
                return "doctype:audio";
            case FILE_ICON_ENUMS.mp4:
                return "doctype:mp4";
            case FILE_ICON_ENUMS.wav:
                return "doctype:audio";
            case FILE_ICON_ENUMS.svg:
                return "doctype:image";
            case FILE_ICON_ENUMS.csv:
                return "doctype:csv";
            case FILE_ICON_ENUMS.html:
                return "doctype:html";
            case FILE_ICON_ENUMS.htm:
                return "doctype:html";
            case FILE_ICON_ENUMS.bsv:
                return "doctype:image";
            case FILE_ICON_ENUMS.py:
                return "doctype:html";
            case FILE_ICON_ENUMS.c:
                return "doctype:html";
            default:
                return "doctype:attachment";
        }
    }

    //takes the file size in bytes and returns a string with the size in the appropriate unit
    get getFileSize() {
        if (!this.file) return "undefined size";

        let bytes = this.file?.ContentDocument?.ContentSize;
        let sizes = ["bytes", "KB", "MB", "GB", "TB"];
        if (bytes === 0) return "0 bytes";
        let i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)), 10);
        return Math.round(bytes / Math.pow(1024, i), 2) + sizes[i];
    }

    get fileTitle() {
        return this.file?.ContentDocument?.Title ?? "Untitled";
    }

    get fileExtension() {
        return this.file?.ContentDocument?.FileExtension ?? "unknown file";
    }

    get fileId() {
        return this.file?.ContentDocumentId ?? "";
    }

    get fileDate() {
        return this.file?.ContentDocument?.CreatedDate ?? "unknown date";
    }
}