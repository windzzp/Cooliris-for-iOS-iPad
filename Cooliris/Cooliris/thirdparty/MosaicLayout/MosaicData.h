//
//  MosaicData.h
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/17/13.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kMosaicLayoutTypeUndefined,
    kMosaicLayoutTypeSingle,
    kMosaicLayoutTypeDouble
} MosaicLayoutType;

@interface MosaicData : NSObject

-(id)initWithDictionary:(NSDictionary *)aDict;

@property (strong) NSString *imageFilename;
@property (strong) NSString *title;
@property (strong) NSString *thumbNailUrl;
@property (assign) BOOL firstTimeShown;
@property (assign) MosaicLayoutType layoutType;
@property (assign) float relativeHeight;
@property (assign) BOOL isFavourite;
@property (assign) BOOL isLocalImage;
@end
