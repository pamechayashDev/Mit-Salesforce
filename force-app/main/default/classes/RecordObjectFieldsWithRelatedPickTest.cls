/**
 * Created by Andreas du Preez on 2024/08/06.
 */

@IsTest
public with sharing class RecordObjectFieldsWithRelatedPickTest {
    @IsTest
    public static void returnsPicklistOptionsForRecordPage() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.pageType = 'RecordPage';
        context.entityName = 'Account';

        RecordObjectFieldsWithRelatedPicklist picklist = new RecordObjectFieldsWithRelatedPicklist(context);

        VisualEditor.DynamicPickListRows picklistRows = picklist.getValues();
        System.assertNotEquals(0, picklistRows.size(), 'Picklist options should be returned for RecordPage');
    }

    @IsTest
    public static void returnsEmptyPicklistForNonRecordPage() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.pageType = 'HomePage';
        context.entityName = 'Account';

        RecordObjectFieldsWithRelatedPicklist picklist = new RecordObjectFieldsWithRelatedPicklist(context);

        VisualEditor.DynamicPickListRows picklistRows = picklist.getValues();
        System.assertEquals(0, picklistRows.size(), 'No picklist options should be returned for non-RecordPage');
    }
}