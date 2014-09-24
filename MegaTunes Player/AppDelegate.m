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
#import "TestFlight.h"



@implementation AppDelegate

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
//#define TESTING 1
//#ifdef TESTING
//    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
//#endif
//    [TestFlight takeOff:@"3ec22a1e-ddac-483c-8152-21c537a9fb42"];

    //*** end of TestFlight code
//130906 1.1 add Store Button begin
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject: @"at=10l9mp" forKey:@"affiliateID"];
//130906 1.1 add Store Button end

//    //Load a couple defaults to userTag Core Data if there aren't any objects in TagData
    
    TagData *tagData = [TagData alloc];
	[tagData listAll];

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
    
    [self customizeGlobalTheme];

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
    
    
    //    UIImage *navBarDefaultImage = [colorSwitcher processImageWithName:@"megaMenu-bar.png"];
    UIImage *navBarDefaultImage = [UIImage imageNamed:@"megaMenu-bar.png"];
    
    [[UINavigationBar appearance] setBackgroundImage:navBarDefaultImage forBarMetrics:UIBarMetricsDefault];
    
    //    UIImage *navBarLandscapeImage = [colorSwitcher processImageWithName:@"megaMenu-bar-landscape.png"];
    UIImage *navBarLandscapeImage = [UIImage imageNamed:@"megaMenu-bar-landscape.png"];
    
    [[UINavigationBar appearance] setBackgroundImage:navBarLandscapeImage forBarMetrics:UIBarMetricsLandscapePhone];
    
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment: 4 forBarMetrics: UIBarMetricsLandscapePhone];
    
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar.png"];
    
    //need to set the title because accessibility uses the title, set text to clear so it doesn't display
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor clearColor], UITextAttributeTextColor,
                                                       nil] forState:UIControlStateNormal];
    
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage tallImageNamed:@"selection-tab.png"]];
    
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
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "com.Frostbite-Learning.CoreDataBasicFromXcode6" in the application's documents directory.
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
		// The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
	if (_managedObjectModel != nil) {
		return _managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MegaTunes Player" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
		// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
	if (_persistentStoreCoordinator != nil) {
		return _persistentStoreCoordinator;
	}

		// Create the coordinator and store

	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MegaTunes Player.sqlite"];
	NSError *error = nil;
	NSString *failureReason = @"There was an error creating or loading the application's saved data.";
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
			// Report any error we got.
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
		dict[NSLocalizedFailureReasonErrorKey] = failureReason;
		dict[NSUnderlyingErrorKey] = error;
		error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}

	return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
	if (_managedObjectContext != nil) {
		return _managedObjectContext;
	}

	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (!coordinator) {
		return nil;
	}
	_managedObjectContext = [[NSManagedObjectContext alloc] init];
	[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	if (managedObjectContext != nil) {
		NSError *error = nil;
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}
@end

