//
//  AlbumViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 3/25/13.
//
//

//130911 1.1 add iTunesStoreButton begin
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//130911 1.1 add iTunesStoreButton end
#import "AlbumViewController.h"
#import "CollectionItemCell.h"
#import "CollectionItem.h"
#import "SongViewController.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"
#import "InCellScrollView.h"
#import "AppDelegate.h"
#import "MTSearchController.h"


@interface AlbumViewController () <UISearchResultsUpdating>
@property (nonatomic, strong) NSArray * albumCollectionSections;
@property (nonatomic, strong) NSArray * albumCollectionSectionTitles;
@property (nonatomic, strong) MTSearchController *searchController;
@property (nonatomic, strong) NSArray *searchResults; // Filtered search results
@end

@implementation AlbumViewController

@synthesize collectionTableView;
@synthesize allSongsView;
@synthesize allSongsButton;
@synthesize collection;
@synthesize collectionType;
@synthesize collectionQueryType;
@synthesize managedObjectContext = managedObjectContext_;
//@synthesize saveIndexPath;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize musicPlayer;
@synthesize showAllSongsCell;
@synthesize isIndexed;
@synthesize songCollection;
@synthesize rightBarButton;
@synthesize collectionPredicate;
@synthesize appDelegate;
@synthesize cellScrolled;

NSMutableArray *collectionDurations;
NSIndexPath *selectedIndexPath;
NSString *selectedName;
NSString *albumMediaItemProperty;
MPMediaGrouping albumMediaGrouping;
CGFloat constraintConstant;
UIImage *backgroundImage;
MPMediaQuery *myAlbumQuery;
MPMediaQuery *selectedQuery;
MPMediaPropertyPredicate *selectedPredicate;
//130912 1.1 add iTunesStoreButton begin
@synthesize moreByArtistButton;

@synthesize iTunesStoreSelector;
@synthesize artistLinkUrl;
@synthesize locale;
@synthesize countryCode;
//@synthesize genreNameFormatted;
//@synthesize albumNameFormatted;
@synthesize artistNameFormatted;
//@synthesize songNameFormatted;
@synthesize iTunesLinkUrl;

NSString *myAffiliateID;

//130912 1.1 add iTunesStoreButton end

BOOL showDuration;
BOOL firstLoad;
//UIActivityIndicatorView *spinner;
#pragma mark - Initial Display methods

- (void) viewDidLoad {
    
    [super viewDidLoad];
    //    LogMethod();
    
    firstLoad = YES;
    self.appDelegate = (id) [[UIApplication sharedApplication] delegate];

    //set up an array of durations to be used in landscape mode
    collectionDurations = [[NSMutableArray alloc] initWithCapacity: [self.collection count]];
//    NSLog (@" count of collection array %d", [self.collection count]);

    if ([self.collection count] > 0) {
        //create the array in the background
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // Perform async operation
            [self createDurationArray];
        });
    }

//131204 1.2 iOS 7 begin
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.titleView = [self customizeTitleView];

    UIButton *tempPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempPlayButton addTarget:self action:@selector(viewNowPlaying) forControlEvents:UIControlEventTouchUpInside];
    [tempPlayButton setImage:[UIImage imageNamed:@"redWhitePlayImage.png"] forState:UIControlStateNormal];
    [tempPlayButton setShowsTouchWhenHighlighted:NO];
    [tempPlayButton sizeToFit];
    
    self.rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempPlayButton];
