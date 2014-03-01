//
//  AppDelegate.m
//  Cooliris
//
//  Created by user on 13-5-20.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "AppDelegate.h"
#import "UncaughtExceptionHandler.h"
#import "ControlPanelViewController.h"
#import "ImageGridViewController.h"
#import "MMDrawerController.h"
#import "UIBarButtonItem+Flat.h"
#import "RootPageViewController.h"
#import "ResourceManager.h"
#import "PageInfoManager.h"

@implementation AppDelegate

@synthesize rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Install uncaught exception handler
    InstallUncaughtExceptionHandler();
    // Initialize data source
    [[ResourceManager sharedInstance] copyDatabaseFile];
    //[[PageInfoManager sharedInstance] loadPageGroups];
    [[PageInfoManager sharedInstance] loadPageInfoGroups];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    // Load root view controller from resource and set it into window's root view controller
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        [[NSBundle mainBundle] loadNibNamed:@"RootViewController_iPhone" owner:self options:nil];
//    } else {
//        [[NSBundle mainBundle] loadNibNamed:@"RootViewController_iPad" owner:self options:nil];
//    }
//    [self.window addSubview:rootViewController.view];
//    self.window.rootViewController = rootViewController;
    
    UIViewController *leftViewController = [[ControlPanelViewController alloc] init];
    //UIViewController *centerViewController = [[ImageGridViewController alloc] init];
    UIViewController *centerViewController = [[RootPageViewController alloc] init];
    
    ((ControlPanelViewController *)leftViewController).delegate = (RootPageViewController *)centerViewController;
    ((RootPageViewController *)centerViewController).delegate = (ControlPanelViewController *)leftViewController;

    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];

    MMDrawerController *drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:navigationController//centerViewController
                                            leftDrawerViewController:leftViewController];
    drawerController.maximumLeftDrawerWidth = 260.0;
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    drawerController.shouldStretchDrawer = NO;
    drawerController.showsShadow = YES;
    
//    [drawerController
//     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
//         MMDrawerControllerDrawerVisualStateBlock block;
//         block = [[MMExampleDrawerVisualStateManager sharedManager]
//                  drawerVisualStateBlockForDrawerSide:drawerSide];
//         if(block){
//             block(drawerController, drawerSide, percentVisible);
//         }
//     }];
    
    //[self.window addSubview:rootViewController.view];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = drawerController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Set the NavagationBar & TabBar & SearchBar's background image
    // NOTE: This only work's for iOS 5.0+
    UIImage *backgroundImage = [UIImage imageNamed:@"Icon_navigationbar_background"];
    [[UINavigationBar appearance] setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    ((UITabBar *)[UITabBar appearance]).backgroundImage = backgroundImage;
    ((UISearchBar *)[UISearchBar appearance]).backgroundImage = backgroundImage;
    
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor colorWithWhite:1 alpha:0.1]
                                  highlightedColor:[UIColor colorWithWhite:0 alpha:0.2]
                                      cornerRadius:5
                                   whenContainedIn:[UINavigationBar class], nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
