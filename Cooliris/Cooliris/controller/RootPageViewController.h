//
//  RootPageViewController.h
//  Cooliris
//
//  Created by user on 13-6-20.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlPanelViewController.h"

@interface RootPageViewController : UIViewController

@property (weak, nonatomic) id<ControlPanelDelegate> delegate;

@end
