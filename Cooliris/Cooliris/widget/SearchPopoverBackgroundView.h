//
//  SearchPopoverBackgroundView.h
//  Cooliris
//
//  Created by user on 13-6-19.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchPopoverBackgroundView : UIPopoverBackgroundView
{
    // contains the image for border.
    UIImageView *_borderImageView;
    
    // contains the image for the arrow.
    UIImageView *_arrowView;
    
    // used for the property arrowOffset specified in the Interface for UIPopoverBackgroundView.
    // We will see later how this value is used to calculate the position for the arrow.
    CGFloat     _arrowOffset;
    
    // used for the property arrowDirection specified in the Interface for UIPopoverBackgroundView.
    UIPopoverArrowDirection _arrowDirection;
}

@end
