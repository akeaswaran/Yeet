//
//  AppDelegate.m
//  yeet
//
//  Created by Akshay Easwaran on 1/13/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "YTAppDelegate.h"
#import "YTMainViewController.h"

@interface YTAppDelegate ()

@end

@implementation YTAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:[[YTMainViewController alloc] init]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
