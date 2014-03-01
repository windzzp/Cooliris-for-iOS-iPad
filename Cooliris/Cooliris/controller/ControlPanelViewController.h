//
//  CategoryViewController.h
//  Cooliris
//
//  Created by user on 13-6-17.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPHeaderView;
@protocol ControlPanelDelegate <NSObject>
//- (void)mainTable:(UITableView *)tableView sectionDidChanged:(CPHeaderView *)sectionItem sectionIndex:(int)sectionIndex;

@optional
- (void)section:(CPHeaderView *)sectionItem didSelectAtSection:(int)section AtIndex:(int)index;
- (void)section:(CPHeaderView *)sectionItem didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)updateControlPanelSection:(int)section AtIndex:(int)index;

@end

@interface ControlPanelViewController : UIViewController <ControlPanelDelegate>

@property (weak, nonatomic) id<ControlPanelDelegate> delegate;

@end
