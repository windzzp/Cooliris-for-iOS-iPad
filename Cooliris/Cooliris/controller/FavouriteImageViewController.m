//
//  FavouriteImageViewController.m
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FavouriteImageViewController.h"
#import "MosaicLayout.h"
#import "MosaicData.h"
#import "MosaicCell.h"
#import "ImageDataProvider.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "SlideShowViewController.h"
#import "ImageDBOperator.h"
#import "FavouriteDBOperator.h"
#import "Image.h"
#import "UIBarButtonItem+Flat.h"

#define kNotification_Favourite  @"favourite"
#define kFavourite_DB_Name       @"favourite"

#define kMargin                  5
#define kColumnsiPadLandscape    4
#define kColumnsiPadPortrait     3
#define kColumnsiPhoneLandscape  3
#define kColumnsiPhonePortrait   2

#define kDoubleColumnProbability 40

@interface FavouriteImageViewController ()

@property (weak,   nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) MBProgressHUD *HUDIndicator;
@property (strong, nonatomic) MosaicCell *fullScreenCell;
@property (strong, nonatomic) UIView   *buttonView;
@property (strong, nonatomic) UIButton *favoriteButton;
@property (strong, nonatomic) UIButton *downloadButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIBarButtonItem *slideShowButton;
@property (strong, nonatomic) UIView *shadow;

@property (strong, nonatomic) NSMutableArray *elements;
@property (strong, nonatomic) FavouriteDBOperator *operator;
@property (strong, nonatomic) NSIndexPath *currentIndex;

@property (nonatomic) BOOL isZooming;
@property (nonatomic) int  columnCount;
@property (nonatomic) CGFloat cellWidth;

#pragma mark - Methods Declare

- (IBAction)cancelFavorite:(id)sender;
- (IBAction)downloadPhoto:(id)sender;
- (IBAction)sharePhoto:(id)sender;
- (IBAction)slideShow:(id)sender;

// Overrided super class method
- (void)initNavigationBar;
- (void)refreshData;

- (void)initLayout;
- (void)initButtonView;
- (void)resetButtonViewFrame;
- (void)registerNotification;
- (void)updateSlideShowButton;
- (void)updateFavoriteButton;
- (void)loadFavouriteImage;
- (void)relayout:(LayoutType)layoutType;
- (NSArray *)imageToMosaicData:(NSArray *)images;
- (int)calcuateColumnCount:(UIInterfaceOrientation)orientation;
- (CGFloat)calcuateCellWidth:(int)columnCount inOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation FavouriteImageViewController

#pragma mark - Init 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentIndex = [[NSIndexPath alloc] init];
    }
    return self;
}

#pragma mark - LifeCycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *nib = [UINib nibWithNibName:@"MosaicCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    [(MosaicLayout *)_collectionView.collectionViewLayout setDelegate:self];
    
    [self initLayout];
    [self initNavigationBar];
    [self initButtonView];
    [self registerNotification];
    
    self.shadow = [[UIView alloc] initWithFrame:self.view.bounds];
    self.shadow.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7].CGColor;
    [self.collectionView addSubview:self.shadow];
    self.shadow.alpha = 0;
    self.shadow.hidden = YES;
    
    self.operator  = [[FavouriteDBOperator alloc] initWithName:kFavourite_DB_Name nDBVersion:1];
    self.isZooming = NO;
    [self loadFavouriteImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SDWebImageManager sharedManager] cancelAll];
    self.shadow.alpha = 0;
    self.shadow.hidden = YES;
    self.buttonView.alpha = 0;
    self.collectionView.scrollEnabled = YES;
    self.isZooming = NO;
    self.isNeedRefreshData = YES;
}

