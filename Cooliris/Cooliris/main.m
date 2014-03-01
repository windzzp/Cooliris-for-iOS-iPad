//
//  main.m
//  Cooliris
//
//  Created by user on 13-5-20.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "UncaughtExceptionHandler.h"
int main(int argc, char *argv[])
{
    @autoreleasepool {
        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception) {
            [UncaughtExceptionHandler PrintStackTrace(exception)];
        } 
    }
}
