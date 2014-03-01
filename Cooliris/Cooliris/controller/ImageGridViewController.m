//
//  ImageGridViewController.m
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ImageGridViewController.h"
#import "ImageGroupCell.h"
#import "DetailViewController.h"
#import "ImageDataProvider.h"
#import "ImageGroup.h"
#import "UIImage+UIImage_Extended.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"
#import "MosaicLayout.h"
#import "Toast+UIView.h"
#import "OptionsViewController.h"
#import "UIBarButtonItemEx.h"
#import "UIBarButtonItem+Flat.h"
#import "SearchPopoverBackgroundView.h"
#import "UIViewController+MMDrawerController.h"
#import "PageInfo.h"
#import "ImageGridFooterView.h"
#import "SearchViewController.h"

#define kColumnMargin                   5
#define kColumnCount_Portrait_iPhone    2
#define kColumnCount_Landscape_iPhone   3
#define kColumnCount_Portrait_iPad      3
#define kColumnCount_Landscape_iPad     4

#define kFooterReuseIdentifier          @"ImageGridFooterView"
#define kFooterViewHeight               60

#define kDoubleColumnProbability        40
#define kOptionViewSize                 CGSizeMake(300, 180)

/**
 * The private members and methods.
 */
@interface ImageGridViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView           *imageCollectionView;
@property (strong, nonatomic)        MBProgressHUD              *HUDIndicator;
@property (strong, nonatomic)        EGORefreshTableHeaderView  *refreshHeaderView;
@property (strong, nonatomic)        ImageGridFooterView        *footerView;
@property (strong, nonatomic)        UIPopoverController        *optionPopoverController;
@property (strong, nonatomic)        UINavigationController     *optionNavigationController;
@property (strong, nonatomic)        UIBarButtonItemEx          *layoutButton;

@property (strong, nonatomic)        NSArray                    *imageGroups;
@property (nonatomic)                int                        columnCount;
@property (nonatomic)                CGFloat                    cellWidth;
@property (nonatomic)                BOOL                       isReloading;
@property (nonatomic)                BOOL                       isLoadingMore;
@property (nonatomic)                BOOL                       hasMoreData;

// Action
- (IBAction)layoutButtonTapped:(id)sender;

// Overrided super class method
- (void)initNavigationBar;
- (void)refreshData;

// Initialize layout & UI
- (void)initRefreshHeaderView;
- (void)initCellLayout;
- (void)loadDefaultData;

- (int)calcuateColumnCount:(UIInterfaceOrientation)orientation;
- (CGFloat)calcuateCellWidth:(int)columnCount inOrientation:(UIInterfaceOrientation)orientation;
- (void)resetCollectionViewLayout:(UIInterfaceOrientation)orientation;
- (void)relayout:(LayoutType)layoutType;

- (void)loadMoreNewData;
- (void)loadMoreOldData;
- (void)completedLoadMore;

@end

@implementation ImageGridViewController

