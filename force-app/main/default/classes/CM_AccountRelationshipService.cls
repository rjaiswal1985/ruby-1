/***********************************************************************************************************************
 * Name: CM_AccountRelationshipService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service to create Account-Account Relationship
 * TestClass : CM_AccountRelationshipService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023         Handles Account-Account Relationship Service invoked from HCORelationship service
 ***********************************************************************************************************************/
public with sharing class CM_AccountRelationshipService {
    /**
     * @description : typecasts input sobject map to account-account data to upsert 
     */
    public static AccountRelation upsertAccountRelationship(Map < String, Map < String, Object >> objParser,String masterRecordId) {
        CM_LoggerUtil.logger(new CM_Log('AccountRelation','Info', masterRecordId, 'Account Relationship Creation Service started')); 
        final Account_Relationship__c accRelation = new Account_Relationship__c();
        Map < String, Object > objectMap = new Map < String, Object > ();
        Map < String, Object > startObjDetails;
        Map < String, Object > endObjectDetails;
        final Map < String, Account_Relationship__c > relationMap = new Map < String, Account_Relationship__c > ();
        final Map < String, Map < String, Sobject >> resultMap = new Map < String, Map < String, Sobject >> ();

        for (String objectKey: objParser.keySet()) {
            objectMap = objParser.get(objectKey);
            for (String str: objectMap.keyset()) {
                if (str == CM_ReltioConstants.STARTOBJECT) {
                    startObjDetails = (Map < String, Object > ) objectMap.get(str);
                    accRelation.From_Account__r = new Account(MDM_Id__c = startObjDetails.get('uri').tostring().substringAfterLast('/'));
                } else if (str == CM_ReltioConstants.ENDOBJECT) {
                    endObjectDetails = (Map < String, Object > ) objectMap.get(str);
                    accRelation.To_Account__r = new Account(MDM_Id__c = endObjectDetails.get('uri').tostring().substringAfterLast('/'));
                } else {
                    accRelation.put(str, objectMap.get(str));
                }
            }
            relationMap.put((String) accRelation.get('MDM_Id__c'), accRelation);
        }
        resultMap.put('Account_Relationship__c', relationMap);

        final AccountRelation accRelationship = new AccountRelation();
        accRelationship.resultMap = resultMap;
        accRelationship.startObjDetails = startObjDetails;
        accRelationship.endObjectDetails = endObjectDetails;
        CM_LoggerUtil.logger(new CM_Log('AccountRelation','Info', masterRecordId, 'Account Relationship Creation Service Completed.')); 
        return accRelationship;
    }
    /*Wrapper Class to handle the Account-Account Relation from inputJson start object, end object */
    public class AccountRelation {
        /* Map of uosert records */
        public Map < String, Map < String, Sobject >> resultMap;
        /* Map of start object  */
        public Map < String, Object > startObjDetails;
        /* Map of end object  */
        public Map < String, Object > endObjectDetails;
    }
    private CM_AccountRelationshipService() {} 
}