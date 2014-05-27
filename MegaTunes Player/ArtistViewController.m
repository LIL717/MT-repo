//
//  CollectionViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//
//130911 1.1 add iTunesStoreButton begin
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//130911 1.1 add iTunesStoreButton end
#import "ArtistViewController.h"
#import "CollectionItemCell.h"
#import "CollectionItem.h"
#import "SongViewController.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"
#import "InCellScrollView.h"
#import "AlbumViewController.h"
#import "MTSearchBar.h"


@interface ArtistViewController ()
    @property (nonatomic, strong) NSArray * artistCollectionSections;
    @property (nonatomic, strong) NSArray * artistCollectionSectionTitles;
@end

@implementation ArtistViewController

@synthesize collectionTableView;
@synthesize allAlbumsView;
@synthesize allAlbumsButton;
@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize collection;
@synthesize collectionType;
@synthesize collectionQueryType;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize isSearching;
@synthesize isIndexed;
@synthesize musicPlayer;
@synthesize albumCollection;
@synthesize rightBarButton;
@synthesize searchResults;
@synthesize cellScrolled;

//130912 1.1 add iTunesStoreButton begin
@synthesize moreGenreButton;

@synthesize iTunesStoreSelector;
@synthesize genreLinkUrl;
@synthesize locale;
@synthesize countryCode;
@synthesize genreNameFormatted;
@synthesize albumNameFormatted;
@synthesize artistNameFormatted;
@synthesize songNameFormatted;
@synthesize iTunesLinkUrl;

NSString *myAffiliateID;

//130912 1.1 add iTunesStoreButton end


NSMutableArray *collectionDurations;
NSIndexPath *selectedIndexPath;
NSString *selectedName;
NSString *searchMediaItemProperty;
CGFloat constraintConstant;
UIImage *backgroundImage;
MPMediaQuery *selectedQuery;
MPMediaQuery *artistQuery;
MPMediaPropertyPredicate *selectedPredicate;

BOOL showDuration;
BOOL firstLoad;
//131203 1.2 iOS 7 begin
//BOOL viewIsAppearing;
//131203 1.2 iOS 7 end

#pragma mark - Initial Display methods

- (void) viewDidLoad {
    
    [super viewDidLoad];
//    LogMethod();
    
    firstLoad = YES;
    //set up an array of durations to be used in landscape mode
    collectionDurations = [[NSMutableArray alloc] initWithCapacity: [self.collection count]];

    if ([self.collection count] > 0) {
        //create the array in the background
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // Perform async operation
            [self createDurationArray];
        });
    }
//131203 1.2 iOS 7 begin
    self.navigationController.navigationBar.topItem.title = @"";
    //set the navigation bar title
    self.navigationItem.titleView = [self customizeTitleView];
    
    //need this for correct placement and touch access in landscape on rotation in iOS 7
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//140127 1.2 iOS 7 end
    
    [self.rightBarButton setIsAccessibilityElement:YES];
    [self.rightBarButton setAccessibilityLabel: NSLocalizedString(@"Now Playing", nil)];
    [self.rightBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    self.cellScrolled = NO;
    
    self.allAlbumsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 110)];
    self.searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width - 15, 55)];
//    self.searchBar.barTintColor = [UIColor darkGrayColor];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed: @"searchBarBackground"] forState: UIControlStateNormal];
    
//    - (void)setImage:(UIImage *)iconImage forSearchBarIcon:(UISearchBarIcon)icon state:(UIControlState)state NS_AVAILABLE_IOS(5_0)
    self.searchBar.backgroundImage = [UIImage imageNamed:@"searchBarBackground"];
