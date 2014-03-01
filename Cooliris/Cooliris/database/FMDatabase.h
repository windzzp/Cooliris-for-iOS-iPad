//
//  FMDatabasePool.m
//  fmdb
//
//  Created by August Mueller on 6/22/11.
//  Copyright 2011 Flying Meat Inc. All rights reserved.
//
//  https://github.com/ccgus/fmdb/tree/master/src
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMResultSet.h"
#import "FMDatabasePool.h"


#if ! __has_feature(objc_arc)
    #define FMDBAutorelease(__v) ([__v autorelease]);
    #define FMDBReturnAutoreleased FMDBAutorelease

    #define FMDBRetain(__v) ([__v retain]);
    #define FMDBReturnRetained FMDBRetain

    #define FMDBRelease(__v) ([__v release]);

	#define FMDBDispatchQueueRelease(__v) (dispatch_release(__v));
#else
    // -fobjc-arc
    #define FMDBAutorelease(__v)
    #define FMDBReturnAutoreleased(__v) (__v)

    #define FMDBRetain(__v)
    #define FMDBReturnRetained(__v) (__v)

    #define FMDBRelease(__v)

	#if TARGET_OS_IPHONE
		// Compiling for iOS
		#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
			// iOS 6.0 or later
			#define FMDBDispatchQueueRelease(__v)
		#else
			// iOS 5.X or earlier
			#define FMDBDispatchQueueRelease(__v) (dispatch_release(__v));
		#endif
	#else
		// Compiling for Mac OS X
		#if MAC_OS_X_VERSION_MIN_REQUIRED >= 1080     
			// Mac OS X 10.8 or later
			#define FMDBDispatchQueueRelease(__v)
		#else
			// Mac OS X 10.7 or earlier
			#define FMDBDispatchQueueRelease(__v) (dispatch_release(__v));
		#endif
	#endif
#endif

/**
 * Algorithms used in ON CONFLICT clause
 * http://www.sqlite.org/lang_conflict.html
 */

typedef enum _conflictType
{
    /**
     * use the following when no conflict action is specified.
     */
    CONFLICT_NONE = 0,
    
    /**
     *  When a constraint violation occurs, an immediate ROLLBACK occurs,
     * thus ending the current transaction, and the command aborts with a
     * return code of SQLITE_CONSTRAINT. If no transaction is active
     * (other than the implied transaction that is created on every command)
     *  then this algorithm works the same as ABORT.
     */
    CONFLICT_ROLLBACK,
    
    /**
     * When a constraint violation occurs,no ROLLBACK is executed
     * so changes from prior commands within the same transaction
     * are preserved. This is the default behavior.
     */
    CONFLICT_ABORT,
    
    /**
     * When a constraint violation occurs, the command aborts with a return
     * code SQLITE_CONSTRAINT. But any changes to the database that
     * the command made prior to encountering the constraint violation
     * are preserved and are not backed out.
     */
    CONFLICT_FAIL,
    
    /**
     * When a constraint violation occurs, the one row that contains
     * the constraint violation is not inserted or changed.
     * But the command continues executing normally. Other rows before and
     * after the row that contained the constraint violation continue to be
     * inserted or updated normally. No error is returned.
     */
    CONFLICT_IGNORE,
    
    /**
     * When a UNIQUE constraint violation occurs, the pre-existing rows that
     * are causing the constraint violation are removed prior to inserting
     * or updating the current row. Thus the insert or update always occurs.
     * The command continues executing normally. No error is returned.
     * If a NOT NULL constraint violation occurs, the NULL value is replaced
     * by the default value for that column. If the column has no default
     * value, then the ABORT algorithm is used. If a CHECK constraint
     * violation occurs then the IGNORE algorithm is used. When this conflict
     * resolution strategy deletes rows in order to satisfy a constraint,
     * it does not invoke delete triggers on those rows.
     *  This behavior might change in a future release.
     */
    CONFLICT_REPLACE
    
}conflictType_e;

static NSString * const CONFLICT_VALUES[] =
{
    @"",
    @" OR ROLLBACK ",
    @" OR ABORT ",
    @" OR FAIL ",
    @" OR IGNORE ",
    @" OR REPLACE "
};

@interface FMDatabase : NSObject  {
    
    sqlite3*            _db;
    NSString*           _databasePath;
    BOOL                _logsErrors;
    BOOL                _crashOnErrors;
    BOOL                _traceExecution;
    BOOL                _checkedOut;
    BOOL                _shouldCacheStatements;
    BOOL                _isExecutingStatement;
    BOOL                _inTransaction;
    int                 _busyRetryTimeout;
    
    NSMutableDictionary *_cachedStatements;
    NSMutableSet        *_openResultSets;
    NSMutableSet        *_openFunctions;

}


@property (atomic, assign) BOOL traceExecution;
@property (atomic, assign) BOOL checkedOut;
@property (atomic, assign) int busyRetryTimeout;
@property (atomic, assign) BOOL crashOnErrors;
@property (atomic, assign) BOOL logsErrors;
@property (atomic, retain) NSMutableDictionary *cachedStatements;


+ (id)databaseWithPath:(NSString*)inPath;
- (id)initWithPath:(NSString*)inPath;

- (BOOL)open;
#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL)openWithFlags:(int)flags;
#endif
- (BOOL)close;
- (BOOL)goodConnection;
- (void)clearCachedStatements;
- (void)closeOpenResultSets;
- (BOOL)hasOpenResultSets;

