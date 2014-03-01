//
//  ImageGroupCache.m
//  Cooliris
//
//  Created by user on 13-6-25.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "ImageGroupCache.h"
#import "ImageDBOperator.h"
#import "ImageGroup.h"

#define kMoreDataStep   5

@implementation ImageGroupCache

- (id)init
{
    self = [super init];
    if (self) {
        _cachedIds = [[NSMutableArray alloc] init];
        _currentGroups = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)setCurrentRange:(NSRange)currentRange
{
    _currentRange = currentRange;
    if (_cachedIds) {
        int size = _cachedIds.count;
        
        int start = currentRange.location;
        int end = currentRange.location + currentRange.length;
        
        start = MAX(0, start);
        end = MIN(size, end);
        
        _currentRange.location = start;
        _currentRange.length = end - start;;
    }
}

- (NSArray *)getCurrentRangeIds
{
    NSMutableArray *outIds = [[NSMutableArray alloc] init];
    int start  = _currentRange.location;
    int end    = start + _currentRange.length;
    
    for (int ix = start; ix < end; ++ix) {
        [outIds addObject:_cachedIds[ix]];
    }
    
    return outIds;
}

- (NSArray *)getMoreRange:(int)step
{
    return [self getRange:NO inStep:step];
}

- (NSArray *)getMoreOldRange:(int)step
{
    // Current is the same with |getMoreRange|
    return [self getRange:NO inStep:step];
}

- (NSArray *)loadMoreData:(int)step needFilleContent:(BOOL)fillContent
{
    NSArray *range = [self getMoreOldRange:kMoreDataStep];
    NSArray *groups = [[ImageDBOperator sharedInstance] getGroupsWith:range];
    for (ImageGroup *group in groups) {
        [[ImageDBOperator sharedInstance] fillImage:group];
    }
    
    return groups;
}

- (NSArray *)getRange:(BOOL)isOld inStep:(int)step
{
    int count = _cachedIds.count;
    if (0 == count) {
        NSLog(@"Cache Data Invalid!");
        return nil;
    }
    
    NSMutableArray *outIds = [[NSMutableArray alloc] init];
    
    int newStart  = _currentRange.location;
    int newEnd    = newStart + _currentRange.length;
    
    int tempStart = newStart;
    int tempEnd   = newEnd;
    
    if (isOld) {
        newEnd += step;
        newEnd = MIN(newEnd, count);
        
        tempStart = tempEnd;
        tempEnd = newEnd;
    } else {
        newStart -= step;
        newStart = MAX(newStart, 0);
        
        tempEnd = tempStart;
        tempStart = newStart;
    }
    
    for (int ix = tempStart; ix < tempEnd; ++ix) {
        [outIds addObject:_cachedIds[ix]];
    }
    
    // Reset current range
    _currentRange.location = newStart;
    _currentRange.length   = newEnd - newStart;
    
    return outIds;
}

@end
