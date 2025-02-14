@IsTest
public with sharing class TestUtility {
    static Integer s_num = 1;

    @IsTest
    static void testGetFakeId() {
      Id id = TestUtility.getFakeId(TLO_Case__c.sObjectType);
    }

   public static String getFakeId(Schema.SObjectType sot)
   {
      String result = String.valueOf(s_num++);
      return sot.getDescribe().getKeyPrefix() +
         '0'.repeat(12-result.length()) + result;
   }

   public static User createTloUser(){
      Profile p = [SELECT Id FROM Profile WHERE Name = 'TLO User'];

      // create User
      User u = new User();

      u.FirstName = 'TLO';
      u.LastName = 'User';
      u.Email = 'test' + System.now().getTime() + '@mit.edu.' + UserInfo.getOrganizationId().toLowerCase();
      u.Username = 'astest' + System.now().getTime() + '@mit.edu.' + UserInfo.getOrganizationId().toLowerCase();
      u.Alias = 'astest';
      u.ProfileId = p.Id;
      u.TimeZoneSidKey    = 'America/New_York';
      u.LocaleSidKey      = 'en_US';
      u.EmailEncodingKey  = 'UTF-8';
      u.LanguageLocaleKey = 'en_US';

      insert u;
      System.debug('u contains ' + u);

      PermissionSetGroup tloGeneralPsg = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName='TLO_General'];
      // force calculation of the PSG if it is not already Updated
      if (tloGeneralPsg.Status != 'Updated') {
         Test.calculatePermissionSetGroup(tloGeneralPsg.Id);
      }

      insert new PermissionSetAssignment(AssigneeId=u.Id, PermissionSetGroupId=tloGeneralPsg.Id);

      insert new PermissionSetAssignment(AssigneeId=u.Id,
               PermissionSetId=[SELECT Id FROM PermissionSet WHERE Name='Query_All_Files'].Id);               

      return u;
	}

   public static User createSystemAdministrator(){
      Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

      // create User
      User u = new User();

      u.FirstName = 'Test';
      u.LastName = 'System Administrator';
      u.Email = 'test' + System.now().getTime() + '@mit.edu.' + UserInfo.getOrganizationId().toLowerCase();
      u.Username = 'testsysadmin' + System.now().getTime() + '@mit.edu.' + UserInfo.getOrganizationId().toLowerCase();
      u.Alias = 'tsadmin';
      u.ProfileId = p.Id;
      u.TimeZoneSidKey    = 'America/New_York';
      u.LocaleSidKey      = 'en_US';
      u.EmailEncodingKey  = 'UTF-8';
      u.LanguageLocaleKey = 'en_US';

      insert u;
      System.debug('u contains ' + u);

      return u;
   }

   public static User createIpiaAdminUser() {
      User u = TestUtility.createTloUser();

      PermissionSetGroup tloIpiaAdminPsg = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName='TLO_IPIA_Admin'];
      // force calculation of the PSG if it is not already Updated
      if (tloIpiaAdminPsg.Status != 'Updated') {
         Test.calculatePermissionSetGroup(tloIpiaAdminPsg.Id);
      }

      insert new PermissionSetAssignment(AssigneeId=u.Id, PermissionSetGroupId=tloIpiaAdminPsg.Id);

      return u;
   }
}