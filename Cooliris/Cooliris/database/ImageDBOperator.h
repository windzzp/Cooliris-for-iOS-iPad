//
//  ImageTable.h
//  Cooliris
//
//  Created by user on 13-6-3.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "AbsDBOperator.h"

@class Image;
@class ImageGroup;

@interface ImageDBOperator : AbsDBOperator

+ (ImageDBOperator *)sharedInstance;
- (NSArray *)getAllGroupIds:(NSString *)withCategory;
- (NSArray *)getGroupsBy:(NSRange)range;
- (NSArray *)getGroupsWith:(NSArray *)ids;
- (NSArray *)getImagesBy:(int)groupId;
- (void)fillImage:(ImageGroup *)imageGroup;
- (BOOL)updateFavoriteImage:(Image *)image;
- (void)updateFavoriteGroup:(ImageGroup *)imageGroup;
- (NSArray *)getArticlesIdByTag:(NSString *)tag;
- (NSArray *)getAllLocalFavourite;

@end
