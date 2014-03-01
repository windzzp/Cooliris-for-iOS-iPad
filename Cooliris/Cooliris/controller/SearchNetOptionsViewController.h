//
//  SearchNetOptionsViewController.h
//  Cooliris
//
//  Created by user on 13-6-18.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchOptionsViewController.h"

@interface SearchNetOptionsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) id<SearchOptionsDelegate> delegate;

@end
