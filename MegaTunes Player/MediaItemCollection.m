//
//  UserMediaItemCollection.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/30/12.
//
//

#import "MediaItemCollection.h"

@implementation MediaItemCollection

@dynamic mediaItem;
@synthesize managedObjectContext = managedObjectContext_;



- (void)addCollectionToCoreData:(NSArray *)collection {
    //LogMethod();
    //this is an array of dictionaries
    
    NSError *error = nil;
    // insert the collection into Core Data
    for (id newItem in collection) {
        
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MediaItemCollection" inManagedObjectContext:self.managedObjectContext];
        [newManagedObject setValue: [newItem valueForKey: @"MediaItem"] forKey:@"mediaItem"];

        
        NSLog(@" newManagedObject is %@", newManagedObject);
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
        }
    }
    
}
@end