#pragma mark - Controller life cycle

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
    
    // 1. Initialize layout & UI
    // 2. Load default data
    [self initNavigationBar];
    [self initRefreshHeaderView];
    [self initCellLayout];
    [self loadDefaultData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SDWebImageManager sharedManager] cancelAll];
    self.isNeedRefreshData = YES;
    NSLog(@"Image Gird View: viewDidDisappear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    //[self resetCollectionViewLayout:toInterfaceOrientation];
    MosaicLayout *layout = (MosaicLayout *)self.imageCollectionView.collectionViewLayout;
    [layout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{    
    //[self resetCollectionViewLayout:self.interfaceOrientation];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageGroups count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    MosaicLayout *layout = (MosaicLayout *)self.imageCollectionView.collectionViewLayout;
//    NSLog(@"%f, %f", layout.headerReferenceSize.width, layout.headerReferenceSize.height);
//    NSLog(@"%f, %f", layout.footerReferenceSize.width, layout.footerReferenceSize.height);
    
    ImageGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier
                                                                     forIndexPath:indexPath];
    if (self.currentDisplayMode == kLayoutTypeSingleLine) {
        [cell setFrameSingleLine];
    } else {
        if (self.isShowDetail) {
            [cell setFrameDetail];
        } else {
            [cell setFrameNoDetail];
        }
    }
    
    cell.imageData = self.imageGroups[indexPath.row];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {        
        UICollectionReusableView *footer =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                           withReuseIdentifier:kFooterReuseIdentifier
                                                  forIndexPath:indexPath];
        
        _footerView = (ImageGridFooterView *)footer;
        
        return footer;
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *detailPhotoStoryboard = [UIStoryboard storyboardWithName:@"DetailViewController"
                                                                    bundle:nil];
    DetailViewController *controller = [detailPhotoStoryboard instantiateInitialViewController];
    controller.currentGroupIndex = [indexPath row];
    controller.currentPageCategory = _pageInfo.title;
    [self.parentViewController.navigationController presentViewController:controller animated:YES completion:nil];
    //[self.parentViewController.navigationController pushViewController:controller animated:YES];
    
    for (NSIndexPath *indexPath in self.imageCollectionView.indexPathsForSelectedItems) {
        [self.imageCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Do nothing
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    //    float height = _imageCollectionView.frame.size.height;
    //    height = _imageCollectionView.contentSize.height;
    //    NSLog(@"frame height = %f, content height = %f, content offset.y = %f",
    //          _imageCollectionView.frame.size.height,
    //          _imageCollectionView.contentSize.height,
    //          _imageCollectionView.contentOffset.y);
    
    if (!_isLoadingMore && _hasMoreData) {
        CGSize contentSize = _imageCollectionView.contentSize;
        CGSize frameSize = _imageCollectionView.frame.size;
        CGPoint contentOffset = _imageCollectionView.contentOffset;
        float scrollPos = contentSize.height - frameSize.height - contentOffset.y;
        
        //if (scrollPos < footer.frame.height) {
        if (scrollPos < kFooterViewHeight) {
            [self loadMoreOldData];
        }
    }
}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self loadMoreNewData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return self.isReloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

#pragma mark - MosaicLayoutDelegate

- (float)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //  Base relative height for simple layout type. This is 1.0 (height equals to width)
    float retVal = 1.0;
    
    //NSMutableArray *self.elements = [(CustomDataSource *)_collectionView.dataSource elements];
    ImageGroup *imageGroup = [self.imageGroups objectAtIndex:indexPath.row];
    
    if (kLayoutTypeSingleLine == self.currentDisplayMode) {
        if (INTERFACE_IS_PHONE) {
            imageGroup.relativeHeight = 1;
            imageGroup.layoutType = kWaterFlowLayoutTypeSingle;
            retVal = 0.3;
        } else {
            imageGroup.relativeHeight = 1;
            imageGroup.layoutType = kWaterFlowLayoutTypeSingle;
            retVal = 0.16;
        }
    } else {
        if (kLayoutTypeGrid == self.currentDisplayMode) {
            imageGroup.relativeHeight = 1;
            imageGroup.layoutType = kWaterFlowLayoutTypeSingle;
            retVal = 1;
            
        } else {
            
            if (imageGroup.relativeHeight != 0 && imageGroup.relativeHeight != 1) {
                
                //  If the relative height was set before, return it
                retVal = imageGroup.relativeHeight;
                
            }else{
                
                BOOL isDoubleColumn = [self collectionView:collectionView isDoubleColumnAtIndexPath:indexPath];
                if (isDoubleColumn) {
                    //  Base relative height for double layout type. This is 0.75 (height equals to 75% width)
                    retVal = 0.75;
                }
                
                /*  Relative height random modifier. The max height of relative height is 25% more than
                 *  the base relative height */
                
                float extraRandomHeight = arc4random() % 25;
                retVal = retVal + (extraRandomHeight / 100);
                
                /*  Persist the relative height on MosaicData so the value will be the same every time
                 *  the mosaic layout invalidates */
                
                imageGroup.relativeHeight = retVal;
            }
        }
        
        if (self.isShowDetail) {
            CGFloat ret = INTERFACE_IS_PHONE ? 1.8 : 1.5;
            retVal = retVal * ret;
        }
    }
    
    return retVal;
}

- (BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath
{
    ImageGroup *imageGroup = [self.imageGroups objectAtIndex:indexPath.row];
    
    if (imageGroup.layoutType == kWaterFlowLayoutTypeUndefined) {
        
        /*  First layout. We have to decide if the MosaicData should be
         *  double column (if possible) or not. */
        
        NSUInteger random = arc4random() % 100;
        if (random < kDoubleColumnProbability) {
            imageGroup.layoutType = kWaterFlowLayoutTypeDouble;
        }else{
            imageGroup.layoutType = kWaterFlowLayoutTypeSingle;
        }
    }
    
    return (imageGroup.layoutType == kWaterFlowLayoutTypeDouble);
}

- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView
{
    
    UIInterfaceOrientation anOrientation = self.interfaceOrientation;
    
    //  Set the quantity of columns according of the device and interface orientation
    NSUInteger retVal = 0;
    if (kLayoutTypeSingleLine == self.currentDisplayMode) {
        retVal = 1;
    } else {
        if (UIInterfaceOrientationIsLandscape(anOrientation)) {
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                retVal = kColumnCount_Landscape_iPad;
            } else {
                retVal = kColumnCount_Landscape_iPhone;
            }
            
        } else {
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                retVal = kColumnCount_Portrait_iPad;
            } else {
                retVal = kColumnCount_Portrait_iPhone;
            }
        }
    }
    
    return retVal;
}

- (float)minimumInteritemSpacingInCollectionView:(UICollectionView *)collectionView
{
    if (self.currentDisplayMode != kLayoutTypeSingleLine && self.isShowDetail) {
        return INTERFACE_IS_PHONE ? 10 : 25;
    }
    
    return 0;
}

#pragma mark - Private methods

- (void)initNavigationBar
{
    // Set up the navigation bar item
    self.parentViewController.navigationItem.titleView = nil;
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
    self.parentViewController.navigationItem.title = _pageInfo.title;
    self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                               initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                               target:self
                                                               action:@selector(layoutButtonTapped:)];
}

