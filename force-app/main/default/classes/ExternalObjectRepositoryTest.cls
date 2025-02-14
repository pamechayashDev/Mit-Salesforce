/**
 * Created by Andreas du Preez on 2024/02/28.
 */

@IsTest
public with sharing class ExternalObjectRepositoryTest {

    @IsTest
    public static void getPatentBreakdownIncomeSummarySuccessTest() {
        List<Forrester_SHIR_CASE_FH_INCOME_SUMMARY__x> result = ExternalObjectRepository.getPatentBreakdownIncomeSummary('4211');

        // Because we're dealing with external objects, we can't get the actual data.
        System.assertEquals(true, result != null);
        System.assertEquals(0, result.size());
    }

    @IsTest
    public static void getPatentBreakdownIncomeSummaryNoResultTest() {
        List<Forrester_SHIR_CASE_FH_INCOME_SUMMARY__x> result = ExternalObjectRepository.getPatentBreakdownIncomeSummary('');

        System.assertEquals(true, result != null);
        System.assertEquals(0, result.size());
    }

    @IsTest
    public static void getFiscalYearsSuccessTest() {
        List<Forrester_FISCAL_YEAR__x> result = ExternalObjectRepository.getFiscalYears();

        // Because we're dealing with external objects, we can't get the actual data.
        System.assertEquals(true, result != null, 'There are results for getFiscalYears()');
        System.assertEquals(0, result.size(), 'There are results for getFiscalYears()');
    }
  
    @IsTest
    public static void getOutstandingPatentCostsSuccessTest() {
        List<Forrester_SHIR_CASE_FH_PATENT_COSTS_D__x> result = ExternalObjectRepository.getOutstandingPatentCosts('4211');

        // Because we're dealing with external objects, we can't get the actual data.
        System.assertEquals(true, result != null);
        System.assertEquals(0, result.size());
    }

    @IsTest
    public static void getOutstandingPatentCostsNoResultTest() {
        List<Forrester_SHIR_CASE_FH_PATENT_COSTS_D__x> result = ExternalObjectRepository.getOutstandingPatentCosts('');

        System.assertEquals(true, result != null);
        System.assertEquals(0, result.size());
    }

    @IsTest
    public static void getUnpaidInvoicesSuccessTest() {
        List<Forrester_SHIR_CASE_UNPAID_INVOICES__x> result = ExternalObjectRepository.getUnpaidInvoices('4211');

        // Because we're dealing with external objects, we can't get the actual data.
        System.assertEquals(true, result != null);
        System.assertEquals(0, result.size());
    }

    @IsTest
    public static void getUnpaidInvoicesNoResultTest() {
        List<Forrester_SHIR_CASE_UNPAID_INVOICES__x> result = ExternalObjectRepository.getUnpaidInvoices('');

        System.assertEquals(true, result != null);
        System.assertEquals(0, result.size());
    }

    @IsTest
    public static void getExternalCommentsTest() {
        List<Forrester_SHIR_COMMENTS_VIEW__x> result =  ExternalObjectRepository.getExternalComments('4906350', 'AGREEMENT', 'ADMIN');

        System.assertEquals(true, result != null);
        System.assertEquals(0, result.size());
    }


}