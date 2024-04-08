/***********************************************************************************************************************
 * Name: CM_ObjectDescription
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Replay the failed events
 * TestClass : CM_ObjectDescription
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          Helper class for the aura component
 ***********************************************************************************************************************/
public with sharing class CM_SobjectController {
    @AuraEnabled(cacheable=true)
     /**
     * @description : Method to get Account Contact Relation
     */
    public static String relationDescription() {
        try {
            return JSON.serialize(Schema.sObjectType.AccountContactRelation);
        } catch(Exception e) {throw new AuraHandledException(e.getMessage());}
    }
}