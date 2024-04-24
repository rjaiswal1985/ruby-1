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
    /**
* @description : This method gets the account Ids from changeEvent invokes 
* corresponding account inactive service
* @parameters : list of AccountChangeEvents
*/  
    public static void accountContactRelations(List<AccountContactRelationChangeEvent> chgEvntLst) {
                
        //Set<String> changedFieldsSet;
        final Map < String, List<Id> > acctContMap = new Map < String, List<Id> > ();        
        
        for(AccountContactRelationChangeEvent ace : chgEvntLst) { 
            Eventbus.ChangeEventHeader header = ace.ChangeEventHeader;                       
            system.debug('changedFieldsSet==>>'+header.changedFields.contains('IsActive'));                                  
            system.debug('JSON==>>'+JSON.Serialize(ace));
            system.debug('is active==>>'+ ace.IsActive );
            system.debug('is direct==>>'+ ace.IsDirect );
            system.debug('change type==>>'+ header.changetype );
            if(header.changetype == 'UPDATE' && ace.IsActive == FALSE 
              && header.changedFields.contains('IsActive')) {                            	                
                if(!acctContMap.containsKey('Acct_Cont_Assc')) {                	
                    acctContMap.put('Acct_Cont_Assc',new List<Id>()); 
                } 
                acctContMap.get('Acct_Cont_Assc').addAll(ace.ChangeEventHeader.getRecordIds());
        	}
        }

		system.debug('acctContMap==>>'+acctContMap);
        if(acctContMap!= null && !acctContMap.isEmpty() && acctContMap.containsKey('Acct_Cont_Assc')) {
        	CM_AccountContactRelationInactiveService.acctContRelationInactivated(acctContMap.get('Acct_Cont_Assc'));    
        }                                        
    }
    /**
* @description : constructor  
*/
    private CM_AcctContRelation_CDC_TriggerHelper() {}
}