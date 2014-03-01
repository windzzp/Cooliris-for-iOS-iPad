//
//  CPSectionView.h
//  ExpansionTableView
//
//  Created by user on 13-6-18.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPHeaderView : UIView

// The title of the header view
@property (strong, nonatomic) NSString *title;
// Whether the view is activied
@property (nonatomic) BOOL isActivied;
// Whether the title is highligted
@property (nonatomic) BOOL highlighted;
// The delegate will invoked when user tapped this view
@property (weak, nonatomic) id delegate;

@end

@protocol CPHeaderViewDelegate <NSObject>
- (void)selectedHeaderWith:(CPHeaderView *)headerView;
@end