//    self.searchBar = [[MTSearchBar alloc] init];
//    self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width - 15, 55);
    [self.searchBar setTranslatesAutoresizingMaskIntoConstraints: YES];
    self.searchBar.delegate = self;
    
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.delegate = self;
    
    self.allAlbumsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 55.0, self.view.bounds.size.width, 55);
    self.allAlbumsButton.frame = frame;
    self.allAlbumsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.allAlbumsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    [self.allAlbumsButton setTitleColor:  [UIColor whiteColor] forState: UIControlStateNormal];
    [self.allAlbumsButton setTitleColor:  [UIColor blueColor] forState: UIControlStateHighlighted];
    [self.allAlbumsButton setTitle: NSLocalizedString(@"All Albums", nil) forState:UIControlStateNormal];
        [self.allAlbumsButton.titleLabel setFont: [UIFont systemFontOfSize: 44]];
    //remember to add a segue to viewController for this action
    [self.allAlbumsButton addTarget:self action:@selector(allAlbumsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.allAlbumsView addSubview: self.allAlbumsButton];
    [self.allAlbumsView addSubview: self.searchBar];

    self.collectionTableView.tableHeaderView = self.allAlbumsView;

    self.collectionTableView.sectionIndexMinimumDisplayRowCount = 20;
//131203 1.2 iOS 7 begin
    
    [self.collectionTableView setSectionIndexColor:[UIColor whiteColor]];
    [self.collectionTableView setSectionIndexBackgroundColor:[UIColor blackColor]];
    
//131203 1.2 iOS 7 end

    if ([self.collection count] >= self.collectionTableView.sectionIndexMinimumDisplayRowCount) {
        isIndexed = YES;
    } else {
        isIndexed = NO;
    }
    
    // format of collectionSections is <MPMediaQuerySection: 0x1cd34c80> title=B, range={0, 5}, sectionIndexTitleIndex=1,

    self.artistCollectionSections = [self.collectionQueryType collectionSections];
    
    NSMutableArray * titles = [NSMutableArray arrayWithCapacity:[self.artistCollectionSections count]];
    for (MPMediaQuerySection * sec in self.artistCollectionSections) {
        [titles addObject:sec.title];
    }
    self.artistCollectionSectionTitles = [titles copy];
    


//    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
//130912 1.1 add iTunesStoreButton begin
    if ([self.collectionType isEqualToString: @"Genres"]) {
        //get the affliate ID
        myAffiliateID = [[NSUserDefaults standardUserDefaults] stringForKey:@"affiliateID"];
        //show the More button for iTunes
        [self establishITunesLink];
        self.moreGenreButton.hidden = YES;
        [self.moreGenreButton addTarget:self action:@selector(linkToiTunesStore:)  forControlEvents:UIControlEventTouchUpInside];
        
        [self.moreGenreButton setIsAccessibilityElement:YES];
        [self.moreGenreButton setAccessibilityLabel: NSLocalizedString(@"ITunesStore", nil)];
        [self.moreGenreButton setAccessibilityTraits: UIAccessibilityTraitButton];
        [self.moreGenreButton setAccessibilityHint: NSLocalizedString(@"View more in this genre.", nil)];
    } else {
        self.moreGenreButton.hidden = YES;
    }
//130912 1.1 add iTunesStoreButton end

}
//130911 1.1 add iTunesStoreButton begin
//fetch the iTunes link info in the background
- (void) establishITunesLink {
    self.locale = [NSLocale currentLocale];
    self.countryCode = [self.locale objectForKey: NSLocaleCountryCode];

    
    //get itunes link for genre which is the title of this view
    
    self.genreNameFormatted = [self.title stringByReplacingOccurrencesOfString:@" "
                                                                    withString:@"+"];
    NSString *iTunesSearchString = [NSString stringWithFormat: @"https://itunes.apple.com/WebObjects/MZStoreServices.woa/ws/genres"];
    
    NSURL *iTunesSearchURL = [NSURL URLWithString: iTunesSearchString];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        iTunesSearchURL];
        [self performSelectorOnMainThread:@selector(fetchedGenre:)
                               withObject:data waitUntilDone:YES];
    });
    
}
//130911 1.1 add iTunesStoreButton end
- (void) createDurationArray {

    for (MPMediaItemCollection* currentQueue in self.collection) {

        //get the duration of the the playlist
            
        NSNumber *playlistDurationNumber = [self calculatePlaylistDuration: currentQueue];
        long playlistDuration = [playlistDurationNumber longValue];
        
        int playlistMinutes = (playlistDuration / 60);     // Whole minutes
        int playlistSeconds = (playlistDuration % 60);                        // seconds
        NSString *itemDuration = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];
        [collectionDurations addObject: itemDuration];

    }
}
//130911 1.1 add iTunesStoreButton begin

