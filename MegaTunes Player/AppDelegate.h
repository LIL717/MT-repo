//
//  AppDelegate.h
//  MegaTunes Player
//
//  Created by Lori Hill on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ColorSwitcher.h"

#define PLAYER_TYPE_PREF_KEY @"player_type_preference"


@interface AppDelegate : UIResponder <UIApplicationDelegate> {

NSManagedObjectModel *managedObjectModel;
NSManagedObjectContext *managedObjectContext;
NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) ColorSwitcher *colorSwitcher;


- (NSString *)applicationDocumentsDirectory;

+ (AppDelegate*)instance;

- (void)customizeGlobalTheme;
- (BOOL) useiPodPlayer;

@end
