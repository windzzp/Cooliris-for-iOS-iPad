//
//  NoteDBOperator.h
//  Cooliris
//
//  Created by user on 13-5-23.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteOpenHelper.h"
#import "SQLiteOpenHelper.h"

@interface NoteDBOperator : NSObject
{
    NSMutableDictionary *note;
    NoteOpenHelper *noteDBHelper;
}

- (id)initWithName:(NSString *) strDBName nDBVersion:(int) nDBVersion;
- (int)insertNoteWithTime:(long)time with:(int)type with:(const NSString *)content;
- (NSMutableDictionary *)getNoteWithTime:(long)time;
- (BOOL)delNotes;

@end
