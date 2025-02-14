public with sharing class FieldFilterStrategy implements ScopeFilter {

    String fieldName;
    String fieldValue;
    FilterOperator operator;

    public enum FilterOperator {
        EQUALS,
        NOT_EQUALS
    }
    public FieldFilterStrategy(String fieldName, String fieldValue, FilterOperator operator) {
        this.fieldName = fieldName;
        this.fieldValue = fieldValue;
        this.operator = operator;
    }
    
    public List<SObject> doFilter(List<SObject> scope, FilterChain chain) {
        List<SObject> filterScope = new List<SObject>();
        for (SObject record : scope) {

            String fieldValue = CsvUtils.extractFieldValues(record, fieldName);

            if (this.operator == FilterOperator.NOT_EQUALS && this.fieldValue != fieldValue) {
                filterScope.add(record);
            }
            if (this.operator == FilterOperator.EQUALS && this.fieldValue == fieldValue) {
                filterScope.add(record);
            }
        }
        return chain.doFilter(filterScope);
    }
}