/***********************************************************************************************************************
* Name: CM_AccountInactiveService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service class invoked on account inactivation
* TestClass : CM_AccountUpdateCaptureService
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
* @description : Based on the process name 'account inactivation' from input parameter,
* this method invokes corresponding services & updates contacts with active account
* @parameters : Map of service name and account IDs from account change event
*/  
    public static void accountInactivationProcess(List<Id> accIds) {        
        final List<Id> inActiveAccIds = new List<Id>(); 		                                             
        final Set<Id> directContSet = new Set<Id>();
        
        /*for(AccountContactRelation acctCont : [Select AccountId,contactId
                            from AccountContactRelation where IsDirect= true AND
                           		AccountId IN :accIds WITH SECURITY_ENFORCED]) {                               
        	directContSet.add(acctCont.contactID);                                                                             
        }*/
        Map<Id, Contact> contMap = new Map<ID, Contact>([SELECT Id,AccountId,Status__c
                                                          FROM Contact where AccountId IN :accIds 
                                                         AND Status__c='Active' WITH SECURITY_ENFORCED]);
        /*for(Contact Cont : [Select Id,AccountId,Status__c
                            from Contact where AccountId IN :accIds WITH SECURITY_ENFORCED]) {                            		                              
        	directContSet.add(cont.Id);                                                                             
        }*/
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