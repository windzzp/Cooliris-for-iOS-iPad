/*
 *  SQLiteOpenHelper.h
 *   This file defines SQLiteOpenHelper class which contains SQL property. 
 *
 *  Created by lzt-Jiaochunxiang on 2012/12/25.
 *  Copyright (c) 2012年  . All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@interface SQLiteOpenHelper : NSObject
{
@protected
    /**
     * The database queue to manager the synchronized db operation.
     */
    FMDatabaseQueue *databaseQueue;
    
    /**
     * The database name.
     */
    NSString *datebaseName;
    
    /**
     * The database version.
     */
    int newVersion;
}

- (id) initWithName:(NSString *) strDBName nDBVersion:(int) nDBVersion;

/**
 * Get the data base.
 */
- (void)getDatabase;

/**
 * Close db.
 */
- (void)close;

/**
 * Operate db in nomal synchronized way.
 *
 * @param block  the db operation block to be operated.
 */
- (void)inDatabase:(void (^)(FMDatabase *db))block;

/**
 * Operate db in thransaction.
 *
 * @param block  the db operation block to be operated.
 */
- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

/**
 * Operate db in defered thransaction.
 *
 * @param block  the db operation block to be operated.
 */
- (void)inDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

/**
 * Call this method when it starts to create the db.
 */
- (void)onCreate:(FMDatabase*) db;

/**
 * Call this method when it starts to open the db.
 */
- (void)onOpen:(FMDatabase*) db;

/**
 * Call this method when it starts to upgrade the db.
 */
- (void)onUpgrade:(FMDatabase*)db;

/**
 * Call this method when it starts to downgrade the db.
 */
- (void)onDowngrade:(FMDatabase*)db;

@end
