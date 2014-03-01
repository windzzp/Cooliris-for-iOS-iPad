//
//  AppDelegate.h
//  Cooliris
//
//  Created by user on 13-5-20.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
// Root view controller
@property (strong, nonatomic) IBOutlet UITabBarController *rootViewController;

@end
