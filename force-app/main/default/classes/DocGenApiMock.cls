public class DocGenApiMock  implements HttpCalloutMock {
    
    public String inventorId = '';
    public Boolean raiseDocuSignException =  false;
    public HTTPResponse respond(HTTPRequest req) {

        
        if (req.getEndpoint().containsignorecase('api/disclosure-doc-gen/v1') || req.getEndpoint().containsignorecase('pdf-generator-v1/generate/from-html') ) {
            PdfGeneratorApiMock pdfMock = new PdfGeneratorApiMock();
            return pdfMock.respond(req);
        }


        if (req.getEndpoint().containsignorecase('envelopes') || req.getEndpoint().containsignorecase('/accounts') ) {
            if (raiseDocuSignException) {
                throw new CalloutException('Some DocuSign Exception');
            }
            DocuSignApiMock docuSignMock = new DocuSignApiMock();
            docuSignMock.inventorId = this.inventorId;
            return docuSignMock.respond(req);
        }

        throw new CalloutException('Test not implemented ' + req.getEndpoint());
    }

    public DocGenApiMock setInventorId(String inventorIdStr) {
        this.inventorId = inventorIdStr;
        return this;
    }

    public DocGenApiMock setRaiseDocuSignException(Boolean raiseDocuSignException) {
        this.raiseDocuSignException = raiseDocuSignException;
        return this;
    }


}