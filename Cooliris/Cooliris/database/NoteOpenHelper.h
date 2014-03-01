//
//  NoteOpenHelper.h
//  Cooliris
//
//  Created by user on 13-5-23.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "SQLiteOpenHelper.h"

#define NoteOpenHelper_Note_Table_Name   @"notes"

#define NoteOpenHelper_Note_TableColumns_Time  @"date"
#define NoteOpenHelper_Note_TableColumns_Content  @"content"
#define NoteOpenHelper_Note_TableColumns_Type  @"type"
#define NoteOpenHelper_Note_TableColumns_Fallback_1  @"fallback_1"
#define NoteOpenHelper_Note_TableColumns_Fallback_2  @"fallback_2"

@interface NoteOpenHelper : SQLiteOpenHelper

/**
 * Initialize the db open helper.
 *
 * @param strDBName    the db name.
 * @param nDBVersion   the db version.
 */
- (id)initWithName:(NSString *) strDBName nDBVersion:(int) nDBVersion;
@end
