/***********************************************************************************************************************
 * Name: CM_PersonCommunicationService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class to handle HCP Communication Details
 * TestClass : CM_PersonCommunicationService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                   28/11/2023          Service class to retrieve HCP Communication Details to upsert
 ***********************************************************************************************************************/
public with sharing class CM_PersonCommunicationService {
    /**
     * @description : Method to get List of HCP Communication details.
     */
    public static Map < String, Person_Communication__c > upsertHCPcommunicationInfo(Map < String, Map < String, Object >> objParser, Contact reltdContact,String masterRecordId) {
        CM_LoggerUtil.logger(new CM_Log('PersonCommunication','Info',String.valueof(Datetime.now()), masterRecordId, 'Person Communication Creation Service Started'));
        final Map < String, Person_Communication__c > communicationMap = new Map < String, Person_Communication__c > ();
        Person_Communication__c communicationInfo;

        Map < String, Object > key2value = new Map < String, Object > ();
        for (String objectKey: objParser.keySet()) {
            communicationInfo = new Person_Communication__c();
            communicationInfo.Contact__r = new Contact(MDM_Id__c = reltdContact.MDM_Id__c);
            communicationInfo.Timestamp__c = reltdContact.Timestamp__c;
            communicationInfo.TimeStamp_Decimal__c = reltdContact.TimeStamp_Decimal__c;
            key2value = objParser.get(objectKey);
            for (String key: key2value.keyset()) {
                communicationInfo.put(key, key2value.get(key));
            }
            communicationMap.put(objectKey, communicationInfo);
        }
        CM_LoggerUtil.logger(new CM_Log('PersonCommunication','Info',String.valueof(Datetime.now()), masterRecordId, 'Person Communication Creation Service Completed'));
        return communicationMap;
    }
    private CM_PersonCommunicationService() {}
}