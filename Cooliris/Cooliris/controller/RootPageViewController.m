//
//  RootPageViewController.m
//  Cooliris
//
//  Created by user on 13-6-20.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "RootPageViewController.h"
#import "UIApplication+AppDimensions.h"
#import "ImageGridViewController.h"
#import "FavouriteImageViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "ControlPanelViewController.h"
#import "PageInfoManager.h"
#import "PageGroupInfo.h"
#import "PageInfo.h"
#import "AbsPageViewController.h"

#define kCustom_Layout_Key       @"layout"
#define kNotification_Layout     @"changeLayout"

#define kImage_Cell_Show_Detail   @"imageCellShowDetail"
#define kNotification_Show_Detail @"showDetail"

@interface RootPageViewController () <UIScrollViewDelegate, ControlPanelDelegate>

// Views
@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (strong, nonatomic)        NSMutableArray *viewControllers;
@property (nonatomic)                NSUInteger     currentPageIndex;
@property (nonatomic)                BOOL           hasLoadSubView;
@property (nonatomic)                BOOL           isCovered;

@property (strong, nonatomic)        NSArray        *pageInfoGroups;
//@property (strong, nonatomic) NSDictionary *pageGroupDict;

- (void)initNavigationBar;
- (void)initPageData;
- (void)initScrollView;
- (void)resetScrollView;
- (NSString *)getPageTitle:(int)page;

@end

@implementation RootPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerNotification];
    [self initNavigationBar];
    [self initPageData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"Root view: viewDidAppear");
    // If some page has been covered when user entey the |DetailViewController|,
    // it should refresh the current page to reload the data
    if (_isCovered) {
        AbsPageViewController *controller = (AbsPageViewController*)[self.viewControllers objectAtIndex:_currentPageIndex];
        [controller refreshData];
        
        NSLog(@"Refresh UI, index = %d", _currentPageIndex);
        _isCovered = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _isCovered = YES;
    NSLog(@"Root view: viewDidDisappear");
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // We init the scrollview in this function, not the |viewDidLoad|.
    // In |viewDidLoad|, the scrollview get a incorrect frame.
    // Why???
    [self initScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// rotation support for iOS 5.x and earlier, note for iOS 6.0 and later this will not be called
//
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // return YES for supported orientations
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#endif

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resetScrollView];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - ControlPanelDelegate

- (void)section:(CPHeaderView *)sectionItem didSelectAtSection:(int)section AtIndex:(int)index
{
    switch (section) {
        case 0:
            if (index == -1) {
                index = 0;
            }
            [self gotoCurrentPage:index animated:YES];
            break;
            
        case 1:
            [self gotoCurrentPage:9 animated:YES];
            [self leftDrawerButtonPress:nil];
            break;
            
        case 2:
            [self gotoCurrentPage:10 animated:YES];
            [self leftDrawerButtonPress:nil];
            break;
            
        default:
            break;
    }
}

- (void)section:(CPHeaderView *)sectionItem didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;
    
    if (0 == section) {
        [self gotoCurrentPage:row animated:YES];
    }
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {}];
}

#pragma mark - Handler button action

- (void)leftDrawerButtonPress:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Private methods

- (void)registerNotification
{
    // Register Notifications.
    // Change UILayout when user make a change in setting.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_Layout
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLayout:)
                                                 name:kNotification_Layout
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_Show_Detail
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDetailChanged:)
                                                 name:kNotification_Show_Detail
                                               object:nil];
}

- (void)initNavigationBar
{
    // Set the title color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Add left button
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    self.navigationItem.leftBarButtonItem = leftDrawerButton;
    
    // [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)initPageData
{
    _pageInfoGroups = [[PageInfoManager sharedInstance] loadPageInfoGroups];
    //_pageGroupDict = [PageInfoManager sharedInstance].pageGroupsDict;
    
    // Add pages
    // NOTE: For favorite & search, it has no sub-item, we also add a placeholder
    int groupCount = _pageInfoGroups.count;
    _viewControllers = [[NSMutableArray alloc] initWithCapacity:groupCount];
    for (NSUInteger ix = 0; ix < groupCount; ++ix) {
        int count = ((PageGroupInfo *)_pageInfoGroups[ix]).pageInfos.count;
        
        if (count > 0) {
            for (int ix = 0; ix < count; ix++) {
                [_viewControllers addObject:[NSNull null]];
            }
        } else {
            [_viewControllers addObject:[NSNull null]];
        }
    }
}

- (void)initScrollView
{
    if (!_hasLoadSubView) {
        NSLog(@"view.frame(%f, %f)", self.view.frame.size.width, self.view.frame.size.height);
        
        NSUInteger numberOfPages = _viewControllers.count;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.contentSize =
        CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberOfPages, CGRectGetHeight(self.scrollView.frame));
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.bounces = NO;
        self.scrollView.delegate = self;
        self.scrollView.clipsToBounds = YES;
        
        // pages are created on demand
        // load the visible page
        // load the page on either side to avoid flashes when the user starts scrolling
        //
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
        [self gotoCurrentPage:0 animated:NO];
        
        _hasLoadSubView = YES;
    }
}


