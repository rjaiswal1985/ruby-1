/***********************************************************************************************************************
 * Name: CM_CustomerInvoiceService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class for Customer Invoice
 * TestClass : CM_CustomerInvoiceService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          Service class to retrieve Customer Invoice data to upsert
 ***********************************************************************************************************************/
public with sharing class CM_CustomerInvoiceService {
    /**CM_ReltioHCOInboundPayloadTriggerHandler
     * @description : Method returns List of Customer Invoices
     */
    public static Map < String, Organization_E_Invoice__c > upsertCustomerInvoice(Map < String, Map < String, Object >> objParser, Account account,String masterRecordId) {
        CM_LoggerUtil.logger(new CM_Log('OrganizationCustomerInvoice','Info',String.valueof(Datetime.now()), masterRecordId, 'Customer Invoice Creation Service started'));  
        final Map < String, Organization_E_Invoice__c > cusInvoiceMap = new Map < String, Organization_E_Invoice__c > ();
        Organization_E_Invoice__c cusInvoice;
        Map < String, Object > key2value = new Map < String, Object > ();
        for (String objectKey: objParser.keySet()) {
            cusInvoice = new Organization_E_Invoice__c();
            cusInvoice.Account__r = new Account(MDM_Id__c = account.MDM_Id__c);
            cusInvoice.Timestamp__c = account.Timestamp__c;
            cusInvoice.TimeStamp_Decimal__c = account.TimeStamp_Decimal__c;
            key2value = objParser.get(objectKey);
            for (String key: key2value.keyset()) {
                cusInvoice.put(key, key2value.get(key));
            }
            cusInvoiceMap.put(objectKey, cusInvoice);
        }
        CM_LoggerUtil.logger(new CM_Log('OrganizationCustomerInvoice','Info',String.valueof(Datetime.now()), masterRecordId, 'Customer Invoice Creation Service completed.'));  
        return cusInvoiceMap;
    }
    private CM_CustomerInvoiceService() {}
}