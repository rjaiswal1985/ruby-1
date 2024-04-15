public class UCB_ActionOverrideController {
	@AuraEnabled
    public static Map<String,String> getActionOverride(String sObjectName,String action) {
        System.debug('---! Object : '+sObjectName);
        System.debug('---! Action : '+action);
        return new Map<String,String>{'componentName'=>'MyUtilComponent','componentType'=>'aura'};
    }
}