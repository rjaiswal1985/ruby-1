({
    onPageReferenceChange: function(component, evt, helper) {
        let myPageRef = component.get("v.pageReference");
        let recordId = myPageRef.state.force__recordId;
        component.set("v.isAccount",recordId.startsWith("001"));
        component.set("v.recordId", myPageRef.state.force__recordId);
    }
})