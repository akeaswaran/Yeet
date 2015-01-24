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
    [[YTCloudKitManager sharedManager] checkIfUsernameIsRegistered:self.usernameField.text successBlock:^(BOOL usernameExists) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //success
        if (!usernameExists) {
            // doesnt exist
            [[YTCloudKitManager sharedManager] registerUsername:self.usernameField.text successBlock:^{
                //success
                [(YTMainViewController*)self.presentingViewController performSelector:@selector(refreshFriendsList) withObject:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            } failureBlock:^(NSError *error) {
                //failure
                //self.failureNotification.subTitleLabel.text = error.localizedDescription;
                //[self.failureNotification show];
                NSLog(@"SIGNUP ERROR: %@",error.localizedDescription);
            }];
        } else {
            //exists
            //[self.failureNotification show];
            NSLog(@"ERROR: USERNAME EXISTS");
        }
    } failureBlock:^(NSError *error) {
        //failure
        //self.failureNotification.subTitleLabel.text = error.localizedDescription;
       // [self.failureNotification show];
        NSLog(@"USERNAME CHECK ERROR: %@",error.localizedDescription);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

@end
