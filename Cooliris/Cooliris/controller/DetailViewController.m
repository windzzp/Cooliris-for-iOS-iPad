//
//  DetailViewController.m
//  Cooliris
//
//  Created by user on 13-5-31.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailViewController.h"
#import "SlideShowViewController.h"
#import "UIImage+UIImage_Extended.h"
#import "UIImageView+WebCache.h"
#import "ImageDataProvider.h"
#import "UIBarButtonItemEx.h"
#import "ImageDBOperator.h"
#import "ZoomImageCell.h"
#import "ImageGroup.h"
#import "Image.h"

@interface DetailViewController ()
{
    NSUInteger currentImageIndex_;
    NSUInteger imageIndexBeforeRotation_;
    NSUInteger groupIndexBeforeRotation_;
    NSUInteger imageGroupsCount_;
    BOOL       isControlHidden_;
    BOOL       isChangingGroup_;
    BOOL       isFirstPage_;
    BOOL       isRotating_;
}

@property (strong, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (strong, nonatomic) IBOutlet UINavigationBar  *navigationBar;

@property (strong, nonatomic) IBOutlet UIScrollView     *groupDescriptionScrollView;
@property (strong, nonatomic) IBOutlet UILabel          *groupDescriptionTitle;
@property (strong, nonatomic) IBOutlet UIView           *groupDescriptionSubtitle;
@property (strong, nonatomic) IBOutlet UIImageView      *groupDescriptionTimeImage;
@property (strong, nonatomic) IBOutlet UILabel          *groupDescriptionTime;
@property (strong, nonatomic) IBOutlet UIImageView      *groupDescriptionCategoryImage;
@property (strong, nonatomic) IBOutlet UILabel          *groupDescriptionCategory;
@property (strong, nonatomic) IBOutlet UIImageView      *groupDescriptionTagImage;
@property (strong, nonatomic) IBOutlet UILabel          *groupDescriptionTag;
@property (strong, nonatomic) IBOutlet UILabel          *groupDescriptionContent;

@property (strong, nonatomic) UIView   *buttonView;
@property (strong, nonatomic) UIButton *favoriteButton;
@property (strong, nonatomic) UIButton *downloadButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *rotateButton;
@property (strong, nonatomic) UIBarButtonItemEx *nextButton;
@property (strong, nonatomic) UIBarButtonItemEx *previousButton;
@property (strong, nonatomic) UIBarButtonItemEx *slideShowButton;

@property (strong, nonatomic) UIView   *changingGroupView;
@property (strong, nonatomic) UILabel  *changingGroupDirection;
@property (strong, nonatomic) UILabel  *changingGroupDescription;

@property (strong, nonatomic) NSArray        *imageGroups;
@property (strong, nonatomic) NSMutableArray *imagesInAllGroup;
@property (strong, nonatomic) NSMutableArray *imagesCounts;
@property (nonatomic) NSUInteger imagesCountInGroup;

@property (strong, nonatomic) NSTimer        *controlHideTimer;
@property (nonatomic) UIImageOrientation currentImageOrientation;

// Init
- (void)initNavigationBar;
- (void)initGestureRecognizer;

// Data
- (void)loadData;

// View Frame
- (CGRect)screenFrame;
- (void)setDescriptionViewFrame;
- (void)resizeDescriptionView;
- (void)addChangingGroupAnimationViewRight:(BOOL)isRight;
- (void)resizeChangingGroupAnimationView;
- (void)addButtonView;
- (void)resetButtonViewFrame;

// Page
- (void)jumpToPageAtIndex:(NSUInteger)index atGroupIndex:(NSUInteger)groupIndex;
- (void)resetImageCell;
- (void)showChangingNextGroup:(BOOL)isNext;

// Controls
- (void)toggleControls;
- (void)hideControls;
- (void)updateControls;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
- (void)cancelHidingTimer;
- (void)setFavoriteStatus:(BOOL)isFavorite;

// Action
- (IBAction)backToGridView:(id)sender;
- (IBAction)addToFavorite:(id)sender;
- (IBAction)sharePhoto:(id)sender;
- (IBAction)rotatePhoto:(id)sender;
- (IBAction)slideShow:(id)sender;
- (IBAction)downloadPhoto:(id)sender;
- (IBAction)goToNextGroup:(id)sender;
- (IBAction)goToPreviousGroup:(id)sender;

// Private Method
- (ZoomImageCell *)currentImageCell;
- (void)onGroupChanged:(NSUInteger)groupIndex;
- (void)setButtonEnabled:(BOOL)enabled;

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        currentImageIndex_ = 0;
        imageIndexBeforeRotation_ = 0;
        groupIndexBeforeRotation_ = 0;
        imageGroupsCount_ = 0;
        isControlHidden_ = NO;
        isChangingGroup_ = NO;
        isFirstPage_ = YES;
        isRotating_ = NO;
        self.currentGroupIndex = 0;
        self.imageGroups = [[NSArray alloc] init];
        self.imagesInAllGroup = [@[] mutableCopy];
        self.imagesCounts = [@[] mutableCopy];
        self.imagesCountInGroup = 0;
        self.controlHideTimer = [[NSTimer alloc] init];
        self.currentImageOrientation = UIImageOrientationUp;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Full Screen Layout.
    self.wantsFullScreenLayout = YES;

    // Description View
    [self setDescriptionViewFrame];
    self.groupDescriptionScrollView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.groupDescriptionScrollView.alpha = 0;
    
    // Left Button View
    [self addButtonView];
    
    // Navigation Bar
    [self initNavigationBar];
    
    // Gesture Recognizer
    [self initGestureRecognizer];
    
    // Load Photo
    [self loadData];
    
    [self setControlsHidden:YES animated:NO permanent:NO];
}

