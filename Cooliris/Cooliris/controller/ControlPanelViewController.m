//
//  CategoryViewController.m
//  Cooliris
//
//  Created by user on 13-6-17.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "ControlPanelViewController.h"
#import "CPHeaderView.h"
#import "NavigationView.h"
#import "SettingsViewController.h"
#import "PageInfoManager.h"
#import "PageGroupInfo.h"
#import "PageInfo.h"

#define kHeaderHeight   44.0
#define kFooterHeight   0
#define kCellHeight     60.0
#define kTableViewWidth 260.0


static NSString *logoNames[] = {
    @"Icon_all",
    @"Icon_ikon",
    @"Icon_photography",
    @"Icon_life",
    @"Icon_inspiration",
    @"Icon_design",
    @"Icon_load",
    @"Icon_course",
    @"Icon_original"
};

@interface ControlPanelViewController () <UITableViewDataSource, UITableViewDelegate, CPHeaderViewDelegate>

// Table view
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// Navigation bar
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
// The saved header view list
@property (strong, nonatomic) NSMutableArray *headerViews;
// Current selected section
@property (nonatomic) NSInteger currentSection;
// Current selected row
@property (nonatomic) NSInteger currentRow;
// Page info groups
@property (strong, nonatomic) NSArray *pageInfoGroups;
//@property (strong, nonatomic) NSDictionary *pageGroupDict;

- (void)didTappedSetting:(id)sender;

@end

@implementation ControlPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentSection = -1;
        self.currentRow = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //[_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kTableViewSectionHeaderViewIdentifier];
    //[_tableView registerClass:[CPCellView class] forCellReuseIdentifier:@"CPCellView"];
    //UINib *nib = [UINib nibWithNibName:@"CPCellView" bundle:nil];
    //[_tableView registerNib:nib forCellReuseIdentifier:@"CPCellView"];
    
    // Load page info groups
    _pageInfoGroups = [[PageInfoManager sharedInstance] loadPageInfoGroups];
    //_pageGroupDict = [PageInfoManager sharedInstance].pageGroupsDict;
    
    // Set table view bounds
    _tableView.bounds = CGRectMake(0, 0, kTableViewWidth, self.view.bounds.size.height);
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Create header views
    _headerViews = [@[] mutableCopy];
    CPHeaderView *headerView = nil;
    int count = _pageInfoGroups.count;
    for (int ix = 0; ix < count; ++ix) {
        headerView = [[CPHeaderView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, kHeaderHeight)];
        //headerView.title = kSectionTypeNames[ix];
        headerView.title = ((PageGroupInfo *)_pageInfoGroups[ix]).title;
        headerView.delegate = self;
        
        [_headerViews addObject:headerView];
    }
    
