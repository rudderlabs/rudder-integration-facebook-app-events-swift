//
//  AppDelegate.m
//  SampleAppObjC
//
//  Created by Pallab Maiti on 11/03/22.
//

#import "AppDelegate.h"

@import RudderStack;
@import FBSDKCoreKit;
@import RudderFacebookAppEvents;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[FBSDKSettings sharedSettings] setAdvertiserTrackingEnabled:YES];
    [[FBSDKSettings sharedSettings] setAdvertiserIDCollectionEnabled:YES];
    [[FBSDKSettings sharedSettings] setAutoLogAppEventsEnabled:YES];
    
//    [[FBSDKAppEvents shared] logEvent:@"Track 1"];
    
    RSConfig *config = [[RSConfig alloc] initWithWriteKey:@"1wvsoF3Kx2SczQNlx1dvcqW9ODW"];
    [config dataPlaneURL:@"https://rudderstacz.dataplane.rudderstack.com"];
    [config loglevel:RSLogLevelVerbose];
    [config trackLifecycleEvents:YES];
    [config recordScreenViews:YES];
    
    self.client = [[RSClient alloc] initWithConfig:config];
    
    [self.client addDestination:[[RudderFacebookAppEventsDestination alloc] init]];
    [self.client track:@"Track 1"];
    return YES;
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
