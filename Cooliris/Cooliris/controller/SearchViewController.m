//
//  SearchViewController.m
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "SearchViewController.h"
#import "JsonObject.h"
#import "MosaicCell.h"
#import "MosaicData.h"
#import "MosaicLayout.h"
#import "Toast+UIView.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "ImageDBOperator.h"
#import "Image.h"
#import "FavouriteDBOperator.h"
#import "SearchOptionsViewController.h"
#import "SearchPopoverBackgroundView.h"
#import "UIBarButtonItem+Flat.h"

#define SearchHeader @"http://image.baidu.com/i?tn=baiduimagejson&ct=201326592&cl=2&lm=-1&st=-1&fm=result&fr=&sf=1&fmq=1349413075627_R&pv=&ic=0&nc=1&z=&se=1&showtab=0&fb=0&face=0&istype=2&ie=utf-8"

#define kMargin                            5
#define kColumnCount_Portrait_iPhone       2
#define kColumnCount_Landscape_iPhone      3
#define kColumnCount_Portrait_iPad         3
#define kColumnCount_Landscape_iPad        4
#define Search_Title_Height_Iphone_Land    32
#define kDoubleColumnProbability           40
#define Search_Title_Height_Normal         44
#define Search_Request_Count               20
#define Search_Request_Max_Page            100
#define Search_Delay_Refresh_Time          1.6

typedef enum {
    SearchTypeNet = 0,
    SearchTypeLocal
} SearchType;

@interface SearchViewController ()
{
    FavouriteDBOperator *operator;
}

@property (strong, nonatomic) NSMutableURLRequest *request;
@property (strong, atomic) NSMutableArray *resultDataSource;
@property (strong, nonatomic) NSMutableArray *selectedImages;
@property (strong, atomic) NSMutableArray *resultArticlesDataSource;
@property (strong, nonatomic) NSArray *allTagsArray;

@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isZooming;
@property (nonatomic) BOOL isLocalSearch;
@property (nonatomic) int currentPageIndex;
@property (nonatomic) int currentArticleIndex;
@property (atomic)    int newImagesCount;
@property (nonatomic) int customResolutionWidth;
@property (nonatomic) int customResolutionHeight;
@property (nonatomic) int selectedResolutionIndex;
@property (strong, nonatomic) NSString *lastKeyWord;
@property (nonatomic) NSIndexPath *selectedIndex;
@property (nonatomic) NSIndexPath *lastSearchSourceIndex;

#pragma mark - IBOutlet

@property (strong, nonatomic) UIBarButtonItem *searchOptionBarBtn;
@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property (strong, nonatomic) IBOutlet UICollectionView *resultView;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) UIView   *buttonView;
@property (strong, nonatomic) UIButton *favoriteButton;
@property (strong, nonatomic) UIButton *downloadButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIPopoverController *popOverController;
@property (strong, nonatomic) UINavigationController *popNavController;
@property (strong, nonatomic) UIView *shadow;

#pragma mark - Thirdparty View

@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
@property (strong, nonatomic) MBProgressHUD *searchProgressHUD;
@property (strong, nonatomic) MosaicCell *fullScreenCell;

#pragma mark - Methods Declare

// Overrided super class method
- (void)initNavigationBar;
- (void)refreshData;

- (void)initVariable;
- (void)initSubviews;
- (void)initButtonView;
- (void)resetButtonViewFrame;
- (void)initLayout;
- (void)reloadDataSource;
- (void)search:(NSString *)url;
- (void)searchDB:(NSString *)tag;
- (void)parseResult:(NSData *)result;
- (BOOL)islocalTag:(NSString *)tag;
- (NSArray *)getAllTags;
- (MosaicData *)parseImage:(JsonObject *)json;
- (NSString *)encodeURLParam:(NSString *)param;
- (int)calcuateColumnCount:(UIInterfaceOrientation)orientation;
- (NSString *)createUrl:(NSString *)keyWord withPageIndex:(int)pageIndex;
- (CGFloat)calcuateCellWidth:(int)columnCount inOrientation:(UIInterfaceOrientation)orientation;

- (IBAction)addOrDeleteFavorite:(id)sender;
- (IBAction)downloadPhoto:(id)sender;
- (IBAction)sharePhoto:(id)sender;

@end

@implementation SearchViewController

#pragma mark  Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark- LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initVariable];
    [self initLayout];
    [self initNavigationBar];
    [self initButtonView];
    
    self.shadow = [[UIView alloc] initWithFrame:self.view.bounds];
    self.shadow.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7].CGColor;
    [self.resultView addSubview:self.shadow];
    self.shadow.alpha = 0;
    self.shadow.hidden = YES;
    
    // Init subview HeadRefreshView / ProgressView / MosaicCell
    [self initSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![self.searchbar isFirstResponder] && (nil == self.resultDataSource ||
                                               0 == [self.resultDataSource count])) {
        //[self.searchbar becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SDWebImageManager sharedManager] cancelAll];
    self.shadow.alpha = 0;
    self.shadow.hidden = YES;
    self.buttonView.alpha = 0;
    self.resultView.scrollEnabled = YES;
    self.isZooming = NO;
    self.isNeedRefreshData = YES;
}

