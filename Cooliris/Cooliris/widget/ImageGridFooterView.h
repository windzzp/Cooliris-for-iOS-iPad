//
//  FooterView.h
//  TestCollectionView
//
//  Created by user on 13-6-26.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGridFooterView : UICollectionReusableView

- (void)startLoading;
- (void)completedLoading;
- (void)completedLoading:(NSString *)withShowingMessage;

@end
