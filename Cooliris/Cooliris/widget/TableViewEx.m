//
//  TableViewEx.m
//  Cooliris
//
//  Created by user on 13-5-24.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "TableViewEx.h"

#define ANIMATION_DURATION	0.30

@interface TableViewExCell : UITableViewCell

- (void)prepareForReuse;

@end

@implementation TableViewExCell

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    UIView *content = [self viewWithTag:CELL_CONTENT_TAG];
    if ([content respondsToSelector:@selector(prepareForReuse)]) {
        [content performSelector:@selector(prepareForReuse)];
    }
    
}

@end


@interface TableViewEx ()

- (void)createTableWithOrientation:(TableViewExOrientation)orientation;
- (void)prepareRotatedView:(UIView *)rotatedView;
- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath;
- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;
- (void)setScrollFraction:(CGFloat)fraction animated:(BOOL)animated;
- (CGPoint)offsetForView:(UIView *)cell;
- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath*)indexPathForView:(UIView *)cell;

@end

@implementation TableViewEx

@synthesize delegate, cellBackgroundColor;
@synthesize selectedIndexPath = selectedIndexPath_;
@synthesize orientation = orientation_;
@synthesize numberOfCells = numberOfCells_;

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numberOfCells
{
    if (self = [super initWithFrame:frame]) {
		numberOfCells_ = numberOfCells;
		cellWidthOrHeight_	= frame.size.height * 4.0 / 3.0;
		[self createTableWithOrientation:TableViewExOrientationHorizontal];
	}
    return self;
}

- (id)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numberOfCells
{
    if (self = [super initWithFrame:frame]) {
		numberOfCells_	= numberOfCells;
		cellWidthOrHeight_	= frame.size.height * 3.0 / 4.0;
		
		[self createTableWithOrientation:TableViewExOrientationVertical];
    }
    return self;
}

- (void)createTableWithOrientation:(TableViewExOrientation)orientation
{
	orientation_ = orientation;
	
	UITableView *tableView;
	if (orientation == TableViewExOrientationHorizontal) {
		int xOrigin	= (self.bounds.size.width - self.bounds.size.height)/2;
		int yOrigin	= (self.bounds.size.height - self.bounds.size.width)/2;
		tableView	= [[UITableView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, self.bounds.size.height, self.bounds.size.width)];
	} else {
		tableView	= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
	}
    
	tableView.tag				= TABLEVIEW_TAG;
	tableView.delegate			= self;
	tableView.dataSource		= self;
	tableView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Rotate the tableView 90 degrees so that it is horizontal
	if (orientation == TableViewExOrientationHorizontal) {
		tableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
    }
	
	tableView.showsVerticalScrollIndicator	 = NO;
	tableView.showsHorizontalScrollIndicator = NO;
	
	[self addSubview:tableView];
}


#pragma mark -
#pragma mark Properties

- (UITableView *)tableView
{
	return (UITableView *)[self viewWithTag:TABLEVIEW_TAG];
}


- (NSArray *)visibleViews
{
	NSArray *visibleCells = [self.tableView visibleCells];
	NSMutableArray *visibleViews = [NSMutableArray arrayWithCapacity:[visibleCells count]];
	
	for (UIView *aView in visibleCells) {
		[visibleViews addObject:[aView viewWithTag:CELL_CONTENT_TAG]];
	}
	return visibleViews;
}


- (CGPoint)contentOffset
{
	CGPoint offset = self.tableView.contentOffset;
	
	if (orientation_ == TableViewExOrientationHorizontal)
		offset = CGPointMake(offset.y, offset.x);
	
	return offset;
}


- (CGSize)contentSize
{
	CGSize size = self.tableView.contentSize;
	
	if (orientation_ == TableViewExOrientationHorizontal) {
		size = CGSizeMake(size.height, size.width);
    }
	
	return size;
}


