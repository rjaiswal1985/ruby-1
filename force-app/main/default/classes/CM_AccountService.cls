/***********************************************************************************************************************
* Name: CM_AccountService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service class for Account data
* TestClass : CM_AccountService
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023         Service class to retrieve Account data to upsert
***********************************************************************************************************************/
public with sharing class CM_AccountService {
    /**
    * @description : returns Account data to upsert
    */
    public static Account upsertAccount(Map<String,Map<String,Object>> objParser,String masterRecordId) { 
        CM_LoggerUtil.logger(new CM_Log('Organization','Info',String.valueof(Datetime.now()), masterRecordId, 'Account Creation Service started'));  
        final Account accountVar = new Account();         
        Map<String,  Object> objectMap = new Map<String,  Object>();
        for(String objectKey : objParser.keySet()) { 
            objectMap = objParser.get(objectKey);
            for(String key : objectMap.keyset()) { 
                accountVar.put(key,objectMap.get(key)); 
            }
        }        
        CM_LoggerUtil.logger(new CM_Log('Organization','Info',String.valueof(Datetime.now()), masterRecordId, 'Account Creation Service completed'));  
        return  accountVar;
    } 
    private CM_AccountService() {}
}