- (void)viewDidLayoutSubviews
{
    // Reset the view frame.(When version is above of IOS5.0)
    [self setDescriptionViewFrame];
    [self resizeDescriptionView];
    [self resetButtonViewFrame];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark
#pragma mark - Init

- (void)initNavigationBar
{
    // Left Item - Back
    UIBarButtonItemEx *backButton = [UIBarButtonItemEx
                                     initWithFrame:CGRectMake(0, 0, 30, 30)
                                     normalImage:[UIImage imageNamed:@"Icon_back"]
                                     highlightImage:[UIImage imageNamed:@"Icon_back"]
                                     target:self
                                     action:@selector(backToGridView:)];
                                     
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Right Item - rotate
    self.nextButton = [UIBarButtonItemEx
                       initWithFrame:CGRectMake(0, 0, 40, 30)
                       normalImage:[UIImage imageNamed:@"Icon_next"]
                       highlightImage:[UIImage imageNamed:@"Icon_next"]
                       target:self
                       action:@selector(goToNextGroup:)];
    self.previousButton = [UIBarButtonItemEx
                           initWithFrame:CGRectMake(0, 0, 40, 30)
                           normalImage:[UIImage imageNamed:@"Icon_previous"]
                           highlightImage:[UIImage imageNamed:@"Icon_previous"]
                           target:self
                           action:@selector(goToPreviousGroup:)];
    self.slideShowButton = [UIBarButtonItemEx
                            initWithFrame:CGRectMake(0, 0, 40, 30)
                            normalImage:[UIImage imageNamed:@"Icon_play"]
                            highlightImage:[UIImage imageNamed:@"Icon_play"]
                            target:self
                            action:@selector(slideShow:)];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = @[self.slideShowButton, self.nextButton, self.previousButton];
    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"Icon_navigationbar_background_transparent"];
    [self.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)initGestureRecognizer
{
    // Single tap
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(toggleControls)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.cancelsTouchesInView = NO;
    [self.imageCollectionView addGestureRecognizer:singleTapRecognizer];
}


#pragma mark
#pragma mark - Data

- (void)loadData
{
    //self.imageGroups = ((ImageDataProvider *)[ImageDataProvider sharedInstance]).imageGroups;
    self.imageGroups = [[ImageDataProvider sharedInstance] getImageGroupsByCategory:_currentPageCategory];
    ImageGroup *currentGroup = self.imageGroups[self.currentGroupIndex];
    for (ImageGroup *imageGroup in self.imageGroups) {
        [self.imagesInAllGroup addObject:imageGroup.images];
        [self.imagesCounts addObject:[NSNumber numberWithInt:imageGroup.images.count]];
    }

    imageGroupsCount_ = self.imageGroups.count;
    
    // Description
    [self setGroupDescription:currentGroup];
    [self resizeDescriptionView];

    // Refresh visiable collection cell
    [self.imageCollectionView reloadData];
    [self showFirstPage];
}

#pragma mark
#pragma mark - View Frame

- (CGRect)screenFrame
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.size.width = isPortrait ? frame.size.width : frame.size.height;
    frame.size.height = isPortrait ? frame.size.height : frame.size.width;

    return frame;
}

