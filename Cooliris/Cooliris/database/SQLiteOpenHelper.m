/*
 *  SQLiteOpenHelper.m
 *   This file defines SQLiteOpenHelper class which contains SQL property. 
 *
 *  Created by lzt-Jiaochunxiang on 2012/12/25.
 *  Copyright (c) 2012年. All rights reserved.
 */

#import "SQLiteOpenHelper.h"
#import "FMDatabase.h"
#define TAG @"SQLiteOpenHelper"


@interface SQLiteOpenHelper (Private)

/**
 * Create new db with the given path.
 *
 * @param dbPath the db path.
 */
- (void)createNewDBWithPath:(NSString*)dbPath;

/**
 * Upgrage or downgrage db with the given path.
 *
 * @param dbPath the db path.
 */
- (void)upOrDowngrageDBWithPath:(NSString*)dbPath;

@end 
@implementation SQLiteOpenHelper

- (id) initWithName:(NSString *) strDBName nDBVersion:(int) nDBVersion
{
    self = [super init];
    if (nil != self) {
        if (nil != strDBName ) {
            datebaseName = strDBName;
            newVersion = nDBVersion;
        }
    }

    return self;
}

- (void) getDatabase
{
    if (nil != databaseQueue) {
        return;
    }
    
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbpath = [docsdir stringByAppendingPathComponent:datebaseName];
    NSLog(@"%s:%s(%d) getDatabase %@",__FILE__,__func__,__LINE__,datebaseName);
    if ([fm fileExistsAtPath:dbpath]) {
        NSLog(@"%s: %s(%d) The %@ file exists.",__FILE__,__func__,__LINE__,dbpath);
        [self upOrDowngrageDBWithPath:dbpath];
    } else {
        NSLog(@"%s: %s(%d) The %@ file doesn't exists.",__FILE__,__func__,__LINE__,dbpath);
        [self createNewDBWithPath:dbpath];
    }
}

- (void)close
{
    if (nil == databaseQueue) {
        return;
    }
    
    [databaseQueue close];
}

- (void)inDatabase:(void (^)(FMDatabase *db))block
{
    if (nil == databaseQueue) {
        return;
    }
    
    [databaseQueue inDatabase:block];
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block
{
    if (nil == databaseQueue) {
        return;
    }
    
    [databaseQueue inTransaction:block];
}

- (void)inDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block
{
    if (nil == databaseQueue) {
        return;
    }
    
    [databaseQueue inDeferredTransaction:block];
}


- (void)onCreate:(FMDatabase*) db
{
    /*
      call all of your create table methods in subclass.
      a simple code in subclass :
     
     [self createXXXTable_1:db];
     [self createXXXTable_2:db];
     ...
     */
}

- (void)onOpen:(FMDatabase*) db
{
    /*  
     a simple code in subclass:
     
     [super onOpen:db];
     
     [m_databaseQueue inDatabase:^(FMDatabase *db)
     {
     [db executeUpdate:@"PRAGMA foreign_keys=ON"];
     }];
     
     */
}

- (void)onUpgrade:(FMDatabase*)db
{
    /*
     1. call all of drop table methods in your subclass.
        a simple code in subclass:
        [self dropXXXTable_1:db];
        [self dropXXXTable_2:db];
        ...
     
     2. call onCreate:  to create your new tables.
        a simple code in subclass:
        [self onCreate:db];
     */
}

- (void)onDowngrade:(FMDatabase*)db
{
    /*
      usurally call onUpgrade: method.
     a simple code in subclass:
     
     [self onUpgrade:db];
     */
}

- (void)createNewDBWithPath:(NSString*)dbPath
{
    databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    if (databaseQueue != nil) {
        __block FMDatabase * tempDb;
        NSLog(@"%s: %s(%d) Create Database success.",__FILE__,__func__,__LINE__);
        // Set Version
        [databaseQueue inDatabase:^(FMDatabase *db) 
         {
             tempDb = db;
             NSString* setversionString = [[NSString alloc] initWithFormat:@"PRAGMA user_version = %d", newVersion]; 
             BOOL bResult = [db executeUpdate:setversionString];
             if (bResult) {
                NSLog(@"%s: %s(%d) Set Databse Version success version=%d",__FILE__,__func__,__LINE__,newVersion);
             } else {
                 NSLog(@"%s: %s(%d) Set DataBse Version failed.",__FILE__,__func__,__LINE__);
             }
         }];
        
        [self onOpen:tempDb];
        [self onCreate:tempDb];
    }
}

- (void)upOrDowngrageDBWithPath:(NSString*)dbPath
{
    databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    if (databaseQueue != nil) {
        __block FMDatabase * tempDb;
        NSLog(@"%s: %s(%d) Open DataBase success.",__FILE__,__func__,__LINE__);
        __block long nOldVersion = -1;
        __block BOOL bResult = NO;
        [databaseQueue inDatabase:^(FMDatabase *db) 
         {
             tempDb = db;
             NSString* readVersionString = @"PRAGMA user_version";
             FMResultSet *cursor = [db executeQuery:readVersionString];
             
             if (cursor != nil) {
                 if ([cursor next]) {
                     nOldVersion = [cursor longForColumn:@"user_version"];
                 }
                 [cursor close];
             }
             NSLog(@"%s: %s(%d) Get DataBase old Version=%li, new version=%d",__FILE__,__func__,__LINE__,nOldVersion,newVersion);
             if (nOldVersion != -1 && nOldVersion != newVersion) {
                 NSString* setversionString =
                 [[NSString alloc] initWithFormat:@"PRAGMA user_version = %d", newVersion];
                 
                 bResult = [db executeUpdate:setversionString];
             } else {
                 bResult = YES;
             }
         }];
        
        if (bResult) {
            NSLog(@"%s: %s(%d) Set Databse Version success version=%d",__FILE__,__func__,__LINE__,newVersion);
            [self onOpen:tempDb];
            if (nOldVersion < newVersion) {
                [self onUpgrade:tempDb];
                NSLog(@"%s: %s(%d) Upgrade.",__FILE__,__func__,__LINE__);
            } else if(nOldVersion > newVersion) {
                [self onDowngrade:tempDb];
                NSLog(@"%s: %s(%d) onDowngrade.",__FILE__,__func__,__LINE__);
            }
        } else {
            NSLog(@"%s: %s(%d) Set Database version failed.",__FILE__,__func__,__LINE__);
        }
    }
}

@end
