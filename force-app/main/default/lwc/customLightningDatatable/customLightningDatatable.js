import LightningDatatable from "lightning/datatable";
import relatedToCustomDataTypeTemplate  from './relatedToCustomDataType.html' 

export default class CustomLightningDatatable extends LightningDatatable{
    static customTypes = {
     relatedToCustomDataTypeTemplate: {
      template:relatedToCustomDataTypeTemplate,
      standardCellLayout: true,
      typeAttributes: ['RelatedTo','sObjectUrl','recordId','recordTypeName','relatedToData']
    },

  };
}