- (void)refreshData
{  
    [self.imageCollectionView reloadData];
}

- (void)initRefreshHeaderView
{
    // Initialize refresh header view
    CGFloat height      = self.imageCollectionView.bounds.size.height;
    CGFloat width       = self.imageCollectionView.bounds.size.width;
    CGRect frame = CGRectMake(0, 0 - height, width, height);
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:frame
                                                               arrowImageName:@"blackArrow.png"
                                                                    textColor:[UIColor blackColor]];
    self.refreshHeaderView.delegate        = self;
    self.refreshHeaderView.backgroundColor = [UIColor whiteColor];
    [self.imageCollectionView addSubview:self.refreshHeaderView];
    [self.refreshHeaderView refreshLastUpdatedDate];
}

- (void)initCellLayout
{
    // Default display mode is |kGroupsLayoutTypeWaterFlow|
    NSNumber *savedLayout = [[NSUserDefaults standardUserDefaults] objectForKey:kCustom_Layout_Key];
    if (nil == savedLayout) {
        self.currentDisplayMode = kLayoutTypeWaterFlow;
    } else {
        self.currentDisplayMode = [savedLayout intValue] + 1;
    }
    
    self.isShowDetail = [[NSUserDefaults standardUserDefaults] boolForKey:kImage_Cell_Show_Detail];
//    _currentDisplayMode = kGroupsLayoutTypeWaterFlow;
    
    // Initialize collection view's column and width
    self.columnCount = [self calcuateColumnCount:self.interfaceOrientation];
    self.cellWidth = [self calcuateCellWidth:self.columnCount inOrientation:self.interfaceOrientation];
    
    // Set layout
    MosaicLayout *layout = (MosaicLayout *)self.imageCollectionView.collectionViewLayout;
    [layout setDelegate:self];
    
    // Register the collection view cell & footer
    UINib *nib = [UINib nibWithNibName:kCellNibName bundle:nil];
    [self.imageCollectionView registerNib:nib forCellWithReuseIdentifier:kCellIdentifier];
    
    nib = [UINib nibWithNibName:kFooterReuseIdentifier bundle:nil];
    [self.imageCollectionView registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                      withReuseIdentifier:kFooterReuseIdentifier];
    
    // Set header and footer size
    //layout.headerReferenceSize = CGSizeMake(0, 300);
    layout.footerReferenceSize = CGSizeMake(0, kFooterViewHeight);
}

