//
//  DetailViewController.h
//  yeet
//
//  Created by Akshay Easwaran on 1/13/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