- (void)setDescriptionViewFrame
{
    CGFloat viewHeight = INTERFACE_IS_PHONE ? 70 : 100;
    CGFloat subViewHeight = 20;
    CGFloat horizontalEdge = 20;
    CGFloat verticalEdge = 5;
    CGFloat space = 1;
    self.groupDescriptionScrollView.frame = CGRectMake(0,
                                                       self.view.bounds.size.height - viewHeight,
                                                       self.view.bounds.size.width,
                                                       viewHeight);
    self.groupDescriptionTitle.frame = CGRectMake(horizontalEdge,
                                                  verticalEdge,
                                                  self.view.bounds.size.width - horizontalEdge * 2,
                                                  subViewHeight);
    
    self.groupDescriptionSubtitle.frame = CGRectMake(horizontalEdge,
                                                     verticalEdge + subViewHeight + space,
                                                     self.view.bounds.size.width - horizontalEdge * 2 - 10,
                                                     subViewHeight);
    self.groupDescriptionTimeImage.frame = CGRectMake(0, 4, 15, 15);
    self.groupDescriptionTime.frame = CGRectMake(15, 0, 75, subViewHeight);
    self.groupDescriptionCategoryImage.frame = CGRectMake(90, 4, 15, 15);
    self.groupDescriptionCategory.frame = CGRectMake(105, 0, 80, subViewHeight);
    self.groupDescriptionTagImage.frame = CGRectMake(185, 4, 15, 15);
    self.groupDescriptionTag.frame = CGRectMake(200, 0, self.view.bounds.size.width -horizontalEdge - 200, subViewHeight);
    
    self.groupDescriptionContent.frame = CGRectMake(horizontalEdge,
                                                    verticalEdge + subViewHeight * 2 + space * 2,
                                                    self.view.bounds.size.width - horizontalEdge * 2,
                                                    subViewHeight);
    
    if (INTERFACE_IS_PHONE) {
        self.groupDescriptionSubtitle.frame = CGRectMake(horizontalEdge,
                                                         verticalEdge + subViewHeight + space,
                                                         self.view.bounds.size.width - horizontalEdge * 2 - 10,
                                                         subViewHeight);
        self.groupDescriptionTimeImage.frame = CGRectMake(0, 4, 15, 15);
        self.groupDescriptionTime.frame = CGRectMake(15, 0, 60, subViewHeight);
        self.groupDescriptionCategoryImage.frame = CGRectMake(75, 4, 15, 15);
        self.groupDescriptionCategory.frame = CGRectMake(90, 0, 80, subViewHeight);
        self.groupDescriptionTagImage.frame = CGRectMake(170, 4, 15, 15);
        self.groupDescriptionTag.frame = CGRectMake(185, 0, self.view.bounds.size.width - horizontalEdge - 185, subViewHeight);
        
        [self.groupDescriptionTitle setFont:[UIFont boldSystemFontOfSize:12]];
        [self.groupDescriptionTime setFont:[UIFont systemFontOfSize:10]];
        [self.groupDescriptionCategory setFont:[UIFont systemFontOfSize:10]];
        [self.groupDescriptionTag setFont:[UIFont systemFontOfSize:10]];
        [self.groupDescriptionContent setFont:[UIFont systemFontOfSize:11]];
    }
}

