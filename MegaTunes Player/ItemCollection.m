//
//  ItemCollection.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/30/12.
//
//

#import "ItemCollection.h"
#import "CollectionItem.h"

@implementation ItemCollection

@dynamic name;
@dynamic duration;
@dynamic lastPlayedDate;
@dynamic collection;
@dynamic inAppPlaylist;
@dynamic sortOrder;

@synthesize managedObjectContext = _managedObjectContext;

- (void)addCollectionToCoreData:(CollectionItem *) collectionItem {

    //LogMethod();
    
    [self removeCollectionFromCoreData];

	NSManagedObjectContext *context = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemCollection"
											  inManagedObjectContext:self.managedObjectContext];
	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]inManagedObjectContext:context];
    // insert the collection into Core Data    
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ItemCollection" inManagedObjectContext:self.managedObjectContext];
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
//	[self.managedObjectContext save:&error];
// Save the context.
	NSError *error = nil;
	if (![context save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
//	NSError * error = nil;
//
//    if (![self.managedObjectContext save:&error]) {
//		NSLog(@"Error: %@", [error localizedDescription]);
//
////        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
//    }

}
- (CollectionItem *) containsItem: (NSNumber *) playingSongPersistentID

{
    BOOL itemFound;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemCollection"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
        
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
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
    
//select all objects in the ItemCollection
    NSFetchRequest * allItems = [[NSFetchRequest alloc] init];
    [allItems setEntity:[NSEntityDescription entityForName:@"ItemCollection" inManagedObjectContext:self.managedObjectContext]];
    [allItems setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * items = [self.managedObjectContext executeFetchRequest:allItems error:&error];
    
    //error handling goes here
    for (NSManagedObject * item in items) {
        [self.managedObjectContext deleteObject:item];
    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end