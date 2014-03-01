//
//  SearchViewController.h
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MosaicLayoutDelegate.h"
#import "RootPageViewController.h"
#import "AbsPageViewController.h"
#import "SearchOptionsViewController.h"

@interface SearchViewController : AbsPageViewController <UICollectionViewDataSource,
                                                         MosaicLayoutDelegate,
                                                         UISearchBarDelegate,
                                                         UIScrollViewDelegate,
                                                         EGORefreshTableHeaderDelegate,
                                                         UICollectionViewDelegate,
                                                         SearchOptionsDelegate>

@end
