/***********************************************************************************************************************
* Name: CM_ReltioHCPInboundPayloadTrigger_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM platform event
* TestClass : CM_ReltioHCPInboundPayloadTrigger_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023         Test class for Reltio HCO trigger handler.
***********************************************************************************************************************/
@isTest
public with sharing class CM_ReltioHCPInboundPayloadTrigger_Test {

    @testSetup static void setupCustomSettingsData() {        
        Test.loadData(Customer_Master_Configurations__c.sObjectType, 'CustomerMasterConfigurations');
        Test.loadData(Exception_Handling__c.sObjectType, 'ReltioHCPRequests');   
    }
    @isTest 
    static void reltioHCPService() {
        final List<Reltio_CM_HCP_Inbound_Payload__e> payloads = new List<Reltio_CM_HCP_Inbound_Payload__e>();
        final List<Contact> conList = new List<Contact>();
        final List<Person_Communication__c> communications = new List<Person_Communication__c>();
        final List<Educational_Detail__c> eduDetails = new List<Educational_Detail__c>();
        final List<License_Information__c> lincences = new List<License_Information__c>();
        Test.startTest();  
        final Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='HCP1' limit 1];
        final Reltio_CM_HCP_Inbound_Payload__e payload = (Reltio_CM_HCP_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCP_Inbound_Payload__e.class);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        for(Contact con : [Select Id,(Select Id from Educational_Details__r),(Select Id from Person_Communications__r),
                        (Select Id from License_Informations__r) from Contact limit 1]) {
            conList.add(con);
            communications.addall(con.Person_Communications__r);
            eduDetails.addAll(con.Educational_Details__r);
            lincences.addAll(con.License_Informations__r);
        }
        System.assertEquals(eduDetails.size(),1,'Education details Created');
        System.assertEquals(lincences.size(),1,'Licences Created');
        System.assertEquals(communications.size(),3,'Communication Created');
        Test.stopTest();
    }
    @isTest 
    static void bulkHCPService() {
        final  List<Reltio_CM_HCP_Inbound_Payload__e> payloads = new List<Reltio_CM_HCP_Inbound_Payload__e>();
        final List<Contact> conList = new List<Contact>();
        final List<Person_Communication__c> communications = new List<Person_Communication__c>();
        final List<Educational_Detail__c> eduDetails = new List<Educational_Detail__c>();
        final List<License_Information__c> lincences = new List<License_Information__c>();
        Reltio_CM_HCP_Inbound_Payload__e payload;
        Test.startTest();
        for(Exception_Handling__c dataFacatory : [Select Request__c from Exception_Handling__c  limit 300] ) {
            payload = (Reltio_CM_HCP_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCP_Inbound_Payload__e.class);
            payloads.add(payload);
        }
        EventBus.publish(payloads);
        Test.getEventBus().deliver(); 
        for(Contact con : [Select Id,(Select Id from Educational_Details__r),
                (Select Id from Person_Communications__r),(Select Id from License_Informations__r) from Contact Limit 500]) {
            conList.add(con);
            communications.addall(con.Person_Communications__r);
            eduDetails.addAll(con.Educational_Details__r);
            lincences.addAll(con.License_Informations__r);
        }
        System.assertEquals(eduDetails.size(),0,'Education details Created');
        System.assertEquals(lincences.size(),0,'Licences Created');
        System.assertEquals(communications.size(),0,'Communication Created');
        Test.stopTest();
    }
    @isTest 
    static void replayService() {
        final  List<Reltio_CM_HCP_Inbound_Payload__e> payloads = new List<Reltio_CM_HCP_Inbound_Payload__e>();
        final List<Contact> conList = new List<Contact>();
        final List<Person_Communication__c> communications = new List<Person_Communication__c>();
        final List<Educational_Detail__c> eduDetails = new List<Educational_Detail__c>();
        final List<License_Information__c> lincences = new List<License_Information__c>();
        Test.startTest();
        final  Exception_Handling__c dataFacatory = [Select Request__c from Exception_Handling__c where Process_Name__c='HCP2' limit 1];
        final Reltio_CM_HCP_Inbound_Payload__e payload = (Reltio_CM_HCP_Inbound_Payload__e) System.JSON.deserialize(dataFacatory.Request__c, Reltio_CM_HCP_Inbound_Payload__e.class);
        payload.Input_Json__c= payload.Input_Json__c.left(50);
        payloads.add(payload);
        EventBus.publish(payloads);
        Test.getEventBus().deliver();
        for(Contact con : [Select Id,(Select Id from Educational_Details__r),(Select Id from Person_Communications__r),(Select Id from License_Informations__r) from Contact limit 1]) {
            conList.add(con);
            communications.addall(con.Person_Communications__r);
            eduDetails.addAll(con.Educational_Details__r);
            lincences.addAll(con.License_Informations__r);
        }
        System.assertEquals(eduDetails.size(),0,'Education details Created');
        System.assertEquals(lincences.size(),0,'Licences Created');
        System.assertEquals(communications.size(),0,'Communication Created');
        Test.stopTest();
    } 
}