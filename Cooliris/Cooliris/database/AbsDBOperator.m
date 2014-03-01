/*
 *  DBHelper.m
 *  This file defines a database class to help managing ROVI database. 
 *
 *  Created by Lzt-yangfan on 2012/12/20.
 *  Copyright (C) 2011, TOSHIBA Corporation.
 *
 */

#import "SQLiteOpenHelper.h"
#import "AbsDBOperator.h"

@interface AbsDBOperator ()

@property (strong, nonatomic, readwrite) SQLiteOpenHelper *dbHelper;

@end

@implementation AbsDBOperator

- (id)initWithName:(NSString *)dbName version:(int)dbVersion
{
    self = [super init];
    if (self) {
        // Initialize DB helper
        if (nil == self.dbHelper) {
            self.dbHelper = [[SQLiteOpenHelper alloc] initWithName:dbName nDBVersion:dbVersion];
            [self establishDB];
        }
    }
    return self;
}

- (void)closeDB
{
    [self.dbHelper close];
    self.dbHelper = nil;
}

/**
 * Establish the Database.
 */
- (void)establishDB
{
    if(_dbHelper) {
        [_dbHelper getDatabase];
    }
}

/**
 * Closes the Cursor, releasing all of its resources and making it completely invalid.
 * Unlike {@link #deactivate()} a call to {@link #requery()} will not make the Cursor valid
 * again.
 */
-(void) closeCursor:(FMResultSet*) cursor
{
    if(nil != cursor) {
        [cursor close];
        cursor = nil;
    } else {
        NSLog(@"NOTE: cursor is null!!!");
    }
}

@end
