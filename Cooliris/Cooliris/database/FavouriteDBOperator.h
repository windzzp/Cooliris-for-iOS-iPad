//
//  FavouriteDBOperator.h
//  Cooliris
//
//  Created by user on 13-6-13.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavouriteOpenHelper.h"
#import "MosaicData.h"

#define kFavouriteDBName    @"favourite"
#define kFavouriteDBVersion 1

@interface FavouriteDBOperator : NSObject

{
    FavouriteOpenHelper *favouriteHelper;
    NSMutableDictionary *tempImage;
}

- (id)initWithName:(NSString *)strDBName nDBVersion:(int)nDBVersion;
//+ (FavouriteDBOperator *)shareInstance;
- (NSArray *)getAllFavourite;
- (NSArray *)getFavouriteByKeyword:(NSString *)keyword;
- (NSArray *)getAllFavouriteByRange:(NSRange)range;
- (BOOL)insertFavourite:(MosaicData *)image;
- (BOOL)insertToFavourite:(MosaicData *)image withKeyword:(NSString *)keyword;
- (int)getFavouriteCount;
- (BOOL)deleteFromFavourite:(MosaicData *)image;
- (BOOL)deleteFromFavouriteByUrl:(NSString *)url;
- (BOOL)isKeywordBeSearched:(NSString *)keyword;
- (BOOL)netUrlIsFavourite:(NSString *)url;
- (BOOL)netImageIsFavourite:(MosaicData *)image;

@end
