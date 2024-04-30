/***********************************************************************************************************************
 * Name: CM_OrganizationLOB
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class for Organization LOB
 * TestClass : CM_OrganizationLOB
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sonakshi Garg                   29/04/2024          Service class to retrieve Organization LOB data to upsert
 ***********************************************************************************************************************/
public with sharing class CM_OrganizationLOB {
    /**CM_ReltioHCOInboundPayloadTriggerHandler
     * @description : Method returns List of Organization LOB
     */
    public static Map < String, Organization_LOB_Information__c > upsertOrganizationLOB(Map < String, Map < String, Object >> objParser, Account account,String masterRecordId) {
     
        final Map < String, Organization_LOB_Information__c > orgLobMap = new Map < String, Organization_LOB_Information__c > ();
        Organization_LOB_Information__c orgLob ;
        Map < String, Object > key2value = new Map < String, Object > ();
        for (String objectKey: objParser.keySet()) {
            orgLob = new Organization_LOB_Information__c();
            orgLob.Organization__r = new Account(MDM_Id__c = account.MDM_Id__c);
            orgLob.Timestamp__c = account.Timestamp__c;
            orgLob.TimeStamp_Decimal__c = account.TimeStamp_Decimal__c;
            key2value = objParser.get(objectKey);
            for (String key: key2value.keyset()) {
                orgLob.put(key, key2value.get(key));
            }
            orgLobMap.put(objectKey, orgLob);
        }
     
        return orgLobMap;
    }
    private CM_OrganizationLOB() {}
}