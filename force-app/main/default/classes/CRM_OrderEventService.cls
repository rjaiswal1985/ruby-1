/***********************************************************************************************************************
* Name: CRM_OrderEventService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: checks order event context and invokes corresponding actions 
* TestClass : CRM_OrderOwnerService
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        27/02/2024          Class invoked from Order platform event subcriber handler.
***********************************************************************************************************************/
public with sharing class CRM_OrderEventService {
    /* type of order event */
    final static string CREATE_ORDER = 'Create_Order';  

    /**
    * @description : This method checks order event - create/update
    * & invokes corresponding helper methods
    * @parameters : list of order platform events
    */    
    public static void processOrderEvents(List<CRM_Order_Event__e > eventLst) {                              
        final List<CRM_Order_Event__e> ordEvntLst = new List<CRM_Order_Event__e>();
        final List<order> orderUpdateLst ;             
        final List <Database.SaveResult> updateResult ;                       
        CRM_OrderTriggerHandler.isFirstRun = false;           
        for( CRM_Order_Event__e ordEvnt : eventLst ) {                
            if(ordEvnt.Order_Event_Type__c == CREATE_ORDER) {
                ordEvntLst.add(OrdEvnt);
            }                
        }            
        if( ordEvntLst != null && !ordEvntLst.isEmpty() ) {
            orderUpdateLst = CRM_OrderEventSubcriberHelper.orderOwnerupdate(ordEvntLst);             
            updateResult = UCB_DMLUtility.updateRecords(orderUpdateLst,false);                                  
            //UCB_LoggerService.logger(new UCB_Log('Order Owner Update', 'DML Upsert Result', JSON.Serialize(updateResult)),false);        
            //UCB_LoggerService.publishLogs();     
        }
  
    }
    /**
    * @description : constructor  
    */
    Private CRM_OrderEventService() {

    }          

}