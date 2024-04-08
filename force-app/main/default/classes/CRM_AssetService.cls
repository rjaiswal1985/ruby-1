/***********************************************************************************************************************
* Name: CRM_AssetService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Publisher of Asset platform event
* TestClass : CRM_AssetService
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        27/02/2024          Class invoked from Asset trigger handler.
***********************************************************************************************************************/
public with sharing class CRM_AssetService {    
    /**
* @description : This method publishes Asset platform event to update owner
* @parameters : list of Assets inserted/updated and trigger context
*/    
    public static void  publishAssetEvent(List<Asset> assetLst , String trigContext) {                   
        CRM_Asset_Event__e event ;                   
        // custom settings/metadata - to get source object/fields and target object/fields                                            
        if(CRM_AssetTriggerHandler.isFirstRun) {         
            final List<CRM_Asset_Event__e> assetPELst = new List<CRM_Asset_Event__e> ();                              
            for ( Asset asst : assetLst ) {                  
                event = new CRM_Asset_Event__e();
                event.Asset_ID__c =  asst.Id;           
                event.Order_Id__c = asst.Order__c;            
                event.Asset_Event_Type__c = trigContext;                                   
                assetPELst.add(event);   
            }
            
            if(!assetPELst.isEmpty()) {  
                PlatformEventFailureCallback callbck = new PlatformEventFailureCallback();
                eventbus.publish(assetPELst,callbck);                                                 
            }           
        }
    }
    
    /**
* @description : constructor  
*/
    Private CRM_AssetService() {
        
    }
}