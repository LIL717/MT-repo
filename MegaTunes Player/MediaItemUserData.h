//
//  MediaItemUserData.h
//  MegaTunes Player
//
//  Created by Lori Hill on 2/6/13.
//
//
@class UserDataForMediaItem;
@class TagData;


@interface MediaItemUserData : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSNumber * bpm;
@property (nonatomic, retain) TagData  * tagData;
@property (nonatomic, retain) NSDate *lastPlayedDate;

@property (nonatomic, retain) NSArray *fetchedObjects;

- (UserDataForMediaItem *) containsItem: (NSNumber *) currentItemPersistentID;
- (NSArray *) containsTag;
- (void) updateTagForItem: (UserDataForMediaItem *) userDataForMediaItem;
- (void) updateCommentsForItem: (UserDataForMediaItem *) userDataForMediaItem;
- (void) listAll;

@end
