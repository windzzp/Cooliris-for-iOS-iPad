//
//  PageInfoManager.m
//  Cooliris
//
//  Created by user on 13-6-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "PageInfoManager.h"
#import "PageInfo.h"
#import "PageGroupInfo.h"

@interface PageInfoManager ()

@property (nonatomic, strong, readwrite) NSMutableArray *pageInfoGroups;
@property (nonatomic, strong, readwrite) NSMutableDictionary *pageGroupsDict;

@end

@implementation PageInfoManager

+ (PageInfoManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    
    return _sharedObject;
}

- (NSArray *)loadPageInfoGroups
{
    if (_pageInfoGroups) {
        return _pageInfoGroups;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PageGroups" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSArray *pages = [data objectForKey:@"default_page"];
    
    NSMutableArray *groups = [@[] mutableCopy];

    PageGroupInfo *group = nil;
    PageInfo *page = nil;
    NSArray *items = nil;
    for (NSDictionary *dict in pages) {
        group = [[PageGroupInfo alloc] init];
        group.title = (NSString *)dict.allKeys[0];
        group.pageInfos = [@[] mutableCopy];
        
        items = dict[group.title];
        for (NSString *item in items) {
            page = [[PageInfo alloc] init];
            page.title = item;
            [group.pageInfos addObject:page];
        }
                
        [groups addObject:group];
    }
    
    self.pageInfoGroups = groups;
    
    return _pageInfoGroups;
}

- (NSDictionary *)loadPageGroups
{
    if (self.pageGroupsDict) {
        return self.pageGroupsDict;
    }
    
    //_pageGroupsDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PageGroups" ofType:@"plist"];
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];

    PageGroupInfo *group = nil;
    PageInfo *page = nil;
    NSArray *items = nil;
    
    NSArray *keys = [dataDict allKeys];
    for (NSString *key in keys) {
        NSLog(@"key = %@, %@", key, [dataDict objectForKey:key]);
        
        // Fill group info
        group = [[PageGroupInfo alloc] init];
        group.title = key;
        if ([key isEqualToString:kPageGroupThemeCategoryTitle]) {
            group.groupType = kPageGroupThemeCategory;
        } else if ([key isEqualToString:kPageGroupSearchTitle]) {
            group.groupType = kPageGroupSearch;
        } else if ([key isEqualToString:kPageGroupFavoriteTitle]) {
            group.groupType = kPageGroupFavorite;
        } else {
            // No title
        }
        
        // TODO
        //group.logoUrl = nil;
        group.pageInfos = [@[] mutableCopy];
        
        // Fill group's page items
        items = dataDict[key];
        if (items && items.count > 0) {
            for (NSString *item in items) {
                page = [[PageInfo alloc] init];
                page.title = item;
                [group.pageInfos addObject:page];
            }
        }

        [groupDict setObject:group forKey:group.title];
        //[_pageGroupsDict setValue:group forKey:group.groupType];
    }
    
    _pageGroupsDict = groupDict;
    
    return _pageGroupsDict;
}

@end
