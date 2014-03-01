//
//  SlideShowSettingViewController.m
//  Cooliris
//
//  Created by user on 13-6-4.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "SlideShowSettingViewController.h"

#define NSUserDefault_Key_Slide_Type_Index      @"SlideShowSettingSelectedTypeIndex"
#define NSUserDefault_Key_Slide_Interval_Index  @"SlideShowSettingSelectedIntervalIndex"
#define NSUserDefault_Key_Slide_Direction_Index @"SlideShowSettingSelectedDirectionIndex"
#define NSUserDefault_Key_Slide_Order_Index     @"SlideShowSettingSelectedOrderIndex"

static NSString *slideTypes[] = {
    @"fade",
    @"cameraIris",
    @"rippleEffect",
    @"suckEffect",
    @"rotate",
    @"moveIn",
    @"push",
    @"reveal",
    @"cube",
    @"alignedCube",
    @"flip",
    @"alignedFlip",
    @"pageCurl",
    @"pageUnCurl",
};

static NSString *slideSubtypes[] = {
    @"fromRight",
    @"fromLeft",
    @"fromBottom",
    @"fromTop",
    @"90ccw",
    @"90cw",
    @"180ccw",
    @"180cw"};

static NSTimeInterval slideIntervals[] = {5, 10, 30, 60};

typedef enum {
    SettingSectionType = 0,
    SettingSectionDirection,
    SettingSectionInterval,
    SettingSectionOrder
} SettingSections;

@interface SlideShowSettingViewController ()

@property (strong, nonatomic) IBOutlet UITableView *settingTable;

@property (strong, nonatomic) NSArray *settingList;
@property (strong, nonatomic) NSArray *settingKey;
@property (strong, nonatomic) NSArray *rotateAngles;
@property (nonatomic) NSUInteger selectedTypeIndex;
@property (nonatomic) NSUInteger selectedDirectionIndex;
@property (nonatomic) NSUInteger selectedIntervalIndex;
@property (nonatomic) NSUInteger selectedOrderIndex;

- (BOOL)selectedTypeHasDirection;

@end

@implementation SlideShowSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.selectedTypeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:NSUserDefault_Key_Slide_Type_Index];
        self.selectedDirectionIndex = [[NSUserDefaults standardUserDefaults] integerForKey:NSUserDefault_Key_Slide_Direction_Index];
        self.selectedIntervalIndex = [[NSUserDefaults standardUserDefaults] integerForKey:NSUserDefault_Key_Slide_Interval_Index];
        self.selectedOrderIndex = [[NSUserDefaults standardUserDefaults] integerForKey:NSUserDefault_Key_Slide_Order_Index];
        self.settingList = [[NSArray alloc] init];
        self.settingKey = [[NSArray alloc] init];
        self.rotateAngles = @[NSLocalizedString(@"slide_setting_direction_rotate_clock_wise_90", @"90 C.W."),
                              NSLocalizedString(@"slide_setting_direction_rotate_unclock_wise_90", @"90 C.C.W."),
                              NSLocalizedString(@"slide_setting_direction_rotate_clock_wise_180", @"180 C.W."),
                              NSLocalizedString(@"slide_setting_direction_rotate_unclock_wise_180", @"180 C.C.W.")];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"SlideShowSettingList" ofType:@"plist"];
    NSArray *dataArray = [[NSArray alloc] initWithContentsOfFile:path];
    self.settingList = dataArray;
    self.title = NSLocalizedString(@"slideshow_setting", @"SlideShow Setting");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.settingList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self.settingList[section]];
    NSString *key = (NSString *)dict.allKeys[0];
    return key;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // For Direction section (section == 2) :
    // If selected slide type has no direction, direction section is "--",
    // otherwise, direction section has four options.
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self.settingList[section]];
    NSString *key = (NSString *)dict.allKeys[0];
    NSArray *settingSection = [dict objectForKey:key];
    switch (section) {
        case SettingSectionType:
        case SettingSectionInterval:
        case SettingSectionOrder:
            return [settingSection count];
            break;
            
        case SettingSectionDirection:
            if ([self selectedTypeHasDirection]) {
                return [settingSection count];
            } else {
                return 1;
            }
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self.settingList[section]];
    NSString *key = (NSString *)dict.allKeys[0];
    NSArray *settingSection = [dict objectForKey:key];
    NSString *item = [settingSection objectAtIndex:row];
    
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SectionsTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:SectionsTableIdentifier];
    }
                
    cell.textLabel.text = item;
    
    // Draw selected mark and refresh data.
    switch (section) {
        case SettingSectionType:
            if (self.selectedTypeIndex == row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
            
        case SettingSectionInterval:
            if (self.selectedIntervalIndex == row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
            
        case SettingSectionDirection:
            if (![self selectedTypeHasDirection]) {
                cell.textLabel.text = @"--";
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else if (self.selectedTypeIndex == 4) {
                cell.textLabel.text = self.rotateAngles[row];
                if (self.selectedDirectionIndex - 4 == row) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                if (self.selectedDirectionIndex == row) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            break;
            
        case SettingSectionOrder:
            if (self.selectedOrderIndex == row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
    }
    
    return cell;
}

#pragma mark
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    switch (section) {
        case SettingSectionType:
            if (row <= 3) {
                // If selected type has no direction, change direction section data to none.
                self.selectedDirectionIndex = 0;
            } else if (row == 4) {
                // If selected type is "rotate", change direction section data to angle parameter.
                if (self.selectedTypeIndex != row) {
                    self.selectedDirectionIndex = 4;
                }
            } else {
                if (self.selectedTypeIndex <= 4) {
                    self.selectedDirectionIndex = 0;
                }
            }
            
            if (self.selectedTypeIndex != row) {
                self.selectedTypeIndex = row;
            }
            
            break;
            
        case SettingSectionInterval:
            if (self.selectedIntervalIndex != row) {
                self.selectedIntervalIndex = row;
            }
            
            break;
            
        case SettingSectionDirection:
            if (![self selectedTypeHasDirection]) {
                // If selected type has no direction, change direction section data to none.
                self.selectedDirectionIndex = 0;
            } else if (self.selectedTypeIndex == 4) {
                // If selected type is "rotate", change direction section data to angle parameter.
                self.selectedDirectionIndex = row + 4;
            } else {
                self.selectedDirectionIndex = row;
            }
            
            break;
            
        case SettingSectionOrder:
            if (self.selectedOrderIndex != row) {
                self.selectedOrderIndex = row;
            }
            break;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.selectedTypeIndex forKey:NSUserDefault_Key_Slide_Type_Index];
    [defaults setInteger:self.selectedIntervalIndex forKey:NSUserDefault_Key_Slide_Interval_Index];
    [defaults setInteger:self.selectedDirectionIndex forKey:NSUserDefault_Key_Slide_Direction_Index];
    [defaults setInteger:self.selectedOrderIndex forKey:NSUserDefault_Key_Slide_Order_Index];
    [defaults synchronize];
    
	[tableView reloadData];
}

#pragma mark
#pragma mark - Porperty

- (BOOL)selectedTypeHasDirection
{
    if (self.selectedTypeIndex <= 3) {
        // If selected type has no direction, change direction section data to none.
        return NO;
    }
    
    return YES;
}

- (NSString *)selectedType
{
	return slideTypes[self.selectedTypeIndex];
}

- (NSString *)selectedDirection
{
	return slideSubtypes[self.selectedDirectionIndex];
}

- (NSTimeInterval)selectedInterval
{
	return slideIntervals[self.selectedIntervalIndex];
}

- (NSUInteger)selectedOrder
{
    return self.selectedOrderIndex;
}

@end