- (void)loadDefaultData
{
    NSLog(@"loadDefaultData, title = %@", _pageInfo.title);
    _hasMoreData = YES;
    
    // Begin to load image data async
    // Befor load data, we ignoring user interaction event
    NSArray *groups = [[ImageDataProvider sharedInstance] getImageGroupsByCategory:_pageInfo.title];
    if (!groups || 0 == groups.count) {
        // Begin to load image data async
        // Befor load data, we ignoring user interaction event
        //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        self.HUDIndicator = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.HUDIndicator];
        // self.HUDIndicator.dimBackground = YES;
        [self.HUDIndicator show:YES];
        
        [[ImageDataProvider sharedInstance] loadImageGroupsAsync:_pageInfo.title completed:^(NSArray *resultImageList, NSError *error) {
            if (!error) {
                self.imageGroups = [[ImageDataProvider sharedInstance] getImageGroupsByCategory:_pageInfo.title];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.HUDIndicator hide:YES];
                //[[UIApplication sharedApp00lication] endIgnoringInteractionEvents];
                
                // Reload image collection data
                [self.imageCollectionView reloadData];
            });
        }];
    } else {
        self.imageGroups = groups;
        [self.imageCollectionView reloadData];
    }
}

#pragma mark - Button Handlers

- (IBAction)layoutButtonTapped:(id)sender
{
    if (INTERFACE_IS_PHONE) {
        if (nil == _optionNavigationController) {
            OptionsViewController *optionViewController = [[OptionsViewController alloc] init];
            optionViewController.contentSizeForViewInPopover = kOptionViewSize;
            
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                           initWithTitle:@"Back"
                                           style:UIBarButtonItemStyleDone
                                           target:self
                                           action:@selector(optionsDoneAction)];
            optionViewController.navigationItem.leftBarButtonItem = backButton;
            
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                           initWithTitle:@"Done"
                                           style:UIBarButtonItemStyleDone
                                           target:self
                                           action:@selector(optionsDoneAction)];
            optionViewController.navigationItem.rightBarButtonItem = doneButton;
            
            _optionNavigationController = [[UINavigationController alloc]
                                           initWithRootViewController:optionViewController];
        }
        
        [self presentViewController:_optionNavigationController animated:YES completion:nil];
        
    } else {
        
        if (nil == _optionPopoverController) {
            OptionsViewController *optionViewController = [[OptionsViewController alloc] init];
            optionViewController.contentSizeForViewInPopover = kOptionViewSize;
            
            _optionPopoverController = [[UIPopoverController alloc] initWithContentViewController:optionViewController];
            _optionPopoverController.popoverBackgroundViewClass = [SearchPopoverBackgroundView class];
        }
        
        if (!_optionPopoverController.isPopoverVisible) {
            // Present the popover from the button that was tapped in the detail view.
            [_optionPopoverController presentPopoverFromBarButtonItem:sender
                                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                                             animated:YES];
        } else {
            [_optionPopoverController dismissPopoverAnimated:YES];
        }
    }
}

- (int)calcuateColumnCount:(UIInterfaceOrientation)orientation
{
    BOOL isPhone = UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom];
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
    int columnCount = kColumnCount_Portrait_iPhone;
    
    if (isPhone) {
        columnCount = isPortrait ? kColumnCount_Portrait_iPhone : kColumnCount_Landscape_iPhone;
    } else {
        columnCount = isPortrait ? kColumnCount_Portrait_iPad : kColumnCount_Landscape_iPad;
    }
    
    return columnCount;
}

- (CGFloat)calcuateCellWidth:(int)columnCount inOrientation:(UIInterfaceOrientation)orientation
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
    
    // The width is not correct if current orientation is Landscape,
    // so we use screen width to calcuate the cell width.
    //CGFloat frameWidth = self.imageCollectionView.frame.size.width;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat frameWidth = isPortrait ? screenSize.width : screenSize.height;
    //CGFloat cropWidth = floorf((frameWidth - (columnCount + 1) * kColumnMargin) / columnCount);
    CGFloat cellWidth = (frameWidth - (columnCount + 1) * kColumnMargin) / columnCount;
    
    return cellWidth;
}

