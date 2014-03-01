//
//  MosaicData.m
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/17/13.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import "MosaicData.h"

@implementation MosaicData
@synthesize title, imageFilename,thumbNailUrl;

- (id)initWithDictionary:(NSDictionary *)aDict
{
    self = [self init];
    if (self){
        self.imageFilename  = [aDict objectForKey:@"imageFilename"];
        self.title          = [aDict objectForKey:@"title"];
        self.thumbNailUrl   = [aDict objectForKey:@"thumbNailUrl"];
        self.firstTimeShown = YES;
    }
    return self;
}

- (NSString *)description
{
    NSString *retVal = [NSString stringWithFormat:@"%@ %@", [super description], self.title];
    return retVal;
}

- (BOOL)isEqual:(id)object
{
    MosaicData *image = (MosaicData *)object;
    return [self.imageFilename isEqualToString:image.imageFilename];
}

@end
