//
//  AppDelegate.swift
//  ExampleSwift
//
//  Created by Arnab Pal on 09/05/20.
//  Copyright © 2020 RudderStack. All rights reserved.
//

import UIKit
import Rudder
import RudderFacebookAppEvents
import FBSDKCoreKit

import AdSupport
import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var client: RSClient?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Request user for Tracking Authorization
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationDidBecomeActive(_:)),
                name: UIApplication.didBecomeActiveNotification,
                object: nil)
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        Settings.shared.isAutoLogAppEventsEnabled = true; // updated
        
        let config: RSConfig = RSConfig(writeKey: "<WRITE_KEY>")
            .dataPlaneURL("<DATA_PLANE_URL>")
            .loglevel(.none)
            .trackLifecycleEvents(false)
            .recordScreenViews(false)
        
        RSClient.sharedInstance().configure(with: config)
        RSClient.sharedInstance().addDestination(RudderFacebookAppEventsDestination())
        
        // Enable FB log manually
//        Settings.shared.enableLoggingBehavior(.appEvents)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    /// `Get Device Consent`: Starting with iOS 14.5, you will need to set `isAdvertiserTrackingEnabled` and log each time you give a device permission to share data with Facebook. Refer Facebook App Event doc here: https://developers.facebook.com/docs/app-events/getting-started-app-events-ios
                    
                
                    print("Authorized")
                case .denied:
                    print("Denied")
                case .notDetermined:
                    print("Not Determined")
                    
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        }
        else{
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                // Advertising tracking is enabled
                Settings.shared.isAdvertiserIDCollectionEnabled = true
                print("Advertising tracking is enabled")
            } else {
               
                print("Advertising tracking is disabled")
            }
        }
       
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension UIApplicationDelegate {
    var client: RSClient? {
        if let appDelegate = self as? AppDelegate {
            return appDelegate.client
        }
        return nil
    }
}
