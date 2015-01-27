//
//  YTParseManager.h
//  yeet
//
//  Created by Akshay Easwaran on 1/27/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef void (^YTSuccessCompletionBlock)();
typedef void (^YTFailureCompletionBlock)(NSError *error);
typedef void (^YTFriendsCompletionBlock)(NSArray *friends, NSError *error);

@interface YTParseManager : NSObject
+(instancetype)sharedManager;

//registration
- (void)registerUsername:(NSString*)username password:(NSString*)password
            successBlock:(YTSuccessCompletionBlock)successBlock
            failureBlock:(YTFailureCompletionBlock)failureBlock;

//Friends

-(void)loadFriendsForCurrentUserWithCompletionBlock:(YTFriendsCompletionBlock)completionBlock;

- (void)blockUser:(PFUser*)user
                 successBlock:(YTSuccessCompletionBlock)successBlock
                 failureBlock:(YTFailureCompletionBlock)failureBlock;

-(void)addFriendWithUsername:(NSString *)username successBlock:(YTSuccessCompletionBlock)successBlock failureBlock:(YTFailureCompletionBlock)failureBlock;

//Sending
-(void)sendMessageToUser:(PFUser*)user successBlock:(YTSuccessCompletionBlock)successBlock failureBlock:(YTFailureCompletionBlock)failureBlock;
@end