- (void)fetchedGenre:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    self.genreLinkUrl = nil;
    
    if (responseData) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              
                              options:kNilOptions
                              error:&error];
        //music is 34
        NSDictionary* musicCategory = [json objectForKey: @"34"];
        if ([musicCategory count] >0) {
//            
//            NSLog (@"musicCategory %@", musicCategory);//this is everything with id=34
//            NSLog (@"MgenreID %@, MgenreName %@", [musicCategory objectForKey: @"id"], [musicCategory objectForKey: @"name"]);
            
            NSDictionary *genres = [musicCategory objectForKey: @"subgenres"];
//            NSDictionary *genres = @"20" : @"Alternative",

            [genres enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                NSString *genreID = key;
                NSDictionary *genreDictionary = obj;
                NSString *genreName = [genreDictionary objectForKey: @"name"];
//                NSLog(@"Genre %@ is %@.",genreID, genreName);

                if ([genreName isEqualToString: self.title]) {
                    self.genreLinkUrl = [NSString stringWithFormat: @"https://itunes.apple.com/%@/genre/id%@", self.countryCode, [genreDictionary objectForKey: @"id"]];
                    *stop = YES;
                }
                NSDictionary *subGenres = [genreDictionary objectForKey: @"subgenres"];
                                           
                [subGenres enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                    NSString *subGenreID = key;
                    NSDictionary *subGenreDictionary = obj;
                    NSString *subGenreName = [subGenreDictionary objectForKey: @"name"];
//                    NSLog(@"SubGenre %@ is %@.", subGenreID, subGenreName);
                    
                    if ([subGenreName isEqualToString: self.title]) {
                        self.genreLinkUrl = [NSString stringWithFormat: @"https://itunes.apple.com/%@/genre/id%@", self.countryCode, [subGenreDictionary objectForKey: @"id"]];
                        *stop = YES;
                    }
                }];
            }];
        }
    }
    
    if (self.genreLinkUrl) {
        self.moreGenreButton.hidden = NO;
    }
    NSLog (@"genreLinkUrl is %@", self.genreLinkUrl);
    
}
//130911 1.1 add iTunesStoreButton end

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
                CollectionItemCell *cell = (CollectionItemCell *)[self.collectionTableView cellForRowAtIndexPath:indexPath];
                [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        }
        self.cellScrolled = NO;
    }
    [self updateLayoutForNewOrientation: self.interfaceOrientation];

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

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
//    LogMethod();
    [self updateLayoutForNewOrientation: orientation];
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
//    LogMethod();
    
//131216 1.2 iOS 7 begin
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);

    CGFloat navBarAdjustment = isPortrait ? 0 : 9;

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
    if (!self.isSearching) {

        BOOL firstRowVisible = NO;
        
        //visibleRows is always 0 the first time through here for a table, populated after that
        if (firstLoad) {
            firstLoad = NO;
            [self.allAlbumsView addSubview: self.searchBar];
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
        CGFloat tableViewHeaderHeight = self.allAlbumsView.frame.size.height;
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
}
- (void) viewWillLayoutSubviews {
//    LogMethod();
        //need this to pin portrait view to bounds otherwise if start in landscape, push to next view, rotate to portrait then pop back the original view in portrait - it will be too wide and "scroll" horizontally
    self.collectionTableView.contentSize = CGSizeMake(self.collectionTableView.frame.size.width, self.collectionTableView.contentSize.height);
    [super viewWillLayoutSubviews];
}
//140113 1.2 iOS 7 begin
//just can't get this to work consistently
//-(void) viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    
//    NSInteger possibleRows = self.collectionTableView.frame.size.height / self.collectionTableView.rowHeight;
//    ////        NSLog (@"possibleRows = %d collection count = %d", possibleRows, [self.collection count]);
//    
//    //if the table won't fill the screen need to update here for tableView header to hide properly - so ugly
//    if (firstLoad && [self.collection count] <= possibleRows && viewIsAppearing) {
//        
//        //this is only necessary when screen will not be filled - this method is executed afterDelay because ContentOffset is probably not correct until after layoutSubviews happens
//        
////        NSLog (@"tableView content size is %f %f",self.collectionTableView.contentSize.height, self.collectionTableView.contentSize.width);
//        
//        BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
//        
//        CGFloat largeHeaderAdjustment = isPortrait ? 11 : 11;
//        
//        CGFloat tableViewHeaderHeight = self.allAlbumsView.frame.size.height;
//        
//        [self.collectionTableView setContentOffset:CGPointMake(0, tableViewHeaderHeight - largeHeaderAdjustment)];
//        
//        [self.collectionTableView reloadData];
//        
//        firstLoad = NO;
//        viewIsAppearing = NO;
//    }
//
//}
//140113 1.2 iOS 7 end
#pragma mark - Search Display methods

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    LogMethod();
    self.isSearching = YES;
    CGRect newFrame = self.searchBar.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = 0;
    newFrame.size.height = 55;
    newFrame.size.width = self.view.bounds.size.width;
    self.searchBar.frame = newFrame;

}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
//    LogMethod();
    //this needs to be here rather than DidEndSearch to avoid flashing wrong data first

