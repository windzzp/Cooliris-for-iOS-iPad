//
//  ImageTable.m
//  Cooliris
//
//  Created by user on 13-6-3.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "ImageDBOperator.h"
#import "ImageGroup.h"
#import "Image.h"
#import "Macro.h"

#define kImageDBName    @"sudasuta.db"
#define kImageDBVersion 1

#define kTableArticles  @"Articles"
#define kTableImages    @"Images"

/* 1. Table Articles */
// TODO: TBD
//static const NSString* kImageGroupColumnId = @"id";
//#define kImageGroupColumnId             @"_id"      // Column:0
//#define kImageGroupColumnContent        @"content"  // Column:1
//#define kImageGroupColumnCategory       @"category" // Column:2 TODO: catagory name is wrong-->category
//#define kImageGroupColumnTime           @"time"     // Column:3
//#define kImageGroupColumnTitle          @"title"    // Column:4
//#define kImageGroupColumnTags           @"tag"      // Column:7
//#define kImageGroupColumnHomepageUrl    @"uri"      // Column:11
//#define kImageGroupColumnPrevious       @"previous" // Column:5
//#define kImageGroupColumnNext           @"next"     // Column:8
//#define kImageGroupColumnCoverUrl       @"cover"
//#define kImageGroupColumnDescription    @"description"
//#define kImageGroupColumnBlog       @"blog"     // Column:10

#define kImageGroupColumnId             @"_id"
//#define kImageGroupColumnContent        @"content"
#define kImageGroupColumnCategory       @"category"
#define kImageGroupColumnTime           @"time"
#define kImageGroupColumnTitle          @"title"
#define kImageGroupColumnTags           @"tag"
#define kImageGroupColumnHomepageUrl    @"uri"
/* [Delete] Fix EUIOS-128 [Author: huyong] 2013-04-17 17:40 ---> */
// Replace by New DB delete the old column.
//#define kImageGroupColumnPrevious       @"previous"
//#define kImageGroupColumnNext           @"next"
/* <--- [Delete] Fix EUIOS-128 */
#define kImageGroupColumnCoverUrl       @"cover"
#define kImageGroupColumnDescription    @"description"

#define kImageGroupColumnIdIx           0
#define kImageGroupColumnCategoryIx     2
#define kImageGroupColumnTimeIx         3
#define kImageGroupColumnTitleIx        4
#define kImageGroupColumnTagsIx         7
#define kImageGroupColumnUrlIx          11
/* [Delete] Fix EUIOS-128 [Author: huyong] 2013-04-17 17:40 ---> */
// Replace by New DB delete the old column.
//#define kImageGroupColumnContentIx      1
//#define kImageGroupColumnPreviousIx     5
//#define kImageGroupColumnNextIx         8
/* <--- [Delete] Fix EUIOS-128 */
#define kImageGroupColumnCoverUrlIx
#define kImageGroupColumnDescriptionIx

//#define kImageGroupColumnBlogIx     10

static const NSString* kImageGroupColumns[] = {
    kImageGroupColumnId,
    kImageGroupColumnCategory,
    kImageGroupColumnTime,
    kImageGroupColumnTitle,
    kImageGroupColumnTags,
    kImageGroupColumnHomepageUrl,
    /* [Delete] Fix EUIOS-128 [Author: huyong] 2013-04-17 17:40 ---> */
    // Replace by New DB delete the old column.
    //kImageGroupColumnPrevious,
    //kImageGroupColumnNext,
    //kImageGroupColumnContent,
    /* <--- [Delete] Fix EUIOS-128 */
    kImageGroupColumnCoverUrl,
    kImageGroupColumnDescription
    //kImageGroupColumnBlog
};

/* 2. Table Images */
// TODO: TBD
//static const NSString* kImageGroupColumnId = @"id";
#define kImagesColumnId             @"_id"      // Column:0
#define kImagesColumnGroupId        @"article"  // Column:1
#define kImagesColumnGuid           @"offline_name"     // Column:2
#define kImagesColumnUrl            @"src"      // Column:10
#define kImagesColumnIsFavorite     @"is_favorite"
// TODO:
//#define kArticlesColumnThumbUrl     @"thumburl"

#define kImagesColumnIdIx           0
#define kImagesColumnActicleIdIx    1
#define kImagesColumnGuidIx         2
#define kImagesColumnUrlIx          10

static const NSString* kImageColumns[] = {
    kImagesColumnId,
    kImagesColumnGroupId,
    //kImagesColumnGuid,
    kImagesColumnUrl,
    kImagesColumnIsFavorite
};

@interface ImageDBOperator ()

- (id)initWithName:(NSString *)dbName version:(int)dbVersion;
- (void)fillImageGroupInfo:(FMResultSet *)cursor intoGroup:(ImageGroup *)group;
- (void)fillImageInfo:(FMResultSet *)cursor intoImage:(Image *)image;

@end

@implementation ImageDBOperator

