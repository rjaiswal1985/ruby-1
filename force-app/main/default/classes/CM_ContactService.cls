/***********************************************************************************************************************
* Name: CM_ContactService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service class for Contact data
* TestClass : CM_ContactService
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   13/11/2023           Service class to retrieve Contact data to upsert
***********************************************************************************************************************/
public with sharing class CM_ContactService {
    /**
    * @description : returns Contact data to upsert 
    */
    public static Contact upsertContact(Map<String,Map<String,Object>> objParser,String masterRecordId) {
        CM_LoggerUtil.logger(new CM_Log('Contact','Info',String.valueof(Datetime.now()), masterRecordId, 'Contact Creation Service started'));  
        final Contact contactRec = new Contact();         
        Map<String,  Object> objectMap = new Map<String,  Object>();
        for(String objectKey : objParser.keySet()) { 
            objectMap = objParser.get(objectKey);
            for(String key : objectMap.keyset()) {                 
                contactRec.put(key,objectMap.get(key)); 
            }
        }
        CM_LoggerUtil.logger(new CM_Log('Contact','Info',String.valueof(Datetime.now()), masterRecordId, 'Contact Creation Service completed.')); 
        return  contactRec;
    }   
    private CM_ContactService() {}
}