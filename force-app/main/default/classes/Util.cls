/**
 * Concept's for now and today dates based on 
 *  - https://salesforce.stackexchange.com/questions/61242/salesforce-is-there-any-way-to-set-system-time-in-test-class
 * 
 * NOTE that now & today are static variabels in this class, for which SF accounts for resetting when running unit tests. 
 * - https://ideas.salesforce.com/s/idea/a0B8W00000GdX0YUAV/remember-static-variables-set-during-testsetup-annotated-methods
 *       > Update from Salesforce Josh Kaplan 8 years ago We intentionally clear out static variables between each test method.  
 * - https://salesforceblue.com/apex-unit-tests-simplified/
 *       > If the value of a static member variable in a test class is changed in a testSetup or test method, the new value isn’t preserved. 
 *       > Other test methods in this class get the original value of the static member variable. 
 *       > This behavior also applies when the static member variable is defined in another class and accessed in test methods.
 */
public with sharing class Util {   

    //  -----------------------------------------------
    //  now     : getter/setter to have testemthod-driven different values for now;
    //  -----------------------------------------------
    @TestVisible
    private static Datetime now;

    @TestVisible
    private static Date today;

    public static Datetime now() {
        return now == null ? Datetime.now() : now;
    }

    //  -----------------------------------------------
    //  today : getter/setter to have testemthod-driven different values for today; see also now
    //  -----------------------------------------------
    public static Date today() {
        return today == null ? Date.today() : today;
    }
}