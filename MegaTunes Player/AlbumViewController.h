//
//  AlbumViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 3/25/13.
//
//

@class CollectionItem;
@class MTSearchBar;
@class AppDelegate;



@interface AlbumViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    
    NSManagedObjectContext *managedObjectContext_;
}

@property (strong, nonatomic)   IBOutlet UITableView *collectionTableView;
@property (strong, nonatomic)   IBOutlet UIView *allSongsView;
@property (strong, nonatomic)   IBOutlet UIButton *allSongsButton;
@property (strong, nonatomic)   IBOutlet UISearchBar *searchBar;
//130912 1.1 add iTunesStoreButton begin
@property (weak, nonatomic) IBOutlet UIButton *moreByArtistButton;
//130912 1.1 add iTunesStoreButton end
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   NSArray *collection;
@property (nonatomic, strong)   NSString *collectionType;
@property (nonatomic, strong)   MPMediaQuery *collectionQueryType;
@property (nonatomic, strong)   NSIndexPath* saveIndexPath;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (readwrite)           BOOL showAllSongsCell;
@property (readwrite)           BOOL isIndexed;
@property (readwrite)           BOOL isSearching;
@property (readwrite)           BOOL cellScrolled;
@property (nonatomic, retain)   MPMediaItemCollection *songCollection;
@property (nonatomic, strong)   UIBarButtonItem *rightBarButton;
@property (nonatomic, strong)   NSArray *searchResults;
@property (nonatomic, strong)   MPMediaPropertyPredicate *collectionPredicate;
@property (nonatomic, strong)   AppDelegate *appDelegate;

//130909 1.1 add iTunesStoreButton begin
@property (strong, nonatomic) NSString *iTunesStoreSelector;
//@property (strong, nonatomic) NSString *genreLinkUrl;
@property (strong, nonatomic) NSLocale *locale;
@property (strong, nonatomic) NSString *countryCode;
//@property (strong, nonatomic) NSString *genreNameFormatted;
//@property (strong, nonatomic) NSString *albumNameFormatted;
@property (strong, nonatomic) NSString *artistNameFormatted;
//@property (strong, nonatomic) NSString *songNameFormatted;
@property (strong, nonatomic) NSString *iTunesLinkUrl;
@property (strong, nonatomic) NSString *artistLinkUrl;


//130909 1.1 add iTunesStoreButton end



- (NSNumber *) calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue;

@end
