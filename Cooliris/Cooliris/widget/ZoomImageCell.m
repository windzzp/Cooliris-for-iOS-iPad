//
//  ZoomImageCell.m
//  Cooliris
//
//  Created by user on 13-5-29.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "ZoomImageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "DetailViewController.h"

#define kMaxScale 5

@interface ZoomImageCell ()
{
    CGPoint currentOffect_;
    CGAffineTransform initImageTransform_;
    BOOL collectionViewScrollEnabled_;
}


- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinch;

@end

@implementation ZoomImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.zoomView.contentSize = self.imageView.frame.size;
    initImageTransform_ = self.transform;
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(handlePinchGesture:)];
    [self.zoomView addGestureRecognizer:pinchGesture];
    
//    UIImage *image = [UIImage imageNamed:@"background_imageCell.jpg"];
//    self.zoomView.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(self.imageView.frame, frameToCenter)) {
        if (frameToCenter.size.width > boundsSize.width && frameToCenter.size.height > boundsSize.height) {
            self.zoomView.contentOffset = CGPointMake(currentOffect_.x - self.imageView.frame.origin.x, currentOffect_.y - self.imageView.frame.origin.y);
        }
		self.imageView.frame = frameToCenter;
	}
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinch
{
    [self.zoomImageCellDelegate onSetControlsHidden:YES];
    self.zoomView.scrollEnabled = YES;
    
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, pinch.scale, pinch.scale);
    self.zoomView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
    currentOffect_ = self.zoomView.contentOffset;
    [self layoutSubviews];
    
    if (pinch.state == UIGestureRecognizerStateEnded) {
        if (self.imageView.frame.size.width <= self.bounds.size.width) {
            // Zoom smaller than initial
            collectionViewScrollEnabled_ = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.imageView.transform = initImageTransform_;
                self.imageView.frame = self.bounds;
            }];
            self.zoomView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        } else if (self.imageView.frame.size.width > self.bounds.size.width * kMaxScale) {
            // Zoom bigger than max scale
            [UIView animateWithDuration:0.3 animations:^{
                self.imageView.transform = CGAffineTransformMakeScale(kMaxScale, kMaxScale);
            }];
            self.zoomView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
        }
        [self layoutSubviews];
        
        if (self.imageView.frame.size.width > self.bounds.size.width) {
            collectionViewScrollEnabled_ = NO;
        } else {
            collectionViewScrollEnabled_ = YES;
            self.zoomView.scrollEnabled = NO;
        }
        
        // Send message to controller to handle if the collection view can scroll
        [self.zoomImageCellDelegate onSetCollectionViewScrollEnabled:collectionViewScrollEnabled_];
    }
    
    pinch.scale = 1;
}

@end
