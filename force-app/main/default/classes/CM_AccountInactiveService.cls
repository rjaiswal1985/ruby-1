/***********************************************************************************************************************
* Name: CM_AccountInactiveService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service class invoked on account inactivation
* TestClass : CM_AccountInactiveService_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   04/04/2024             Account Inactivation Service class
***********************************************************************************************************************/
public with sharing class CM_AccountInactiveService {
    /* Account status inactive */
    final static string ACCOUNT_INACTIVE = 'Account Inactive';
    
    /**
* @description : Account inactivation process invoked when account status is inactive 
* @parameters : List of account IDs from account change event
*/  
    public static void accountInactivationProcess(List<Id> accIds) {        
        final List<Id> inActiveAccIds = new List<Id>(); 		                                             
        final Set<Id> directContSet = new Set<Id>();
        
        Map<Id, Contact> contMap = new Map<ID, Contact>([SELECT Id,AccountId,Status__c
                                                          FROM Contact where AccountId IN :accIds 
                                                         AND Status__c='Active' WITH SECURITY_ENFORCED]);
        system.debug('contMap==>>'+contMap);
        if(contMap != null && !contMap.isEmpty()) {
        	CM_AssociateActiveAccountonContact.updateContwithActiveAccnt(contMap.keySet());    
        }        
    }
    
    /**
* @description : constructor  
*/  
    private CM_AccountInactiveService() {}
}