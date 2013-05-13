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

@end

@implementation AlbumViewController

@synthesize collectionTableView;
@synthesize collection;
@synthesize collectionType;
@synthesize collectionQueryType;
@synthesize managedObjectContext;
@synthesize saveIndexPath;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize musicPlayer;
@synthesize albumDataArray;
@synthesize showAllSongsCell;
@synthesize sectionedArray;
@synthesize rightBarButton;

BOOL cellScrolled;
//BOOL disableRotation;
//UIActivityIndicatorView *spinner;

- (void) viewDidLoad {
    
    [super viewDidLoad];
	
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
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
    
    //add an NSString @"All Songs" object to the beginning of the collection array, then use albumDataArray as data source for table - EXCEPT for Playlists and Podcasts - don't add it for playlists and podcasts
    
    self.showAllSongsCell = YES;
//set to NO just to get indexing working - then change it back and figure out how to deal with the showAllSongsCell
//    self.showAllSongsCell = NO;

    
    if ([self.collectionType isEqualToString: @"Playlists"]) {
        self.showAllSongsCell = NO;
    }
    
    if ([self.collectionType isEqualToString: @"Podcasts"]) {
        self.showAllSongsCell = NO;
    }

    self.albumDataArray = [[NSMutableArray alloc] initWithCapacity: 20];
    [self.albumDataArray addObjectsFromArray: self.collection];
    if (showAllSongsCell) {
        [self.albumDataArray insertObject: @" All Songs" atIndex: 0];
    }
//    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

//    MPMediaItemCollection *currentQueue = [MPMediaItemCollection collectionWithItems: self.collection];
//
//    self.currentQueue = self.mainViewController.userMediaItemCollection;
//
//    NSArray *returnedQueue = [currentQueue items];
//
//    for (MPMediaItem *album in returnedQueue) {
//        NSLog(@"The key: %@",[MPMediaItem titlePropertyForGroupingType:MPMediaGroupingAlbum]);
//    }
//    
//    for (MPMediaItemCollection *mediaItem in self.collection)
//    {
//        [self.albumDataArray addObject:[mediaItem representativeItem]];
//    }
//    
//    self.sectionedArray = [self partitionObjects:self.albumDataArray collationStringSelector:@selector(albumTitle)];
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
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:44];
    label.font = newFont;
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
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.collectionTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
    } else {
        [self.collectionTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        //if rotating to landscape and row 0 will be visible, need to scrollRectToVisible to align it correctly
        NSArray *indexes = [self.collectionTableView indexPathsForVisibleRows];
        //        NSLog (@"visible indexes %@", indexes);
        NSIndexPath *index = [indexes objectAtIndex: 0];
        if (index.row == 0) {
            [self.collectionTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        }
    }
    [self.collectionTableView reloadData];
    cellScrolled = NO;
    
//    //recenter spinner
//    [spinner setCenter: CGPointMake (self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];

}
- (void) viewWillLayoutSubviews {
    //need this to pin portrait view to bounds otherwise if start in landscape, push to next view, rotate to portrait then pop back the original view in portrait - it will be too wide and "scroll" horizontally
    self.collectionTableView.contentSize = CGSizeMake(self.collectionTableView.frame.size.width, self.collectionTableView.contentSize.height);
    [super viewWillLayoutSubviews];
}

//- (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
//{
//    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
//    NSInteger sectionCount = [[collation sectionTitles] count];
//    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
//    for(int i = 0; i < sectionCount; i++)
//    {
//        [unsortedSections addObject:[NSMutableArray array]];
//    }
//    for (id object in array)
//    {
//        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
//        [[unsortedSections objectAtIndex:index] addObject:object];
//    }
//    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
//    for (NSMutableArray *section in unsortedSections)
//    {
//        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
//    }
//    return sections;
//}



//#pragma mark Table view methods________________________
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
//}


#pragma - TableView Index Scrolling

// Configures the table view.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
//    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
    
    return [self.albumDataArray count];
//    return [[[[UILocalizedIndexedCollation currentCollation] objectAtIndex: section] collectionSections] count];

//     return [[self.sectionedArray objectAtIndex:section] count];

}


- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
    if (indexPath.row == 0 && showAllSongsCell) {
        // dequeue and configure my static cell for indexPath.row
        NSString *cellIdentifier = @"allSongsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor blueColor];
        cell.textLabel.text = @"All Songs";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:44];
        cell.textLabel.textColor = [UIColor whiteColor];
        DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.textLabel.textColor];
        accessory.highlightedColor = [UIColor blueColor];
        cell.accessoryView = accessory;
        
        return cell;
    } 

	CollectionItemCell *cell = (CollectionItemCell *)[tableView
                                                      dequeueReusableCellWithIdentifier:@"CollectionItemCell"];
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    //commented out while getting indexing to work
    
    BOOL emptyArray = NO;
    
    MPMediaItemCollection *currentQueue = [MPMediaItemCollection alloc];
    
    if ([[self.albumDataArray objectAtIndex:indexPath.row] count] == 0) {
        emptyArray = YES;
    } else {
        currentQueue = [MPMediaItemCollection collectionWithItems: [[self.albumDataArray objectAtIndex:indexPath.row] items]];
    }

    if ([self.collectionType isEqualToString: @"Playlists"]) {
        MPMediaPlaylist  *mediaPlaylist = [self.albumDataArray objectAtIndex:indexPath.row];
        cell.nameLabel.text = [mediaPlaylist valueForProperty: MPMediaPlaylistPropertyName];
    } else {
        if ([self.collectionType isEqualToString: @"Podcasts"]) {
            //commented out while getting indexing to work
            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyPodcastTitle];
        } else {
        cell.durationLabel.text = @"";
            //commented out while getting indexing to work

        cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyAlbumTitle];
