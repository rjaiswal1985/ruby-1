public with sharing class CM_ReltioPayloadHandler {
    @AuraEnabled
    public static void processAndTriggerService(String jsonPayload) {
        // Deserialize the JSON string into a Map or another suitable structure
        Map<String, Object> payloadData = (Map<String, Object>) JSON.deserializeUntyped(jsonPayload);

        // Create a list of platform event objects to be passed to the trigger service
        List<Reltio_CM_HCO_Inbound_Payload__e> platformEvents = new List<Reltio_CM_HCO_Inbound_Payload__e>();

        // Populate the platform event object with data from the payload
        Reltio_CM_HCO_Inbound_Payload__e newEvent = new Reltio_CM_HCO_Inbound_Payload__e();
        //newEvent.ReplayId = (Long) payloadData.get('ReplayId');
        //newEvent.eventUUId = (String) payloadData.get('eventUUId');
        newEvent.Input_Json__c = jsonPayload; // If you need to pass the whole payload

        platformEvents.add(newEvent);
        System.debug('platformEvents== ' +platformEvents);
        
        JSON_Data__c jsonD = new JSON_Data__c();
        jsonD.Name = 'UCB Replay 1';
        jsonD.Input_Json__c = jsonPayload;
        insert jsonD;
        System.debug('jsonD = '+jsonD.Id);

        // Now call the reltioPayloadTriggerService with the list of platform event objects
        CM_ReltioHCOInboundPayloadTriggerHandler.reltioPayloadTriggerService(platformEvents);
    }
}