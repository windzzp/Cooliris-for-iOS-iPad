//
//  PageInfoManager.h
//  Cooliris
//
//  Created by user on 13-6-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageInfoManager : NSObject

@property (nonatomic, strong, readonly) NSArray *pageInfoGroups;
@property (nonatomic, strong, readonly) NSDictionary *pageGroupsDict;

+ (PageInfoManager *)sharedInstance;
- (NSArray *)loadPageInfoGroups;
- (NSDictionary *)loadPageGroups;

@end