- (void)resizeDescriptionView
{
    CGSize contentSize = [self.groupDescriptionContent.text
                          sizeWithFont:self.groupDescriptionContent.font
                          constrainedToSize:CGSizeMake(self.groupDescriptionContent.frame.size.width, 9999)
                          lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect DescriptionFrame = self.groupDescriptionContent.frame;
    DescriptionFrame.size.height = contentSize.height;
    self.groupDescriptionContent.frame = DescriptionFrame;
    
    CGSize categorySize = [self.groupDescriptionCategory.text
                           sizeWithFont:self.groupDescriptionCategory.font
                           constrainedToSize:CGSizeMake(9999, 20)
                           lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect categoryFrame = self.groupDescriptionCategory.frame;
    categoryFrame.size.width = categorySize.width;
    self.groupDescriptionCategory.frame = categoryFrame;
    CGFloat tagOriginX = self.groupDescriptionCategory.frame.origin.x + self.groupDescriptionCategory.frame.size.width + 20;
    if (INTERFACE_IS_PHONE) {
        tagOriginX = self.groupDescriptionCategory.frame.origin.x + self.groupDescriptionCategory.frame.size.width + 10;
    }
    self.groupDescriptionTagImage.frame = CGRectMake(tagOriginX, 4, 15, 15);
    self.groupDescriptionTag.frame = CGRectMake(tagOriginX + 15, 0, self.view.bounds.size.width - 20 - tagOriginX - 15, 20);
    self.groupDescriptionScrollView.contentSize = CGSizeMake(self.groupDescriptionContent.frame.size.width,
                                                             self.groupDescriptionContent.frame.origin.y +
                                                             self.groupDescriptionContent.frame.size.height + 5);
}

- (void)addChangingGroupAnimationViewRight:(BOOL)isRight
{
    CGRect viewFrame = self.view.bounds;
    viewFrame.origin.x = isRight ? self.view.bounds.size.width : -self.view.bounds.size.width;;
    self.changingGroupView = [[UIView alloc] initWithFrame:viewFrame];
    self.changingGroupDirection = [[UILabel alloc]
                                   initWithFrame:CGRectMake(0,
                                                            self.changingGroupView.frame.size.height * 2.0 / 5.0,
                                                            self.changingGroupView.frame.size.width,
                                                            40)];
    self.changingGroupDescription = [[UILabel alloc]
                                     initWithFrame:CGRectMake(0,
                                                              self.changingGroupDirection.frame.origin.y + self.changingGroupDirection.frame.size.height + 10,
                                                              self.changingGroupView.frame.size.width,
                                                              20)];
    
    if (INTERFACE_IS_PHONE) {
        [self.changingGroupDirection setFont:[UIFont boldSystemFontOfSize:15]];
        [self.changingGroupDescription setFont:[UIFont systemFontOfSize:15]];
    } else {
        [self.changingGroupDirection setFont:[UIFont boldSystemFontOfSize:40]];
        [self.changingGroupDescription setFont:[UIFont systemFontOfSize:40]];
    }
    
    self.changingGroupView.backgroundColor = [UIColor blackColor];
    self.changingGroupDirection.backgroundColor = [UIColor clearColor];
    self.changingGroupDescription.backgroundColor = [UIColor clearColor];
    
    self.changingGroupDirection.textColor = [UIColor whiteColor];
    self.changingGroupDescription.textColor = [UIColor whiteColor];
    
    self.changingGroupDirection.textAlignment = NSTextAlignmentCenter;
    self.changingGroupDescription.textAlignment = NSTextAlignmentCenter;
    
    [self.changingGroupView addSubview:self.changingGroupDirection];
    [self.changingGroupView addSubview:self.changingGroupDescription];
}

- (void)resizeChangingGroupAnimationView
{
    CGSize textSize = [self.changingGroupDescription.text
                       sizeWithFont:self.changingGroupDescription.font
                       constrainedToSize:CGSizeMake(self.changingGroupDescription.frame.size.width, 9999)
                       lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect DescriptionFrame = self.changingGroupDescription.frame;
    DescriptionFrame.size.height = textSize.height;
    self.changingGroupDescription.frame = DescriptionFrame;
}

- (void)addButtonView
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
    
    self.rotateButton = [[UIButton alloc]
                         initWithFrame:CGRectMake(leftSpace,
                                                  centerHeight - buttonSpace/2.0 - buttonWidth,
                                                  buttonWidth,
                                                  buttonWidth)];
    self.favoriteButton = [[UIButton alloc]
                           initWithFrame:CGRectMake(leftSpace,
                                                    self.rotateButton.frame.origin.y - buttonSpace - buttonWidth,
                                                    buttonWidth,
                                                    buttonWidth)];
    self.downloadButton = [[UIButton alloc]
                           initWithFrame:CGRectMake(leftSpace,
                                                    centerHeight + buttonSpace/2.0,
                                                    buttonWidth,
                                                    buttonWidth)];
    self.shareButton = [[UIButton alloc]
                        initWithFrame:CGRectMake(leftSpace,
                                                 self.downloadButton.frame.origin.y + buttonWidth + buttonSpace,
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
    
    NSString *rotateImageName = INTERFACE_IS_PHONE ? @"Icon_rotate_left" : @"Icon_rotate_left_ipad";
    [self.rotateButton setImage:[UIImage imageNamed:rotateImageName]
                       forState:UIControlStateNormal];
    [self.rotateButton setImage:[UIImage imageNamed:rotateImageName]
                       forState:UIControlStateHighlighted];
    [self.rotateButton setBackgroundImage:[UIImage imageNamed:@"Icon_button_bg"]
                                 forState:UIControlStateNormal];
    
    [self.view addSubview:self.buttonView];
    self.buttonView.alpha = 0;
    [self.buttonView addSubview:self.favoriteButton];
    [self.buttonView addSubview:self.downloadButton];
    [self.buttonView addSubview:self.shareButton];
    [self.buttonView addSubview:self.rotateButton];
    [self.favoriteButton addTarget:self
                            action:@selector(addToFavorite:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.downloadButton addTarget:self
                            action:@selector(downloadPhoto:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self
                         action:@selector(sharePhoto:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.rotateButton addTarget:self
                          action:@selector(rotatePhoto:)
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
    
    self.rotateButton.frame = CGRectMake(leftSpace,
                                         centerHeight - buttonSpace/2.0 - buttonWidth,
                                         buttonWidth,
                                         buttonWidth);
    self.favoriteButton.frame = CGRectMake(leftSpace,
                                           self.rotateButton.frame.origin.y - buttonSpace - buttonWidth,
                                           buttonWidth,
                                           buttonWidth);
    self.downloadButton.frame = CGRectMake(leftSpace,
                                           centerHeight + buttonSpace/2.0,
                                           buttonWidth,
                                           buttonWidth);
    self.shareButton.frame = CGRectMake(leftSpace,
                                        self.downloadButton.frame.origin.y + buttonWidth + buttonSpace,
                                        buttonWidth,
                                        buttonWidth);
}

#pragma mark
#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    isRotating_ = YES;
    imageIndexBeforeRotation_ = currentImageIndex_;
    groupIndexBeforeRotation_ = self.currentGroupIndex;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.wantsFullScreenLayout = YES;
    currentImageIndex_ = imageIndexBeforeRotation_;
    self.currentGroupIndex = groupIndexBeforeRotation_;
    
    // Photo View
    UICollectionViewFlowLayout *imageCollectionViewOldLayout = (UICollectionViewFlowLayout *)self.imageCollectionView.collectionViewLayout;
    UICollectionViewFlowLayout *imageCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    imageCollectionViewLayout.minimumInteritemSpacing  = imageCollectionViewOldLayout.minimumInteritemSpacing;
    imageCollectionViewLayout.minimumLineSpacing       = imageCollectionViewOldLayout.minimumLineSpacing;
    imageCollectionViewLayout.sectionInset             = imageCollectionViewOldLayout.sectionInset;
    imageCollectionViewLayout.scrollDirection          = imageCollectionViewOldLayout.scrollDirection;
    [self.imageCollectionView setCollectionViewLayout:imageCollectionViewLayout animated:NO];
    
    // View Frame
    [self setDescriptionViewFrame];
    [self resizeDescriptionView];
    [self resetButtonViewFrame];
    
    [self jumpToPageAtIndex:currentImageIndex_ atGroupIndex:self.currentGroupIndex];
    isRotating_ = NO;
}

#pragma mark
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [[self.imagesCounts objectAtIndex:section] integerValue];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.imageGroups.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isFirstPage_ && !isRotating_ && self.currentGroupIndex != indexPath.section) {
        [self onGroupChanged:indexPath.section];
    }
    
    if (!isChangingGroup_ && !isRotating_) {
        currentImageIndex_ = indexPath.row;
        [self updateControls];
    }
    
    Image *imageData = [[self.imagesInAllGroup objectAtIndex:self.currentGroupIndex] objectAtIndex:currentImageIndex_];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:currentImageIndex_ inSection:self.currentGroupIndex];
    ZoomImageCell *imageCell = [collectionView
                                dequeueReusableCellWithReuseIdentifier:kZoomImageCellIdentifier
                                forIndexPath:newIndexPath];
    if (imageCell) {
        [self resetImageCell];
        [self setButtonEnabled:YES];
        __weak ZoomImageCell *cell = imageCell;
        [cell.imageView setImageWithURL:[NSURL URLWithString:imageData.url]
                       placeholderImage:[UIImage imageNamed:nil]
                                options:SDWebImageProgressiveDownload
                               progress:^(NSUInteger receivedSize, long long expectedSize) {
                                   cell.indicator.center = cell.imageView.center;
                                   [cell.indicator startAnimating];
                                   [self setButtonEnabled:NO];
                               }
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  [cell.indicator stopAnimating];
                                  [self setButtonEnabled:YES];
                              }];
        
        // Set IScrollEnabledDelegate
        imageCell.zoomImageCellDelegate = self;
        imageCell.zoomView.scrollEnabled = NO;
        imageCell.imageView.image = [imageCell.imageView.image fixOrientation:self.currentImageOrientation];
    }
    
    return imageCell;
}

#pragma mark
#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isFirstPage_) {
        isFirstPage_ = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.currentImageOrientation = UIImageOrientationUp;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!isChangingGroup_) {
        NSArray *visiableIndexs = [self.imageCollectionView indexPathsForVisibleItems];
        NSIndexPath *indexPath = [visiableIndexs objectAtIndex:0];
        currentImageIndex_ = indexPath.row;
        [self updateControls];
    }
    [self hideControlsAfterDelay];
}

#pragma mark
#pragma mark - IScrollEnabledDelegate

- (void)onSetControlsHidden:(BOOL)hidden
{
    [self setControlsHidden:hidden animated:YES permanent:NO];
}

- (void)onSetCollectionViewScrollEnabled:(BOOL)enabled
{
    self.imageCollectionView.scrollEnabled = enabled;
}

- (void)resetImageCell
{
    ZoomImageCell *imageCell = [self currentImageCell];
    imageCell.imageView.frame = imageCell.bounds;
    imageCell.zoomView.contentOffset = CGPointMake(0, 0);
    imageCell.zoomView.contentSize = imageCell.imageView.frame.size;
    imageCell.imageView.transform = CGAffineTransformIdentity;
    [imageCell.indicator stopAnimating];
    
    [self onSetCollectionViewScrollEnabled:YES];
}

#pragma mark
#pragma mark - Page Control

- (void)jumpToPageAtIndex:(NSUInteger)index atGroupIndex:(NSUInteger)groupIndex
{
    // Reset the bigger imageview
    [self resetImageCell];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:groupIndex];
    [self.imageCollectionView scrollToItemAtIndexPath:indexPath
                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                             animated:NO];
    [self updateControls];
    [self hideControlsAfterDelay];
}

