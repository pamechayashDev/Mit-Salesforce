@RestResource(urlMapping =  '/api/disclosure-doc-gen/v1/*')
global with sharing class DisclosureDocGenAPI {

    // https://sfdcblog.binaryrepublik.com/2019/06/generate-pdf-file-with-apex-trigger-in.html#.Y8blftJBwYs
    @HttpGet
    global static String generateDocument() {
        
        String disclosureIdStr = RestContext.request.params.get('disclosureId');
        String inventorIdStr = RestContext.request.params.get('inventorId');

        String base64Pdf = DisclosureInventorDocumentService.getDisclosureInventorDocument(disclosureIdStr, inventorIdStr);
        return base64Pdf;
    }
}