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
#import "JFMinimalNotification.h"
#import "GMDCircleLoader.h"

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

-(void)displaySuccessNotificationWithTitle:(NSString*)title subtitle:(NSString*)subtitle {
    JFMinimalNotification *successNote = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleSuccess title:title subTitle:subtitle dismissalDelay:1.5 touchHandler:^{
        [successNote dismiss];
    }];
    
    [self.view addSubview:successNote];
    [successNote show];
}

-(void)displayFailureNotificationWithError:(NSError*)error {
    JFMinimalNotification *errorNote = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleSuccess title:@"Error" subTitle:error.localizedDescription dismissalDelay:1.5 touchHandler:^{
        [errorNote dismiss];
    }];
    
    [self.view addSubview:errorNote];
    [errorNote show];
}

-(IBAction)signUp:(id)sender {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([kYTUseParseCloud isEqual:@YES]) {
        [[YTParseManager sharedManager] registerUsername:self.usernameField.text password:self.passwordField.text successBlock:^{
            //success
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [(YTMainViewController*)self.presentingViewController performSelector:@selector(refreshFriendsList) withObject:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            [(YTAppDelegate*)[[UIApplication sharedApplication] delegate] askForNotifications];
            
        } failureBlock:^(NSError *error) {
            //failure
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"SIGNUP ERROR: %@",error.localizedDescription);
            [self displayFailureNotificationWithError:error];
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
                    [self displayFailureNotificationWithError:error];
                }];
                
            } else {
                //exists
                NSLog(@"ERROR: USERNAME EXISTS");
                NSError *error = [NSError errorWithDomain:@"me.akeaswaran" code:1 userInfo:@{NSLocalizedDescriptionKey: @"User already exists"}];
                [self displayFailureNotificationWithError:error];
            }
        } failureBlock:^(NSError *error) {
            //failure
            NSLog(@"USERNAME CHECK ERROR: %@",error.localizedDescription);
            [self displayFailureNotificationWithError:error];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
}

@end
