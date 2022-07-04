//
//  ViewController.swift
//  ExampleSwift
//
//  Created by Arnab Pal on 09/05/20.
//  Copyright © 2020 RudderStack. All rights reserved.
//

import UIKit
import AdSupport
import AppTrackingTransparency
import FBSDKCoreKit
import Rudder


class ViewController: UIViewController, UIApplicationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        RSClient.sharedInstance().track(RSEvents.Ecommerce.productAdded, properties: properties)
    }
    
    
    @IBAction func track(_ sender: Any) {
        
        RSClient.sharedInstance().identify("random_user", traits: [
            RSKeys.Identify.Traits.email: "test@example.com",
            RSKeys.Identify.Traits.firstName: "firstName",
            RSKeys.Identify.Traits.lastName: "lastName",
            RSKeys.Identify.Traits.phone: "0123456789",
            RSKeys.Identify.Traits.birthday: "01/01/2001",
            RSKeys.Identify.Traits.gender: "M",
            RSKeys.Identify.Traits.Address.city: "City",
            "state": "State",
            "postalcode": "postalCode",
            RSKeys.Identify.Traits.Address.country: "Country"
        ])
        
        
        let properties: [String: Any] = [
            RSKeys.Ecommerce.productId: "a123",
            RSKeys.Ecommerce.rating: 123,
            "name": "adName",

            RSKeys.Ecommerce.value: 120.87,
            RSKeys.Ecommerce.price: 230,
            RSKeys.Ecommerce.revenue: 34,

            RSKeys.Ecommerce.orderId: "12o3of",
            RSKeys.Ecommerce.currency: "INR",
            "description": "description",
            RSKeys.Ecommerce.query: "query",
            "key-1": "value-1",
            "key-2": 123
        ]
        RSClient.sharedInstance().track(RSEvents.Ecommerce.productAdded, properties: properties)
        RSClient.sharedInstance().track(RSEvents.Ecommerce.productAddedToWishList, properties: properties)
//        RSClient.sharedInstance().track(RSEvents.Ecommerce.checkoutStarted, properties: properties)
        
//        RSClient.sharedInstance().track(RSEvents.Ecommerce.productsSearched, properties: [
//            "contentType": "cnka",
//            "abc": "123"
//        ])
    }
}

