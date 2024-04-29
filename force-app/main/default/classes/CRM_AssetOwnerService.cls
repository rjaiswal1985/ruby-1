/***********************************************************************************************************************
* Name: CRM_AssetOwnerService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service class for asset owner update
* TestClass : CRM_AssetOwnerService_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                   DATE                DETAIL
* 1.0             Sruthi M                 24/04/2024          Service class for asset owner update
***********************************************************************************************************************/
public with sharing class CRM_AssetOwnerService {

    /**
* @description : From assets get corresponding Order owner and update Asset Owner 
* @parameters : list of Asset IDs
*/  
    public static void updateAssetOwner(List<Id> assetIds) { 
        final List<Asset> assetUpdateLst = new List<Asset>();
        final List <Database.SaveResult> updateResult ;        
        final Map<Id,Asset> assetMap = getAsstOrdrMap(assetIds);         
        
        for( Id asstId : assetMap.keySet() ) {                            
        	if(assetMap.get(asstId)!=null) {
                assetUpdateLst.add( new Asset(Id = asstId,OwnerId = assetMap.get(asstId).Order__r.OwnerId));
            }                
        }
        updateResult = UCB_DMLUtility.updateRecords(assetUpdateLst,false);                                  
        //UCB_LoggerService.logger(new UCB_Log('Asset_Owner_Update', 'DML_Upsert_Result', JSON.Serialize(updateResult)),false);        
        //UCB_LoggerService.publishLogs(); 
    }
    
    /**
* @description : This method returns asset and related order details 
* from asset platform event
* @parameters : asset platform event list
*/
    public static Map<Id,Asset> getAsstOrdrMap(List<Id> assetIds) {         
        final Map<Id,Asset> asstOrdrMap = new Map<Id,Asset>(); 
        for(Asset asst: [Select Id,Order__c,Order__r.OwnerId from Asset where Id IN:assetIds WITH SECURITY_ENFORCED ]) {
        	asstOrdrMap.put(asst.Id,asst);            
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
    private CRM_AssetOwnerService() {}
}