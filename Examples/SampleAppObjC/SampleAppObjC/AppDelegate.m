//
//  AppDelegate.m
//  SampleAppObjC
//
//  Created by Pallab Maiti on 11/03/22.
//

#import "AppDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@import Rudder;
@import FBSDKCoreKit;
@import RudderFacebookAppEvents;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    FBSDKSettings.sharedSettings.isAutoLogAppEventsEnabled = YES; 
    
    
    RSConfig *config = [[RSConfig alloc] initWithWriteKey:@"<WRITE_KEY>"];
    [config dataPlaneURL:@"<DATA_PLANE_URL>"];
    [config loglevel:RSLogLevelVerbose];
    [config trackLifecycleEvents:YES];
    [config recordScreenViews:YES];
    
    [[RSClient sharedInstance] configureWith:config];
    [[RSClient sharedInstance] addDestination:[[RudderFacebookAppEventsDestination alloc] init]];
    
    [[RSClient sharedInstance] track:@"Track 1"];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Check if the iOS version is 14 or later
    if (@available(iOS 14, *)) {
        // Request tracking authorization if the iOS version is 14 or later
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status) {
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    NSLog(@"Authorized");
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                    NSLog(@"Denied");
                    break;
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    NSLog(@"Not Determined");
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    NSLog(@"Restricted");
                    break;
                default:
                    NSLog(@"Unknown");
                    break;
            }
        }];
    } else {
        // Handle cases for iOS versions below 14
        if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
            // Advertising tracking is enabled
            
            FBSDKSettings.sharedSettings.isAdvertiserIDCollectionEnabled = YES;
            NSLog(@"Advertising tracking is enabled");
        } else {
            // Advertising tracking is disabled
            NSLog(@"Advertising tracking is disabled");
        }
        // Additional handling for pre-iOS 14 can go here
    }
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
