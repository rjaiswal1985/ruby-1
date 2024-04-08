/***********************************************************************************************************************
* Name: CRM_AssetEventService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: checks asset event context and invokes corresponding actions
* TestClass : CRM_AssetEventService
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        14/03/2024          Class invoked from Asset platform event subcriber helper.
***********************************************************************************************************************/
public with sharing class CRM_AssetEventService {
    /* type of Asset event */
    final static string CREATE_ASSET = 'Create_Asset';
    /**
    * @description : This method checks the asset platform event type
    * and invokes the corresponding handler actions
    * @parameters : list of asset platform events
    */    
    public static List<CRM_Asset_Event__e> processAssetEvents(List<CRM_Asset_Event__e> eventLst) {                              
        final List<CRM_Asset_Event__e> asstEvntLst = new List<CRM_Asset_Event__e>();
        for( CRM_Asset_Event__e asstEvnt : eventLst ) {                        
            if(asstEvnt.Asset_Event_Type__c == CREATE_ASSET) {
                asstEvntLst.add(asstEvnt);
            }                
        } 
        return asstEvntLst;
    }
    /**
    * @description : constructor  
    */
    private CRM_AssetEventService() { } 
}