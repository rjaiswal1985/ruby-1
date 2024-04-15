({
	initialiseComponent : function(component,config) {
        var componentName = 'c:MDMRedirect';//+config.componentName;
        $A.createComponent(
            componentName,
            {
                recordId : component.get('v.recordId'),
                sObjectName : component.get('v.sObjectName'),
                pageReference : component.get('v.pageReference')
            },
            function(comp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(comp);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
	}
})