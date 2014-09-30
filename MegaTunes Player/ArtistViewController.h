//
//  CollectionViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//
@class CollectionItem;

@interface ArtistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UISearchControllerDelegate>
 {

    NSManagedObjectContext *managedObjectContext_;
}

@property (strong, nonatomic)   IBOutlet UITableView *collectionTableView;
@property (strong, nonatomic)   IBOutlet UIView *allAlbumsView;
//@property (strong, nonatomic) IBOutlet UIView *searchControllerView;
@property (strong, nonatomic)   IBOutlet UIButton *allAlbumsButton;
//140114 1.2 iOS 7 begin

//140114 1.2 iOS 7 end
//130912 1.1 add iTunesStoreButton begin
@property (strong, nonatomic)   IBOutlet UIButton *moreGenreButton;
//130912 1.1 add iTunesStoreButton end

@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   NSArray *collection;
@property (nonatomic, strong)   NSString *collectionType;
@property (nonatomic, strong)   MPMediaQuery *collectionQueryType;
@property (nonatomic, strong)   NSIndexPath* saveIndexPath;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (readwrite)           BOOL isIndexed;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   NSArray *albumCollection;
@property (nonatomic, strong)   UIBarButtonItem *rightBarButton;
//@property (nonatomic, strong)   NSArray *searchResults;
@property (readwrite)           BOOL cellScrolled;

//130909 1.1 add iTunesStoreButton begin
@property (strong, nonatomic) NSString *iTunesStoreSelector;
@property (strong, nonatomic) NSString *genreLinkUrl;
@property (strong, nonatomic) NSLocale *locale;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *genreNameFormatted;
@property (strong, nonatomic) NSString *albumNameFormatted;
@property (strong, nonatomic) NSString *artistNameFormatted;
@property (strong, nonatomic) NSString *songNameFormatted;
@property (strong, nonatomic) NSString *iTunesLinkUrl;

//130909 1.1 add iTunesStoreButton end
- (IBAction)allAlbumsButtonTapped:(id)sender;
- (NSNumber *) calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue;

@end
