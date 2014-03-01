//
//  SettingsViewController.m
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "AppDelegate.h"
#import "SlideShowSettingViewController.h"

#define kCustom_Layout_Key        @"layout"
#define kNotification_Layout      @"changeLayout"

#define kImage_Cell_Show_Detail   @"imageCellShowDetail"
#define kNotification_Show_Detail @"showDetail"

typedef enum {
    SettingSectionCache = 0,
    SettingSectionSlideShow,
    SettingSectionLayout,
    SettingSectionDetail,
    SettingSectionAbout
} SettingSections;

@interface SettingsViewController ()

@property (strong, nonatomic) AboutViewController *aboutViewController;

@property (strong, nonatomic) UIActivityIndicatorView *clearIndicatorView;
@property (strong, nonatomic) UILabel *sizeLabel;

@property (nonatomic) float  currentCacheSize;
@property (nonatomic) NSIndexPath *lastIndex;

- (void)clearCache;

@end

@implementation SettingsViewController

#pragma mark - Init Method

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

#pragma mark - LifeCycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title             = NSLocalizedString(@"setting", @"Setting");;
    self.currentCacheSize  = 0.0;
  
    // The IndicatorView When Clear Cache.
    self.clearIndicatorView = [[UIActivityIndicatorView alloc] init];
    self.clearIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.clearIndicatorView.color = [UIColor blackColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // About View Controller.
    if (nil == self.aboutViewController) {
        self.aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController"
                                                                         bundle:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // Get Cache Size In Background
    __block float size = 0.0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [cache objectAtIndex:0];
        size = [self fileSizeForDir:cachePath];
        
        // Update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentCacheSize = size;
            NSString *cacheSize = NSLocalizedString(@"current_cache", @"Cache Size : %.2fMB");
            self.sizeLabel.text = [NSString stringWithFormat:cacheSize,self.currentCacheSize];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)clearCache
{
    [self.clearIndicatorView startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // Get Cache Path
        NSLog(@"clear cache start ...");
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *paths = nil;
        paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSMutableString *path = [paths objectAtIndex:0];
        NSDictionary *attributes = [manager attributesOfItemAtPath:path error:nil];
        
        // Delete Cache
        if ([manager isDeletableFileAtPath:path]) {
            [manager removeItemAtPath:path error:nil];
            [manager createDirectoryAtPath:path withIntermediateDirectories:YES
                                attributes:attributes error:nil];
            NSLog(@"clear cache finish ...");
            [NSThread sleepForTimeInterval:1.0];
        }
        
        // Update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *clearindex = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView cellForRowAtIndexPath:clearindex].userInteractionEnabled = YES;
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            [self.clearIndicatorView stopAnimating];
            self.currentCacheSize = 0.00;
            NSString *cacheSize = NSLocalizedString(@"current_cache", @"Cache Size : %.2fMB");
            self.sizeLabel.text = [NSString stringWithFormat:cacheSize,self.currentCacheSize];
        });
    });
}

- (float)fileSizeForDir:(NSString *)path
{
    // Get FileManager And Path
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    float size = 0;
    NSArray *array = [fileManger contentsOfDirectoryAtPath:path error:nil];
    
    // Get Every File Size In Cache Directroy
    for (int i = 0; i < [array count]; i++) {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        BOOL isDir;
        
        // Get File Size And Convert to ..MB.
        if (!([fileManger fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)) {
            NSDictionary *fileAtrributeDic = [fileManger attributesOfItemAtPath:fullPath error:nil];
            size += fileAtrributeDic.fileSize / 1024.0 / 1024.0;
        } else {
            
            // Recursion Get File Size
            size += [self fileSizeForDir:fullPath];
        }
    }
    return size;
}

- (void)sendAdviceEmail
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        mailer.navigationBar.tintColor = [UIColor whiteColor];

        [mailer setSubject:NSLocalizedString(@"advice", "Advice")];
        
        // Set up recipients
        NSArray *toRecipients  = @[@"woyaowenzi@126.com"];
        //NSArray *ccRecipients  = @[@"liulin-1985@163.com"];
        //NSArray *bccRecipients = @[@"woyaoowenzi@yahoo.com.hk"];
        [mailer setToRecipients:toRecipients];
        //[mailer setCcRecipients:ccRecipients];
        //[mailer setBccRecipients:bccRecipients];
        
        // Add web image into mailbody
        NSMutableString *emailBody = [NSMutableString string];
        NSString *url = @"http://farm8.staticflickr.com/7381/8777040719_ac79e3b4d3_n.jpg";
        [emailBody appendFormat:@"<div> <img src='%@'> </div> <br>", url];
        [emailBody appendString:NSLocalizedString(@"feedback_advice", "Advice")];
        
        // Send Email
        [mailer setMessageBody:emailBody isHTML:YES];
        mailer.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:mailer animated:YES completion:^{}];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Failure"
                                                        message:@"Your device doesn't support in-app email"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
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
}

