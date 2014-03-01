//
//  UIColor+UIColor_Extended.h
//  Cooliris
//
//  This file is the extension of the UIColor.
//
//  Created by user on 13-5-22.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColor_Extended)

/**
 * Constuctor color from HEX.
 *
 * @param stringToConvert  the HEX to parse
 * @return The UIColor after being parsed.
 */
+ (UIColor *)colorWithHex:(UInt64)hex;

/**
 * Constuctor color from HEX string.
 *
 * @param stringToConvert  the string to parse
 * @return The UIColor after being parsed.
 */
+ (UIColor *)colorWithHexString: (NSString *) stringToConvert;

@end