// encryption methods.  You need to have purchased the sqlite encryption extensions for these to work.
- (BOOL)setKey:(NSString*)key;
- (BOOL)rekey:(NSString*)key;

- (NSString *)databasePath;

- (NSString*)lastErrorMessage;

- (int)lastErrorCode;
- (BOOL)hadError;
- (NSError*)lastError;

- (sqlite_int64)lastInsertRowId;

- (sqlite3*)sqliteHandle;

- (BOOL)update:(NSString*)sql withErrorAndBindings:(NSError**)outErr, ...;
- (BOOL)executeUpdate:(NSString*)sql, ...;
- (BOOL)executeUpdateWithFormat:(NSString *)format, ...;
- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
- (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;
// Add by LZT (201201026)--Begin
- (FMResultSet *)executeQueryWithDistinct: (BOOL)distinct withTable: (NSString*)table
                              withColumns:(NSString*__strong*)columns withColumnCount:(int)nColumnCount withSelection:(NSString*)selection
                        withSelectionArgs:(NSArray*) selectionArgs withGroupBy:(NSString*)groupBy
                               withHaving:(NSString*)having withOrderBy:(NSString*)orderBy withLimit:(NSString*)limit;

- (FMResultSet *)executeQueryWithTable: (NSString*)table
                           withColumns:(NSString*__strong*)columns withColumnCount:(int)nColumnCount withSelection:(NSString*)selection
                     withSelectionArgs:(NSArray*)selectionArgs withGroupBy:(NSString*)groupBy
                            withHaving:(NSString*)having withOrderBy:(NSString*)orderBy withLimit:(NSString*)limit;
/**
 * Build an SQL query string from the given clauses.
 *
 * @param distinct true if you want each row to be unique, false otherwise.
 * @param tables The table names to compile the query against.
 * @param columns A list of which columns to return. Passing null will
 *            return all columns, which is discouraged to prevent reading
 *            data from storage that isn't going to be used.
 * @param where A filter declaring which rows to return, formatted as an SQL
 *            WHERE clause (excluding the WHERE itself). Passing null will
 *            return all rows for the given URL.
 * @param groupBy A filter declaring how to group rows, formatted as an SQL
 *            GROUP BY clause (excluding the GROUP BY itself). Passing null
 *            will cause the rows to not be grouped.
 * @param having A filter declare which row groups to include in the cursor,
 *            if row grouping is being used, formatted as an SQL HAVING
 *            clause (excluding the HAVING itself). Passing null will cause
 *            all row groups to be included, and is required when row
 *            grouping is not being used.
 * @param orderBy How to order the rows, formatted as an SQL ORDER BY clause
 *            (excluding the ORDER BY itself). Passing null will use the
 *            default sort order, which may be unordered.
 * @param limit Limits the number of rows returned by the query,
 *            formatted as LIMIT clause. Passing null denotes no LIMIT clause.
 
 * @return the SQL query string
 */
- (NSString *) buildQueryStringWithDistinct:(BOOL)distinct
                                  withTable:(NSString*)tables
                                withColumns:(NSString*__strong*)columns
                           withColumnsCount:(int)nCount
                                  withWhere:(NSString*) where
                                withGroupBy:(NSString*)groupBy
                                 withHaving:(NSString*) having
                                withOrderBy:(NSString*)orderBy
                                  withLimit:(NSString*) limit;
// Add by LZT (201201026)--End

- (FMResultSet *)executeQuery:(NSString*)sql, ...;
- (FMResultSet *)executeQueryWithFormat:(NSString*)format, ...;
- (FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
- (FMResultSet *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;

// Add by LZT (201201026)--Begin
- (BOOL)insertWithOnConflictTableName: (NSString*)table withNULLColumnHack: (NSString*)nullColumnHack withValues: (NSDictionary*)contentValues withConflict: (conflictType_e)eConflictAlgorithm;

- (BOOL) updateWithOnConflictTableName: (NSString*)table withValues: (NSDictionary*)contentValues withWhereClause: (NSString*)whereClause withWhereArgs:   (NSString*[])whereArgs withConflict: (conflictType_e)eConflictAlgorithm;
// Add by LZT (201201026)--End

- (BOOL)rollback;
- (BOOL)commit;
- (BOOL)beginTransaction;
- (BOOL)beginDeferredTransaction;
- (BOOL)inTransaction;
- (BOOL)shouldCacheStatements;
- (void)setShouldCacheStatements:(BOOL)value;

#if SQLITE_VERSION_NUMBER >= 3007000
- (BOOL)startSavePointWithName:(NSString*)name error:(NSError**)outErr;
- (BOOL)releaseSavePointWithName:(NSString*)name error:(NSError**)outErr;
- (BOOL)rollbackToSavePointWithName:(NSString*)name error:(NSError**)outErr;
- (NSError*)inSavePoint:(void (^)(BOOL *rollback))block;
#endif

+ (BOOL)isSQLiteThreadSafe;
+ (NSString*)sqliteLibVersion;

- (int)changes;

- (void)makeFunctionNamed:(NSString*)name maximumArguments:(int)count withBlock:(void (^)(sqlite3_context *context, int argc, sqlite3_value **argv))block;

@end

@interface FMStatement : NSObject {
    sqlite3_stmt *_statement;
    NSString *_query;
    long _useCount;
}

@property (atomic, assign) long useCount;
@property (atomic, retain) NSString *query;
@property (atomic, assign) sqlite3_stmt *statement;

- (void)close;
- (void)reset;

@end

