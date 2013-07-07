//
//  AppDelegate.h
//  MegaTunes Player
//
//  Created by Lori Hill on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//#import "ColorSwitcher.h"

//#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
//#define SHOW_PLAYLIST_REMAINING_KEY @"show_playlist_remaining"


@interface AppDelegate : UIResponder <UIApplicationDelegate, NSFetchedResultsControllerDelegate> {
    UINavigationController *navigationController;
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
}

@property (strong, nonatomic) UIWindow *window;
//@property (strong, retain) UINavigationController *navigationController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//@property (nonatomic, retain) ColorSwitcher *colorSwitcher;
//@property (nonatomic) BOOL iCloudAvailable;


- (NSURL *)applicationDocumentsDirectory;

//+ (AppDelegate*)instance;

- (void)customizeGlobalTheme;
//- (BOOL) useiPodPlayer;
//- (BOOL) showPlaylistRemaining;


@end
