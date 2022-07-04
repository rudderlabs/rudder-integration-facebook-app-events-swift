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
    let properties: [String: Any] = [
        RSKeys.Ecommerce.productId: "a123",
        RSKeys.Ecommerce.rating: 123,
        "name": "adName",   // RSKeys.Ecommerce.promotionName
        RSKeys.Ecommerce.currency: "INR",
        RSKeys.Ecommerce.orderId: "12o3of",
        "description": "description",   // RSKeys.Other.description
        RSKeys.Ecommerce.query: "query",
        
        RSKeys.Ecommerce.value: 120.87,
        RSKeys.Ecommerce.price: 230,
        RSKeys.Ecommerce.revenue: 34,
        
        "key-1": "value-1",
        "key-2": 123
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Identify(_ sender: Any) {
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
    }
    
    @IBAction func standardTraack(_ sender: Any) {
        let eventList: [String] = [
            RSEvents.Ecommerce.productAdded, RSEvents.Ecommerce.productAddedToWishList, RSEvents.Ecommerce.productViewed,
            RSEvents.Ecommerce.checkoutStarted, RSEvents.Ecommerce.spendCredits,
            RSEvents.Ecommerce.orderCompleted,
            RSEvents.Ecommerce.productsSearched, RSEvents.Ecommerce.paymentInfoEntered, RSEvents.LifeCycle.completeRegistration, RSEvents.LifeCycle.achieveLevel, RSEvents.LifeCycle.completeTutorial, RSEvents.LifeCycle.unlockAchievement,
//            RSEvents.LifeCycle.subscribe, RSEvents.LifeCycle.startTrial,
            RSEvents.Ecommerce.promotionClicked, RSEvents.Ecommerce.promotionViewed, RSEvents.Ecommerce.productReviewed
        ]
        
        for event in eventList {
            RSClient.sharedInstance().track(event, properties: properties)
        }
    }
    
    @IBAction func customTrack(_ sender: Any) {
        RSClient.sharedInstance().track("Empty track events")
        RSClient.sharedInstance().track("Track events with properties", properties: [
            "key-1": "value-1",
            "key-2": 45,
            "key-3": 34.56,
            "key-4": true
        ])
    }
    
    @IBAction func screen(_ sender: Any) {
        RSClient.sharedInstance().track("Screen with props", properties: [
            "key-1": "value-1",
            "key-2": 45,
            "key-3": 34.56,
            "key-4": true
        ])
    }
    
}

