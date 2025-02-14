global class InventionWrapper {
    public InventionWrapper() {

    }

    global Invention_Disclosure__c invention;

    global Boolean anticipatedPublicationDisclosure;
    global String anticipatedPublicationDisclosureDate;
    global String conceptionDate;
    global String oralDisclosureDate;
    global Boolean oralPresentation;
    global Boolean partOfThesis;
    global String publicationDate;
    global Boolean publishedOrDisclosed;
    global Boolean reducedToPractice;
    global String reducedToPracticeDate;
    global Boolean thesisHold;
    
    global String materialsFromOtherLab;
    global String materialsFurtherComments;
    global List<Third_Party_Material__c> materials;

    global String thesisDefenseDate;
    global String thesisSubmittedDate;
    global String thesisDegreeDate;

    global List<String> typeOfPresentations;


}