//140127 1.2 iOS 7 end
    
    [self.rightBarButton setIsAccessibilityElement:YES];
    [self.rightBarButton setAccessibilityLabel: NSLocalizedString(@"Now Playing", nil)];
    [self.rightBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    self.cellScrolled = NO;
    
    self.showAllSongsCell = YES;

    if ([self.collectionType isEqualToString: @"Playlists"]) {
        self.showAllSongsCell = NO;
    }
    
    if ([self.collectionType isEqualToString: @"Podcasts"]) {
        self.showAllSongsCell = NO;
    }

	UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];

	searchResultsController.tableView.dataSource = self;
	searchResultsController.tableView.delegate = self;


	self.searchController = [[MTSearchController alloc] initWithSearchResultsController:searchResultsController];
	self.searchController.delegate = self;

	self.searchController.searchResultsUpdater = self;

	if (self.showAllSongsCell) {
		self.allSongsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		CGRect frame = CGRectMake(0.0, 44.0, self.view.bounds.size.width, 55);
		self.allSongsButton.frame = frame;
		self.allSongsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		self.allSongsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
		[self.allSongsButton setTitleColor:  [UIColor whiteColor] forState: UIControlStateNormal];
		[self.allSongsButton setTitleColor:  [UIColor blueColor] forState: UIControlStateHighlighted];
		[self.allSongsButton setTitle: NSLocalizedString(@"All Songs", nil) forState:UIControlStateNormal];
		[self.allSongsButton.titleLabel setFont: [UIFont systemFontOfSize: 44]];
			//remember to add a segue to viewController for this action
		[self.allSongsButton addTarget:self action:@selector(allSongsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self.searchController.searchBar addSubview: self.allSongsButton];
		[self.searchController formatSearchBarForInitialViewWithHeight: 99.0 andOffset: -20.0];
	} else {
		[self.searchController formatSearchBarForInitialViewWithHeight: 44.0 andOffset: 0.0];
	}

	self.collectionTableView.tableHeaderView = self.searchController.searchBar;
	self.definesPresentationContext = YES;
    //since collectionSections is not working for Playlists (submitted bug report to Apple 14409913), don't show allow indexing until Apple fixes it or make a workaround (like the sections for TaggedSongViewController)
    if ([self.collectionType isEqualToString: @"Playlists"]) {
        self.collectionTableView.sectionIndexMinimumDisplayRowCount = 999;
    } else {
        self.collectionTableView.sectionIndexMinimumDisplayRowCount = 20;
    }
    
//131203 1.2 iOS 7 begin
    
    [self.collectionTableView setSectionIndexColor:[UIColor whiteColor]];
    [self.collectionTableView setSectionIndexBackgroundColor:[UIColor blackColor]];
    
//131203 1.2 iOS 7 end
    
    if ([self.collection count] >= self.collectionTableView.sectionIndexMinimumDisplayRowCount) {
        self.isIndexed = YES;
    } else {
        self.isIndexed = NO;
    }
    

    
    
    // format of collectionSections is <MPMediaQuerySection: 0x1cd34c80> title=B, range={0, 5}, sectionIndexTitleIndex=1,

    self.albumCollectionSections = [self.collectionQueryType collectionSections];
        
    NSMutableArray * titles = [NSMutableArray arrayWithCapacity:[self.albumCollectionSections count]];
    for (MPMediaQuerySection * sec in self.albumCollectionSections) {
        [titles addObject:sec.title];
    }
    self.albumCollectionSectionTitles = [titles copy];
//    
//    NSLog (@"albumCollectionSections %@", self.albumCollectionSections);
//    NSLog (@"collection %@", self.collection);
//    NSLog (@"albumCollectionSectionTitles %@", self.albumCollectionSectionTitles);
    
    if ([self.collectionType isEqualToString: @"Playlists"]) {
        albumMediaItemProperty = MPMediaPlaylistPropertyName;
        albumMediaGrouping = MPMediaGroupingPlaylist;
    } else if ([self.collectionType isEqualToString: @"Podcasts"]) {
        albumMediaItemProperty = MPMediaItemPropertyPodcastTitle;
        albumMediaGrouping = MPMediaGroupingPodcastTitle;
    } else {
        // albums and compilations
        albumMediaItemProperty = MPMediaItemPropertyAlbumTitle;
        albumMediaGrouping = MPMediaGroupingAlbum;
    }
//130912 1.1 add iTunesStoreButton begin
    if ([self.collectionType isEqualToString: @"Artists"]) {
        //get the affliate ID
        myAffiliateID = [[NSUserDefaults standardUserDefaults] stringForKey:@"affiliateID"];
        //show the More button for iTunes
        [self establishITunesLink];
        self.moreByArtistButton.hidden = YES;
        [self.moreByArtistButton addTarget:self action:@selector(linkToiTunesStore:)  forControlEvents:UIControlEventTouchUpInside];
        
        [self.moreByArtistButton setIsAccessibilityElement:YES];
        [self.moreByArtistButton setAccessibilityLabel: NSLocalizedString(@"ITunesStore", nil)];
        [self.moreByArtistButton setAccessibilityTraits: UIAccessibilityTraitButton];
        [self.moreByArtistButton setAccessibilityHint: NSLocalizedString(@"View more in this genre.", nil)];
    } else {
        self.moreByArtistButton.hidden = YES;
    }
//130912 1.1 add iTunesStoreButton end
}
//130911 1.1 add iTunesStoreButton begin
//fetch the iTunes link info in the background
- (void) establishITunesLink {
    self.locale = [NSLocale currentLocale];
    self.countryCode = [self.locale objectForKey: NSLocaleCountryCode];
    
    
    //get itunes link for artist which is the title of this view
    
    self.artistNameFormatted = [self.title stringByReplacingOccurrencesOfString:@" "
                                                                    withString:@"+"];
    NSString *iTunesSearchString = [NSString stringWithFormat: @"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/itmsSearch?lang=1&output=json&country=%@&term=%@&media=music&limit=50", self.countryCode, self.artistNameFormatted];
    
    NSURL *iTunesSearchURL = [NSURL URLWithString: iTunesSearchString];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        iTunesSearchURL];
        [self performSelectorOnMainThread:@selector(fetchedArtist:)
                               withObject:data waitUntilDone:YES];
    });
    
}
//130911 1.1 add iTunesStoreButton end
//130911 1.1 add iTunesStoreButton begin

- (void)fetchedArtist:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    self.artistLinkUrl = nil;
    
