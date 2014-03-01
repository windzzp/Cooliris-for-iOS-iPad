//
//  ImageCell.h
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier @"ImageCell"
#define kCellNibName    @"ImageCell"

@class Image;

//typedef NS_ENUM(NSInteger, ImageCellSelectState) {
//    STATE_NORMAL,
//    STATE_SELECTED,
//    STATE_UNSELECTED
//};

@interface ImageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
//@property (weak, nonatomic) IBOutlet UIImageView *selectedView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *description;
@property (nonatomic) BOOL isMultiSelected;

@property (strong, nonatomic) Image *imageData;

- (void)setBorderColor:(UIColor *)color withWidth:(CGFloat)width inState:(BOOL)selected;
- (void)setImageData:(Image *)imageData useThumbnail:(BOOL)useThumbnail;

@end