- (void)viewDidLayoutSubviews
{
    [self resetButtonViewFrame];
    self.shadow.frame = self.view.bounds;
}

#pragma mark - System Methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    MosaicLayout *layout = (MosaicLayout *)self.resultView.collectionViewLayout;
    [layout invalidateLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Collectionview DataSource Method

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.resultDataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *forRecyle = @"cell";
    MosaicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:forRecyle
                                                                forIndexPath:indexPath];
    
    MosaicData *image = [self.resultDataSource objectAtIndex:[indexPath row]];
    cell.mosaicData = image;

    float randomWhite = (arc4random() % 40 + 10) / 255.0;
    cell.backgroundColor = [UIColor colorWithWhite:randomWhite alpha:1];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.fadeIn = YES;
    [cell.imageView setImageWithURL:[NSURL URLWithString:cell.mosaicData.imageFilename]
                   placeholderImage:nil
                            options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    
    return cell;
}

#pragma mark - MosaicLayoutDelegate Method

- (float)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Base relative height for simple layout type. This is 1.0 (height equals to width)
    float retVal = 1.0;
    
    // NSMutableArray *self.elements = [(CustomDataSource *)_collectionView.dataSource elements];
    MosaicData *aMosaicModule = [self.resultDataSource objectAtIndex:indexPath.row];
    
    if (kLayoutTypeGrid== self.currentDisplayMode || kLayoutTypeSingleLine == self.currentDisplayMode) {
        aMosaicModule.relativeHeight = 1;
        aMosaicModule.layoutType = kMosaicLayoutTypeSingle;
        retVal = 1;
        
    } else {
    
        if (aMosaicModule.relativeHeight != 0 && aMosaicModule.relativeHeight != 1) {
        
            //  If the relative height was set before, return it
            retVal = aMosaicModule.relativeHeight;
        
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
        
            aMosaicModule.relativeHeight = retVal;
        }
    }
    return retVal;
}

- (BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath
{
    // NSMutableArray *elements = [(CustomDataSource *)_collectionView.dataSource elements];
    MosaicData *aMosaicModule = [self.resultDataSource objectAtIndex:indexPath.row];
    
    if (aMosaicModule.layoutType == kMosaicLayoutTypeUndefined) {
        
        /*  First layout. We have to decide if the MosaicData should be
         *  double column (if possible) or not. */
        
        NSUInteger random = arc4random() % 100;
        if (random < kDoubleColumnProbability) {
            aMosaicModule.layoutType = kMosaicLayoutTypeDouble;
        }else{
            aMosaicModule.layoutType = kMosaicLayoutTypeSingle;
        }
    }
    
    BOOL retVal = aMosaicModule.layoutType == kMosaicLayoutTypeDouble;
    
    return retVal;
}

- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView
{
    UIInterfaceOrientation anOrientation = self.interfaceOrientation;
    
    //  Set the quantity of columns according of the device and interface orientation
    NSUInteger retVal = 0;
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
    
    return retVal;
}

- (float)minimumInteritemSpacingInCollectionView:(UICollectionView *)collectionView
{
    return 0;
}

#pragma mark - UIClllectionView Delegate Method

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.resultView.scrollEnabled = NO;
    self.shadow.frame = CGRectMake(0, self.resultView.contentOffset.y, self.view.bounds.size.width, self.view.bounds.size.height);
    self.shadow.hidden = NO;
    if (!self.isZooming) {
        self.isZooming = YES;
        self.selectedIndex = indexPath;
        //    static BOOL isZoomed = NO;
        MosaicCell *cell = (MosaicCell *)[self.resultView cellForItemAtIndexPath:indexPath];
        
        // Check the select image is favourite or not.
        if (!cell.mosaicData.isLocalImage) {
            cell.mosaicData.isFavourite =  [operator netImageIsFavourite:cell.mosaicData];
        }
        [self updateFavouriteBtnImageByImg:cell.mosaicData];
        
        CGSize screenSize  = self.resultView.bounds.size;
        float imageAspect;
        if (cell.image) {
            imageAspect  = cell.image.size.width / cell.image.size.height;
            self.favoriteButton.enabled = YES;
            self.downloadButton.enabled = YES;
            self.shareButton.enabled = YES;
        } else {
            imageAspect  = cell.bounds.size.width / cell.bounds.size.height;
            self.favoriteButton.enabled = NO;
            self.downloadButton.enabled = NO;
            self.shareButton.enabled = NO;
        }
        
        float screenAspect = screenSize.width / screenSize.height;
        
        CGRect newFrame;
        if (imageAspect < screenAspect) {
            // Image is too tall, image will fill the screen height
            float newH = screenSize.height;
            float newW = screenSize.height * imageAspect;
            newFrame = CGRectMake((screenSize.width - newW) / 2, 0 + self.resultView.contentOffset.y, newW, newH);
            
        } else if (imageAspect > screenAspect) {
            // Image is too width, image will fill the screen width
            float newW = screenSize.width;
            float newH = screenSize.width / imageAspect;
            newFrame = CGRectMake(0, (screenSize.height - newH) / 2 + self.resultView.contentOffset.y, newW, newH);
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [self.resultView bringSubviewToFront:cell];
            // cell.transform = CGAffineTransformMake(newFrame.size.width / , 0, 0, 1.5, 200, 200);
            // cell.transform = CGAffineTransformMake(1.5, 0, 0, 1.5, 200, 200);
            cell.orignalFrame  = cell.frame;
            cell.orignalCenter = cell.center;
            cell.frame = newFrame;
            self.fullScreenCell = cell;
            self.buttonView.alpha = 1;
            self.shadow.alpha = 1;
            
        } completion:^(BOOL finished) {
        }];
        
    } else {
        [UIView animateWithDuration:0.3 animations:^{

            // cell.transform = CGAffineTransformMake(1.0, 0, 0, 1.0, 0, 0);
            self.fullScreenCell.frame = self.fullScreenCell.orignalFrame;
            self.fullScreenCell.center= self.fullScreenCell.orignalCenter;
            self.buttonView.alpha = 0;
            self.shadow.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [self.resultView sendSubviewToBack:self.fullScreenCell];
            self.isZooming = NO;
            self.shadow.hidden = YES;
            self.resultView.scrollEnabled = YES;
        }];
    }
}