- (void)setContentOffset:(CGPoint)offset
{
	if (orientation_ == TableViewExOrientationHorizontal) {
		self.tableView.contentOffset = CGPointMake(offset.y, offset.x);
    } else {
		self.tableView.contentOffset = offset;
    }
}


- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated
{
	CGPoint newOffset;
	
	if (orientation_ == TableViewExOrientationHorizontal) {
		newOffset = CGPointMake(offset.y, offset.x);
	}
	else {
		newOffset = offset;
	}
	[self.tableView setContentOffset:newOffset animated:animated];
}

- (void)setScrollFraction:(CGFloat)fraction animated:(BOOL)animated
{
	CGFloat maxScrollAmount = [self contentSize].width - self.bounds.size.width;
    
	CGPoint offset = self.contentOffset;
	offset.x = maxScrollAmount * fraction;
	[self setContentOffset:offset animated:animated];
}

#pragma mark -
#pragma mark Selection

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    //	self.selectedIndexPath	= indexPath;
    NSInteger count = [self.tableView.visibleCells count];
    NSInteger index = [indexPath row];
    if (index < count/2 || index > numberOfCells_ - count/2) {
        
    } else {
        CGPoint defaultOffset	= CGPointMake(0, (index - count/2) * cellWidthOrHeight_);
        [self.tableView setContentOffset:defaultOffset animated:animated];
    }
}


- (void)setSelectedIndexPath:(NSIndexPath *)indexPath
{
	if (![selectedIndexPath_ isEqual:indexPath]) {
		NSIndexPath *oldIndexPath = selectedIndexPath_;
		
		selectedIndexPath_ = indexPath;
		
		UITableViewCell *deselectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:oldIndexPath];
		UITableViewCell *selectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath_];
		
		if ([delegate respondsToSelector:@selector(tableViewEx:selectedView:atIndexPath:deselectedView:)]) {
			UIView *selectedView = [selectedCell viewWithTag:CELL_CONTENT_TAG];
			UIView *deselectedView = [deselectedCell viewWithTag:CELL_CONTENT_TAG];
			
			[delegate tableViewEx:self
                     selectedView:selectedView
                      atIndexPath:selectedIndexPath_
                   deselectedView:deselectedView];
		}
        [self selectCellAtIndexPath:indexPath animated:YES];
	}
}

#pragma mark -
#pragma mark Multiple Sections

- (UIView *)viewToHoldSectionView:(UIView *)sectionView
{
	// Enforce proper section header/footer view height abd origin. This is required because
	// of the way UITableView resizes section views on orientation changes.
	if (orientation_ == TableViewExOrientationHorizontal) {
		sectionView.frame = CGRectMake(0, 0, sectionView.frame.size.width, self.frame.size.height);
    }
	
	UIView *rotatedView = [[UIView alloc] initWithFrame:sectionView.frame];
	
	if (orientation_ == TableViewExOrientationHorizontal) {
		rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	} else {
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	[rotatedView addSubview:sectionView];
	return rotatedView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([delegate respondsToSelector:@selector(numberOfSectionsInTableViewEx:)]) {
        return [delegate numberOfSectionsInTableViewEx:self];
    }
    return 1;
}

#pragma mark -
#pragma mark Location and Paths

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	return [cell viewWithTag:CELL_CONTENT_TAG];
}

- (NSIndexPath *)indexPathForView:(UIView *)view
{
	NSArray *visibleCells = [self.tableView visibleCells];
	
	__block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UITableViewCell *cell = obj;
        
		if ([cell viewWithTag:CELL_CONTENT_TAG] == view) {
            indexPath = [self.tableView indexPathForCell:cell];
			*stop = YES;
		}
	}];
	return indexPath;
}

- (CGPoint)offsetForView:(UIView *)view
{
	// Get the location of the cell
	CGPoint cellOrigin = [view convertPoint:view.frame.origin toView:self];
	
	// No need to compensate for orientation since all values are already adjusted for orientation
	return cellOrigin;
}

