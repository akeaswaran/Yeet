//
//  YTParseManager.m
//  yeet
//
//  Created by Akshay Easwaran on 1/27/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "YTParseManager.h"
#import "YTConstants.h"
#import <Parse/Parse.h>

@implementation YTParseManager

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static YTParseManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[YTParseManager alloc] init];
    });
    return manager;
}

//registration
- (void)registerUsername:(NSString*)username password:(NSString*)password
            successBlock:(YTSuccessCompletionBlock)successBlock
            failureBlock:(YTFailureCompletionBlock)failureBlock {
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if (succeeded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock();
                });
            } else {
                //failure
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    }];
}

//Friends

-(void)loadFriendsForCurrentUserWithCompletionBlock:(YTFriendsCompletionBlock)completionBlock {
    PFQuery *selfQuery = [PFQuery queryWithClassName:@"Friend"];
    [selfQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [selfQuery includeKey:@"user"];
    
    PFQuery *otherQuery = [PFQuery queryWithClassName:@"Friend"];
    [otherQuery whereKey:@"friend" equalTo:[PFUser currentUser]];
    [otherQuery includeKey:@"friend"];
    
    PFQuery *bigQuery = [PFQuery orQueryWithSubqueries:@[selfQuery,otherQuery]];
    
    PFQuery *blockedQuery = [PFQuery queryWithClassName:@"Block"];
    [blockedQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [blockedQuery includeKey:@"friend"];
    
    [bigQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *results = [NSMutableArray array];
            NSArray *blocked =  [blockedQuery findObjects];
            if (blocked) {
                NSMutableArray *blockedNames = [NSMutableArray array];
                for (PFObject *block in blocked) {
                    PFUser *user = block[@"blocked"];
                    [blockedNames addObject:user.username];
                }
                
                for (PFObject *friend in objects) {
                    PFUser *user = friend[@"friend"];
                    if (![blockedNames containsObject:user.username]) {
                        [results addObject:friend];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(results,nil);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(objects,error);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,error);
            });
        }
    }];
}

- (void)blockUser:(PFUser*)user
                 successBlock:(YTSuccessCompletionBlock)successBlock
                 failureBlock:(YTFailureCompletionBlock)failureBlock {
    PFObject *friend = [PFObject objectWithClassName:@"Block"];
    [friend setObject:[PFUser currentUser] forKey:@"user"];
    [friend setObject:user forKey:@"blocked"];
    [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        } else {
            if (succeeded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock();
                });
            } else {
                //failure
            }
        }
    }];
}

-(void)addFriendWithUsername:(NSString *)username successBlock:(YTSuccessCompletionBlock)successBlock failureBlock:(YTFailureCompletionBlock)failureBlock {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:username];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFUser *user = [objects firstObject];
            [self _addFriend:user successBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock();
                });
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock(error);
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    }];
}

- (void)_addFriend:(PFUser*)user
                 successBlock:(YTSuccessCompletionBlock)successBlock
                 failureBlock:(YTFailureCompletionBlock)failureBlock {
    PFObject *friend = [PFObject objectWithClassName:@"Friend"];
    [friend setObject:[PFUser currentUser] forKey:@"user"];
    [friend setObject:user forKey:@"friend"];
    [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        } else {
            if (succeeded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock();
                });
            } else {
                //failure
            }
        }
    }];
}

-(void)sendMessageToUser:(PFUser*)user successBlock:(YTSuccessCompletionBlock)successBlock failureBlock:(YTFailureCompletionBlock)failureBlock {
    PFPush *push = [PFPush push];
    [push setMessage:[NSString stringWithFormat:@"YEET from %@",[PFUser currentUser].username]];
    [push setChannel:user.username];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        } else {
            if (succeeded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock();
                });
            } else {
                //failure
            }
        }
    }];
}


@end
