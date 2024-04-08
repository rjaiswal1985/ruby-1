public class PlatformEventFailureCallback implements EventBus.EventPublishFailureCallback {
        
    public void onFailure(EventBus.FailureResult result) {
		throw new CustomException('Simulated Exception');
    }
    
    public class CustomException extends Exception{}
}