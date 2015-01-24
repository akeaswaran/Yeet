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
}

-(void)refreshFriendsList {
    _objects = [NSArray array];
    [self.tableView reloadData];
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
    return cell;
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *unfriendAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unfriend" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
    }];
    
    
    UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Block" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
       
    }];
    
    return @[unfriendAction,blockAction];
}

@end
