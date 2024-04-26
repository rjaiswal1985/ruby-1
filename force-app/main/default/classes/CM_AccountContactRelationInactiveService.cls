/***********************************************************************************************************************
* Name: CM_AccountContactRelationInactiveService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service class invoked on account inactivation
* TestClass : CM_AccountContactRelationInactiveService
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   04/04/2024             Account Inactivation Service class
***********************************************************************************************************************/
public with sharing class CM_AccountContactRelationInactiveService {
    /* Account status inactive */
    final static string ACCOUNT_INACTIVE = 'Account Inactive';
    
    /**
* @description : Based on the process name 'account inactivation' from input parameter,
* this method invokes corresponding services & updates contacts with active account
* @parameters : Map of service name and account IDs from account change event
*/  
    public static void acctContRelationInactivated(Set<Id> accConRelIds) {        
        final Set<Id> directContSet = new Set<Id>();
        final Map<Id, Contact> contMap = new Map<ID, Contact>([SELECT Id,Status__c FROM Contact
                                                           where Id IN(select contactId from
                                                           AccountContactRelation where Id IN:accConRelIds AND isDirect = true)                                                                                    
                                                          AND Status__c='Active' WITH SECURITY_ENFORCED]);
        system.debug('contMap==>>'+contMap);
        for(AccountContactRelation accConRel : [Select Id,AccountId,ContactID
                            from AccountContactRelation where ID IN :accConRelIds AND isDirect = true 
                                                AND Contact.Status__c='Active' WITH SECURITY_ENFORCED]) {                            		                              
        	directContSet.add(accConRel.ContactID);                                                                             
        }
        system.debug('directContSet==>>'+directContSet);
        if(contMap != null && !contMap.isEmpty()) {
        	CM_AssociateActiveAccountonContact.updateContwithActiveAccnt(contMap.keySet(),'Acct_Cont_Inactivation');    
        }        
    }
    
    /**
* @description : constructor  
*/  
    private CM_AccountContactRelationInactiveService() {}
}