//
//  ImageGroupCache.h
//  Cooliris
//
//  Created by user on 13-6-25.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageGroupCache : NSObject

@property (strong, nonatomic) NSArray        *cachedIds;
@property (strong, nonatomic) NSMutableArray *currentGroups;
@property (nonatomic)         NSRange        currentRange;

- (NSArray *)getCurrentRangeIds;
- (NSArray *)getMoreRange:(int)step;
- (NSArray *)getMoreOldRange:(int)step;
- (NSArray *)getRange:(BOOL)isOld inStep:(int)step;


// Should we remove it from this class
- (NSArray *)loadMoreData:(int)step needFilleContent:(BOOL)fillContent;

@end
