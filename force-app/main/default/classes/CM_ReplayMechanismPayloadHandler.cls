/***********************************************************************************************************************
 * Name: CM_ReplayMechanismPayloadHandler
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Dynamically calling Subscriber based on Replay ID, EventUUID and platform event
 * TestClass : CM_ReplayMechanismPayloadHandlerTest
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Azhar Jamil                   4/29/2024          Class invoked from the lwc component Replay Mechanism dynamically based on platform event.
 ***********************************************************************************************************************/

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

            if (replayMetadata != null) {
                String subscriberClassName = replayMetadata.Subscriber_Class__c;
                String strSObjectName = replayMetadata.Channel_Name__c;

                if (String.isNotBlank(subscriberClassName) && String.isNotBlank(strSObjectName)) {
                    // Create a new instance of the subscriber class
                    Type subscriberType = Type.forName(subscriberClassName);
                    Object subscriberInstance = subscriberType.newInstance();
                    System.debug('Test subscriberInstance==> '+subscriberInstance);

                    // Check if the class implements ReplaySubscriber
                    if (subscriberInstance instanceof ReplaySubscriber) {
                        List<SObject> platformEvents = new List<SObject>();
                        SObject newEvent = Schema.getGlobalDescribe().get(strSObjectName).newSObject();
                        newEvent.put('Input_Json__c', jsonPayload);
                        platformEvents.add(newEvent);
                        System.debug('Test platformEvents==> '+platformEvents);

                        // Cast the instance to ReplaySubscriber and call the processPayload method
                        ReplaySubscriber subscriber = (ReplaySubscriber) subscriberInstance;
                        subscriber.processPayload(platformEvents);
                        System.debug('Test subscriber==> '+subscriber);

                        return 'Success: The payload was processed successfully.';
                    } else {
                        return 'Error: The class does not implement the ReplaySubscriber interface.';
                    }
                } else {
                    return 'Error: No valid subscriber class or sObject type specified.';
                }
            } else {
                return 'Error: No valid metadata found for the specified channel.';
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return 'Error: An unexpected error occurred during processing.';
        }
    }
}