//
//  CollectionViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

#import "ArtistViewController.h"
#import "CollectionItemCell.h"
#import "CollectionItem.h"
#import "SongViewController.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"
#import "InCellScrollView.h"
#import "AlbumViewController.h"


@interface ArtistViewController ()
    @property (nonatomic, retain, readwrite) NSArray * collectionSections;
    @property (nonatomic, retain, readwrite) NSArray * collectionSectionTitles;
@end

@implementation ArtistViewController

@synthesize collectionTableView;
@synthesize allAlbumsView;
@synthesize allAlbumsButton;
@synthesize searchBar;
@synthesize collection;
@synthesize collectionType;
@synthesize collectionQueryType;
@synthesize managedObjectContext;
//@synthesize saveIndexPath;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize musicPlayer;
@synthesize albumCollection;
@synthesize rightBarButton;

NSArray *searchResults;
NSMutableArray *collectionDurations;
NSIndexPath *selectedIndexPath;
NSString *selectedName;
NSString *searchMediaItemProperty;
CGFloat constraintConstant;
UIImage *backgroundImage;

BOOL cellScrolled;
BOOL isSearching;
BOOL isIndexed;
BOOL showDuration;
//BOOL disableRotation;

- (void) viewDidLoad {
    
    [super viewDidLoad];
//    LogMethod();
    
    //set up an array of durations to be used in landscape mode
    collectionDurations = [[NSMutableArray alloc] initWithCapacity: [self.collection count]];

    //create the array in the background
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        [self createDurationArray];
    });
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

    self.allAlbumsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.allAlbumsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    
    self.collectionTableView.sectionIndexMinimumDisplayRowCount = 20;

    if ([self.collection count] > self.collectionTableView.sectionIndexMinimumDisplayRowCount) {
        isIndexed = YES;
    } else {
        isIndexed = NO;
    }
    
    // format of collectionSections is <MPMediaQuerySection: 0x1cd34c80> title=B, range={0, 5}, sectionIndexTitleIndex=1,

    self.collectionSections = [self.collectionQueryType collectionSections];
    
    NSMutableArray * titles = [NSMutableArray arrayWithCapacity:[self.collectionSections count]];
    for (MPMediaQuerySection * sec in self.collectionSections) {
        [titles addObject:sec.title];
    }
    self.collectionSectionTitles = [titles copy];
    


//    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;

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
//    LogMethod();
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
                CollectionItemCell *cell = (CollectionItemCell *)[self.collectionTableView cellForRowAtIndexPath:indexPath];
                [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
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
//    LogMethod();
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
    if (!isSearching) {

        BOOL firstRowVisible = NO;
        //visibleRows is always 0 the first time through here for a table, populated after that
        NSArray *visibleRows = [self.collectionTableView indexPathsForVisibleRows];
        NSIndexPath *index = [visibleRows objectAtIndex: 0];
        if (index.section == 0 && index.row == 0) {
            firstRowVisible = YES;
        }
        
        // hide the search bar and All Albums cell
        CGFloat tableViewHeaderHeight = self.allAlbumsView.frame.size.height;
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
}
- (void)updateContentOffset {
    //this is only necessary when screen will not be filled - this method is executed afterDelay because ContentOffset is probably not correct until after layoutSubviews happens
    
//    NSLog (@"tableView content size is %f %f",self.collectionTableView.contentSize.height, self.collectionTableView.contentSize.width);

    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat largeHeaderAdjustment = isPortrait ? 11 : 23;

    CGFloat tableViewHeaderHeight = self.allAlbumsView.frame.size.height;

    [self.collectionTableView setContentOffset:CGPointMake(0, tableViewHeaderHeight - largeHeaderAdjustment)];
}
- (void) viewWillLayoutSubviews {
//    LogMethod();
        //need this to pin portrait view to bounds otherwise if start in landscape, push to next view, rotate to portrait then pop back the original view in portrait - it will be too wide and "scroll" horizontally
    self.collectionTableView.contentSize = CGSizeMake(self.collectionTableView.frame.size.width, self.collectionTableView.contentSize.height);
    [super viewWillLayoutSubviews];
}
#pragma mark - Search Display methods

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    LogMethod();
    isSearching = YES;
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"Searching" object:nil];

}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //this needs to be here rather than DidEndSearch to avoid flashing wrong data first

