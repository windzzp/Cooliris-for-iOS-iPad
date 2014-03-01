//
//  UncaughtExceptionHandler.h
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#define PrintStackTrace(exp)  printStackTrace:__TIME__ withFile:__FILE__ withFunction:__FUNCTION__ withLine:__LINE__ withExp:exp
@interface UncaughtExceptionHandler : NSObject{
	BOOL dismissed;
}
+ (void)printStackTrace:(const char *)time withFile:(const char *)file withFunction:(const char *)function withLine:(const int)line withExp:(NSException *)exp;
@end


void HandleException(NSException *exception);
void SignalHandler(int signal);
void InstallUncaughtExceptionHandler(void);
