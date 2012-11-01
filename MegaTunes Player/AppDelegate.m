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



@implementation AppDelegate


@synthesize window = _window;
@synthesize colorSwitcher;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;

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
        [[UIAlertView alloc] initWithTitle:@"Pazi!! Data Management Error with Persistent Store Coordinator"
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
    MediaGroupViewController *controller = (MediaGroupViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
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
