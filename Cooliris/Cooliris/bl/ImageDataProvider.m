//
//  ImageDataProvider.m
//  Cooliris
//
//  Created by user on 13-5-24.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "ImageDataProvider.h"
#import "Image.h"
#import "ImageGroup.h"
#import "MosaicData.h"
#import "ImageDBOperator.h"
#import "PageInfoManager.h"
#import "PageGroupInfo.h"
#import "PageInfo.h"
#import "ImageGroupCache.h"

#define kMoreDataStep   5
#define kStartDataIx    30
#define kStartDataStep  40

@interface ImageDataProvider ()
{
    NSObject *lock;
}

// The image list
@property (nonatomic, strong, readwrite) NSMutableArray *imageList;
@property (nonatomic, strong, readwrite) NSMutableArray *mosaicImageList;
@property (nonatomic, strong, readwrite) NSMutableArray *imageGroups;

@property (nonatomic, strong) NSMutableDictionary *loadedGroupsCache;

@property (nonatomic) NSRange currentRange;

- (NSArray *)loadImageGroups;
- (NSArray *)loadImageGroups:(NSRange)range;

@end

@implementation ImageDataProvider

+ (ImageDataProvider *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    
    return _sharedObject;
}

#pragma mark - Public method

- (id)init
{
    self = [super init];
    if (self) {
        lock = [[NSObject alloc] init];
        
        self.imageList = [@[] mutableCopy];
        //self.categoryImageGroupsDict = [[NSMutableDictionary alloc] init];
        self.imageGroupsCache = [[NSMutableDictionary alloc] init];
        self.loadedGroupsCache = [[NSMutableDictionary alloc] init];
        NSArray *pageInfoGroups = [PageInfoManager sharedInstance].pageInfoGroups;
        PageGroupInfo *group = ((PageGroupInfo *)pageInfoGroups[0]);
        
        for (PageInfo *page in group.pageInfos) {
            //[self.categoryImageGroupsDict setObject:[[NSMutableArray alloc] init] forKey:page.title];
            [self.imageGroupsCache setObject:[[ImageGroupCache alloc] init] forKey:page.title];
        }

        //[[ImageDBOperator sharedInstance] getAllGroupIds:nil];
    }
    return self;
}

- (NSArray *)getImageGroupsByCategory:(NSString *)category
{
    ImageGroupCache *cacheItem = _imageGroupsCache[category];
    if (cacheItem) {
        return cacheItem.currentGroups;
    }
    
    return nil;
}

- (void)loadImageGroupsAsync:(LoadCompleteBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //self.mosaicImageList = [self loadWebMosaicImage];
        
        self.currentRange = NSMakeRange(kStartDataIx, kStartDataStep);
        self.imageGroups = [self loadImageGroups:self.currentRange];
        
        completionBlock(self.imageGroups, nil);
    });
}

- (void)loadMoreImageGroupsAsync:(LoadCompleteBlock)completionBlock
{
    [self loadMoreImageGroupsAsync:kMoreDataStep completed:completionBlock];
}

- (void)loadMoreImageGroupsAsync:(int)requestCount completed:(LoadCompleteBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (0 == _currentRange.location) {
            // No mroe data
            completionBlock(@[], nil);
        } else {
            NSRange range = NSMakeRange(_currentRange.location - requestCount, requestCount);
            NSArray *moreData = [self loadImageGroups:range];
            
            if (moreData) {
                for (ImageGroup *group in moreData) {
                    [((NSMutableArray *)_imageGroups) insertObject:group atIndex:0];
                }
                
                int start = _currentRange.location - moreData.count;
                self.currentRange = NSMakeRange(MAX(0, start), _imageGroups.count);
                completionBlock(moreData, nil);
                
            } else {
                // No mroe data
                completionBlock(@[], nil);
            }
        }
    });
}

