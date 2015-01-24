//
//  YTUser.m
//  yeet
//
//  Created by Akshay Easwaran on 1/24/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "YTUser.h"
#import <CloudKit/CloudKit.h>

@implementation YTUser

+ (instancetype)sharedInstance {
    static YTUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [YTUser new];
    });
    return sharedInstance;
}

- (void)fetchCurrentUserWithSuccessBlock:(void(^)(CKRecord *currentUserRecord))successBlock
                     failureBlock:(void(^)(NSError *error))failureBlock {
    __weak typeof(self) weakSelf = self;
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        } else {
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"usernames"
                                                       predicate:[NSPredicate predicateWithFormat:@"creatorUserRecordID = %@", recordID]];
            [[[CKContainer defaultContainer] publicCloudDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock(error);
                    });
                } else if ([results count] > 0) {
                    [strongSelf setCurrentUserRecord:[results firstObject]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successBlock([self currentUserRecord]);
                    });
                }
            }];
        }
    }];
}

-(BOOL)currentUserExists {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"userExists"];
}

@end
