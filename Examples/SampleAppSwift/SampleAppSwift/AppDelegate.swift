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
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationDidBecomeActive(_:)),
                name: UIApplication.didBecomeActiveNotification,
                object: nil)
        
//        requestPermission()
        ApplicationDelegate.shared.application(
           application,
           didFinishLaunchingWithOptions: launchOptions
       )
        
        let config: RSConfig = RSConfig(writeKey: "1wvsoF3Kx2SczQNlx1dvcqW9ODW")
            .dataPlaneURL("https://rudderstacz.dataplane.rudderstack.com")
            .loglevel(.none)
            .trackLifecycleEvents(false)
            .recordScreenViews(false)
        
        RSClient.sharedInstance().configure(with: config)
        RSClient.sharedInstance().addDestination(RudderFacebookAppEventsDestination())
        
//        FBSDKLoggingBehaviorAppEvents
//        Settings.shared.loggingBehaviors([.appEvents,])
//        Settings.shared.enableLoggingBehavior(.appEvents)
        
//        Settings.shared.enableLoggingBehavior(.appEvents)
//        Settings.shared.enableLoggingBehavior(.appEvents)
//        Settings.shared.enableLoggingBehavior(.networkRequests)
//        Settings.shared.enableLoggingBehavior(.developerErrors)
//        Settings.shared.enableLoggingBehavior(.graphAPIDebugInfo)
//        Settings.shared.enableLoggingBehavior(.accessTokens)
        Settings.shared.isAutoLogAppEventsEnabled = true
        Settings.shared.isAdvertiserIDCollectionEnabled = true
        
//        Settings.shared.loggingBehaviors = Set<AnyHashable>([FBSDKLoggingBehaviorAppEvents, FBSDKLoggingBehaviorGraphAPIDebugInfo, FBSDKLoggingBehaviorCacheErrors, FBSDKLoggingBehaviorAccessTokens, FBSDKLoggingBehaviorDeveloperErrors, FBSDKLoggingBehaviorNetworkRequests, FBSDKLoggingBehaviorGraphAPIDebugWarning, FBSDKLoggingBehaviorInformational, FBSDKLoggingBehaviorUIControlErrors, FBSDKLoggingBehaviorPerformanceCharacteristics])
        
        
        Settings.shared.loggingBehaviors = ([LoggingBehavior.appEvents, .developerErrors])
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    Settings.shared.isAdvertiserTrackingEnabled = true
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    // Now that we are authorized we can get the IDFA
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
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
