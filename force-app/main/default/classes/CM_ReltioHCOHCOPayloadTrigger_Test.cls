/***********************************************************************************************************************
* Name: CM_ReltioHCOHCOPayloadTrigger_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM platform event
* TestClass : CM_ReltioHCOHCOPayloadTrigger_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023         Test class for Reltio HCOHCO trigger handler.
***********************************************************************************************************************/
@isTest
public with sharing class CM_ReltioHCOHCOPayloadTrigger_Test {

    @testSetup static void setupCustomSettingsData() {        
        Test.loadData(Customer_Master_Configurations__c.sObjectType, 'CustomerMasterConfigurations');
        Test.loadData(Exception_Handling__c.sObjectType, 'ReltioHCOHCORequests');   
    }
    @isTest 
    static void reltioHCOHCOService() {
        final List<Reltio_CM_HCO_HCO_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_HCO_Inbound_Payload__e>();
        final List<Account> acclist = new List<Account>();
        final List<Organization_E_Invoice__c> invoices = new List<Organization_E_Invoice__c>();
        final List<Organization_Communication__c> comminications = new List<Organization_Communication__c>();
        final List<Account_Relationship__c> relationShips = new List<Account_Relationship__c>();
        Test.startTest();  
        final Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='HCOHCO1' limit 1];
        final Reltio_CM_HCO_HCO_Inbound_Payload__e payload = (Reltio_CM_HCO_HCO_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_HCO_Inbound_Payload__e.class);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        Test.stopTest();
        for(Account acc : [Select Id,(Select Id from Organization_Communications__r),(Select Id from Organization_E_Invoices__r),
                    (Select Id from Account_Relationships__r) from Account limit 4]) {
            acclist.add(acc);
            invoices.addall(acc.Organization_E_Invoices__r);
            comminications.addAll(acc.Organization_Communications__r);
            relationShips.addAll(acc.Account_Relationships__r);
        }
        System.assertEquals(acclist.size(),2,'Account Created');
        System.assertEquals(relationShips.size(),1,'Relationship Created');
    }
    @isTest 
    static void bulkHCOHCOService() {
        final  List<Reltio_CM_HCO_HCO_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_HCO_Inbound_Payload__e>();
        final List<Account> acclist = new List<Account>();
        final List<Organization_E_Invoice__c> invoices = new List<Organization_E_Invoice__c>();
        final List<Organization_Communication__c> comminications = new List<Organization_Communication__c>();
        final List<Account_Relationship__c> relationShips = new List<Account_Relationship__c>();
        Reltio_CM_HCO_HCO_Inbound_Payload__e payload;
        Test.startTest();
        for(Exception_Handling__c dataFacatory : [Select Request__c from Exception_Handling__c Limit 50] ) {
            payload = (Reltio_CM_HCO_HCO_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_HCO_Inbound_Payload__e.class);
            payloads.add(payload);
        }
        EventBus.publish(payloads);
        Test.getEventBus().deliver(); 
        Test.stopTest();
        for(Account acc : [Select Id,(Select Id from Organization_Communications__r),(Select Id from Organization_E_Invoices__r),
            (Select Id from Account_Relationships__r) from Account limit 1500]) {
            acclist.add(acc);
            invoices.addall(acc.Organization_E_Invoices__r);
            comminications.addAll(acc.Organization_Communications__r);
            relationShips.addAll(acc.Account_Relationships__r);
        }
        System.assertEquals(acclist.size(),100,'Account Created');
        System.assertEquals(relationShips.size(),50,'Relationship Created');
    }
    @isTest 
    static void replayService() {
        final  List<Reltio_CM_HCO_HCO_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_HCO_Inbound_Payload__e>();
        final List<Account> acclist = new List<Account>();
        final List<Organization_E_Invoice__c> invoices = new List<Organization_E_Invoice__c>();
        final List<Organization_Communication__c> comminications = new List<Organization_Communication__c>();
        Test.startTest();
        final  Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='HCOHCO1' limit 1];
        final Reltio_CM_HCO_HCO_Inbound_Payload__e payload = (Reltio_CM_HCO_HCO_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_HCO_Inbound_Payload__e.class);
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