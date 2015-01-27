//
//  YTCloudKitManager.h
//  yeet
//
//  Created by Akshay Easwaran on 1/24/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

@interface YTCloudKitManager : NSObject
+(instancetype)sharedManager;

//registration
- (void)registerUsername:(NSString*)username
            successBlock:(void(^)())successBlock
            failureBlock:(void(^)(NSError* error))failureBlock;
- (void)checkIfUsernameIsRegisteredWithRecordId:(CKRecordID*)recordId
                                   successBlock:(void(^)())successBlock
                                   failureBlock:(void(^)(NSError* error))failureBlock;
- (void)checkIfUsernameIsRegistered:(NSString*)username
                       successBlock:(void(^)(BOOL usernameExists))successBlock
                       failureBlock:(void(^)(NSError *error))failureBlock;

//Friends

- (void)loadFriendsToCurrentUserWithSuccessBlock:(void(^)(NSArray *friends))successBlock
                                    failureBlock:(void(^)(NSError *error))failureBlock;

- (void)blockUser:(CKRecord*)user
     successBlock:(void(^)(CKRecord *blockedUser))successBlock
     failureBlock:(void(^)(NSError *error))failureBlock;

- (void)addFriendWithUsername:(NSString*)username
                 successBlock:(void(^)(CKRecord *newFriend))successBlock
                 failureBlock:(void(^)(NSError *error))failureBlock;

- (void)sendYoToFriend:(CKRecord*)friendRecord
          successBlock:(void(^)())successBlock
          failureBlock:(void(^)(NSError *error))failureBlock;

@end