//    [self.collectionTableView reloadData];
    [self.searchBar removeFromSuperview];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    LogMethod();
    self.isSearching = NO;
    //reload the original tableView otherwise section headers are not visible :(  this seems to be an Apple bug

    self.collectionTableView.tableHeaderView = self.allAlbumsView;
    self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width - 15, 55);
    [self.allAlbumsView addSubview:self.searchBar];

    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat navBarAdjustment = isPortrait ? 0 : 9;

    // hide the search bar and All Albums cell
    CGFloat tableViewHeaderHeight = self.allAlbumsView.frame.size.height;
    CGFloat adjustedHeaderHeight = tableViewHeaderHeight - navBarAdjustment;

    [self.collectionTableView setContentOffset:CGPointMake(0, adjustedHeaderHeight)];
    [self.collectionTableView reloadData];
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    LogMethod();
    searchMediaItemProperty = [[NSString alloc] init];
    
    artistQuery = [[MPMediaQuery alloc] init];
    artistQuery = [self.collectionQueryType copy];
    
//    MPMediaGrouping mediaGrouping = MPMediaGroupingAlbumArtist;
    
    if ([self.collectionType isEqualToString: @"Artists"] || [self.collectionType isEqualToString: @"Genres"]) {
        searchMediaItemProperty = MPMediaItemPropertyAlbumArtist;
//        mediaGrouping = MPMediaGroupingAlbumArtist;
    } else {
        if ([self.collectionType isEqualToString: @"Composers"]) {
            searchMediaItemProperty = MPMediaItemPropertyComposer;
//            mediaGrouping = MPMediaGroupingComposer;
        }
    }
    MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue: searchText
                                                                                     forProperty: searchMediaItemProperty
                                                                                  comparisonType:MPMediaPredicateComparisonContains];

    

//    [artistQuery setGroupingType: mediaGrouping];
    [artistQuery addFilterPredicate: filterPredicate];
    
//    if ([self.collectionType isEqualToString: @"Genres"]) {
//        [myArtistQuery addFilterPredicate: [MPMediaPropertyPredicate
//                                                predicateWithValue: self.title
//                                                forProperty: MPMediaItemPropertyGenre]];
//    }  //I think this is already included in the query when come from genre
    
    searchResults = [artistQuery collections];
    //
    //    NSPredicate *resultPredicate = [NSPredicate
    //                                    predicateWithFormat:@"SELF contains[cd] %@",
    //                                    searchText];
    //
    //    searchResults = [self.collection filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString

