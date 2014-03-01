//
//  Json_Object.h
//  TestWeibo
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

#define initFailedWithMethodName(name) NSLog(@"%s:\n%s(%d) \nreason:JsonObject %@ failed null JsonObject was  return.", __FILE__, __FUNCTION__, __LINE__, name);

#define initFailedWithParam(param) NSLog(@"%s:\n%s(%d) \nreason:JsonObject initWithData failed with null param(%s).", __FILE__, __FUNCTION__, __LINE__, object_getClassName(param));

#define variableNotInitialized  NSLog(@"%s:\n%s(%d) \nreason:Variable is not initialized.", __FILE__, __FUNCTION__, __LINE__);

#define numberFailedTo(tp) NSLog(@"%s:\n%s(%d) \nreason:getInt failed, NSNumber convert to %@ failed.", __FILE__, __func__, __LINE__, tp);

//#define noSuchValue (fmt, ...) NSLog((@"%s:%s(%d)  getInt failed.No value for this key or the value for this key isn't NSNumber type.\n" fmt),__FILE__,__func__,__LINE__,##__VA_ARGS__);

@interface JsonObject : NSObject
{
    NSMutableDictionary *json;
}

#pragma mark init

/**
 * Init a Json_Object with specific object.
 */
- (id)initWithData:(const NSData *)data;
- (id)initWithString:(const NSString *)str;
- (id)initWithDictionary:(const NSDictionary *)dic;
- (id)initWithArray:(const NSArray *)arr withName:(const NSString *)name;

#pragma mark parse

/**
 * Return allkeys of current JsonObject.
 */
- (NSArray  *)allKeys;

/**
 * Parse content.
 */
- (int)getInt:(const NSString *)key;
 - (int)getInt:(const NSString *)key withFallBack:(int)fallback;

/**
  * Return a strng value for specific key,if value invalid return nil(may cause your app crash,call with fallback(@"")), if you have a default value call 
  * with fallback
  * pls.
  */
- (NSString *)getString:(const NSString *)key;
- (NSString *)getString:(const NSString *)key withFallBack:(NSString *)fallback;

/**
 * If value invalid will return NO by default, if you have a defalut value pls call with fallback.
 */
- (BOOL)getBool:(const NSString *)key;
- (BOOL)getBool:(const NSString *)key withFallBack:(BOOL)fallback;

/**
 * Return a long int value for specific key,if value invalid return LONG_MIN.
 */
- (long)getLong:(const NSString *)key;
- (long)getLong:(const NSString *)key withFaLLBack:(long)fallback;

/**
 * Return a NSArray, If value for the key is invalid return nil.
 */
- (NSArray *)getArray:(const NSString *)key;
- (NSArray *)getArray:(const NSString *)key withFallBack:(NSArray *)fallback;

- (JsonObject *)getJsonObject:(const NSString*)key;
- (JsonObject *)getJsonObject:(const NSString *)key withFallBack:(JsonObject *)fallback;

- (NSArray *)getJsonArray:(const NSString *)key;
- (NSArray *)getJsonArray:(const NSString *)key withFallBack:(NSArray *)fallback;

#pragma mark modify

/**
 * Modify JsonObject
 */
- (void)addInt:(int)value withKey:(const NSString *)key;
- (void)addLong:(long)value withKey:(const NSString *)key;
- (void)addBool:(BOOL)value withKey:(const NSString *)key;
- (void)addString:(NSString *)value withKey:(const NSString *)key;

/**
 * Before add the Object pls reference to isValidJSONObject.
 */
- (void)addObject:(id)value withKey:(const NSString *)key;

/**
 * Add a set of value to the jsonObject.you can put some key-values into a dictionary,
 * and then call this method.All the keys must be nsstring and all values 
 * reference to isValidJSONObject.
 */
- (void)addValuesFromDictionary:(const NSDictionary *)dictionary;

- (void)delByKey:(const NSString *)key;
- (void)delByKeys:(NSArray *)keys;

#pragma mark create json data

/**
 * reference to isValidJSONObject.
 */
+ (BOOL)canCreateJson:(id)object;

/**
 * Create Json data.Static method the object must be NSArray or NSdictionary,pls reference to
 * isValidJSONObject.
 */
+ (NSData *)createJsonData:(id)Object;
+ (NSString *)createJsonString:(id)object;

/**
 * If current Json_Object has been modified and you want to create a new json string.
 *
 * @return Jsonstring of current JsonObject.
 */
- (NSString *)toJsonString;
@end
