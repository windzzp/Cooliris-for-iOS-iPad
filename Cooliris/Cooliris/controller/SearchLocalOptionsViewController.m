//
//  SearchLocalOptionsViewController.m
//  Cooliris
//
//  Created by user on 13-6-18.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "SearchLocalOptionsViewController.h"
#import "SearchViewController.h"

@interface SearchLocalOptionsViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView  *scrollView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tagButtons;

@end

@implementation SearchLocalOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - LifeCycle Methods.

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scrollView.frame = CGRectMake(0, 0, 320, 280);
    self.scrollView.contentSize = CGSizeMake(960, 280);
    self.contentSizeForViewInPopover = CGSizeMake(320, 300);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction Methods.

- (IBAction)tagTap:(id)sender
{
    UIButton *tagBtn = (UIButton *)sender;
    [self.delegate searchLocalTagChanged:tagBtn.titleLabel.text];
}

#pragma mark - UIScrollView Delegate Methods.

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = floorf((scrollView.contentOffset.x - 320 / 100) / 320) + 1;
    [self.pageControl setCurrentPage:page];
}

@end
