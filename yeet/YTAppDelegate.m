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
@property (strong, nonatomic) YTMainViewController *mainViewController;
@property (strong, nonatomic) UINavigationController *mainNavController;
@end

@implementation YTAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _mainViewController = [[YTMainViewController alloc] init];
    _mainNavController = [[UINavigationController alloc] initWithRootViewController:_mainViewController];
    [self setupAppearance];
    [self.window setRootViewController:_mainNavController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)setupAppearance {
    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

@end
