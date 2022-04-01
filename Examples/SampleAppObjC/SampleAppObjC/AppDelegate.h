//
//  AppDelegate.h
//  SampleAppObjC
//
//  Created by Pallab Maiti on 11/03/22.
//

#import <UIKit/UIKit.h>

@import RudderFacebookAppEvents;
@import RudderStack;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) RSClient *client;

@end