#pragma mark - SearBarDelegate Method

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (self.popOverController.isPopoverVisible) {
        [self.popOverController dismissPopoverAnimated:YES];
    }
    [searchBar resignFirstResponder];
    
    // Ready to search.
    if (self.isLocalSearch) {
        if ([self islocalTag:searchBar.text]) {
            
            // Search From DB.
            if (![self.lastKeyWord isEqualToString:searchBar.text] || -1 == self.currentArticleIndex) {
                self.lastKeyWord = searchBar.text;
                [self searchDB:self.searchbar.text];
            } else {
                [self reloadDataSource];
            }
        } else {
            [self.view makeToast:NSLocalizedString(@"change_to_internet", "Click tag or change to net search")];
        }
        
    } else {
        
        // Search From internet.
        if ( nil != [searchBar text]) {
            
            if (![_lastKeyWord isEqualToString:searchBar.text]) {
                self.currentPageIndex = 1;
                self.lastKeyWord      = searchBar.text;
            }
            NSString *key         = [self encodeURLParam:searchBar.text];
            NSString *requestUrl  = [self createUrl:key withPageIndex:self.currentPageIndex];
            [self search:requestUrl];
        }
    }
}

#pragma mark - Private Method

- (void)initSubviews
{
    // Register CollectoinView Cell.
    UINib *nib = [UINib nibWithNibName:@"MosaicCell" bundle:nil];
    [self.resultView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    MosaicLayout *layout = [[MosaicLayout alloc] init];
    layout.delegate = self;
    self.resultView.collectionViewLayout = layout;
    
    // Init Refresh View.
    if (nil == self.refreshHeaderView) {
        NSString *imageName = @"blackArrow";
        CGFloat height      = self.resultView.bounds.size.height;
        CGFloat width       = self.view.frame.size.width;
        CGRect frame = CGRectMake(0, 0 - height, width, height);
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:frame
                                                                            arrowImageName:imageName
                                                                                 textColor:[UIColor blackColor]];
        view.delegate          = self;
        view.backgroundColor   = [UIColor whiteColor];
        [self.resultView addSubview:view];
        self.refreshHeaderView = view;
        [self.refreshHeaderView refreshLastUpdatedDate];
    }
    
    // Init processgress view.
    self.searchProgressHUD = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.searchProgressHUD];
}

- (void)initNavigationBar
{
    // Set up the navigation bar item
    [self.parentViewController.navigationItem setTitleView:self.titleView];    
    NSString *title = NSLocalizedString(@"search_option", @"Search Options");
    self.searchOptionBarBtn = [[UIBarButtonItem alloc] initWithTitle:title
                                                               style:UIBarButtonItemStyleBordered target:self
                                                              action:@selector(dropDown:)];
    [self.searchOptionBarBtn removeTitleShadow];
    self.parentViewController.navigationItem.rightBarButtonItem = self.searchOptionBarBtn;
}

- (void)refreshData
{
    [self.resultView reloadData];
}

