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
        List<CRM_Asset_Event__e> assetPELst = new List<CRM_Asset_Event__e> ();
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;       
            // custom settings/metadata - to get source object/fields and target object/fields                                            
            if(schema.SobjectType.CRM_Asset_Event__e.isAccessible()) {
                system.debug('PE is accessible');
                if(CRM_AssetTriggerHandler.isFirstRun) {         
                    //final List<CRM_Asset_Event__e> assetPELst = new List<CRM_Asset_Event__e> ();                              
                    for ( Asset asst : assetLst ) {  
                        
                        event = new CRM_Asset_Event__e();
                        event.Asset_ID__c =  asst.Id;           
                        event.Order_Id__c = asst.Order__c;            
                        event.Asset_Event_Type__c = trigContext;                                   
                        assetPELst.add(event);   
                    }
                } 
            } else{
                system.debug('Not accessible');
                throw new SObjectException('No access to platform event.');
				/*custExcp = new UCB_CustomExceptionWrapper();
            	excpLst = new List<UCB_CustomExceptionWrapper>();
            	custExcp.module = 'Asset Owner Update';
            	//custExcp.exceptn =  excp;                       
            	excpLst.add(custExcp);            
            	UCB_ExceptionService.logException(excpLst); */                 
            }           
        
        if(!assetPELst.isEmpty()) {  
            //PlatformEventFailureCallback callbck = new PlatformEventFailureCallback();
            //eventbus.publish(assetPELst,callbck);                
            eventbus.publish(assetPELst);                                                   
        }           
        
    }
    
    /**
* @description : constructor  
*/
    Private CRM_AssetService() {}    
}