- (void)showChangingNextGroup:(BOOL)isNext
{
    self.imageCollectionView.scrollEnabled = NO;
    isChangingGroup_ = YES;
    ImageGroup *currentGroup = (ImageGroup *)self.imageGroups[self.currentGroupIndex];
    
    [self addChangingGroupAnimationViewRight:isNext ? YES : NO];
    [self.view addSubview:self.changingGroupView];
        
    self.changingGroupDirection.text = isNext ?
                                       NSLocalizedString(@"group_changing_next", "Next Group") :
                                       NSLocalizedString(@"group_changing_previous", "Previous Group");
    self.changingGroupDescription.text = currentGroup.title;
    [self resizeChangingGroupAnimationView];
    
    CGRect endFrame = [self screenFrame];
    endFrame.origin.x = isNext ? -[self screenFrame].size.width : [self screenFrame].size.width;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.changingGroupView.frame = [self screenFrame];
                     }
                     completion:^(BOOL finished) {
                         [self setGroupDescription:currentGroup];
                         [self resizeDescriptionView];
                         [self jumpToPageAtIndex:currentImageIndex_ atGroupIndex:self.currentGroupIndex];
                         [UIView animateWithDuration:0.3
                                               delay:0.6
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              self.changingGroupView.frame = endFrame;
                                          }
                                          completion:^(BOOL finished) {
                                              [self.changingGroupView removeFromSuperview];
                                              self.imageCollectionView.scrollEnabled = YES;
                                              isChangingGroup_ = NO;
                                          }];
                     }];
}

