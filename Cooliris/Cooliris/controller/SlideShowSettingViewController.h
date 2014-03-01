//
//  SlideShowSettingViewController.h
//  Cooliris
//
//  Created by user on 13-6-4.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SlideOrderOrdinal = 0,
    SlideOrderRandom
} SlideOrder;

@interface SlideShowSettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic, readonly) NSString *selectedType;
@property (strong, nonatomic, readonly) NSString *selectedDirection;
@property (nonatomic, readonly) NSTimeInterval selectedInterval;
@property (nonatomic, readonly) NSUInteger selectedOrder;

@end
