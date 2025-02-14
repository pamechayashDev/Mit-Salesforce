public with sharing class CRDRNotesPdfController {
    public String pdf {get;set;}
    public String crdrName {get;set;}

    public CRDRNotesPdfController() {
        Id parId = ApexPages.currentPage().getParameters().get('id');
        crdrName = 'CRDR_Notes_' + parId + '.pdf';

        pdf = DocumentGenerationService.getCrdrNotesPdfFileAsBase64String(parId);

    }
}