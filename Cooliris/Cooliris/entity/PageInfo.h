//
//  PageInfo.h
//  Cooliris
//
//  Created by user on 13-6-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageGroupInfo;

@interface PageInfo : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *logoUrl;

@property (nonatomic, weak) PageGroupInfo *parentGroup;

@end
