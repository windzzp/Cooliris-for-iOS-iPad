//
//  NSThreadEx.h
//  Cooliris
//
//  This file is the is the extension of the NSThread.
//
//  Created by user on 13-5-22.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThreadEx : NSThread
{
    BOOL isWait_;
}

/**
 * Set the thread to wait.
 */
- (void)wait;

/**
 * Set the thread to wait for some time.
 *
 * @param timeOut. The time to wait.
 */
- (void)wait:(NSTimeInterval)timeOut;

/**
 * To notify the waiting thread to continue .
 */
- (void)notify;

@end