- (void)resetScrollView
{
    // remove all the subviews from our scrollview
    for (UIView *view in self.scrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSUInteger numPages = self.viewControllers.count;
    
    // adjust the contentSize (larger or smaller) depending on the orientation
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numPages, CGRectGetHeight(self.scrollView.frame));
    
    // Reset the view controller's frame
    for (int ix = 0; ix < _viewControllers.count; ++ix) {
        UIViewController *controller = _viewControllers[ix];
        if ((NSNull *)controller != [NSNull null]) {
            CGRect frame = self.scrollView.frame;
            frame.origin.x = CGRectGetWidth(frame) * ix;
            frame.origin.y = 0;
            controller.view.frame = frame;
        }
    }
    
    // remain at the same page (don't animate)
    [self gotoCurrentPage:_currentPageIndex animated:NO];
}

- (NSString *)getPageTitle:(int)page
{
    if (page < 9) {
        PageInfo *pageInfo = ((PageGroupInfo *)_pageInfoGroups[0]).pageInfos[page];
        return pageInfo.title;

    } else if (page == 9 || page == 10) {
        PageGroupInfo *pageGroup = ((PageGroupInfo *)_pageInfoGroups[page - 9]);
        return pageGroup.title;
    } else {
        return @"";
    }
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.viewControllers.count)
        return;
    
    // replace the placeholder if necessary
    UIViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        if (page < 9) {
            controller = [[ImageGridViewController alloc] init];
            [self addChildViewController:controller];
            ((ImageGridViewController *)controller).pageInfo = ((PageGroupInfo *)_pageInfoGroups[0]).pageInfos[page];
            ((ImageGridViewController *)controller).isNeedRefreshData = NO;
        } else if (page == 9) {
            controller = [[FavouriteImageViewController alloc] init];
            [self addChildViewController:controller];
            ((FavouriteImageViewController *)controller).isNeedRefreshData = NO;
        } else {
            controller = [[SearchViewController alloc] init];
            [self addChildViewController:controller];
            ((SearchViewController *)controller).isNeedRefreshData = NO;
        }
        
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self.scrollView addSubview:controller.view];
        
        AbsPageViewController *absController = (AbsPageViewController *)controller;
        if (absController.isNeedRefreshData) {
            [absController refreshData];
            absController.isNeedRefreshData = NO;
        }
    }
    
    AbsPageViewController *absController = (AbsPageViewController *)controller;
    if (absController.isNeedRelayout) {
        [absController relayout:absController.currentDisplayMode];
        [absController refreshData];
    }
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // Set current page
    [self gotoCurrentPage:page animated:NO];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)gotoCurrentPage:(int)page animated:(BOOL)animated
{
    _currentPageIndex = page;
    if (page < 0 || page > _viewControllers.count - 1) {
        return;
    }
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
        
    // Set current page
    AbsPageViewController *controller = (AbsPageViewController*)[self.viewControllers objectAtIndex:page];
    [controller initNavigationBar];
    
    if (page < 9) {
        [self.delegate updateControlPanelSection:0 AtIndex:page];
    } else if (page == 9) {
        [self.delegate updateControlPanelSection:1 AtIndex:0];
    } else {
        [self.delegate updateControlPanelSection:2 AtIndex:0];
    }
}

- (void)changeLayout:(NSNotification *)notification
{
    NSNumber *savedLayout = [[NSUserDefaults standardUserDefaults] objectForKey:kCustom_Layout_Key];
    LayoutType displayMode = savedLayout.intValue + 1;
    
    NSNumber *newLayout = (NSNumber *)[notification object];
    switch ([newLayout intValue]) {
        case 0:
            displayMode = kLayoutTypeWaterFlow;
            break;
            
        case 1:
            displayMode = kLayoutTypeGrid;
            break;
            
        case 2:
            displayMode = kLayoutTypeSingleLine;
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i <= 10; i++) {
        if (self.viewControllers[i] != [NSNull null]) {
            AbsPageViewController *controller = (AbsPageViewController*)[self.viewControllers objectAtIndex:i];
            if (displayMode != controller.currentDisplayMode) {
                controller.isNeedRelayout = YES;
                controller.currentDisplayMode = displayMode;
            }
        }
    }
    
    [self gotoCurrentPage:_currentPageIndex animated:NO];
}

- (void)showDetailChanged:(NSNotification *)notification
{
    NSNumber *savedDetail = [[NSUserDefaults standardUserDefaults] objectForKey:kImage_Cell_Show_Detail];
    BOOL showDetail = savedDetail.boolValue;

    NSNumber *needShowDetail = (NSNumber *)[notification object];
    showDetail = needShowDetail.boolValue;
    
    for (int i = 0; i <= 10; i++) {
        if (self.viewControllers[i] != [NSNull null]) {
            AbsPageViewController *controller = (AbsPageViewController*)[self.viewControllers objectAtIndex:i];
            
            if (showDetail != controller.isShowDetail) {
                controller.isNeedRelayout = YES;
                controller.isShowDetail = showDetail;
            }
        }
    }
    
    [self gotoCurrentPage:_currentPageIndex animated:NO];
}

@end
