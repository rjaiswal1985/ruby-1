/***********************************************************************************************************************
* Name: CM_AssociateActiveAccountonContact
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Associates Active Account on Contact when Direct related Account is inactivated
* TestClass : CM_AssociateActiveAccountonContact_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                  DATE                DETAIL
* 1.0             Sruthi M                17/04/2024          Associates AccountContact when direct account is made inactive
***********************************************************************************************************************/
public with sharing class CM_AssociateActiveAccountonContact {
    /* Null Value */
    final static String NULL_VALUE = null;
    /* Count of no of relations */
    final static Integer RELATIONS_COUNT = 1;  
    /* Process account inactivation */
    final static String ACCOUNT_INACTIVATION = 'Account_Inactivation';
    /* Process account contact relation inactivation */
    final static String ACCT_CONT_INACTIVATION = 'Acct_Cont_Inactivation'; 
    /* String variable Owner */
    final static String OWNER = 'Owner';
    
    /**
* @description : This method updates contact with Active account
* when direct account is deactivated, based on the accountcontact relation 
* @parameters : Set of contact IDs
*/  
    public static void updateContwithActiveAccnt(Set<Id> recIdSet, String processName) {        
        final List<Contact> contUpdateLst = new List<Contact>();
        List<Database.UpsertResult> upsertResults;
        Contact contToUpdate; 

        final Map<String, Object> bindVars = new Map<String, Object>();
        bindVars.put('Owner','Owner');
        bindVars.put('Status','Active');        
        bindVars.put('recIdSet','recIdSet');
                                       
        final String queryOwnerStr = getDynamicQuery(processName,'Owner');
        system.debug('queryOwnerStr==>>'+queryOwnerStr);
        system.debug('recIdSet==>>'+recIdSet);

        List<Contact> conWithownerLst =  Database.queryWithBinds(queryOwnerStr, bindVars, AccessLevel.SYSTEM_MODE);
        system.debug('conWithownerLst==>>'+conWithownerLst);

        //for(Contact cont : System.Database.query(queryOwnerStr)) {
        for(Contact cont : conWithownerLst) {  
        	if(cont.AccountContactRelations.size() == RELATIONS_COUNT) { 
                system.debug('owner list==>>'+cont.AccountContactRelations);
                if(processName == ACCOUNT_INACTIVATION) {
                	recIdSet.remove(cont.AccountId);    
                }
                if(processName == ACCT_CONT_INACTIVATION) {
                	recIdSet.remove(cont.Id);    
                }
                
                system.debug('contToUpdate==>>'+contToUpdate);                
                contToUpdate = instantiateContwithAcct(cont.AccountContactRelations[0]);
                contUpdateLst.add(contToUpdate); 
                system.debug('contToUpdate==>>'+contToUpdate);
                system.debug('contUpdateLst==>>'+contUpdateLst);                
            } 
        }  
        
        system.debug('recIdSet==>>'+recIdSet);
        
        if(recIdSet != null && !recIdSet.isEmpty()) {
            final String queryNonOwnerStr = getDynamicQuery(processName,'Non_Owner');
            
            system.debug('queryNonOwnerStr ==>>'+queryNonOwnerStr);

            for(Contact con: System.Database.Query(queryNonOwnerStr)) {
            system.debug('related member==>>'+con);
            	for(AccountContactRelation rels : con.AccountContactRelations) {                	
                    system.debug('rels==>>'+rels);                    
                    
                    contToUpdate = instantiateContwithAcct(con.AccountContactRelations[0]);                
                	contUpdateLst.add(contToUpdate);
                    system.debug('contToUpdate==>>'+contToUpdate);
                	system.debug('contUpdateLst==>>'+contUpdateLst);
                }	               
            }
        }                   
        system.debug('contUpdateLst==>>'+contUpdateLst);
        upsertResults = UCB_DMLUtility.upsertRecords(contUpdateLst,false,System.AccessLevel.USER_MODE); 
        //UCB_LoggerService.logger(new UCB_Log('Contact update with Active Account', 'DML Upsert Result', JSON.Serialize(upsertResults)),false);  
        //UCB_LoggerService.publishLogs();         
    }
    /**
* @description : associate contact with active accountID
* @Parameters : accountcontactrelation record
*/     
    public static Contact instantiateContwithAcct(AccountContactRelation accConRel) {    	
    	final Contact conRec = new Contact(Id = accConRel.ContactId,AccountId = accConRel.AccountId);                       
        system.debug('contact instantiated==>>'+conRec);
        return conRec;        
    }
    /**
* @description : get dynamic query based on the process
* @Parameters : process name, member type
*/ 
    public static String getDynamicQuery(String processName, String relMemberType) { 
        
        final String startQuery = 'Select Id,AccountId,(Select accountId,contactId,Relationship_Type__c from AccountContactRelations where ';        
        String subQuery = 'Account.Status__c=:Status AND Status__c =:Status order by startdate asc LIMIT 1)';
        String finalQuery;        

        if(processName == ACCOUNT_INACTIVATION) {            
        	subQuery += ' from Contact where AccountID =:recIdSet WITH SECURITY_ENFORCED ';                                                                  
        }
        
        if(processName == ACCT_CONT_INACTIVATION) {                      
        	subQuery += 'from Contact where ID =:recIdSet WITH SECURITY_ENFORCED ';                                                            
        }   
        if(relMemberType == OWNER) {
            final String ownerWhereClause = 'Relationship_Type__c=:Owner AND ';
            finalQuery = startQuery+ownerWhereClause+subQuery;
        } else {
            finalQuery = startQuery+subQuery;
        }  
        system.debug('finalQuery==>>'+finalQuery);            
        return finalQuery;
    }

    /**
* @description : constructor  
*/  
    private CM_AssociateActiveAccountonContact() {}
}