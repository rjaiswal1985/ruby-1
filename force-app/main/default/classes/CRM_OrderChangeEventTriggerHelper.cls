/***********************************************************************************************************************
* Name: CRM_OrderChangeEventTriggerHelper
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper for Order change events
* TestClass : CRM_OrderChangeEventTriggerHelper
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                   DATE                DETAIL
* 1.0             Sruthi M                 24/04/2024          Helper for Order change events
***********************************************************************************************************************/
public with sharing class CRM_OrderChangeEventTriggerHelper {
    /* Process name helps to invoke corresponding service */
    final static string OWNER_CALCULATION = 'Owner_Calculation'; 
    /**
* @description : From the list of AccountChangeEvents this method gets the account Ids 
* and invokes corresponding service(account inactive)
* @parameters : list of AccountChangeEvents
*/  
    public static void processOrderEvents(List<OrderChangeEvent> chgEvntLst) {        
        List<Id> orderIds;             
        final Map < String, List<Id> > orderMap = new Map < String, List<Id> > (); 
        Eventbus.ChangeEventHeader header;
        for(OrderChangeEvent ace : chgEvntLst) { 
            //Eventbus.ChangeEventHeader header = ace.ChangeEventHeader;
            header = ace.ChangeEventHeader;
            system.debug('header==>>'+header);
            if(header.changetype == 'CREATE') {                
                orderIds = new List<Id>();
                orderIds.addAll(ace.ChangeEventHeader.getRecordIds());
                if(orderMap.containsKey(OWNER_CALCULATION)) {
                    orderMap.get(OWNER_CALCULATION).addAll(orderIds);                      
                } else {
                    orderMap.put(OWNER_CALCULATION,orderIds);
                }                                               
            }
        }

        system.debug('orderMap==>>'+orderMap);        
        if(orderMap!= null && !orderMap.isEmpty() && orderMap.containsKey(OWNER_CALCULATION)) {
            CRM_OrderOwnerService.updateOrderOwner(orderMap.get(OWNER_CALCULATION));            
        }                                        
    }
    /**
* @description : constructor  
*/
    private CRM_OrderChangeEventTriggerHelper() {}
}