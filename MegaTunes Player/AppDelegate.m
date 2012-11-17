//
//  AppDelegate.m
//  MegaTunes Player
//
//  Created by Lori Hill on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ColorSwitcher.h"
#import "MediaGroupViewController.h"
#import "CustomNavigationBar.h"



@implementation AppDelegate


@synthesize window = _window;
@synthesize colorSwitcher;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;

static const NSUInteger kNavigationBarHeight = 60;


//+ (AppDelegate *)instance {
//    return [[UIApplication sharedApplication] delegate];
//}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ != nil)
    {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel_ != nil)
    {
        return managedObjectModel_;
    }
    //    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"CroatiaFest" ofType:@"momd"];
    //    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MegaTunes Player" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator_ != nil)
    {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MegaTunes Player.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        UIAlertView* alertView =
        [[UIAlertView alloc] initWithTitle:@"Data Management Error with Persistent Store Coordinator"
                                   message:@"Press the Home button to quit this application."
                                  delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles: nil];
        [alertView show];
        
    }
    
    return persistentStoreCoordinator_;
}
#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
    //Customize the look of the UINavBar for iOS5 devices

}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    
    MediaGroupViewController *mediaGroupViewController = (MediaGroupViewController *)navigationController.topViewController;
    mediaGroupViewController.managedObjectContext = self.managedObjectContext;


//    UINavigationController *newNavigationController = [self customizeNavigationController: navigationController];
//
//    MediaGroupViewController *mediaGroupViewController = (MediaGroupViewController *)newNavigationController.topViewController;
//    mediaGroupViewController.managedObjectContext = self.managedObjectContext;
    
//    [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                [UIFont systemFontOfSize:22], UITextAttributeFont,
//                                                   [UIColor yellowColor], UITextAttributeTextColor,
//                                                   [UIColor grayColor], UITextAttributeTextShadowColor,
//                                                   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
//                                                   nil]];
    
//    [navigationController.navigationBar setTitleVerticalPositionAdjustment: 0 forBarMetrics: UIBarMetricsDefault];
    [navigationController.navigationBar setTitleVerticalPositionAdjustment: 4 forBarMetrics: UIBarMetricsLandscapePhone];
    
    
//    [[UIBarButtonItem appearance] setBackButtonBackgroundVerticalPositionAdjustment: 7.0f
//                                                                      forBarMetrics:UIBarMetricsLandscapePhone];
//    const CGFloat TextOffset = 0.0f;
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(TextOffset, 0)
//     forBarMetrics:UIBarMetricsDefault];
//
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(TextOffset, 0)
//     forBarMetrics:UIBarMetricsLandscapePhone];

    
    self.colorSwitcher = [[ColorSwitcher alloc] initWithScheme:@"maroon"];
    //    self.colorSwitcher = [[ColorSwitcher alloc] initWithScheme:@"black"];
    
    [self customizeGlobalTheme];
    
//    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
//
//    if (idiom == UIUserInterfaceIdiomPad) {
//        [self iPadInit];
//    }


    return YES;
}

