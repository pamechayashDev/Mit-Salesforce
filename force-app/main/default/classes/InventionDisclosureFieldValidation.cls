public with sharing class InventionDisclosureFieldValidation {
    public static void validateInventionDisclosureFields(Invention_Disclosure__c inventionDisclosure) {
        validateAnticipatedPublication(inventionDisclosure);
        validateOralPresentation(inventionDisclosure);
        validatePublishedOrDisclosed(inventionDisclosure);
        validateReducedToPractice(inventionDisclosure);
    }

    public static Boolean validateInventionDisclosureFieldsDisclosureUpdate(Invention_Disclosure__c inventionDisclosure) {
        if (validateAnticipatedPublicationDisclosureUpdate(inventionDisclosure) &&
            validateReducedToPracticeDisclosureUpdate(inventionDisclosure) &&
            validateOralPresentationDisclosureUpdate(inventionDisclosure) &&
            validatePublishedOrDisclosedDisclosureUpdate(inventionDisclosure)) {
                return true;
        } else {
            return false;
        }
    }

    public static void validatePublishedOrDisclosed(Invention_Disclosure__c inventionDisclosure) {
        if (inventionDisclosure.Disclosure_Published_Or_Disclosed__c == 'Yes' && 
            (inventionDisclosure.Publication_Date__c == null || inventionDisclosure.First_Publication_Comment__c == null)) {
                inventionDisclosure.Publication_Date__c.addError('Must be present with Published_Or_Disclosed as true');
                inventionDisclosure.First_Publication_Comment__c.addError('Must be present with Published_Or_Disclosed as true');
        } else if (inventionDisclosure.Disclosure_Published_Or_Disclosed__c == 'No' && 
            (inventionDisclosure.Publication_Date__c != null || inventionDisclosure.First_Publication_Comment__c != null)) {
                inventionDisclosure.Disclosure_Published_Or_Disclosed__c.addError('Must be true to add Publication_Date and First_Publication_Comment');
        }
    }

    public static Boolean validatePublishedOrDisclosedDisclosureUpdate(Invention_Disclosure__c inventionDisclosure) {
        if (inventionDisclosure.Disclosure_Published_Or_Disclosed__c == 'Yes' && 
            (inventionDisclosure.Publication_Date__c == null || inventionDisclosure.First_Publication_Comment__c == null)) {
                return false;
        } else if (inventionDisclosure.Disclosure_Published_Or_Disclosed__c == 'No' && 
            (inventionDisclosure.Publication_Date__c != null || inventionDisclosure.First_Publication_Comment__c != null)) {
                return false;
        }

        return true;
    }

    public static void validateAnticipatedPublication(Invention_Disclosure__c inventionDisclosure) {
        if (inventionDisclosure.Disclosure_Anticipated_Publication__c == 'Yes' && 
            (inventionDisclosure.Anticipated_Publication_Disclosure_Date__c == null || inventionDisclosure.Anticipated_Publication_Comment__c == null)) {
                inventionDisclosure.Anticipated_Publication_Disclosure_Date__c.addError('Must be present with Anticipated_Publication_Disclosure as true');
                inventionDisclosure.Anticipated_Publication_Comment__c.addError('Must be present with Anticipated_Publication_Disclosure as true');
        } else if (inventionDisclosure.Disclosure_Anticipated_Publication__c == 'No' && 
            (inventionDisclosure.Anticipated_Publication_Disclosure_Date__c != null || inventionDisclosure.Anticipated_Publication_Comment__c != null)) {
                inventionDisclosure.Disclosure_Anticipated_Publication__c.addError('Must be true to add Anticipated_Publication_Disclosure_Date and Anticipated_Publication_Comment');
        }
    }

    public static Boolean validateAnticipatedPublicationDisclosureUpdate(Invention_Disclosure__c inventionDisclosure) {
        if (inventionDisclosure.Disclosure_Anticipated_Publication__c == 'Yes' && 
            (inventionDisclosure.Anticipated_Publication_Disclosure_Date__c == null || inventionDisclosure.Anticipated_Publication_Comment__c == null)) {
                return false;
        } else if (inventionDisclosure.Disclosure_Anticipated_Publication__c == 'No' && 
            (inventionDisclosure.Anticipated_Publication_Disclosure_Date__c != null || inventionDisclosure.Anticipated_Publication_Comment__c != null)) {
                return false;       
        }

        return true;
    }

    public static void validateOralPresentation(Invention_Disclosure__c inventionDisclosure) {
        if (inventionDisclosure.Disclosure_Oral_Presentation__c == 'Yes' && 
            (inventionDisclosure.Oral_Disclosure_Date__c == null || inventionDisclosure.First_Oral_Disclosure_Comment__c == null)) {
                inventionDisclosure.Anticipated_Publication_Disclosure_Date__c.addError('Must be present with Anticipated_Publication_Disclosure as true');
                inventionDisclosure.First_Oral_Disclosure_Comment__c.addError('Must be present with Anticipated_Publication_Disclosure as true');
        } else if (inventionDisclosure.Disclosure_Oral_Presentation__c == 'No' && 
        (inventionDisclosure.Oral_Disclosure_Date__c != null || inventionDisclosure.First_Oral_Disclosure_Comment__c != null)) {
            inventionDisclosure.Disclosure_Oral_Presentation__c.addError('Must be true to add Anticipated_Publication_Disclosure_Date and Anticipated_Publication_Comment');
        }
    }

    public static Boolean validateOralPresentationDisclosureUpdate(Invention_Disclosure__c inventionDisclosure) {
        if (inventionDisclosure.Disclosure_Oral_Presentation__c == 'Yes' && 
            (inventionDisclosure.Oral_Disclosure_Date__c == null || inventionDisclosure.First_Oral_Disclosure_Comment__c == null)) {
                return false;
        } else if (inventionDisclosure.Disclosure_Oral_Presentation__c == 'No' && 
        (inventionDisclosure.Oral_Disclosure_Date__c != null || inventionDisclosure.First_Oral_Disclosure_Comment__c != null)) {
            return false;
        }

        return true;
    }

    public static void validateReducedToPractice(Invention_Disclosure__c inventionDisclosure) {
        if (inventionDisclosure.Disclosure_Reduced_To_Practice__c == 'Yes' && 
            (inventionDisclosure.Reduced_To_Practice_Date__c == null || inventionDisclosure.Reduced_To_Practice_Comment__c == null)) {
                inventionDisclosure.Anticipated_Publication_Disclosure_Date__c.addError('Must be present with Anticipated_Publication_Disclosure as true');
                inventionDisclosure.Reduced_To_Practice_Comment__c.addError('Must be present with Anticipated_Publication_Disclosure as true');
        } else if (inventionDisclosure.Disclosure_Reduced_To_Practice__c == 'No' && 
            (inventionDisclosure.Reduced_To_Practice_Date__c != null || inventionDisclosure.Reduced_To_Practice_Comment__c != null)) {
                inventionDisclosure.Disclosure_Reduced_To_Practice__c.addError('Must be true to add Anticipated_Publication_Disclosure_Date and Anticipated_Publication_Comment');
        }
    }

    public static Boolean validateReducedToPracticeDisclosureUpdate(Invention_Disclosure__c inventionDisclosure) {
        if (inventionDisclosure.Disclosure_Reduced_To_Practice__c == 'Yes' && 
            (inventionDisclosure.Reduced_To_Practice_Date__c == null || inventionDisclosure.Reduced_To_Practice_Comment__c == null)) {
                return false;
        } else if (inventionDisclosure.Disclosure_Reduced_To_Practice__c == 'No' && 
            (inventionDisclosure.Reduced_To_Practice_Date__c != null || inventionDisclosure.Reduced_To_Practice_Comment__c != null)) {
                return false;
        }

        return true;
    }

}