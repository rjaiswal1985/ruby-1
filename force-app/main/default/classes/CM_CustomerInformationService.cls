/***********************************************************************************************************************
 * Name: CM_CustomerInformationService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class for Customer Communication Information
 * TestClass : CM_CustomerInformationService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          Service class to retrieve Customer Communication data to upsert
 ***********************************************************************************************************************/
public with sharing class CM_CustomerInformationService {
    /**
     * @description : returns list of Customer communication information of Account
     */
    public static Map < String, Organization_Communication__c > upsertCommInformation(Map < String, Map < String, Object >> objParser, Account account,String masterRecordId) {
        CM_LoggerUtil.logger(new CM_Log('CustomerInformation','Info',String.valueof(Datetime.now()), masterRecordId, 'Customer Information Creation Service started'));  
        final Map < String, Organization_Communication__c > cusInformMap = new Map < String, Organization_Communication__c > ();
        Map < String, Object > key2values = new Map < String, Object > ();
        Organization_Communication__c cusInformation;
        for (String objectKey: objParser.keySet()) {
            cusInformation = new Organization_Communication__c();
            cusInformation.Account__r = new Account(MDM_Id__c = account.MDM_Id__c);
            cusInformation.Timestamp__c = account.Timestamp__c;
            cusInformation.TimeStamp_Decimal__c = account.TimeStamp_Decimal__c;
            key2values = objParser.get(objectKey);
            for (String key: key2values.keyset()) {
                cusInformation.put(key, key2values.get(key));
            }
            cusInformMap.put(objectKey, cusInformation);
        }
        CM_LoggerUtil.logger(new CM_Log('CustomerInformation','Info',String.valueof(Datetime.now()), masterRecordId, 'Customer Information Creation Service completed.'));  
        return cusInformMap;
    }
    private CM_CustomerInformationService() {}
}