- (void)initButtonView
{
    CGFloat centerHeight = self.view.bounds.size.height / 2.0 - 44;
    CGFloat buttonWidth = INTERFACE_IS_PHONE ? 35 : 50;
    CGFloat buttonSpace = INTERFACE_IS_PHONE ? 5 : 12;
    CGFloat leftSpace = INTERFACE_IS_PHONE ? 2 : 4;
    
    self.buttonView = [[UIView alloc]
                       initWithFrame:CGRectMake(leftSpace,
                                                44,
                                                buttonWidth,
                                                self.view.bounds.size.height - 44)];
    
    self.downloadButton = [[UIButton alloc]
                           initWithFrame:CGRectMake(leftSpace,
                                                    centerHeight - buttonWidth/2.0,
                                                    buttonWidth,
                                                    buttonWidth)];
    self.favoriteButton = [[UIButton alloc]
                           initWithFrame:CGRectMake(leftSpace,
                                                    self.downloadButton.frame.origin.y - buttonSpace - buttonWidth,
                                                    buttonWidth,
                                                    buttonWidth)];
    self.shareButton = [[UIButton alloc]
                        initWithFrame:CGRectMake(leftSpace,
                                                 self.downloadButton.frame.origin.y + buttonWidth +buttonSpace,
                                                 buttonWidth,
                                                 buttonWidth)];
    NSString *favImageName = INTERFACE_IS_PHONE ? @"Icon_heart" : @"Icon_heart_ipad";
    [self.favoriteButton setImage:[UIImage imageNamed:favImageName]
                         forState:UIControlStateNormal];
    [self.favoriteButton setImage:[UIImage imageNamed:favImageName]
                         forState:UIControlStateHighlighted];
    [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"Icon_button_bg"]
                                   forState:UIControlStateNormal];
    
    NSString *downImageName = INTERFACE_IS_PHONE ? @"Icon_download" : @"Icon_download_ipad";
    [self.downloadButton setImage:[UIImage imageNamed:downImageName]
                         forState:UIControlStateNormal];
    [self.downloadButton setImage:[UIImage imageNamed:downImageName]
                         forState:UIControlStateHighlighted];
    [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"Icon_button_bg"]
                                   forState:UIControlStateNormal];
    
    NSString *shareImageName = INTERFACE_IS_PHONE ? @"Icon_share" : @"Icon_share_ipad";
    [self.shareButton setImage:[UIImage imageNamed:shareImageName]
                      forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage imageNamed:shareImageName]
                      forState:UIControlStateHighlighted];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"Icon_button_bg"]
                                forState:UIControlStateNormal];
    
    [self.view addSubview:self.buttonView];
    self.buttonView.alpha = 0;
    [self.buttonView addSubview:self.favoriteButton];
    [self.buttonView addSubview:self.downloadButton];
    [self.buttonView addSubview:self.shareButton];
    [self.favoriteButton addTarget:self
                            action:@selector(addOrDeleteFavorite:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.downloadButton addTarget:self
                            action:@selector(downloadPhoto:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self
                         action:@selector(sharePhoto:)
               forControlEvents:UIControlEventTouchUpInside];
}

- (void)resetButtonViewFrame
{
    CGFloat centerHeight = self.view.bounds.size.height / 2.0 - 44;
    CGFloat buttonWidth = INTERFACE_IS_PHONE ? 35 : 50;
    CGFloat buttonSpace = INTERFACE_IS_PHONE ? 5 : 12;
    CGFloat leftSpace = INTERFACE_IS_PHONE ? 2 : 4;
    
    self.buttonView.frame = CGRectMake(leftSpace,
                                       44,
                                       buttonWidth,
                                       self.view.bounds.size.height - 44);
    
    self.downloadButton.frame = CGRectMake(leftSpace,
                                           centerHeight - buttonWidth/2.0,
                                           buttonWidth,
                                           buttonWidth);
    self.favoriteButton.frame = CGRectMake(leftSpace,
                                           self.downloadButton.frame.origin.y - buttonSpace - buttonWidth,
                                           buttonWidth,
                                           buttonWidth);
    self.shareButton.frame = CGRectMake(leftSpace,
                                        self.downloadButton.frame.origin.y + buttonWidth +buttonSpace,
                                        buttonWidth,
                                        buttonWidth);
}

- (void)initVariable
{
    //Init Variable.
    self.currentPageIndex         = 1;
    self.currentArticleIndex      = -1;
    self.selectedResolutionIndex  = -1;
    self.customResolutionHeight   = -1;
    self.customResolutionWidth    = -1;
    self.isLoading                = NO;
    self.isZooming                = NO;
    self.isLocalSearch            = NO;
    self.lastKeyWord              = @"";
    self.resultDataSource         = [[NSMutableArray alloc] init];
    self.request                  = [[NSMutableURLRequest alloc] init];
    self.selectedImages           = [[NSMutableArray alloc] init];
    self.resultArticlesDataSource = [[NSMutableArray alloc] init];
    self.allTagsArray             = [self getAllTags];
    operator = [[FavouriteDBOperator alloc] initWithName:@"favourite" nDBVersion:1];
}

- (void)initLayout
{    
    // Get the user selected UILayout.
    NSNumber *savedLayout = [[NSUserDefaults standardUserDefaults] objectForKey:kCustom_Layout_Key];
    self.currentDisplayMode = (nil == savedLayout) ? kLayoutTypeWaterFlow : [savedLayout intValue] ;
    if (nil == savedLayout) {
        self.currentDisplayMode = kLayoutTypeWaterFlow;
    } else {
        switch ([savedLayout intValue]) {
            case 0:
                self.currentDisplayMode = kLayoutTypeWaterFlow;
                break;
                
            case 1:
                self.currentDisplayMode = kLayoutTypeGrid;
                break;
                
            case 2:
                self.currentDisplayMode = kLayoutTypeSingleLine;
                break;
                
            default:
                break;
        }
    }
}

- (BOOL)islocalTag:(NSString *)tag
{
    tag = [tag stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [self.allTagsArray containsObject:tag];
}

- (NSArray *)getAllTags
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LocalTags" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSArray *tags = [data objectForKey:@"tags"];
    return tags;
}

- (void)searchDB:(NSString *)tag
{
    if (nil == self.resultArticlesDataSource) {
        self.resultArticlesDataSource = [[NSMutableArray alloc] init];
    }
    if (nil == self.resultDataSource) {
        self.resultDataSource = [[NSMutableArray alloc] init];
    }
    
    // Thread to load articleIds for tag.
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // Get article ids for specific tag.
        [self.resultArticlesDataSource removeAllObjects];
        NSArray *articles = [[ImageDBOperator sharedInstance] getArticlesIdByTag:tag];
        
        if (nil == articles || 0 == [articles count]) {
            [self.view performSelectorOnMainThread:@selector(makeToast:)
                                        withObject:NSLocalizedString(@"local_no_image", @"Please change to net search.")
                                     waitUntilDone:NO];
            return ;
        }
        [self.resultArticlesDataSource addObjectsFromArray:articles];
        
        // Get images by first article id int the article datasource.
        self.currentArticleIndex = 0;
        [self.resultDataSource  removeAllObjects];
        int articleId =  [[self.resultArticlesDataSource objectAtIndex:self.currentArticleIndex] intValue];
        NSArray * images = [[ImageDBOperator sharedInstance] getImagesBy:articleId];
        self.newImagesCount = [images count];
        
        // Add images to datasource.
        for (int i = 0; i < self.newImagesCount; i++) {
            MosaicData *data   = [[MosaicData alloc] init];
            Image *image       = [images objectAtIndex:i];
            data.imageFilename = image.url;
            data.isFavourite   = image.isFavorite;
            data.isLocalImage  = YES;
            [self.resultDataSource addObject:data];
        }
        
        self.currentArticleIndex++;
        
        // Update UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.resultView reloadData];
            
            [self.view makeToast:[NSString stringWithFormat:
                                  NSLocalizedString(@"local_get_image", @"get %d iamges from local"),self.newImagesCount]];
            
            [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.resultView];
            self.isLoading = NO;
        });
    });
}

