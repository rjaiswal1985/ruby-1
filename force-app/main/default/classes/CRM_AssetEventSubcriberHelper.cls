/***********************************************************************************************************************
* Name: CRM_AssetEventSubcriberHelper
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Asset platfrom event subcriber helper
* TestClass : CRM_AssetEventSubcriberHelper
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        13/03/2024          Class invoked from Asset platform event subscriber.
***********************************************************************************************************************/
public with sharing class CRM_AssetEventSubcriberHelper {   
    
    /**
* @description : This method processes asset platform event 
* and based on event type invokes handler actions
* @parameters : list of order platform event
*/        
    public static List<Asset> assetOwnerupdate(List<CRM_Asset_Event__e > eventLst) { 
        final List<Asset> assetUpdateLst = new List<Asset>();        
        final Map<Id,Id> asstOrdrMap  = getAsstOrdrMap(eventLst);                                
        final Map<Id,Id> ordOwnrMap = getOrdOwnrMap(asstOrdrMap.values());                         
        
        for( Id asstId : asstOrdrMap.keySet() ) {                            
            if(ordOwnrMap.get(asstOrdrMap.get(asstId))!=null) {
                assetUpdateLst.add( new Asset(Id = asstId,OwnerId = ordOwnrMap.get(asstOrdrMap.get(asstId))));
            }                
        }
        return assetUpdateLst;
    }
    
    /**
* @description : This method returns asset and related order details 
* from asset platform event
* @parameters : asset platform event list
*/
    public static Map<Id,Id> getAsstOrdrMap(List<CRM_Asset_Event__e> asstEvntLst) {         
        final Map<Id,Id> asstOrdrMap = new Map<Id,Id>();                
        for (CRM_Asset_Event__e  event : asstEvntLst) {                         
            asstOrdrMap.put(event.Asset_ID__c,event.Order_ID__c);                           
        }                                                         
        return asstOrdrMap;
    }
    /**
* @description : This method returns order and its owner details
* @parameters : order Ids
*/
    public static Map<Id,Id> getOrdOwnrMap(List<Id> ordIds) {               
        final Map<Id,Id>  ordOwnrMap = new Map<Id,Id>();        
        for (Order ord : [select id,ownerID from order where ID IN: ordIds WITH SECURITY_ENFORCED ]) {
            ordOwnrMap.put(ord.Id,ord.ownerID);
        }        
        return ordOwnrMap;
    }
    
    
    /**
* @description : constructor   
*/
    private CRM_AssetEventSubcriberHelper() {} 
    
}