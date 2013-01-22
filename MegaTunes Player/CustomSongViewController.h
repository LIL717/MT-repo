//
//  CustomSongViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 1/22/13.
//
//

@class CollectionItem;
@class SongInfo;

@interface CustomSongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,MPMediaPickerControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;
    
}

@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   CollectionItem *collectionItem;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   SongInfo *songInfo;
@property (nonatomic, strong)   NSIndexPath* saveIndexPath;
@property (nonatomic, strong)   MPMediaItem *itemToPlay;


@end