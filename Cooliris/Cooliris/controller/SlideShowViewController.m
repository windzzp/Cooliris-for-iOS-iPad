//
//  SlideShowViewController.m
//  Cooliris
//
//  Created by user on 13-6-3.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SlideShowViewController.h"
#import "SlideShowSettingViewController.h"
#import "UIBarButtonItemEx.h"
#import "UIImageView+WebCache.h"
#import "MosaicData.h"
#import "Image.h"

@interface SlideShowViewController ()
{
    SlideShowSettingViewController *settingController_;
	NSUInteger currentIndex_;
    NSUInteger previousIndex_;
    NSTimer   *controlHideTimer_;
    NSTimer   *changeTimer_;
    BOOL       isControlHidden_;
    BOOL       isSliding_;
}

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIBarButtonItemEx *slideButton;

// Init
- (void)initNavigationBar;
- (void)initGestureRecognizer;
- (void)initData;

// SlideShow
- (void)SlideShowAfterDelay;
- (void)startSlide;
- (void)stopSlide;
- (void)nextImage;

// Action
- (IBAction)setting:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)toggleSlide:(id)sender;
- (void)dismiss;

// Controls
- (void)toggleControls;
- (void)hideControls;
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)cancelHidingTimer;
- (void)updateSlideButtonStatus;

@end

@implementation SlideShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.slideSource = [[NSArray alloc] init];
        currentIndex_ = 0;
        previousIndex_ = 0;
        if (!settingController_) {
            settingController_ = [[SlideShowSettingViewController alloc] init];
        }
        controlHideTimer_ = [[NSTimer alloc] init];
        changeTimer_ = [[NSTimer alloc] init];
        isControlHidden_ = YES;
        isSliding_ = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wantsFullScreenLayout = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self initNavigationBar];
    [self initGestureRecognizer];
    [self initData];
    
    [self hideControls];
    [self SlideShowAfterDelay];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    // Start Slide Show
    [self hideControls];
    [self SlideShowAfterDelay];
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
                                     action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Right Item -
    UIBarButtonItemEx *settingButton = [UIBarButtonItemEx
                                        initWithFrame:CGRectMake(0, 0, 60, 30)
                                        normalImage:[UIImage imageNamed:@"Icon_gear"]
                                        highlightImage:[UIImage imageNamed:@"Icon_gearSelected"]
                                        target:self
                                        action:@selector(setting:)];
    self.slideButton = [UIBarButtonItemEx
                        initWithFrame:CGRectMake(0, 0, 30, 30)
                        normalImage:[UIImage imageNamed:@"Icon_play"]
                        highlightImage:[UIImage imageNamed:@"Icon_play"]
                        target:self
                        action:@selector(toggleSlide:)];
    self.navigationItem.rightBarButtonItems = @[settingButton, self.slideButton];
    self.navigationItem.title = @"SlideShow";
    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"Icon_navigationbar_background_transparent"];
    [self.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)initGestureRecognizer
{
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(toggleControls)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTapRecognizer];
}

- (void)initData
{
    if (self.isFavorite) {
        MosaicData *imageData = (MosaicData *)[self.slideSource objectAtIndex:currentIndex_];
        [self.imageView setImageWithURL:[NSURL URLWithString:imageData.imageFilename]
                       placeholderImage:nil
                                options:currentIndex_ == 0 ? SDWebImageRefreshCached : 0];
    } else {
        Image *imageData = (Image *)[self.slideSource objectAtIndex:currentIndex_];
        [self.imageView setImageWithURL:[NSURL URLWithString:imageData.url]
                       placeholderImage:nil
                                options:currentIndex_ == 0 ? SDWebImageRefreshCached : 0];
    }
}

#pragma mark
#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
	return YES;
}

#pragma mark
#pragma mark - SlideShow

