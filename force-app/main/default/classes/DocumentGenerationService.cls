public with sharing class DocumentGenerationService {
    public static String DEFAULT_COVER_PAGE = 'Cover_Page_Disclosure';

    public static string generate(String templateKey, Object variables, Boolean includeCoverPage) {
        System.debug('DocumentGenerationService START: ');

        try {           
            Document_Template__c docTemplate = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = :templateKey LIMIT 1];
            String htmlValue  = docTemplate.Raw_HTML_Tempalte__c;
            
            List<String> htmlParts = htmlValue.split('<style><\\/style>');
            if (htmlParts.size() == 2) {
                Document_Template__c style = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'style' LIMIT 1];
                String styleValue  = style.Raw_HTML_Tempalte__c;
                htmlValue  = htmlParts.get(0) + styleValue + htmlParts.get(1);
            }

             if (templateKey != 'Inventor' && includeCoverPage) {
                htmlParts = htmlValue.split('<div id="CoverPage"><\\/div>');
                if (htmlParts.size() == 2) {
                    Document_Template__c coverPage = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = :coverPage() LIMIT 1];
                    String coverPageValue  = coverPage.Raw_HTML_Tempalte__c;
                    List<String> coverPageParts = coverPageValue.split('<body>');
                    if (coverPageParts.size() == 2) {
                        coverPageParts = coverPageParts.get(1).split('<\\/body>');
                        if (coverPageParts.size() == 2) {
                            htmlValue = htmlParts.get(0) + coverPageParts.get(0) + htmlParts.get(1);
                        }
                    }
                }
            }

            if (templateKey != 'Inventor') {
                htmlParts = htmlValue.split('<div id="Inventor"><\\/div>');
                if (htmlParts.size() == 2) {
                    Document_Template__c inventor = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'Inventor' LIMIT 1];
                    String inventorValue  = inventor.Raw_HTML_Tempalte__c;
                    List<String> inventorParts = inventorValue.split('<body>');
                    if (inventorParts.size() == 2) {
                        inventorParts = inventorParts.get(1).split('<\\/body>');
                        if (inventorParts.size() == 2) {
                            htmlValue = htmlParts.get(0) + inventorParts.get(0) + htmlParts.get(1);
                        }
                    }
                }
            }
            String templateFooterKey = 'footer';
            if (templateKey == coverPage()) {
                templateFooterKey = coverPage() + '_footer';
            }
            Document_Template__c footerTemplate = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = :templateFooterKey LIMIT 1];
            String footerValue  = footerTemplate.Raw_HTML_Tempalte__c;
    
            DocGenRequestWrapper docGenReq = new DocGenRequestWrapper();
            docGenReq.htmlTemplate = htmlValue;
            docGenReq.variables = variables;
            docGenReq.footerTemplate = footerValue;


            //System.debug(JSON.serialize(docGenReq));

            Map<string, string> headers = new Map<String, String>();
            headers.put( 'Content-Type',  'application/json;charset=UTF-8');
    
            System.debug('DocumentGenerationService calling pdf generator api: ');
            String apiName = 'pdfGeneratorApi';
            Blob response = AwsApiCall.restPostGetBodyAsBlob(apiName, '/generate/from-html', headers, JSON.serialize(docGenReq));
            System.debug('DocumentGenerationService DONE calling pdf generator api: ');
    
            System.debug('DocumentGenerationService END: ');
            String base64Pdf = EncodingUtil.base64Encode(response);
            return base64Pdf;
        } catch (Exception e) {
            System.debug('DocumentGenerationService Exception: ');
            HandleLogException.logException(e);
            throw new CalloutException(e.getMessage());
        }
    }

   @AuraEnabled(cacheable=true)
     public static String getReviewPdfFileAsBase64String(String disclosureIdStr) {
        DisclosureWrapper disWrapper = DisclosureDao.getDisclosureWrapperById(disclosureIdStr, null);
        Boolean includeCoverPage = (disWrapper.disclosure.Status__c == 'Approved')? true: false;
        String base64Pdf = DocumentGenerationService.generate(disWrapper.recordTypeDeveloperName, disWrapper, includeCoverPage);
        return base64Pdf;
    }

  public static String coverPage() {
    try {
        return ConfigurationBuilder.getConfigurationToString('coverPageDisclosure');
    } catch (ConfigurationBuilder.MissingConfigurationException ex) {
        return DEFAULT_COVER_PAGE;
    }
  }

  public static string generate(String coverPageKey, String templateKey, Object variables) {
        System.debug('DocumentGenerationService START: ');

        try {
            Document_Template__c docTemplate = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = :coverPageKey LIMIT 1];
            String htmlValue  = docTemplate.Raw_HTML_Tempalte__c;

            List<String> htmlParts = htmlValue.split('<style><\\/style>');
            if (htmlParts.size() == 2) {
                Document_Template__c style = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = 'style' LIMIT 1];
                String styleValue  = style.Raw_HTML_Tempalte__c;
                htmlValue  = htmlParts.get(0) + styleValue + htmlParts.get(1);
            }

            if (templateKey != null) {
                htmlParts = htmlValue.split('<div id="ContentPage"><\\/div>');
                if (htmlParts.size() == 2) {
                    Document_Template__c contentPage = [select Raw_HTML_Tempalte__c from Document_Template__c where Template_Key__c = :templateKey LIMIT 1];
                    String contentPageValue  = contentPage.Raw_HTML_Tempalte__c;
                    List<String> contentPageParts = contentPageValue.split('<body>');
                    if (contentPageParts.size() == 2) {
                        contentPageParts = contentPageParts.get(1).split('<\\/body>');
                        if (contentPageParts.size() == 2) {
                            htmlValue = htmlParts.get(0) + contentPageParts.get(0) + htmlParts.get(1);
                        }
                    }
                }
            }


            DocGenRequestWrapper docGenReq = new DocGenRequestWrapper();
            docGenReq.htmlTemplate = htmlValue;
            docGenReq.variables = variables;
            docGenReq.footerTemplate = '';

            System.debug(JSON.serialize(docGenReq));

            Map<string, string> headers = new Map<String, String>();
            headers.put( 'Content-Type', 'application/json;charset=UTF-8');

            System.debug('DocumentGenerationService calling pdf generator api: ');
            String apiName = 'pdfGeneratorApi';
            Blob response = AwsApiCall.restPostGetBodyAsBlob(apiName, '/generate/from-html', headers, JSON.serialize(docGenReq));
            System.debug('DocumentGenerationService DONE calling pdf generator api: ');

            System.debug('DocumentGenerationService END: ');
            String base64Pdf = EncodingUtil.base64Encode(response);
            return base64Pdf;
        } catch (Exception e) {
            System.debug('DocumentGenerationService Exception: ');
            HandleLogException.logException(e);
            throw new CalloutException(e.getMessage());
        }
    }

 @AuraEnabled(cacheable=true)
 public static String getCrdrNotesPdfFileAsBase64String(String crdrIdStr) {
        CrdrWrapper crdrWrapper = CrdrDao.getCrdrWrapperById(crdrIdStr);
        String base64Pdf = DocumentGenerationService.generate('Cover_Page_CRDRNotes', null, crdrWrapper);
        return base64Pdf;
 }

 @AuraEnabled(cacheable=true)
 public static String getUtilizationReportPdfFileAsBase64String(String utilReportIdStr) {
        UtilizationReportWrapper utilReportWrapper = UtilizationReportDao.getUtilizationReportWrapperById(utilReportIdStr);
        String contentPage = null;
        String lSoD = utilReportWrapper.utilizationReport.Latest_Stage_of_Development__c;
        if (lSoD == 'Not Licensed') {
            contentPage = 'Not_Licensed_Utilization_Report';
        }
        if (lSoD == 'Licensed') {
            contentPage = 'Licensed_Utilization_Report';
        }
        if (lSoD == 'Commercialized') {
            contentPage = 'Commercialized_Utilization_Report';
        }

        String base64Pdf = DocumentGenerationService.generate('Cover_Page_Utilization_Report', contentPage, utilReportWrapper);
        return base64Pdf;
 }

}