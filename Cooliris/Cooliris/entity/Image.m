//
//  Image.m
//  Cooliris
//
//  Created by user on 13-5-24.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "Image.h"

@implementation Image

- (BOOL)isEqual:(id)object{
    Image *image = (Image *)object;
    if ([self.url isEqualToString:image.url] && [self.thumbUrl isEqualToString:image.thumbUrl]) {
        return YES;
    }
    return NO;
}

@end
