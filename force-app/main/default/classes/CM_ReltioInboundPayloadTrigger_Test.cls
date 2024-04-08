/***********************************************************************************************************************
* Name: CM_ReltioInboundPayloadTrigger_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM platform event
* TestClass : CM_ReltioInboundPayloadTrigger_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023         Test class for Reltio trigger handler
***********************************************************************************************************************/
@isTest
public with sharing class CM_ReltioInboundPayloadTrigger_Test {
    /*****Event Published **************** */
    private static final String EVENT_MSG = 'Event Published';
    
    @testSetup static void setupCustomSettingsData() {        
        Test.loadData(Customer_Master_Configurations__c.sObjectType, 'CustomerMasterConfigurations');
        Test.loadData(Exception_Handling__c.sObjectType, 'ReltioRequests');   }
    @isTest 
    static void reltioHCOService() {
        final List<Reltio_CM_HCO_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_Inbound_Payload__e>();
        Test.startTest();  
        final Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='ReltioHCOService'];
        final Reltio_CM_HCO_Inbound_Payload__e payload = (Reltio_CM_HCO_Inbound_Payload__e) JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_Inbound_Payload__e.class);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        System.assertEquals(payloads.size(),1,EVENT_MSG);
        Test.stopTest();
    }
    @isTest 
    static void reltioHCPService() {
        final List<Reltio_CM_HCP_Inbound_Payload__e> payloads = new List<Reltio_CM_HCP_Inbound_Payload__e>();
        Test.startTest();
        final Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='ReltioHCPService'];
        final Reltio_CM_HCP_Inbound_Payload__e payload = (Reltio_CM_HCP_Inbound_Payload__e) JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCP_Inbound_Payload__e.class);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        System.assertEquals(payloads.size(),1,EVENT_MSG);
        Test.stopTest();
    }
    @isTest 
    static void reltioHCOHCOService() {
        final  List<Reltio_CM_HCO_HCO_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_HCO_Inbound_Payload__e>();
        Test.startTest();
        final  Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='ReltioHCOHCOService'];
        final Reltio_CM_HCO_HCO_Inbound_Payload__e payload = (Reltio_CM_HCO_HCO_Inbound_Payload__e) JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_HCO_Inbound_Payload__e.class);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        System.assertEquals(payloads.size(),1,EVENT_MSG);
        Test.stopTest();
    }
    @isTest 
    static void reltioHCPHCOService() {
        final  List<Reltio_CM_HCO_HCP_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_HCP_Inbound_Payload__e>();
        Test.startTest();
        final  Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='ReltioHCPHCOService'];
        final Reltio_CM_HCO_HCP_Inbound_Payload__e payload = (Reltio_CM_HCO_HCP_Inbound_Payload__e) JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_HCP_Inbound_Payload__e.class);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        System.assertEquals(payloads.size(),1,EVENT_MSG);
        Test.stopTest();
    }
    @isTest 
    static void replayService() {
        final  List<Reltio_CM_HCO_HCP_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_HCP_Inbound_Payload__e>();
        Test.startTest();
        final  Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='ReltioHCPHCOService'];
        final Reltio_CM_HCO_HCP_Inbound_Payload__e payload = (Reltio_CM_HCO_HCP_Inbound_Payload__e) JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_HCP_Inbound_Payload__e.class);
        payload.Input_Json__c= payload.Input_Json__c.left(50);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        System.assertEquals(payloads.size(),1,EVENT_MSG);
        Test.stopTest();
    }
}