- (void)showFirstPage
{
    self.imageCollectionView.scrollEnabled = NO;
    ImageGroup *currentGroup = (ImageGroup *)self.imageGroups[self.currentGroupIndex];
    
    [UIView animateWithDuration:0
                     animations:^{
                         
                     }
                     completion:^(BOOL finished) {
                         [self setGroupDescription:currentGroup];
                         [self resizeDescriptionView];
                         [self jumpToPageAtIndex:currentImageIndex_ atGroupIndex:self.currentGroupIndex];
                     }];
}

- (void)showCurrentPage
{
    self.imageCollectionView.scrollEnabled = NO;
    ImageGroup *currentGroup = (ImageGroup *)self.imageGroups[self.currentGroupIndex];
    
    [UIView animateWithDuration:0
                     animations:^{
                         
                     }
                     completion:^(BOOL finished) {
                         self.groupDescriptionTitle.text = [NSString stringWithFormat:@"< %@ >  %@", self.currentPageCategory, currentGroup.title];
                         self.groupDescriptionContent.text = currentGroup.description;
                         [self resizeDescriptionView];
                         [self jumpToPageAtIndex:imageIndexBeforeRotation_ atGroupIndex:groupIndexBeforeRotation_];
                     }];
}

#pragma mark
#pragma mark - Controls

