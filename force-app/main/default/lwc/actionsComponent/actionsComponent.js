import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getURL from '@salesforce/apex/IframeController.getURL';


export default class ActionsComponent extends NavigationMixin(LightningElement) {
    @api invoke(){
        getURL().then(data=>{
            console.log('---! Data '+ data);
            this.openSubTab();
        }).catch(error=>{
            console.log('---  Error : '+JSON.stringify(error));
        });
        this.openSubTab();
    }

    openSubTab() {
        // Define the attributes for the subtab
        const pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'IframePage'
            }
        };

        // Open the subtab using the navigation service
        this[NavigationMixin.Navigate](pageReference);
    }
}