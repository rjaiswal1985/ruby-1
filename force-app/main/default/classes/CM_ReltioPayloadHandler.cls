public with sharing class CM_ReltioPayloadHandler {
    @AuraEnabled
    public static void processAndTriggerService(String jsonPayload, String channelName) {
        // Deserialize the JSON string into a Map or another suitable structure
        Map<String, Object> payloadData = (Map<String, Object>) JSON.deserializeUntyped(jsonPayload);
        
        Replay_Mechanism_Subscriber__mdt replayMechSub = Replay_Mechanism_Subscriber__mdt.getInstance(channelName);
        System.debug('----->'+replayMechSub);
        Map<String, Replay_Mechanism_Subscriber__mdt> mapReplayMechSub = Replay_Mechanism_Subscriber__mdt.getAll();
        for(String nameChannel : mapReplayMechSub.keySet()){
            System.debug('-----> '+mapReplayMechSub.get(nameChannel).Channel_Name__c);
        }
        
        // Create a list of platform event objects to be passed to the trigger service
        List<Reltio_CM_HCO_Inbound_Payload__e> platformEvents = new List<Reltio_CM_HCO_Inbound_Payload__e>();

        // Populate the platform event object with data from the payload
        Reltio_CM_HCO_Inbound_Payload__e newEvent = new Reltio_CM_HCO_Inbound_Payload__e();
        newEvent.Input_Json__c = jsonPayload; // If you need to pass the whole payload

        
        
        Reltio_CM_HCO_Inbound_Payload__e cusMaster = (Reltio_CM_HCO_Inbound_Payload__e)newEvent ;
        platformEvents.add(cusMaster);
        System.debug('platformEvents== ' +platformEvents);
        
        // Now call the reltioPayloadTriggerService with the list of platform event objects
        CM_ReltioHCOInboundPayloadTriggerHandler.reltioPayloadTriggerService(platformEvents);
        
    }
}