- (void)viewDidLayoutSubviews
{
    [self resetButtonViewFrame];
    self.shadow.frame = self.view.bounds;
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
    
    MosaicLayout *layout = (MosaicLayout *)_collectionView.collectionViewLayout;
    [layout invalidateLayout];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_elements count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    MosaicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    MosaicData *data = [_elements objectAtIndex:indexPath.row];
    cell.mosaicData = data;
    
    float randomWhite = (arc4random() % 40 + 10) / 255.0;
    cell.backgroundColor = [UIColor colorWithWhite:randomWhite alpha:1];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.fadeIn = YES;
    [cell.imageView setImageWithURL:[NSURL URLWithString:cell.mosaicData.imageFilename]
                   placeholderImage:nil//[UIImage imageNamed:@"placeholder"]
                            options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"1---didSelectItemAtIndexPath, %@", indexPath);
    self.collectionView.scrollEnabled = NO;
    self.shadow.frame = CGRectMake(0, self.collectionView.contentOffset.y, self.view.bounds.size.width, self.view.bounds.size.height);
    self.shadow.hidden = NO;
    
    self.currentIndex = indexPath;
    
    if (!self.isZooming) {
        self.isZooming = YES;
        MosaicCell *cell = (MosaicCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
        CGSize cellSize = cell.frame.size;
        CGSize screenSize = self.collectionView.bounds.size;
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
        [self updateFavoriteButton];
        
        float screenAspect = screenSize.width / screenSize.height;
        NSLog(@"Image Aspect: %f, Screen Aspect: %f, Cell Size: (%f, %f)", imageAspect, screenAspect, cellSize.width, cellSize.height);
    
        CGRect newFrame;
        if (imageAspect < screenAspect) {
            // Image is too tall, image will fill the screen height
            float newH = screenSize.height;
            float newW = screenSize.height * imageAspect;
            newFrame = CGRectMake((screenSize.width - newW) / 2, 0 + self.collectionView.contentOffset.y, newW, newH);
        
        } else if (imageAspect > screenAspect) {
            // Image is too width, image will fill the screen width
            float newW = screenSize.width;
            float newH = screenSize.width / imageAspect;
            newFrame = CGRectMake(0, (screenSize.height - newH) / 2 + self.collectionView.contentOffset.y, newW, newH);
        }
    
        [UIView animateWithDuration:0.3 animations:^{
            [self.collectionView bringSubviewToFront:cell];
            //cell.transform = CGAffineTransformMake(newFrame.size.width / , 0, 0, 1.5, 200, 200);
            //cell.transform = CGAffineTransformMake(1.5, 0, 0, 1.5, 200, 200);
            cell.orignalFrame   = cell.frame;
            cell.frame          = newFrame;
            self.fullScreenCell = cell;
            self.buttonView.alpha = 1;
            self.shadow.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            NSLog(@"frame: %f, %f, %f, %f", cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
            NSLog(@"bounds: %f, %f, %f, %f", cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
        }];
        
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            
            NSLog(@"frame: %f, %f, %f, %f", self.fullScreenCell.frame.origin.x, self.fullScreenCell.frame.origin.y, self.fullScreenCell.frame.size.width, self.fullScreenCell.frame.size.height);
            NSLog(@"bounds: %f, %f, %f, %f", self.fullScreenCell.bounds.origin.x, self.fullScreenCell.bounds.origin.y, self.fullScreenCell.bounds.size.width, self.fullScreenCell.bounds.size.height);
            //cell.transform = CGAffineTransformMake(1.0, 0, 0, 1.0, 0, 0);
            self.fullScreenCell.frame = self.fullScreenCell.orignalFrame;
            self.buttonView.alpha = 0;
            self.shadow.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [self.collectionView sendSubviewToBack:self.fullScreenCell];
            self.isZooming = NO;
            [self updateFavoriteButton];
            self.shadow.hidden = YES;
            self.collectionView.scrollEnabled = YES;
        }];
    }
}


#pragma mark - MosaicLayoutDelegate

- (float)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //  Base relative height for simple layout type. This is 1.0 (height equals to width)
    float retVal = 1.0;
    
    //NSMutableArray *self.elements = [(CustomDataSource *)_collectionView.dataSource elements];
    MosaicData *aMosaicModule = [self.elements objectAtIndex:indexPath.row];
    
    if (kLayoutTypeGrid == self.currentDisplayMode || kLayoutTypeSingleLine == self.currentDisplayMode) {
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
    //NSMutableArray *elements = [(CustomDataSource *)_collectionView.dataSource elements];
    MosaicData *aMosaicModule = [self.elements objectAtIndex:indexPath.row];
    
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
            retVal = kColumnsiPadLandscape;
        }else{
            retVal = kColumnsiPhoneLandscape;
        }
        
    }else{
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            retVal = kColumnsiPadPortrait;
        }else{
            retVal = kColumnsiPhonePortrait;
        }
    }
    
    return retVal;
}

- (float)minimumInteritemSpacingInCollectionView:(UICollectionView *)collectionView
{
    return 0;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex + 1) {
        Image *image = [[Image alloc] init];
        image.url        = self.fullScreenCell.mosaicData.imageFilename;
        image.isFavorite = self.fullScreenCell.mosaicData.isFavourite;
        
        self.fullScreenCell.mosaicData.isFavourite = NO;
        [[ImageDBOperator sharedInstance] updateFavoriteImage:image];
        [self.operator deleteFromFavourite:self.fullScreenCell.mosaicData];
        
        self.fullScreenCell.frame = self.fullScreenCell.orignalFrame;
        [self.collectionView sendSubviewToBack:self.fullScreenCell];
        self.isZooming = NO;
        self.buttonView.alpha = 0;
        [self updateFavoriteButton];
        
        self.shadow.alpha = 0;
        self.shadow.hidden = YES;
        self.collectionView.scrollEnabled = YES;
        
//        [self loadFavouriteImage];
        
        // Make a delete animation.
        [self.elements removeObjectAtIndex:[self.currentIndex row]];
        NSMutableArray *indexPaths = [@[] mutableCopy];
        [indexPaths addObject:[NSIndexPath indexPathForRow:[self.currentIndex row] inSection:0]];
        [self.collectionView performBatchUpdates:^{
            // Do delete animation
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
        } completion:^(BOOL finished) {
            [self updateSlideShowButton];
        }];
    }
}

#pragma mark - Private Methods

