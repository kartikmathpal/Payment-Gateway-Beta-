//
//  ViewController.swift
//  Payment Gateway
//
//  Created by Kartik Mathpal on 08/04/16.
//  Copyright © 2016 Mathpal Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PayPalPaymentDelegate{ //Step4.

    //Steps to follow for PayPal integration
    //1.Add PayPal config. in AppDelegate
    //2.Create PayPal object
    //3.Declare Payment Configurations
    //4.Implement PayPal payment delegate
    //5.Add payment items & related details
    
    var payPalConfig = PayPalConfiguration() //Step2.
    
    //Step3.
    var environment : String = PayPalEnvironmentNoNetwork{
        willSet(newEnvironment){
            if(newEnvironment != environment){
                PayPalMobile.preconnectWithEnvironment(newEnvironment)
            }
        }
    }
    var acceptCreditCards : Bool = true {
        didSet{
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       //Step3.
       payPalConfig.acceptCreditCards = acceptCreditCards
       payPalConfig.merchantName = "MathpalInc."
       payPalConfig.merchantPrivacyPolicyURL = NSURL(string:"https://twitter.com/kmathpal")
       payPalConfig.merchantUserAgreementURL = NSURL(string:"")
       payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0] 
       payPalConfig.payPalShippingAddressOption = .PayPal
        
       PayPalMobile.preconnectWithEnvironment(environment)
        
    }
    
    //Step4.
    //PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        print("Payment Cancelled")
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        print("Payment Successfully completed")
        paymentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            //send confirmation to your server
            print("Here is the proof of your payment :\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
        
        })
        
    }
    
    

    @IBAction func payBtnPressed(sender: AnyObject) {
        
        //Step5.
        //Process payment once pay button is clicked
        
        var item1 = PayPalItem(name: "---", withQuantity: 1, withPrice: NSDecimalNumber(string: "9.99"), withCurrency: "USD", withSku: "---")
        
        let items = [item1]
        
        let subtotal = PayPalItem.totalPriceForItems(items)
        
        //Optional : include payment details
        let  shipping = NSDecimalNumber(string : "0.0")
        let tax = NSDecimalNumber(string: "0.0")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "-----", intent: .Sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if(payment.processable){
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            presentViewController(paymentViewController, animated : true , completion : nil)
        }
        
    }
     


}

