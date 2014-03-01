//
//  NSData+NSData_Extended.h
//  Cooliris
//
//  This file is the extension of the NSData.
//
//  Created by user on 13-5-22.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSData_Extended)

/**
 * The NSData object is initialized with the contents of the Base 64 encoded string.
 *
 * @param string. An NSString object that contains only Base 64 encoded data.
 * @return The NSData object.
 */
+ (NSData *)dataWithBase64:(NSString *) string;

/**
 * The NSData object is initialized with the contents of the Base 64 encoded string.
 *
 * @param string. An NSString object that contains only Base 64 encoded data.
 * @return self.
 */
- (id)initWithBase64:(NSString *) string;

/**
 * This method returns a Base 64 encoded string representation of the data object.
 *
 * @param lineLength. A value of zero means no line breaks.
 * @return The base 64 encoded data.
 */
- (NSString *)base64WithLength:(unsigned int) lineLength;

/**
 * Decrypt the data.
 *
 * @param key. The decrypt key.
 */
- (NSData *)decryptWithKey:(NSString *)key;

/**
 * Encrypt the data.
 *
 * @param key. The encrypt key.
 */
- (NSData *)encryptWithKey:(NSString *)key;

@end
