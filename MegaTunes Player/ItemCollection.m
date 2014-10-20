//
//  ItemCollection.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/30/12.
//
//

#import "ItemCollection.h"
#import "CollectionItem.h"
#import "AppDelegate.h"

@implementation ItemCollection

@dynamic name;
@dynamic duration;
@dynamic lastPlayedDate;
@dynamic collection;
@dynamic inAppPlaylist;
@dynamic sortOrder;

- (void)addCollectionToCoreData:(CollectionItem *) collectionItem {

    //LogMethod();
    
    [self removeCollectionFromCoreData];

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

//	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemCollection"
//											  inManagedObjectContext:context];
//	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]inManagedObjectContext:context];
    // insert the collection into Core Data
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ItemCollection" inManagedObjectContext:context];
    [newManagedObject setValue: collectionItem.name forKey:@"name"];
    [newManagedObject setValue: collectionItem.duration forKey: @"duration"];
    [newManagedObject setValue: collectionItem.lastPlayedDate forKey: @"lastPlayedDate"];
    [newManagedObject setValue: collectionItem.collection forKey: @"collection"];
    [newManagedObject setValue: [NSNumber numberWithBool:collectionItem.inAppPlaylist ] forKey: @"inAppPlaylist"];
    [newManagedObject setValue: collectionItem.sortOrder forKey:@"sortOrder"];

//    NSArray *collectionArray = [collectionItem.collection items];
//
//    for (MPMediaItem *song in collectionArray) {
//        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSLog (@"collection to save \t\t%@", songTitle);
//    }
//    
//    NSLog(@" newManagedObject is %@", newManagedObject);

// Save the context.
	NSError *error = nil;
	if (![context save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
		abort();
	}

}
- (CollectionItem *) containsItem: (NSNumber *) playingSongPersistentID
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

    BOOL itemFound;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemCollection"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
        
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

	if (error) {
		NSLog(@"Error requesting items from Core Data: %@", [error localizedDescription]);
	}
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }

    itemFound = NO;
    //if there are no objects, set itemFound to NO
    if ([fetchedObjects count] == 0) {
        NSLog (@"no collection item objects fetched");
    } else {
            // if there is an object, need to see if song is in the list
            MPMediaItemCollection *mediaItemCollection = [[fetchedObjects objectAtIndex:0] valueForKey: @"collection"];
            NSArray *savedQueue = [mediaItemCollection items];
        
            for (MPMediaItem *song in savedQueue) {
//                if ([[song valueForProperty: MPMediaItemPropertyTitle] isEqual: playingSong]) {
                if ([[song valueForProperty: MPMediaItemPropertyPersistentID] isEqual: playingSongPersistentID]) {
                    itemFound = YES;
                }
            }
    }
    if (itemFound) {
        return [fetchedObjects objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void)removeCollectionFromCoreData {
//    LogMethod();
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
//select all objects in the ItemCollection
    NSFetchRequest * allItems = [[NSFetchRequest alloc] init];
    [allItems setEntity:[NSEntityDescription entityForName:@"ItemCollection" inManagedObjectContext:context]];
    [allItems setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * fetchedObjects = [context executeFetchRequest:allItems error:&error];

	if (error) {
		NSLog(@"Error requesting items from Core Data: %@", [error localizedDescription]);
	}
	if (fetchedObjects != nil) {
//			//this is all for debugging can be removed
//		MPMediaItemCollection *mediaItemCollection = [[fetchedObjects objectAtIndex:0] valueForKey: @"collection"];
//		NSArray *savedQueue = [mediaItemCollection items];
//
//		for (MPMediaItem *song in savedQueue) {
//			NSLog (@"%@", [song valueForProperty: MPMediaItemPropertyTitle]);
//		}
//			//end of code for debugging
		for (NSManagedObject * item in fetchedObjects) {
			[context deleteObject:item];
		}
	} else {
		NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
		abort();
	}

}

@end