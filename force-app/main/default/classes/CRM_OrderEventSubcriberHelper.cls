/***********************************************************************************************************************
* Name: CRM_OrderEventSubcriberHelper
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper to handle order platform events
* TestClass : CRM_OrderTriggerHandler
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        21/02/2024          Class invoked from Order platform event services.
***********************************************************************************************************************/
public with sharing class CRM_OrderEventSubcriberHelper {   
    /* territory primary owner */
    final static String PRIMARY_OWNER = 'Primary Owner'; 
    /**
    * @description : This method processes order platform event 
    * and updates the order owner
    * @parameters : list of order platform event
    */        
    public static List<Order> orderOwnerupdate(List<CRM_Order_Event__e > eventLst) { 
        final List<order> orderUpdateLst = new List<order>();        
        final Map<Id,Id> orderAccMap  = getOrderAccntMap(eventLst);                        
        final Map<Id,Id> accTerrMap = getAccTerrMap(orderAccMap.values());                
        final Map<Id,Id> terrMngrMap =  getTerrMangrMap(accTerrMap.values()); 
                                             
        for( Id ordId : orderAccMap.keySet() ) {                
            if(terrMngrMap.get(accTerrMap.get(orderAccMap.get(ordId)))!=null) {
                orderUpdateLst.add( new Order(Id = ordId,OwnerId = terrMngrMap.get(accTerrMap.get(orderAccMap.get(ordId))) ));
            }                
        }
        return orderUpdateLst;
    }

    /**
    * @description : This method returns order and related account details from order platform event
    * @parameters : order platform event list
    */
    public static Map<Id,Id> getOrderAccntMap(List<CRM_Order_Event__e> orderEvntLst) {         
        final Map<Id,Id> ordrAccMap = new Map<Id,Id>();                
        for (CRM_Order_Event__e  event : orderEvntLst) {                         
            ordrAccMap.put(event.Order_Id__c,event.Sold_To_Account__c);                           
        }                                                 
        return ordrAccMap;
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
        for(UserTerritory2Association userTerr: [ SELECT Id, UserId,user.Name,Territory2.Name, Territory2Id,Territory2.Business_unit__c,RoleInTerritory2 FROM UserTerritory2Association 
                                                        where IsActive = true AND Territory2Id IN:terrIDs AND RoleInTerritory2 =: PRIMARY_OWNER WITH SECURITY_ENFORCED] ) { 
            terrMangrMap.put(userTerr.Territory2Id,userTerr.UserId);
        }
        return terrMangrMap;
    } 
    
    /**
    * @description : constructor   
    */
    private CRM_OrderEventSubcriberHelper() {} 

}