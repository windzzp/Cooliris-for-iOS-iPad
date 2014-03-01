//
//  ImageGroup.h
//  Cooliris
//
//  Created by user on 13-6-3.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kWaterFlowLayoutTypeUndefined,
    kWaterFlowLayoutTypeSingle,
    kWaterFlowLayoutTypeDouble
} WaterFlowLayoutType;

@interface ImageGroup : NSObject

@property (nonatomic) int groupId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) NSString *categories; // Should we use |int|&|int| ? for search
@property (nonatomic, strong) NSString *tags;       // Should we use |int|&|int| ? for search
//@property (nonatomic, strong) NSArray  *categories; // Should we use |int|&|int| ? for search
//@property (nonatomic, strong) NSArray  *tags;       // Should we use |int|&|int| ? for search
@property (nonatomic, strong) NSString *homePageUrl;

@property (nonatomic, strong) NSArray  *images;     // Image list
@property (nonatomic) BOOL isFavorite;              // The group is favorite or not

// UI information
@property (assign) WaterFlowLayoutType layoutType;
@property (assign) float relativeHeight;

@end
