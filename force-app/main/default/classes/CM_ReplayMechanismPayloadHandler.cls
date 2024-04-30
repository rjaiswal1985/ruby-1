public with sharing class CM_ReplayMechanismPayloadHandler {
    @AuraEnabled
    public static String processAndTriggerService(String jsonPayload, String channelName) {
        try {
            // Get all custom metadata
            Map<String, Replay_Mechanism_Subscriber__mdt> mapReplayMechSub = Replay_Mechanism_Subscriber__mdt.getAll();
            
            // Find the relevant metadata for the channel
            Replay_Mechanism_Subscriber__mdt replayMetadata = null;
            for (String strMetakey : mapReplayMechSub.keySet()) {
                Replay_Mechanism_Subscriber__mdt metadata = mapReplayMechSub.get(strMetakey);
                if (metadata.Channel_Name__c == channelName) {
                    replayMetadata = metadata;
                    break;
                }
            }
            
            if(replayMetadata != Null){
                // Get the sObject type and subscriber class name from metadata
                String strSObjectName = replayMetadata.Channel_Name__c;
                if(String.isNotBlank(strSObjectName)){
                    // Create a dynamic list of the appropriate sObject type
                    Type sObjectType = Type.forName(strSObjectName);
                    List<SObject> platformEvents = new List<SObject>();
                    
                    // Create a new instance of the sObject and set the required fields
                    //SObject newEvent = (SObject) sObjectType.newInstance();
                    sObject newEvent = Schema.getGlobalDescribe().get(strSObjectName).newSObject();
                    newEvent.put('Input_Json__c', jsonPayload); // Ensure this field exists
                    platformEvents.add(newEvent);
                    
                    // Get the subscriber class name and method name from metadata
                    String subscriberClassName = replayMetadata.Subscriber_Class__c;
                    String subscriberMethodName = replayMetadata.Subscriber_Method__c;
                    
                    if(String.isNotBlank(subscriberClassName) && String.isNotBlank(subscriberMethodName)){
                        // Use reflection to dynamically instantiate the subscriber class and call the method
                        Type subscriberType = Type.forName(subscriberClassName);
                        Object subscriberInstance = subscriberType.newInstance();
                        
                        // Use reflection to call the method specified by Subscriber_Method__c
                        //subscriberType.getMethod(subscriberMethodName, new List<Type>{List<SObject>.class});
                        //method.invoke(subscriberInstance, new List<Object>{platformEvents});
                        
                        return 'Success: The payload was processed successfully.';
                    } else {
                        System.debug('No valid subscriber class or method specified in metadata for channel: ' + channelName);
                        return 'Error: No valid subscriber class or method specified in metadata for channel: ' + channelName;
                    }
                } else {
                    System.debug('No valid sObject type specified in metadata for channel: ' + channelName);
                    return 'Error: No valid sObject type specified in metadata for channel: ' + channelName;
                }
            } else {
                System.debug('No valid metadata found for channel: ' + channelName);
                return 'Error: No valid metadata found for channel: ' + channelName; // Return error message
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return 'Error: An unexpected error occurred during processing.';
        }
    }
}

/*public with sharing class CM_ReplayMechanismPayloadHandler {
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
        
        // Get the custom metadata for the channel
        Replay_Mechanism_Subscriber__mdt channelMetadata = Replay_Mechanism_Subscriber__mdt.getInstance(channelName);
        
        // Create a list of platform event objects to be passed to the trigger service
        List<sObject> platformEvents = new List<sObject>();
        
        // Get the platform event type from the custom metadata
        String platformEventType = channelMetadata.Channel_Name__c;
        
        // Create a new instance of the platform event type
        sObject newEvent = Schema.getGlobalDescribe().get(platformEventType).newSObject();
        
        // Populate the platform event object with data from the payload
        newEvent.put('Input_Json__c', jsonPayload); // If you need to pass the whole payload
        
        // Add the platform event object to the list
        platformEvents.add(newEvent);
        
        System.debug('platformEvents== ' +platformEvents);
        
        // Now call the trigger service with the list of platform event objects
        String subscriberClass = channelMetadata.Subscriber_Class__c;
        Type targetType = Type.forName(subscriberClass);
        String triggerMethod = channelMetadata.Subscriber_Method__c;
        
        if (targetType != null && triggerMethod != null) {
            Object targetObject = targetType.newInstance();
            Method triggerMethodObj = targetType.getDeclaredMethod(triggerMethod, List<sObject>.class);
            triggerMethodObj.setAccessible(true);
            triggerMethodObj.invoke(targetObject, platformEvents);
        }
    }
}*/