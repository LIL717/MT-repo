	//
	//  AppDelegate.m
	//  MegaTunes Player
	//
	//  Created by Lori Hill on 2/24/12.
	//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
	//

#import "AppDelegate.h"
	//#import "ColorSwitcher.h"
#import "MediaGroupViewController.h"
#import "MainViewcontroller.h"
	//#import "CustomNavigationBar.h"
#import "TagData.h"
#import "TagItem.h"
#import "MediaItemUserData.h"
#import "UserDataForMediaItem.h"
#import "Reachability.h"
	//#import "TestFlight.h"



@implementation AppDelegate


@synthesize window = _window;
	//@synthesize navigationController;

	//@synthesize colorSwitcher;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;




static const NSUInteger kNavigationBarHeight = 60;
	// Add new private instance variable


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


#pragma mark TODO before submit to Apple Store

		//*** beginning of TestFlight code
		// comment out #define TESTING 1 before production!!!!
#define TESTING 1
		//#ifdef TESTING
		//    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
		//#endif
		//    [TestFlight takeOff:@"3ec22a1e-ddac-483c-8152-21c537a9fb42"];

		//*** end of TestFlight code
		//130906 1.1 add Store Button begin
	NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject: @"at=10l9mp" forKey:@"affiliateID"];
		//130906 1.1 add Store Button end

		//Load a couple defaults to userTag Core Data if there aren't any objects in TagData

	TagData *tagData = [TagData alloc];
	tagData.managedObjectContext = self.managedObjectContext;


	if ([[tagData fetchTagList] count] == 0) {

		TagItem *userTagItem = [TagItem alloc];

		userTagItem.tagName = @"warmup";

		userTagItem.tagColorRed = [NSNumber numberWithInt: 26];
		userTagItem.tagColorGreen = [NSNumber numberWithInt: 121];
		userTagItem.tagColorBlue = [NSNumber numberWithInt: 23];
		userTagItem.tagColorAlpha = [NSNumber numberWithInt: 255];
		userTagItem.sortOrder = [NSNumber numberWithInt: 0];

		[tagData addTagItemToCoreData: userTagItem];

		userTagItem.tagName = @"cooldown";

		userTagItem.tagColorRed = [NSNumber numberWithInt: 0];
		userTagItem.tagColorGreen = [NSNumber numberWithInt: 0];
		userTagItem.tagColorBlue = [NSNumber numberWithInt: 118];
		userTagItem.tagColorAlpha = [NSNumber numberWithInt: 255];
		userTagItem.sortOrder = [NSNumber numberWithInt: 1];

		[tagData addTagItemToCoreData: userTagItem];

	}
		//    NSLog (@"preload tags");
		//    [tagData listAll];

		//check if icloud is accessible

		//    [self initializeiCloudAccessWithCompletion:^(BOOL available) {
		//
		//        _iCloudAvailable = available;
		//
		//        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
		//        [standardUserDefaults setBool: _iCloudAvailable forKey:@"iCloudAvailable"];
		//
		//        BOOL iCloudAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudAvailable"];
		//        NSLog (@"iCloudAvailable BOOL from NSUserDefaults is %d", iCloudAvailable);
		//
		//
		//    }];

		// allocate a reachability object
	Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];

		// tell the reachability that we DO want to be reachable on 3G/EDGE/CDMA
	reach.reachableOnWWAN = YES;

		// set the blocks
	reach.reachableBlock = ^(Reachability*reach)
	{
	NSLog(@"REACHABLE!");
	NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setBool: YES forKey:@"networkAvailable"];
	};

	reach.unreachableBlock = ^(Reachability*reach)
	{
	NSLog(@"UNREACHABLE!");
	NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setBool: NO forKey:@"networkAvailable"];

	};

		// start the notifier which will cause the reachability object to retain itself!
	[reach startNotifier];

	BOOL networkAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"networkAvailable"];
	NSLog (@"networkAvailable BOOL from NSUserDefaults is %d", networkAvailable);

		//prevent app from timing out due to idelness
	[UIApplication sharedApplication].idleTimerDisabled = YES;


		//    [self.window setRootViewController:navigationController];

		//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		//    // Override point for customization after application launch.
		//
		////    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
		//    MediaGroupViewController *mediaGroupViewController = [[MediaGroupViewController alloc] initWithCoder:self];
		////    controller.managedObjectContext = self.managedObjectContext;
		////    return YES;
		//
		//    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mediaGroupViewController];
		//    self.window.rootViewController = navigationController;
		//    [self.window makeKeyAndVisible];
		//
		////    [self.window setRootViewController:navigationController];
		//
		//    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
		//
		//    MediaGroupViewController *mediaGroupViewController = (MediaGroupViewController *)self.window.rootViewController;
		//    mediaGroupViewController.managedObjectContext = self.managedObjectContext;

		//    [navigationController.navigationBar setTitleVerticalPositionAdjustment: 4 forBarMetrics: UIBarMetricsLandscapePhone];


		//    self.colorSwitcher = [[ColorSwitcher alloc] initWithScheme:@"maroon"];
		//    self.colorSwitcher = [[ColorSwitcher alloc] initWithScheme:@"black"];

	[self customizeGlobalTheme];

		//    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
		//
		//    if (idiom == UIUserInterfaceIdiomPad) {
		//        [self iPadInit];
		//    }


	return YES;
}
	// // Add to end of "Helpers" section
	// - (void)initializeiCloudAccessWithCompletion:(void (^)(BOOL available)) completion {
	//     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	//         _iCloudRoot = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
	//         if (_iCloudRoot != nil) {
	//             dispatch_async(dispatch_get_main_queue(), ^{
	//                 NSLog(@"iCloud available at: %@", _iCloudRoot);
	//                 completion(TRUE);
	//             });
	//         }
	//         else {
	//             dispatch_async(dispatch_get_main_queue(), ^{
	//                 NSLog(@"iCloud not available");
	//                 completion(FALSE);
	//             });
	//         }
	//
	//     });
	//
	//
	// }

