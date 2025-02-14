public with sharing class ApiConfigurationBuilder {
    public class MissingApiConfigurationException extends Exception {}
    private List<ApiConfigurations__c> configs = new List<ApiConfigurations__c>();

    public ApiConfigurationBuilder academicHistoryApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'academicHistoryApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder appointmentHistoryApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'appointmentHistoryApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder forresterApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'forresterApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder guestAccountApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'guestAccountApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder researchApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'researchApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder piDashApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'piDashApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder accountApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'accountApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder peopleSearchApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'peopleSearchApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder digitalIdApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'digitalIdApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder notificationApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'notificationApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }
    public ApiConfigurationBuilder pdfGeneratorApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'pdfGeneratorApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder mitDocusignApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'mitDocusignApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public ApiConfigurationBuilder iedisonApi(String base, String path) {
        configs.add(new ApiConfigurations__c(Name = 'iedisonApi', Api_Base__c = base, Api_Path__c = path));
        return this;
    }

    public List<ApiConfigurations__c> build(){
        return configs;
    }

    public static String getApiBaseToString(String instanceName) {
        ApiConfigurations__c config = ApiConfigurations__c.getInstance(instanceName);
        if (config != null) {
            return config.Api_Base__c;
        } else {
            throw new MissingApiConfigurationException(instanceName);
        }
    }

    public static String getApiPathToString(String instanceName) {
        ApiConfigurations__c config = ApiConfigurations__c.getInstance(instanceName);
        if (config != null) {
            return config.Api_Path__c;
        } else {
            throw new MissingApiConfigurationException(instanceName);
        }
    }

}