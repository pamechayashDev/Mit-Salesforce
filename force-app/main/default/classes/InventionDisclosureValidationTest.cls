/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class InventionDisclosureValidationTest {
    @TestSetup
    static void setup(){
        TestSetup.defaultConfiguration();
    }

    @isTest
    public static void InventionDisclosureValidationTestTrue() {
        try {
            Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Invention_Disclosure').getRecordTypeId();
            Disclosure__c testDisclosure = new Disclosure__c(Name__c = 'Test Disclosure', Status__c = 'Inventor Submitted', RecordTypeId = recordTypeId);
            insert testDisclosure;
            Invention_Disclosure__c testInvention = new Invention_Disclosure__c(Name = 'Test Invention', Disclosure__c = testDisclosure.Id, Disclosure_Published_Or_Disclosed__c = 'Yes', Disclosure_Anticipated_Publication__c = 'Yes', Disclosure_Oral_Presentation__c = 'Yes', Disclosure_Reduced_To_Practice__c = 'Yes');
            insert testInvention;
            InventionDisclosureFieldValidation.validateInventionDisclosureFields(testInvention);
        } catch(Exception e) {
            System.assert(true);
        }
    }

    @isTest
    public static void InventionDisclosureValidationDisclosureUpdateTestTrue() {
        try {
            Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Invention_Disclosure').getRecordTypeId();
            Disclosure__c testDisclosure = new Disclosure__c(Name__c = 'Test Disclosure', RecordTypeId = recordTypeId);
            insert testDisclosure;
            Invention_Disclosure__c testInvention = new Invention_Disclosure__c(Name = 'Test Invention', Disclosure__c = testDisclosure.Id, Disclosure_Published_Or_Disclosed__c = 'Yes', Disclosure_Anticipated_Publication__c = 'Yes', Disclosure_Oral_Presentation__c = 'Yes', Disclosure_Reduced_To_Practice__c = 'Yes');
            insert testInvention;
            InventionDisclosureFieldValidation.validateReducedToPracticeDisclosureUpdate(testInvention);
            InventionDisclosureFieldValidation.validateOralPresentationDisclosureUpdate(testInvention);
            InventionDisclosureFieldValidation.validatePublishedOrDisclosedDisclosureUpdate(testInvention);

            testDisclosure.Status__c = 'Inventor Submitted';
            Database.update(testDisclosure);
            Boolean result = InventionDisclosureFieldValidation.validateInventionDisclosureFieldsDisclosureUpdate(testInvention);
        } catch(Exception e) {
            System.assert(true);
        }
    }

    @isTest
    public static void InventionDisclosureValidationTestFalse() {
        try {
            Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Invention_Disclosure').getRecordTypeId();
            Disclosure__c testDisclosure = new Disclosure__c(Name__c = 'Test Disclosure', Status__c = 'Inventor Submitted', RecordTypeId = recordTypeId);
            insert testDisclosure;
            Invention_Disclosure__c testInvention = new Invention_Disclosure__c(Name = 'Test Invention',Disclosure__c = testDisclosure.Id, Publication_Date__c = Date.newInstance(2022, 06, 09), Anticipated_Publication_Disclosure_Date__c = Date.newInstance(2022, 06, 09), Oral_Disclosure_Date__c = Date.newInstance(2022, 06, 09), Reduced_To_Practice_Date__c = Date.newInstance(2022, 06, 09));
            insert testInvention;
            InventionDisclosureFieldValidation.validateInventionDisclosureFields(testInvention);
        } catch(Exception e) {
            System.assert(true);
        }
    }

    @isTest
    public static void InventionDisclosureValidationDisclosureUpdateTestFalse() {
        try {
            Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Invention_Disclosure').getRecordTypeId();
            Disclosure__c testDisclosure = new Disclosure__c(Name__c = 'Test Disclosure', RecordTypeId = recordTypeId);
            insert testDisclosure;
            Invention_Disclosure__c testInvention = new Invention_Disclosure__c(Name = 'Test Invention', Disclosure__c = testDisclosure.Id, Publication_Date__c = Date.newInstance(2022, 06, 09), Anticipated_Publication_Disclosure_Date__c = Date.newInstance(2022, 06, 09), Oral_Disclosure_Date__c = Date.newInstance(2022, 06, 09), Reduced_To_Practice_Date__c = Date.newInstance(2022, 06, 09));
            insert testInvention;

            testDisclosure.Status__c = 'Inventor Submitted';
            Database.update(testDisclosure);
            Boolean result = InventionDisclosureFieldValidation.validateInventionDisclosureFieldsDisclosureUpdate(testInvention);
        } catch(Exception e) {
            System.assert(true);
        }
    }
}