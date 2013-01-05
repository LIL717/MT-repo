//
//  AppDelegate.m
//  podradio
//
//  Created by Tope on 28/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "ColorSwitcher.h"

@implementation AppDelegate

@synthesize window = _window;

@synthesize colorSwitcher;

+ (AppDelegate *)instance {
   return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //self.colorSwitcher = [[ColorSwitcher alloc] initWithScheme:@"maroon"];
    self.colorSwitcher = [[ColorSwitcher alloc] initWithScheme:@"black"];
    
    [self customizeGlobalTheme];
    
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    
    if (idiom == UIUserInterfaceIdiomPad) {
        [self iPadInit];
    }

    return YES;
}


- (void)customizeGlobalTheme {
    UIImage *navBarImage = [colorSwitcher processImageWithName:@"menu-bar.png"];
    
    [[UINavigationBar appearance] setBackgroundImage:navBarImage 
                                       forBarMetrics:UIBarMetricsDefault];
    
    
    UIImage* barbuttonImage = [UIImage tallImageNamed:@"menubar-button.png"];
    UIImage *barButton = [barbuttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [[UIBarButtonItem appearance] setBackgroundImage:barButton forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsDefault];
    
    UIImage *backButton = [[UIImage tallImageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 5)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    UIImage* tabBarBackground = [colorSwitcher processImageWithName:@"tabbar.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    
    
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage tallImageNamed:@"selection-tab.png"]];
    
    UIImage *minImage = [UIImage tallImageNamed:@"slider-fill.png"];
    UIImage *maxImage = [UIImage tallImageNamed:@"slider-track.png"];
    UIImage *thumbImage = [UIImage tallImageNamed:@"slider-handle.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage 
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:[minImage stretchableImageWithLeftCapWidth:4 topCapHeight:0]
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage 
                                forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage 
                                forState:UIControlStateHighlighted];    
}


-(void)iPadInit {
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController; 
    
    UINavigationController *detailNav = [splitViewController.viewControllers lastObject];
    id<MasterViewControllerDelegate> masterDelegate = [detailNav.viewControllers objectAtIndex:0];
    id<UISplitViewControllerDelegate> splitDelegate = [detailNav.viewControllers objectAtIndex:0];
    
    UINavigationController *masterNav = [splitViewController.viewControllers objectAtIndex:0];
    MasterViewController* master = [masterNav.viewControllers objectAtIndex:0];
    
    master.delegate = masterDelegate;
    splitViewController.delegate = splitDelegate;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