- (void)customizeGlobalTheme {


		//    //    UIImage *navBarDefaultImage = [colorSwitcher processImageWithName:@"megaMenu-bar.png"];
		//    UIImage *navBarDefaultImage = [UIImage imageNamed:@"navBarBackground.png"];

		//    [[UINavigationBar appearance] setBackgroundImage:navBarDefaultImage forBarMetrics:UIBarMetricsDefault];
	[[UINavigationBar appearance] setTitleVerticalPositionAdjustment: -5 forBarMetrics: UIBarMetricsDefault];

		//
		//    //    UIImage *navBarLandscapeImage = [colorSwitcher processImageWithName:@"megaMenu-bar-landscape.png"];
		//    UIImage *navBarLandscapeImage = [UIImage imageNamed:@"megaMenu-bar-landscape.png"];
		//
		//    [[UINavigationBar appearance] setBackgroundImage:navBarLandscapeImage forBarMetrics:UIBarMetricsLandscapePhone];

	[[UINavigationBar appearance] setTitleVerticalPositionAdjustment: -3 forBarMetrics: UIBarMetricsLandscapePhone];


		//    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
		//    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
		//    //    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		//    //    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
		//
		//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage: menuBarImage48  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage: menuBarImage48  forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
		//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage: menuBarImage58  forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
		//        [[UIBarButtonItem appearance] setBackButtonBackgroundImage: menuBarImage58  forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
		//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(menuBarImage48.size.width*2, menuBarImage48.size.height*2) forBarMetrics:UIBarMetricsDefault];
		//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, menuBarImage58.size.height*2) forBarMetrics:UIBarMetricsLandscapePhone];


		//    UIImage* tabBarBackground = [colorSwitcher processImageWithName:@"tabbar.png"];
		//    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar.png"];

		//need to set the title because accessibility uses the title, set text to clear so it doesn't display
	[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
													   [UIColor clearColor], NSForegroundColorAttributeName,
													   nil] forState:UIControlStateNormal];

		//    [[UITabBar appearance] setBackgroundImage:tabBarBackground];

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
	//// Returns whether or not to use the iPod music player instead of the application music player.
	//- (BOOL) useiPodPlayer {
	//    //      LogMethod();
	//	if ([[NSUserDefaults standardUserDefaults] boolForKey: PLAYER_TYPE_PREF_KEY]) {
	//		return YES;
	//	} else {
	//		return NO;
	//	}
	//}
	// Returns whether to show the playlist remaining time in the player
	//- (BOOL) showPlaylistRemaining {
	//    //      LogMethod();
	//	if ([[NSUserDefaults standardUserDefaults] boolForKey: SHOW_PLAYLIST_REMAINING_KEY]) {
	//		return YES;
	//	} else {
	//		return NO;
	//	}
	//}
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

