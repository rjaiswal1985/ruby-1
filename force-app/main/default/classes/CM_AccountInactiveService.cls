/***********************************************************************************************************************
* Name: CM_AccountInactiveService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper for CM_AccountDataCaptureTrigger
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
    /* Process to Associate Contact with Account */
    final static string ASSC_CONT_ACCT = 'Associate ContAcct'; 
    /* Null Value */
    final static string NULL_VALUE = null;  
    /* Relation Type Owner */
    final static string RELATED_OWNER = 'Owner'; 
    
    /**
* @description : This method gets details of account service to invoke 
* and account Ids from changeEvent 
* @parameters : Map of account service and account IDs
*/  
    public static List<Contact> directRelAccountInactivated(Map<String,List<Id>> accMap) {        
        final List<Contact> contUpdateLst; 
        final Map<Id,Id> conAccMap = new Map<Id,Id>();
        final List<Id> accIds; 		         
        final List<Contact> conLst = new List<Contact>();        
        final Set<Id> conNonOwnrSet = new Set<Id>();        
        Contact contRec;
        final Set<Id> directContSet = new Set<Id>();
        for(String str : accMap.keySet()) {
            if(str == ACCOUNT_INACTIVE ) {
                accIds = accMap.get(str);		    
            }            
        }
        for(Account acct : [Select Id,
                           (Select accountId,contactId,Relationship_Type__c from AccountContactRelations where IsDirect= true)
                           from Account where Id IN :accIds WITH SECURITY_ENFORCED]) {
                               for(AccountContactRelation reltn : acct.AccountContactRelations) {
                                	directContSet.add(reltn.contactID);   
                               }                               
            
        }
        system.debug('directContSet==>>'+directContSet);
        contUpdateLst = CM_AssociateActiveAccountonContact.getContwithActiveAccnt(directContSet);
        system.debug('contUpdateLst==>>'+contUpdateLst);
        return contUpdateLst;
    }
    
    /**
* @description : constructor  
*/  
    private CM_AccountInactiveService() {}
}