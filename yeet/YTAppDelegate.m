//
//  AppDelegate.m
//  yeet
//
//  Created by Akshay Easwaran on 1/13/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "YTAppDelegate.h"
#import "YTMainViewController.h"
#import "YTConstants.h"
#import <Parse/Parse.h>

@interface YTAppDelegate ()
@property (strong, nonatomic) YTMainViewController *mainViewController;
@property (strong, nonatomic) UINavigationController *mainNavController;
@end

@implementation YTAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if ([kYTUseParseCloud isEqual:@YES]) {
        [Parse setApplicationId:kYTParseAppID clientKey:kYTParseClientKey];
        _mainViewController = [[YTMainViewController alloc] initWithCloudService:YTCloudServiceParse];
    } else {
        _mainViewController = [[YTMainViewController alloc] initWithCloudService:YTCloudServiceCloudKit];
    }
    
    _mainNavController = [[UINavigationController alloc] initWithRootViewController:_mainViewController];
    [_mainNavController setNavigationBarHidden:YES];
    [self setupAppearance];
    [self.window setRootViewController:_mainNavController];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)setupAppearance {
    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

-(void)askForNotifications {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if ([kYTUseParseCloud isEqual:@YES]) {
        [[PFInstallation currentInstallation] setDeviceTokenFromData:deviceToken];
        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
        [[PFInstallation currentInstallation] setChannels:@[[PFUser currentUser].username]];
        [[PFInstallation currentInstallation] saveInBackground];
    }
}

@end
