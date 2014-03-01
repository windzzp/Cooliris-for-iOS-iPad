//
//  OptionsViewController.h
//  Cooliris
//
//  Created by user on 13-6-13.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol LayoutConfigurationChangedDelegate <NSObject>

/**
 * Called when the layout type changed.
 *
 * @param newLayoutType The new layout type.
 */
- (void)layoutTypeChanged:(int)newLayoutType;

/**
 * Called when the show detail (ON/OFF) switch controller value changed.
 *
 * @param needShow |YES| is needed to show detail.
 */
- (void)showDetailInfoChanged:(BOOL)needShow;

@end


@interface OptionsViewController : UIViewController

// The |LayoutConfigurationChangedDelegate| delegate.
//@property (weak, nonatomic) id<LayoutConfigurationChangedDelegate> delegate;

@end
