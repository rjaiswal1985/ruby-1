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
    public static Account upsertAccount(Map<String,Map<String,Object>> objParser) { 
        //UCB_LoggerService.logger(new List<UCB_Log>{new UCB_Log(RELTIOHCO,'Account creation Service','Account Creation Service started')});
        final Account accountVar = new Account();         
        Map<String,  Object> objectMap = new Map<String,  Object>();
        for(String objectKey : objParser.keySet()) { 
            objectMap = objParser.get(objectKey);
            for(String key : objectMap.keyset()) { 
                accountVar.put(key,objectMap.get(key)); 
            }
        }        
        //UCB_LoggerService.logger(new List<UCB_Log>{new UCB_Log(RELTIOHCO,'Account creation Service','Account Creation Service ended')});
        return  accountVar;
    } 
    private CM_AccountService() {}
}