//    [self.collectionTableView reloadData];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    LogMethod();
    isSearching = NO;
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
    searchMediaItemProperty = [[NSString alloc] init];
    MPMediaGrouping mediaGrouping = MPMediaGroupingAlbumArtist;
    
    if ([self.collectionType isEqualToString: @"Artists"] || [self.collectionType isEqualToString: @"Genres"]) {
        searchMediaItemProperty = MPMediaItemPropertyAlbumArtist;
        mediaGrouping = MPMediaGroupingAlbumArtist;
    } else {
        if ([self.collectionType isEqualToString: @"Composers"]) {
            searchMediaItemProperty = MPMediaItemPropertyComposer;
            mediaGrouping = MPMediaGroupingComposer;
        }
    }
    MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue: searchText
                                                                                     forProperty: searchMediaItemProperty
                                                                                  comparisonType:MPMediaPredicateComparisonContains];

    
    MPMediaQuery *myArtistQuery = [[MPMediaQuery alloc] init];
//    [myArtistQuery setGroupingType: MPMediaGroupingAlbumArtist];
    [myArtistQuery setGroupingType: mediaGrouping];
    [myArtistQuery addFilterPredicate: filterPredicate];
    
    if ([self.collectionType isEqualToString: @"Genres"]) {
        [myArtistQuery addFilterPredicate: [MPMediaPropertyPredicate
                                                predicateWithValue: self.title
                                                forProperty: MPMediaItemPropertyGenre]];
    }
    
    searchResults = [myArtistQuery collections];
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
        return [self.collectionSections count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    LogMethod();

    MPMediaQuerySection * sec = nil;
    sec = self.collectionSections[section];
    return sec.title;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//    LogMethod();
    if (tableView == self.searchDisplayController.searchResultsTableView) {

            return nil;
    } else {

    return [[NSArray arrayWithObject:@"{search}"] arrayByAddingObjectsFromArray:self.collectionSectionTitles];
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
        MPMediaQuerySection * sec = self.collectionSections[section];
        return sec.range.length;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    LogMethod();
        //this must be nil or the section headers of the original tableView are awkwardly visible
        // original table must be reloaded after search to get them back :(  this seems to be an Apple bug
    if (isSearching) {

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

    if (isSearching) {

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
    
    //don't use CollectionItemCell for searchResultsCell won't respond to touches to scroll anyway and terrible performance on GoBackClick when autoRotated
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *searchResultsCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	CollectionItemCell *cell = (CollectionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"CollectionItemCell"];
    cell.durationLabel.text = @"";

    MPMediaQuerySection * sec = self.collectionSections[indexPath.section];
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
        if ([self.collectionType isEqualToString: @"Podcasts"]) {
            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyPodcastTitle];
        }
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
    
    //if there is more than one album, display albums, otherwise display songs in the album in song order

    if ([self.searchDisplayController isActive]) {

//        NSLog (@"[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow] is %@", [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow]);

            selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        

//        NSLog (@"selectedIndexPath.row is %d", selectedIndexPath.row);
//        UITableViewCell *searchResultsCell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:selectedIndexPath];
//        selectedName = [searchResults objectAtIndex:selectedIndexPath.row];
//        NSLog (@"searchResults %@", searchResults);
        
        
        MPMediaItemCollection *searchCollection = [searchResults objectAtIndex: selectedIndexPath.row];
        NSString *mediaItemName = [[searchCollection representativeItem] valueForProperty: searchMediaItemProperty];
//        
//        //        NSArray *searchCollectionArray = [searchCollection items];
//        //        for (MPMediaItem *item in searchCollectionArray) {
//        ////            NSLog (@" whatIsThis %@", [[artistCollection representativeItem] valueForProperty: MPMediaItemPropertyAlbumArtist]);
//        //            NSLog (@" whatIsThis %@", [item valueForProperty: MPMediaItemPropertyAlbumArtist]);
//        //
//        //        }
//        //        cell.textLabel.text = [[searchCollection representativeItem] valueForProperty: MPMediaItemPropertyAlbumArtist];
        selectedName = mediaItemName;
    } else {
        selectedIndexPath = indexPath;
        CollectionItemCell *cell = (CollectionItemCell*)[tableView cellForRowAtIndexPath:selectedIndexPath];
        selectedName = cell.nameLabel.text;
    }

//        NSLog (@"selectedName is %@", selectedName);
    
        NSString *mediaItemProperty = [[NSString alloc] init];
        
        if ([self.collectionType isEqualToString: @"Artists"] || [self.collectionType isEqualToString: @"Genres"]) {
            mediaItemProperty = MPMediaItemPropertyAlbumArtist;
        } else {
            if ([self.collectionType isEqualToString: @"Composers"]) {
                 mediaItemProperty = MPMediaItemPropertyComposer;
            }
        }
    
        MPMediaQuery *myCollectionQuery = [[MPMediaQuery alloc] init];
//        MPMediaQuery *myCollectionQuery = self.collectionQueryType;
    
        [myCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
                                                predicateWithValue: selectedName
                                                forProperty: mediaItemProperty]];
        
        if ([self.collectionType isEqualToString: @"Genres"]) {
            [myCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
                                                    predicateWithValue: self.title
                                                    forProperty: MPMediaItemPropertyGenre]];
        }
        // Sets the grouping type for the media query
        [myCollectionQuery setGroupingType: MPMediaGroupingAlbum];
        
//        self.collectionQueryType = myCollectionQuery;
        self.albumCollection = [myCollectionQuery collections];
        
//        NSLog(@"album Collection count is %d", [self.albumCollection count]);
        if ([self.albumCollection count] > 1) {
            [self performSegueWithIdentifier: @"AlbumCollections" sender: self];
        } else {
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
        
        MPMediaQuery *myCollectionQuery = [[MPMediaQuery alloc] init];

        if ([self.collectionType isEqualToString: @"Genres"]) {
            
            [myCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
                                                    predicateWithValue: self.title
                                                    forProperty: MPMediaItemPropertyGenre]];
            // Sets the grouping type for the media query
            [myCollectionQuery setGroupingType: MPMediaGroupingAlbum];
        } else {
            myCollectionQuery = [MPMediaQuery albumsQuery];
        }
        
		albumViewController.collection = [myCollectionQuery collections];;
        albumViewController.collectionType = @"Albums";
        albumViewController.collectionQueryType = myCollectionQuery;
        albumViewController.title = NSLocalizedString(@"Albums", nil);
        albumViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
	}
    //this is called if there is only one album - the songs for that album are displayed in track order
	if ([segue.identifier isEqualToString:@"ViewSongs"])
	{

        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;

        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = selectedName;
//        collectionItem.duration = [self calculatePlaylistDuration: [self.collectionDataArray objectAtIndex:indexPath.row]];
        collectionItem.duration = [self calculatePlaylistDuration: [self.albumCollection objectAtIndex: 0]];

        
//        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[[self.collectionDataArray objectAtIndex:indexPath.row] items]];
        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[[self.albumCollection objectAtIndex:0] items]];

//        collectionItem.collectionArray = [self.albumCollection objectAtIndex:0];


        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
        songViewController.title = collectionItem.name;
//        NSLog (@"collectionItem.name is %@", collectionItem.name);

        songViewController.collectionItem = collectionItem;

	}
    if ([segue.identifier isEqualToString:@"AlbumCollections"])
	{
        AlbumViewController *albumViewController = segue.destinationViewController;
        albumViewController.managedObjectContext = self.managedObjectContext;
        
        albumViewController.title = selectedName;
        albumViewController.collection = self.albumCollection;
        albumViewController.collectionType = self.collectionType;
        albumViewController.collectionQueryType = self.collectionQueryType;
        
        albumViewController.iPodLibraryChanged = self.iPodLibraryChanged;
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
- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
}

#pragma mark Application state management_____________
// Standard methods for managing application state.

- (void)goBackClick
{
    //both actually go back to mediaGroupViewController
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
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
