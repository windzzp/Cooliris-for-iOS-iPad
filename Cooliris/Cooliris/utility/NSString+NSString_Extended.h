//
//  NSString+NSString_Extended.h
//  Cooliris
//
//  This file is the extension of the NSString.
//
//  Created by user on 13-5-22.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_Extended)

/**
 * Encoding the URL.
 * For example: 
 * Before encoding: http://www.viewster.tv/viewster_v2/toshiba.html?mId=1140-11804-000
 * After encoding:  http%3A%2F%2Fwww.viewster.tv%2Fviewster_v2%2Ftoshiba.html%3FmId%3D1140-11804-000
 *
 * Reserved characters after percent-encoding:
 *  !   *   '   (   )   ;   :   @   &   =   +   $   ,   /   ?   #   [   ]
 * %21 %2A %27 %28 %29 %3B %3A %40 %26 %3D %2B %24 %2C %2F %3F %23 %5B %5D
 * 
 * @return The url encode.
 */
- (NSString *)urlencode;

@end
