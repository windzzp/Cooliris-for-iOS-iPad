//
//  OptionsViewController.m
//  Cooliris
//
//  Created by user on 13-6-13.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "OptionsViewController.h"
#define kCustom_Layout_Key        @"layout"
#define kNotification_Layout      @"changeLayout"

#define kImage_Cell_Show_Detail   @"imageCellShowDetail"
#define kNotification_Show_Detail @"showDetail"

typedef enum {
    OptionSectionLayout = 0,
    OptionSectionDetail,
    
    OptionSectionsCount
} OptionsTypeSections;

//typedef enum {
//    OptionsLayoutGridMode = 0,
//    OptionsLayoutWaterFlowMode,
//} OptionsTypeLayout;
//
//typedef enum {
//    OptionsDetailShow
//}OptionsDetailState;

@interface OptionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)layoutStyleSegmentedControlChanged:(UISegmentedControl *)control;
- (void)detailStateSwitchControlChanged:(UISwitch *)control;

@end

@implementation OptionsViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 45;
    
    if ([indexPath section] == OptionSectionLayout)
    {
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return OptionSectionsCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"Unknown";
    
    switch (section)
    {
        case OptionSectionLayout:
            title = NSLocalizedString(@"layout", @"Layout");
            break;
            
        case OptionSectionDetail:
            title = NSLocalizedString(@"detail", @"Detail");
            break;
            
        default:
            break;
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    switch (section)
    {
        case OptionSectionLayout:
            count = 1;
            break;
            
        case OptionSectionDetail:
            count = 1;
            break;
            
        default:
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    int section = [indexPath section];
    int row = [indexPath row];
    switch (section) {
        case OptionSectionLayout:
            if (0 == row) {
                cell.detailTextLabel.text = NSLocalizedString(@"layout", @"Layout");
                
                //UISegmentedControl *layoutSegment = [UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 100, 50);
                UISegmentedControl *layoutSegment = [[UISegmentedControl alloc] initWithItems:
                                                     @[
                                                       [UIImage imageNamed:@"Icon_flow"],
                                                       [UIImage imageNamed:@"Icon_grid"],
                                                       [UIImage imageNamed:@"Icon_list"]
                                                     //@"Grid", @"WaterFlow"
                                                     ]];
                layoutSegment.frame = CGRectMake(0, 0, 200, 30);
                layoutSegment.segmentedControlStyle = UISegmentedControlStylePlain;
                NSNumber *layoutIndex = [[NSUserDefaults standardUserDefaults]
                                         objectForKey:kCustom_Layout_Key];
                if (nil == layoutIndex) {
                    layoutSegment.selectedSegmentIndex = 0;
                } else {
                    layoutSegment.selectedSegmentIndex = layoutIndex.integerValue;
                }
                
                [layoutSegment addTarget:self action:@selector(layoutStyleSegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
                
                cell.accessoryView = layoutSegment;
            }
            break;
            
        case OptionSectionDetail:
            if (0 == row) {
                cell.detailTextLabel.text = NSLocalizedString(@"show_detail", @"Show Detail Info");
                UISwitch *showDetailSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
                showDetailSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kImage_Cell_Show_Detail];
                [showDetailSwitch addTarget:self action:@selector(detailStateSwitchControlChanged:) forControlEvents:UIControlEventValueChanged];
                
                cell.accessoryView = showDetailSwitch;
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Private methods

- (void)layoutStyleSegmentedControlChanged:(UISegmentedControl *)control
{
    NSLog(@"SegmentedControlChanged");
//    if (_delegate) {
//        [_delegate layoutTypeChanged:control.selectedSegmentIndex];
//    }
    int newIndex = control.selectedSegmentIndex;
    NSNumber *old = [[NSUserDefaults standardUserDefaults] objectForKey:kCustom_Layout_Key];
    int oldIndex = [old intValue];
    if (newIndex != oldIndex) {
        // Save the user select to userdefault.
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newIndex]
                                                  forKey:kCustom_Layout_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Notify other ViewController to relayout UI.
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Layout
                                                            object:[NSNumber numberWithInt:newIndex]];
    }
}

- (void)detailStateSwitchControlChanged:(UISwitch *)control
{
    NSLog(@"SwitchControlChanged");
    [[NSUserDefaults standardUserDefaults] setBool:control.isOn forKey:kImage_Cell_Show_Detail];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Notify other ViewController to relayout UI.
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Show_Detail
                                                        object:[NSNumber numberWithBool:control.isOn]];
    
//    if (_delegate) {
//        [_delegate showDetailInfoChanged:control.on];
//    }
}

@end