//- (UINavigationController *)customizeNavigationController: navController
//{
////    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
//    
//    // Ensure the UINavigationBar is created so that it can be archived. If we do not access the
//    // navigation bar then it will not be allocated, and thus, it will not be archived by the
//    // NSKeyedArchvier.
//    [navController navigationBar];
//    
//    // Archive the navigation controller.
//    NSMutableData *data = [NSMutableData data];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:navController forKey:@"root"];
//    [archiver finishEncoding];
//    
//    // Unarchive the navigation controller and ensure that our UINavigationBar subclass is used.
//    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    [unarchiver setClass:[CustomNavigationBar class] forClassName:@"UINavigationBar"];
//    UINavigationController *customizedNavController = [unarchiver decodeObjectForKey:@"root"];
//    [unarchiver finishDecoding];
//    
//    // Modify the navigation bar to have a background image.
//    CustomNavigationBar *navBar = (CustomNavigationBar *)[customizedNavController navigationBar];
//    
//    CGRect frame = navBar.frame;
//    frame.size.height = kNavigationBarHeight;
//    navBar.frame = frame;
//    
//    [navBar setBackgroundImage:[UIImage imageNamed:@"megaMenu-bar.png"] forBarMetrics:UIBarMetricsDefault];
//    [navBar setBackgroundImage:[UIImage imageNamed:@"megaMenu-bar-landscape.png"] forBarMetrics:
//     UIBarMetricsLandscapePhone];
//    [navBar setTitleVerticalPositionAdjustment: 5 forBarMetrics: UIBarMetricsDefault];
//    [navBar setTitleVerticalPositionAdjustment: 10 forBarMetrics: UIBarMetricsLandscapePhone];
//    
//    
//    //    //this does not fit in the titleview "space"
//    [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                [UIFont systemFontOfSize:44], UITextAttributeFont,
//                                                   [UIColor yellowColor], UITextAttributeTextColor,
//                                                   [UIColor grayColor], UITextAttributeTextShadowColor,
//                                                   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
//                                                   nil]];
//
////    self.colorSwitcher = [[ColorSwitcher alloc] initWithScheme:@"maroon"];
//    
//    return customizedNavController;
//}
- (void)customizeGlobalTheme {
    
    UIImage *navBarDefaultImage = [colorSwitcher processImageWithName:@"megaMenu-bar.png"];
    [[UINavigationBar appearance] setBackgroundImage:navBarDefaultImage forBarMetrics:UIBarMetricsDefault];
    
//    UIImage *navBarLandscapeImage = [colorSwitcher processImageWithName:@"megaMenu-bar-landscape.png"];
    UIImage *navBarLandscapeImage = [colorSwitcher processImageWithName:@"megaMenu-bar@2x.png"];
    [[UINavigationBar appearance] setBackgroundImage:navBarLandscapeImage forBarMetrics:UIBarMetricsLandscapePhone];
    
//    UIImage* barButtonImage = [UIImage tallImageNamed:@"menubar-button.png"];
//    
//    [[UIBarButtonItem appearance] setBackgroundImage:barButtonImage forState:UIControlStateNormal
//                                          barMetrics:UIBarMetricsDefault];
//    
//    UIImage* barButtonLandscapeImage = [UIImage tallImageNamed:@"menubar-button@2x.png"];
//    
//    [[UIBarButtonItem appearance] setBackgroundImage:barButtonLandscapeImage forState:UIControlStateNormal
//                                          barMetrics:UIBarMetricsLandscapePhone];
//    
////    UIImage *backButton = [UIImage tallImageNamed:@"back.png"];
//    UIImage *backButton = [UIImage tallImageNamed:@"arrow_left_48.png"];
//
//
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
//                                                    barMetrics:UIBarMetricsDefault];
//    
////    UIImage *backButtonLandscape = [UIImage tallImageNamed:@"back.png"];
//    UIImage *backButtonLandscape = [UIImage tallImageNamed:@"arrow_left_48.png"];
//    
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonLandscape forState:UIControlStateNormal
//                                                    barMetrics:UIBarMetricsLandscapePhone];

    
//    UIImage* tabBarBackground = [colorSwitcher processImageWithName:@"tabbar.png"];
//    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
//    
//    
//    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage tallImageNamed:@"selection-tab.png"]];
    
    UIImage *minImage = [UIImage tallImageNamed:@"slider-fill.png"];
    UIImage *maxImage = [UIImage tallImageNamed:@"slider-trackGray.png"];
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
// Returns whether or not to use the iPod music player instead of the application music player.
- (BOOL) useiPodPlayer {
    //      LogMethod();
	if ([[NSUserDefaults standardUserDefaults] boolForKey: PLAYER_TYPE_PREF_KEY]) {
		return YES;
	} else {
		return NO;
	}
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
