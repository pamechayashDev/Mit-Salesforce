@IsTest
public with sharing class HelpersTest {
    @IsTest
    static void testUtility() {
       System.assert(Helpers.booleanFromYesNoUnknown('Yes') == true , 'Boolean value from Yes/No/Unknown error');
       System.assert(Helpers.birthDayFromValue(Date.newInstance(2020, 7, 17)) == '0717' , 'BirthDay value from Date error');
    }

   @IsTest
   static void testLabelsFromMultiPicklist() {
      List<String> labels = Helpers.labelsFromMultiPicklist('Electronic Disclosure', DisclosureRecordFetch.getInventionDisclosureTypeOfPresentationPicklist());
      System.assert(labels[0] == 'Electronic Disclosure' , 'Labels from MultiPicklist error');
   }

   @IsTest
   static void testEmail() {
      // Positive testing
      System.assert(Helpers.isMitEmailAddress('abc@mit.edu'), 'abc@mit.edu');
      System.assert(Helpers.isMitEmailAddress('abc@ll.mit.edu'), 'abc@ll.mit.edu');
      System.assert(Helpers.isMitEmailAddress('abc2@ll.mit.edu'), 'abc2@ll.mit.edu');
      System.assert(Helpers.isMitEmailAddress('abc2@alum.mit.edu'), 'abc2@alum.mit.edu');


      // Negative testing
      System.assert(!Helpers.isMitEmailAddress('abc@harvard.edu'), 'abc@harvard.edu');
      System.assert(!Helpers.isMitEmailAddress('abc2@harvard.edu'), 'abc2@harvard.edu');
      System.assert(!Helpers.isMitEmailAddress('amit.edu@harvard.edu'), 'amit.edu@harvard.edu');
      System.assert(!Helpers.isMitEmailAddress('a-mit.edu@harvard.edu'), 'a-mit.edu@harvard.edu');
      System.assert(!Helpers.isMitEmailAddress('a.mit.edu@harvard.edu'), 'a.mit.edu@harvard.edu');
   }

   @IsTest
   static void testGetDisplayName() {
      System.assertEquals(
         'John Peter',
         Helpers.getDisplayName(
            'John',
            'James',
            'Mark',
            'Peter'
         ), 'Expected display name to be "Preferred Name + Last Name"'
      );

      System.assertEquals(
         'James Mark Peter',
         Helpers.getDisplayName(
            null,
            'James',
            'Mark',
            'Peter'
         ), 'Expected display name to be "First Name + Middle Name + Last Name"'
      );

      System.assertEquals(
         'James Peter',
         Helpers.getDisplayName(
            null,
            'James',
            null,
            'Peter'
         ), 'Expected display name to be "First Name + Last Name"'
      );

      System.assertEquals(
         'James Peter',
         Helpers.getDisplayName(
            null,
            'James',
            ' ',
            'Peter'
         ), 'Expected display name to trim out extra spaces'
      );

      System.assertEquals(
         'James Mark Peter',
         Helpers.getDisplayName(
            null,
            'James',
            'Mark',
            ' Peter'
         ), 'Expected display name to trim out extra spaces'
      );

      System.assertEquals(
         'John Peter',
         Helpers.getDisplayName(
            'John ',
            'James',
            'Mark',
            'Peter'
         ), 'Expected display name to trim out extra spaces'
      );
   }

}