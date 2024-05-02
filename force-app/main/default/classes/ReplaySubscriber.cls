public interface ReplaySubscriber {
    void processPayload(List<SObject> platformEvents);
}