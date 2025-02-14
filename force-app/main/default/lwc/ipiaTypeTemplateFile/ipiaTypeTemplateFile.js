/**
 * Created by Andreas du Preez on 2024/07/29.
 */

import { api, LightningElement } from "lwc";
import getIPIATypeTemplate from "@salesforce/apex/IPIAController.getIPIATypeTemplate";
import { NavigationMixin } from "lightning/navigation";
import DOCUMENT_ICON from "@salesforce/resourceUrl/document_icon_svg";

const MEGABYTE_IN_BYTES = 1000000;
const CUSTOM_ICON_ID = "document_icon";

export default class IpiaTypeTemplateFile extends NavigationMixin(LightningElement) {

    @api recordId;
    loading = true;
    fileData = {};

    connectedCallback() {
        getIPIATypeTemplate({ recordId: this.recordId }).then((result) => {
            this.fileData = {
                fileId: result.ContentDocumentId,
                fileName: result.Title,
                fileDate: result.LastModifiedDate,
                fileSize: result.ContentSize < MEGABYTE_IN_BYTES ? `${Math.trunc(result.ContentSize / (1024))}kb` : `${Math.trunc((result.ContentSize / (1024 ** 2)) * 100) / 100}mb`,
                fileType: result.FileType.toLowerCase(),
                fileBase64: result.ContentBody
            };
            this.loading = false;
        }).catch((error) => {
            console.error(error);
            this.loading = false;
        });
    }

    previewFile() {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "filePreview"
            },
            state: {
                recordIds: this.fileData.fileId,
                selectedRecordId: this.fileData.fileId
            }
        });
    }

    get getFileIcon() {
        switch (this.fileData.fileType) {
            case "pdf":
                return "doctype:pdf";
            case "png":
            case "jpeg":
            case "jpg":
                return "doctype:image";
            case "doc":
            case "docx":
                return "doctype:word";
            case "xls":
            case "xlsx":
            case "excel":
                return "doctype:excel";
            case "zip":
                return "doctype:zip";
            case "xml":
                return "doctype:xml";
            default:
                return "doctype:unknown";
        }
    }

    get getHeaderIconUrl() {
        return `${DOCUMENT_ICON}#${CUSTOM_ICON_ID}`;
    }
}