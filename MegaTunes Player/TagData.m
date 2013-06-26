//
//  TagData.m
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//

#import "TagData.h"
#import "TagItem.h"

@implementation TagData

@dynamic tagName;
@dynamic tagColorRed;
@dynamic tagColorGreen;
@dynamic tagColorBlue;
@dynamic tagColorAlpha;
@dynamic sortOrder;
@dynamic mediaItemUserData;

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;

@synthesize fetchedObjects;

-(NSArray *) fetchTagList
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TagData"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error = nil;
    NSArray *allFetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (allFetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }
    
    return allFetchedObjects;
}
- (TagItem *) containsItem: (NSNumber *) sortOrder {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TagData"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"sortOrder == %@", sortOrder];
    
    [fetchRequest setPredicate:pred];
    
    //    NSLog(@"entity retrieved is %@", entity);
    
    self.fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
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
        
    NSError * error = nil;
    
    // insert the tagData into Core Data
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TagData" inManagedObjectContext:self.managedObjectContext];
    [newManagedObject setValue: tagItem.tagName forKey:@"tagName"];
    [newManagedObject setValue: tagItem.tagColorRed forKey:@"tagColorRed"];
    [newManagedObject setValue: tagItem.tagColorGreen forKey:@"tagColorGreen"];
    [newManagedObject setValue: tagItem.tagColorBlue forKey:@"tagColorBlue"];
    [newManagedObject setValue: tagItem.tagColorAlpha forKey:@"tagColorAlpha"];
    [newManagedObject setValue: tagItem.sortOrder forKey:@"sortOrder"];
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
}
- (void) updateTagItemInCoreData: (TagItem *) tagItem {
    
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
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }

}
- (void) listAll {
    // Test listing all tagItems from the store
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TagData"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *allFetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (allFetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }
    
    for (TagItem *tagItem in allFetchedObjects) {
        NSLog(@"Name: %@", tagItem.tagName);
        int red = [tagItem.tagColorRed intValue];
        int green = [tagItem.tagColorGreen intValue];
        int blue = [tagItem.tagColorBlue intValue];
        int alpha = [tagItem.tagColorAlpha intValue];
        
        UIColor *color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
                NSLog(@"Color: %@", color);
        
        int sortOrder = [tagItem.sortOrder intValue];
        NSLog(@"sortOrder: %d", sortOrder);
    }
}

@end