- (void)search:(NSString *)url
{
    if(nil == self.request) {
        self.request = [[NSMutableURLRequest alloc] init];
    }
    
    [self.searchProgressHUD show:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // Set the request params
        [self.request setURL:[NSURL URLWithString:url]];
        [self.request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        [self.request setTimeoutInterval:10];
        [self.request setHTTPMethod:@"GET"];
        NSString *contentType = @"text/xml";
        [self.request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *result;
        NSInteger requestCount = 0;
        
        while (requestCount < 3) {
            result = [NSURLConnection sendSynchronousRequest:self.request
                                           returningResponse:&response
                                                       error:&error];
            if (200 == [response statusCode]) {
                break;
            }
            
            requestCount++;
        }
        
        if(3 == requestCount || nil == result) {
            NSLog(@"request failed.");
        }
        
        [self parseResult:result];
        self.currentPageIndex++;
        [NSThread sleepForTimeInterval:0.5];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchProgressHUD hide:YES];
            if (self.newImagesCount > 0) {
                
                if (2 == self.currentPageIndex) {
                    
                    // If enter the other case when you search a sencond keyword may crash.
                    [self.resultView reloadData];
                } else {
                
                    // Reload collection view with animation
                    NSMutableArray *indexPaths = [@[] mutableCopy];
                    
                    for (int ix = 0; ix < self.newImagesCount; ++ix) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:ix inSection:0]];
                    }
                    
                    [self.resultView performBatchUpdates:^{
                        // Do insert animation
                        [self.resultView insertItemsAtIndexPaths:indexPaths];
                    } completion:^(BOOL finished) {
                    }];
                }
                
                [self.view makeToast:[NSString stringWithFormat:
                                      NSLocalizedString(@"net_get_image", @"get %d images from net."),self.newImagesCount]];
                self.newImagesCount = 0;
                
            } else {
                [self.view makeToast:NSLocalizedString(@"on_image_try", @"You can try again.")];
            }
            
            [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.resultView];
            self.isLoading = NO;
            
        });
    });
}

