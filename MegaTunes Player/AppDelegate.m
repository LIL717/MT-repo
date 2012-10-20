//
//  AppDelegate.m
//  MegaTunes Player
//
//  Created by Lori Hill on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ColorSwitcher.h"



@implementation AppDelegate 
@synthesize window = _window;
@synthesize colorSwitcher;

+ (AppDelegate *)instance {
    return [[UIApplication sharedApplication] delegate];
}

//Explicitly write Core Data accessors
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"<Project Name>.sqlite"]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
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
