//
//  UserMediaItemCollection.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/30/12.
//
//

@interface MediaItemCollection : NSManagedObject

@property (nonatomic, retain) MPMediaItem *mediaItem;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


- (void)addCollectionToCoreData:(NSArray *)collection;

@end
