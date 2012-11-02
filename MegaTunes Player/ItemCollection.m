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
@dynamic collection;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;

- (void)addCollectionToCoreData:(CollectionItem *) collectionItem {

    //LogMethod();
    
    [self removeCollectionFromCoreData];
    
    NSError * error = nil;
    
    // insert the collection into Core Data    
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ItemCollection" inManagedObjectContext:self.managedObjectContext];
    [newManagedObject setValue: collectionItem.name forKey:@"name"];
    [newManagedObject setValue: collectionItem.duration forKey: @"duration"];
    [newManagedObject setValue: collectionItem.collection forKey: @"collection"];
    
//    NSArray *collectionArray = [collectionItem.collection items];
//
//    for (MPMediaItem *song in collectionArray) {
//        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSLog (@"collection to save \t\t%@", songTitle);
//    }
//    
//    NSLog(@" newManagedObject is %@", newManagedObject);
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
    
}
- (CollectionItem *) containsItem: (NSString *) playingSong

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
        NSLog (@"no objects fetched");
        itemFound = NO;
    } else {
            // if there is an object, need to see if song is in the list
            MPMediaItemCollection *mediaItemCollection = [[fetchedObjects objectAtIndex:0] valueForKey: @"collection"];
            NSArray *savedQueue = [mediaItemCollection items];
        
            for (MPMediaItem *song in savedQueue) {
                if ([[song valueForProperty: MPMediaItemPropertyTitle] isEqual: playingSong]) {
                    itemFound = YES;

                }
            }
    }
    //if the item wasn't found, need to delete the queue because a different collection is playing
    if (itemFound) {
        return [fetchedObjects objectAtIndex:0];
    } else {
        [self removeCollectionFromCoreData];
        CollectionItem *returnEmpty = [CollectionItem alloc];
        returnEmpty.name  = @"";
        returnEmpty.duration = nil;
        returnEmpty.collection = nil;
        return returnEmpty;
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