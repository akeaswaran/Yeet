//
//  MasterViewController.m
//  yeet
//
//  Created by Akshay Easwaran on 1/13/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "YTMainViewController.h"
#import <Parse/Parse.h>

@interface YTMainViewController ()
@property NSArray *objects;
@end

@implementation YTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)refreshFriends {
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _objects = objects;
        } else {
            _objects = @[];
        }
        [self.tableView reloadData];
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
    PFObject *object = self.objects[indexPath.row];
    PFUser *user = object[@"user"];
    cell.textLabel.text = [user username];
    return cell;
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *unfriendAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unfriend" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        PFObject *object = _objects[indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded && !error) {
                [self refreshFriends];
            }
        }];
    }];
    
    
    UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Block" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        PFObject *blockObject = [PFObject objectWithClassName:@"Block"];
        PFObject *object = _objects[indexPath.row];
        [blockObject setObject:object[@"user"] forKey:@"blocked"];
        [blockObject setObject:[PFUser currentUser] forKey:@"user"];
        [blockObject saveInBackground];
    }];
    
    return @[unfriendAction,blockAction];
}

@end