#pragma mark - UITableview Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
            
        case SettingSectionCache:
            return 1;
            break;
            
        case SettingSectionSlideShow:
            return 1;
            break;
            
        case SettingSectionLayout:
            return 3;
            break;
            
        case SettingSectionDetail:
            return 1;
            break;
            
        case SettingSectionAbout:
            return 2;
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RecyleIdentity = @"RecyleIdentity";
    NSInteger row     = [indexPath row];
    NSInteger section = [indexPath section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecyleIdentity];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:@"NewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (SettingSectionSlideShow == section || SettingSectionAbout == section) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    switch (section) {
            
        case SettingSectionCache:
            if (0 == row) {
                cell.textLabel.text = NSLocalizedString(@"clear_cache", @"Clear Cache");
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
                [view addSubview:self.clearIndicatorView];
                self.clearIndicatorView.center = view.center;
                cell.accessoryView  = view;
                self.sizeLabel      = cell.detailTextLabel;
                NSString *cacheSize = NSLocalizedString(@"current_cache", @"Cache Size : %.2fMB");
                self.sizeLabel.text = [NSString stringWithFormat:cacheSize,self.currentCacheSize];
            }
            break;
            
        case SettingSectionSlideShow:
            if (0 == row) {
                cell.textLabel.text = NSLocalizedString(@"slideshow_setting", @"SlideShow Setting");
            }
            break;
            
        case SettingSectionLayout:
        {
            NSNumber *layoutIndex = [[NSUserDefaults standardUserDefaults] objectForKey:kCustom_Layout_Key];
            int savedRow = [layoutIndex intValue];
            cell.accessoryType = (row == savedRow && nil != layoutIndex) ?
            UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            if (layoutIndex) {
                self.lastIndex = [NSIndexPath indexPathForItem:savedRow inSection:2];
            }
            
            if (0 == row) {
                cell.textLabel.text = NSLocalizedString(@"water_flow", @"Water Flow");
                
                if (nil == layoutIndex) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    
                    // Save the default layout to userdefault.
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:row]
                                                              forKey:kCustom_Layout_Key];
                    self.lastIndex = indexPath;
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Layout
                                                                        object:[NSNumber numberWithInt:row]];
                }
            }
            if (1 == row) {
                cell.textLabel.text = NSLocalizedString(@"grid_layout", @"Grid");
            }
            if (2 == row) {
                cell.textLabel.text = NSLocalizedString(@"linear_layout", @"LinearLayout");
            }
        }
            break;
            
        case SettingSectionDetail:
            if (0 == row) {
                cell.textLabel.text = NSLocalizedString(@"show_detail", @"Show Detail Info");
                UISwitch *showDetailSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
                showDetailSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kImage_Cell_Show_Detail];
                [showDetailSwitch addTarget:self action:@selector(detailStateSwitchControlChanged:) forControlEvents:UIControlEventValueChanged];
                
                cell.accessoryView = showDetailSwitch;
            }
            break;
            
        case SettingSectionAbout:
            if (0 == row) {
                cell.textLabel.text = NSLocalizedString(@"about_us", @"About");
            }
            if (1 == row) {
                cell.textLabel.text = NSLocalizedString(@"advice", @"Advice");
            }
            break;
            
        default:
            break;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
            
        case SettingSectionCache:
            return NSLocalizedString(@"cache", @"Cache");
            break;
            
        case SettingSectionSlideShow:
            return NSLocalizedString(@"slideshow", @"SlideShow");
            break;
            
        case SettingSectionLayout:
            return NSLocalizedString(@"layout", @"Layout");
            break;
            
        case SettingSectionDetail:
            return NSLocalizedString(@"detail", @"Detail");
            break;
            
        case SettingSectionAbout:
            return NSLocalizedString(@"about", @"About");
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SettingSectionCache) {
        return 50;
    }
    
    return 44;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row     = [indexPath row];
    NSInteger section = [indexPath section];
    switch (section) {
        case SettingSectionCache:
            if (0 == row) {
                NSString *title   = NSLocalizedString(@"clear_dialog_title", @"Clear Warring");
                NSString *content = NSLocalizedString(@"sure_to_clear", "Are sure to clear the cache?");
                
                UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:title
                                                                 message:content
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                                       otherButtonTitles:NSLocalizedString(@"ok", @"Ok"), nil];
                [alert show];
            }
            break;
            
        case SettingSectionSlideShow:
        {
            SlideShowSettingViewController *slide = [[SlideShowSettingViewController alloc] init];
            slide.title = NSLocalizedString(@"slideshow_setting", @"SlideShow Setting");
            [self.navigationController pushViewController:slide animated:YES];
        }
            break;
            
        case SettingSectionLayout:
        {
            NSNumber *old = [[NSUserDefaults standardUserDefaults] objectForKey:kCustom_Layout_Key];
            int oldRow = [old intValue];
            if (row != oldRow) {
                
                UITableViewCell *newCell   = [tableView cellForRowAtIndexPath:indexPath];
                newCell.accessoryType      = UITableViewCellAccessoryCheckmark;
                UITableViewCell *oldCell   = [tableView cellForRowAtIndexPath:self.lastIndex];
                oldCell.accessoryType      = UITableViewCellAccessoryNone;
                self.lastIndex = indexPath;
                
                // Save the user select to userdefault.
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:row]
                                                          forKey:kCustom_Layout_Key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Notify other ViewController to relayout UI.
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Layout
                                                                    object:[NSNumber numberWithInt:row]];
            }
        }
            break;
            
        case SettingSectionDetail:
            
            break;
            
        case SettingSectionAbout:
            if (0 == row) {
                [self.navigationController pushViewController:self.aboutViewController animated:YES];
            }
            if (1 == row) {
                [self sendAdviceEmail];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - UIAlertViewDelegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex) {
        NSIndexPath *clearCacheIndex = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.tableView cellForRowAtIndexPath:clearCacheIndex].userInteractionEnabled = NO;
        [self clearCache];
    }
}

@end
