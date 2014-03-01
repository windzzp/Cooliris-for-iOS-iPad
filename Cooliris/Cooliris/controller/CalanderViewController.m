//
//  CalanderViewController.m
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "CalanderViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface CalanderViewController ()

{
    NoteDBOperator *DBOperator;
    NSString *oldContent;
    NSString *newContent;
}
@property (strong,nonatomic) VRGCalendarView *calendar;
@property (strong,nonatomic) IBOutlet UIButton *addNoteBtn;
@property (strong,nonatomic) UIViewController *editController;
@property (strong,nonatomic) NSDate *selTime;
@property (strong,nonatomic) UILabel *selectTimeLabel;
@property (strong,nonatomic) UIActivityIndicatorView *saveIndicatorView;
@property (strong,nonatomic) UITextView *editContent;

- (IBAction)addNote:(id)sender;

@end

@implementation CalanderViewController

#pragma mark Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark  LifeCycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.calendar = [[VRGCalendarView alloc] init];
    self.calendar.delegate = self;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.title = @"Calander";
    [self.view addSubview:self.calendar];
    self.addNoteBtn.enabled = NO;
    self.addNoteBtn.alpha   = 0.3;
    
    [self initializeEditController];
    
    [self initializeDB];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(detectOrientation)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.selectTimeLabel.center = CGPointMake(self.editController.view.center.x, 30);
    self.editContent.center = CGPointMake(self.editController.view.center.x, 75 + self.editContent.frame.size.height / 2);
}

- (void)viewWillAppear:(BOOL)animated
{
    oldContent = nil;
    newContent = nil;
    self.editContent.text = nil;
    self.calendar.center =  CGPointMake(self.view.center.x, self.calendar.center.y);
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    else
        [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark System Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft | toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    else
        [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark Private Methods

- (void)dimissKeyBoard:(UITapGestureRecognizer *)tap
{
    [self.editContent resignFirstResponder];
}

- (void)initializeEditController
{
    //config edit controller.
    self.editController =[[UIViewController alloc]init];
    CGFloat width  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat hght = [[UIScreen mainScreen] bounds].size.height;
    self.editController.view.frame = CGRectMake(0, 44, width, hght - 44 - 20);
    self.editController.title = @"Add Note";
    self.editController.view.backgroundColor = [UIColor lightGrayColor];
    NSString *imgPath = [NSString stringWithFormat:@"%@/%@.png", [[NSBundle mainBundle] resourcePath], @"wall"];
    UIImage *img      = [[UIImage alloc] initWithContentsOfFile:imgPath];
    self.editController.view.layer.contents = (id)img.CGImage;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dimissKeyBoard:)];
    [self.editController.view addGestureRecognizer:tap];

    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(save)];
    self.editController.navigationItem.rightBarButtonItem = saveItem;
    //add a UIlabel to show the select time,which view add a note.
    CGPoint p                                = self.editController.view.center;
    self.selectTimeLabel                     = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
    self.selectTimeLabel.center              = CGPointMake(p.x, 30);
    self.selectTimeLabel.textColor           = [UIColor grayColor];
    self.selectTimeLabel.textAlignment       = NSTextAlignmentCenter;
    self.selectTimeLabel.layer.masksToBounds = NO;
    self.selectTimeLabel.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.selectTimeLabel.layer.shadowOffset  = CGSizeMake(1, 2);
    self.selectTimeLabel.layer.shadowRadius  = 5.0;
    self.selectTimeLabel.layer.shadowOpacity = 0.9f;
    self.selectTimeLabel.layer.cornerRadius  = 10.0;
    self.selectTimeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:21];
    NSString *imgPath1 = [NSString stringWithFormat:@"%@/%@.png", [[NSBundle mainBundle] resourcePath], @"title"];
    UIImage *img1 = [[UIImage alloc] initWithContentsOfFile:imgPath1];
    self.selectTimeLabel.layer.contents =(id)img1.CGImage;
    [self.editController.view addSubview:self.selectTimeLabel];
    
    //add a activityIndicatorView to the editController.
    self.saveIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.saveIndicatorView.center = p;
    self.saveIndicatorView.color  = [UIColor brownColor];