{
//    LogMethod();
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}
-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
//    LogMethod();
    self.searchDisplayController.searchResultsTableView.rowHeight = 55;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return [self.artistCollectionSections count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    LogMethod();

    MPMediaQuerySection * sec = nil;
    sec = self.artistCollectionSections[section];
    return sec.title;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//    LogMethod();
    if (tableView == self.searchDisplayController.searchResultsTableView) {

            return nil;
    } else {

    return [[NSArray arrayWithObject:@"{search}"] arrayByAddingObjectsFromArray:self.artistCollectionSectionTitles];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {

//        NSLog (@" searchResults count is %d", [searchResults count]);
        return [searchResults count];
    } else {
        MPMediaQuerySection * sec = self.artistCollectionSections[section];
        return sec.range.length;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    LogMethod();
        //this must be nil or the section headers of the original tableView are awkwardly visible
        // original table must be reloaded after search to get them back :(  this seems to be an Apple bug
    if (self.isSearching) {

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
        if (isIndexed) {
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

    if (self.isSearching) {

//    if (tableView == self.searchDisplayController.searchResultsTableView) {

        return 0;
    } else {
        //if there aren't enough for indexing, dispense with the section headers
        if (isIndexed) {
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

    MPMediaQuerySection * sec = self.artistCollectionSections[indexPath.section];
//    NSLog (@" section is %d", indexPath.section);

    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);

    if (tableView == self.searchDisplayController.searchResultsTableView) {
//140113 1.2 iOS 7 begin
        tableView.backgroundColor = [UIColor blackColor];
//140113 1.2 iOS 7 end

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
//140113 1.2 iOS 7 end
            searchResultsCell.textLabel.highlightedTextColor = [UIColor blueColor];
            searchResultsCell.textLabel.lineBreakMode = NSLineBreakByClipping;
            
            DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:[UIColor whiteColor]];
            accessory.highlightedColor = [UIColor blueColor];
            searchResultsCell.accessoryView = accessory;
        }

        MPMediaItemCollection *searchCollection = [searchResults objectAtIndex: indexPath.row];
        NSString *mediaItemName = [[searchCollection representativeItem] valueForProperty: searchMediaItemProperty];

        searchResultsCell.textLabel.text = mediaItemName;

        return searchResultsCell;

////        NSArray *searchCollectionArray = [searchCollection items];
////        for (MPMediaItem *item in searchCollectionArray) {
//////            NSLog (@" whatIsThis %@", [[artistCollection representativeItem] valueForProperty: MPMediaItemPropertyAlbumArtist]);
////            NSLog (@" whatIsThis %@", [item valueForProperty: MPMediaItemPropertyAlbumArtist]);
////
////        }

    } else {

        MPMediaItemCollection * currentQueue = self.collection[sec.range.location + indexPath.row];

        if ([self.collectionType isEqualToString: @"Artists"]) {
            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyAlbumArtist];
        }
        if ([self.collectionType isEqualToString: @"Composers"]) {
            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyComposer];
        }
        if ([self.collectionType isEqualToString: @"Genres"]) {
            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyAlbumArtist];
        }
//        if ([self.collectionType isEqualToString: @"Podcasts"]) {
//            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyPodcastTitle];
//        }
        if (cell.nameLabel.text == nil) {
            cell.nameLabel.text = @"Unknown";
        }
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
                
                int playlistMinutes = (playlistDuration / 60);     // Whole minutes
                int playlistSeconds = (playlistDuration % 60);                        // seconds
                cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];
            }

        }
        
        //show accessory if not indexed
        if (isIndexed) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
            accessory.highlightedColor = [UIColor blueColor];
            cell.accessoryView = accessory;
        }

        //this works because setFrame is subclassed in CollectionItemCell to move offset for grouped cells so they will line up with scrollview cells
        //set the textLabel to the same thing - it is used if the text does not need to scroll
//        cell.textLabel.font = [UIFont systemFontOfSize:44];
//        cell.textLabel.textColor = [UIColor whiteColor];
//        cell.textLabel.highlightedTextColor = [UIColor blueColor];
//        cell.textLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"list-backwseparator.png"]];
//        cell.textLabel.lineBreakMode = NSLineBreakByClipping;
//        cell.textLabel.text = cell.nameLabel.text;
        

        //size of duration Label is set at 130 to match the fixed size that it is set in interface builder
        // note that cell.durationLabel.frame.size.width) = 0 here
        //    NSLog (@"************************************width of durationLabel is %f", cell.durationLabel.frame.size.width);

        // if want to make scrollview width flex with width of duration label, need to set it up in code rather than interface builder - not doing that now, but don't see any problem with doing it
        
    //    CGSize durationLabelSize = [cell.durationLabel.text sizeWithFont:cell.durationLabel.font
    //                                                   constrainedToSize:CGSizeMake(135, CGRectGetHeight(cell.durationLabel.bounds))
    //                                                       lineBreakMode:NSLineBreakByClipping];
        //cell.durationLabel.frame.size.width = 130- have to hard code because not calculated yet at this point
        
        //this is the constraint from scrollView to Cell  needs to just handle accessory in portrait and handle duration and accessory in landscape