- (void)resetCollectionViewLayout:(UIInterfaceOrientation)orientation
{
    self.columnCount = [self calcuateColumnCount:orientation];
    self.cellWidth = [self calcuateCellWidth:self.columnCount inOrientation:orientation];
    
    UICollectionViewFlowLayout *oldLayout = (UICollectionViewFlowLayout *)self.imageCollectionView.collectionViewLayout;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing  = oldLayout.minimumInteritemSpacing;
    layout.minimumLineSpacing       = oldLayout.minimumLineSpacing;
    layout.sectionInset             = oldLayout.sectionInset;
    layout.scrollDirection          = oldLayout.scrollDirection;
    layout.itemSize                 = CGSizeMake(self.cellWidth, self.cellWidth);
    //layout.sectionInset = UIEdgeInsetsMake(kColumnMargin, kColumnMargin, kColumnMargin, kColumnMargin);
    
    [self.imageCollectionView setCollectionViewLayout:layout];
    //[self.imageCollectionView setCollectionViewLayout:layout animated:YES];
}

- (void)relayout:(LayoutType)layoutType
{
    self.currentDisplayMode = layoutType;
    for (ImageGroup *group in self.imageGroups) {
        group.layoutType = kWaterFlowLayoutTypeUndefined;
    }
    
    //MosaicLayout *layout = (MosaicLayout *)self.imageCollectionView.collectionViewLayout;
    [self.imageCollectionView performBatchUpdates:^{}
                                       completion:^(BOOL finished){
                                           if (finished) {
                                               self.isNeedRelayout = NO;
                                           }
                                       }];
    //[layout invalidateLayout];
}

- (void)optionsDoneAction
{
    if (INTERFACE_IS_PHONE) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
    }
}

- (void)loadMoreNewData
{
    // Do nothing if current is reloading data
    if (_isReloading) {
        return;
    }
    
    // Set the reloading flag into |YES| before fetching data
    _isReloading = YES;
    [[ImageDataProvider sharedInstance]
     loadMoreImageGroupsAsync:_pageInfo.title
     withCount:_columnCount
     loadOldData:NO
     completed:^(NSArray *results, NSError *error) {
         
         // Make the loading take's more time
         [NSThread sleepForTimeInterval:1];
         NSLog(@"Has loaded data");
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             // Stop the header view
             [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.imageCollectionView];
             
             // Reload collection view with animation
             int count = (nil == results) ? 0 : results.count;
             if (0 == count) {
                 _isReloading = NO;
                 // Toast: No more data
                 [self.view makeToast:NSLocalizedString(@"no_more_images", @"no_more_images")];
                 
             } else {
                 NSMutableArray *indexPaths = [@[] mutableCopy];
                 for (int ix = 0; ix < count; ++ix) {
                     [indexPaths addObject:[NSIndexPath indexPathForRow:ix inSection:0]];
                 }
                 
                 [self.imageCollectionView performBatchUpdates:^{
                     // Do insert animation
                     [self.imageCollectionView insertItemsAtIndexPaths:indexPaths];
                 } completion:^(BOOL finished) {
                     
                     // Set the reloading flag into |NO| after fetched data and reset UI
                     _isReloading = NO;
                     
//                     [[NSUserDefaults standardUserDefaults] setInteger:<#(NSInteger)#> forKey:_pageInfo.title];
//                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                 }];
             }
         });
     }];
}

- (void)loadMoreOldData
{
    // 1. Footer view'll start indicator
    [_footerView startLoading];
    _isLoadingMore = YES;
    
    // 2. Async load more data
    [[ImageDataProvider sharedInstance]
     loadMoreImageGroupsAsync:_pageInfo.title
     withCount:_columnCount * 5
     loadOldData:YES
     completed:^(NSArray *results, NSError *error) {
         // Make the loading take's more time
         //[NSThread sleepForTimeInterval:5];
         NSLog(@"Has loaded old data");
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             // Reload collection view with animation
             //[self.imageCollectionView reloadData];
             _isLoadingMore = NO;
             
             int count = (nil == results) ? 0 : results.count;
             if (0 == count) {
                 // Set the footer view' text
                 _hasMoreData = NO;
                 [_footerView completedLoading:NSLocalizedString(@"no_more_old_images", @"no_more_old_images")];
             } else {
                 [_footerView completedLoading];
                 [_imageCollectionView reloadData];
                 //[self.imageCollectionView performBatchUpdates:^{} completion:^(BOOL finished){}];
             }
         });
     }];
}

- (void)completedLoadMore
{
    [_footerView completedLoading];
    _isLoadingMore = NO;
}

@end