//    [editController.view addSubview:saveIndicatorView];

    //add a textView to editController.
    int height = 280;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        height = 500;
    }
    self.editContent = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 120.0, self.view.bounds.size.width - 20, height)];
    self.editContent.center    = CGPointMake(p.x, 75 + height / 2);
    self.editContent.textColor = [UIColor blackColor];
    self.editContent.font = self.selectTimeLabel.font;
    self.editContent.font = [UIFont fontWithName:@"Helvetica-LightOblique" size:19];
    self.editContent.layer.masksToBounds = NO;
    self.editContent.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.editContent.layer.shadowOffset  = CGSizeMake(1, 2);
    self.editContent.layer.shadowRadius  = 5.0;
    self.editContent.layer.shadowOpacity = 0.9f;
    self.editContent.layer.cornerRadius  = 5.0;
    NSString *imgPath2 = [NSString stringWithFormat:@"%@/%@.png",[[NSBundle mainBundle] resourcePath],@"edit"];
    UIImage *img2 = [[UIImage alloc] initWithContentsOfFile:imgPath2];
    self.editContent.layer.contents =(id)img2.CGImage;
    [self.editController.view addSubview:self.editContent];
    
    self.selTime = nil;
    oldContent   = nil;
    newContent   = nil;
}


- (void)initializeDB
{
    if (nil == DBOperator) {
        DBOperator = [[NoteDBOperator alloc] initWithName:@"NoteDB" nDBVersion:1];
    }
}

- (IBAction)addNote:(id)sender
{
    NSLog(@"add note ....");
    if (self.editController) {
        if ([self.navigationController isNavigationBarHidden])
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController pushViewController:self.editController animated:YES];
        if (self.selTime) {
            NSDateFormatter * format  = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd"];
            self.selectTimeLabel.text = [format stringFromDate:self.selTime];
            NSMutableDictionary *tmpNote = [DBOperator getNoteWithTime:(long)[self.selTime timeIntervalSince1970]];
            if (tmpNote) {
                oldContent= [tmpNote objectForKey:NoteOpenHelper_Note_TableColumns_Content];
                if (nil != oldContent && ![oldContent isEqualToString:@""]) {
                    self.editContent.text = oldContent;
                }
            }
        }
    }
}

- (void)save
{
    if (self.saveIndicatorView) {
        [self.editContent insertSubview:self.saveIndicatorView atIndex:0];
        [self.editContent resignFirstResponder];
        newContent = self.editContent.text;
        NSLog(@"Saving note ...");
        if (nil != newContent && ![newContent isEqualToString:@""] && ![newContent isEqualToString:oldContent]) {
            [self.saveIndicatorView startAnimating];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (1 == [DBOperator insertNoteWithTime:(long)[self.selTime timeIntervalSince1970]
                                                   with:1 with:newContent]) {
                    NSLog(@"insert to db success");
                }
                [NSThread sleepForTimeInterval:0.5];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.saveIndicatorView performSelectorOnMainThread:@selector(stopAnimating)
                                                             withObject:nil waitUntilDone:NO];
                });
            });
        }
    }
}

- (void)detectOrientation
{
    UIDevice *device            = [UIDevice currentDevice];
    self.selectTimeLabel.center = CGPointMake(self.editController.view.center.x, 30);
    self.editContent.center     = CGPointMake(self.editController.view.center.x, 75 + self.editContent.frame.size.height / 2);
    self.calendar.center        = CGPointMake(self.view.center.x, self.calendar.center.y);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        switch (device.orientation) {
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                [self.calendar resetSizeWidth:44 withHeight:30];
                break;
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationPortraitUpsideDown:
                [self.calendar resetSizeWidth:44 withHeight:35];
                break;
                
            default:
                break;
        }
        [self.calendar updateSize];
    }
}

#pragma mark CalendarView Delegate Methods

- (void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date
{
    NSLog(@"You select date: %@", date);
    self.selTime                        = date;
    self.addNoteBtn.enabled             = YES;
    self.addNoteBtn.alpha               = 1.0;
    self.addNoteBtn.layer.masksToBounds = NO;
    self.addNoteBtn.layer.shadowColor   = [UIColor grayColor].CGColor;
    self.addNoteBtn.layer.shadowOffset  = CGSizeMake(1, 3);
    self.addNoteBtn.layer.shadowRadius  = 5.0;
    self.addNoteBtn.layer.shadowOpacity = 0.9f;
}

- (void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month
        targetHeight:(float)targetHeight
            animated:(BOOL)animated
{
    
}

@end
