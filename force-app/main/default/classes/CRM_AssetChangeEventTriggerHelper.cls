/***********************************************************************************************************************
* Name: CRM_AssetChangeEventTriggerHelper
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper for Asset change events
* TestClass : CRM_AssetChangeEventTriggerHelper
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                   DATE                DETAIL
* 1.0             Sruthi M                 24/04/2024          Helper for Asset change events
***********************************************************************************************************************/
public with sharing class CRM_AssetChangeEventTriggerHelper {
    /* Process name helps to invoke corresponding service */
    final static string OWNER_CALCULATION = 'Owner_Calculation'; 
    /**
* @description : From the list of AccountChangeEvents this method gets the account Ids 
* and invokes corresponding service(account inactive)
* @parameters : list of AccountChangeEvents
*/  
    public static void processAssetEvents(List<OrderChangeEvent> chgEvntLst) {        
        List<Id> assetIds;             
        final Map < String, List<Id> > assetMap = new Map < String, List<Id> > (); 
        Eventbus.ChangeEventHeader header;
        for(OrderChangeEvent ace : chgEvntLst) { 
            //Eventbus.ChangeEventHeader header = ace.ChangeEventHeader;
            header = ace.ChangeEventHeader;
            system.debug('header==>>'+header);
            if(header.changetype == 'CREATE') {                
                assetIds = new List<Id>();
                assetIds.addAll(ace.ChangeEventHeader.getRecordIds());
                if(assetMap.containsKey(OWNER_CALCULATION)) {
                    assetMap.get(OWNER_CALCULATION).addAll(assetIds);                      
                } else {
                    assetMap.put(OWNER_CALCULATION,assetIds);
                }                                               
            }
        }

        system.debug('assetMap==>>'+assetMap);        
        if(assetMap!= null && !assetMap.isEmpty() && assetMap.containsKey(OWNER_CALCULATION)) {
            CRM_AssetOwnerService.updateAssetOwner(assetMap.get(OWNER_CALCULATION));            
        }                                        
    }
    /**
* @description : constructor  
*/
    private CRM_AssetChangeEventTriggerHelper() {}
}