//
//  ImageGridViewController.h
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "EGORefreshTableHeaderView.h"
#import "MosaicLayoutDelegate.h"
#import "OptionsViewController.h"
#import "RootPageViewController.h"
#import "AbsPageViewController.h"

@class PageInfo;
@interface ImageGridViewController : AbsPageViewController <UICollectionViewDataSource,
                                                            UICollectionViewDelegate,
                                                            UICollectionViewDelegateFlowLayout,
                                                            EGORefreshTableHeaderDelegate,
                                                            MosaicLayoutDelegate>
@property (strong, nonatomic) PageInfo *pageInfo;

@end
