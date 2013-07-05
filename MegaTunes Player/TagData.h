//
//  TagData.h
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//

#import <CoreData/CoreData.h>
@class TagItem;
@class MediaItemUserData;

@interface TagData : NSManagedObject <NSFetchedResultsControllerDelegate> {
    
    NSManagedObjectContext *managedObjectContext_;
}
@property (nonatomic, retain) NSString *tagName;
@property (nonatomic, retain) NSNumber *tagColorRed;
@property (nonatomic, retain) NSNumber *tagColorGreen;
@property (nonatomic, retain) NSNumber *tagColorBlue;
@property (nonatomic, retain) NSNumber *tagColorAlpha;
@property (nonatomic, retain) NSNumber *sortOrder;
@property (nonatomic, retain) MediaItemUserData *mediaItemUserData;


@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *fetchedObjects;


- (NSArray *) fetchTagList;
- (void) addTagItemToCoreData:(TagItem *) tagItem;
- (void) updateTagItemInCoreData: (TagItem *) tagItem;
- (void) deleteTagDataFromCoreData: (TagData *) tagData;

- (void) listAll;
- (TagItem *) containsItem: (NSNumber *) sortOrder;
//- (void)removeUGItemFromCoreData;

@end
