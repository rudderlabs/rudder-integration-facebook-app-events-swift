//
//  ViewController.m
//  SampleAppObjC
//
//  Created by Pallab Maiti on 11/03/22.
//

#import "ViewController.h"
#import "AppDelegate.h"

@import Rudder;
@import FBSDKCoreKit;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onTap:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [[RSClient sharedInstance] track:@"Track 2"];
        });
    });
}

@end
