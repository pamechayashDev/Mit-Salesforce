public with sharing  class IPIAContentVersionWrapper implements Comparable  {
    DocumentLinkProcessor.FileNameDefinition fileNameDefinition;
    public ContentVersion contentVersion;

    public IPIAContentVersionWrapper(ContentVersion contentVersion, DocumentLinkProcessor.FileNameDefinition fileDefinition) {
        this.contentVersion = contentVersion;
        this.fileNameDefinition = fileDefinition;
    }
    public Integer compareTo(Object compareTo) {
         if (compareTo == null) return 1; // Move null values to the end
         IPIAContentVersionWrapper a = this;
         IPIAContentVersionWrapper b = (IPIAContentVersionWrapper)compareTo;

         if (a.fileNameDefinition == null) return 1; // Move null values to the end
         if (b.fileNameDefinition == null) return 1; // Move null values to the end

         if (a.fileNameDefinition.fileWriteDate == null) return 1; // Move null values to the end
         if (b.fileNameDefinition.fileWriteDate == null) return 1; // Move null values to the end

         Integer compare = compareDatesTo(a.fileNameDefinition.fileWriteDate, b.fileNameDefinition.fileWriteDate);
         return compare * (-1); // descending
    }

    private Integer compareDatesTo(DateTime a, DateTime b) {
        if (a == b) return 0;
        return (a < b) ? -1 : 1 ;
    }
}