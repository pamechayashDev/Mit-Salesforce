public with sharing class LogUtil {

    @AuraEnabled
    public static void logLwcError(String exceptionDetails) {
        HandledException ex = new HandledException(exceptionDetails);
        HandleLogException.logException(ex);
        System.debug(exceptionDetails);
    }
}