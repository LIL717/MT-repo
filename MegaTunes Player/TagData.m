//
//  TagData.m
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//

#import "TagData.h"
#import "TagItem.h"
#import "MediaItemUserData.h"
#import "AppDelegate.h"


@implementation TagData

@dynamic tagName;
@dynamic tagColorRed;
@dynamic tagColorGreen;
@dynamic tagColorBlue;
@dynamic tagColorAlpha;
@dynamic sortOrder;
@dynamic mediaItemUserData;

@synthesize fetchedObjects;

-(NSArray *) fetchTagList
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TagData"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSError *error = nil;
    NSArray *allFetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    if (allFetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }
    
    return allFetchedObjects;
}
- (TagItem *) containsItem: (NSNumber *) sortOrder {

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TagData"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"sortOrder == %@", sortOrder];
    
    [fetchRequest setPredicate:pred];
    
    //    NSLog(@"entity retrieved is %@", entity);
    
    self.fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (self.fetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }
    
    if ([self.fetchedObjects count] == 0) {
        NSLog (@"no tag objects fetched");
        return nil;
    } else {
        // if there is an object, need to return it
        return [self.fetchedObjects objectAtIndex:0];
    }
    
}
- (void)addTagItemToCoreData:(TagItem *) tagItem {
    
    //LogMethod();
        
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

    // insert the tagData into Core Data
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TagData" inManagedObjectContext:context];
    [newManagedObject setValue: tagItem.tagName forKey:@"tagName"];
    [newManagedObject setValue: tagItem.tagColorRed forKey:@"tagColorRed"];
    [newManagedObject setValue: tagItem.tagColorGreen forKey:@"tagColorGreen"];
    [newManagedObject setValue: tagItem.tagColorBlue forKey:@"tagColorBlue"];
    [newManagedObject setValue: tagItem.tagColorAlpha forKey:@"tagColorAlpha"];
    [newManagedObject setValue: tagItem.sortOrder forKey:@"sortOrder"];

	NSError * error = nil;
    if (![context save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TagDataChanged" object:nil];

}
- (void) updateTagItemInCoreData: (TagItem *) tagItem {

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

    NSError * error = nil;
    
    if ([self containsItem: tagItem.sortOrder]) {
        //if the object is found, update its fields
        [[self.fetchedObjects objectAtIndex:0] setValue: tagItem.tagName forKey: @"tagName"];
        [[self.fetchedObjects objectAtIndex:0] setValue: tagItem.tagColorRed forKey:@"tagColorRed"];
        [[self.fetchedObjects objectAtIndex:0] setValue: tagItem.tagColorGreen forKey:@"tagColorGreen"];
        [[self.fetchedObjects objectAtIndex:0] setValue: tagItem.tagColorBlue forKey:@"tagColorBlue"];
        [[self.fetchedObjects objectAtIndex:0] setValue: tagItem.tagColorAlpha forKey:@"tagColorAlpha"];
//        [[self.fetchedObjects objectAtIndex:0] setValue: tagItem.sortOrder forKey:@"sortOrder"];
    }
    if (![context save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TagDataChanged" object:nil];


}
- (void) deleteTagDataFromCoreData: (TagData *) tagData {

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;

    NSError * error = nil;
    
    [context deleteObject: tagData];
        
    if (![context save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TagDataChanged" object:nil];
    
    
}

- (void) listAll {
    // Test listing all tagItems from the store
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TagData"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *allFetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (allFetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }
    
    for (TagData *tagData in allFetchedObjects) {
        NSLog(@"TagName: %@", tagData.tagName);
        int red = [tagData.tagColorRed intValue];
        int green = [tagData.tagColorGreen intValue];
        int blue = [tagData.tagColorBlue intValue];
        int alpha = [tagData.tagColorAlpha intValue];
        
        UIColor *color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
                NSLog(@"TagColor: %@", color);
        
        int sortOrder = [tagData.sortOrder intValue];
        NSLog(@"sortOrder: %d", sortOrder);
        NSLog(@"mediaItemUserData: %@", tagData.mediaItemUserData);

    }
}

@end
