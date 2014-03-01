//
//  ImageDataProvider.h
//  Cooliris
//
//  Created by user on 13-5-24.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

// Define the callback when load images completed.
typedef void(^LoadCompleteBlock)(NSArray *resultImageList, NSError *error);

@interface ImageDataProvider : NSObject

@property (nonatomic, strong, readonly) NSArray *imageList;
@property (nonatomic, strong, readonly) NSArray *mosaicImageList;
@property (nonatomic, strong, readonly) NSArray *imageGroups;

@property (nonatomic, strong) NSMutableDictionary *imageGroupsCache;

+ (ImageDataProvider *)sharedInstance;
- (NSArray *)getImageGroupsByCategory:(NSString *)category;

// TODO: To be removed
- (void)loadImageGroupsAsync:(LoadCompleteBlock)completionBlock;
- (void)loadMoreImageGroupsAsync:(LoadCompleteBlock)completionBlock;
- (void)loadMoreImageGroupsAsync:(int)requestCount completed:(LoadCompleteBlock)completionBlock;

- (void)loadImageGroupsAsync:(NSString *)withCategory completed:(LoadCompleteBlock)completionBlock;
- (void)loadMoreImageGroupsAsync:(NSString *)withCategory withCount:(int)requestCount loadOldData:(BOOL)isOld completed:(LoadCompleteBlock)completionBlock;

@end