//    MPMediaItem *song = [self.collectionItem.collectionArray objectAtIndex: 0];
    
    if (responseData) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              
                              options:kNilOptions
                              error:&error];
        
        NSArray* results = [json objectForKey:@"results"];
        if ([results count] >0) {
            
            NSLog (@"results %@", results);
            
            for (NSDictionary *item in results) {
                NSLog (@"%@   %@  %@  %@  %@", [item objectForKey: @"itemParentName"], [item objectForKey: @"trackCount"], [item objectForKey: @"trackNumber"], [item objectForKey: @"itemName"], [item objectForKey: @"artistName"]);

                    if ([[item objectForKey: @"kind"] isEqualToString: @"song"]
                        //                    && [[item objectForKey: @"itemName"] isEqualToString: [song valueForProperty:  MPMediaItemPropertyTitle]]
                        && [[item objectForKey: @"artistName"] isEqualToString: self.title]) {
                        self.artistLinkUrl = [item objectForKey: @"artistLinkUrl"];
                        break;
                    }
            }
        }
    }
    
    if (self.artistLinkUrl) {
        self.moreByArtistButton.hidden = NO;
    }
    NSLog (@"artistLinkUrl is %@", self.artistLinkUrl);
    
    //itemLinkUrl = "https://itunes.apple.com/us/album/you-love-me/id464532842?i=464532972&uo=4";
}
//130911 1.1 add iTunesStoreButton end
- (void) createDurationArray {
    
    for (MPMediaItemCollection* currentQueue in self.collection) {
        
        //get the duration of the the playlist
        
        NSNumber *playlistDurationNumber = [self calculatePlaylistDuration: currentQueue];
        long playlistDuration = [playlistDurationNumber longValue];
        
        int playlistMinutes = (int)(playlistDuration / 60);     // Whole minutes
        int playlistSeconds = (playlistDuration % 60);                        // seconds
        NSString *itemDuration = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];
        [collectionDurations addObject: itemDuration];
        
    }
}
- (void) viewWillAppear:(BOOL)animated
{
//    LogMethod();
    [super viewWillAppear: animated];
//131216 1.2 iOS 7 begin
    //this moved here when goBackClick removed
    if (iPodLibraryChanged) {
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
//131216 1.2 iOS 7 end
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (playingItem) {
        //initWithTitle cannot be nil, must be @""
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    //    // if rows have been scrolled, they have been added to this array, so need to scroll them back to 0
    //    YAY this works!!
    if (self.cellScrolled) {
        for (NSIndexPath *indexPath in [self.collectionTableView indexPathsForVisibleRows]) {
//            if (indexPath.row > 0) {
                NSLog (@" indexPath to scroll %@", indexPath);
                CollectionItemCell *cell = (CollectionItemCell *)[self.collectionTableView cellForRowAtIndexPath:indexPath];
                [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//            }
        }
        self.cellScrolled = NO;
    }
    [self updateLayoutForNewOrientation];
    
    return;
}

- (UILabel *) customizeTitleView
{
//131205 1.2 iOS 7 begin
    
    //    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:44]}].width, 48);
    
//131205 1.2 iOS 7 end
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:44];
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}
//- (BOOL)shouldAutorotate {
//    if (disableRotation) {
//        return NO;
//    } else {
//        return [self.navigationController.topViewController shouldAutorotate];
//    }
//}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation];
}
- (void) updateLayoutForNewOrientation {
    //    LogMethod();
//131216 1.2 iOS 7 begin
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat navBarAdjustment = isPortrait ? 0 : 0;
    
    if (isPortrait) {
        UIButton *tempPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [tempPlayButton addTarget:self action:@selector(viewNowPlaying) forControlEvents:UIControlEventTouchUpInside];
        [tempPlayButton setImage:[UIImage imageNamed:@"redWhitePlayImage.png"] forState:UIControlStateNormal];
        [tempPlayButton setShowsTouchWhenHighlighted:NO];
        [tempPlayButton sizeToFit];
        [tempPlayButton setContentEdgeInsets: UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
        
        self.rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempPlayButton];
    } else {
        UIButton *tempPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [tempPlayButton addTarget:self action:@selector(viewNowPlaying) forControlEvents:UIControlEventTouchUpInside];
        [tempPlayButton setImage:[UIImage imageNamed:@"redWhitePlayImage.png"] forState:UIControlStateNormal];
        [tempPlayButton setShowsTouchWhenHighlighted:NO];
        [tempPlayButton sizeToFit];
        [tempPlayButton setContentEdgeInsets: UIEdgeInsetsMake(3.0, 0.0, -3.0, 0.0)];
        
        self.rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempPlayButton];
    }
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (playingItem) {
        //initWithTitle cannot be nil, must be @""
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    
    //131216 1.2 iOS 7 end
        //don't need to do this if the search table is showing
    if (!self.searchController.isActive) {
        
        BOOL firstRowVisible = NO;
        
        //visibleRows is always 0 the first time through here for a table, populated after that
        if (firstLoad) {
            firstLoad = NO;
            firstRowVisible = YES;
        } else {
            NSArray *visibleRows = [self.collectionTableView indexPathsForVisibleRows];
            if ([visibleRows count] != 0) {
                NSIndexPath *index = [visibleRows objectAtIndex: 0];
                if (index.section == 0 && index.row == 0) {
                    firstRowVisible = YES;
                }
            }
        }
        
        // hide the search bar and All Albums cell
        CGFloat tableViewHeaderHeight = self.searchController.searchBar.frame.size.height;
        CGFloat adjustedHeaderHeight = tableViewHeaderHeight - navBarAdjustment;
//140113 1.2 iOS 7 begin
        //        NSInteger possibleRows = self.collectionTableView.frame.size.height / self.collectionTableView.rowHeight;
        ////        NSLog (@"possibleRows = %d collection count = %d", possibleRows, [self.collection count]);
        //        //if the table won't fill the screen need to wait for delay in order for tableView header to hide properly - so ugly
        //        if (firstLoad && [self.collection count] <= possibleRows) {
        //                [self performSelector:@selector(updateContentOffset) withObject:nil afterDelay:1.0];
        ////            } else {
        ////                [self performSelector:@selector(updateContentOffset) withObject:nil afterDelay:0.0];
        ////            }
        //        } else {
//140113 1.2 iOS 7 end
        if (firstRowVisible) {
            //        [self.collectionTableView scrollRectToVisible:CGRectMake(0, adjustedHeaderHeight, 1, 1) animated:NO];
            [self.collectionTableView setContentOffset:CGPointMake(0, adjustedHeaderHeight)];

//140113 1.2 iOS 7 begin
        }
        
        //        }
        //        firstLoad = NO;
//140113 1.2 iOS 7 end
        [self.collectionTableView reloadData];
    }
    self.cellScrolled = NO;
    
//    //recenter spinner
//    [spinner setCenter: CGPointMake (self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];

}
- (void)updateContentOffset {
    //this is only necessary when screen will not be filled - this method is executed afterDelay because ContentOffset is probably not correct until after layoutSubviews happens
    
    //    NSLog (@"tableView content size is %f %f",self.collectionTableView.contentSize.height, self.collectionTableView.contentSize.width);
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat largeHeaderAdjustment = isPortrait ? 11 : 23;
    
    CGFloat tableViewHeaderHeight = self.allSongsView.frame.size.height;
    
    [self.collectionTableView setContentOffset:CGPointMake(0, tableViewHeaderHeight - largeHeaderAdjustment)];
}
- (void) viewWillLayoutSubviews {
    //need this to pin portrait view to bounds otherwise if start in landscape, push to next view, rotate to portrait then pop back the original view in portrait - it will be too wide and "scroll" horizontally
    self.collectionTableView.contentSize = CGSizeMake(self.collectionTableView.frame.size.width, self.collectionTableView.contentSize.height);
    [super viewWillLayoutSubviews];
}
#pragma mark - Search Display Delegate methods

- (void)willPresentSearchController:(MTSearchController *)searchController {
	[searchController.searchBar setSearchFieldBackgroundPositionAdjustment: UIOffsetMake (0.0, 0.0)];
	[searchController.searchBar setTintColor: [UIColor lightGrayColor]];
}
- (void)willDismissSearchController:(MTSearchController *)searchController {
	if (self.showAllSongsCell) {
		[self.searchController formatSearchBarForInitialViewWithHeight: 99.0 andOffset: -20.0];
		CGRect frame = CGRectMake(0.0, 44.0, self.view.bounds.size.width, 55);
		self.allSongsButton.frame = frame;
		[self.searchController.searchBar addSubview: self.allSongsButton];
		[self.collectionTableView setContentOffset:CGPointMake(0, 99)];
	} else {
		[self.searchController formatSearchBarForInitialViewWithHeight: 44.0 andOffset: 0.0];
		[self.collectionTableView setContentOffset:CGPointMake(0, 44)];
	}
	[self.collectionTableView reloadData];

}
#pragma mark - Search Display methods

- (void) updateSearchResultsForSearchController:(MTSearchController *)searchController
{
	LogMethod();

	NSString *searchText = [self.searchController.searchBar text];
    
    NSLog (@"searchMediaItemProperty is %@", albumMediaItemProperty);
    MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue: searchText
                                                                                 forProperty: albumMediaItemProperty
                                                                              comparisonType:MPMediaPredicateComparisonContains];
    
    
    myAlbumQuery = [[MPMediaQuery alloc] init];
    //must copy otherwise adds the predicate to self.collectionQueryType too
    myAlbumQuery = [self.collectionQueryType copy];
    
    [myAlbumQuery setGroupingType: albumMediaGrouping];
    [myAlbumQuery addFilterPredicate: filterPredicate];

    self.searchResults = [myAlbumQuery collections];
    
//    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
//    NSArray *playlists = [myPlaylistsQuery collections];
//    
//    for (MPMediaPlaylist *playlist in playlists) {
//        NSLog (@"%@", [playlist valueForProperty: MPMediaPlaylistPropertyName]);
//        
//        NSArray *songs = [playlist items];
//        for (MPMediaItem *song in songs) {
//            NSString *songTitle =
//            [song valueForProperty: MPMediaItemPropertyTitle];
//            NSLog (@"\t\t%@", songTitle);
//        }
//    }
	[((UITableViewController *)searchController.searchResultsController).tableView reloadData];


}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return 1;
    } else {
        return [self.albumCollectionSections count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //    LogMethod();
    
    MPMediaQuerySection * sec = nil;
    sec = self.albumCollectionSections[section];
    return sec.title;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //    LogMethod();
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        
        return nil;
    } else {
        
        return [[NSArray arrayWithObject:@"{search}"] arrayByAddingObjectsFromArray:self.albumCollectionSectionTitles];
        //    return self.collectionSectionTitles;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //    LogMethod();
    
    //    NSLog (@"SectionIndexTitle is %@ at index %d", title, index);
    //since search was added to the array, need to return index - 1 to get to correct title, for search, set content Offset to top of table :)
    if ([title isEqualToString: @"{search}"]) {
        [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        return NSNotFound;
    } else {
        return index -1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        
        //        NSLog (@" searchResults count is %d", [self.searchResults count]);
        return [self.searchResults count];
    } else {
        MPMediaQuerySection * sec = self.albumCollectionSections[section];
        return sec.range.length;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //    LogMethod();
    //this must be nil or the section headers of the original tableView are awkwardly visible
    // original table must be reloaded after search to get them back :(  this seems to be an Apple bug
    if (self.searchController.isActive) {
        
        return nil;
        
    } else {
        NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
        if (sectionTitle == nil) {
            return nil;
        }
        CGFloat sectionViewHeight;
        CGFloat sectionViewWidth;
        UIColor *sectionHeaderColor;
        //if there aren't enough for indexing, dispense with the section headers
        if (self.isIndexed) {
            sectionViewHeight = 10;
            sectionViewWidth = tableView.bounds.size.width;
            sectionHeaderColor = [UIColor whiteColor];
        } else {
            sectionViewHeight = 0;
            sectionViewWidth = 0;
        }
        
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionViewWidth, sectionViewHeight)];
        [sectionView setBackgroundColor:sectionHeaderColor];
        //    [sectionView addSubview:label];
        
        return sectionView;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    LogMethod();
    
    if (self.searchController.isActive) {
        
        //    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return 0;
    } else {
        //if there aren't enough for indexing, dispense with the section headers
        if (self.isIndexed) {
            return 10;
        } else {
            return 0;
        }
    }
}


- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
    
    //don't use CollectionItemCell for searchResultsCell won't respond to touches to scroll anyway and terrible performance on return when autoRotated
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *searchResultsCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	CollectionItemCell *cell = (CollectionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"CollectionItemCell"];
    cell.durationLabel.text = @"";
    
    MPMediaQuerySection * sec = self.albumCollectionSections[indexPath.section];
    //    NSLog (@" section is %d", indexPath.section);
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
//140113 1.2 iOS 7 begin
        tableView.backgroundColor = [UIColor blackColor];
//140113 1.2 iOS 7 end
		tableView.rowHeight = 55;

        if ( searchResultsCell == nil ) {
            searchResultsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//140113 1.2 iOS 7 begin
            //            searchResultsCell.selectionStyle = UITableViewCellSelectionStyleGray;
            //            searchResultsCell.selectedBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
//140113 1.2 iOS 7 end
            searchResultsCell.textLabel.font = [UIFont systemFontOfSize:44];
            searchResultsCell.textLabel.textColor = [UIColor whiteColor];
//140113 1.2 iOS 7 begin
            searchResultsCell.backgroundColor = [UIColor blackColor];
			UIView *v = [[UIView alloc] init];
			v.backgroundColor = [UIColor blackColor];
			searchResultsCell.selectedBackgroundView = v;

//140113 1.2 iOS 7 end
            searchResultsCell.textLabel.highlightedTextColor = [UIColor blueColor];
            searchResultsCell.textLabel.lineBreakMode = NSLineBreakByClipping;
            
            DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:[UIColor whiteColor]];
            accessory.highlightedColor = [UIColor blueColor];
            searchResultsCell.accessoryView = accessory;
        }
        NSString *mediaItemName;
        MPMediaItemCollection *searchCollection = [self.searchResults objectAtIndex: indexPath.row];
        
        if ([self.collectionType isEqualToString: @"Playlists"]) {
            MPMediaPlaylist  *mediaPlaylist = [self.searchResults objectAtIndex: indexPath.row];
            mediaItemName = [mediaPlaylist valueForProperty: MPMediaPlaylistPropertyName];
        } else {
            mediaItemName = [[searchCollection representativeItem] valueForProperty: albumMediaItemProperty];
        }
//        NSArray *searchCollectionArray = [searchCollection items];
//        for (MPMediaItem *item in searchCollectionArray) {
//            //            NSLog (@" whatIsThis %@", [[artistCollection representativeItem] valueForProperty: MPMediaItemPropertyAlbumArtist]);
//            NSLog (@" whatIsThis %@", [item valueForProperty: MPMediaPlaylistPropertyName]);
//        }
        searchResultsCell.textLabel.text = mediaItemName;
        
        return searchResultsCell;
        
    } else {
    
//        BOOL emptyArray = NO;
        
        MPMediaItemCollection *currentQueue = [MPMediaItemCollection alloc];
        
        if ([self.collection count] == 0) {
//            emptyArray = YES;
        } else {
            currentQueue = self.collection[sec.range.location + indexPath.row];
        }

        if ([self.collectionType isEqualToString: @"Playlists"]) {
            MPMediaPlaylist  *mediaPlaylist = self.collection[sec.range.location + indexPath.row];
            cell.nameLabel.text = [mediaPlaylist valueForProperty: MPMediaPlaylistPropertyName];
        } else {
            if ([self.collectionType isEqualToString: @"Podcasts"]) {
                cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyPodcastTitle];
            } else {
            cell.durationLabel.text = @"";

            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyAlbumTitle];
            }
        }

        if (cell.nameLabel.text == nil) {
            cell.nameLabel.text = @"Unknown";
        }
        if ([cell.nameLabel.text isEqualToString: @""]) {
            cell.nameLabel.text = @"Unknown";
        }
