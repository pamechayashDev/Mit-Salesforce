public class Helpers {
    public static String YesNoFromBoolean(Boolean value) {
        if (value == true) {
            return 'Yes';
        }

        return 'No';
    }

    public static Boolean BooleanFromYesNo(String value) {
        if (value != null) {
            if (value.toUpperCase() == 'YES') {
                return true;
            }
        }

        return false;
    }

    public static Boolean signedStatusBoolean(String value) {
        if (value != null) {
            if (value.toUpperCase() == 'PENDING') {
                return false;
            }
            if (value.toUpperCase() == 'OPTED OUT') {
                return false;
            }
            if (value.toUpperCase() == 'YES') {
                return true;
            }
        }

        return false;
    }

   /*
   * Forrester Birth day is not a Date but a birth DAY format MMdd
   */
   public static String birthDayFromValue(Date value) {
        if( value == null ) {
            return null;
        }
         return DateTime.newInstance(
                value.year(), value.month(), value.day()
            ).format('MMdd');
    }

    public static Boolean booleanFromYesNoUnknown (String value) {
        if (value == null || value.toUpperCase() == 'UNKNOWN') {
           return null;
        }
        return (value.toUpperCase() == 'YES' || value.toUpperCase() == 'Y' || value.toUpperCase() == 'TRUE' ) ? true : false;
    }

    public static String formatDate(Date inputDate, String formatString) {
        if (inputDate == null) {
            return null;
        }
        DateTime inputDateTime = DateTime.newInstance(inputDate.year(), inputDate.month(), inputDate.day());
        return inputDateTime.format(formatString);
    }

    public static String formatDateGMT(Date inputDate, String formatString) {
        if (inputDate == null) {
            return null;
        }
        Time myTime = Time.newInstance(0, 0, 0, 0);
        DateTime inputDateTime = DateTime.newInstanceGMT(inputDate, myTime);
        return inputDateTime.formatGMT(formatString);
    }

    /* If we use external Object Date field type with the Custom Object Date field type. The value will be stored in
     Oracle on the previous day at 20:00.
     OData uses Edm.DateTimeOffset, to save the GMT datetime in Oracle the offset need to be corrected
     The aim is to save this as Midnight DateTime in Oracle.
     To View the jason dateTime values from OData
     https://shirley-tlo-odata.api-dev.mit.edu/odata.rsc/Forrester_CONTACT?%24top=51&%24orderby=CONTACT_RECID&%24count=true&%24filter=indexOf(CONTACT_RECID,%272450%27)%20ne%20-1
    */
    public static DateTime dateToEdmDateTimeOffset(Date inputDate) {
        if (inputDate == null) {
            return null;
        }

        Time myTime = Time.newInstance(0, 0, 0, 0);
        Date dt = Date.newInstance(inputDate.year(), inputDate.month(), inputDate.day());
        DateTime inputDateTime = DateTime.newInstanceGMT(dt, myTime);
        // TODO dont know where in OData this is configured to be America/New_York
        TimeZone tz = TimeZone.getTimeZone('America/New_York');
        Integer offset = tz.getOffset(inputDateTime);
        Integer hours = (offset / (60 * 60 * 1000));
        System.debug('offset (hours): ' + hours);

        // Example value shown in SF: 2024-02-12T05:00:00.000+0000 will be saved as midnight since the offset will be removed
        // Jason example value from OData rest response: 2024-08-10T00:00:00.000-04:00 OData will subtract so we need to add the inverse offset
        return inputDateTime.addHours(hours * -1);

    }

    public static Date dateTimeToDate (DateTime dt) {
        if (dt == null) {
            return null;
        }
        Date d = Date.newInstance(dt.year(), dt.month(), dt.day());
        return d;
    }
    public static String formatDate(Date inputDate) {
        DateTime dt = DateTime.newInstance(inputDate.year(), inputDate.month(), inputDate.day());
        return formatDate(dt);
    }

    public static String formatDate(Datetime dt) {
        return dt.format('yyyy-MM-dd');
    }

    // Get a Department head for disclosure that is not Delegated_To__c
    public static Map<Id, Department_Head__c> toDisclosureDeptHeadLookup(List<Department_Head__c>  deptHeadsQuery) {
       Map<Id, Department_Head__c> disclosureDeptHeadLookup = new Map<Id, Department_Head__c>();
       if (!deptHeadsQuery.isEmpty()) {
            for(Department_Head__c deptHead : deptHeadsQuery) {
               if (deptHead.Delegated_To__c == null) { // dont want delegated Department Heads. There should always be one
                   disclosureDeptHeadLookup.put(deptHead.Disclosure__c, deptHead);
               }
           }
       }
       return disclosureDeptHeadLookup;
    }

    // Get List of Department Heads that does not have Delegated_To__c value. This will happen if a new Item is inserted and the delegated from has not set the Delegated_To__c value
    public static Map<Id, List<Department_Head__c>> toDisclosureDeptHeadListLookup(List<Department_Head__c>  deptHeadsQuery) {
       Map<Id, List<Department_Head__c>> disclosureDeptHeadListLookup = new Map<Id, List<Department_Head__c>>();
       if (!deptHeadsQuery.isEmpty()) {
            for(Department_Head__c deptHead : deptHeadsQuery) {
               if (deptHead.Delegated_To__c == null) {
                   if (disclosureDeptHeadListLookup.get(deptHead.Disclosure__c) == null) {
                    disclosureDeptHeadListLookup.put(deptHead.Disclosure__c, new List<Department_Head__c>());
                   }
                   disclosureDeptHeadListLookup.get(deptHead.Disclosure__c).add(deptHead);
               }
           }
       }
       return disclosureDeptHeadListLookup;
    }

    public static Boolean IsNonMitSalary(String value) {
        if (value != null) {
            if (value == 'Non-MIT' || value == 'Both') {
                return true;
            }
        }

        return false;
    }

    public static Boolean IsWorkDoneOutsideMit(String value) {
        if (value != null) {
            if (value == 'Yes') {
                return true;
            }
        }

        return false;
    }

    public static String stringFromMultiPicklist(string selectedItems, Map<String,String> pickListMap) {
        String returnValue;
        if (selectedItems != null) {
            List<String> selectedItemList = selectedItems.split(';');
            for(String selectedItem : selectedItemList ) {
                if (returnValue != null) {
                    returnValue = returnValue + ', ' + pickListMap.get(selectedItem);
                } else {
                    returnValue = pickListMap.get(selectedItem);
                }
            }
        }
        return returnValue;
    }

    public static List<String> labelsFromMultiPicklist(string selectedItems, Map<String,String> pickListMap) {
       List<String> returnValues = new List<String>();
       if (selectedItems != null) {
           List<String> selectedItemList = selectedItems.split(';');
           for(String selectedItem : selectedItemList ) {
                returnValues.add(pickListMap.get(selectedItem));
           }
       }
       return returnValues;
    }

    public static String labelFromPicklist(string selectedItem, Map<String,String> pickListMap) {
        String returnValue = pickListMap.get(selectedItem);
        return returnValue;
     }

    public static String convertSemicolonToComma(String value) {
        if (value != null) {
            return value.replace(';', ', ');
        }
        return value;
    }

    /**
     * Helper function to determine if kerb is active from mitMoiraStatus
     * 
        REGISTERABLE = 0, //  username hasn't been assigned
           ACTIVE = 1, // common case and represents an active account
        HALF_REGISTERED = 2, // transitional state that occurs after you have chosen a username and before you set an password
        DELETED = 3, // deactivated account
        NOT_REGISTERED = 4, // historical
        ENROLLED_REGISTERABLE = 5, // historical
        ENROLLED_NOTREGISTERABLE = 6, // historical
        HALF_ENROLLED = 7, // historical
        REGISTERABLE_KERB_ONLY = 8, // kerb only accounts (lincoln)
            ACTIVE_KERB_ONLY = 9, // kerb only accounts (lincoln)
        SUSPENDED = 10, // suspended locks out WIN/EXCHANGE and set DISALLOW_ALL
        EXPIRED = 11, // same as 10, pwchange required is set
        EXPIRED_KERB_ONLY = 12 // same as 11 but for lincoln
     */
    public static Boolean isActiveKerb(String mitMoiraStatus) {
        if (mitMoiraStatus == '1' || mitMoiraStatus == '9') {
            return true;
        }
        return false;
    }

    public static Boolean isMitEmailAddress(String email) {
       return Pattern.matches('(.)*@(.)*[\\.]?mit.edu(.)*', email);
    }

    /**
     * Helper function to calculate a Contact's Display Name
     */
    public static String getDisplayName(
        String preferredFirstName,
        String legalFirstName,
        String legalMiddleName,
        String legalLastName
    ) {
        String name;
        if (preferredFirstName != null && preferredFirstName != '') {
            name = preferredFirstName.trim();
        } else {
            name =
                (legalFirstName != null ? legalFirstName.trim() : '') +
                ' ' +
                (legalMiddleName != null ? legalMiddleName.trim() : '');
        }

        name = name.trim();
        name = name + ' ' + (legalLastName != null ? legalLastName.trim() : '');
        name = name.trim();

        return name;
    }
}