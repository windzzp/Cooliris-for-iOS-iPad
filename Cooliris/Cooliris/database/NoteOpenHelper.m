//
//  NoteOpenHelper.m
//  Cooliris
//
//  Created by user on 13-5-23.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "NoteOpenHelper.h"
#import "FMDatabase.h"

@interface NoteOpenHelper (private)

- (void)createNoteTable:(FMDatabase *)db;
- (void)dropNoteTable:(FMDatabase *)db;
/*
 -(void)createXXXTable:(FMDatabase *)db;
 -(void)dropXXTable:(FMDatabase *)db;
 ...
 */
@end

@implementation NoteOpenHelper

- (id)initWithName:(NSString *)strDBName nDBVersion:(int)nDBVersion
{
    self = [super init];
    if (nil != self) {
        datebaseName = strDBName;
        newVersion   = nDBVersion;
    }
    return self;
};

- (void)onCreate:(FMDatabase *)db
{
    [super onCreate:db];
    [self createNoteTable:db];
}

- (void)onOpen:(FMDatabase *)db
{
    [super onOpen:db];
    [databaseQueue inDatabase:^(FMDatabase *db) {
         [db executeUpdate:@"PRAGMA foreign_keys=ON"];
     }];
}

- (void)onUpgrade:(FMDatabase *)db
{
    [super onUpgrade:db];
    [self dropNoteTable:db];
}

- (void)onDowngrade:(FMDatabase *)db
{
    [super onDowngrade:db];
    [self onUpgrade:db];
}

- (void)createNoteTable:(FMDatabase *)db
{
    NSMutableString *sqlString = [[NSMutableString alloc] init];
    [sqlString appendFormat:@"CREATE TABLE IF NOT EXISTS %@(", NoteOpenHelper_Note_Table_Name];
    [sqlString appendFormat:@"%@ INTEGER PRIMARY KEY,", NoteOpenHelper_Note_TableColumns_Time];
    [sqlString appendFormat:@"%@ INTEGER,", NoteOpenHelper_Note_TableColumns_Type];
    [sqlString appendFormat:@"%@ TEXT", NoteOpenHelper_Note_TableColumns_Content];
//    [sqlString appendFormat:@"%@ TEXT,", NoteOpenHelper_Note_TableColumns_Fallback_1];
//    [sqlString appendFormat:@"%@ TEXT", NoteOpenHelper_Note_TableColumns_Fallback_2];
    [sqlString appendFormat:@");"];
    
//    ;
    if ([db executeUpdate:sqlString]) {
        NSLog(@"create table success .....");
    }
}

- (void)dropNoteTable:(FMDatabase *)db
{
    NSString *strSQL = [[NSString alloc] initWithFormat:@"DROP TABLE IF EXISTS %@",NoteOpenHelper_Note_Table_Name];
    [db executeUpdate:strSQL];
}

@end