//        NSLog (@"cell.nameLabel.text is %@", cell.nameLabel.text);
        
        //get the duration of the the playlist
        if (isPortrait) {
            showDuration = NO;
            cell.durationLabel.hidden = YES;
        } else {
            showDuration = YES;
            cell.durationLabel.hidden = NO;
            
            //if the array has been populated in the background at least to the point of the index, then use the table otherwise calculate the playlistDuration here
            if ([collectionDurations count] > (sec.range.location + indexPath.row)) {
                cell.durationLabel.text = collectionDurations[sec.range.location + indexPath.row];
            } else {
                NSNumber *playlistDurationNumber = [self calculatePlaylistDuration: currentQueue];
                long playlistDuration = [playlistDurationNumber longValue];
                
                int playlistMinutes = (int)(playlistDuration / 60);     // Whole minutes
                int playlistSeconds = (playlistDuration % 60);                        // seconds
                cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];
            }
            
        }
            //show accessory if not indexed
            if (self.isIndexed) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
                accessory.highlightedColor = [UIColor blueColor];
                cell.accessoryView = accessory;
            }

        return [self handleCellScrolling: cell inTableView: tableView];
    }
}
- (NSNumber *)calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue {
    
    NSArray *returnedQueue = [currentQueue items];
    
    long playlistDuration = 0;
    long songDuration = 0;
    
    for (MPMediaItem *song in returnedQueue) {
        songDuration = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
        //if the  song has been deleted during a sync then pop to rootViewController
        
        if (songDuration == 0 && self.iPodLibraryChanged) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            NSLog (@"BOOM");
        }
        //        playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
        playlistDuration = (playlistDuration + songDuration);
        
    }
    return [NSNumber numberWithLong: playlistDuration];
}
- (CollectionItemCell *) handleCellScrolling: (CollectionItemCell *) cell inTableView: (UITableView *) tableView {
    //    LogMethod();
    //size of duration Label is set at 130 to match the fixed size that it is set in interface builder
    // note that cell.durationLabel.frame.size.width) = 0 here
    //    NSLog (@"************************************width of durationLabel is %f", cell.durationLabel.frame.size.width);
    
    // if want to make scrollview width flex with width of duration label, need to set it up in code rather than interface builder - not doing that now, but don't see any problem with doing it
    
    //    CGSize durationLabelSize = [cell.durationLabel.text sizeWithFont:cell.durationLabel.font
    //                                                   constrainedToSize:CGSizeMake(135, CGRectGetHeight(cell.durationLabel.bounds))
    //                                                       lineBreakMode:NSLineBreakByClipping];
    //cell.durationLabel.frame.size.width = 130- have to hard code because not calculated yet at this point
    
    //this is the constraint from scrollView to Cell  needs to just handle accessory in portrait and handle duration and accessory in landscape
    
//140113 1.2 iOS 7 begin
    cell.scrollViewToCellConstraint.constant = showDuration ? (0 + 130 + 5) : 5;
//140113 1.2 iOS 7 end
    //    NSLog (@"constraintConstant is %f", cell.scrollViewToCellConstraint.constant);
    
    
    NSUInteger scrollViewWidth;
    
    if (showDuration) {
        //        scrollViewWidth = (tableView.frame.size.width - durationLabelSize.width - cell.accessoryView.frame.size.width);
        scrollViewWidth = (tableView.frame.size.width - 168);
    } else {
        scrollViewWidth = (tableView.frame.size.width - 38);
    }
    [cell.scrollView removeConstraint:cell.centerXInScrollView];
    
    //calculate the label size to fit the text with the font size
//131210 1.2 iOS 7 begin
    
//    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
//                                       constrainedToSize:CGSizeMake(INT16_MAX,cell.frame.size.height)
//                                           lineBreakMode:NSLineBreakByClipping];
    
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:cell.nameLabel.text
                                                                        attributes:@{NSFontAttributeName: cell.nameLabel.font}];
    
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(INT16_MAX, cell.frame.size.height)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize labelSize = rect.size;
    
