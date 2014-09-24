//
//  MediaItemUserData.m
//  MegaTunes Player
//
//  Created by Lori Hill on 2/6/13.
//
//

#import "MediaItemUserData.h"
#import "UserDataForMediaItem.h"
#import "TagData.h"
#import "AppDelegate.h"

@implementation MediaItemUserData

@dynamic title;
@dynamic comments;
@dynamic persistentID;
@dynamic bpm;
@dynamic tagData;
@dynamic lastPlayedDate;

@synthesize fetchedObjects;

- (UserDataForMediaItem *) containsItem: (NSNumber *) currentItemPersistentID {

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaItemUserData"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"persistentID == %@", currentItemPersistentID];

    [fetchRequest setPredicate:pred];
    
//    NSLog(@"entity retrieved is %@", entity);

    self.fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    if (self.fetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }
    
    if ([self.fetchedObjects count] == 0) {
//        NSLog (@"no mediatItemUser objects fetched");
        return nil;
    } else {
        // if there is an object, need to return it
        return [self.fetchedObjects objectAtIndex:0];
    }

}
- (NSArray *) containsTag {

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaItemUserData"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tagData != nil"];
    
    [fetchRequest setPredicate:pred];
    
//    //    NSLog(@"entity retrieved is %@", entity);
//    
//    self.fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    
//    if (self.fetchedObjects == nil) {
//        // Handle the error
//        NSLog (@"fetch error");
//    }
//    
//    if ([self.fetchedObjects count] == 0) {
//        //        NSLog (@"no mediatItemUser objects fetched");
//        return nil;
//    } else {
//        // if there is an object, need to return it
//        return [self.fetchedObjects objectAtIndex:0];
//    }
//    NSError *error = nil;
    NSArray *allFetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (allFetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }
    
    return allFetchedObjects;
    
}
//update or add  NOTE: mediaItemUserData is never deleted,  the tagData is set to nil when a tag is removed, but object is never deleted

- (void) updateTagForItem: (UserDataForMediaItem *) userDataForMediaItem {

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

    NSError * error = nil;
    
    if ([self containsItem: userDataForMediaItem.persistentID]) {
        //if the object is found, update its fields
//        [[self.fetchedObjects objectAtIndex:0] setValue: userDataForMediaItem.tagName forKey: @"tagName"];
        [[self.fetchedObjects objectAtIndex:0] setValue: userDataForMediaItem.tagData forKey: @"tagData"];

    } else {
        //if the object was not found in Core Data, add a new object
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MediaItemUserData" inManagedObjectContext:context];
        [newManagedObject setValue: userDataForMediaItem.title forKey:@"title"];
        [newManagedObject setValue: userDataForMediaItem.persistentID forKey:@"persistentID"];
        [newManagedObject setValue: userDataForMediaItem.tagData forKey: @"tagData"];
    }
    if (![context save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TagDataForItemChanged" object:nil];
}
- (void) updateCommentsForItem: (UserDataForMediaItem *) userDataForMediaItem {
    
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

	NSError * error = nil;
    
    if ([self containsItem: userDataForMediaItem.persistentID]) {
        //if the object is found, update its fields
        [[self.fetchedObjects objectAtIndex:0] setValue: userDataForMediaItem.comments forKey: @"comments"];
    } else {
        //if the object was not found in Core Data, add a new object
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MediaItemUserData" inManagedObjectContext:context];
        [newManagedObject setValue: userDataForMediaItem.title forKey:@"title"];
        [newManagedObject setValue: userDataForMediaItem.comments forKey: @"comments"];
        [newManagedObject setValue: userDataForMediaItem.persistentID forKey:@"persistentID"];

    }
    if (![context save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
}

- (void) listAll {
// Test listing all tagData from the store

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

	NSError * error = nil;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaItemUserData"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSArray *fetchedObjects2 = [context executeFetchRequest:fetchRequest error:&error];
    for (UserDataForMediaItem *uDFMI in fetchedObjects2) {
        NSLog(@"title: %@", uDFMI.title);
        NSLog(@"persistentID: %@", uDFMI.persistentID);
        NSLog(@"comments: %@", uDFMI.comments);
        NSLog(@"tagData: %@", uDFMI.tagData);
    }
}
//end test
@end
