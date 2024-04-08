({
    onPageReferenceChange: function(component, evt, helper) {
        let myPageRef = component.get("v.pageReference");
        component.set("v.recordId", myPageRef.state.force__recordId);
    }
})