//
//  YTCloudKitManager.m
//  yeet
//
//  Created by Akshay Easwaran on 1/24/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "YTCloudKitManager.h"
#import <CloudKit/CloudKit.h>
#import "YTUser.h"

@implementation YTCloudKitManager

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static YTCloudKitManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[YTCloudKitManager alloc] init];
    });
    return manager;
}

- (CKDatabase*)_publicDatabase {
    return [[CKContainer defaultContainer] publicCloudDatabase];
}

- (void)registerUsername:(NSString*)username
            successBlock:(void(^)())successBlock
            failureBlock:(void(^)(NSError* error))failureBlock {
    [[self _publicDatabase] performQuery:[[CKQuery alloc] initWithRecordType:@"usernames" predicate:[NSPredicate predicateWithFormat:@"username = %@", username]] inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error || results.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(nil);
            });
        } else {
            // Create username
            CKRecord *record = [[CKRecord alloc] initWithRecordType:@"usernames"];
            [record setObject:username forKey:@"username"];
            [[self _publicDatabase] saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
              if (error) {
                  failureBlock(error);
              } else {
                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userExists"];
                  [[NSUserDefaults standardUserDefaults] synchronize];
                  
                  [[YTUser sharedInstance] setCurrentUserRecord:record];
                  [self _setupPushNotificationsForUsername:username];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      successBlock();
                  });
              }
            }];
        }
    }];
}

- (void)blockUserWithUsername:(NSString*)username
            successBlock:(void(^)())successBlock
            failureBlock:(void(^)(NSError* error))failureBlock {
            // Create username
    [self checkIfUsernameIsRegistered:username successBlock:^(BOOL usernameExists) {
        if (usernameExists) {
            CKRecord *record = [[CKRecord alloc] initWithRecordType:@"block"];
            [record setObject:username forKey:@"blocked"];
            
            CKReference *newFriendReference = [[CKReference alloc] initWithRecord:[[YTUser sharedInstance] currentUserRecord] action:CKReferenceActionDeleteSelf];
            record[@"user"] = newFriendReference;
            
            [[self _publicDatabase] saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock(error);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successBlock();
                    });
                }
            }];
        } else {
            NSError *error = [NSError errorWithDomain:@"me.akeaswaran"
                                                 code:1
                                             userInfo:@{NSLocalizedDescriptionKey: @"User doesn't exist"
                                                        }];
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    } failureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock(error);
        });
    }];
}

- (void)addFriendWithUsername:(NSString*)username
                 successBlock:(void(^)(CKRecord *newFriend))successBlock
                 failureBlock:(void(^)(NSError *error))failureBlock {
    [self checkIfUsernameIsRegistered:username successBlock:^(BOOL usernameExists) {
         if (usernameExists) {
             CKRecord *newFriend = [[CKRecord alloc] initWithRecordType:@"friend"];
             [newFriend setObject:username
                           forKey:@"username"];
             CKRecord *record = [[YTUser sharedInstance] currentUserRecord];
             CKReference *newFriendReference = [[CKReference alloc] initWithRecord:record
                                                                            action:CKReferenceActionDeleteSelf];
             newFriend[@"friend"] = newFriendReference;
             
             [[[CKContainer defaultContainer] publicCloudDatabase] saveRecord:newFriend completionHandler:^(CKRecord *record, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock(error);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successBlock(newFriend);
                    });
                }
            }];
         } else {
             NSError *error = [NSError errorWithDomain:@"me.akeaswaran"
                                                  code:1
                                              userInfo:@{NSLocalizedDescriptionKey: @"User doesn't exist"
                                                         }];
             dispatch_async(dispatch_get_main_queue(), ^{
                 failureBlock(error);
             });
         }
    } failureBlock:^(NSError *error) {
         failureBlock(error);
    }];
}

-(void)loadFriendsForCurrentUserWithCompletionBlock:(YTFriendsCompletionBlock)completionBlock {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friend = %@",[[[YTUser sharedInstance] currentUserRecord] recordID]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"friend" predicate:predicate];
    [[self _publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(results,error);
        });
    }];
}

- (void)checkIfUsernameIsRegisteredWithRecordId:(CKRecordID*)recordId
                                   successBlock:(void(^)())successBlock
                                   failureBlock:(void(^)(NSError* error))failureBlock {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creatorUserRecordID = %@", recordId];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"usernames"
                                               predicate:predicate];
    [[self _publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error || results.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        } else {
            [self _setupPushNotificationsForUsername:[results.firstObject objectForKey:@"username"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock();
            });
        }
    }];
}

- (void)checkIfUsernameIsRegistered:(NSString*)username
                       successBlock:(void(^)(BOOL usernameExists))successBlock
                       failureBlock:(void(^)(NSError *error))failureBlock {
    CKQuery *query = [[CKQuery alloc]
                      initWithRecordType:@"usernames"
                      predicate:[NSPredicate
                                 predicateWithFormat:@"username = %@", username]];
    [[self _publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL usernameExists = (results.count > 0) ? YES : NO;
                successBlock(usernameExists);
            });
        }
    }];
}

- (void)_setupPushNotificationsForUsername:(NSString*)username {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"to = %@", username];
    CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"YEET" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation];
    CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
    [notificationInfo setDesiredKeys:@[@"to",@"from"]];
    [notificationInfo setAlertLocalizationArgs:@[@"from"]];
    [notificationInfo setAlertBody:@"YEET from %@"];
    [notificationInfo setShouldBadge:YES];
    
    [subscription setNotificationInfo:notificationInfo];
    
    [[[CKContainer defaultContainer] publicCloudDatabase] saveSubscription:subscription completionHandler:^(CKSubscription *subscription, NSError *error) {
        if (!error) {
            //success
        } else {
            //failure
        }
    }];
}

@end
