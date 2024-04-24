/***********************************************************************************************************************
 * Name: CM_EducationalDetailsService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class to handle HCP Education Details
 * TestClass : CM_EducationalDetailsService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                   13/11/2023           Service class to retrieve HCP Education data to upsert
 ***********************************************************************************************************************/
public with sharing class CM_EducationalDetailsService {
    /**
     * @description : Method returns data about HCP Education 
     */
    public static Map < String, Educational_Detail__c > upsertEducationalDetails(Map < String, Map < String, Object >> objParser, Contact reltdContact,String masterRecordId) {
        CM_LoggerUtil.logger(new CM_Log(String.valueof(Datetime.now()), masterRecordId, 'Education Details Creation Service Started'));
        final Map < String, Educational_Detail__c > hcpEduMap = new Map < String, Educational_Detail__c > ();
        Educational_Detail__c hcpEduDetails;

        Map < String, Object > key2value = new Map < String, Object > ();
        for (String objectKey: objParser.keySet()) {
            hcpEduDetails = new Educational_Detail__c();
            hcpEduDetails.Contact__r = new Contact(MDM_Id__c = reltdContact.MDM_Id__c);
            hcpEduDetails.Timestamp__c = reltdContact.Timestamp__c;
            hcpEduDetails.TimeStamp_Decimal__c = reltdContact.TimeStamp_Decimal__c;
            key2value = objParser.get(objectKey);
            for (String key: key2value.keyset()) {
                hcpEduDetails.put(key, key2value.get(key));
            }
            hcpEduMap.put(objectKey, hcpEduDetails);
        }
        CM_LoggerUtil.logger(new CM_Log(String.valueof(Datetime.now()), masterRecordId, 'Education Details Creation Service Started'));
        return hcpEduMap;
    }
    private CM_EducationalDetailsService() {}
}