- (void)SlideShowAfterDelay
{
    [self stopSlide];
    isSliding_ = YES;
    changeTimer_ = [NSTimer scheduledTimerWithTimeInterval:settingController_.selectedInterval
                                                    target:self
                                                  selector:@selector(startSlide)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)startSlide
{
    isSliding_ = YES;
    [self hideControls];
	CATransition *transition = [CATransition animation];
	transition.type = settingController_.selectedType;
	transition.subtype = settingController_.selectedDirection;
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [self nextImage];
    [self.imageView.layer addAnimation:transition forKey:@"Transition"];
}

- (void)stopSlide
{
    isSliding_ = NO;
    if (changeTimer_) {
		[changeTimer_ invalidate];
		changeTimer_ = nil;
	}
    [self cancelHidingTimer];
}

- (void)nextImage
{
    if (settingController_.selectedOrder == SlideOrderOrdinal) {
        currentIndex_ ++;
        if (currentIndex_ >= [self.slideSource count]) {
            currentIndex_ = 0;
        }
    } else if (settingController_.selectedOrder == SlideOrderRandom) {
        while (currentIndex_ == previousIndex_ || currentIndex_ >= [self.slideSource count] - 1) {
            currentIndex_ = arc4random() % [self.slideSource count];
        }
    }
    
    if (self.isFavorite) {
        MosaicData *imageData = (MosaicData *)[self.slideSource objectAtIndex:currentIndex_];
        [self.imageView setImageWithURL:[NSURL URLWithString:imageData.imageFilename]
                       placeholderImage:nil
                                options:currentIndex_ == 0 ? SDWebImageRefreshCached : 0];
    } else {
        Image *imageData = (Image *)[self.slideSource objectAtIndex:currentIndex_];
        [self.imageView setImageWithURL:[NSURL URLWithString:imageData.url]
                       placeholderImage:nil
                                options:currentIndex_ == 0 ? SDWebImageRefreshCached : 0];
    }
    
    previousIndex_ = currentIndex_;
}

#pragma mark
#pragma mark - Action

- (IBAction)setting:(id)sender;
{
    [self stopSlide];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingController_];
    UIBarButtonItem *done = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self action:@selector(dismiss)];
    settingController_.navigationItem.rightBarButtonItem = done;
    
    navController.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)back:(id)sender;
{
    [self stopSlide];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleSlide:(id)sender
{
    isSliding_ = !isSliding_;
    if (isSliding_) {
        [self hideControls];
        [self SlideShowAfterDelay];
    } else {
        [self stopSlide];
    }
    [self updateSlideButtonStatus];
    [self hideControlsAfterDelay];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Start Slide Show
    isSliding_ = YES;
    [self hideControls];
    [self SlideShowAfterDelay];
}

#pragma mark
#pragma mark - Controls

- (void)toggleControls
{
    [self setControlsHidden:!isControlHidden_ animated:YES];
}

- (void)hideControls
{
    [self setControlsHidden:YES animated:YES];
}

- (void)hideControlsAfterDelay
{
	if (!isControlHidden_) {
		controlHideTimer_ = [NSTimer scheduledTimerWithTimeInterval:5
                                                             target:self
                                                           selector:@selector(hideControls)
                                                           userInfo:nil
                                                            repeats:NO];
	}
}

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated
{
    isControlHidden_ = hidden;
    if (!hidden) {
        [self hideControlsAfterDelay];
    }
    [self updateSlideButtonStatus];
	
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
    }
	self.navigationBar.alpha = hidden ? 0 : 1;
    
	if (animated) {
        [UIView commitAnimations];
    }
}

- (void)cancelHidingTimer
{
	// If a timer exists then cancel and release
	if (controlHideTimer_) {
		[controlHideTimer_ invalidate];
		controlHideTimer_ = nil;
	}
}

- (void)updateSlideButtonStatus
{
    NSString *imageName = isSliding_ ? @"Icon_pause" : @"Icon_play";
    [self.slideButton setNormalImage:[UIImage imageNamed:imageName]];
    [self.slideButton setHighlightImage:[UIImage imageNamed:imageName]];
}

@end
