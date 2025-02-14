public with sharing class DisclosureReviewPdfController {
    public String pdf {get;set;}
    public String disclosureName {get;set;}

    public DisclosureReviewPdfController() {
        Id parId = ApexPages.currentPage().getParameters().get('id');

        pdf = DocumentGenerationService.getReviewPdfFileAsBase64String(parId);

        Disclosure__c disclosure = [Select Id, Name from Disclosure__c where Id = :parId];
        disclosureName = 'Disclosure_Review_' + disclosure.Name + '.pdf' ;

    }
}