//131210 1.2 iOS 7 end

    
    //Make sure that label is aligned with scrollView
    [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    cell.scrollView.delegate = cell.scrollView;
    
    //    NSLog (@"labelSize.width is %f and scrollViewWidth is %d", labelSize.width, scrollViewWidth);
    if (labelSize.width>scrollViewWidth) {
        //        cell.scrollView.hidden = NO;
        //        cell.textLabel.hidden = YES;
        cell.scrollView.scrollEnabled = YES;
        //        NSLog (@"%@ is scrollable", cell.nameLabel.text);
        
    }
    else {
        //        cell.scrollView.hidden = YES;
        //        cell.textLabel.hidden = NO;
        cell.scrollView.scrollEnabled = NO;
        
    }
    return cell;
}
//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    //    LogMethod();
    
    if (self.searchController.isActive) {
        
        selectedIndexPath = [((UITableViewController *)self.searchController.searchResultsController).tableView indexPathForSelectedRow];
        
        MPMediaItemCollection *searchCollection = [self.searchResults objectAtIndex: selectedIndexPath.row];
        NSString *mediaItemName;

        if ([self.collectionType isEqualToString: @"Playlists"]) {
//            MPMediaPlaylist  *mediaPlaylist = [searchCollection items];
            mediaItemName = [searchCollection valueForProperty: MPMediaPlaylistPropertyName];
        } else {
            if ([self.collectionType isEqualToString: @"Podcasts"]) {
                mediaItemName = [[searchCollection representativeItem] valueForProperty: MPMediaItemPropertyPodcastTitle];
            } else {                
                mediaItemName = [[searchCollection representativeItem] valueForProperty: MPMediaItemPropertyAlbumTitle];
            }
        }

        selectedName = mediaItemName;
        self.songCollection = searchCollection;
//        selectedQuery = myAlbumQuery;
    } else {
        selectedIndexPath = indexPath;
        CollectionItemCell *cell = (CollectionItemCell*)[tableView cellForRowAtIndexPath:selectedIndexPath];
        selectedName = cell.nameLabel.text;
        MPMediaQuerySection * sec = self.albumCollectionSections[indexPath.section];
        self.songCollection = self.collection[sec.range.location + indexPath.row];
//        selectedQuery = [self.collectionQueryType copy];
//        selectedPredicate = [MPMediaPropertyPredicate predicateWithValue: selectedName
//                                                             forProperty: MPMediaItemPropertyAlbumTitle];
        
    }
    selectedQuery = [self.collectionQueryType copy];
    selectedPredicate = [MPMediaPropertyPredicate predicateWithValue: selectedName
                                                         forProperty: albumMediaItemProperty];
    [selectedQuery addFilterPredicate: selectedPredicate];
    [selectedQuery setGroupingType: MPMediaGroupingTitle];
    
    [self performSegueWithIdentifier: @"ViewSongs" sender: self];
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    LogMethod();
//    NSIndexPath *indexPath = [ self.collectionTableView indexPathForCell:sender];

	if ([segue.identifier isEqualToString:@"ViewAllSongs"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;
        
//        MPMediaQuery *myCollectionQuery = self.collectionQueryType;
        selectedQuery = [self.collectionQueryType copy];

        NSArray *allSongCollection = [selectedQuery items];
        
//        NSMutableArray *allSongMutableArray = [[NSMutableArray alloc] init];
        long playlistDuration = 0;
        
        //        collectionItem.duration = [self calculatePlaylistDuration: [self.collectionDataArray objectAtIndex:indexPath.row]];
//        
//        for (MPMediaItem *song in allSongCollection) {
//            if ([song valueForProperty: MPMediaItemPropertyIsCloudItem]) {
//            }
//            [allSongMutableArray addObject: song];
////                playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
//        }
//        NSArray *songs = allSongCollection;
        NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
        
        // sort the song list into alphabetical order with the nuances of Apple's sorting - see createComparator below
        for (MPMediaItem *song in allSongCollection) {
            NSUInteger newIndex = [songMutableArray indexOfObject:song
                                         inSortedRange:(NSRange){0, [songMutableArray count]}
                                               options:NSBinarySearchingInsertionIndex
                                                  usingComparator: [self createComparator]];
            [songMutableArray insertObject:song atIndex:newIndex];

            playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
    //                NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
    //                NSLog (@"\t\t%@", songTitle);
        }
        
        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.duration = [NSNumber numberWithLong: playlistDuration];
        collectionItem.collectionArray = songMutableArray;
        
//        NSLog (@" albums coolectionItem.collectionArray is %@", collectionItem.collectionArray);
        
        if ([self.collectionType isEqualToString: @"Albums"] || [self.collectionType isEqualToString: @"Compilations"]) {
            songViewController.title = NSLocalizedString(@"Songs", nil);
        } else {
            collectionItem.name = self.title;
            songViewController.title = NSLocalizedString(collectionItem.name, nil);
        }

        songViewController.collectionItem = collectionItem;
        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        songViewController.listIsAlphabetic = YES;
        
        selectedQuery = [self.collectionQueryType copy];
        [selectedQuery setGroupingType: MPMediaGroupingTitle];
        songViewController.collectionQueryType = selectedQuery;
        //130912 1.1 add iTunesStoreButton begin
        if ([self.collectionType isEqualToString: @"Artists"]) {
            //if displaying all songs by one artist, iTunes search will be for Artist
            songViewController.collectionType = @"Artists";
        } else {
            songViewController.collectionType = @"All";
        }
        //130912 1.1 add iTunesStoreButton end

	}
    
	if ([segue.identifier isEqualToString:@"ViewSongs"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;
        
        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = selectedName;
        
        
        NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
        long playlistDuration = 0;
        
        NSArray *allSongCollection = [NSMutableArray arrayWithArray:[self.songCollection items]];

        
        //        collectionItem.duration = [self calculatePlaylistDuration: [self.collectionDataArray objectAtIndex:indexPath.row]];
                
        for (MPMediaItem *song in allSongCollection) {
            [songMutableArray addObject: song];
            playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
        }
        
        collectionItem.duration = [NSNumber numberWithLong: playlistDuration];

//        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[self.songCollection items]];
        collectionItem.collectionArray = songMutableArray;

        
        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        songViewController.listIsAlphabetic = NO;
        songViewController.title = collectionItem.name;        
        songViewController.collectionItem = collectionItem;
        songViewController.collectionQueryType = selectedQuery;
//130912 1.1 add iTunesStoreButton begin
        if ([self.collectionType isEqualToString: @"Artists"]) {
            //going to show song list from album so want to set iTunes store search to album rather than artist
            songViewController.collectionType = @"Albums";
        } else {
            songViewController.collectionType = self.collectionType;
        }
//130912 1.1 add iTunesStoreButton end

//        }
	}
    
    if ([segue.identifier isEqualToString:@"ViewNowPlaying"])
	{
		MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;
        
        mainViewController.playNew = NO;
        mainViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
    }

}
-(NSComparator) createComparator {
//omg this is crazy long, but necessary to make sort results like Apple's
    NSComparator comparator = ^(id obj1, id obj2) {
        NSString *string1 = [obj1 valueForProperty:MPMediaItemPropertyTitle];
        NSString *string2 = [obj2 valueForProperty:MPMediaItemPropertyTitle];
        
        //titles that start with an apostrophe sort without the apostrophe  i.e. 'Tis sorts as Tis
        NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"'("];
        
        BOOL isPunct1 = [unwantedChars characterIsMember:[(NSString*)string1 characterAtIndex:0]];
        BOOL isPunct2 = [unwantedChars characterIsMember:[(NSString*)string2 characterAtIndex:0]];
        if (isPunct1) {
            NSString *newString1 = [string1 substringFromIndex:1];
            string1 = [[NSString alloc] initWithString: newString1];
        }
        if (isPunct2) {
            NSString *newString2 = [string2 substringFromIndex:1];
            string2 = [[NSString alloc] initWithString: newString2];
            
        }
        //titles that start with "The " will sort with the first letter of the second word
        if ([string1 length] > 4) {
            BOOL containsThe1 = [[string1 substringWithRange: NSMakeRange(0,4)] isEqualToString: @"The "];
            if (containsThe1) {
                NSString *newString1 = [string1 substringFromIndex:4];
                string1 = [[NSString alloc] initWithString: newString1];
            }
        }
        if ([string2 length] > 4) {
            BOOL containsThe2 = [[string2 substringWithRange: NSMakeRange(0,4)] isEqualToString: @"The "];
            if (containsThe2) {
                NSString *newString2 = [string2 substringFromIndex:4];
                string2 = [[NSString alloc] initWithString: newString2];
            }
        }
        
        //titles that start with "A " will sort with the first letter of the second word
        if ([string1 length] > 2) {
            BOOL containsA1 = [[string1 substringWithRange: NSMakeRange(0,2)] isEqualToString: @"A "];
            if (containsA1) {
                NSString *newString1 = [string1 substringFromIndex:2];
                string1 = [[NSString alloc] initWithString: newString1];
            }
        }
        if ([string2 length] > 2) {
            BOOL containsA2 = [[string2 substringWithRange: NSMakeRange(0,2)] isEqualToString: @"A "];
            if (containsA2) {
                NSString *newString2 = [string2 substringFromIndex:2];
                string2 = [[NSString alloc] initWithString: newString2];
            }
        }
        
        //titles that start with "An " will sort with the first letter of the second word
        if ([string1 length] > 3) {
            BOOL containsAn1 = [[string1 substringWithRange: NSMakeRange(0,3)] isEqualToString: @"An "];
            if (containsAn1) {
                NSString *newString1 = [string1 substringFromIndex:3];
                string1 = [[NSString alloc] initWithString: newString1];
            }
        }
        if ([string2 length] > 3) {
            BOOL containsAn2 = [[string2 substringWithRange: NSMakeRange(0,3)] isEqualToString: @"An "];
            if (containsAn2) {
                NSString *newString2 = [string2 substringFromIndex:3];
                string2 = [[NSString alloc] initWithString: newString2];
            }
        }
        //make titles that start with a lower case letter sort before the same capital letter titles
        BOOL isLowerCase1 = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[(NSString*)string1 characterAtIndex:0]];
        BOOL isLowerCase2 = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[(NSString*)string2 characterAtIndex:0]];
        
        if (isLowerCase1) {
            NSString *stringy1 = [string1 stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string1  substringToIndex:1] capitalizedString]];
            string1 = [[NSString alloc] initWithString: stringy1];
        }
        if (isLowerCase2) {
            
            NSString *stringy2 = [string2 stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string2  substringToIndex:1] capitalizedString]];
            string2 = [[NSString alloc] initWithString: stringy2];
        }
        //make titles that start with numbers sort after alphabetic titles
        BOOL isNumber1 = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[(NSString*)string1 characterAtIndex:0]];
        BOOL isNumber2 = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[(NSString*)string2 characterAtIndex:0]];
        
        if (isNumber1 && !isNumber2) {
            return NSOrderedDescending;
        } else if (!isNumber1 && isNumber2) {
            return NSOrderedAscending;
        }
        //make titles that start with symbols sort after alphabetic titles
        BOOL isSymbol1 = [[NSCharacterSet symbolCharacterSet] characterIsMember:[(NSString*)string1 characterAtIndex:0]];
        BOOL isSymbol2 = [[NSCharacterSet symbolCharacterSet] characterIsMember:[(NSString*)string2 characterAtIndex:0]];
        
        if (isSymbol1 && !isSymbol2) {
            return NSOrderedDescending;
        } else if (!isSymbol1 && isSymbol2) {
            return NSOrderedAscending;
        }
        return [(NSString *)string1 compare:string2 options:NSCaseInsensitiveSearch];
        
    };
    return comparator;
}

- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
}

#pragma mark Application state management_____________
// Standard methods for managing application state.

//130909 1.1 add iTunesStoreButton begin

- (IBAction)linkToiTunesStore:(id)sender {
    
    self.iTunesLinkUrl = [NSString stringWithFormat: @"%@?%@", self.artistLinkUrl, myAffiliateID];
    //    self.iTunesLinkUrl = [NSString stringWithFormat: @"%@", self.genreLinkUrl];
    
    //    self.ITunesLinkUrl = @"https://itunes.apple.com/us/genre/music-dance/id17";
    //    self.ITunesLinkUrl = @"https://itunes.apple.com/us/genre/id17";
    
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.iTunesLinkUrl]];
    
    NSLog (@"iTunesLink is %@", self.iTunesLinkUrl);
    
}
- (IBAction)allSongsButtonTapped: (id) sender {

	[self performSegueWithIdentifier: @"ViewAllSongs" sender: self];
}
//130909 1.1 add iTunesStoreButton end
- (void) registerForMediaPlayerNotifications {
    //    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
//    [notificationCenter addObserver: self
//                           selector: @selector(receiveSearchingNotification:)
//                               name: @"Searching"
//                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector(receiveCellScrolledNotification:)
                               name: @"CellScrolled"
                             object: nil];
    
    [notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_iPodLibraryChanged:)
                               name: MPMediaLibraryDidChangeNotification
                             object: nil];
    