- (void)loadImageGroupsAsync:(NSString *)withCategory completed:(LoadCompleteBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        @synchronized(lock)
        {
            NSLog(@"loadImageGroupsAsync:%@", withCategory);
            NSArray *groups = nil;
            NSMutableArray *loadedGroups = [[NSMutableArray alloc] init];
            
            // Get the cache object from dictionary
            ImageGroupCache *cache = _imageGroupsCache[withCategory];
            if (cache) {
                
                // Load the cache ids first
                if (0 == cache.cachedIds.count) {
                    NSString *category = withCategory;
                    
                    // Make the specified category [All] can search all data.
                    if (!withCategory || [withCategory isEqualToString:@"全部"]) {
                        category = nil;
                    }
                    
                    // Load all group ids by category
                    cache.cachedIds = [[ImageDBOperator sharedInstance] getAllGroupIds:category];
                }
                
                // Load the initialized cache data
                //NSArray *range = [cache getMoreOldRange:kMoreDataStep];
                //NSArray *groups = [[ImageDBOperator sharedInstance] getGroupsWith:range];
                
                // Set default range
                NSNumber *start = [[NSUserDefaults standardUserDefaults] objectForKey:withCategory];
                NSUInteger startIndex = cache.cachedIds.count * 1 / 5;
                if (nil != start) {
                    startIndex = start.integerValue;
                }
                NSRange defaultRange = { startIndex, 30 };
                cache.currentRange = defaultRange;
                
                NSMutableArray *rangeIds = [[NSMutableArray alloc] initWithArray:[cache getCurrentRangeIds]];
                NSMutableArray *removedIds = [[NSMutableArray alloc] init];
                NSUInteger count = rangeIds.count;
                for (int i = 0; i < count; i++) {
                    int rangeId = [rangeIds[i] intValue];
                    ImageGroup *group = [_loadedGroupsCache objectForKey:[NSNumber numberWithInt:rangeId]];
                    if (group) {
                        NSLog(@"loadImageGroupsAsync: group:%d is existed in loaded groups cache", group.groupId);
                        [removedIds addObject:rangeIds[i]];
                        [loadedGroups addObject:group];
                    }
                }
                [rangeIds removeObjectsInArray:removedIds];
                
                groups = [[ImageDBOperator sharedInstance] getGroupsWith:rangeIds];
                for (ImageGroup *group in groups) {
                    [[ImageDBOperator sharedInstance] fillImage:group];
                    [self.loadedGroupsCache setObject:group forKey:[NSNumber numberWithInt:group.groupId]];
                    [loadedGroups addObject:group];
                }
                
                // Sort array in loaded groups.
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_groupId" ascending:YES];
                [loadedGroups sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                // Insert the new item in the header of the Array
                // NOTE: it seems inefficiency
                for (int ix = loadedGroups.count - 1; ix >=0; --ix) {
                    [cache.currentGroups insertObject:loadedGroups[ix] atIndex:0];
                }
                
                //for (ImageGroup *group in groups) {
                //    [cache.currentGroups insertObject:group atIndex:0];
                //}
            }
            
            if (completionBlock) {
                completionBlock(loadedGroups, nil);
            }

        }
    });
}

- (void)loadMoreImageGroupsAsync:(NSString *)withCategory
                       withCount:(int)requestCount
                     loadOldData:(BOOL)isOld
                       completed:(LoadCompleteBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @synchronized(lock)
        {
            NSLog(@"loadImageGroupsAsync:withCategory:%@, requestCount: %d, isOld = %d", withCategory, requestCount, isOld);
            
            NSArray *groups = nil;
            NSMutableArray *loadedGroups = [[NSMutableArray alloc] init];
            
            // Get the cache object from dictionary
            ImageGroupCache *cache = _imageGroupsCache[withCategory];
            if (cache) {
                
                // Load the cache ids first
                if (0 == cache.cachedIds.count) {
                    NSLog(@"Have you loadImageGroupsAsync for first???");
                    //completionBlock(groups, @"Have not initialized...");
                    completionBlock(groups, nil);
                    
                    return;
                }
                
                // Load the initialized cache data
                NSMutableArray *rangeIds = [[NSMutableArray alloc] initWithArray:[cache getRange:isOld inStep:requestCount]];
                NSMutableArray *removedIds = [[NSMutableArray alloc] init];
                NSUInteger count = rangeIds.count;
                for (int i = 0; i < count; i++) {
                    int rangeId = [rangeIds[i] intValue];
                    ImageGroup *group = [_loadedGroupsCache objectForKey:[NSNumber numberWithInt:rangeId]];
                    if (group) {
                        NSLog(@"loadMoreImageGroupsAsync: group:%d is existed in loaded groups cache", group.groupId);
                        [removedIds addObject:rangeIds[i]];
                        [loadedGroups addObject:group];
                    }
                }
                [rangeIds removeObjectsInArray:removedIds];
                
                groups = [[ImageDBOperator sharedInstance] getGroupsWith:rangeIds];
                for (ImageGroup *group in groups) {
                    [[ImageDBOperator sharedInstance] fillImage:group];
                    [self.loadedGroupsCache setObject:group forKey:[NSNumber numberWithInt:group.groupId]];
                    [loadedGroups addObject:group];
                }
                
                // Sort array in loaded groups.
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_groupId" ascending:YES];
                [loadedGroups sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                // Insert the new item in the header of the Array
                // NOTE: it seems inefficiency
                if (isOld) {
                    [cache.currentGroups addObjectsFromArray:loadedGroups];
                    
                } else {
                    for (int ix = loadedGroups.count - 1; ix >=0; --ix) {
                        [cache.currentGroups insertObject:loadedGroups[ix] atIndex:0];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:cache.currentRange.location]
                                                              forKey:withCategory];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
            if (completionBlock) {
                completionBlock(loadedGroups, nil);
            }
        }
    });
}

