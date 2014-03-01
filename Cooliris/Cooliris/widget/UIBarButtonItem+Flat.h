//
//  UIBarButtonItem+Flat.h
//  Cooliris
//
//  Created by user on 13-6-19.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Flat)

+ (void) configureFlatButtonsWithColor:(UIColor *)color
                      highlightedColor:(UIColor *)highlightedColor
                          cornerRadius:(CGFloat)cornerRadius
                       whenContainedIn:(Class <UIAppearanceContainer>)containerClass, ... NS_REQUIRES_NIL_TERMINATION;

+ (void) configureFlatButtonsWithColor:(UIColor *)color
                      highlightedColor:(UIColor *)highlightedColor
                             withImage:(UIImage *)image
                     hightlightedImage:(UIImage *)highlightedImage
                          cornerRadius:(CGFloat)cornerRadius
                       whenContainedIn:(Class <UIAppearanceContainer>)containerClass, ... NS_REQUIRES_NIL_TERMINATION;

+ (void) configureFlatButtonsWithColor:(UIColor *)color
                      highlightedColor:(UIColor *)highlightedColor
                          cornerRadius:(CGFloat) cornerRadius;

- (void) configureFlatButtonWithColor:(UIColor *)color
                     highlightedColor:(UIColor *)highlightedColor
                         cornerRadius:(CGFloat)cornerRadius UI_APPEARANCE_SELECTOR;

- (void) removeTitleShadow;

@end
