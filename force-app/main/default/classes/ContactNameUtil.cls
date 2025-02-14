public with sharing class ContactNameUtil {

    public static String toFullName(String firstName, String middleName, String lastName, Boolean includeMiddle) {
        String resultStr = '';
        if (firstName != null) {
            if (firstName.length() > 0) {
                resultStr = firstName;
            }
        }

        if (includeMiddle == true) {
            if (middleName != null) {
                if (middleName.length() > 0) {
                    resultStr = resultStr + ' ' + middleName;
                }
            }
        }

        if (lastName != null) {
            if (lastName.length() > 0) {
                resultStr = resultStr + ' ' + lastName;
            }
        }

        return resultStr;
    }
}