public class FailureAndSuccessCallback implements EventBus.EventPublishFailureCallback,
    EventBus.EventPublishSuccessCallback {
    
    public void onFailure(EventBus.FailureResult result) {
        List<String> eventUuids = result.getEventUuids();
        System.debug(eventUuids.size() + ' events failed to publish.');      
        System.debug('Callback eventUuids to match with event objects: ' + eventUuids);

        // Create a follow-up task for failed events.
        insertTask(eventUuids, false);
    }

    public void onSuccess(EventBus.SuccessResult result) {
        List<String> eventUuids = result.getEventUuids();
        System.debug(eventUuids.size() + ' events were published successfully.');
        System.debug('Callback eventUuids to match with event objects: ' + eventUuids);

        // Create a follow-up task for successful events.
        insertTask(eventUuids, true);
    }
    
    private void insertTask(List<String> eventUuids, Boolean isSuccess) {
        String eventIdString = '';
        for (String evtId : eventUuids) {
            eventIdString += evtId + ' ';
        }
        Task t = new Task();
        if (isSuccess == true) {
            t.Subject = 'Follow up on successful event publishing.';
            t.Description = eventUuids.size() + 
                ' events published successfully. Event UUIDs: '
            + eventIdString;
        } else {
            t.Subject = 'Follow up on event publishing failures.';
            t.Description = eventUuids.size() + 
                ' events failed to publish. Event UUIDs: '
            + eventIdString; 
        }

        // Set the due date
        t.ActivityDate = Date.today().addDays(3);
        // Set owner ID explicitly. 
        // Otherwise, the task assignee is the Automated Process User.
        // ---
        // CHANGE EMAIL ADDRESS to the email of a valid user in your org.
        // ---
        User myUser = [SELECT Id from User WHERE Email='user@example.com'];
        t.OwnerId = myUser.Id;
        // Insert task
        Database.SaveResult sr = Database.insert(t);
        if (!sr.isSuccess()) {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }
    }
}