//
//  UIApplication+AppDimensions.h
//  DMLazyScrollViewExample
//
//  Created by user on 13-6-20.
//  Copyright (c) 2013年 daniele. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (AppDimensions)

+(CGSize) currentSize;
+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation;

@end
