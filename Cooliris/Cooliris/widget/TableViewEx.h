//
//  TableViewEx.h
//  Cooliris
//
//  Created by user on 13-5-24.
//  Copyright (c) 2013年 user. All rights reserved.
//

#define TABLEVIEW_TAG			800
#define ROTATED_CELL_VIEW_TAG	801
#define CELL_CONTENT_TAG		802

@class TableViewEx;

typedef enum {
	TableViewExOrientationVertical,
	TableViewExOrientationHorizontal
} TableViewExOrientation;


@protocol TableViewExDelegate <NSObject>

- (UIView *)tableViewEx:(TableViewEx *)tableViewEx viewForRect:(CGRect)rect;
- (void)tableViewEx:(TableViewEx *)tableViewEx setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath;

@optional

- (void)tableViewEx:(TableViewEx *)tableViewEx selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView;
- (void)tableViewEx:(TableViewEx *)tableViewEx scrolledToOffset:(CGPoint)contentOffset;
- (void)tableViewEx:(TableViewEx *)tableViewEx scrolledToFraction:(CGFloat)fraction;
- (NSUInteger)numberOfSectionsInTableViewEx:(TableViewEx *)tableViewEx;
- (NSUInteger)numberOfCellsForTableViewEx:(TableViewEx *)tableViewEx inSection:(NSInteger)section;
- (CGFloat)tableViewEx:(TableViewEx *)tableViewEx heightOrWidthForCellAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface TableViewEx : UIView <UITableViewDelegate, UITableViewDataSource>
{
	CGFloat	cellWidthOrHeight_;
}

@property (nonatomic, unsafe_unretained) id<TableViewExDelegate> delegate;
@property (nonatomic, readonly, unsafe_unretained) UITableView *tableView;
@property (nonatomic, readonly, unsafe_unretained) NSArray *visibleViews;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) UIColor *cellBackgroundColor;
@property (nonatomic, readonly) TableViewExOrientation orientation;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, assign) NSUInteger numberOfCells;

- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numberOfCells;
- (id)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numberOfCells;
- (void)reloadData;

@end