- (void)registerNotification
{
    // Register Notifications.
    // Reload Favourite images when user add new favourite image.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_Favourite
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavouriteUI:)
                                                 name:kNotification_Favourite
                                               object:nil];
}

- (void)initNavigationBar
{
    // Set up the navigation bar item
    self.parentViewController.navigationItem.titleView = nil;
    self.parentViewController.navigationItem.title = NSLocalizedString(@"favourite", @"Favourite");
    
    NSString *title = NSLocalizedString(@"SlideShow", @"SlideShow");
    self.slideShowButton = [[UIBarButtonItem alloc]
                            initWithTitle:title
                            style:UIBarButtonItemStyleBordered
                            target:self
                            action:@selector(slideShow:)];
    [self.slideShowButton removeTitleShadow];
    self.parentViewController.navigationItem.rightBarButtonItem = self.slideShowButton;
    
    [self updateSlideShowButton];
}

- (void)refreshData
{
    [self.collectionView reloadData];
}

- (void)initButtonView
{
    CGFloat centerHeight = self.view.bounds.size.height / 2.0 - 44;
    CGFloat buttonWidth = INTERFACE_IS_PHONE ? 35 : 50;
    CGFloat buttonSpace = INTERFACE_IS_PHONE ? 5 : 12;
    CGFloat leftSpace = INTERFACE_IS_PHONE ? 2 : 4;
    
    self.buttonView = [[UIView alloc]
                       initWithFrame:CGRectMake(0,
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
                            action:@selector(cancelFavorite:)
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
    
    self.buttonView.frame = CGRectMake(0,
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
    
    self.columnCount = [self calcuateColumnCount:self.interfaceOrientation];
    self.cellWidth = [self calcuateCellWidth:self.columnCount inOrientation:self.interfaceOrientation];
}

- (int)calcuateColumnCount:(UIInterfaceOrientation)orientation
{
    BOOL isPhone = UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom];
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
    int columnCount = kColumnsiPhonePortrait;
    
    if (isPhone) {
        columnCount = isPortrait ? kColumnsiPhonePortrait : kColumnsiPhoneLandscape;
    } else {
        columnCount = isPortrait ? kColumnsiPadPortrait : kColumnsiPadLandscape;
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

- (void)relayout:(LayoutType)layoutType
{
    if ([self.elements count] > 0) {
        for (MosaicData *data in self.elements) {
            data.layoutType = kMosaicLayoutTypeUndefined;
        }
        self.currentDisplayMode = layoutType;
        MosaicLayout *layout = (MosaicLayout *)self.collectionView.collectionViewLayout;
        [self.collectionView performBatchUpdates:^{}
                                      completion:^(BOOL finished){
                                          if (finished) {
                                              self.isNeedRelayout = NO;
                                          }
                                      }];
        [layout invalidateLayout];
    }
}

- (void)loadFavouriteImage
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray *localFavorite = [[ImageDBOperator sharedInstance] getAllLocalFavourite];
        NSArray *netFavourite  = [self.operator getAllFavourite];
        
        NSMutableArray *allfavourite = [[NSMutableArray alloc] init];
        [allfavourite addObjectsFromArray:[self imageToMosaicData:localFavorite]];
        [allfavourite addObjectsFromArray:netFavourite];
        
        if ([self.elements count] > 0) {
            [self.elements removeAllObjects];
        }
        self.elements = allfavourite;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self updateSlideShowButton];
        });
    });
}

- (NSArray *)imageToMosaicData:(NSArray *)images
{
    NSMutableArray *mosaicDatas = [[NSMutableArray alloc] init];
    for (Image *img in images) {
        MosaicData *data   = [[MosaicData alloc] init];
        data.imageFilename = img.url;
        data.isFavourite   = img.isFavorite;
        [mosaicDatas addObject:data];
    }
    
    return mosaicDatas;
}

- (void)updateSlideShowButton
{
    if (self.elements.count == 0 || self.elements == nil) {
        self.slideShowButton.enabled = NO;
    } else {
        self.slideShowButton.enabled = YES;
    }
}

- (void)updateFavoriteButton
{
    NSString *imageName;
    if (self.favoriteButton.enabled) {
        imageName = INTERFACE_IS_PHONE ? @"Icon_heart_favorite" : @"Icon_heart_favorite_ipad";
    } else {
        imageName = INTERFACE_IS_PHONE ? @"Icon_heart" : @"Icon_heart_ipad";
    }
    
    [self.favoriteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (IBAction)cancelFavorite:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"dialog_msg_cancel_favorite_title", nil)
                          message:NSLocalizedString(@"dialog_msg_cancel_favorite_content", @"Do you want to cancel this favorite?")
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                          otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
    [alert show];
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

- (IBAction)slideShow:(id)sender
{
    SlideShowViewController *slideShow = [[SlideShowViewController alloc] init];
    slideShow.isFavorite = YES;
    slideShow.slideSource = self.elements;
    [self.parentViewController.navigationController presentViewController:slideShow animated:YES completion:nil];
}

#pragma mark - Notification Methods

- (void)updateFavouriteUI:(NSNotification *)notification
{
    [self loadFavouriteImage];
}

@end