- (void)parseResult:(NSData *)result
{
    if (nil != result) {
        // Correct Encoding.
        NSString *encodeStr = [[NSString alloc] initWithBytes:[result bytes]
                                                       length:[result length]
                                                     encoding:NSUTF8StringEncoding];
        if (nil == encodeStr) {
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            encodeStr = [[NSString alloc] initWithBytes:[result bytes]
                                                 length:[result length]
                                               encoding:enc];
        }
        
        // Get images Array.
        NSData *encodeData      = [encodeStr dataUsingEncoding:NSUTF8StringEncoding];
        JsonObject *jsonResult  = [[JsonObject alloc] initWithData:encodeData];
        NSArray *imgJsonArray   = [jsonResult getJsonArray:@"data" withFallBack:@[]];
        
        if (nil == self.resultDataSource) {
            self.resultDataSource = [[NSMutableArray alloc] init];
        }
        if (1 == self.currentPageIndex) {
            [self.resultDataSource removeAllObjects];
        }
        
        if (nil != imgJsonArray && 0 != [imgJsonArray count]) {
            self.newImagesCount = 0;
            
            // To parse new image.
            for (JsonObject *json in imgJsonArray) {
                MosaicData *image = [self parseImage:json];
                
                // Add new image to datasource.
                if (nil != image && ![self.resultDataSource containsObject:image]) {
                    if (1 == self.currentPageIndex) {
                        [self.resultDataSource addObject:image];
                    } else {
                        [self.resultDataSource insertObject:image atIndex:0];
                    }

                    self.newImagesCount++;
                }
            }
            
        } else if (1 == self.currentPageIndex) {
            
            // If no data for a new keyword,we should remove images of the last keyword and update
            // ui at the same time.
            [self.resultView performSelectorOnMainThread:@selector(reloadData)
                                              withObject:nil
                                           waitUntilDone:NO];
        }
    } else {
        NSLog(@"cann't parse, the data from internet is null.");
    }
}

- (NSString *)createUrl:(NSString *)keyWord withPageIndex:(int)pageIndex
{
    NSMutableString * url = [[NSMutableString alloc] initWithString:SearchHeader];
    int width  = 0;
    int height = 0;

    // Get user input resolution.
    if (self.customResolutionHeight > 0 && self.customResolutionWidth > 0) {
        
        width  = self.customResolutionWidth;
        height = self.customResolutionHeight;
        [url appendFormat:@"&width=%d",width];
        [url appendFormat:@"&height=%d",height];
        
    } else {
        
        int random;
        if (self.selectedResolutionIndex >= 0) {
            
            // Use user select resolution.
            random = self.selectedResolutionIndex;
        } else {
            
            // Use random resolution.
            random = arc4random() % 6;
        }
        
        switch (random) {
            case 0:
                width  = 1024;
                height = 768;
                
            case 1:
                width  = 1024;
                height = 768;
                break;
                
            case 2:
                width  = 800;
                height = 600;
                break;
                
            case 3:
                width  = 640;
                height = 960;
                break;
                
            case 4:
                width  = 240;
                height = 320;
                break;
                
            case 5:
                width  = 640;
                height = 480;
                break;
                
            default:
                break;
        }
        
        if (0 == random) {
            [url appendString:@"&width="];
            [url appendString:@"&height="];
        } else {
            [url appendFormat:@"&width=%d", width];
            [url appendFormat:@"&height=%d", height];
        }
    }
    
    [url appendString:@"&word="];
    [url appendString:keyWord];
    [url appendFormat:@"&rn=%d",Search_Request_Count];
    [url appendFormat:@"&pn=%d",pageIndex];
    [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url = %@",url);
    
    return url;
}

- (NSString *)encodeURLParam:(NSString *)param
{
    NSString *escapedStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)param, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return escapedStr;
}

- (MosaicData *)parseImage:(JsonObject *)json
{
    if (nil != json) {
        NSString *url      = [json getString:@"objURL"];
        NSString *thumbURL = [json getString:@"thumbURL"];
        if (nil != url && url.length > 0) {
            MosaicData *image   = [[MosaicData alloc] init];
            image.imageFilename = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            image.thumbNailUrl  = thumbURL;
            image.isLocalImage  = NO;
            
            return image;
        }
    }
    return nil;
}

