/**
 * Created by Andreas du Preez on 2024/08/06.
 */

global class RecordObjectFieldsWithRelatedPicklist extends RecordObjectFieldsPicklist {
    global RecordObjectFieldsWithRelatedPicklist(VisualEditor.DesignTimePageContext context) {
        super(context);
        List<VisualEditor.DataRow> picklistRows = new List<VisualEditor.DataRow>();

        if (context.pageType == 'RecordPage') {
            // Get the current page's entity name and record type
            String entityName = context.entityName;
            SObjectType recordType = Schema.getGlobalDescribe().get(entityName);
            Map<String, Schema.SObjectField> fieldMap = recordType.getDescribe().fields.getMap();

            // For each field found...
            for (String field : fieldMap.keySet()) {
                // Add the field as a picklist option
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(field).getDescribe();
                SObjectType relatedObject = fieldDescribe.getReferenceTo().isEmpty() ? null : fieldDescribe.getReferenceTo()[0];

                if (fieldDescribe.getRelationshipName() != null && relatedObject != null) {
                    Map<String, Schema.SObjectField> relationshipFieldMap = relatedObject.getDescribe().fields.getMap();

                    for (String relationshipField : relationshipFieldMap.keySet()) {
                        Schema.DescribeFieldResult relationshipFieldDescribe = relationshipFieldMap.get(relationshipField).getDescribe();
                        picklistRows.add(new VisualEditor.DataRow(fieldDescribe.getLabel() + ' - ' + relationshipFieldDescribe.getLabel(), entityName + '.' + fieldDescribe.getRelationshipName() + '.' + relationshipFieldDescribe.getName()));
                    }
                }
            }

            super.addValues(picklistRows);
        }
    }
}