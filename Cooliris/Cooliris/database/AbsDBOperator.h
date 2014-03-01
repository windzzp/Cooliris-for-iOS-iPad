/*
 *  DBHelper.h
 *  This file defines a database class to help managing ROVI database. 
 *
 *  Created by Lzt-yangfan on 2012/12/20.
 *  Copyright (C) 2011, TOSHIBA Corporation.
 *
 */

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "SQLiteOpenHelper.h"

/**
 * The type index of DB.
 */
#define DBHelper_AGGREGATE_DB                        0
#define DBHelper_PROGRAMDETAILS_DB                   1
#define DBHelper_REMIND_DB                           2
#define DBHelper_FAVORITE_DB                         3
#define DBHelper_COLOR_DB                            4
#define DBHelper_CHANNEL_CATEGORY_DB                 5
#define DBHelper_IR_BLASTER_DB                       6
#define DBHelper_RECORDING_DB                        7
#define DBHelper_TEMP_DB                             8

@interface AbsDBOperator : NSObject

@property (strong, nonatomic, readonly) SQLiteOpenHelper *dbHelper;

/**
 * Initialize the specified database with specified name and version.
 *
 * @param dbName    The specified database name.
 * @param dbVersion The specified database version.
 *
 * @return The database operation instance.
 */
- (id)initWithName:(NSString *)dbName version:(int)dbVersion;

/**
 * Establish the Database.
 */
- (void)establishDB;

/**
 * Close the database and finish the complement job.
 */
- (void)closeDB;

/**
 * Closes the Cursor, releasing all of its resources and making it completely invalid.
 * Unlike {@link #deactivate()} a call to {@link #requery()} will not make the Cursor valid
 * again.
 */
- (void)closeCursor:(FMResultSet*) cursor;

@end
