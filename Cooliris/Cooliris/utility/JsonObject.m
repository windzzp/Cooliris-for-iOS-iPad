//
//  Json_Object.m
//  TestWeibo
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013. All rights reserved.
//

#import "JsonObject.h"

@implementation JsonObject


- (id)init
{
    self = [super init];
    if (nil != self) {
        json = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark init

- (id)initWithData:(const NSData *)data
{
    self = [self init];
    if (nil != self) {
        if (nil == data || [data length] == 0) {
            initFailedWithParam(data);
        } else {
            NSData * da = [data copy];
            NSError *error = nil;
            json = [ NSJSONSerialization JSONObjectWithData:da options:NSJSONReadingMutableContainers error:&error];
            if (nil == json || nil != error) {
                NSLog(@"%s:\n%s(%d) \nreason:error occur when init JsonObject with initWithData. error:%@", __FILE__, __func__, __LINE__, error);
            }
        }
    } else {
        initFailedWithMethodName(@"initWithData");
    }
    return self;
}

- (id)initWithDictionary:(const NSDictionary *)dic
{
    self = [self init];
    if (nil != self) {
        if (nil == dic) {
            initFailedWithParam(dic);
        } else {
            [json setDictionary:[dic copy]];
        }
    } else {
        initFailedWithMethodName(@"initWithDictionary");
    }
    return self;
}

- (id)initWithString:(const NSString *)str
{
    self = [self init];
    if (nil != self) {
        if (nil == str || 0 == str.length) {
            initFailedWithParam(str);
        } else {
            NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
            self =[self initWithData:data];
        }
    } else {
        initFailedWithMethodName(@"initWithString");
    }
    return self;
}

- (id)initWithArray:(const NSArray *)arr withName:(const NSString *)name
{
    self = [self init];
    if (nil != self) {
        if (nil == arr || nil == name || name.length == 0) {
            NSLog(@"%s:\n%s(%d) \nreason:JsonObject initWithArray failed, array or arrname is null.", __FILE__, __func__, __LINE__);
        } else {
            [json setDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:[arr copy],[name copy], nil]];
        }
    } else {
        initFailedWithMethodName(@"initWithArray");
    }
    return self;
}

#pragma mark Parse

- (void)noSuchValue:(id)tmpvalue withKey:(const NSString*)key
{
    NSLog(@"%s:\n%s(%d) \nreason:get value failed.No value for this key or the value for this key isn't NSNumber type.\nkey = %@.\nvalue = %@", __FILE__, __func__, __LINE__, key, tmpvalue);
}

- (NSArray *)allKeys
{
    NSArray *keys = nil;
    if (nil != json) {
        keys = [json allKeys];
    } else {
        NSLog(@"%s:\n%s(%d) \nreason:getJsonObject keys faild.", __FILE__, __FUNCTION__, __LINE__);
    }
    return keys;
}

- (int)getInt:(const NSString *)key
{
    int value = INT_MIN;
    if (nil != json) {
        id number = [json objectForKey:key];
        if (nil != number && [number isKindOfClass:[NSNumber class]]) {
            if ([number respondsToSelector:@selector(intValue)]) {
                value = [(NSNumber *)number intValue];
            } else {
            numberFailedTo(@"int");
            }
        } else {
            [self noSuchValue:number withKey:key];
        }
    } else {
        variableNotInitialized;
    }
    return value;
}

- (int)getInt:(const NSString *)key withFallBack:(int)fallback
{
    int value = [self getInt:key];
    if (INT_MIN == value)
        return fallback;
    return value;
}

- (long)getLong:(const NSString *)key
{
    long value = LONG_MIN;
    if (nil != json) {
        id number = [json objectForKey:key];
        if (nil != number && [number isKindOfClass:[NSNumber class]]) {
            if ([number respondsToSelector:@selector(longValue)]) {
                value = [(NSNumber *)number longValue];
            } else {
                numberFailedTo(@"long");
            }
        } else {
            [self noSuchValue:number withKey:key];
        }
    } else {
        variableNotInitialized;
    }
    return value;
}

- (long)getLong:(const NSString *)key withFaLLBack:(long)fallback
{
    long value = [self getLong:key];
    if (LONG_MIN == value)
        return fallback;
    return value;
}

- (BOOL)getBool:(const NSString *)key
{
    BOOL value = NO;
    if (nil != json) {
        id number = [json objectForKey:key];
        if (nil != number && [number isKindOfClass:[NSNumber class]]) {
            if ([number respondsToSelector:@selector(boolValue)]) {
                value = [(NSNumber *)number boolValue];
            } else {
                numberFailedTo(@"Bool");
            }
        } else {
            [self noSuchValue:number withKey:key];
        }
    } else {
        variableNotInitialized;
    }
    return value;
}

- (BOOL)getBool:(const NSString *)key withFallBack:(BOOL)fallback
{
    BOOL value = fallback;
    if (nil != json) {
        id number = [json objectForKey:key];
        if (nil != number && [number isKindOfClass:[NSNumber class]]) {
            if ([number respondsToSelector:@selector(boolValue)]) {
                value = [(NSNumber *)number boolValue];
            } else {
                numberFailedTo(@"Bool");
            }
        } else {
            [self noSuchValue:number withKey:key];
        }
    } else {
        variableNotInitialized;
    }
    return value;
}

- (NSString *)getString:(const NSString *)key
{
    NSString * value = nil;
    if (nil != json) {
        id strval = [json objectForKey:key];
        if (nil != strval && [strval isKindOfClass:[NSString class]]) {
            value = (NSString *)strval;
        } else {
            [self noSuchValue:strval withKey:key];
        }
    } else {
        variableNotInitialized;
    }
    return value;
}

- (NSString *)getString:(const NSString *)key withFallBack:(NSString *)fallback
{
    NSString *value = [self getString:key];
    if (nil == value || 0 == value.length)
        return fallback;
    return fallback;
}

- (NSArray *)getArray:(const NSString *)key
{
    NSArray *value = nil;
    if (nil != json) {
        id array = [json objectForKey:key];
        if (nil != array && [array isKindOfClass:[NSArray class]]) {
            value = [(NSArray *)array copy];
        } else {
            [self noSuchValue:array withKey:key];
        }
    } else {
        variableNotInitialized;
    }
    return value;
}

- (NSArray *)getArray:(const NSString *)key withFallBack:(NSArray *)fallback
{
    NSArray *value = [self getArray:key];
    if (nil == value)
        return fallback;
    return value;
}

- (NSArray *)getJsonArray:(const NSString *)key
{
    NSMutableArray *value = nil;
    if (nil != json) {
        NSArray *array = [json objectForKey:key];
        if (nil !=array && [array isKindOfClass:[NSArray class]]) {
            /* Parse every json in the json array through loop.*/
            value = [[NSMutableArray alloc] init];
            for (id jsn in array) {
                if ([jsn isKindOfClass:[NSDictionary class]]) {
                    [value addObject:[[JsonObject alloc] initWithDictionary:(NSDictionary*)jsn]];
                } else {
                    NSLog(@"%s:\n%s(%d) \nreason:An Object was reject while getJsonObject key = %@.\nvalue = %@", __FILE__, __func__, __LINE__, key, jsn);
                }
            }
        } else {
            [self noSuchValue:array withKey:key];
        }
    } else {
        variableNotInitialized;
    }
    return value;
}

- (NSArray *)getJsonArray:(const NSString *)key withFallBack:(NSArray *)fallback
{
    NSArray *value = [self getJsonArray:key];
    if (nil == value)
        return fallback;
    return value;
}

- (JsonObject *)getJsonObject:(const NSString *)key
{
    JsonObject *value = nil;
    if (nil != json) {
        id json_obj = [json objectForKey:key];
        if (nil != json_obj && [json_obj isKindOfClass:[NSDictionary class]]) {
            value = [[JsonObject alloc] initWithDictionary:(NSDictionary *)json_obj];
        } else {
            [self noSuchValue:json_obj withKey:key];
        }
    } else {
        variableNotInitialized;
    }
    return value;
}

- (JsonObject *)getJsonObject:(const NSString *)key withFallBack:(JsonObject *)fallback
{
    JsonObject *value = [self getJsonObject:key];
    if (nil == value)
        return fallback;
    return value;
}

#pragma mark Modify Json

- (void)addInt:(int)value withKey:(const NSString *)key
{
    if (nil == json) {
        variableNotInitialized;
    } else {
        [json setObject:[NSNumber numberWithInt:value] forKey:key];
    }
}

- (void)addBool:(BOOL)value withKey:(const NSString *)key
{
    if (nil == json) {
        variableNotInitialized;
    } else {
        [json setObject:[NSNumber numberWithBool:value] forKey:key];
    }
}

- (void)addLong:(long)value withKey:(const NSString *)key
{
    if (nil == json) {
        variableNotInitialized;
    } else {
        [json setObject:[NSNumber numberWithLong:value] forKey:key];
    }
}

- (void)addString:(NSString *)value withKey:(const NSString *)key
{
    if (nil == json) {
        variableNotInitialized;
    } else {
        if (nil == value) {
            [json setObject:[[NSNull alloc] init] forKey:key];////--->NSNULL ?
        } else {
            [json setObject:value forKey:key];
        }
    }
}

- (void)addObject:(id)value withKey:(const NSString *)key
{
    if (nil == json) {
        variableNotInitialized;
    } else {
        if ([NSJSONSerialization isValidJSONObject:value]) {
            if (nil != value) {
                [json setObject:value forKey:key];
            } else {
                [json setObject:[[NSNull alloc] init] forKey:key];
            }
        } else {
            NSLog(@"%s:\n%s(%d) \nreason:Illegal value reference to (isValidJSONObject).", __FILE__, __func__, __LINE__);
        }
    }
}

- (void)addValuesFromDictionary:(const NSDictionary *)dictionary
{
    NSDictionary * dic = [dictionary copy];
    NSArray * all_keys = [dic allKeys];
    if (nil != all_keys) {
        for (NSString *key in all_keys) {
            @autoreleasepool {
                id value = [dic objectForKey:key];
                if ([value isKindOfClass:[NSNumber class]])
                    [json setObject:(NSNumber *)value forKey:key];
                if ([value isKindOfClass:[NSString class]])
                    [self addString:(NSString *)value withKey:key];
                if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[ NSDictionary class]])
                    [self addObject:value withKey:key];
            }
        }
    }
}

