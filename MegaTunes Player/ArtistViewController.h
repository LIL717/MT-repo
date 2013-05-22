//
//  CollectionViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//
@class CollectionItem;
@class MTSearchBar;

@interface ArtistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {

    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic)   IBOutlet UITableView *collectionTableView;
@property (strong, nonatomic)   IBOutlet UIView *allAlbumsView;
@property (strong, nonatomic)   IBOutlet UIButton *allAlbumsButton;
@property (strong, nonatomic)   IBOutlet MTSearchBar *searchBar;

@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   NSArray *collection;
@property (nonatomic, strong)   NSString *collectionType;
@property (nonatomic, strong)   MPMediaQuery *collectionQueryType;
@property (nonatomic, strong)   NSIndexPath* saveIndexPath;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (readwrite)           BOOL isSearching;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   NSArray *albumCollection;
@property (nonatomic, strong)   UIBarButtonItem *rightBarButton;
@property (nonatomic, strong)   NSArray *searchResults;


- (NSNumber *) calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue;

@end
