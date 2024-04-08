/***********************************************************************************************************************
* Name: CRM_OrderService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Publisher of Order platform event
* TestClass : CRM_OrderService
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        27/02/2024          Class invoked from Order trigger handler
***********************************************************************************************************************/
public with sharing class CRM_OrderService {    
    /**
    * @description : This method publishes order platform event to update owner
    * @parameters : list of orders inserted/updated & trigger context
    */    
    public static void  publishOrderEvent(List<order> oderLst , String trigContext) {                   
        CRM_Order_Event__e event ;                   
        // custom settings/metadata - to get source object/fields and target object/fields                                            
        if(CRM_OrderTriggerHandler.isFirstRun) {         
            final List<CRM_Order_Event__e> orderPELst = new List<CRM_Order_Event__e> ();                              
            for ( Order ord : oderLst ) {  
                event = new CRM_Order_Event__e();           
                event.Order_Id__c = ord.Id;            
                event.Order_Event_Type__c =  trigContext;
                event.Sold_To_Account__c =  ord.AccountId;
                event.Bill_To_Account__c =  ord.Bill_To_Account__c;
                event.Ship_To_Account__c =  ord.Ship_To_Account__c;
                event.Payer__c =  ord.Payer__c;
                event.Bill_To_Contact__c =  ord.BillToContactId;                       
                orderPELst.add(event);   
            }               
            if(!orderPELst.isEmpty()) {                        
                eventbus.publish(orderPELst);                                 
            }           
        }
    }
    
    /**
    * @description : constructor  
    */
    Private CRM_OrderService() {

    }
}