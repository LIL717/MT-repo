//
//  ItemCollection.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/30/12.
//
//
@class CollectionItem;

@interface ItemCollection : NSManagedObject <NSFetchedResultsControllerDelegate> {
    NSManagedObjectContext *managedObjectContext_;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSDate *lastPlayedDate;
@property (nonatomic, retain) MPMediaItemCollection *collection;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)addCollectionToCoreData:(CollectionItem *) collectionItem;
- (CollectionItem *) containsItem: (NSString *) playingSong;
- (void)removeCollectionFromCoreData;

@end