public with sharing class PlatformEventController {
    @AuraEnabled(cacheable=true)
    public static List<String> getPlatformEventNames() {
        List<String> eventNames = new List<String>();
        
        // Query all objects and filter out the platform event objects
        for (Schema.SObjectType eventType : Schema.getGlobalDescribe().Values()) {
            String eventName = eventType.getDescribe().getName();
            String namespacePrefix = eventType.getDescribe().getKeyPrefix();
            if (eventName.endsWith('__e') && !eventName.contains('__c') && (namespacePrefix == null || !eventName.startsWith(namespacePrefix + '__'))) {
                eventNames.add(eventName);
            }
        }
        System.debug('Names PE == '+eventNames);
        return eventNames;
    }
}