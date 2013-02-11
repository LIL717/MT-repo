//
//  MediaItemUserData.h
//  MegaTunes Player
//
//  Created by Lori Hill on 2/6/13.
//
//
@class UserDataForMediaItem;

@interface MediaItemUserData : NSManagedObject <NSFetchedResultsControllerDelegate> {
    
    NSManagedObjectContext *managedObjectContext_;
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * userClassification;
@property (nonatomic, retain) NSString * userNotes;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSDate   * lastPlayedDate;
@property (nonatomic, retain) NSNumber * bpm;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSArray *fetchedObjects;

- (void)addMediaItemToCoreData:(UserDataForMediaItem *) mediaItem;
- (UserDataForMediaItem *) containsItem: (NSNumber *) currentItem;
- (void) updateLastPlayedDateForItem: (NSNumber *) currentItem;
//- (void)removeMediaItemFromCoreData;

@end
