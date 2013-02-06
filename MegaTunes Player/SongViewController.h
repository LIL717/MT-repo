//
//  SongViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class CollectionItem;
@class SongInfo;

@interface SongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,MPMediaPickerControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;

}

@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   CollectionItem *collectionItem;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   SongInfo *songInfo;
@property (nonatomic, strong)   MPMediaItem *itemToPlay;
@property (readwrite)           BOOL iPodLibraryChanged;



@end