- (void)reloadDataSource
{
    if (!self.isLoading && !self.isLocalSearch) {
        self.isLoading     = YES;
        
        if (nil != self.resultDataSource && nil != self.lastKeyWord) {
            NSString *key = [self encodeURLParam:self.lastKeyWord];
            NSString *requestUrl = [self createUrl:key withPageIndex:self.currentPageIndex];
            [self search:requestUrl];
        }
    } else if (self.isLocalSearch){
        
        if (self.currentArticleIndex >= 1 && self.currentArticleIndex < [self.resultArticlesDataSource count] ) {
            
            // To load local images for next article id.
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                int articleId = [[self.resultArticlesDataSource objectAtIndex:self.currentArticleIndex] intValue];
                self.currentArticleIndex++;
                NSArray *newImages = [[ImageDBOperator sharedInstance] getImagesBy:articleId];
                
                // TODO check newImages cout
                self.newImagesCount = [newImages count];
                
                // Add to collectionview datasource.
                for (int i = 0; i < self.newImagesCount; i++) {
                    MosaicData *data = [[MosaicData alloc] init];
                    Image *image       = [newImages objectAtIndex:i];
                    data.imageFilename = image.url;
                    data.isFavourite   = image.isFavorite;
                    data.isLocalImage  = YES;
                    [self.resultDataSource insertObject:data atIndex:0];
                }
                
                // Update UI.
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Reload collection view with animation
                    NSMutableArray *indexPaths = [@[] mutableCopy];
                    
                    for (int ix = 0; ix < self.newImagesCount; ++ix) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:ix inSection:0]];
                    }
                    
                    [self.resultView performBatchUpdates:^{
                        // Do insert animation
                        [self.resultView insertItemsAtIndexPaths:indexPaths];
                    } completion:^(BOOL finished) {
                    }];
                    
                    [self.view makeToast:[NSString stringWithFormat:
                                          NSLocalizedString(@"local_get_image", @"get %d iamges from local"),self.newImagesCount]];
                    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.resultView];
                    self.isLoading = NO;
                });
            });
            
        } else if ([self.resultArticlesDataSource count] == self.currentArticleIndex) {
            [self.view makeToast:NSLocalizedString(@"current_tag_load_all", @"Current tag load complete") ];
            self.isLoading = NO;
            [self.refreshHeaderView performSelector:@selector(egoRefreshScrollViewDataSourceDidFinishedLoading:)
                                         withObject:self.resultView afterDelay:1.0];
        } else {
            [self.view makeToast:NSLocalizedString(@"local_search_click_tag", @"Please click tag to start local search")];
            self.isLoading = NO;
            [self.refreshHeaderView performSelector:@selector(egoRefreshScrollViewDataSourceDidFinishedLoading:)
                                         withObject:self.resultView afterDelay:1.0];
        }
    }
}

- (IBAction)addOrDeleteFavorite:(id)sender
{
    MosaicCell *selCell = (MosaicCell *)[self.resultView cellForItemAtIndexPath:self.selectedIndex];
    MosaicData *image   = selCell.mosaicData;
    
    if (selCell.mosaicData.isLocalImage) {
        BOOL oldState = selCell.mosaicData.isFavourite;
        
        // If local image ,update favourite state.
        Image *image = [[Image alloc] init];
        image.url        = selCell.mosaicData.imageFilename;
        image.isFavorite = selCell.mosaicData.isFavourite;
        
        // Change favourite state.
        if ([[ImageDBOperator sharedInstance] updateFavoriteImage:image]) {
            NSLog(@"update local image favourite state success.");
            selCell.mosaicData.isFavourite = !oldState;
        } else {
            NSLog(@"update local image favourite state failed.");
        }
        
    } else {
        
        // If internet iamge insert or delete from Favourite DB.
        if (!selCell.mosaicData.isFavourite) {
            
            // Insert into DB.
            if ([operator insertToFavourite:image withKeyword:self.lastKeyWord]) {
                NSLog(@"success insert into favourite DB.");
                selCell.mosaicData.isFavourite = YES;
            } else {
                NSLog(@"failed insert into favourite DB.");
            }
            
        } else {
            
            // Delete from DB.
            if ([operator deleteFromFavourite:selCell.mosaicData]) {
                NSLog(@"delete from favourite success.");
                selCell.mosaicData.isFavourite = NO;
            } else {
                NSLog(@"failed delete from favourite db.");
            }
        }
    }
    
    [self updateFavouriteBtnImageByImg:selCell.mosaicData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"favourite" object:nil];
}

