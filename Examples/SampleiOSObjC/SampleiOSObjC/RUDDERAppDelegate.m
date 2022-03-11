//
//  RUDDERAppDelegate.m
//  Rudder-Facebook
//
//  Created by arnab on 11/15/2019.
//  Copyright (c) 2019 arnab. All rights reserved.
//

#import "RUDDERAppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@import RudderStack;
@import RudderFacebookAppEvents;

@implementation RUDDERAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [[FBSDKSettings sharedSettings] setAdvertiserTrackingEnabled:YES];
    [[FBSDKSettings sharedSettings] setAutoLogAppEventsEnabled:YES];

    RSConfig *config = [[RSConfig alloc] initWithWriteKey:@"1wvsoF3Kx2SczQNlx1dvcqW9ODW"];
    [config dataPlaneURL:@"https://rudderstacz.dataplane.rudderstack.com"];
    [config loglevel:RSLogLevelDebug];
    [config trackLifecycleEvents:YES];
    [config recordScreenViews:YES];
    
    RSClient *client = [[RSClient alloc] initWithConfig:config];
    
//    RSOption *option = [[RSOption alloc] init];
//    [option putIntegration:@"Firebase" isEnabled:NO];
//    [client setOption:option];
    
    //[client addWithPlugin:[[RSFirebaseDestination alloc] init]];
    [client addWithDestination:[[RudderFacebookAppEventsDestination alloc] init]];
    [client track:@"Track 1" properties:NULL option:NULL];

//
//    [FBSDKAppEvents logEvent:@"test_events"];
    
    /*RSConfig *configBuilder = [[RSConfig alloc] init];
    [configBuilder withDataPlaneUrl:dataPlaneUrl];
    [configBuilder withLoglevel:RSLogLevelDebug];
//    [configBuilder withControlPlaneUrl:@"https://chilly-seahorse-73.loca.lt"];
    [configBuilder withFactory:[RudderFacebookFactory instance]];
    RSClient *rudderClient = [RSClient getInstance:writeKey config:configBuilder];
    
    [rudderClient track:@"level_up"];
    [rudderClient track:@"daily_rewards_claim" properties:@{
        @"revenue":@"346",
        @"name":@"tyres"
    }];
    [rudderClient track:@"revenue"];
    
    [rudderClient screen:@"Main Screen"];
    [[RSClient sharedInstance] identify:@"test_user_id"
                                 traits:@{@"foo": @"bar",
                                          @"foo1": @"bar1",
                                          @"email": @"test@gmail.com",
                                          @"key_1" : @"value_1",
                                          @"key_2" : @"value_2"
                                 }
     ];
    [[RSClient sharedInstance] group:@"sample_group_id"
                                  traits:@{@"foo": @"bar",
                                           @"foo1": @"bar1",
                                           @"email": @"ruchira@gmail.com"}
    ];*/
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
