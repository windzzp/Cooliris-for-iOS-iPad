//
//  UIBarButtonItemEx.h
//  Cooliris
//
//  Created by user on 13-6-7.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItemEx : UIBarButtonItem
{
    UIImage *normalImage_;
    UIImage *highlightImage_;
    SEL customAction_;
}

/**
 * Create and return a new bar button item.
 * @param frame The frame of the button.
 * @param image The image of the button to show when unselected. Works best with images under 44x44.
 * @param selectedImage The image of the button to show when the button is tapped. Works best with images under 44x44.
 * @param target The target of the selector
 * @param action The selector to perform when the button is tapped
 *
 * @return An instance of the new button to be used like a normal UIBarButtonItem
 */
+ (UIBarButtonItemEx *)initWithFrame:(CGRect)frame
                         normalImage:(UIImage *)normalImage
                      highlightImage:(UIImage *)highlightImage
                              target:(id)target
                              action:(SEL)action;

- (void)setNormalImage:(UIImage *)image;
- (void)setHighlightImage:(UIImage *)image;
- (void)setCustomAction:(SEL)action;

@end
