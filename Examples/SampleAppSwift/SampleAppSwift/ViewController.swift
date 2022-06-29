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
    }
    
    
    @IBAction func track(_ sender: Any) {
        RSClient.sharedInstance().track(RSEvents.Ecommerce.productsSearched, properties: [
            "contentType": "cnka",
            "abc": "123"
        ])
    }
}

