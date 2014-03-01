//
//  AboutViewController.m
//  Cooliris
//
//  Created by user on 13-5-23.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (strong,nonatomic) IBOutlet UIImageView *appIcon;
@property (strong,nonatomic) IBOutlet UILabel *appName;
@property (strong,nonatomic) IBOutlet UILabel *welcome;
@property (strong,nonatomic) IBOutlet UILabel *version;
@property (strong,nonatomic) IBOutlet UILabel *authorTitle;
@property (strong,nonatomic) IBOutlet UILabel *author;
@property (strong,nonatomic) IBOutlet UILabel *contactTitle;
@property (strong,nonatomic) IBOutlet UILabel *contact;
@property (strong,nonatomic) IBOutlet UILabel *addressTitle;
@property (strong,nonatomic) IBOutlet UILabel *address;

@end

@implementation AboutViewController

#pragma mark Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark Lifecyle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self resetViewFrame];
    self.title = NSLocalizedString(@"about", @"About");
    NSString *version = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.version.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"version", @"Version"), version];
    self.welcome.text = NSLocalizedString(@"welcome", @"Welcome");
    self.authorTitle.text = NSLocalizedString(@"author_title", @"Author");
    self.author.text = NSLocalizedString(@"author", @"Author");
    self.contactTitle.text = NSLocalizedString(@"contact_title", @"Contact");
    self.contact.text = NSLocalizedString(@"contact", @"Contact");
    self.addressTitle.text = NSLocalizedString(@"address_title", @"Address");
    self.address.text = NSLocalizedString(@"address", @"Address");
}

#pragma mark System Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    [self resetViewFrame];
}

- (void)resetViewFrame
{
    if (INTERFACE_IS_PAD) {
        self.appIcon.frame = CGRectMake(0, 60, self.view.frame.size.width, 140);
        self.appName.frame = CGRectMake(0, 220, self.view.frame.size.width, 30);
        self.welcome.frame = CGRectMake(0, 270, self.view.frame.size.width, 30);
        self.version.frame = CGRectMake(0, 380, self.view.frame.size.width, 30);
        CGFloat originX = 130;
        CGFloat originY = 450;
        self.authorTitle.frame = CGRectMake(originX, originY, 80, 20);
        self.author.frame = CGRectMake(originX + 80, originY, 250, 20);
        self.contactTitle.frame = CGRectMake(originX, originY + 25, 80, 20);
        self.contact.frame = CGRectMake(originX + 80, originY + 25, 250, 20);
        self.addressTitle.frame = CGRectMake(originX, originY + 50, 80, 20);
        self.address.frame = CGRectMake(originX + 80, originY + 50, 250, 20);
        
    } else {
        self.appIcon.frame = CGRectMake(0, 60, self.view.frame.size.width, 80);
        self.appName.frame = CGRectMake(0, 160, self.view.frame.size.width, 30);
        self.welcome.frame = CGRectMake(0, 200, self.view.frame.size.width, 30);
        self.version.frame = CGRectMake(0, 280, self.view.frame.size.width, 30);
        CGFloat originX = 50;
        CGFloat originY = 320;
        self.authorTitle.frame = CGRectMake(originX, originY, 60, 20);
        self.author.frame = CGRectMake(originX + 60, originY, 250, 20);
        self.contactTitle.frame = CGRectMake(originX, originY + 20, 80, 20);
        self.contact.frame = CGRectMake(originX + 60, originY + 20, 250, 20);
        self.addressTitle.frame = CGRectMake(originX, originY + 40, 80, 20);
        self.address.frame = CGRectMake(originX + 60, originY + 40, 250, 20);
        
        [self.appName setFont:[UIFont boldSystemFontOfSize:20]];
        [self.welcome setFont:[UIFont systemFontOfSize:15]];
        [self.version setFont:[UIFont systemFontOfSize:15]];
        [self.authorTitle setFont:[UIFont systemFontOfSize:12]];
        [self.author setFont:[UIFont systemFontOfSize:12]];
        [self.contactTitle setFont:[UIFont systemFontOfSize:12]];
        [self.contact setFont:[UIFont systemFontOfSize:12]];
        [self.addressTitle setFont:[UIFont systemFontOfSize:12]];
        [self.address setFont:[UIFont systemFontOfSize:12]];
    }
}

@end
