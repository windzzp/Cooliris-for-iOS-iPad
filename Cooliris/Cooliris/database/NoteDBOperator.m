//
//  NoteDBOperator.m
//  Cooliris
//
//  Created by user on 13-5-23.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "NoteDBOperator.h"
#import "FMDatabase.h"
#import "UncaughtExceptionHandler.h"

#ifndef _countof
#define _countof(array) (sizeof(array)/sizeof(*array))
#endif

static const NSString * tempColumns[] =
{
    NoteOpenHelper_Note_TableColumns_Time ,
    NoteOpenHelper_Note_TableColumns_Type,
    NoteOpenHelper_Note_TableColumns_Content,
};

@implementation NoteDBOperator

- (id)initWithName:(NSString *)strDBName nDBVersion:(int)nDBVersion
{
    self = [super init];
    if (nil != self) {
        if (nDBVersion < 1) {
            nDBVersion =  1;
             }
            noteDBHelper = [[NoteOpenHelper alloc]initWithName:strDBName nDBVersion:nDBVersion];
            if (nil != noteDBHelper) {
                [noteDBHelper getDatabase];
           
            note = nil;
        }
    }
    return self;
}

- (int)insertNoteWithTime:(long)time with:(int)type with:(const NSString *)content
{
    __block int result = 0;
    
    [noteDBHelper inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (nil == note) {
            note = [[NSMutableDictionary alloc] init];
        }
        
        [note setObject:[NSNumber numberWithLong:time] forKey:NoteOpenHelper_Note_TableColumns_Time];
        [note setObject:[NSNumber numberWithInt:type]  forKey:NoteOpenHelper_Note_TableColumns_Type];
        [note setObject:content forKey:NoteOpenHelper_Note_TableColumns_Content];
        
        if ([db insertWithOnConflictTableName:NoteOpenHelper_Note_Table_Name
                           withNULLColumnHack:nil
                                   withValues:note
                                 withConflict:CONFLICT_REPLACE])
            result =1;
    }];
    return result;
}

- (BOOL)delNotes
{
    __block BOOL result = NO;
    [noteDBHelper inDatabase:^(FMDatabase *db) {
        NSString * strSQL = [[NSString alloc] initWithFormat:@"delete from %@", NoteOpenHelper_Note_Table_Name];
        if ([db executeUpdate:strSQL])
            result = YES;
    }];
    return result;
}

- (NSMutableDictionary *)getNoteWithTime:(long)time
{
    __block NSMutableDictionary * notetmp = nil;
    __block FMResultSet *cusor = nil;
    @try {
        [noteDBHelper inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSMutableString * selection = [[NSMutableString alloc] init];
            [selection appendFormat:@"%@=%ld", NoteOpenHelper_Note_TableColumns_Time,time];
            cusor = [db executeQueryWithTable:NoteOpenHelper_Note_Table_Name
                                      withColumns:tempColumns
                                  withColumnCount:_countof(tempColumns)
                                    withSelection:selection
                                withSelectionArgs:nil
                                      withGroupBy:nil
                                       withHaving:nil
                                      withOrderBy:NoteOpenHelper_Note_TableColumns_Time
                                        withLimit:nil];
            
            if (nil != cusor) {
                notetmp = [[NSMutableDictionary alloc] init];
                while (cusor.next) {
                    [notetmp setObject:[NSNumber numberWithLong:[cusor longForColumnIndex:0]]  forKey:NoteOpenHelper_Note_TableColumns_Time];
                    [notetmp setObject:[NSNumber numberWithInt:[cusor intForColumnIndex:1]] forKey:NoteOpenHelper_Note_TableColumns_Type];
                    [notetmp setObject:[cusor stringForColumnIndex:2] forKey:
                     NoteOpenHelper_Note_TableColumns_Content];
                }
                 [cusor close];
            }
        }];
    }
    @catch (NSException *exception) {
        [UncaughtExceptionHandler PrintStackTrace(exception)];
    }
    @finally {
       
    }
    return notetmp;
}

@end
