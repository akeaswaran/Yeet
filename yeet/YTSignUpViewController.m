//
//  YTSignUpViewController.m
//  yeet
//
//  Created by Akshay Easwaran on 1/13/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "YTSignUpViewController.h"
#import "YTCloudKitManager.h"
#import "YTMainViewController.h"
#import "YTParseManager.h"
#import "YTConstants.h"
#import "YTAppDelegate.h"

@interface YTSignUpViewController ()
@end

@implementation YTSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_usernameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)signUp:(id)sender {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([kYTUseParseCloud isEqual:@YES]) {
        [[YTParseManager sharedManager] registerUsername:self.usernameField.text password:self.passwordField.text successBlock:^{
            //success
            [(YTMainViewController*)self.presentingViewController performSelector:@selector(refreshFriendsList) withObject:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            [(YTAppDelegate*)[[UIApplication sharedApplication] delegate] askForNotifications];
            
        } failureBlock:^(NSError *error) {
            //failure
            NSLog(@"SIGNUP ERROR: %@",error.localizedDescription);
        }];
    } else {
        [[YTCloudKitManager sharedManager] checkIfUsernameIsRegistered:self.usernameField.text successBlock:^(BOOL usernameExists) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            //success
            if (!usernameExists) {
                // doesnt exist
                [[YTCloudKitManager sharedManager] registerUsername:self.usernameField.text successBlock:^{
                    //success
                    [(YTMainViewController*)self.presentingViewController performSelector:@selector(refreshFriendsList) withObject:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [(YTAppDelegate*)[[UIApplication sharedApplication] delegate] askForNotifications];
                } failureBlock:^(NSError *error) {
                    //failure
                    NSLog(@"SIGNUP ERROR: %@",error.localizedDescription);
                }];
                
            } else {
                //exists
                NSLog(@"ERROR: USERNAME EXISTS");
            }
        } failureBlock:^(NSError *error) {
            //failure
            NSLog(@"USERNAME CHECK ERROR: %@",error.localizedDescription);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
}

@end
