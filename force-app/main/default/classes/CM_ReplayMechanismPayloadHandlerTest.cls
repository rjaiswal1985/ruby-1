@IsTest
public class CM_ReplayMechanismPayloadHandlerTest {
    // Define a test-only class to simulate Replay_Mechanism_Subscriber__mdt
    public class TestMetadata {
        public String channelName;
        public String subscriberClass;
        //public String subscriberMethod;

        public TestMetadata(String channelName, String subscriberClass) {
            this.channelName = channelName;
            this.subscriberClass = subscriberClass;
            //this.subscriberMethod = subscriberMethod;
        }
    }

    @IsTest
    static void testProcessAndTriggerServiceSuccess() {
        // Mock custom metadata
        List<TestMetadata> metadata = new List<TestMetadata>{
            new TestMetadata('Reltio_CM_HCO_Inbound_Payload__e', 'ReplaySubscriber')
        };

        // Create a test JSON payload
        String testJsonPayload = '{"key": "value"}';
        String testChannelName = 'Reltio_CM_HCO_Inbound_Payload__e';

        // Call the Apex method, providing expected metadata for channelName
        Test.startTest();
        String result = CM_ReplayMechanismPayloadHandler.processAndTriggerService(testJsonPayload, testChannelName);
        Test.stopTest();

        // Assert the expected outcome
        System.assertEquals('Success: The payload was processed successfully.', result, 'Unexpected return value from processAndTriggerService.');
    }

    @IsTest
    static void testProcessAndTriggerServiceInvalidChannel() {
        // Test with a channel name that doesn't exist in the simulated metadata
        String testJsonPayload = '{"key": "value"}';
        String invalidChannelName = 'NonExistentChannel';

        Test.startTest();
        String result = CM_ReplayMechanismPayloadHandler.processAndTriggerService(testJsonPayload, invalidChannelName);
        Test.stopTest();

        System.assertEquals('Error: No valid metadata found for the specified channel.', result, 'Unexpected return value for invalid channel.');
    }
}