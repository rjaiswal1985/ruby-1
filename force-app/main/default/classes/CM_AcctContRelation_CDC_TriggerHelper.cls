/***********************************************************************************************************************
* Name: CM_AcctContRelation_CDC_TriggerHelper
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper for Account data change events
* TestClass : CM_AcctContRelation_CDC_TriggerHelper
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   18/04/2024             Helper for Account data change events
***********************************************************************************************************************/
public with sharing class CM_AcctContRelation_CDC_TriggerHelper {
    /* Account status inactive */
    final static string INACTIVE_STATUS = 'Inactive';
    /* Process name Account Contact Inactivation */
    final static string ACCT_CONT_INACTIVE = 'Acct_Cont_Inactivation';
    /**
* @description : This method gets the account Ids from changeEvent invokes 
* corresponding account inactive service
* @parameters : list of AccountChangeEvents
*/  
    public static void accountContactRelations(List<AccountContactRelationChangeEvent> chgEvntLst) {                
        List<Id> accConRelIds;
        final Map < String, Set<Id> > acctContMap = new Map < String, Set<Id> > ();        
        Eventbus.ChangeEventHeader header;
        for(AccountContactRelationChangeEvent ace : chgEvntLst) { 
            header = ace.ChangeEventHeader; 
            if(header.changetype == 'UPDATE' && ace.Status__c == INACTIVE_STATUS 
              && header.changedFields.contains('Status__c')) { 
                accConRelIds = new List<Id>(); 
                accConRelIds.addAll(ace.ChangeEventHeader.getRecordIds());  
                if(!acctContMap.containsKey(ACCT_CONT_INACTIVE)) {                	
                    acctContMap.put(ACCT_CONT_INACTIVE,new Set<Id>()); 
                } 
                acctContMap.get(ACCT_CONT_INACTIVE).addAll(accConRelIds);
        	}
        }

		system.debug('acctContMap==>>'+acctContMap);
        if(acctContMap!= null && !acctContMap.isEmpty() && acctContMap.containsKey(ACCT_CONT_INACTIVE)) {
        	CM_AccountContactRelationInactiveService.acctContRelationInactivated(acctContMap.get(ACCT_CONT_INACTIVE));    
        }                                        
    }
    /**
* @description : constructor  
*/
    private CM_AcctContRelation_CDC_TriggerHelper() {}
}