////
////  AppDelegate.m
////  MegaTunes Player
////
////  Created by Lori Hill on 2/24/12.
////  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
////
//
//#import "AppDelegate.h"
//#import "MediaGroupViewController.h"
//#import "MainViewcontroller.h"
//#import "TagData.h"
//#import "TagItem.h"
//#import "MediaItemUserData.h"
//#import "UserDataForMediaItem.h"
//#import "Reachability.h"
////#import "TestFlight.h"
//
//
//
//@implementation AppDelegate
//
//
//@synthesize window = _window;
////@synthesize navigationController;
//
//@synthesize managedObjectModel = managedObjectModel_;
//@synthesize managedObjectContext = managedObjectContext_;
//@synthesize fetchedResultsController = fetchedResultsController_;
//@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;
//
//
//
//
//// Add new private instance variable
//
//
////+ (AppDelegate *)instance {
////    return [[UIApplication sharedApplication] delegate];
////}
//
//#pragma mark - Core Data stack
//
///**
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
// */
//- (NSManagedObjectContext *)managedObjectContext
//{
//    if (managedObjectContext_ != nil)
//    {
//        return managedObjectContext_;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil)
//    {
//        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
//        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
//    }
//    return managedObjectContext_;
//}
//
///**
// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
// */
//- (NSManagedObjectModel *)managedObjectModel
//{
//    if (managedObjectModel_ != nil)
//    {
//        return managedObjectModel_;
//    }
//    //    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"CroatiaFest" ofType:@"momd"];
//    //    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
//    
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MegaTunes Player" withExtension:@"momd"];
//    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return managedObjectModel_;
//}
//
///**
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
// */
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    if (persistentStoreCoordinator_ != nil)
//    {
//        return persistentStoreCoordinator_;
//    }
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MegaTunes Player.sqlite"];
//    
//    NSError *error = nil;
//    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
//    {
//        UIAlertView* alertView =
//        [[UIAlertView alloc] initWithTitle:@"Data Management Error with Persistent Store Coordinator"
//                                   message:@"Press the Home button to quit this application."
//                                  delegate:self
//                         cancelButtonTitle:@"OK"
//                         otherButtonTitles: nil];
//        [alertView show];
//        
//    }
//    
//    return persistentStoreCoordinator_;
//}
//#pragma mark - Application's Documents directory
//
///**
// Returns the URL to the application's Documents directory.
// */
//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}
//
//- (void)applicationWillResignActive:(UIApplication *)application
//{
//    /*
//     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//     */
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    /*
//     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//     */
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application
//{
//    /*
//     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//     */
//    //Customize the look of the UINavBar for iOS5 devices
//    
//}
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    
//    
//#pragma mark TODO before submit to Apple Store
//    
//    //*** beginning of TestFlight code
//    // comment out #define TESTING 1 before production!!!!
////#define TESTING 1
////#ifdef TESTING
////    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
////#endif
////    [TestFlight takeOff:@"3ec22a1e-ddac-483c-8152-21c537a9fb42"];
//
//    //*** end of TestFlight code
////130906 1.1 add Store Button begin
//    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    [standardUserDefaults setObject: @"at=10l9mp" forKey:@"affiliateID"];
////130906 1.1 add Store Button end
//
//    //Load a couple defaults to userTag Core Data if there aren't any objects in TagData
//    
//    TagData *tagData = [TagData alloc];
//    tagData.managedObjectContext = self.managedObjectContext;
//    
//    
//    if ([[tagData fetchTagList] count] == 0) {
//        
//        TagItem *userTagItem = [TagItem alloc];
//        
//        userTagItem.tagName = @"warmup";
//        
//        userTagItem.tagColorRed = [NSNumber numberWithInt: 26];
//        userTagItem.tagColorGreen = [NSNumber numberWithInt: 121];
//        userTagItem.tagColorBlue = [NSNumber numberWithInt: 23];
//        userTagItem.tagColorAlpha = [NSNumber numberWithInt: 255];
//        userTagItem.sortOrder = [NSNumber numberWithInt: 0];
//        
//        [tagData addTagItemToCoreData: userTagItem];
//        
//        userTagItem.tagName = @"cooldown";
//        
//        userTagItem.tagColorRed = [NSNumber numberWithInt: 0];
//        userTagItem.tagColorGreen = [NSNumber numberWithInt: 0];
//        userTagItem.tagColorBlue = [NSNumber numberWithInt: 118];
//        userTagItem.tagColorAlpha = [NSNumber numberWithInt: 255];
//        userTagItem.sortOrder = [NSNumber numberWithInt: 1];
//        
//        [tagData addTagItemToCoreData: userTagItem];
//        
//    }
//    //    NSLog (@"preload tags");
//    //    [tagData listAll];
//    
//    //check if icloud is accessible
//    
//    //    [self initializeiCloudAccessWithCompletion:^(BOOL available) {
//    //
//    //        _iCloudAvailable = available;
//    //
//    //        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    //        [standardUserDefaults setBool: _iCloudAvailable forKey:@"iCloudAvailable"];
//    //
//    //        BOOL iCloudAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudAvailable"];
//    //        NSLog (@"iCloudAvailable BOOL from NSUserDefaults is %d", iCloudAvailable);
//    //
//    //
//    //    }];
//    
//    // allocate a reachability object
//    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
//    
//    // tell the reachability that we DO want to be reachable on 3G/EDGE/CDMA
//    reach.reachableOnWWAN = YES;
//    
//    // set the blocks
//    reach.reachableBlock = ^(Reachability*reach)
//    {
//        NSLog(@"REACHABLE!");
//        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
//        [standardUserDefaults setBool: YES forKey:@"networkAvailable"];
//    };
//    
//    reach.unreachableBlock = ^(Reachability*reach)
//    {
//        NSLog(@"UNREACHABLE!");
//        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
//        [standardUserDefaults setBool: NO forKey:@"networkAvailable"];
//        
//    };
//    
//    // start the notifier which will cause the reachability object to retain itself!
//    [reach startNotifier];
//    
//    BOOL networkAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"networkAvailable"];
//    NSLog (@"networkAvailable BOOL from NSUserDefaults is %d", networkAvailable);
//    
//    //prevent app from timing out due to idelness
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
//
//    
//    //    [self.window setRootViewController:navigationController];
//    
//    //    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    //    // Override point for customization after application launch.
//    //
//    ////    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//    //    MediaGroupViewController *mediaGroupViewController = [[MediaGroupViewController alloc] initWithCoder:self];
//    ////    controller.managedObjectContext = self.managedObjectContext;
//    ////    return YES;
//    //
//    //    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mediaGroupViewController];
//    //    self.window.rootViewController = navigationController;
//    //    [self.window makeKeyAndVisible];
//    //
//    ////    [self.window setRootViewController:navigationController];
//    //
//    //    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//    //
//    //    MediaGroupViewController *mediaGroupViewController = (MediaGroupViewController *)self.window.rootViewController;
//    //    mediaGroupViewController.managedObjectContext = self.managedObjectContext;
//    
//    //    [navigationController.navigationBar setTitleVerticalPositionAdjustment: 4 forBarMetrics: UIBarMetricsLandscapePhone];
//    
//    [self customizeGlobalTheme];
//    
//    //    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
//    //
//    //    if (idiom == UIUserInterfaceIdiomPad) {
//    //        [self iPadInit];
//    //    }
//    
//    
//    return YES;
//}
//// // Add to end of "Helpers" section
//// - (void)initializeiCloudAccessWithCompletion:(void (^)(BOOL available)) completion {
////     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////         _iCloudRoot = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
////         if (_iCloudRoot != nil) {
////             dispatch_async(dispatch_get_main_queue(), ^{
////                 NSLog(@"iCloud available at: %@", _iCloudRoot);
////                 completion(TRUE);
////             });
////         }
////         else {
////             dispatch_async(dispatch_get_main_queue(), ^{
////                 NSLog(@"iCloud not available");
////                 completion(FALSE);
////             });
////         }
////
////     });
////
////
//// }
//
//- (void)customizeGlobalTheme {
//    
//    
////    UIImage *navBarDefaultImage = [UIImage imageNamed:@"megaMenu-bar.png"];
////    
////    [[UINavigationBar appearance] setBackgroundImage:navBarDefaultImage forBarMetrics:UIBarMetricsDefault];
////    
////    UIImage *navBarLandscapeImage = [UIImage imageNamed:@"megaMenu-bar-landscape.png"];
////    
////    [[UINavigationBar appearance] setBackgroundImage:navBarLandscapeImage forBarMetrics:UIBarMetricsLandscapePhone];
//
//    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment: 4 forBarMetrics: UIBarMetricsLandscapePhone];
//    
//    
//    //    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    //    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    //    //    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    //    //    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
//    //
//    //    [[UIBarButtonItem appearance] setBackButtonBackgroundImage: menuBarImage48  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    //    [[UIBarButtonItem appearance] setBackButtonBackgroundImage: menuBarImage48  forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
//    //    [[UIBarButtonItem appearance] setBackButtonBackgroundImage: menuBarImage58  forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
//    //        [[UIBarButtonItem appearance] setBackButtonBackgroundImage: menuBarImage58  forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
//    //    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(menuBarImage48.size.width*2, menuBarImage48.size.height*2) forBarMetrics:UIBarMetricsDefault];
//    //    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, menuBarImage58.size.height*2) forBarMetrics:UIBarMetricsLandscapePhone];
//    
//    
//    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar.png"];
//    
//    //need to set the title because accessibility uses the title, set text to clear so it doesn't display
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       [UIColor clearColor], UITextAttributeTextColor,
//                                                       nil] forState:UIControlStateNormal];
//    
//    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
//    
//    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage tallImageNamed:@"selection-tab.png"]];
//    
//    UIImage *minImage = [UIImage tallImageNamed:@"slider-fill.png"];
//    UIImage *maxImage = [UIImage tallImageNamed:@"slider-trackGray.png"];
//    UIImage *thumbImage = [UIImage tallImageNamed:@"slider-handle.png"];
//    
//    [[UISlider appearance] setMaximumTrackImage:maxImage
//                                       forState:UIControlStateNormal];
//    [[UISlider appearance] setMinimumTrackImage:[minImage stretchableImageWithLeftCapWidth:4 topCapHeight:0]
//                                       forState:UIControlStateNormal];
//    [[UISlider appearance] setThumbImage:thumbImage
//                                forState:UIControlStateNormal];
//    [[UISlider appearance] setThumbImage:thumbImage
//                                forState:UIControlStateHighlighted];
//}
////// Returns whether or not to use the iPod music player instead of the application music player.
////- (BOOL) useiPodPlayer {
////    //      LogMethod();
////	if ([[NSUserDefaults standardUserDefaults] boolForKey: PLAYER_TYPE_PREF_KEY]) {
////		return YES;
////	} else {
////		return NO;
////	}
////}
//// Returns whether to show the playlist remaining time in the player
////- (BOOL) showPlaylistRemaining {
////    //      LogMethod();
////	if ([[NSUserDefaults standardUserDefaults] boolForKey: SHOW_PLAYLIST_REMAINING_KEY]) {
////		return YES;
////	} else {
////		return NO;
////	}
////}
//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//    /*
//     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//     */
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    /*
//     Called when the application is about to terminate.
//     Save data if appropriate.
//     See also applicationDidEnterBackground:.
//     */
//}
//
//@end