- (void)toggleControls
{
    [self setControlsHidden:!isControlHidden_ animated:YES permanent:NO];
}

- (void)hideControls
{
    [self setControlsHidden:YES animated:YES permanent:NO];
}

- (void)updateControls
{
	// Title
    self.navigationItem.title = [NSString stringWithFormat:@"%i/%i",
                                 currentImageIndex_ + 1,
                                 self.imagesCountInGroup];
	
    // Favorite Button
    Image *image = [[self.imagesInAllGroup objectAtIndex:self.currentGroupIndex] objectAtIndex:currentImageIndex_];
    [self setFavoriteStatus:image.isFavorite];
}

- (void)hideControlsAfterDelay
{
	if (!isControlHidden_) {
        [self cancelHidingTimer];
		self.controlHideTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                 target:self
                                                               selector:@selector(hideControls)
                                                               userInfo:nil
                                                                repeats:NO];
	}
}

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent
{
    // Cancel timer
    [self cancelHidingTimer];
	isControlHidden_ = hidden;
	
	// Animate
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
    }
    
    // Navigation Bar
	self.navigationBar.alpha = hidden ? 0 : 1;
    self.groupDescriptionScrollView.alpha = hidden ? 0 : 1;
    self.buttonView.alpha = hidden ? 0 : 1;
    
	if (animated) {
        [UIView commitAnimations];
    }
    
	if (!permanent && !hidden) {
        [self hideControlsAfterDelay];
    }
	
}

- (void)cancelHidingTimer
{
	// If a timer exists then cancel and release
	if (self.controlHideTimer) {
		[self.controlHideTimer invalidate];
		self.controlHideTimer = nil;
	}
}

- (void)setFavoriteStatus:(BOOL)isFavorite
{
    NSString *imageName;
    if (INTERFACE_IS_PHONE) {
        imageName = isFavorite ? @"Icon_heart_favorite" : @"Icon_heart";
    } else {
        imageName = isFavorite ? @"Icon_heart_favorite_ipad" : @"Icon_heart_ipad";
    }
    
    if (self.favoriteButton) {
        [self.favoriteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
}

#pragma mark
#pragma mark - Action

- (IBAction)backToGridView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addToFavorite:(id)sender
{
    [self cancelHidingTimer];
    Image *image = [[self.imagesInAllGroup objectAtIndex:self.currentGroupIndex] objectAtIndex:currentImageIndex_];
    
    if ([[ImageDBOperator sharedInstance] updateFavoriteImage:image]) {
        image.isFavorite = !image.isFavorite;
    }
    
    [self setFavoriteStatus:image.isFavorite];
    [self hideControlsAfterDelay];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"favourite" object:nil];
}

- (IBAction)sharePhoto:(id)sender
{
    [self cancelHidingTimer];
    
    // Create share content
    NSString *message = @"Share Photo: ";
    UIImage *image = [self currentImageCell].imageView.image;
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
        [self hideControlsAfterDelay];
    };
    
    activityController.completionHandler = block;
    
    // Select your required server to share. (Default select all)
    //    activityController.excludedActivityTypes = (@[
    //                                                UIActivityTypeAssignToContact,
    //                                                UIActivityTypeMail,
    //                                                UIActivityTypeMessage,
    //                                                UIActivityTypePrint,
    //                                                UIActivityTypePostToFacebook,
    //                                                UIActivityTypePostToTwitter,
    //                                                UIActivityTypePostToWeibo
    //                                                ]);
    
    [self presentViewController:activityController animated:YES completion:nil];
}

