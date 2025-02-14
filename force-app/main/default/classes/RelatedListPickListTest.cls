/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-16-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public with sharing class RelatedListPickListTest {
    @TestSetup
     static void setup(){
         TestSetup.defaultConfiguration();
    }

    @isTest
    static void testAllValues() {
        VisualEditor.DynamicPickListRows testValues = new VisualEditor.DynamicPickListRows();
        testValues.addRow(new VisualEditor.DataRow('BioTangDisclosure__r', 'BioTangDisclosure__r'));
        testValues.addRow(new VisualEditor.DataRow('Inventors__r', 'Inventors__r'));

        RelatedListPickList rLPL = new RelatedListPickList();
        rLPL.relatedLists = testValues;
        VisualEditor.DynamicPickListRows rows = rLPL.getValues();
        System.assertEquals(2, rows.size(), 'No Lists were found');
    }

    @isTest
    static void testDefaultValue() {
        VisualEditor.DynamicPickListRows testValues = new VisualEditor.DynamicPickListRows();
        testValues.addRow(new VisualEditor.DataRow('BioTangDisclosure__r', 'BioTangDisclosure__r'));

        RelatedListPickList rLPL = new RelatedListPickList();
        rLPL.relatedLists = testValues;
        VisualEditor.DataRow row = rLPL.getDefaultValue();
        System.assertEquals('BioTangDisclosure__r', row.getLabel(), 'BioTangDisclosure__r was not the default value');
    }
}