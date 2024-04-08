/***********************************************************************************************************************
 * Name: CM_ReltioHCPService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class handles Contact Creation, Service invoked from platform event trigger handler
 * TestClass : CM_ReltioHCPService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                   07/11/2023          Contact Creation Service 
 ***********************************************************************************************************************/
public with sharing class CM_ReltioHCPService {
    /**    
     * @description :  Method to parse input json and get Contact data
     * Parameters : input json, process name from platfrom event
     */
    public static Map < String, Map < String, Sobject >> upsertHCPServices(String inputJson, Map < String, CM_ReltioHandlerService.SobjectData > process2Metadata) {        
        final Map < String, Map < String, Map < String, Object >>> key2value = CM_JSONParser.objectJsonParsers(inputJson, process2Metadata.get(CM_ReltioConstants.RELTIOHCP));
        return upsertHCPSelector(key2value);
    }

    /**     
     * @description : Retrieves data of Contact and related sobjects
     */
    public static Map < String, Map < String, Sobject >> upsertHCPSelector(Map < String, Map < String, Map < String, Object >>> key2value) {
        final Map < String, Map < String, Sobject >> resultMap = new Map < String, Map < String, Sobject >> ();
        Contact contact = CM_ContactService.upsertContact(key2value.get('Contact'));
        Map < String, Person_Communication__c > commInfoMap = new Map < String, Person_Communication__c > ();
        final Map < String, Contact > contactMap = new Map < String, Contact > ();

        //person communication information
        if (key2value.containsKey('Person_Communication__c')) {
            commInfoMap = CM_PersonCommunicationService.upsertHCPcommunicationInfo(key2value.get('Person_Communication__c'), contact);
            resultMap.put('Person_Communication__c', commInfoMap);
        }

        if (key2value.containsKey('Educational_Detail__c')) {
            final Map < String, Educational_Detail__c > hcpEduMap = CM_EducationalDetailsService.upsertEducationalDetails(key2value.get('Educational_Detail__c'), contact);
            resultMap.put('Educational_Detail__c', hcpEduMap);
        }

        if (key2value.containsKey('License_Information__c')) {
            final Map < String, License_Information__c > hcpLicenseInfoMap = CM_LicenseInformationService.upsertLicenseInformationDetails(key2value.get('License_Information__c'), contact);
            resultMap.put('License_Information__c', hcpLicenseInfoMap);
        }

        //update phone and email in the contact from Communication Information
        contact = getContactList(contact, commInfoMap.values());
        contactMap.put(contact.MDM_Id__c, contact);
        resultMap.put('Contact', contactMap);
        return resultMap;
    }
    /**     
     * @description : Populates Contact primary phone, email
     */
    private static contact getContactList(Contact contact, List < Person_Communication__c > personInfoList) {
        for (Person_Communication__c hcpInfo: personInfoList) {
            if (hcpInfo.Subtype__c == CM_ReltioConstants.PRIMARYPHONE) {
                contact.Phone = hcpInfo.value__c;
            }
            if (hcpInfo.Subtype__c == CM_ReltioConstants.PRIMARYEMAIL) {
                contact.Email = hcpInfo.value__c;
            }
        }
        contact.MailingStreet = CM_ReltioHandlerService.addressLine(contact.MailingStreet,contact.Address_Line_1__c,true);
        contact.MailingStreet = CM_ReltioHandlerService.addressLine(contact.MailingStreet,contact.Address_Line_2__c,false);
        contact.MailingStreet = CM_ReltioHandlerService.addressLine(contact.MailingStreet,contact.Address_Line_3__c,false);
        contact.MailingStreet = CM_ReltioHandlerService.addressLine(contact.MailingStreet,contact.Address_Line_4__c,false);

        contact.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(contact.Native_Address__Street__s,contact.Native_Address_Line_1__c,true);
        contact.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(contact.Native_Address__Street__s ,contact.Native_Address_Line_2__c,false);
        contact.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(contact.Native_Address__Street__s ,contact.Native_Address_Line_3__c,false);
        contact.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(contact.Native_Address__Street__s ,contact.Native_Address_Line_4__c,false);
        return contact;
    }
    public  static Map<String, Map < String, Sobject >> getOldContactMap(Map <String, Map < String, Sobject >> upsertNewMap) {
        final Set<String> recordId = upsertNewMap.get('Contact').keyset();
        final Map <String, Map < String, Sobject >> upsertOldMap = new Map < String, Map < String, Sobject >> ();
        upsertOldMap.put('Contact',new Map <String, Sobject>());  
        upsertOldMap.put('Educational_Detail__c',new Map <String, Sobject>());  
        upsertOldMap.put('Person_Communication__c',new Map <String, Sobject>());  
        upsertOldMap.put('License_Information__c',new Map <String, Sobject>()); 
        for(Contact con : [Select Id,MDM_Id__c,TimeStamp_Decimal__c,Account.MDM_Id__c,
            (Select Id,MDM_Id__c,Contact__r.MDM_Id__c,TimeStamp_Decimal__c from Educational_Details__r),
            (Select Id,MDM_Id__c,Contact__r.MDM_Id__c,TimeStamp_Decimal__c from Person_Communications__r),
            (Select Id,MDM_Id__c,Contact__r.MDM_Id__c,TimeStamp_Decimal__c from License_Informations__r) 
            from Contact where MDM_Id__c = :recordId with SECURITY_ENFORCED]) {
            upsertOldMap.get('Contact').put(con.MDM_Id__c,con);
            for(Educational_Detail__c education : con.Educational_Details__r) {
                upsertOldMap.get('Educational_Detail__c').put(education.MDM_Id__c,education);  
            }
            for(Person_Communication__c communication: con.Person_Communications__r) {
                upsertOldMap.get('Person_Communication__c').put(communication.MDM_Id__c,communication); 
            }
            for(License_Information__c licence: con.License_Informations__r) {
                upsertOldMap.get('License_Information__c').put(licence.MDM_Id__c,licence); 
            }
        }
        return upsertOldMap;
    }
    private CM_ReltioHCPService() {}
}