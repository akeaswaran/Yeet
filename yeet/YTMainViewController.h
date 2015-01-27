//
//  MasterViewController.h
//  yeet
//
//  Created by Akshay Easwaran on 1/13/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    YTCloudServiceParse,
    YTCloudServiceCloudKit
} YTCloudService;

@interface YTMainViewController : UITableViewController
-(void)refreshFriendsList;
-(instancetype)initWithCloudService:(YTCloudService)service;
@end

