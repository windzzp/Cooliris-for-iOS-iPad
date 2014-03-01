//
//  FavouriteOpenHelper.h
//  Cooliris
//
//  Created by user on 13-6-13.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "SQLiteOpenHelper.h"

#define kTableFavourite     @"Favourite"

#define kFavouriteColumnAutoId     @"id"
#define kFavouriteColumnUrl        @"url"
#define kFavouriteColumnKeyword    @"keyword"
#define kFavouriteColumnTime       @"date"

@interface FavouriteOpenHelper : SQLiteOpenHelper


@end
