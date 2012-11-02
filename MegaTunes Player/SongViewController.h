//
//  SongViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class CollectionItem;

@interface SongViewController : UITableViewController <MPMediaPickerControllerDelegate, UITableViewDelegate> {
    NSManagedObjectContext *managedObjectContext;

}

@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   CollectionItem *collectionItem;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;

@end