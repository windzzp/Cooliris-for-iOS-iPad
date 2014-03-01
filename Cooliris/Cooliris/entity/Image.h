//
//  Image.h
//  Cooliris
//
//  Created by user on 13-5-24.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageGroup;

@interface Image : NSObject

#pragma mark - Network properties

@property (nonatomic) int imageId;
@property (nonatomic, strong) NSString *title;      // TODO: To be removed
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *thumbUrl;

#pragma mark - Local property

@property (nonatomic, strong) NSString *downloadPath;
@property (nonatomic, strong) NSString *thumbDownloadPath;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic, weak) ImageGroup *parentGroup;

@end
