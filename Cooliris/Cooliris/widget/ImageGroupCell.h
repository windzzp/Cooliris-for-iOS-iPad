//
//  ImageGroupCell.h
//  Cooliris
//
//  Created by user on 13-6-4.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier @"ImageGroupCell"
#define kCellNibName    @"ImageGroupCell"

@class ImageGroup;

@interface ImageGroupCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView  *detailView;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailDescription;

@property (strong, nonatomic) UIImage *image;
@property (nonatomic) BOOL isMultiSelected;

@property (strong, nonatomic) ImageGroup *imageData;

- (void)setBorderColor:(UIColor *)color withWidth:(CGFloat)width inState:(BOOL)selected;
- (void)setImageData:(ImageGroup *)imageData useThumbnail:(BOOL)useThumbnail;
- (void)setFrameSingleLine;
- (void)setFrameDetail;
- (void)setFrameNoDetail;

@end
