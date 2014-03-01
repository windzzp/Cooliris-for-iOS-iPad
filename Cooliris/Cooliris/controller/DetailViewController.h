//
//  DetailViewController.h
//  Cooliris
//
//  Created by user on 13-5-31.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomImageCell.h"

@interface DetailViewController : UIViewController <UICollectionViewDelegate,
                                                    UICollectionViewDataSource,
                                                    UICollectionViewDelegateFlowLayout,
                                                    ZoomImageCellDelegate>

@property (nonatomic)         NSUInteger currentGroupIndex;
@property (strong, nonatomic) NSString   *currentPageCategory;

@end