//- (void)loadImageGroupsAsync:(NSString *)withCategory completed:(LoadCompleteBlock)completionBlock
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        @synchronized(lock)
//        {
//            NSLog(@"loadImageGroupsAsync:%@", withCategory);
//            NSArray *groups = nil;
//            
//            // Get the cache object from dictionary
//            ImageGroupCache *cache = _imageGroupsCache[withCategory];
//            if (cache) {
//                
//                // Load the cache ids first
//                if (0 == cache.cachedIds.count) {
//                    NSString *category = withCategory;
//                    
//                    // Make the specified category [All] can search all data.
//                    if (!withCategory || [withCategory isEqualToString:@"全部"]) {
//                        category = nil;
//                    }
//                    
//                    // Load all group ids by category
//                    cache.cachedIds = [[ImageDBOperator sharedInstance] getAllGroupIds:category];
//                }
//                
//                // Load the initialized cache data
//                //NSArray *range = [cache getMoreOldRange:kMoreDataStep];
//                //NSArray *groups = [[ImageDBOperator sharedInstance] getGroupsWith:range];
//                
//                // Set default range
//                NSNumber *start = [[NSUserDefaults standardUserDefaults] objectForKey:withCategory];
//                NSUInteger startIndex = cache.cachedIds.count * 1 / 5;
//                if (nil != start) {
//                    startIndex = start.integerValue;
//                }
//                NSRange defaultRange = { startIndex, 30 };
//                cache.currentRange = defaultRange;
//                
//                groups = [[ImageDBOperator sharedInstance] getGroupsWith:[cache getCurrentRangeIds]];
//                for (ImageGroup *group in groups) {
//                    [[ImageDBOperator sharedInstance] fillImage:group];
//                }
//                
//                // Insert the new item in the header of the Array
//                // NOTE: it seems inefficiency
//                for (int ix = groups.count - 1; ix >=0; --ix) {
//                    [cache.currentGroups insertObject:groups[ix] atIndex:0];
//                }
//                
//                //for (ImageGroup *group in groups) {
//                //    [cache.currentGroups insertObject:group atIndex:0];
//                //}
//            }
//            
//            if (completionBlock) {
//                completionBlock(groups, nil);
//            }
//            
//        }
//    });
//}
//
//- (void)loadMoreImageGroupsAsync:(NSString *)withCategory
//                       withCount:(int)requestCount
//                     loadOldData:(BOOL)isOld
//                       completed:(LoadCompleteBlock)completionBlock
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        @synchronized(lock)
//        {
//            NSLog(@"loadImageGroupsAsync:withCategory:%@, requestCount: %d, isOld = %d", withCategory, requestCount, isOld);
//            
//            NSArray *groups = nil;
//            
//            // Get the cache object from dictionary
//            ImageGroupCache *cache = _imageGroupsCache[withCategory];
//            if (cache) {
//                
//                // Load the cache ids first
//                if (0 == cache.cachedIds.count) {
//                    NSLog(@"Have you loadImageGroupsAsync for first???");
//                    //completionBlock(groups, @"Have not initialized...");
//                    completionBlock(groups, nil);
//                    
//                    return;
//                }
//                
//                // Load the initialized cache data
//                NSArray *range = [cache getRange:isOld inStep:requestCount];
//                groups = [[ImageDBOperator sharedInstance] getGroupsWith:range];
//                
//                // Fill group data
//                for (ImageGroup *group in groups) {
//                    [[ImageDBOperator sharedInstance] fillImage:group];
//                }
//                
//                // Insert the new item in the header of the Array
//                // NOTE: it seems inefficiency
//                if (isOld) {
//                    [cache.currentGroups addObjectsFromArray:groups];
//                    
//                } else {
//                    for (int ix = groups.count - 1; ix >=0; --ix) {
//                        [cache.currentGroups insertObject:groups[ix] atIndex:0];
//                    }
//                    
//                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:cache.currentRange.location]
//                                                              forKey:withCategory];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                }
//            }
//            
//            if (completionBlock) {
//                completionBlock(groups, nil);
//            }
//        }
//    });
//}

#pragma mark - Private method

- (NSArray *)loadImageGroups
{
    NSRange range = {1, 50};
    NSArray *groups = [[ImageDBOperator sharedInstance] getGroupsBy:range];
    for (ImageGroup *group in groups) {
        [[ImageDBOperator sharedInstance] fillImage:group];
    }
    
    return groups;
}

- (NSArray *)loadImageGroups:(NSRange)range
{
    NSArray *groups = [[ImageDBOperator sharedInstance] getGroupsBy:range];
    for (ImageGroup *group in groups) {
        [[ImageDBOperator sharedInstance] fillImage:group];
    }
    
    return groups;
}

@end
