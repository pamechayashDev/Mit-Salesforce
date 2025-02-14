global virtual class RecordObjectFieldsPicklist extends VisualEditor.DynamicPickList {
    private VisualEditor.DynamicPickListRows picklistRows = new VisualEditor.DynamicPickListRows();

    global RecordObjectFieldsPicklist(VisualEditor.DesignTimePageContext context) {
        if (context.pageType == 'RecordPage') {
            // Get the current page's entity name and record type
            string entityName = context.entityName;
            SObjectType recordType = Schema.getGlobalDescribe().get(entityName);
            Map<String, Schema.SObjectField> fieldMap = recordType.getDescribe().fields.getMap();

            // For each field found...
            for (String field : fieldMap.keySet()) {
                // Add the field as a picklist option
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(field).getDescribe();
                picklistRows.addRow(new VisualEditor.DataRow(fieldDescribe.getLabel(), entityName + '.' + fieldDescribe.getName()));
            }
        }
    }

    global override VisualEditor.DataRow getDefaultValue() {
        // By default, return the first field in the list
        return picklistRows.get(0);
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        return picklistRows;
    }

    protected void addValues(List<VisualEditor.DataRow> pickListRows) {
        this.picklistRows.addAllRows(pickListRows);
    }
}