//        constraintConstant = isPortrait ? 30 : (30 + 130 + 5);

//        NSLog (@"constraintConstant is %f", constraintConstant);

        return [self handleCellScrolling: cell inTableView: tableView];


    }
}
- (NSNumber *)calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue {
//    LogMethod();
    NSArray *returnedQueue = [currentQueue items];
    
    long playlistDuration = 0;
    long songDuration = 0;

    for (MPMediaItem *song in returnedQueue) {
        songDuration = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
        
//        //if the  song has been deleted during a sync then pop to rootViewController

        if (songDuration == 0 && self.iPodLibraryChanged) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            NSLog (@"BOOM");
        }
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
        scrollViewWidth = (tableView.frame.size.width - 166);
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
    
    //if there is more than one album, display albums, otherwise display songs in the album in song order

    if ([self.searchDisplayController isActive]) {

        selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];

//        MPMediaItemCollection *searchCollection = [searchResults objectAtIndex: selectedIndexPath.row];
        MPMediaItemCollection *searchCollection = [searchResults objectAtIndex: selectedIndexPath.row];

        NSString *mediaItemName = [[searchCollection representativeItem] valueForProperty: searchMediaItemProperty];
        selectedName = mediaItemName;
//        selectedQuery = artistQuery;
//        self.albumCollection = [searchCollection items];
    } else {
        selectedIndexPath = indexPath;
        CollectionItemCell *cell = (CollectionItemCell*)[tableView cellForRowAtIndexPath:selectedIndexPath];
        selectedName = cell.nameLabel.text;
        NSLog (@" name is %@", cell.nameLabel.text);
    }
    
    NSString *mediaItemProperty = [[NSString alloc] init];
    
    if ([self.collectionType isEqualToString: @"Artists"] || [self.collectionType isEqualToString: @"Genres"]) {
        mediaItemProperty = MPMediaItemPropertyAlbumArtist;
//130912 1.1 add iTunesStoreButton begin
        self.collectionType = @"Artists";
//130912 1.1 add iTunesStoreButton end
    } else {
        if ([self.collectionType isEqualToString: @"Composers"]) {
            mediaItemProperty = MPMediaItemPropertyComposer;
        }
    }
    selectedQuery = [self.collectionQueryType copy];
    selectedPredicate = [MPMediaPropertyPredicate predicateWithValue: selectedName
                                                             forProperty: mediaItemProperty];
        
    [selectedQuery addFilterPredicate: selectedPredicate];
    