+ (ImageDBOperator *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        //_sharedObject = [[self alloc] init]; // or some other init method
        _sharedObject = [[self alloc] initWithName:kImageDBName version:kImageDBVersion];
    });
    
    return _sharedObject;
}

- (id)initWithName:(NSString *)dbName version:(int)dbVersion
{
    self = [super initWithName:dbName version:dbVersion];
    if (self) {
        // Custom initialize
    }
    return self;
}


- (NSArray *)getAllGroupIds:(NSString *)withCategory;
{
    NSLog(@"getAllGroupIds with category = %@", withCategory);
    __block NSMutableArray *groupIds = [@[] mutableCopy];
    
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        
        FMResultSet *cursor;
        @try {
            //NSString *sql = @"select * from Articles where category like % 'abc'";
            //cursor = [db executeQuery:sql];
            
            NSString *selection = nil;
            NSArray  *selectionArgs = nil;
            
            if (withCategory) {
                NSMutableString *tempCategory = [[NSMutableString alloc] init];
                [tempCategory appendString:@"%"];
                [tempCategory appendFormat:@"%@", withCategory];
                [tempCategory appendString:@"%"];

                selection = @"category like ?";
                selectionArgs = @[tempCategory];
            }

            NSString *columns[] = { kImageGroupColumnId };
            cursor = [db executeQueryWithTable:kTableArticles
                                   withColumns:columns
                               withColumnCount:_countof(columns)
                                 withSelection:selection
                             withSelectionArgs:selectionArgs
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:nil
                                     withLimit:nil];
            
            if (cursor) {
                while ([cursor next]) {
                    // Add it into group list
                    int groupId = [cursor intForColumn:kImageGroupColumnId];
                    [groupIds addObject:[NSNumber numberWithInt:groupId]];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            //[cursor close];
            [self closeCursor:cursor];
        }
    }];
    
    return groupIds;
}

- (NSArray *)getGroupsBy:(NSRange)range
{
    __block NSMutableArray *groups = [@[] mutableCopy];
    
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        
        FMResultSet *cursor;
        @try {
            // select * from Articles where _id >= (start:1) and _id <= (end:5)
            NSString *selection = [NSString stringWithFormat:@"_id >= ? and _id <= ?"];
            NSArray  *selectionArgs = @[[NSNumber numberWithInt:range.location],
                                        [NSNumber numberWithInt:range.location + range.length - 1]];
            cursor = [db executeQueryWithTable:kTableArticles
                                   withColumns:kImageGroupColumns
                               withColumnCount:_countof(kImageGroupColumns)
                                 withSelection:selection
                             withSelectionArgs:selectionArgs
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:nil
                                     withLimit:nil];
            
            if (cursor) {
                while ([cursor next]) {
                    
                    // Fill image group data
                    ImageGroup *group = [[ImageGroup alloc] init];
                    [self fillImageGroupInfo:cursor intoGroup:group];
                    
                    // Add it into group list
                    [groups addObject:group];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            //[cursor close];
            [self closeCursor:cursor];
        }
    }];
    
    return groups;
}

- (NSArray *)getGroupsWith:(NSArray *)ids
{
    if (!ids || 0 == ids.count) {
        NSLog(@"ids is empty!");
        return nil;
    }
    
    __block NSMutableArray *groups = [@[] mutableCopy];
    
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        
        FMResultSet *cursor;
        @try {
            // select * from Articles where _id IN (1,3,4,5)
            
            // Get the range string           
            NSMutableString *range = [[NSMutableString alloc] init];
            int count = ids.count;
            [range appendString:@"("];
            
            for (int ix = 0; ix < count; ++ix) {
                [range appendString:[ids[ix] stringValue]];
                if ((count - 1) != ix) {
                    [range appendString:@","];
                }
            }
            [range appendString:@")"];

            NSString *sql = [NSString stringWithFormat:@"select * from Articles where _id IN %@", range];
            cursor = [db executeQuery:sql];
            
            /*
            NSString *selection = [NSString stringWithFormat:@"_id IN "];
            NSArray  *selectionArgs = @[range];
            cursor = [db executeQueryWithTable:kTableArticles
                                   withColumns:kImageGroupColumns
                               withColumnCount:_countof(kImageGroupColumns)
                                 withSelection:selection
                             withSelectionArgs:selectionArgs
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:nil
                                     withLimit:nil];
             */
            
            if (cursor) {
                while ([cursor next]) {
                    
                    // Fill image group data
                    ImageGroup *group = [[ImageGroup alloc] init];
                    [self fillImageGroupInfo:cursor intoGroup:group];
                    
                    // Add it into group list
                    [groups addObject:group];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            //[cursor close];
            [self closeCursor:cursor];
        }
    }];
    
    return groups;
}