- (void)delByKey:(const NSString *)key
{
    if (nil == json) {
        variableNotInitialized;
    } else {
        [json removeObjectForKey:key];
    }
}

- (void)delByKeys:(NSArray *)keys
{
    if (nil == json) {
        variableNotInitialized;
    } else {
        [json removeObjectsForKeys:keys];
    }
}

#pragma mark create json

+ (BOOL)canCreateJson:(id)object
{
    return [NSJSONSerialization isValidJSONObject:object];
}

+ (NSData *)createJsonData:(id)object
{
    NSData * json_data = nil;
    if ([NSJSONSerialization isValidJSONObject:object]) {
        NSError *error;
        json_data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        if (nil == json_data || 0 == json_data.length || nil != error) {
            NSLog(@"%s:\n%s(%d) \nreason:Error occur when createJsonData error:%@", __FILE__, __func__, __LINE__, error);
        }
    } else {
        NSLog(@"%s:\n%s(%d) \nreason:Invalid JsonObject %@", __FILE__, __func__, __LINE__, object);
    }
    return json_data;
}

+ (NSString *)createJsonString:(id)object
{
    NSData *data = [self createJsonData:object];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)toJsonString
{
    NSString *json_str = nil;
    if (nil == json) {
        variableNotInitialized;
    } else {
        json_str = [JsonObject createJsonString:json];
    }
    return json_str;
}

@end
