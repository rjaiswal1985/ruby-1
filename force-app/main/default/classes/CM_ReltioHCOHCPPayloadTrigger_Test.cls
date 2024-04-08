/***********************************************************************************************************************
* Name: CM_ReltioHCOHCPPayloadTrigger_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM platform event
* TestClass : CM_ReltioHCOHCPPayloadTrigger_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023         Test class for Reltio HCO trigger handler.
***********************************************************************************************************************/
@isTest
public with sharing class CM_ReltioHCOHCPPayloadTrigger_Test {

    @testSetup static void setupCustomSettingsData() {        
        Test.loadData(Customer_Master_Configurations__c.sObjectType, 'CustomerMasterConfigurations');
        Test.loadData(Exception_Handling__c.sObjectType, 'ReltioHCOHCPRequests');   
    }
    @isTest 
    static void reltioHCOHCPService() {
        final List<Reltio_CM_HCO_HCP_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_HCP_Inbound_Payload__e>();
        final List<Account> acclist = new List<Account>();
        final List<Organization_E_Invoice__c> invoices = new List<Organization_E_Invoice__c>();
        final List<Organization_Communication__c> comminications = new List<Organization_Communication__c>();
        final List<Contact> contactList = new List<Contact>();
        final List<AccountContactRelation> relationList = new List<AccountContactRelation>();
        Test.startTest();  
        final Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='HCOHCP1' limit 1];
        system.debug('@dataFacatory@'+dataFacatory);
        final Reltio_CM_HCO_HCP_Inbound_Payload__e payload = (Reltio_CM_HCO_HCP_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_HCP_Inbound_Payload__e.class);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        for(Account acc : [Select Id,(Select Id from Organization_Communications__r),(Select Id from Organization_E_Invoices__r),
                    (Select Id from Contacts),(Select Id from AccountContactRelations) from Account limit 500]) {
            acclist.add(acc);
            invoices.addall(acc.Organization_E_Invoices__r);
            comminications.addAll(acc.Organization_Communications__r);
            contactList.addAll(acc.Contacts);
            relationList.addAll(acc.AccountContactRelations);
        }
        system.debug('@1rohit1@'+acclist.size());
        system.debug('@1rohit2@'+invoices.size());
        system.debug('@1rohit3@'+comminications.size());
        System.assertEquals(acclist.size(),1,'Account Created');
        System.assertEquals(contactList.size(),1,'Contact Created');
        System.assertEquals(relationList.size(),1,'Account Contact Relationship Created');
    }
    @isTest 
    static void bulkHCOHCPService() {
        final  List<Reltio_CM_HCO_HCP_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_HCP_Inbound_Payload__e>();
        final List<Account> acclist = new List<Account>();
        final List<Organization_E_Invoice__c> invoices = new List<Organization_E_Invoice__c>();
        final List<Organization_Communication__c> comminications = new List<Organization_Communication__c>();
        final List<Contact> contactList = new List<Contact>();
        final List<AccountContactRelation> relationList = new List<AccountContactRelation>();
        Reltio_CM_HCO_HCP_Inbound_Payload__e payload;
        Test.startTest();
        for(Exception_Handling__c dataFacatory : [Select Request__c from Exception_Handling__c  limit 20] ) {
            payload = (Reltio_CM_HCO_HCP_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_HCP_Inbound_Payload__e.class);
            payloads.add(payload);
        }
        EventBus.publish(payloads);
        Test.getEventBus().deliver(); 
        Test.stopTest();
        for(Account acc : [Select Id,(Select Id from Organization_Communications__r),(Select Id from Organization_E_Invoices__r),
            (Select Id from Contacts),(Select Id from AccountContactRelations) from Account limit 500]) {
            acclist.add(acc);
            invoices.addall(acc.Organization_E_Invoices__r);
            comminications.addAll(acc.Organization_Communications__r);
            contactList.addAll(acc.Contacts);
            relationList.addAll(acc.AccountContactRelations);
        }
        System.assertEquals(acclist.size(),20,'Accounts Created');
        System.assertEquals(contactList.size(),20,'Contacts Created');
        System.assertEquals(relationList.size(),20,'Relationships Created');
        
    }
    @isTest 
    static void replayService() {
        final  List<Reltio_CM_HCO_HCP_Inbound_Payload__e> payloads = new List<Reltio_CM_HCO_HCP_Inbound_Payload__e>();
        final List<Account> acclist = new List<Account>();
        final List<Organization_E_Invoice__c> invoices = new List<Organization_E_Invoice__c>();
        final List<Organization_Communication__c> comminications = new List<Organization_Communication__c>();
        final List<Contact> contactList = new List<Contact>();
        final List<AccountContactRelation> relationList = new List<AccountContactRelation>();
        Test.startTest();
        final  Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='HCOHCP1' limit 1];
        final Reltio_CM_HCO_HCP_Inbound_Payload__e payload = (Reltio_CM_HCO_HCP_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCO_HCP_Inbound_Payload__e.class);
        payload.Input_Json__c= payload.Input_Json__c.left(50);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        Test.stopTest();
        for(Account acc : [Select Id,(Select Id from Organization_Communications__r),(Select Id from Organization_E_Invoices__r),
        (Select Id from Contacts),(Select Id from AccountContactRelations) from Account limit 500]) {
        acclist.add(acc);
        invoices.addall(acc.Organization_E_Invoices__r);
        comminications.addAll(acc.Organization_Communications__r);
        contactList.addAll(acc.Contacts);
        relationList.addAll(acc.AccountContactRelations);
    }
        System.assertEquals(acclist.size(),0,'Accounts Created');
        System.assertEquals(contactList.size(),0,'Contacts Created');
        System.assertEquals(relationList.size(),0,'Relationships Created');        
    } 
}