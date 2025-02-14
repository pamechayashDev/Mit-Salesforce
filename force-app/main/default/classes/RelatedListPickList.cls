/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-16-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class RelatedListPickList extends VisualEditor.DynamicPickList {

    public VisualEditor.DynamicPickListRows relatedLists = new VisualEditor.DynamicPickListRows();

    public RelatedListPickList() {
        Schema.DescribeSObjectResult r = Disclosure__c.SObjectType.getDescribe();
		for (Schema.ChildRelationship cr: r.getChildRelationships()) {
            if (cr.getRelationshipName() != null) {
                if (cr.getRelationshipName().contains('__r')) {
                    relatedLists.addRow(new VisualEditor.DataRow(cr.getRelationshipName(), cr.getRelationshipName()));
                    // system.debug('====child relationship name==='+cr.getRelationshipName());
                }
            }
		}
    }

    public override VisualEditor.DataRow getDefaultValue(){
        return relatedLists.get(0);
    } 

    public override VisualEditor.DynamicPickListRows getValues() {
        return relatedLists;
    }
}