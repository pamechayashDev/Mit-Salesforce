public with sharing class StringUtils {
    
    public static String convertMapToQueryString(Map<string, string> queryParams) {
        String queryParamsStr = '';
        for (String key : queryParams.keySet()) {
            if (queryParamsStr.length() > 0) {
                queryParamsStr += '&';
            }
            String value = queryParams.get(key);
            queryParamsStr += key + '=' + value;
        }

        return queryParamsStr;
    }

    public static String ifNullReplace(String checkValue, String defaultValue) {
        return checkValue != null ? checkValue : defaultValue;
    }

    public static String removeNonNumericCharacters(String value) {
        if (value == null) {
            return null;
        }
        Pattern nonAlphanumeric = Pattern.compile('[^0-9]');
        Matcher matcher = nonAlphanumeric.matcher(value);
        return matcher.replaceAll('');
    }

    public static Set<String> toSetStrings(Set<Decimal> values) {
        Set<String> stringSet = new  Set<String>();
        for (Decimal x : values) {
            stringSet.add(String.valueOf(x));
        }
        return stringSet;        
    }
    
}