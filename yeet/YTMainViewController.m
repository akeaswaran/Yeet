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
#import "YTUser.h"
#import "YTCloudKitManager.h"

@interface YTMainViewController ()
@property NSArray *objects;
@end

@implementation YTMainViewController

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
    [[YTCloudKitManager sharedManager] loadFriendsForCurrentUserWithCompletionBlock:^(NSArray *friends, NSError *error) {
        if (!error) {
            _objects = friends;
        } else {
            _objects = [NSArray array];
        }
        [self.tableView reloadData];
    }];
}

-(void)addFriend {
    NSLog(@"Add Friend");
}

-(void)showSignUp {
    [[YTUser sharedInstance] fetchCurrentUserWithSuccessBlock:^(CKRecord *currentUserRecord) {
        NSLog(@"SUCCESS");
        if (currentUserRecord && [[YTUser sharedInstance] currentUserRecord]) {
            NSLog(@"CURRENT USER FOUND, REFRESHING NOW: %@",currentUserRecord);
            [self refreshFriendsList];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"CURRENT USER ERROR: %@",error.localizedDescription);
        YTSignUpViewController *signUpViewController = [[YTSignUpViewController alloc] init];
        [self presentViewController:signUpViewController animated:YES completion:nil];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor darkTextColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    
    CKRecord *friend = [self.objects objectAtIndex:[indexPath row]];
    [cell.textLabel setText:[friend objectForKey:@"username"]];
    return cell;
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *unfriendAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unfriend" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        CKRecord *friend = [self.objects objectAtIndex:[indexPath row]];
        [[[CKContainer defaultContainer] publicCloudDatabase] deleteRecordWithID:friend.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
            if (error) {
                //display error
            }
            [self.tableView reloadData];
        }];
    }];
    
    
    UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Block" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        CKRecord *friend = [self.objects objectAtIndex:[indexPath row]];
       [[YTCloudKitManager sharedManager] blockUserWithUsername:[friend objectForKey:@"username"] successBlock:^{
           //success
       } failureBlock:^(NSError *error) {
           //failure
       }];
    }];
    
    return @[unfriendAction,blockAction];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //send YEET
}

@end
