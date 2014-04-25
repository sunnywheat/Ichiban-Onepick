//
//  AppDelegate.m
//  onepick
//
//  Created by yiqin on 4/21/14.
//  Copyright (c) 2014 purdue. All rights reserved.
//

// #define barTintColor [UIColor colorWithRed: 0.984 green: 0.471 blue: 0.525 alpha: 1]
//
// Reminder: You can use this calculator and put in what you want the color to be when rendered on screen, it will tell you what to set the color of the barTintColor so when Apple adjusts it, it will show as intended
//
#define barTintColor [UIColor colorWithRed: 226.0/255.0 green: 55.0/255.0 blue: 60.0/255.0 alpha: 1]
#define tintcolor [UIColor whiteColor]

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // Define color.
    [[UINavigationBar appearance] setBarTintColor:barTintColor];
    [[UITabBar appearance] setTintColor:barTintColor];
    // White or black
    [[UINavigationBar appearance] setTintColor:tintcolor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : tintcolor}];
    // Set status bar style
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    // Parse.com
    [Parse setApplicationId:@"2D6T3tgwBIPoE8HkuninwT3gsUkrHouCfzg0MzDL"
                  clientKey:@"cmvDVWTEIrZO4phyuddppS96diUqckCKazxBEwxH"];
    // Parse Test
    /*
    PFObject *gameScore = [PFObject objectWithClassName:@"GameScore"];
    gameScore[@"score"] = @1337;
    gameScore[@"playerName"] = @"Sean Plott";
    gameScore[@"cheatMode"] = @NO;
    [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Parse succeed.");
        } else {
            // If it doesn't print Error, please check the wifi connection.
            NSLog(@"Error.");
        }
    }];
    */
    
    
    // Initialize data on Parse.com
    /*
    PFObject *ichibanCategory = [PFObject objectWithClassName:@"ichibanCategoryIN"];
    ichibanCategory[@"category"] = @"Beef";
    [ichibanCategory saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"ichiban category created.");
        } else {
            NSLog(@"ichiban category error.");
        }
    }];
    */
    
    /*
    PFObject *dish = [PFObject objectWithClassName:@"BeefIN"];
    dish[@"name"] = @"Beef 1";
    dish[@"price"] = @11;
    [dish saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Dish created.");
        } else {
            NSLog(@"Dish error.");
        }
    }];
    */
     
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
