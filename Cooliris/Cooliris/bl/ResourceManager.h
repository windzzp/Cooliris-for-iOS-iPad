//
//  ResourceManager.h
//  Cooliris
//
//  Created by user on 13-6-24.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceManager : NSObject

+ (ResourceManager *)sharedInstance;
- (void)copyDatabaseFile;
- (BOOL)isDatabaseFileExisted;

@end
