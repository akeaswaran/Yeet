//
//  YTUser.h
//  yeet
//
//  Created by Akshay Easwaran on 1/24/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
@interface YTUser : NSObject
@property (nonatomic) CKRecord *currentUserRecord;
+(instancetype)sharedInstance;
-(BOOL)currentUserExists;
- (void)fetchCurrentUserWithSuccessBlock:(void(^)(CKRecord *currentUserRecord))successBlock
                            failureBlock:(void(^)(NSError *error))failureBlock;
@end
