//
//  SearchNetOptionsViewController.m
//  Cooliris
//
//  Created by user on 13-6-18.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "SearchNetOptionsViewController.h"
#import "Toast+UIView.h"

@interface SearchNetOptionsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *footView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *widthField;
@property (strong, nonatomic) IBOutlet UITextField *heightField;

@property (nonatomic) NSIndexPath *lastResolutionIndex;

@end

@implementation SearchNetOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.lastResolutionIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

#pragma mark - Lifecycle Methods.

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(320, 300);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UItableview Datasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *forRecyle = @"ForRecyle";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:forRecyle];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:forRecyle];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    int row = [indexPath row];
    switch (row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"resolution_all", nil);
            break;
            
        case 1:
            cell.textLabel.text = @"1024 x 768";
            break;
            
        case 2:
            cell.textLabel.text = @"800 x 600";
            break;
            
        case 3:
            cell.textLabel.text = @"640 x 960";
            break;
            
        case 4:
            cell.textLabel.text = @"240 x 320";
            break;
            
        case 5:
            cell.textLabel.text = @"640 x 480";
            break;
            
        default:
            break;
    }
    
    int oldRow = [self.lastResolutionIndex row];
    cell.accessoryType = (row == oldRow && self.lastResolutionIndex != nil) ?
    UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableView Delegate Methods.

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int newRow = [indexPath row];
    int oldRow = (self.lastResolutionIndex != nil) ? [self.lastResolutionIndex row] : -1;
    
    if (newRow != oldRow) {
        
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType    = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastResolutionIndex];
        oldCell.accessoryType    = UITableViewCellAccessoryNone;
        
        self.lastResolutionIndex = indexPath;
        self.widthField.text     = nil;
        self.heightField.text    = nil;
        
        [self.delegate searchNetResolutionChanged:newRow resolution:newCell.textLabel.text];
    }
}

#pragma mark - UITextField Delegate Methods.

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView deselectRowAtIndexPath:self.lastResolutionIndex animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (nil != self.widthField.text && nil != self.heightField.text) {
        
        int width  = [self.widthField.text intValue];
        int height = [self.heightField.text intValue];
        
        if (width > 0 && height > 0) {
            [self.delegate searchNetResolutionChanged:width height:height];
            
            UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:self.lastResolutionIndex];
            oldCell.accessoryType    = UITableViewCellAccessoryNone;
        }
    } 
}

@end
