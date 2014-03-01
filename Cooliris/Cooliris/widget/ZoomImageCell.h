///Users/user/Documents/MediaGuide/Other/edu/demo/Cooliris/Cooliris/widget/ImageCell.h
//  ZoomImageCell.h
//  Cooliris
//
//  Created by user on 13-5-29.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kZoomImageCellIdentifier @"ZoomImageCell"

@protocol ZoomImageCellDelegate <NSObject>

- (void)onSetControlsHidden:(BOOL)hidden;
- (void)onSetCollectionViewScrollEnabled:(BOOL)enabled;

@end

@interface ZoomImageCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIScrollView *zoomView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) id<ZoomImageCellDelegate> zoomImageCellDelegate;

@end


