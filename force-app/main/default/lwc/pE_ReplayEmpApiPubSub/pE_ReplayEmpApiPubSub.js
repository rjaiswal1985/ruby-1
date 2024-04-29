import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import getPlatformEvents from '@salesforce/apex/FetchPlatformEvents.getPlatformEvents';
import processAndTriggerService from '@salesforce/apex/CM_ReltioPayloadHandler.processAndTriggerService';

export default class PE_ReplayEmpApiPubSub extends LightningElement {
    title;
    showPayload = false;
    selectedEventName;
    platformEvents = [];
    replayId = -1; // Set to -1 to get all events
    eventUUID = '';
    isSubscribed = false;
    subscription = {};
    requiredEvent={};
    disableSubmitButton = true; // Initially disable the Submit button

    handleReplayIdChange(event){
        this.replayId = event.target.value;
    }

    handleEventUUIDChange(event){
        this.eventUUID = event.target.value;
    }

    handleEventNameChange(event) {
        this.selectedEventName = event.detail.value;
    }

    @wire(getPlatformEvents)
    wiredPlatformEvents({ error, data }) {
        if (data) {
            this.platformEvents = data.map(eventName => {
                return { label: eventName, value: eventName };
            });
        } else if (error) {
            console.error('Error fetching platform events:', error);
        }
    }

    viewPayload() {
        this.subscribeToChannel();
    }

    submitPayload() {
        // Call the Apex method to process and trigger the service
        processAndTriggerService({ jsonPayload: this.requiredEvent, channelName: this.selectedEventName })
            .then(() => {
                console.log('Payload processed and service triggered successfully.');
            })
            .catch(error => {
                console.error('Error while processing payload:', error);
            });
    }

    subscribeToChannel() {
        const messageCallback = (response) => {
            // Handle incoming events
            console.log('Received event payload: ', JSON.stringify(response));
            // Check if the condition to unsubscribe is met
            if (response.data.event.replayId==this.replayId || response.data.event.eventUUID == this.eventUUID) {
                this.requiredEvent = JSON.stringify(response);
                console.log('Received Filtered event payload: ', this.requiredEvent);
                console.log('Test eventUUID: '+this.eventUUID)
                this.unsubscribeFromChannel();
            }
            this.showPayload = true;
            this.disableSubmitButton = false; // Enable the Submit button when the payload is visible
        };

        // Callback invoked when a subscribe operation is successfully completed
        const subscribeCallback = (response) => {
            console.log('Successfully subscribed to channel: ', JSON.stringify(response));
            this.isSubscribed = true;
        };

        // Callback invoked when an error occurs
        const errorCallback = (error) => {
            console.error('Error occurred: ', JSON.stringify(error));
        };

        const channelName = '/event/' + this.selectedEventName;
        this.title = "Below is the message sent to the "+this.selectedEventName+" Channel";
        // Subscribe to the channel
        subscribe(channelName, this.replayId == -1 ? this.eventUUID : this.replayId - 1, messageCallback)
            .then(response => {
                this.subscription = response;
                subscribeCallback(response);
            })
            .catch(errorCallback);
        
        // Set up error handler
        onError(errorCallback);
    }

    unsubscribeFromChannel() {
        // Unsubscribe from the channel
        unsubscribe(this.subscription, (response) => {
            console.log('Unsubscribed from channel: ', JSON.stringify(response));
            this.isSubscribed = false;
        });
    }

    disconnectedCallback() {
        // Automatically unsubscribe from the channel when the component is disconnected
        this.unsubscribeFromChannel();
    }
}