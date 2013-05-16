//
//  AlbumViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 3/25/13.
//
//

@class CollectionItem;
@class MTSearchBar;


@interface AlbumViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic)   IBOutlet UITableView *collectionTableView;
@property (strong, nonatomic)   IBOutlet UIView *allSongsView;
@property (strong, nonatomic)   IBOutlet UIButton *allSongsButton;
@property (strong, nonatomic)   IBOutlet MTSearchBar *searchBar;

@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   NSArray *collection;
@property (nonatomic, strong)   NSString *collectionType;
@property (nonatomic, strong)   MPMediaQuery *collectionQueryType;
@property (nonatomic, strong)   NSIndexPath* saveIndexPath;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (readwrite)           BOOL showAllSongsCell;
@property (nonatomic, retain)   MPMediaItemCollection *songCollection;
@property (nonatomic, strong)   UIBarButtonItem *rightBarButton;



- (NSNumber *) calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue;

@end
