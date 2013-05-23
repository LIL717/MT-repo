//
//  AlbumViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 3/25/13.
//
//


#import "AlbumViewController.h"
#import "CollectionItemCell.h"
#import "CollectionItem.h"
#import "SongViewController.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"
#import "InCellScrollView.h"


@interface AlbumViewController ()
@property (nonatomic, strong) NSArray * albumCollectionSections;
@property (nonatomic, strong) NSArray * albumCollectionSectionTitles;
@end

@implementation AlbumViewController

@synthesize collectionTableView;
@synthesize allSongsView;
@synthesize allSongsButton;
@synthesize searchBar;
@synthesize collection;
@synthesize collectionType;
@synthesize collectionQueryType;
@synthesize managedObjectContext;
//@synthesize saveIndexPath;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize musicPlayer;
@synthesize showAllSongsCell;
@synthesize isIndexed;
@synthesize isSearching;
@synthesize songCollection;
@synthesize rightBarButton;
@synthesize searchResults;
@synthesize collectionPredicate;

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


BOOL cellScrolled;
BOOL showDuration;
//UIActivityIndicatorView *spinner;
#pragma mark - Initial Display methods

- (void) viewDidLoad {
    
    [super viewDidLoad];
    //    LogMethod();
    
    //set up an array of durations to be used in landscape mode
    collectionDurations = [[NSMutableArray alloc] initWithCapacity: [self.collection count]];
    NSLog (@" count of collection array %d", [self.collection count]);

    if ([self.collection count] > 0) {
        //create the array in the background
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // Perform async operation
            [self createDurationArray];
        });
    }
    //set up grouped table view to look like plain (so that section headers won't stick to top)
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    self.collectionTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]];
    self.collectionTableView.opaque = NO;
    self.collectionTableView.backgroundView = nil; // THIS ONE TRIPPED ME UP!
    backgroundImage = [UIImage imageNamed: @"list-background.png"];
    
    self.navigationItem.hidesBackButton = YES; // Important
    //initWithTitle cannot be nil, must be @""
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBackClick)];
    
    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(viewNowPlaying)];
    
    UIImage *menuBarImageDefault = [[UIImage imageNamed:@"redWhitePlay57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"redWhitePlay68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.rightBarButton setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.rightBarButton setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    cellScrolled = NO;
    
    self.showAllSongsCell = YES;

    if ([self.collectionType isEqualToString: @"Playlists"]) {
        self.showAllSongsCell = NO;
    }
    
    if ([self.collectionType isEqualToString: @"Podcasts"]) {
        self.showAllSongsCell = NO;
    }

    if (showAllSongsCell) {
        self.allSongsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.allSongsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        [self.allSongsButton setTitleColor:  [UIColor blueColor] forState: UIControlStateHighlighted];
    } else {
        self.allSongsButton.hidden = YES;
        CGRect frame = self.allSongsView.frame;
        frame.size.height = 55;
        self.allSongsView.frame = frame;
    }
    self.collectionTableView.sectionIndexMinimumDisplayRowCount = 20;
    
    if ([self.collection count] > self.collectionTableView.sectionIndexMinimumDisplayRowCount) {
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
    
    NSLog (@"albumCollectionSections %@", self.albumCollectionSections);
    NSLog (@"collection %@", self.collection);
    NSLog (@"albumCollectionSectionTitles %@", self.albumCollectionSectionTitles);
    
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

}
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
- (void) viewWillAppear:(BOOL)animated
{
    LogMethod();
    [super viewWillAppear: animated];
    
    self.navigationItem.titleView = [self customizeTitleView];
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (playingItem) {
        //initWithTitle cannot be nil, must be @""
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    //    // if rows have been scrolled, they have been added to this array, so need to scroll them back to 0
    //    YAY this works!!
    if (cellScrolled) {
        for (NSIndexPath *indexPath in [self.collectionTableView indexPathsForVisibleRows]) {
            if (indexPath.row > 0) {
//                NSLog (@" indexPath to scroll %@", indexPath);
                CollectionItemCell *cell = (CollectionItemCell *)[self.collectionTableView cellForRowAtIndexPath:indexPath];
                [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }
        }
        cellScrolled = NO;
    }
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
    return;
}
-(void) viewDidAppear:(BOOL)animated {
    //    LogMethod();
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super viewDidAppear:(BOOL)animated];
}
- (UILabel *) customizeTitleView
{
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
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
    
    [self updateLayoutForNewOrientation: orientation];
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    //    LogMethod();
    CGFloat navBarAdjustment;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        navBarAdjustment = 11;
        [self.collectionTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
    } else {
        navBarAdjustment = 23;
        [self.collectionTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
    }
        //don't need to do this if the search table is showing
    if (!self.isSearching) {
        
        BOOL firstRowVisible = NO;
        //visibleRows is always 0 the first time through here for a table, populated after that
        NSArray *visibleRows = [self.collectionTableView indexPathsForVisibleRows];
        NSIndexPath *index = [visibleRows objectAtIndex: 0];
        if (index.section == 0 && index.row == 0) {
            firstRowVisible = YES;
        }
        
        // hide the search bar and All Albums cell
        CGFloat tableViewHeaderHeight = self.allSongsView.frame.size.height;
        CGFloat adjustedHeaderHeight = tableViewHeaderHeight - navBarAdjustment;
        NSInteger possibleRows = self.collectionTableView.frame.size.height / self.collectionTableView.rowHeight;
        //        NSLog (@"possibleRows = %d collection count = %d", possibleRows, [self.collection count]);
        
        //if the table won't fill the screen need to wait for delay in order for tableView header to hide properly - so ugly
        if ([self.collection count] <= possibleRows) {
            [self performSelector:@selector(updateContentOffset) withObject:nil afterDelay:0.0];
        } else {
            if (firstRowVisible) {
                //        [self.collectionTableView scrollRectToVisible:CGRectMake(0, adjustedHeaderHeight, 1, 1) animated:NO];
                [self.collectionTableView setContentOffset:CGPointMake(0, adjustedHeaderHeight)];
            }
        }
        
        [self.collectionTableView reloadData];
    }
    cellScrolled = NO;
    
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
#pragma mark - Search Display methods

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    LogMethod();
    self.isSearching = YES;
    //    [[NSNotificationCenter defaultCenter] postNotificationName: @"Searching" object:nil];
    
}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //this needs to be here rather than DidEndSearch to avoid flashing wrong data first
    
    //    [self.collectionTableView reloadData];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    LogMethod();
    self.isSearching = NO;
    //reload the original tableView otherwise section headers are not visible :(  this seems to be an Apple bug
    
    CGFloat largeHeaderAdjustment;
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    if (isPortrait) {
        largeHeaderAdjustment = 11;
    } else {
        largeHeaderAdjustment = 23;
    }
    
    [self.collectionTableView scrollRectToVisible:CGRectMake(largeHeaderAdjustment, 0, 1, 1) animated:YES];
    [self.collectionTableView reloadData];
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    LogMethod();
    
    NSLog (@"searchMediaItemProperty is %@", albumMediaItemProperty);
    MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue: searchText
                                                                                 forProperty: albumMediaItemProperty
                                                                              comparisonType:MPMediaPredicateComparisonContains];
    
    
    myAlbumQuery = [[MPMediaQuery alloc] init];
    //must copy otherwise adds the predicate to self.collectionQueryType too
    myAlbumQuery = [self.collectionQueryType copy];
    
    [myAlbumQuery setGroupingType: albumMediaGrouping];
    [myAlbumQuery addFilterPredicate: filterPredicate];

    searchResults = [myAlbumQuery collections];
    
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
    //    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        //        NSLog (@" searchResults count is %d", [searchResults count]);
        return [searchResults count];
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
    
    if (self.isSearching) {
        
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
    
    
    //don't use CollectionItemCell for searchResultsCell won't respond to touches to scroll anyway and terrible performance on GoBackClick when autoRotated
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *searchResultsCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	CollectionItemCell *cell = (CollectionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"CollectionItemCell"];
    cell.durationLabel.text = @"";
    
    MPMediaQuerySection * sec = self.albumCollectionSections[indexPath.section];
    //    NSLog (@" section is %d", indexPath.section);
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        if ( searchResultsCell == nil ) {
            searchResultsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            searchResultsCell.selectionStyle = UITableViewCellSelectionStyleGray;
            searchResultsCell.selectedBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
            searchResultsCell.textLabel.font = [UIFont systemFontOfSize:44];
            searchResultsCell.textLabel.textColor = [UIColor whiteColor];
            searchResultsCell.textLabel.highlightedTextColor = [UIColor blueColor];
            searchResultsCell.textLabel.lineBreakMode = NSLineBreakByClipping;
            
            DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:[UIColor whiteColor]];
            accessory.highlightedColor = [UIColor blueColor];
            searchResultsCell.accessoryView = accessory;
        }
        NSString *mediaItemName;
        MPMediaItemCollection *searchCollection = [searchResults objectAtIndex: indexPath.row];
        
        if ([self.collectionType isEqualToString: @"Playlists"]) {
            MPMediaPlaylist  *mediaPlaylist = [searchResults objectAtIndex: indexPath.row];
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
    
        BOOL emptyArray = NO;
        
        MPMediaItemCollection *currentQueue = [MPMediaItemCollection alloc];
        
        if ([self.collection count] == 0) {
            emptyArray = YES;
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
                
                int playlistMinutes = (playlistDuration / 60);     // Whole minutes
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
    
    cell.scrollViewToCellConstraint.constant = showDuration ? (30 + 130 + 5) : 30;
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
    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
                                       constrainedToSize:CGSizeMake(INT16_MAX,cell.frame.size.height)
                                           lineBreakMode:NSLineBreakByClipping];
    
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
    
    if ([self.searchDisplayController isActive]) {
        
        selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        
        MPMediaItemCollection *searchCollection = [searchResults objectAtIndex: selectedIndexPath.row];
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
        
        NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
        long playlistDuration = 0;
        
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

	}
    
	if ([segue.identifier isEqualToString:@"ViewSongs"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;
        
        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = selectedName;
        collectionItem.duration = [self calculatePlaylistDuration: self.songCollection];

        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[self.songCollection items]];
        
        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        songViewController.listIsAlphabetic = NO;
        songViewController.title = collectionItem.name;        
        songViewController.collectionItem = collectionItem;
        songViewController.collectionQueryType = selectedQuery;

//        }
	}
    
    if ([segue.identifier isEqualToString:@"ViewNowPlaying"])
	{
		MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;
        
        mainViewController.playNew = NO;
        mainViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

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

- (void)goBackClick
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor darkGrayColor];
//    if (disableRotation) {
//        [self.view addSubview:spinner]; // spinner is not visible until started
//        [spinner startAnimating];
//    }

    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        //delay so that networkActivityIndicator can be visible
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.navigationController popViewControllerAnimated:YES];

//            });
        
    }
}

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
        cellScrolled = YES;
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
    LogMethod();
    
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
    
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
	
    
}
@end
