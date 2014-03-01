//
//  AbsPageViewController.h
//  Cooliris
//
//  Created by user on 13-6-25.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCustom_Layout_Key       @"layout"
#define kNotification_Layout     @"changeLayout"

#define kImage_Cell_Show_Detail   @"imageCellShowDetail"
#define kNotification_Show_Detail @"showDetail"

//@protocol PageDelegate <NSObject>
//- (void)initNavigationBar;
//@end

typedef enum {
    kLayoutTypeUndefined,
    kLayoutTypeWaterFlow,
    kLayoutTypeGrid,
    kLayoutTypeSingleLine,
} LayoutType;

@interface AbsPageViewController : UIViewController

@property (nonatomic) BOOL isNeedRefreshData;
@property (nonatomic) BOOL isNeedRelayout;
@property (nonatomic) BOOL isShowDetail;
@property (nonatomic) LayoutType currentDisplayMode;

// The following methods should be overrided by subclass
- (void)initNavigationBar;
- (void)refreshData;
- (void)relayout:(LayoutType)layoutType;

@end
