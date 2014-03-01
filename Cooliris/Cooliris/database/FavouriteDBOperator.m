//
//  FavouriteDBOperator.m
//  Cooliris
//
//  Created by user on 13-6-13.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "FavouriteDBOperator.h"
#import "Image.h"
#import "Macro.h"
#import "FMDatabase.h"

static const NSString *tempColumn[] =
{
    kFavouriteColumnAutoId,
    kFavouriteColumnUrl,
    kFavouriteColumnKeyword,
    kFavouriteColumnTime
};

@implementation FavouriteDBOperator

- (id)initWithName:(NSString *)strDBName nDBVersion:(int)nDBVersion
{
    self = [super init];
    if (nil != self) {
        if (nDBVersion < 1) {
            nDBVersion =  1;
        }
        favouriteHelper = [[FavouriteOpenHelper alloc]initWithName:strDBName nDBVersion:nDBVersion];
        if (nil != favouriteHelper) {
            [favouriteHelper getDatabase];
            
            tempImage = nil;
        }
    }
    return self;
}

- (NSArray *)getAllFavourite
{
    __block NSMutableArray *allFavourite = [[NSMutableArray alloc] init];
    
    [favouriteHelper inDatabase:^(FMDatabase *db){
        FMResultSet *cursor;
        @try {
            cursor = [db executeQueryWithTable:kTableFavourite
                                   withColumns:tempColumn
                               withColumnCount:_countof(tempColumn)
                                 withSelection:nil
                             withSelectionArgs:nil
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:kFavouriteColumnAutoId
                                     withLimit:nil];
            if (nil != cursor) {
                while ([cursor next]) {
                    MosaicData *image  = [[MosaicData alloc] init];
                    image.imageFilename     = [cursor stringForColumn:kFavouriteColumnUrl];
                    [allFavourite addObject:image];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            [cursor close];
        }
    }];
    
    return allFavourite;
}

- (BOOL)insertFavourite:(MosaicData *)image
{
    return [self insertToFavourite:image withKeyword:@""];
}

- (BOOL)insertToFavourite:(MosaicData *)image withKeyword:(NSString *)keyword
{
    __block BOOL result = NO;
    if (nil == tempImage) {
        tempImage = [[NSMutableDictionary alloc] init];
    }
    [tempImage setObject:image.imageFilename forKey:kFavouriteColumnUrl];
    [tempImage setObject:keyword forKey:kFavouriteColumnKeyword];
    long time = [[NSDate date] timeIntervalSince1970];
    [tempImage setObject:[NSNumber numberWithLong:time] forKey:kFavouriteColumnTime];
    
    [favouriteHelper inDatabase:^(FMDatabase *db) {
        //        FMResultSet *cursor;
        
        @try {
            if([db insertWithOnConflictTableName:kTableFavourite
                              withNULLColumnHack:nil
                                      withValues:tempImage
                                    withConflict:CONFLICT_IGNORE]) {
                result = YES;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            //            [self closeCursor:cursor];
        }
    }];
    
    return result;
}

- (NSArray *)getFavouriteByKeyword:(NSString *)keyword
{
    NSString *key = keyword;
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [sql appendFormat:@" %@ = '%@'",kFavouriteColumnKeyword,key];
    
    [favouriteHelper inDatabase:^(FMDatabase *db) {
        FMResultSet *cursor;
        
        @try {
            cursor = [db executeQueryWithTable:kTableFavourite
                                   withColumns:tempColumn
                               withColumnCount:_countof(tempColumn)
                                 withSelection:sql
                             withSelectionArgs:nil
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:kFavouriteColumnAutoId
                                     withLimit:nil];
            
            if (nil != cursor) {
                while ([cursor next]) {
                    MosaicData *img   = [[MosaicData alloc] init];
                    img.imageFilename     = [cursor stringForColumn:kFavouriteColumnUrl];
                    [array addObject:img];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            [cursor close];
        }
    }];
    
    return array;
}

- (NSArray *)getAllFavouriteByRange:(NSRange)range
{
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@" %@ > %d and %@ < %d",kFavouriteColumnAutoId,
     range.location,kFavouriteColumnAutoId,(range.location + range.length - 1)];
    
    [favouriteHelper inDatabase:^(FMDatabase *db) {
        FMResultSet *cursor;
        @try {
            cursor = [db executeQueryWithTable:kTableFavourite
                                   withColumns:tempColumn
                               withColumnCount:_countof(tempColumn)
                                 withSelection:sql
                             withSelectionArgs:nil
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:kFavouriteColumnAutoId
                                     withLimit:nil];
            
            if (nil != cursor) {
                while ([cursor next]) {
                    MosaicData *img   = [[MosaicData alloc] init];
                    img.imageFilename     = [cursor stringForColumn:kFavouriteColumnUrl];
                    [array addObject:img];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            [cursor close];
        }
        
    }];
    
    return array;
}

- (int)getFavouriteCount
{
    __block int count = 0;
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"select * from %@",kTableFavourite];
    
    [favouriteHelper inDatabase:^(FMDatabase *db) {
        FMResultSet *cursor;
        
        @try {
            cursor = [db executeQuery:sql];
            
            if (nil != cursor) {
                while ([cursor next]) {
                    //Don't know why always return 1
//                    count = [cursor columnCount];
                    count++;
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            [cursor close];
        }
        
    }];
    
    return count;
}

- (BOOL)deleteFromFavouriteByUrl:(NSString *)url
{
    NSString *deleteUrl = url;
    __block BOOL result = NO;
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"delete from %@ where %@ = '%@' ",kTableFavourite,kFavouriteColumnUrl,deleteUrl];
    
    [favouriteHelper inDatabase:^(FMDatabase *db) {
       
        @try {
            if ([db executeUpdate:sql]) {
                result = YES;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
    }];
    
    return result;
}

- (BOOL)deleteFromFavourite:(MosaicData *)image
{
    return [self deleteFromFavouriteByUrl:image.imageFilename];
}

- (BOOL)isKeywordBeSearched:(NSString *)keyword
{
    __block BOOL result = NO;
    __block int  count  = 0 ;
    NSString *key = keyword;
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"select * from %@ ",kTableFavourite];
    [sql appendFormat:@"where %@ = '%@' ",kFavouriteColumnKeyword,key];
    
    [favouriteHelper inDatabase:^(FMDatabase *db) {
        FMResultSet *cursor;
        
        @try {
            cursor = [db executeQuery:sql];
            
            if (nil != cursor) {
                while ([cursor next]) {
                    //Don't know why always return 1
//                    count = [cursor columnCount];
                    count++;
                }
            result = (count > 0) ? YES : NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            [cursor close];
        }
    }];
    
    return result;
}

- (BOOL)netUrlIsFavourite:(NSString *)url
{
    __block BOOL isFavourite = NO;
    NSString *tempUrl = url;
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@" %@ = '%@' ",kFavouriteColumnUrl,tempUrl];
    
    [favouriteHelper inDatabase:^(FMDatabase *db) {
       
        FMResultSet *cursor;
        @try {
            cursor = [db executeQueryWithTable:kTableFavourite
                                   withColumns:tempColumn
                               withColumnCount:_countof(tempColumn)
                                 withSelection:sql
                             withSelectionArgs:nil
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:kFavouriteColumnAutoId
                                     withLimit:nil];
            if (nil != cursor) {
                int count = 0;
                while ([cursor next]) {
                    count++;
                }
                isFavourite = (count > 0) ? YES : NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            [cursor close];
        }
    }];
    
    return isFavourite;
}

- (BOOL)netImageIsFavourite:(MosaicData *)image
{
    return [self netUrlIsFavourite:image.imageFilename];
}

@end
