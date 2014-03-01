//
//  AbsPageViewController.m
//  Cooliris
//
//  Created by user on 13-6-25.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "AbsPageViewController.h"

@interface AbsPageViewController ()

@end

@implementation AbsPageViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationBar
{
    // Default do nothing
}

- (void)refreshData
{
    // Default do nothing
}

- (void)relayout:(LayoutType)layoutType
{
    
}

@end