- (NSArray *)getImagesBy:(int)groupId
{
    __block NSMutableArray *images = [@[] mutableCopy];
    
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        
        FMResultSet *cursor;
        @try {
            // select * from Images where acticle = (groupId)
            //NSString *sql = [NSString stringWithFormat:@"select * from Images where article = %d", groupId];
            //cursor = [db executeQuery:sql];
            NSString *selection = [NSString stringWithFormat:@"%@ = ?", kImagesColumnGroupId];
            NSArray  *selectionArgs = @[[NSNumber numberWithInt:groupId]];
            cursor = [db executeQueryWithTable:kTableImages
                                   withColumns:kImageColumns
                               withColumnCount:_countof(kImageColumns)
                                 withSelection:selection
                             withSelectionArgs:selectionArgs
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:nil
                                     withLimit:nil];
            
            if (cursor) {
                while ([cursor next]) {
                    
                    // Fill image data
                    Image *image = [[Image alloc] init];
                    [self fillImageInfo:cursor intoImage:image];
                    
                    // Add it into group list
                    [images addObject:image];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            //[cursor close];
            [self closeCursor:cursor];
        }
    }];

    return images;
}

- (void)fillImage:(ImageGroup *)imageGroup
{
    if (!imageGroup) {
        NSLog(@"Invalid param");
        return;
    }
    
    // Get the image and set the image's parent
    imageGroup.images = [self getImagesBy:imageGroup.groupId];
    for (Image *image in imageGroup.images) {
        image.parentGroup = imageGroup;
    }
}

- (BOOL)updateFavoriteImage:(Image *)image
{
    __block BOOL result = NO;
    Image *updateImage = image;
    int favourite = (!updateImage.isFavorite) ? 1 : 0;
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"update %@ set %@ = %d",kTableImages,kImagesColumnIsFavorite,favourite];
    [sql appendFormat:@" where %@ = '%@'",kImagesColumnUrl,updateImage.url];
    
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql] ? YES : NO;
    }];
    
    return result;
}

- (void)updateFavoriteGroup:(ImageGroup *)imageGroup
{
    
}

#pragma mark - Private methods

- (void)fillImageGroupInfo:(FMResultSet *)cursor intoGroup:(ImageGroup *)group
{
    if (!cursor || !group) {
        return;
    }
    
    group.groupId     = [cursor intForColumn:kImageGroupColumnId];
    group.title       = [cursor stringForColumn:kImageGroupColumnTitle];
    group.description = [cursor stringForColumn:kImageGroupColumnDescription];
    group.time        = [cursor stringForColumn:kImageGroupColumnTime];
    group.coverUrl    = [cursor stringForColumn:kImageGroupColumnCoverUrl];
    group.homePageUrl = [cursor stringForColumn:kImageGroupColumnHomepageUrl];
    
    group.categories  = [cursor stringForColumn:kImageGroupColumnCategory];
    group.tags        = [cursor stringForColumn:kImageGroupColumnTags];
}

- (void)fillImageInfo:(FMResultSet *)cursor intoImage:(Image *)image
{
    image.imageId    = [cursor intForColumn:kImagesColumnId];
    //image.url      = [cursor stringForColumnIndex:kImagesColumnUrlIx];
    image.url        = [cursor stringForColumn:kImagesColumnUrl];
    image.isFavorite =  (1 == [cursor intForColumn:kImagesColumnIsFavorite]) ? YES : NO;
}

- (NSArray *)getArticlesIdByTag:(NSString *)tag
{
    __block NSMutableArray * tagGroups = nil;
    
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        FMResultSet *cursor;
        @try {
            NSString *selection = [NSString stringWithFormat:@" %@ like '%%%@%%'",kImageGroupColumnTags,tag];
            
            cursor = [db executeQueryWithTable:kTableArticles
                                   withColumns:kImageGroupColumns
                               withColumnCount:_countof(kImageGroupColumns)
                                 withSelection:selection
                             withSelectionArgs:nil
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:kImageGroupColumnId
                                     withLimit:nil];
            if (nil != cursor) {
                tagGroups = [[NSMutableArray alloc] init];
                
                while ([cursor next]) {
                    [tagGroups addObject: [NSNumber numberWithInt:[cursor intForColumn:kImageGroupColumnId]]];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            [self closeCursor:cursor];
        }
    }];
    
    return tagGroups;
}

- (NSArray *)getAllLocalFavourite
{
    __block NSMutableArray *allFavourite = [[NSMutableArray alloc] init];
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        FMResultSet *cursor;
        @try {
            NSString *selection = [NSString stringWithFormat:@" %@ = %d ",kImagesColumnIsFavorite,1];
            
            cursor = [db executeQueryWithTable:kTableImages
                                   withColumns:kImageColumns
                               withColumnCount:_countof(kImageColumns)
                                 withSelection:selection
                             withSelectionArgs:nil
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:nil
                                     withLimit:nil];
            if (nil != cursor) {
                while ([cursor next]) {
                    Image *image = [[Image alloc] init];
                    [self fillImageInfo:cursor intoImage:image];
                    [allFavourite addObject:image];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            [self closeCursor:cursor];
        }
    }];
    
    return allFavourite;
}

@end
