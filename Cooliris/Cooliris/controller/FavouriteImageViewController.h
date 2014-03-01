//
//  FavouriteImageViewController.h
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MosaicLayoutDelegate.h"
#import "RootPageViewController.h"
#import "AbsPageViewController.h"

@interface FavouriteImageViewController : AbsPageViewController <UICollectionViewDataSource,
                                                                 UICollectionViewDelegate,
                                                                 MosaicLayoutDelegate,
                                                                 UIAlertViewDelegate>

@end