- (IBAction)rotatePhoto:(id)sender
{
    [self cancelHidingTimer];
    ZoomImageCell *currentCell = [self currentImageCell];
    
    CATransition *transition = [CATransition animation];
	transition.type = @"rotate";
	transition.subtype = @"90cw";
    transition.duration = 0.15;
//    transition.removedOnCompletion = NO;
    [currentCell.imageView.layer addAnimation:transition forKey:@"Transition"];
    currentCell.imageView.image = [currentCell.imageView.image imageRotatedByDegrees:-90];
    
    self.currentImageOrientation = [currentCell.imageView.image
                                    rotateImageOrientation:self.currentImageOrientation
                                    isClockWise:NO];
    [self hideControlsAfterDelay];
}

- (IBAction)slideShow:(id)sender
{
    SlideShowViewController *slideShow = [[SlideShowViewController alloc] init];
    slideShow.isFavorite = NO;
    slideShow.slideSource = self.imagesInAllGroup[self.currentGroupIndex];
    [self presentViewController:slideShow animated:YES completion:nil];
}

- (IBAction)downloadPhoto:(id)sender
{
    [self cancelHidingTimer];
    UIImageWriteToSavedPhotosAlbum([self currentImageCell].imageView.image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   nil);
    
    [self hideControlsAfterDelay];
}

- (IBAction)goToNextGroup:(id)sender
{
    self.currentGroupIndex = self.currentGroupIndex + 1;
    currentImageIndex_ = 0;
    [self showChangingNextGroup:YES];
}

- (IBAction)goToPreviousGroup:(id)sender
{
    self.currentGroupIndex = self.currentGroupIndex - 1;
    currentImageIndex_ = 0;
    [self showChangingNextGroup:NO];
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

#pragma mark
#pragma mark - Private Method

- (ZoomImageCell *)currentImageCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentImageIndex_ inSection:self.currentGroupIndex];
    ZoomImageCell *currentCell = (ZoomImageCell *)[self.imageCollectionView cellForItemAtIndexPath:indexPath];
    return currentCell;
}

- (void)onGroupChanged:(NSUInteger)groupIndex
{
    if (groupIndex - self.currentGroupIndex == 1) {
        self.currentGroupIndex = groupIndex;
        currentImageIndex_ = 0;
        [self showChangingNextGroup:YES];
    } else if (self.currentGroupIndex - groupIndex == 1) {
        self.currentGroupIndex = groupIndex;
        currentImageIndex_ = self.imagesCountInGroup - 1;
        [self showChangingNextGroup:NO];
    }
}

- (NSUInteger)imagesCountInGroup
{
    return [[self.imagesCounts objectAtIndex:self.currentGroupIndex] integerValue];
}

- (void)setButtonEnabled:(BOOL)enabled
{
    [self.rotateButton setEnabled:enabled];
    [self.downloadButton setEnabled:enabled];
    [self.favoriteButton setEnabled:enabled];
    [self.shareButton setEnabled:enabled];
}

- (void)setGroupDescription:(ImageGroup *)group
{
    self.groupDescriptionTitle.text = [NSString stringWithFormat:@"%@", group.title];
    self.groupDescriptionTime.text = group.time;
    self.groupDescriptionCategory.text = [NSString stringWithFormat:@"%@: %@",
                                          NSLocalizedString(@"group_description_category", @"Category"),
                                          group.categories];
    self.groupDescriptionTag.text = [NSString stringWithFormat:@"%@: %@",
                                     NSLocalizedString(@"group_description_tag", @"Tag"),
                                     group.tags];
    self.groupDescriptionContent.text = group.description;
}

@end
