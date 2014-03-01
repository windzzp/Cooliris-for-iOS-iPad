//
//  UIBarButtonItemEx.m
//  Cooliris
//
//  Created by user on 13-6-7.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "UIBarButtonItemEx.h"

@interface UIBarButtonItemEx()
{
    UIButton *button_;
    id target_;
}

@end

@implementation UIBarButtonItemEx

+ (UIBarButtonItemEx *)initWithFrame:(CGRect)frame
                         normalImage:(UIImage *)normalImage
                      highlightImage:(UIImage *)highlightImage
                              target:(id)target
                              action:(SEL)action
{
    return [[UIBarButtonItemEx alloc] initWithFrame:frame
                                        normalImage:normalImage
                                     highlightImage:highlightImage
                                             target:target
                                             action:action];
}


- (id)initWithFrame:(CGRect)frame
        normalImage:(UIImage *)image
     highlightImage:(UIImage *)highlightImage
             target:(id)target
             action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    /* Init method inherited from UIBarButtonItem */
    self = [[UIBarButtonItemEx alloc] initWithCustomView:button];
    
    if (self) {
        /* Assign ivars */
        button_ = button;
        normalImage_ = image;
        highlightImage_ = highlightImage;
        target_ = target;
    }
    
    return self;
}

- (void)setNormalImage:(UIImage *)image
{
    normalImage_ = image;
    [button_ setImage:image forState:UIControlStateNormal];
}

- (void)setHighlightImage:(UIImage *)image
{
    highlightImage_ = image;
    [button_ setImage:image forState:UIControlStateHighlighted];
}

- (void)setCustomAction:(SEL)action
{
    customAction_ = action;
    
    [button_ removeTarget:nil
                   action:NULL
         forControlEvents:UIControlEventAllEvents];
    
    [button_ addTarget:target_
                action:action
      forControlEvents:UIControlEventTouchUpInside];
}

@end
