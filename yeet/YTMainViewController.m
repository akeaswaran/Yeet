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
#import <QuartzCore/QuartzCore.h>
#import "YTUser.h"
#import "YTParseManager.h"
#import "YTCloudKitManager.h"
#import "Colours.h"
#import "GMDCircleLoader.h"
#import "JFMinimalNotification.h"

@interface YTMainViewController ()
@property NSArray *objects;
@property NSArray *colors;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Load");
    if (![[YTUser sharedInstance] currentUserExists]) {
        NSLog(@"NOT EXISTS");
        [self showSignUp];
    } else {
        NSLog(@"Exists");
    }
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    _colors = [[UIColor dangerColor] colorSchemeOfType:ColorSchemeAnalagous];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 5.0 - 40.0, self.view.frame.size.height - 5.0 - 40.0, 40.0, 40.0)];
    [addButton setBackgroundColor:[UIColor blueColor]];
    [addButton addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    [addButton.layer setCornerRadius:20];
    [addButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [addButton.layer setBorderWidth:3.0];
    
    [self.view addSubview:addButton];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor darkGrayColor]];
    [self.refreshControl addTarget:self action:@selector(refreshFriendsList) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshFriendsList {
    _objects = [NSArray array];

    if (_cloudService == YTCloudServiceCloudKit) {
        [[YTCloudKitManager sharedManager] loadFriendsToCurrentUserWithSuccessBlock:^(NSArray *friends) {
            //success
            _objects = friends;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } failureBlock:^(NSError *error) {
            //failure
            _objects = [NSArray array];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }];
    } else {
        [[YTParseManager sharedManager] loadFriendsForCurrentUserWithCompletionBlock:^(NSArray *friends, NSError *error) {
            if (!error) {
                _objects = friends;
            } else {
                _objects = [NSArray array];
            }
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
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
        [GMDCircleLoader setOnView:self.view withTitle:@"Adding Friend..." animated:YES];
        if (_cloudService == YTCloudServiceCloudKit) {
            [[YTCloudKitManager sharedManager] addFriendWithUsername:usernameField.text successBlock:^(CKRecord *newFriend) {
                [GMDCircleLoader hideFromView:self.view animated:YES];
                NSLog(@"Success");
                [self refreshFriendsList];
            } failureBlock:^(NSError *error) {
                NSLog(@"ERROR: %@",error);
                [GMDCircleLoader hideFromView:self.view animated:YES];
                [self displayFailureNotificationWithError:error];
            }];
        } else {
            [[YTParseManager sharedManager] addFriendWithUsername:usernameField.text successBlock:^(CKRecord *newFriend) {
                NSLog(@"Success");
                [GMDCircleLoader hideFromView:self.view animated:YES];
                [self refreshFriendsList];
            } failureBlock:^(NSError *error) {
                NSLog(@"ERROR: %@",error);
                [GMDCircleLoader hideFromView:self.view animated:YES];
                [self displayFailureNotificationWithError:error];
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
    NSInteger colorIndex = indexPath.row % _colors.count;
    [cell setBackgroundColor:_colors[colorIndex]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:50]];
    
    if (_cloudService == YTCloudServiceCloudKit) {
        CKRecord *friend = [self.objects objectAtIndex:[indexPath row]];
        [cell.textLabel setText:[[friend objectForKey:@"username"] uppercaseString]];
    } else {
        PFObject *friend = _objects[indexPath.row];
        PFUser *friendUser = friend[@"friend"];
        [cell.textLabel setText:[friendUser.username uppercaseString]];
    }
    [cell.textLabel sizeToFit];
    
    return cell;
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *unfriendAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unfriend" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        if (_cloudService == YTCloudServiceCloudKit) {
            CKRecord *friend = [self.objects objectAtIndex:[indexPath row]];
            [[[CKContainer defaultContainer] publicCloudDatabase] deleteRecordWithID:friend.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
                [GMDCircleLoader hideFromView:self.view animated:YES];
                if (error) {
                    //display error
                    [self displayFailureNotificationWithError:error];
                }
                [self refreshFriendsList];
            }];
        } else {
            PFObject *friend = _objects[indexPath.row];
            NSString *friendName = friend[@"friend"][@"username"];
            [friend deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [GMDCircleLoader hideFromView:self.view animated:YES];
                if (succeeded && !error) {
                    //success
                    [self displaySuccessNotificationWithTitle:@"Sucessfully removed friend" subtitle:[NSString stringWithFormat:@"%@ was removed from your friends list.",friendName]];
                } else {
                    //failure
                    [self displayFailureNotificationWithError:error];
                }
            }];
        }
    }];
    
    UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Block" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        if (_cloudService == YTCloudServiceCloudKit) {
            CKRecord *friend = [self.objects objectAtIndex:[indexPath row]];
            [[YTCloudKitManager sharedManager] blockUser:friend successBlock:^(CKRecord *blockedUser){
                //success
                [GMDCircleLoader hideFromView:self.view animated:YES];
            } failureBlock:^(NSError *error) {
                //failure
                [GMDCircleLoader hideFromView:self.view animated:YES];
                [self displayFailureNotificationWithError:error];
            }];
        } else {
            PFObject *friend = _objects[indexPath.row];
            NSString *friendName = friend[@"friend"][@"username"];
            [[YTParseManager sharedManager] blockUser:friend[@"friend"] successBlock:^{
                //success
                [GMDCircleLoader hideFromView:self.view animated:YES];
                [self displaySuccessNotificationWithTitle:@"Sucessfully blocked user" subtitle:[NSString stringWithFormat:@"%@ was blocked from sending you messages.",friendName]];
            } failureBlock:^(NSError *error) {
                //failure
                [GMDCircleLoader hideFromView:self.view animated:YES];
                [self displayFailureNotificationWithError:error];
            }];
        }
    }];
    
    return @[unfriendAction,blockAction];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [GMDCircleLoader setOnView:self.view withTitle:@"Sending YEET..." animated:YES];
    
    if (_cloudService == YTCloudServiceParse) {
        //send YEET w Parse
        PFObject *friend = _objects[indexPath.row];
        PFUser *friendUser = friend[@"friend"];
        [[YTParseManager sharedManager] sendMessageToUser:friendUser successBlock:^{
            //success
            [GMDCircleLoader hideFromView:self.view animated:YES];
            [self displaySuccessNotificationWithTitle:[NSString stringWithFormat:@"YEET sent to %@",friendUser.username] subtitle:nil];
        } failureBlock:^(NSError *error) {
            //failure
            [GMDCircleLoader hideFromView:self.view animated:YES];
            [self displayFailureNotificationWithError:error];
        }];
    } else {
        //send YEET w CloudKit
        CKRecord *friend = _objects[indexPath.row];
        [[YTCloudKitManager sharedManager] sendYoToFriend:friend successBlock:^{
            //success
            [GMDCircleLoader hideFromView:self.view animated:YES];
            [self displaySuccessNotificationWithTitle:@"YEET sent!" subtitle:nil];
        } failureBlock:^(NSError *error) {
            //failure
            [GMDCircleLoader hideFromView:self.view animated:YES];
            [self displayFailureNotificationWithError:error];
        }];
    }
}

@end
