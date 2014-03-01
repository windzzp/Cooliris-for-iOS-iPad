//
//  SearchOptionsViewController.m
//  Cooliris
//
//  Created by user on 13-6-18.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "SearchOptionsViewController.h"
#import "SearchNetOptionsViewController.h"
#import "SearchLocalOptionsViewController.h"

typedef enum {
    SearchOptionsSearchType = 0,
    SearchOptionsNetworkResolution,
    SearchOptionsLocalTheme
} SearchOptionsSections;

@interface SearchOptionsViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SearchNetOptionsViewController   *netOptionController;
@property (strong, nonatomic) SearchLocalOptionsViewController *localOptionCtontroller;

@property (nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) NSString *netDetailText;
@property (strong, nonatomic) NSString *localDetailText;

- (void)searchTypeSegmentedClicked:(UISegmentedControl *)control;

@end

@implementation SearchOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.netDetailText = NSLocalizedString(@"resolution_all", nil);
    }
    return self;
}

#pragma mark - LifeCycle Methods.

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(320, 300);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableview DataSource Mehtods.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *forRecyle = @"ForRecyle";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:forRecyle];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:forRecyle];
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    int row     = [indexPath row];
    int section = [indexPath section];
    
    switch (section) {
        case SearchOptionsSearchType:
            if (row == 0) {
                UISegmentedControl *layoutSegment = [[UISegmentedControl alloc] initWithItems:
                                                     @[
                                                     NSLocalizedString(@"net", @"Net"),
                                                     NSLocalizedString(@"local", @"Local")
                                                     ]];
                cell.textLabel.text = NSLocalizedString(@"search_type", @"Search Type");
                layoutSegment.frame = CGRectMake(0, 0, 200, 30);
                layoutSegment.segmentedControlStyle = UISegmentedControlStylePlain;
                layoutSegment.selectedSegmentIndex = self.selectedIndex;
                [layoutSegment addTarget:self action:@selector(searchTypeSegmentedClicked:) forControlEvents:UIControlEventValueChanged];
                
                cell.accessoryView = layoutSegment;
            }
            break;
            
        case SearchOptionsNetworkResolution:
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"resolution", @"Resolution");
                cell.detailTextLabel.text = self.netDetailText;
                if (self.selectedIndex == 0) {
                    cell.userInteractionEnabled = YES;
                    cell.textLabel.textColor = [UIColor blackColor];
                } else {
                    cell.userInteractionEnabled = NO;
                    cell.textLabel.textColor = [UIColor grayColor];
                }
            }
            break;
            
        case SearchOptionsLocalTheme:
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"theme", @"Theme");
                cell.detailTextLabel.text = self.localDetailText;
                if (self.selectedIndex == 0) {
                    cell.userInteractionEnabled = NO;
                    cell.textLabel.textColor = [UIColor grayColor];
                } else {
                    cell.userInteractionEnabled = YES;
                    cell.textLabel.textColor = [UIColor blackColor];
                }
            }
            break;
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - UITableView Delegate Methods.

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SearchOptionsSearchType:
            return NSLocalizedString(@"search_type", @"Search Type");
            break;
            
        case SearchOptionsNetworkResolution:
            return NSLocalizedString(@"net_search", @"Net Search");
            break;
            
        case SearchOptionsLocalTheme:
            return NSLocalizedString(@"local_search", @"Local Search");
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row     = [indexPath row];
    int section = [indexPath section];
    
    switch (section) {
        case SearchOptionsSearchType:

            break;
            
        case SearchOptionsNetworkResolution:
            if (row == 0) {
                if (nil == self.netOptionController) {
                    self.netOptionController = [[SearchNetOptionsViewController alloc] initWithNibName:@"SearchNetOptionsViewController" bundle:nil];
                    self.netOptionController.title = NSLocalizedString(@"resolution", @"Resolution");;
                    self.netOptionController.delegate = self;
                    self.netOptionController.contentSizeForViewInPopover = CGSizeMake(320, 300);
                }
                
                [self.navigationController pushViewController:self.netOptionController animated:YES];
            }
            break;
            
        case SearchOptionsLocalTheme:
            if (row == 0) {
                if (nil == self.localOptionCtontroller) {
                    self.localOptionCtontroller = [[SearchLocalOptionsViewController alloc] initWithNibName:@"SearchLocalOptionsViewController" bundle:nil];
                    self.localOptionCtontroller.title = NSLocalizedString(@"theme", @"Theme");
                    self.localOptionCtontroller.delegate = self;
                    self.localOptionCtontroller.contentSizeForViewInPopover = CGSizeMake(320, 300);
                }
                
                [self.navigationController pushViewController:self.localOptionCtontroller animated:YES];
            }
            break;
    }
}

- (void)searchTypeSegmentedClicked:(UISegmentedControl *)control
{
    NSIndexPath *netIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath *localIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    UITableViewCell *netCell = [self.tableView cellForRowAtIndexPath:netIndexPath];
    UITableViewCell *localCell = [self.tableView cellForRowAtIndexPath:localIndexPath];
    if (control.selectedSegmentIndex == 0) {
        localCell.userInteractionEnabled = NO;
        localCell.textLabel.textColor = [UIColor grayColor];
        localCell.detailTextLabel.text = nil;
        self.localDetailText = nil;
        netCell.userInteractionEnabled = YES;
        netCell.textLabel.textColor = [UIColor blackColor];
    } else {
        netCell.userInteractionEnabled = NO;
        netCell.textLabel.textColor = [UIColor grayColor];
        localCell.userInteractionEnabled = YES;
        localCell.textLabel.textColor = [UIColor blackColor];
    }
    self.selectedIndex = control.selectedSegmentIndex;
    [self.delegate searchTypeChanged:control.selectedSegmentIndex];
}

- (void)searchNetResolutionChanged:(NSInteger)index resolution:(NSString *)resolution
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.netDetailText = resolution;
    cell.detailTextLabel.text = self.netDetailText;
    [self.tableView reloadData];
    [self.delegate searchNetResolutionChanged:index resolution:resolution];
}

- (void)searchNetResolutionChanged:(NSInteger)width height:(NSInteger)height
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.netDetailText = [NSString stringWithFormat:@"%d x %d", width, height];
    cell.detailTextLabel.text = self.netDetailText;
    [self.tableView reloadData];
    [self.delegate searchNetResolutionChanged:width height:height];
}

- (void)searchLocalTagChanged:(NSString *)tag
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.localDetailText = tag;
    cell.detailTextLabel.text = self.localDetailText;
    [self.tableView reloadData];
    [self.delegate searchLocalTagChanged:tag];
}

@end
