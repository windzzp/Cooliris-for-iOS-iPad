//
//  UIDevice+UIDevice_Extended.h
//  Cooliris
//
//  This file is the extension of the UIDevice.
//
//  Created by user on 13-5-22.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (UIDevice_Extended)

/**
 * Get the mac address of the device.
 *
 * @return the mac address of the device.
 */
- (NSString *)macAddress;

@end
