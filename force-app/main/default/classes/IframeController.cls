public with sharing class IframeController {
    public IframeController() {

    }
    @AuraEnabled
    public static string getURL(){
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:POC_AzureAD/dashboard/organization');
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'https://customerprofile.qas.invisalign.com/dashboard/organization';
    }
}