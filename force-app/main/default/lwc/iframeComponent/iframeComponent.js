import { LightningElement,api } from 'lwc';

export default class IframeComponent extends LightningElement {
  @api height = '500px';
  @api sandbox = '';
  @api url = 'https://developer.salesforce.com/docs/component-library/bundle/lightning:container';
  @api width = '100%';
  
  renderedCallback() {
    if (this.sandbox) {
      const element = this.template.querySelector('iframe');
      element.sandbox = this.sandbox;
    }
  }
}