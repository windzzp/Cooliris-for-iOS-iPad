//
//  NSThreadEx.m
//  Cooliris
//
//  Created by user on 13-5-22.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "NSThreadEx.h"

@interface NSThreadEx ()

- (void)notifyOnThread;

@end

@implementation NSThreadEx

- (void)wait
{
    isWait_ = YES;
    
    NSPort *port = [NSPort port];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addPort:port forMode:NSDefaultRunLoopMode];
    while (isWait_) {
        [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)wait:(NSTimeInterval)timeOut
{
    isWait_ = YES;
    
    NSDate *dateOut = [NSDate dateWithTimeIntervalSinceNow:timeOut];
    while (isWait_ && [dateOut compare:[NSDate date]] == NSOrderedDescending) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:dateOut];
    }
}

- (void) notifyOnThread
{
    isWait_ = NO;
}

- (void) notify
{
    [self performSelector:@selector(notifyOnThread) onThread:self withObject:nil waitUntilDone:NO];
}

@end
