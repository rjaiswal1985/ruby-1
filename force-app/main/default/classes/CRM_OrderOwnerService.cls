/***********************************************************************************************************************
* Name: CRM_OrderOwnerService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper for Updating Order owner on Order Creation
* TestClass : CRM_OrderCreationService_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                   DATE                DETAIL
* 1.0             Sruthi M                 24/04/2024          Service class to update owner on order
***********************************************************************************************************************/
public with sharing class CRM_OrderOwnerService {
    
    /* territory primary owner */
    final static String PRIMARY_OWNER = 'Primary Owner'; 
    /**
* @description : From orders get corresponding Account and update owner
* on Order based on Account's territory related primary owner
* @parameters : list of Order IDs
*/  
    public static void updateOrderOwner(List<Id> orderIds) { 
        final List<order> orderUpdateLst = new List<order>();
        final List <Database.SaveResult> updateResult ;
        final Map<Id,Id> accTerrMap;
        final Map<Id,Id> terrMngrMap;
        
        final Map<Id,Id> orderAcctMap = getOrderRelatedAccount(orderIds);
        
        if(orderAcctMap!=null && !orderAcctMap.isEmpty()) {
            accTerrMap = getAccTerrMap(orderAcctMap.values());
        }
        if(accTerrMap!=null && !accTerrMap.isEmpty()) {
            terrMngrMap =  getTerrMangrMap(accTerrMap.values());
        }  
                        
        for( Id ordId : orderAcctMap.keySet() ) {                
            if(terrMngrMap.get(accTerrMap.get(orderAcctMap.get(ordId)))!=null) {
                orderUpdateLst.add( new Order(Id = ordId,OwnerId = terrMngrMap.get(accTerrMap.get(orderAcctMap.get(ordId))) ));
            }                
        }
        updateResult = UCB_DMLUtility.updateRecords(orderUpdateLst,false);                                  
        //UCB_LoggerService.logger(new UCB_Log('Order_Owner_Update', 'DML_Upsert_Result', JSON.Serialize(updateResult)),false);        
        //UCB_LoggerService.publishLogs(); 
    }
    
    /**
* @description : This method returns order and its account details
* @parameters : order Ids
*/
    public static Map<Id,Id> getOrderRelatedAccount(List<Id> orderIds) { 
        final Map<Id,Id> orderAcctMap = new Map<Id,Id>();
        for(Order ord : [Select id,AccountId from Order where ID IN:orderIds WITH SECURITY_ENFORCED ]) {
            orderAcctMap.put(ord.Id,ord.AccountId);    
        } 
        return orderAcctMap;                                
    }
    
    /**
* @description : This method returns account and its territory details
* @parameters : account ids
*/
    public static Map<Id,Id> getAccTerrMap(List<Id> accIds) {               
        final Map<Id,Id>  accntTerrMap = new Map<Id,Id>();        
        for ( Account acc : [ Select Id,(SELECT ObjectId,Territory2Id FROM ObjectTerritory2Associations LIMIT 1) 
                             from Account where ID IN: accIds WITH SECURITY_ENFORCED ] ) {
                                 for ( ObjectTerritory2Association objTerr : acc.ObjectTerritory2Associations ) {                                    
                                     accntTerrMap.put(acc.Id,objTerr.Territory2Id);                                   
                                 }
                             }
        
        return accntTerrMap;
    }
    
    /**
* @description : This method returns territory and its manager details
* @parameters : list of territory IDs
*/
    public static Map<Id,Id> getTerrMangrMap(List<Id> terrIDs) { 
        final Map<Id,Id> terrMangrMap = new Map<Id,Id>();
        for(UserTerritory2Association userTerr: [ SELECT Id, UserId,user.Name,Territory2.Name, Territory2Id,Territory2.Business_unit__c,
                                                 RoleInTerritory2 FROM UserTerritory2Association where IsActive = true AND Territory2Id IN:terrIDs
                                                 AND RoleInTerritory2 =: PRIMARY_OWNER WITH SECURITY_ENFORCED] ) { 
        	terrMangrMap.put(userTerr.Territory2Id,userTerr.UserId);
     	}
        return terrMangrMap;
    } 
    
    /**
* @description : constructor  
*/
    private CRM_OrderOwnerService() {}
}