/***********************************************************************************************************************
 * Name: CM_AccountContactRelationshipService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service to create AccountContact Relationship
 * TestClass : CM_AccountContactRelationshipService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023         Handles AccountContact Relationship Service invoked from HCPHCOService
 ***********************************************************************************************************************/
public with sharing class CM_AccountContactRelationshipService {
    /**
     * @description : typecasts input sobject map to accountcontact data to upsert
     */
    public static AccountRelation upsertAccountRelationship(Map < String, Map < String, Object >> objParser,String masterRecordId) {
        CM_LoggerUtil.logger(new CM_Log(String.valueof(Datetime.now()), masterRecordId, 'Account Relationship Creation Service started')); 
        final AccountContactRelation accRelation = new AccountContactRelation();
        Map < String, Object > objectMap = new Map < String, Object > ();
        final Map < String, String > contact2Account = new Map < String, String > ();
        Map < String, Object > startObjDetails;
        Map < String, Object > endObjectDetails;
        final Map < String, AccountContactRelation > relationMap = new Map < String, AccountContactRelation > ();
        final Map < String, Map < String, Sobject >> resultMap = new Map < String, Map < String, Sobject >> ();
        
        for (String objectKey: objParser.keySet()) {
            objectMap = objParser.get(objectKey);
            for (String str: objectMap.keyset()) {
                if (str == CM_ReltioConstants.STARTOBJECT) {
                    startObjDetails = (Map < String, Object > ) objectMap.get(str);
                    accRelation.Contact = new Contact(MDM_Id__c = startObjDetails.get('uri').tostring().substringAfterLast('/'));
                } else if (str == CM_ReltioConstants.ENDOBJECT) {
                    endObjectDetails = (Map < String, Object > ) objectMap.get(str);
                    accRelation.Account = new Account(MDM_Id__c = endObjectDetails.get('uri').tostring().substringAfterLast('/'));
                } else {
                    accRelation.put(str, objectMap.get(str));
                }
            }
            accRelation.AccountContact_Id__c = accRelation.Account.MDM_Id__c + accRelation.Contact.MDM_Id__c;
            relationMap.put(accRelation.AccountContact_Id__c, accRelation);
        }
        resultMap.put('AccountContactRelation', relationMap);
        contact2Account.put(accRelation.Contact.MDM_Id__c, accRelation.Account.MDM_Id__c);
        CM_LoggerUtil.logger(new CM_Log(String.valueof(Datetime.now()), masterRecordId, 'Account Relationship Creation Service completed'));  

        final AccountRelation relationship = new AccountRelation();
        relationship.resultMap = resultMap;
        relationship.contact2Account = contact2Account;
        relationship.startObjDetails = startObjDetails;
        relationship.endObjectDetails = endObjectDetails;
        return relationship;
    }
    /*Wrapper Class to handle the AccountContact Relation from inputJson start object, end object */
    public class AccountRelation {
        /* List of upserted records */
        public Map < String, Map < String, Sobject >> resultMap;
        /* Details of Contact */
        public Map < String, Object > startObjDetails;
        /* Details of Account*/
        public Map < String, Object > endObjectDetails;
        /* Contact 2Account*/
        public Map < String, String > contact2Account;
    }
    private CM_AccountContactRelationshipService() {} 
}