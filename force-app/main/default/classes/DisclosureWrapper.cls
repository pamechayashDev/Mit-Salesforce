global class DisclosureWrapper {
    public DisclosureWrapper() {
        this.isAntibody = false;
        this.isMouseStrain = false;
    }

    global String recordTypeDeveloperName;
    global String subTypeDeveloperName;

    global String disclosureTitle;
    global String disclosureType;
    global String submittedDate;

    global Boolean isAntibody;
    global Boolean isMouseStrain;
    global Boolean hasPublicationLinks;
    global Boolean hasDetails;

    global Disclosure__c disclosure;
    global string disclosureStatus;
    global List<String> disclosureReasons;
    global Account submittingContact;
    global String submittingContactFullName;
    global String submittedOnBehalf;

    global List<DisclosureInventorWrapper> inventors;

    global List<DisclosureExternalFunding__c> externalFunding;
    global List<DisclosureExternalFunding__c> externalFundingKC;
    global List<DisclosureExternalFunding__c> externalFundingManual;
    global List<DisclosureInternalFunding__c> internalFunding;
    global Department_Head__c departmentHead;
    global List<Commercial_Interest__c> commercialInterests;

    global BioTang_Disclosure__c biotang;
    global List<Lab_Materials__c> materials;

    global Cell_Line__c cellLine;
    global Plasmid__c plasmid;
    global Other_Material__c otherMaterial;
    global MouseStrainWrapper mouseStrainWrapper;
    global AntibodyWrapper antibodyWrapper;

    global InventionWrapper inventionWrapper;
    global Thesis__c thesis;

    global CopyrightWrapper copyrightWrapper;
    global List<Third_Party_Content__c> thirdPartyContent;
    global List<Open_Source__c> openSource;
    global SoftwareCodeWrapper softwareCodeWrapper;
    global List<Third_Party_Code__c> thirdPartCode;
    global List<String> softwarePubliclyAvailable;

    // Logged in inventor
    global DisclosureConditionsWrapper disclosureConditions;
    global DisclosureInventor__c inventor;
}