/***********************************************************************************************************************
* Name: CM_ReltioHCOInboundPayloadTrigger_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM platform event
* TestClass : CM_ReltioHCOInboundPayloadTrigger_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023         Test class for Reltio HCO trigger handler.
***********************************************************************************************************************/
@isTest
public with sharing class CM_ReltioHCOInboundPayloadTrigger_Test {

    @testSetup static void setupCustomSettingsData() {        
        Test.loadData(Customer_Master_Configurations__c.sObjectType, 'CustomerMasterConfigurations');
        Test.loadData(Exception_Handling__c.sObjectType, 'ReltioHCORequests');   
    }
    @isTest 
    static void reltioHCOService() {
        final List<Reltio_CM_HCO_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_Inbound_Payload__e>();
        final List<Account> acclist = new List<Account>();
        final List<Organization_E_Invoice__c> invoices = new List<Organization_E_Invoice__c>();
        final List<Organization_Communication__c> comminications = new List<Organization_Communication__c>();
        Test.startTest();  
        final Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='HCOTestData' limit 1];
        system.debug('@dataFacatory@'+dataFacatory);
        final Reltio_CM_HCO_Inbound_Payload__e payload = (Reltio_CM_HCO_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_Inbound_Payload__e.class);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        for(Account acc : [Select Id,(Select Id from Organization_Communications__r),(Select Id from Organization_E_Invoices__r) from Account limit 500]) {
            acclist.add(acc);
            invoices.addall(acc.Organization_E_Invoices__r);
            comminications.addAll(acc.Organization_Communications__r);
        }
        system.debug('@rohit1@'+acclist.size());
        system.debug('@rohit2@'+invoices.size());
        system.debug('@rohit3@'+comminications.size());
        for(Exception_Handling__c exp:[Select Id,Additional_Info_JSON__c,Module__c,Component_Name__c,Name from Exception_Handling__c]) {
            System.debug('@rohit@'+exp);
        }
        System.assertEquals(acclist.size(),1,'Account Created');
        System.assertEquals(invoices.size(),1,'Invoice Created');
        System.assertEquals(comminications.size(),3,'Communication Created');
    }
    @isTest 
    static void bulkHCOService() {
        final  List<Reltio_CM_HCO_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_Inbound_Payload__e>();
        final List<Account> acclist = new List<Account>();
        final List<Organization_E_Invoice__c> invoices = new List<Organization_E_Invoice__c>();
        final List<Organization_Communication__c> comminications = new List<Organization_Communication__c>();
        Reltio_CM_HCO_Inbound_Payload__e payload;
        String request;
        Test.startTest();
        final Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='HCOTestData' limit 1];
        for(Integer i=0; i<2; i++) {
            request = dataFacatory.Request__c;
            request.replaceAll('HCO1','HCO'+i);
            system.debug('@request@'+request);
            payload = (Reltio_CM_HCO_Inbound_Payload__e) System.JSON.deserialize(request, Reltio_CM_HCO_Inbound_Payload__e.class);
            payloads.add(payload);
        }
        EventBus.publish(payloads);
        Test.getEventBus().deliver(); 
        for(Account acc : [Select Id,(Select Id from Organization_Communications__r),(Select Id from Organization_E_Invoices__r) from Account limit 350]) {
            acclist.add(acc);
            invoices.addall(acc.Organization_E_Invoices__r);
            comminications.addAll(acc.Organization_Communications__r);
        }
        System.assertEquals(acclist.size(),20,'Account Created');
        System.assertEquals(invoices.size(),1,'Invoice Created');
        System.assertEquals(comminications.size(),41,'Communication Created');
        Test.stopTest();
    }
    @isTest 
    static void replayService() {
        final  List<Reltio_CM_HCO_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_Inbound_Payload__e>();
        final List<Account> acclist = new List<Account>();
        final List<Organization_E_Invoice__c> invoices = new List<Organization_E_Invoice__c>();
        final List<Organization_Communication__c> comminications = new List<Organization_Communication__c>();
        Test.startTest();
        final  Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='HCO2' limit 1];
        final Reltio_CM_HCO_Inbound_Payload__e payload = (Reltio_CM_HCO_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_Inbound_Payload__e.class);
        payload.Input_Json__c= payload.Input_Json__c.left(50);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        for(Account acc : [Select Id,(Select Id from Organization_Communications__r),(Select Id from Organization_E_Invoices__r) from Account limit 500]) {
            acclist.add(acc);
            invoices.addall(acc.Organization_E_Invoices__r);
            comminications.addAll(acc.Organization_Communications__r);
        }
        System.assertEquals(acclist.size(),0,'Account Created');
        System.assertEquals(invoices.size(),0,'Invoice Created');
        System.assertEquals(comminications.size(),0,'Communication Created');
        Test.stopTest();
    } 
}