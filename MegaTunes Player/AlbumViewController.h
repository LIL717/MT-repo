//
//  AlbumViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 3/25/13.
//
//

@class CollectionItem;

@interface AlbumViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate> {
    
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic)   IBOutlet UITableView *collectionTableView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   NSArray *collection;
@property (nonatomic, strong)   NSString *collectionType;
@property (nonatomic, strong)   NSIndexPath* saveIndexPath;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   NSMutableArray *albumDataArray;

- (NSNumber *) calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue;

@end