- (void)updateFavouriteBtnImageByImg:(MosaicData *)image
{
    NSString *imageName;
    if (INTERFACE_IS_PHONE) {
        imageName = image.isFavourite ? @"Icon_heart_favorite" : @"Icon_heart";
    } else {
        imageName = image.isFavourite ? @"Icon_heart_favorite_ipad" : @"Icon_heart_ipad";
    }
    if (self.favoriteButton) {
        [self.favoriteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
}

- (IBAction)downloadPhoto:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(self.fullScreenCell.imageView.image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"dialog_msg_save_image_failed_title", nil)
                              message:NSLocalizedString(@"dialog_msg_save_image_failed_content", nil)
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"dialog_msg_save_image_success_title", nil)
                              message:NSLocalizedString(@"dialog_msg_save_image_success_content", nil)
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)sharePhoto:(id)sender
{
    // Create share content
    NSString *message = @"Share Photo: ";
    UIImage *image = self.fullScreenCell.imageView.image;
    NSArray *arrayOfActivityItems = [NSArray arrayWithObjects:message, image, nil];
    
    // ViewController
    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:arrayOfActivityItems
                                                    applicationActivities:nil];
    
    // Completion Handler
    UIActivityViewControllerCompletionHandler block = ^(NSString *activityType, BOOL completed) {
        if (completed) {
            NSLog(@"Completed!");
        } else {
            NSLog(@"Cancled!");
        }
    };
    
    activityController.completionHandler = block;
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropDown:(id)sender
{
    if (INTERFACE_IS_PHONE) {
        
        // Options in IPhone
        if (nil == self.popNavController) {
            SearchOptionsViewController *searchOption = [[SearchOptionsViewController alloc] init];
            
            UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(back)];
            
            self.popNavController = [[UINavigationController alloc] initWithRootViewController:searchOption];
            searchOption.title    = NSLocalizedString(@"search_option", @"Search Option");
            searchOption.navigationItem.leftBarButtonItem = backBarItem;
            searchOption.delegate = self;
            self.popNavController.navigationBar.barStyle = UIBarStyleBlack;
        }
        [self presentViewController:self.popNavController animated:YES completion:nil];
        
    } else if (nil == self.popOverController) {
        
        // Options in IPad.
        SearchOptionsViewController *searchOption = [[SearchOptionsViewController alloc] init];
        searchOption.title        = NSLocalizedString(@"search_option", @"Search Option");
        searchOption.contentSizeForViewInPopover  = CGSizeMake(320, 300);
        searchOption.delegate = self;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:searchOption];
        navController.contentSizeForViewInPopover = CGSizeMake(320, 300);
        
        self.popOverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        
        // Modify the popover background.
        self.popOverController.popoverBackgroundViewClass = [SearchPopoverBackgroundView class];
    }
    
    if (!self.popOverController.isPopoverVisible) {
        [self.popOverController presentPopoverFromBarButtonItem:sender
                                       permittedArrowDirections:UIPopoverArrowDirectionAny
                                                       animated:YES];
    } else {
        [self.popOverController dismissPopoverAnimated:YES];
    }
}

- (void)relayout:(LayoutType)layoutType
{
    if ([self.resultDataSource count] > 0) {
        for (MosaicData *data in self.resultDataSource) {
            data.layoutType = kMosaicLayoutTypeUndefined;
        }
        self.currentDisplayMode = layoutType;
        MosaicLayout *layout = (MosaicLayout *)self.resultView.collectionViewLayout;
        [self.resultView performBatchUpdates:^{}
                                  completion:^(BOOL finished){
                                      if (finished) {
                                          self.isNeedRelayout = NO;
                                      }
                                  }];
        [layout invalidateLayout];
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
    //CGFloat cropWidth = floorf((frameWidth - (columnCount + 1) * kMargin) / columnCount);
    CGFloat cellWidth = (frameWidth - (columnCount + 1) * kMargin) / columnCount;
    
    return cellWidth;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - Refresh Control Delegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return self.isLoading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - SearchOptionsDelegate

- (void)searchTypeChanged:(NSUInteger)type
{
    if (type == SearchTypeLocal) {
        self.isLocalSearch = YES;
        self.searchbar.placeholder = NSLocalizedString(@"local_search", @"Local Search");
    } else {
        self.isLocalSearch = NO;
        self.searchbar.placeholder = NSLocalizedString(@"net_search", @"Net Search");
    }
}

- (void)searchNetResolutionChanged:(NSInteger)index resolution:(NSString *)resolution
{
    self.currentArticleIndex      = 0;
    self.customResolutionWidth    = -1;
    self.customResolutionHeight   = -1;
    self.selectedResolutionIndex  = index;
}

- (void)searchNetResolutionChanged:(NSInteger)width height:(NSInteger)height
{
    self.currentArticleIndex      = 0;
    self.customResolutionWidth    = width;
    self.customResolutionHeight   = height;
    self.selectedResolutionIndex  = -1;
}

- (void)searchLocalTagChanged:(NSString *)tag
{
    [self.popOverController dismissPopoverAnimated:YES];
    
    self.searchbar.text = tag;
    self.currentPageIndex = 1;
    [self.searchbar becomeFirstResponder];
    self.customResolutionHeight  = -1;
    self.customResolutionWidth   = -1;
    self.selectedResolutionIndex = -1;
}

@end
