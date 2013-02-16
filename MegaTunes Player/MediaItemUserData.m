//
//  MediaItemUserData.m
//  MegaTunes Player
//
//  Created by Lori Hill on 2/6/13.
//
//

#import "MediaItemUserData.h"
#import "UserDataForMediaItem.h"

@implementation MediaItemUserData

@dynamic title;
@dynamic userGrouping;
@dynamic comments;
@dynamic persistentID;
@dynamic bpm;

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;

@synthesize fetchedObjects;

- (UserDataForMediaItem *) containsItem: (NSNumber *) currentItemPersistentID {

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaItemUserData"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"persistentID == %@", currentItemPersistentID];

    [fetchRequest setPredicate:pred];
    
//    NSLog(@"entity retrieved is %@", entity);

    NSError *error = nil;
    self.fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (self.fetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }
    
    if ([self.fetchedObjects count] == 0) {
        NSLog (@"no objects fetched");
        return nil;
    } else {
        // if there is an object, need to return it
        return [self.fetchedObjects objectAtIndex:0];
    }
}
- (void) updateUserGroupingForItem: (UserDataForMediaItem *) userDataForMediaItem {
    
    NSError * error = nil;
    
    if ([self containsItem: userDataForMediaItem.persistentID]) {
        //if the object is found, update its fields
        [[self.fetchedObjects objectAtIndex:0] setValue: userDataForMediaItem.userGrouping forKey: @"userGrouping"];
    } else {
        //if the object was not found in Core Data, add a new object
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MediaItemUserData" inManagedObjectContext:self.managedObjectContext];
        [newManagedObject setValue: userDataForMediaItem.title forKey:@"title"];
        [newManagedObject setValue: userDataForMediaItem.userGrouping forKey: @"userGrouping"];
        [newManagedObject setValue: userDataForMediaItem.persistentID forKey:@"persistentID"];
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
}
- (void) updateCommentsForItem: (UserDataForMediaItem *) userDataForMediaItem {
    
    NSError * error = nil;
    
    if ([self containsItem: userDataForMediaItem.persistentID]) {
        //if the object is found, update its fields
        [[self.fetchedObjects objectAtIndex:0] setValue: userDataForMediaItem.comments forKey: @"comments"];
    } else {
        //if the object was not found in Core Data, add a new object
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MediaItemUserData" inManagedObjectContext:self.managedObjectContext];
        [newManagedObject setValue: userDataForMediaItem.title forKey:@"title"];
        [newManagedObject setValue: userDataForMediaItem.comments forKey: @"comments"];
        [newManagedObject setValue: userDataForMediaItem.persistentID forKey:@"persistentID"];
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
}
@end