//            cell.textLabel.text = [temp valueForProperty:MPMediaItemPropertyAlbumTitle];
        }
    }

    //get the duration of the the playlist
    if (isPortrait) {
        cell.durationLabel.hidden = YES;
    } else {
        cell.durationLabel.hidden = NO;
        
        if (emptyArray) {
            cell.durationLabel.text = @"";
        } else {
            NSNumber *playlistDurationNumber = [self calculatePlaylistDuration: currentQueue];
            long playlistDuration = [playlistDurationNumber longValue];
            
            int playlistMinutes = (playlistDuration / 60);     // Whole minutes
            int playlistSeconds = (playlistDuration % 60);                        // seconds
            cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];
        //            [cell.textLabel addSubView:cell.durationLabel];
        }
    }
    
    if (cell.nameLabel.text == nil) {
        cell.nameLabel.text = @"Unknown";
    }
    if ([cell.nameLabel.text isEqualToString: @""]) {
        cell.nameLabel.text = @"Unknown";
    }
    NSLog (@"cell.nameLabel.text is %@", cell.nameLabel.text);

    //set the textLabel to the same thing - it is used if the text does not need to scroll
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:44];
    cell.textLabel.font = newFont;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = [UIColor blueColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = cell.nameLabel.text;
    //comment out for indexing
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
    accessory.highlightedColor = [UIColor blueColor];
    cell.accessoryView = accessory;
    
    //    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //size of duration Label is set at 130 to match the fixed size that it is set in interface builder
    // note that cell.durationLabel.frame.size.width) = 0 here
    //    NSLog (@"************************************width of durationLabel is %f", cell.durationLabel.frame.size.width);
    
    // if want to make scrollview width flex with width of duration label, need to set it up in code rather than interface builder - not doing that now, but don't see any problem with doing it
    
    //    CGSize durationLabelSize = [cell.durationLabel.text sizeWithFont:cell.durationLabel.font
    //                                                   constrainedToSize:CGSizeMake(135, CGRectGetHeight(cell.durationLabel.bounds))
    //                                                       lineBreakMode:NSLineBreakByClipping];
    //cell.durationLabel.frame.size.width = 130- have to hard code because not calculated yet at this point
    
    //this is the constraint from scrollView to Cell  needs to just handle accessory in portrait and handle duration and accessory in landscape
    CGFloat contraintConstant = isPortrait ? 30 : (30 + 130 + 5);
    
    
    cell.scrollViewToCellConstraint.constant = contraintConstant;
    
    NSUInteger scrollViewWidth;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        //14 just is the number that was needed to make the label scroll correctly within the scrollView
        scrollViewWidth = (tableView.frame.size.width -28 - cell.accessoryView.frame.size.width);
    } else {
        //        scrollViewWidth = (tableView.frame.size.width - durationLabelSize.width - cell.accessoryView.frame.size.width);
        // and 145 is the number that makes the scroll work right in landscape - don't try to figure it out
        scrollViewWidth = (tableView.frame.size.width - 145 - cell.accessoryView.frame.size.width);
        
    }
    [cell.scrollView removeConstraint:cell.centerXInScrollView];
    
    //calculate the label size to fit the text with the font size
    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
                                       constrainedToSize:CGSizeMake(INT16_MAX,tableView.rowHeight)
                                           lineBreakMode:NSLineBreakByClipping];
    
    //    //build a new label that will hold all the text
    //    UILabel *newLabel = [[UILabel alloc] initWithFrame: cell.nameLabel.frame];
    //    CGRect frame = newLabel.frame;
    ////    frame.size.height = CGRectGetHeight(cell.nameLabel.bounds);
    //    frame.size.width = labelSize.width;
    //    newLabel.frame = frame;
    //
    //    //set the UIOutlet label's frame to the new sized frame
    //    cell.nameLabel.frame = newLabel.frame;
    
    //    NSLog (@"size of newLabel is %f", frame.size.width);
    
    //***********add constaint to line up Y of nameLabel and scrollView
    
    //Make sure that label is aligned with scrollView
    [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    cell.scrollView.delegate = cell.scrollView;

    
    if (labelSize.width>scrollViewWidth) {
        cell.scrollView.hidden = NO;
        cell.textLabel.hidden = YES;
    }
    else {
        cell.scrollView.hidden = YES;
        cell.textLabel.hidden = NO;
    }

    return cell;
    
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

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    //    LogMethod();
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    LogMethod();
    NSIndexPath *indexPath = [ self.collectionTableView indexPathForCell:sender];

	if ([segue.identifier isEqualToString:@"ViewAllSongs"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;
        
        MPMediaQuery *myCollectionQuery = self.collectionQueryType;
        
        NSArray *songCollection = [myCollectionQuery items];
        
        NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
        long playlistDuration = 0;
        
        // sort the song list into alphabetical order with the nuances of Apple's sorting - see createComparator below
        for (MPMediaItem *song in songCollection) {
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
        
        if ([self.collectionType isEqualToString: @"Albums"] || [self.collectionType isEqualToString: @"Compilations"]) {
            songViewController.title = NSLocalizedString(@"Songs", nil);
        } else {
            collectionItem.name = self.title;
            songViewController.title = NSLocalizedString(collectionItem.name, nil);
        }
        songViewController.collectionItem = collectionItem;
        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
            
	}
    
	if ([segue.identifier isEqualToString:@"ViewSongs"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;
        
        CollectionItemCell *cell = (CollectionItemCell*)[self.collectionTableView cellForRowAtIndexPath:indexPath];

        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = cell.nameLabel.text;
//        collectionItem.duration = [self calculatePlaylistDuration: [self.collection objectAtIndex:indexPath.row]];
        collectionItem.duration = [self calculatePlaylistDuration: [self.albumDataArray objectAtIndex:indexPath.row]];


        
//        collectionItem.collection = [MPMediaItemCollection collectionWithItems: [[self.collection objectAtIndex:indexPath.row] items]];
//        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[[self.collection objectAtIndex:indexPath.row] items]];
        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[[self.albumDataArray objectAtIndex:indexPath.row] items]];

        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
        songViewController.title = collectionItem.name;
        //        NSLog (@"collectionItem.name is %@", collectionItem.name);
        
        songViewController.collectionItem = collectionItem;
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
