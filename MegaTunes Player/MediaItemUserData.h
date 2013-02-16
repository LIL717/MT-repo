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
@property (nonatomic, retain) NSString * userGrouping;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSNumber * bpm;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSArray *fetchedObjects;

- (UserDataForMediaItem *) containsItem: (NSNumber *) currentItemPersistentID;
- (void) updateUserGroupingForItem: (UserDataForMediaItem *) userDataForMediaItem;
- (void) updateCommentsForItem: (UserDataForMediaItem *) userDataForMediaItem;
@end
