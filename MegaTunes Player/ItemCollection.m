//
//  ItemCollection.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/30/12.
//
//

#import "ItemCollection.h"

@implementation ItemCollection

@dynamic name;
@dynamic duration;
@dynamic collection;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;



//- (void)addCollectionToCoreData:(NSArray *)mediaItemArray (MPMediaItemCollection *) mediaItemCollection {
- (void)addCollectionToCoreData:(MPMediaItemCollection *) mediaItemCollection {
    //LogMethod();
    
    [self removeCollectionFromCoreData];
    
    NSError * error = nil;
    
    // insert the collection into Core Data
//    for (MPMediaItem *newItem in mediaItemArray) {
    
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ItemCollection" inManagedObjectContext:self.managedObjectContext];
//        [newManagedObject setValue: [newItem valueForProperty: MPMediaItemPropertyTitle]                forKey:@"name"];
//        [newManagedObject setValue: [newItem valueForProperty:MPMediaItemPropertyPlaybackDuration] forKey: @"duration"];
        [newManagedObject setValue: mediaItemCollection forKey: @"collection"];
    
    NSArray *returnedQueue = [mediaItemCollection items];

    for (MPMediaItem *song in returnedQueue) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSLog (@"collection to save \t\t%@", songTitle);
    }
    
        NSLog(@" newManagedObject is %@", newManagedObject);
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
        }
//    }
    
}
- (MPMediaItemCollection *) containsItem: (NSString *) playingSong

{
    BOOL itemFound;
//    NSLog (@"currently playing song is %@", playingSong);
    
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
    MPMediaItemCollection *mediaItemCollection = [[fetchedObjects objectAtIndex:0] valueForKey: @"collection"];
    itemFound = NO;
    //if there are no objects, set itemFound to NO
    if ([fetchedObjects count] == 0) {
        NSLog (@"no objects fetched");
        itemFound = NO;
    } else {
            // if there is an object, need to see if song is in the list
            NSArray *savedQueue = [mediaItemCollection items];
        
            for (MPMediaItem *song in savedQueue) {
                if ([[song valueForProperty: MPMediaItemPropertyTitle] isEqual: playingSong]) {
                    itemFound = YES;
                    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
                    NSLog (@"saved collection\t\t%@", songTitle);
                }
            }
    }
    //if the item wasn't found, need to delete the queue because a different collection is playing
    if (!itemFound) {
            [self removeCollectionFromCoreData];
    }
    return mediaItemCollection;
}

- (void)removeCollectionFromCoreData {
    LogMethod();
    
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

//#pragma mark - Fetched results controller
//
//- (NSFetchedResultsController *)fetchedResultsController
//{
//    
//    if (fetchedResultsController_ != nil)
//    {
//        return fetchedResultsController_;
//    }
//    
//    /*
//     Set up the fetched results controller.
//     */
//    // Create the fetch request for the entity.
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    // Edit the entity name as appropriate.
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemCollection" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // Set the batch size to a suitable number.
//    [fetchRequest setFetchBatchSize:20];
//    
//    // Edit the sort key as appropriate.
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//    
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    
//    // Edit the section name key path and cache name if appropriate.
//    // nil for section name key path means "no sections".
//    //    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
//    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"name" cacheName:@"Root"];
//    
//    aFetchedResultsController.delegate = self;
//    self.fetchedResultsController = aFetchedResultsController;
//    
//    
//	NSError *error = nil;
//	if (![self.fetchedResultsController performFetch:&error])
//    {
//        UIAlertView* alertView =
//        [[UIAlertView alloc] initWithTitle:@"Data Management Error"
//                                   message:@"Press the Home button to quit this application."
//                                  delegate:self
//                         cancelButtonTitle:@"OK"
//                         otherButtonTitles: nil];
//        [alertView show];
//	}
//    
//    return fetchedResultsController_;
//}    
//


@end