#pragma mark -
#pragma mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[self setSelectedIndexPath:indexPath];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([delegate respondsToSelector:@selector(tableViewEx:heightOrWidthForCellAtIndexPath:)]) {
        return [delegate tableViewEx:self heightOrWidthForCellAtIndexPath:indexPath];
    }
    return cellWidthOrHeight_;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Don't allow the currently selected cell to be selectable
	if ([selectedIndexPath_ isEqual:indexPath]) {
		return nil;
	}
	return indexPath;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ([delegate respondsToSelector:@selector(tableViewEx:scrolledToOffset:)]) {
		[delegate tableViewEx:self scrolledToOffset:self.contentOffset];
    }
	
	CGFloat amountScrolled	= self.contentOffset.x;
	CGFloat maxScrollAmount = [self contentSize].width - self.bounds.size.width;
	
	if (amountScrolled > maxScrollAmount) {
        amountScrolled = maxScrollAmount;
    }
	if (amountScrolled < 0) {
        amountScrolled = 0;
    }
	
	if ([delegate respondsToSelector:@selector(tableViewEx:scrolledToFraction:)]) {
		[delegate tableViewEx:self scrolledToFraction:amountScrolled/maxScrollAmount];
    }
}


#pragma mark -
#pragma mark TableViewDataSource

- (void)setCell:(UITableViewCell *)cell boundsForOrientation:(TableViewExOrientation)theOrientation
{
	if (theOrientation == TableViewExOrientationHorizontal) {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.height, cellWidthOrHeight_);
	}
	else {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.width, cellWidthOrHeight_);
	}
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewExCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TableViewExCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		[self setCell:cell boundsForOrientation:orientation_];
		
		cell.contentView.frame = cell.bounds;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// Add a view to the cell's content view that is rotated to compensate for the table view rotation
		CGRect viewRect;
		if (orientation_ == TableViewExOrientationHorizontal) {
			viewRect = CGRectMake(0, 0, cell.bounds.size.height, cell.bounds.size.width);
		} else {
			viewRect = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
        }
		
		UIView *rotatedView				= [[UIView alloc] initWithFrame:viewRect];
		rotatedView.tag					= ROTATED_CELL_VIEW_TAG;
		rotatedView.center				= cell.contentView.center;
		rotatedView.backgroundColor		= self.cellBackgroundColor;
		
		if (orientation_ == TableViewExOrientationHorizontal) {
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		} else {
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        }
		
		// We want to make sure any expanded content is not visible when the cell is deselected
		rotatedView.clipsToBounds = YES;
		
		// Prepare and add the custom subviews
		[self prepareRotatedView:rotatedView];
		
		[cell.contentView addSubview:rotatedView];
	}
	[self setCell:cell boundsForOrientation:orientation_];
	
	[self setDataForRotatedView:[cell.contentView viewWithTag:ROTATED_CELL_VIEW_TAG] forIndexPath:indexPath];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUInteger numOfItems = numberOfCells_;
	
	if ([delegate respondsToSelector:@selector(numberOfCellsForTableViewEx:inSection:)]) {
		numOfItems = [delegate numberOfCellsForTableViewEx:self inSection:section];
		
		// Animate any changes in the number of items
		[tableView beginUpdates];
		[tableView endUpdates];
	}
	
    return numOfItems;
}

#pragma mark -
#pragma mark Rotation

- (void)prepareRotatedView:(UIView *)rotatedView
{
	UIView *content = [delegate tableViewEx:self viewForRect:rotatedView.bounds];
	
	// Add a default view if none is provided
	if (content == nil) {
		content = [[UIView alloc] initWithFrame:rotatedView.bounds];
    }
	
	content.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	content.tag = CELL_CONTENT_TAG;
	[rotatedView addSubview:content];
}


- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath
{
	UIView *content = [rotatedView viewWithTag:CELL_CONTENT_TAG];
	
    [delegate tableViewEx:self setDataForView:content forIndexPath:indexPath];
}

-(void)reloadData
{
    [self.tableView reloadData];
}

@end