//
//    if ([self.collectionType isEqualToString: @"Genres"]) {
//        [newCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
//                                                predicateWithValue: self.title
//                                                forProperty: MPMediaItemPropertyGenre]];
//    }
    // Sets the grouping type for the media query
    [selectedQuery setGroupingType: MPMediaGroupingAlbum];
    
    self.albumCollection = [selectedQuery collections];
    
    NSLog (@" albumCollection passed to albumViewController is %@", self.albumCollection);
    

    if ([self.albumCollection count] > 1) {
        [self performSegueWithIdentifier: @"AlbumCollections" sender: self];
    } else {
        [selectedQuery setGroupingType: MPMediaGroupingTitle];
        [self performSegueWithIdentifier: @"ViewSongs" sender: self];
    }
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();
//    NSIndexPath *indexPath = [ self.collectionTableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"ViewAllAlbums"])
	{
		AlbumViewController *albumViewController = segue.destinationViewController;
        albumViewController.managedObjectContext = self.managedObjectContext;
                
        selectedQuery = [self.collectionQueryType copy];

//        if ([self.collectionType isEqualToString: @"Genres"]) {
//            
//            [myCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
//                                                    predicateWithValue: self.title
//                                                    forProperty: MPMediaItemPropertyGenre]];
//            // Sets the grouping type for the media query
            [selectedQuery setGroupingType: MPMediaGroupingAlbum];
//        } else {
//            myCollectionQuery = [MPMediaQuery albumsQuery];
//        }
        
		albumViewController.collection = [selectedQuery collections];;
        albumViewController.collectionType = @"Albums";
        albumViewController.collectionQueryType = selectedQuery;
        albumViewController.title = NSLocalizedString(@"Albums", nil);
        albumViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        albumViewController.collectionPredicate = nil;

        
	}
    //this is called if there is only one album - the songs for that album are displayed in track order
	if ([segue.identifier isEqualToString:@"ViewSongs"])
	{

        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;

        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = selectedName;
        
        NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
        long playlistDuration = 0;
//        collectionItem.duration = [self calculatePlaylistDuration: [self.collectionDataArray objectAtIndex:indexPath.row]];
        NSArray *songs = [[self.albumCollection objectAtIndex:0] items];
        
        for (MPMediaItem *song in songs) {
            [songMutableArray addObject: song];
            playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
        }
//        collectionItem.collectionArray = [self.albumCollection objectAtIndex:0];
        collectionItem.duration = [NSNumber numberWithLong: playlistDuration];
        
        
        //        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[[self.collectionDataArray objectAtIndex:indexPath.row] items]];
//        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[[self.albumCollection objectAtIndex:0] items]];
        collectionItem.collectionArray = [NSMutableArray arrayWithArray: songMutableArray];


        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        songViewController.listIsAlphabetic = NO;
        
        songViewController.title = collectionItem.name;
//        NSLog (@"collectionItem.name is %@", collectionItem.name);

        songViewController.collectionItem = collectionItem;
        songViewController.collectionQueryType = selectedQuery;
//130912 1.1 add iTunesStoreButton begin
        songViewController.collectionType = self.collectionType;
//130912 1.1 add iTunesStoreButton end

	}
    if ([segue.identifier isEqualToString:@"AlbumCollections"])
	{
        AlbumViewController *albumViewController = segue.destinationViewController;
        albumViewController.managedObjectContext = self.managedObjectContext;
        
        albumViewController.title = selectedName;
        albumViewController.collection = self.albumCollection;
        albumViewController.collectionType = self.collectionType;
        albumViewController.collectionQueryType = selectedQuery;
        albumViewController.collectionPredicate = selectedPredicate;

        
        albumViewController.iPodLibraryChanged = self.iPodLibraryChanged;
	}
    if ([segue.identifier isEqualToString:@"ViewNowPlaying"])
	{
		MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;

        mainViewController.playNew = NO;
        mainViewController.iPodLibraryChanged = self.iPodLibraryChanged;

    }
}
- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
}

#pragma mark Application state management_____________
// Standard methods for managing application state.

//// this subclassed to prevent scrollView from intrepretting half a tap as a tap (turning cell blue but not actually selecting until next selection
//- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
//{
//    LogMethod();
//    
//    CGPoint currentTouchPosition=[gesture locationInView:self.collectionTableView];
//    NSIndexPath *indexPath = [self.collectionTableView indexPathForRowAtPoint: currentTouchPosition];
//    CollectionItemCell *cell = (CollectionItemCell *)[self.collectionTableView cellForRowAtIndexPath:indexPath];
//    cell.nameLabel.highlighted = YES;
//
//    [self.collectionTableView.delegate tableView:self.collectionTableView didSelectRowAtIndexPath:indexPath];
//    [self performSegueWithIdentifier: @"ViewSongs" sender: [self.collectionTableView cellForRowAtIndexPath:indexPath]];
//}
//130909 1.1 add iTunesStoreButton begin

- (IBAction)linkToiTunesStore:(id)sender {
    
    self.iTunesLinkUrl = [NSString stringWithFormat: @"%@?%@", self.genreLinkUrl, myAffiliateID];
//    self.iTunesLinkUrl = [NSString stringWithFormat: @"%@", self.genreLinkUrl];

//    self.ITunesLinkUrl = @"https://itunes.apple.com/us/genre/music-dance/id17";
//    self.ITunesLinkUrl = @"https://itunes.apple.com/us/genre/id17";


    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.iTunesLinkUrl]];
    
    NSLog (@"iTunesLink is %@", self.iTunesLinkUrl);
    
}
- (IBAction)allAlbumsButtonTapped {
    
    [self performSegueWithIdentifier: @"ViewAllAlbums" sender: self];
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
    
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
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
//        
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

    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];

}
- (void)didReceiveMemoryWarning {
        
    [super didReceiveMemoryWarning];
	

}
@end
