//
//  DishTableViewController.h
//  onepick
//
//  Created by yiqin on 4/22/14.
//  Copyright (c) 2014 purdue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "NSString+JSONStringToDictionary.h"
#import "Cart.h"

@interface DishTableViewController : PFQueryTableViewController <UITableViewDelegate>

@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) Cart *cart;

@end
