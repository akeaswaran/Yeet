//
//  YTAddFriendViewController.m
//  yeet
//
//  Created by Akshay Easwaran on 1/16/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "YTAddFriendViewController.h"
#import <Parse/Parse.h>

@interface YTAddFriendViewController ()
{
    IBOutlet UIView *hudView;
    IBOutlet UIActivityIndicatorView *indicatorView;
    IBOutlet UITextField *usernameField;
}
@end

@implementation YTAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [indicatorView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)add:(id)sender {
    [hudView setHidden:NO];
    [indicatorView setHidden:NO];
    [indicatorView startAnimating];
    
    PFObject *friend = [PFObject objectWithClassName:@"Friends"];
    [friend setObject:[PFUser currentUser] forKey:@"user"];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:usernameField.text];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [hudView setHidden:YES];
        [indicatorView setHidden:YES];
        [indicatorView stopAnimating];
        if (!error) {
            if (!objects) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Username not found" message:@"This username can not be found in our database. Please try again." preferredStyle:UIAlertControllerStyleAlert];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alertController animated:YES completion:nil];
                });
            } else {
                [friend setObject:[objects firstObject] forKey:@"friend"];
                [friend saveInBackground];
            }
        }
    }];
}

@end
