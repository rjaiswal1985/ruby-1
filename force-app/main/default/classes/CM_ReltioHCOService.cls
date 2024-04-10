/***********************************************************************************************************************
 * Name: CM_ReltioHCOService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class handles Account Creation, Service invoked from platform event trigger handler
 * TestClass : CM_ReltioHCOService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          Account Creation Service 
 ***********************************************************************************************************************/
public with sharing class CM_ReltioHCOService {
    /* Account String */
    final static string ACCOUNTSTRING = 'Account';
    /**    
     * @description :  Method to parse input json and get Account data
     * @Parameters : input json, process name from platfrom event
     */
    public static Map < String, Map < String, Sobject >> upsertHCOServices(String inputJson, Map < String, CM_ReltioHandlerService.SobjectData > process2Metadata) {
        final Map < String, Map < String, Map < String, Object >>> key2value = CM_JSONParser.objectJsonParsers(inputJson, process2Metadata.get(CM_ReltioConstants.RELTIOHCO));
        return upsertHCOSelector(key2value);
    }
    /**     
     * @description : Retrieves data of Account and related Sobjects
     */
    public static Map < String, Map < String, Sobject >> upsertHCOSelector(Map < String, Map < String, Map < String, Object >>> key2value) {
        final Map < String, Map < String, Sobject >> resultMap = new Map < String, Map < String, Sobject >> ();
        Map < String, Organization_Communication__c > cusCommunication = new Map < String, Organization_Communication__c > ();
        final Map < String, Account > accountMap = new Map < String, Account > ();

        Account account = new Account();
        if (key2value.containsKey(ACCOUNTSTRING)) {
            account = CM_AccountService.upsertAccount(key2value.get(ACCOUNTSTRING));
        }

        if (key2value.containsKey('Organization_Communication__c')) {
            cusCommunication = CM_CustomerInformationService.upsertCommInformation(key2value.get('Organization_Communication__c'), account);
            resultMap.put('Organization_Communication__c', cusCommunication);
        }

        if (key2value.containsKey('Organization_E_Invoice__c')) {
            final Map < String, Organization_E_Invoice__c > cosInvoiceMap = CM_CustomerInvoiceService.upsertCustomerInvoice(key2value.get('Organization_E_Invoice__c'), account);
            resultMap.put('Organization_E_Invoice__c', cosInvoiceMap);
        }

        //update phone and email in the Account from Customer Communication
        account = getAccountList(account, cusCommunication.values());
        accountMap.put(account.MDM_Id__c, account);
        resultMap.put(ACCOUNTSTRING, accountMap);

        return resultMap;
    }
    /**     
     * @description : Populates Account primary phone, email
     */
    private static Account getAccountList(Account account, List < Organization_Communication__c > cusInformList) {
        for (Organization_Communication__c cusInformation: cusInformList) {
            if (cusInformation.Subtype__c == CM_ReltioConstants.PRIMARYPHONE) {
                account.Phone = cusInformation.value__c;
            }
            if (cusInformation.Subtype__c == CM_ReltioConstants.PRIMARYEMAIL) {
                account.Company_Email__c = cusInformation.value__c;
            }
        }
        account.ShippingStreet = CM_ReltioHandlerService.addressLine(account.ShippingStreet,account.Address_Line_1__c,true);
        account.ShippingStreet = CM_ReltioHandlerService.addressLine(account.ShippingStreet,account.Address_Line_2__c,false);
        account.ShippingStreet = CM_ReltioHandlerService.addressLine(account.ShippingStreet,account.Address_Line_3__c,false);
        account.ShippingStreet = CM_ReltioHandlerService.addressLine(account.ShippingStreet,account.Address_Line_4__c,false);

        account.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(account.Native_Address__Street__s,account.Native_Address_Line_1__c,true);
        account.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(account.Native_Address__Street__s ,account.Native_Address_Line_2__c,false);
        account.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(account.Native_Address__Street__s ,account.Native_Address_Line_3__c,false);
        account.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(account.Native_Address__Street__s ,account.Native_Address_Line_4__c,false);

        return account;
    }   
    public  static Map<String, Map < String, Sobject >> getOldAccountMap(Map <String, Map < String, Sobject >> upsertNewMap) {
        Set<String> recordId = upsertNewMap.get(ACCOUNTSTRING).keyset();
        final Map <String, Map < String, Sobject >> upsertOldMap = new Map < String, Map < String, Sobject >> ();
        upsertOldMap.put(ACCOUNTSTRING,new Map <String, Sobject>());  
        upsertOldMap.put('Organization_Communication__c',new Map <String, Sobject>());  
        upsertOldMap.put('Organization_E_Invoice__c',new Map <String, Sobject>());  
        for(Account acc : [Select Id,MDM_Id__c,TimeStamp_Decimal__c,
                        (Select Id,MDM_Id__c,Account__r.MDM_Id__c,TimeStamp_Decimal__c from Organization_Communications__r),
                        (Select Id,MDM_Id__c,Account__r.MDM_Id__c,TimeStamp_Decimal__c from Organization_E_Invoices__r) 
                        from Account where MDM_Id__c = :recordId with SECURITY_ENFORCED]) {
            upsertOldMap.get(ACCOUNTSTRING).put(acc.MDM_Id__c,acc);
            for(Organization_Communication__c communication: acc.Organization_Communications__r) {
                upsertOldMap.get('Organization_Communication__c').put(communication.MDM_Id__c,communication);  
            }
            for(Organization_E_Invoice__c invoice: acc.Organization_E_Invoices__r) {
                upsertOldMap.get('Organization_E_Invoice__c').put(invoice.MDM_Id__c,invoice); 
            }
        }
        return upsertOldMap;
    }
    private CM_ReltioHCOService() {}
}