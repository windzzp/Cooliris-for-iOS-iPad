//
//  PageGroupInfo.h
//  Cooliris
//
//  Created by user on 13-6-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPageGroupThemeCategoryTitle    @"主题"
#define kPageGroupFavoriteTitle         @"收藏"
#define kPageGroupSearchTitle           @"搜索"

typedef NS_ENUM(NSInteger, PageGroupType) {
    kPageGroupThemeCategory = 0,
    kPageGroupFavorite,
    kPageGroupSearch
};

@class PageInfo;

@interface PageGroupInfo : NSObject

@property (nonatomic)         int groupType;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *logoUrl;
@property (nonatomic, strong) NSMutableArray *pageInfos;

@end
