({
	doInit : function(component, event, helper) {
        alert('---! Helloooo');
		var pageRef = component.get('v.pageReference');
        var actionName = pageRef.attributes.actionName;
        var sObjectName = pageRef.attributes.objectApiName;
        console.log('---! '+sObjectName);
        console.log('---! '+actionName);
        var action = component.get('c.getActionOverride');
        action.setParams({ 
            sObjectName : pageRef.attributes.objectApiName,
            action : pageRef.attributes.actionName
        });
        action.setCallback(this,function(response){
             var state = response.getState();
            console.log('--! Response' + state);
            console.log('--! Response' + JSON.stringify(response.getReturnValue()));
            var config = response.getReturnValue();
            helper.initialiseComponent(component,config);
            
        });
        $A.enqueueAction(action);
        
	}
})