//    NSArray *sections = [_pageGroupDict allKeys];
//    PageGroupInfo *group = nil;
//    for (NSString *key in sections) {
//        group = _pageGroupDict[key];
//        
//        headerView = [[CPHeaderView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, kHeaderHeight)];
//        headerView.title = group.title;
//        headerView.delegate = self;
//        
//        if (kPageGroupThemeCategory == group.groupType) {
//        }
//    }
    
    // Initialize login controller
    // Add a custom view to the navigation bar
    NavigationView *navigationView = [[NavigationView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    navigationView.cellMode = NavigationMode;
    navigationView.frame = CGRectMake(0, 0, kTableViewWidth, self.navigationBar.bounds.size.height);
    
    navigationView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon_cp_navigationbar_background"]];
    //navigationView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    navigationView.imageView.image = [UIImage imageNamed:@"Icon_cp_logo"];
    
    navigationView.textLabel.backgroundColor = [UIColor clearColor];
    navigationView.detailTextLabel.backgroundColor = [UIColor clearColor];
    navigationView.textLabel.textColor = [UIColor lightGrayColor];
    navigationView.detailTextLabel.textColor = [UIColor grayColor];
    navigationView.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    navigationView.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    
    navigationView.textLabel.text = @"lin liu";
    navigationView.detailTextLabel.text = @"woyaowenzi@gmail.com";
    
    // Accessory view
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [button addTarget:self action:@selector(didTappedSetting:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"Icon_gear"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"Icon_gearSelected"] forState:UIControlStateHighlighted];
    navigationView.accessoryView = button;
        
    [self.navigationBar addSubview:navigationView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _pageInfoGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CPHeaderView *header = _headerViews[section];
    if (!header.isActivied) {
        return 0;
    }
    
    return ((PageGroupInfo *)_pageInfoGroups[section]).pageInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *identify = @"CPCellView";
//    CPCellView *cell = [tableView dequeueReusableCellWithIdentifier:identify];
//    if (!cell) {
//        cell = [[CPCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
//    }
//    cell.title.text = @"ABC";
    
    static NSString *identify = @"Cell";
    NavigationView *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[NavigationView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
        cell.cellMode = CustomCellMode;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    // Set background image
    cell.bounds = CGRectMake(0, 0, kTableViewWidth, cell.bounds.size.height);
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon_cp_cell_background"]];
    
    // Set default icon
    cell.imageView.image = [UIImage imageNamed:@"Icon_gear"];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

    [cell.textLabel setFont:[UIFont systemFontOfSize:18.0]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setTextColor:[UIColor lightGrayColor]];
    
    //cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Set the cell's information
    int section = indexPath.section;
    int row = indexPath.row;
    PageGroupInfo *group = (PageGroupInfo *)_pageInfoGroups[section];
    if (group.pageInfos.count > 0) {
        cell.textLabel.text = ((PageInfo *)group.pageInfos[row]).title;
        cell.imageView.image = [UIImage imageNamed:logoNames[row]];
    }
    
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch (section) {            
//        case kSectionCategory:
//            return @"Category";
//            
//        case kSectionFavorite:
//            return @"Favorite";
//            
//        case kSectionSearch:
//            return @"Search";
//            
//        default:
//            return nil;
//    }
//}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _headerViews[section];
//    UIView *header = [[CPHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
//    return header;
    
//    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTableViewSectionHeaderViewIdentifier];
//    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
//    [customView setBackgroundColor:[UIColor blueColor]];
//    [header.contentView addSubview:customView];
//    header.textLabel.text = @"TEXT";
//    header.backgroundColor = [UIColor redColor];
//    return header;
}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    // custom view for footer. will be adjusted to default or specified footer height
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kFooterHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentRow = indexPath.row;
    if (_delegate && [_delegate respondsToSelector:@selector(section:didSelectRowAtIndexPath:)]) {
        CPHeaderView *header = _headerViews[indexPath.section];
        [_delegate section:header didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - CPHeaderViewDelegate

- (void)selectedHeaderWith:(CPHeaderView *)headerView
{
    int section = [_headerViews indexOfObject:headerView];
    
    // Un-highlighted the other header view
    for (int ix = 0; ix < _headerViews.count; ++ix) {
        if (ix != section) {
            [_headerViews[ix] setHighlighted:NO];
        }
    }
    
    if (headerView.isActivied) {
        if (self.currentSection == section) {
            headerView.isActivied = NO;
            
            int rowCount = [_tableView numberOfRowsInSection:section];
            NSMutableArray *operationItems = [@[] mutableCopy];
            for (int ix = 0; ix < rowCount; ++ix) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ix inSection:section];
                [operationItems addObject:indexPath];
            }
            
            [_tableView deleteRowsAtIndexPaths:operationItems withRowAnimation:UITableViewRowAnimationTop];
        }
        
    } else {
        headerView.isActivied = YES;
        
        int rowCount = ((PageGroupInfo *)_pageInfoGroups[section]).pageInfos.count;
        NSMutableArray *operationItems = [@[] mutableCopy];
        for (int ix = 0; ix < rowCount; ++ix) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ix inSection:section];
            [operationItems addObject:indexPath];
        }
        [_tableView insertRowsAtIndexPaths:operationItems withRowAnimation:UITableViewRowAnimationTop];
        
        if (section == 0 && [self.tableView respondsToSelector:@selector(selectRowAtIndexPath:animated:scrollPosition:)]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentRow inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    if (section != 0 && [self.tableView respondsToSelector:@selector(deselectRowAtIndexPath:animated:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentRow inSection:0];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        self.currentRow = -1;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(section:didSelectAtSection:AtIndex:)]) {
        self.currentSection = section;
        [_delegate section:headerView didSelectAtSection:section AtIndex:self.currentRow];
    }
}

- (void)didTappedSetting:(id)sender
{
    SettingsViewController *controller    = [[SettingsViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    UIBarButtonItem *done = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self action:@selector(dimiss)];
    controller.navigationItem.rightBarButtonItem = done;
    
    navController.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStyleFlipHorizontal;// UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)dimiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ControlPanelDelegate

- (void)updateControlPanelSection:(int)section AtIndex:(int)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:section];
    CPHeaderView *headerView = [_headerViews objectAtIndex:section];
        
    if (self.currentSection != section)
    {
        [self selectedHeader:headerView];
    }
        
    if (self.currentSection == 0 &&
        [self.tableView respondsToSelector:@selector(selectRowAtIndexPath:animated:scrollPosition:)]) {
        self.currentRow = index;
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)selectedHeader:(CPHeaderView *)headerView
{
    int section = [_headerViews indexOfObject:headerView];
    self.currentSection = section;
    
    CPHeaderView *themeHeader = [_headerViews objectAtIndex:0];
    
    if (section == 0 && !headerView.isActivied) {
        headerView.isActivied = YES;
        
        int rowCount = ((PageGroupInfo *)_pageInfoGroups[section]).pageInfos.count;
        NSMutableArray *operationItems = [@[] mutableCopy];
        for (int ix = 0; ix < rowCount; ++ix) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ix inSection:section];
            [operationItems addObject:indexPath];
        }
        [_tableView insertRowsAtIndexPaths:operationItems withRowAnimation:UITableViewRowAnimationTop];
    }
    
    if (section!= 0 && themeHeader.isActivied) {
        themeHeader.isActivied = NO;
        
        int rowCount = [_tableView numberOfRowsInSection:0];
        NSMutableArray *operationItems = [@[] mutableCopy];
        for (int ix = 0; ix < rowCount; ++ix) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ix inSection:0];
            [operationItems addObject:indexPath];
        }
        
        [_tableView deleteRowsAtIndexPaths:operationItems withRowAnimation:UITableViewRowAnimationTop];
        self.currentRow = -1;
    }
    
    // Un-highlighted the other header view
    for (int ix = 0; ix < _headerViews.count; ++ix) {
        if (ix == section) {
            [_headerViews[ix] setHighlighted:YES];
            ((CPHeaderView *)_headerViews[ix]).isActivied = YES;
        } else {
            [_headerViews[ix] setHighlighted:NO];
            ((CPHeaderView *)_headerViews[ix]).isActivied = NO;
        }
    }
}

@end
