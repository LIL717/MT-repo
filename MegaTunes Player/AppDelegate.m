//
//  AppDelegate.m
//  MegaTunes Player
//
//  Created by Lori Hill on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PlaylistPickerViewController.h"
#import "Playlist.h"

@implementation AppDelegate {
	NSMutableArray *playlists;
}
@synthesize window = _window;

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    // Override point for customization after application launch.
//    playlists = [NSMutableArray arrayWithCapacity:20];
//	Playlist *playlist = [[Playlist alloc] init];
//	playlist.name = @"Woot Woot";
//	playlist.duration = @"55:00";
//	[playlists addObject:playlist];
//    
//	playlist = [[Playlist alloc] init];
//	playlist.name = @"Easy Does It";
//	playlist.duration = @"17:00";
//	[playlists addObject:playlist];
//    
//    playlist = [[Playlist alloc] init];
//	playlist.name = @"Workin Hard";
//	playlist.duration = @"70:00";
//	[playlists addObject:playlist];
//
//	UINavigationController *navigationController =
//    (UINavigationController *) self.window.rootViewController;
//	PlaylistPickerViewController *playlistPickerViewController =
//    [[navigationController viewControllers] objectAtIndex:0];
//	playlistPickerViewController.playlists = playlists;
//    return YES;
//}

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
