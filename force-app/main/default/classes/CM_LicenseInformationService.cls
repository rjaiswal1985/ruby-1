/***********************************************************************************************************************
 * Name: CM_LicenseInformationService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class to handle HCP License Information
 * TestClass : CM_LicenseInformationService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                   17/11/2023           Service class to retrieve HCP License Information data to upsert
 ***********************************************************************************************************************/
public with sharing class CM_LicenseInformationService {
    /**
     * @description : Method to get List of HCP License Information
     */
    public static Map < String, License_Information__c > upsertLicenseInformationDetails(Map < String, Map < String, Object >> objParser, Contact reltdContact) {
        //UCB_LoggerService.logger(new List<UCB_Log>{new UCB_Log(RELTIOHCP,'License Information Creation Service','License Information Creation Service Started')});
        final Map < String, License_Information__c > hcpLicenseMap = new Map < String, License_Information__c > ();
        License_Information__c hcpLicenseInfo;

        Map < String, Object > key2value = new Map < String, Object > ();
        for (String objectKey: objParser.keySet()) {
            hcpLicenseInfo = new License_Information__c();
            hcpLicenseInfo.Contact__r = new Contact(MDM_ID__c = reltdContact.MDM_Id__c);
            hcpLicenseInfo.Timestamp__c = reltdContact.Timestamp__c;
            hcpLicenseInfo.TimeStamp_Decimal__c = reltdContact.TimeStamp_Decimal__c;
            key2value = objParser.get(objectKey);
            for (String key: key2value.keyset()) {
                hcpLicenseInfo.put(key, key2value.get(key));
            }
            hcpLicenseMap.put(objectKey, hcpLicenseInfo);
        }
        //UCB_LoggerService.logger(new List<UCB_Log>{new UCB_Log(RELTIOHCP,'License Information Creation Service','License Information Creation Service ended')});
        return hcpLicenseMap;
    }
    private CM_LicenseInformationService() {}
}