//    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    [musicPlayer beginGeneratingPlaybackNotifications];
    
}

- (void) receiveCellScrolledNotification:(NSNotification *) notification
{
//    LogMethod();
    if ([[notification name] isEqualToString:@"CellScrolled"]) {
        self.cellScrolled = YES;
    }
}
//- (void) receiveSearchingNotification:(NSNotification *) notification
//{
//    //    LogMethod();
//    if ([[notification name] isEqualToString:@"Searching"]) {
//        disableRotation = YES;
//    }
//}

- (void) handle_iPodLibraryChanged: (id) changeNotification {
    //    LogMethod();
	// Implement this method to update cached collections of media items when the
	// user performs a sync while application is running.
    [self setIPodLibraryChanged: YES];
    
}
// When the playback state changes, if stopped remove nowplaying button
- (void) handle_PlaybackStateChanged: (id) notification {
//    LogMethod();
    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
    if (playbackState == MPMusicPlaybackStateStopped) {
        self.navigationItem.rightBarButtonItem= nil;
	}
    
}
- (void)dealloc {
    //    LogMethod();
   
//    [[NSNotificationCenter defaultCenter] removeObserver: self
//                                                    name: @"Searching"
//                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: @"CellScrolled"
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMediaLibraryDidChangeNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
//    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
	
    
}
@end
