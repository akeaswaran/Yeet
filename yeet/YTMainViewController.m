//
//  MasterViewController.m
//  yeet
//
//  Created by Akshay Easwaran on 1/13/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "YTMainViewController.h"
#import "YTSignUpViewController.h"
#import <CloudKit/CloudKit.h>
#import <Parse/Parse.h>
#import "YTUser.h"
#import "YTParseManager.h"
#import "YTCloudKitManager.h"

@interface YTMainViewController ()
@property NSArray *objects;
@property YTCloudService cloudService;
@end

@implementation YTMainViewController

-(instancetype)initWithCloudService:(YTCloudService)service {
    self = [super init];
    if (self) {
        _cloudService = service;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Load");
    if (![[YTUser sharedInstance] currentUserExists]) {
        NSLog(@"NOT EXISTS");
        [self showSignUp];
    } else {
        NSLog(@"Exists");
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriend)];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    [self.tableView setBackgroundColor:[UIColor darkTextColor]];
}

-(void)refreshFriendsList {
    _objects = [NSArray array];
    if (_cloudService == YTCloudServiceCloudKit) {
        [[YTCloudKitManager sharedManager] loadFriendsToCurrentUserWithSuccessBlock:^(NSArray *friends) {
            //success
            _objects = friends;
            [self.tableView reloadData];
        } failureBlock:^(NSError *error) {
            //failure
            _objects = [NSArray array];
            [self.tableView reloadData];
        }];
    } else {
        [[YTParseManager sharedManager] loadFriendsForCurrentUserWithCompletionBlock:^(NSArray *friends, NSError *error) {
            if (!error) {
                _objects = friends;
            } else {
                _objects = [NSArray array];
            }
            [self.tableView reloadData];
        }];
    }
}

-(void)addFriend {
    NSLog(@"Add Friend");
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Add Friend"
                                          message:@"Enter the username of the user you would like to ass as a friend."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        textField.placeholder = @"username";
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *usernameField = alertController.textFields.firstObject;
        if (_cloudService == YTCloudServiceCloudKit) {
            [[YTCloudKitManager sharedManager] addFriendWithUsername:usernameField.text successBlock:^(CKRecord *newFriend) {
                NSLog(@"Success");
                [self refreshFriendsList];
            } failureBlock:^(NSError *error) {
                NSLog(@"ERROR: %@",error);
            }];
        } else {
            [[YTParseManager sharedManager] addFriendWithUsername:usernameField.text successBlock:^(CKRecord *newFriend) {
                NSLog(@"Success");
                [self refreshFriendsList];
            } failureBlock:^(NSError *error) {
                NSLog(@"ERROR: %@",error);
            }];
        }
    }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)showSignUp {
    if (_cloudService == YTCloudServiceCloudKit) {
        [[YTUser sharedInstance] fetchCurrentUserWithSuccessBlock:^(CKRecord *currentUserRecord) {
            NSLog(@"SUCCESS");
            if (currentUserRecord && [[YTUser sharedInstance] currentUserRecord]) {
                NSLog(@"CURRENT USER FOUND, REFRESHING NOW: %@",currentUserRecord);
                [self refreshFriendsList];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"CURRENT USER ERROR: %@",error.localizedDescription);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                YTSignUpViewController *signUpViewController = [[YTSignUpViewController alloc] init];
                [self presentViewController:signUpViewController animated:YES completion:nil];
            });
        }];
    } else {
        if (![PFUser currentUser]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                YTSignUpViewController *signUpViewController = [[YTSignUpViewController alloc] init];
                [self presentViewController:signUpViewController animated:YES completion:nil];
            });
        } else {
            [self refreshFriendsList];
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor darkTextColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:50]];
    
    if (_cloudService == YTCloudServiceCloudKit) {
        CKRecord *friend = [self.objects objectAtIndex:[indexPath row]];
        [cell.textLabel setText:[friend objectForKey:@"username"]];
    } else {
        PFObject *friend = _objects[indexPath.row];
        PFUser *friendUser = friend[@"friend"];
        [cell.textLabel setText:friendUser.username];
    }
    [cell.textLabel sizeToFit];
    
    return cell;
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *unfriendAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unfriend" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        if (_cloudService == YTCloudServiceCloudKit) {
            CKRecord *friend = [self.objects objectAtIndex:[indexPath row]];
            [[[CKContainer defaultContainer] publicCloudDatabase] deleteRecordWithID:friend.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
                if (error) {
                    //display error
                }
                [self.tableView reloadData];
            }];
        } else {
            PFObject *friend = _objects[indexPath.row];
            [friend deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded && !error) {
                    //success
                } else {
                    //failure
                }
            }];
        }
    }];
    
    UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Block" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        if (_cloudService == YTCloudServiceCloudKit) {
            CKRecord *friend = [self.objects objectAtIndex:[indexPath row]];
            [[YTCloudKitManager sharedManager] blockUser:friend successBlock:^(CKRecord *blockedUser){
                //success
            } failureBlock:^(NSError *error) {
                //failure
            }];
        } else {
            PFObject *friend = _objects[indexPath.row];
            [[YTParseManager sharedManager] blockUser:friend[@"friend"] successBlock:^{
                //success
            } failureBlock:^(NSError *error) {
                //failure
            }];
        }
    }];
    
    return @[unfriendAction,blockAction];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (_cloudService == YTCloudServiceParse) {
        //send YEET w Parse
        PFObject *friend = _objects[indexPath.row];
        PFUser *friendUser = friend[@"friend"];
        [[YTParseManager sharedManager] sendMessageToUser:friendUser successBlock:^{
            //success
        } failureBlock:^(NSError *error) {
            //failure
        }];
    } else {
        //send YEET w CloudKit
        CKRecord *friend = _objects[indexPath.row];
        [[YTCloudKitManager sharedManager] sendYoToFriend:friend successBlock:^{
            //success
        } failureBlock:^(NSError *error) {
            //failure
        }];
    }
}

@end
