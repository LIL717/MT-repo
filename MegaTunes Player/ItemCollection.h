//
//  ItemCollection.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/30/12.
//
//
@class CollectionItem;

@interface ItemCollection : NSManagedObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSDate *lastPlayedDate;
@property (nonatomic, retain) MPMediaItemCollection *collection;
@property (nonatomic)         BOOL inAppPlaylist;
@property (nonatomic, retain) NSNumber *sortOrder;

- (void)addCollectionToCoreData:(CollectionItem *) collectionItem;
- (CollectionItem *) containsItem: (NSNumber *) playingSongPersistentID;
- (void)removeCollectionFromCoreData;

@end