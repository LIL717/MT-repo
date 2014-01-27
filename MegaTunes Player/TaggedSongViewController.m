//
//  TaggedSongViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 6/28/13.
//
//
//

#import "MainViewController.h"
#import "InfoTabBarController.h"
#import "TaggedSongViewController.h"
#import "DTCustomColoredAccessory.h"
#import "SongCell.h"
#import "InCellScrollView.h"
#import "CollectionItem.h"
#import "ItemCollection.h"
#import "UIImage+AdditionalFunctionalities.h"
#import "UserDataForMediaItem.h"
#import "MediaItemUserData.h"
#import "TagData.h"
#import "KSLabel.h"
#import "TaggedSectionIndexData.h"
#import "Reachability.h"

@interface TaggedSongViewController ()
@property (nonatomic, strong) NSMutableArray * taggedSongSections;  // an dictionary with a key of the first letter of the tagName and 1 object:  a dictionary of all the songs (mediaItems) in that section
@property (nonatomic, strong) NSArray *taggedSongSectionTitles;  //need to keep this as its own array instead of adding as dictionary key so that search can be added to the top!
@end

@implementation TaggedSongViewController

@synthesize songTableView;
@synthesize shuffleView;
@synthesize shuffleButton;
@synthesize searchBar;
@synthesize collectionItem;
@synthesize collectionOfOne;
@synthesize musicPlayer;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize mediaItemForInfo;
@synthesize itemToPlay;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
//@synthesize listIsAlphabetic;
@synthesize isSearching;
@synthesize songCollection;
@synthesize playBarButton;
@synthesize tagBarButton;
@synthesize colorTagBarButton;
@synthesize noColorTagBarButton;

@synthesize collectionQueryType;        //used as base of query for search
@synthesize searchResults;
@synthesize collectionItemToSave;
@synthesize showTagButton;
@synthesize showTags;
@synthesize songViewTitle;
@synthesize swipeLeftRight;
@synthesize collectionContainsICloudItem;
@synthesize cellScrolled;
@synthesize songShuffleButtonPressed;
@synthesize taggedSongArray;
@synthesize sortedTaggedArray;
@synthesize taggedSectionIndexData;



NSMutableArray *songDurations;
NSMutableArray *savedDataSource;
NSNumber *savedPlaylistDuration;
NSMutableArray *savedTaggedDataSource;
NSNumber *savedTaggedPlaylistDuration;
NSIndexPath *selectedIndexPath;
MPMediaItem *selectedSong;
NSString *searchMediaItemProperty;
CGFloat constraintConstant;
//UIImage *backgroundImage;
UIButton *infoButton;

BOOL isIndexed;
BOOL showDuration;
BOOL turnOnShuffle;
BOOL currentDataSourceContainsICloudItems;
BOOL firstLoad;
BOOL excludeICloudItems;


#pragma mark - Initial Display methods

- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
    
    //as this method starts, the whole collectionArray is available including ICloudItems
    currentDataSourceContainsICloudItems = YES;
    
    firstLoad = YES;
    self.songShuffleButtonPressed = NO;
    
    
    self.songViewTitle = self.title;
    self.showTagButton = NO;
    self.songTableView.scrollsToTop = YES;
    self.showTags = YES;
    
//131203 1.2 iOS 7 begin

//    //set up grouped table view to look like plain (so that section headers won't stick to top)
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
//    self.songTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]];
//    self.songTableView.opaque = NO;
//    self.songTableView.backgroundView = nil; // THIS ONE TRIPPED ME UP!
//    //    backgroundImage = [UIImage imageNamed: @"list-background.png"];
    
//131203 1.2 iOS 7 end

    
    //make the back arrow for left bar button item
    
//131204 1.2 iOS 7 begin
    
    //    self.navigationItem.hidesBackButton = YES; // Important
    //    //initWithTitle cannot be nil, must be @""
    //	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
    //                                                                             style:UIBarButtonItemStyleBordered
    //                                                                            target:self
    //                                                                            action:@selector(goBackClick)];
    //
    //    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
//131204 1.2 iOS 7 end
//140127 1.2 iOS 7 begin
    UIButton *tempPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempPlayButton addTarget:self action:@selector(viewNowPlaying) forControlEvents:UIControlEventTouchUpInside];
    [tempPlayButton setImage:[UIImage imageNamed:@"redWhitePlayImage.png"] forState:UIControlStateNormal];
    [tempPlayButton setShowsTouchWhenHighlighted:NO];
    [tempPlayButton sizeToFit];
    
    self.playBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempPlayButton];
//140127 1.2 iOS 7 end
    [self.playBarButton setIsAccessibilityElement:YES];
    [self.playBarButton setAccessibilityLabel: NSLocalizedString(@"Now Playing", nil)];
    [self.playBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
//140124 1.2 iOS 7 begin
    UIButton *tempColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempColorButton addTarget:self action:@selector(showTagColors) forControlEvents:UIControlEventTouchUpInside];
    [tempColorButton setImage:[UIImage imageNamed:@"colorImage.png"] forState:UIControlStateNormal];
    [tempColorButton setShowsTouchWhenHighlighted:NO];
    [tempColorButton sizeToFit];
    
    self.colorTagBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempColorButton];
//140124 1.2 iOS 7 end
    [self.colorTagBarButton setIsAccessibilityElement:YES];
    [self.colorTagBarButton setAccessibilityLabel: NSLocalizedString(@"Show tag colors", nil)];
    [self.colorTagBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
//140124 1.2 iOS 7 begin
    UIButton *tempNoColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempNoColorButton addTarget:self action:@selector(showTagColors) forControlEvents:UIControlEventTouchUpInside];
    [tempNoColorButton setImage:[UIImage imageNamed:@"noColorImage.png"] forState:UIControlStateNormal];
    [tempNoColorButton setShowsTouchWhenHighlighted:NO];
    [tempNoColorButton sizeToFit];
    
    self.noColorTagBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempNoColorButton];
//140124 1.2 iOS 7 end
    [self.noColorTagBarButton setIsAccessibilityElement:YES];
    [self.noColorTagBarButton setAccessibilityLabel: NSLocalizedString(@"Hide tqg colors", nil)];
    [self.noColorTagBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    self.cellScrolled = NO;
    
    // load the taggedSongArray if it has not been previously loaded
    if (!self.taggedSongArray) {
        [self createTaggedSongArray];
    }
    
    [self prepareArrayDependentData];
    
    //check if collection has ICloud Items
    
    self.collectionContainsICloudItem = NO;
    [self checkForICloudItemsWithCompletion:^(BOOL result) {
        
    }];
    
    
    
}

- (void) createTaggedSongArray {
    //    LogMethod();
    
    NSMutableArray *songDictMutableArray = [NSMutableArray arrayWithCapacity: 20];
    //    self.taggedSongArray = [NSMutableArray arrayWithCapacity: 20];
    
    long taggedDuration = 0;
    
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    NSArray *taggedMediaItems = [mediaItemUserData containsTag];
    
    for (MediaItemUserData *taggedMediaItem in taggedMediaItems) {
        //        NSLog (@" song is %@ with persistentID %@", taggedMediaItem.title, taggedMediaItem.persistentID);
        
        MPMediaQuery *mySongQuery = [MPMediaQuery songsQuery];
        MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue: taggedMediaItem.persistentID
                                                                                     forProperty:  MPMediaItemPropertyPersistentID];
        [mySongQuery addFilterPredicate: filterPredicate];
        MPMediaPropertyPredicate *cloudPredicate = [MPMediaPropertyPredicate predicateWithValue:  [NSNumber numberWithInt: 0]
                                                                                    forProperty:  MPMediaItemPropertyIsCloudItem];
        if (excludeICloudItems) {
            //iCloud items have value 1 for MPMediaItemPropertyIsCloudItem so if excluding them, only choose items with value 0
            
            //        [mySongQuery addFilterPredicate: filterPredicate];
            [mySongQuery addFilterPredicate: cloudPredicate];
            
            currentDataSourceContainsICloudItems = NO;
        } else {
            currentDataSourceContainsICloudItems = YES;
        }
        
        NSArray *filteredArray = [mySongQuery items];
        if ([filteredArray count] > 0) {
            
            MPMediaItem *song = [MPMediaItem alloc];
            for (MPMediaItem *filteredItem in filteredArray) {
                //                NSLog (@"item with persistentID %@", [filteredItem valueForProperty: MPMediaItemPropertyPersistentID]);
                song = filteredItem;
            }
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: song, @"Song", taggedMediaItem.tagData, @"TagData", nil];
            
            [songDictMutableArray addObject: dict];
            taggedDuration = (taggedDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
            //                NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
            //                NSLog (@"\t\t%@", songTitle);
        }
    }
    
    self.sortedTaggedArray = [songDictMutableArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        TagData *firstTagData = [(NSDictionary *)a objectForKey: @"TagData"];
        TagData *secondTagData = [(NSDictionary *)b objectForKey: @"TagData"];
        return [firstTagData.sortOrder compare: secondTagData.sortOrder];
    }];
    
    self.taggedSongArray = [self.sortedTaggedArray mutableCopy];
    self.collectionItem.duration = [NSNumber numberWithLong: taggedDuration];
}
- (void) prepareArrayDependentData {
    if ([self.taggedSongArray count] > 1) {
        self.shuffleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.shuffleButton.contentEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0);
        [self.shuffleButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [self.shuffleButton setTitleColor:  [UIColor blueColor] forState: UIControlStateHighlighted];
        [self.shuffleButton setTitle: NSLocalizedString(@"Shuffle", nil) forState: UIControlStateNormal];
        self.shuffleButton.hidden = NO;
        CGRect frame = self.shuffleView.frame;
        frame.size.height = 110;
        self.shuffleView.frame = frame;
    } else {
        self.shuffleButton.hidden = YES;
        CGRect frame = self.shuffleView.frame;
        frame.size.height = 55;
        self.shuffleView.frame = frame;
    }
    
    [self loadSectionData];
    
    songDurations = [[NSMutableArray alloc] initWithCapacity: [self.taggedSongArray count]];
    
    if ([self.taggedSongArray count] > 0) {
        
        //create the array in the background
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // Perform async operation
            [self createDurationArray];
        });
    }
}
- (void) loadSectionData {
    //    LogMethod();
    
    self.songTableView.sectionIndexMinimumDisplayRowCount = 20;
    [self.songTableView setSectionIndexColor:[UIColor whiteColor]];
    
    isIndexed = NO;
    
    savedTaggedDataSource = [self.taggedSongArray copy];
    savedTaggedPlaylistDuration = [self.collectionItem.duration copy];
    //    if (self.collectionContainsICloudItem) {
    //        [self adjustTaggedDataSource];
    //    }
    [self createTagSections];
    if ([self.taggedSongArray count] >= self.songTableView.sectionIndexMinimumDisplayRowCount) {
        isIndexed = YES;
    }
    //    NSLog (@"songSectionTitles %@", self.songSectionTitles);
}

- (void) createTagSections {
    //    LogMethod();
    
    BOOL found;
    
    TagData *tagData = [TagData alloc];
    tagData.managedObjectContext = self.managedObjectContext;
    
    int arrayCount;
    arrayCount = [[tagData fetchTagList] count];
    self.taggedSongSections = [NSMutableArray arrayWithCapacity: arrayCount];
    NSMutableArray * titles = [NSMutableArray arrayWithCapacity: arrayCount];
    
    // Loop through the songsDictArray and create our keys and 2 objects for each key, TagData and range (starting index which is location and number of items in the section which is length
    //    typedef struct _NSRange {
    //        NSUInteger location;
    //        NSUInteger length;
    //    } NSRange;
    // format of taggedSongSections is  title=ABC, range={0, 5}, sectionIndexTitleIndex=1,
    
    int currentLocation = 0;
    int sectionItemCount = 0;
    int sectionCount = 0;
    NSString *sectionNameToSave;
    NSString *sectionName;
    
    for (NSDictionary *dict in self.taggedSongArray) {  //dict is a dictionary with 2 objects, mediaItem (song) and TagData
        TagData *tagData = [dict objectForKey: @"TagData"];
        //        NSLog (@"tagData.tagName is %@", tagData.tagName);
        sectionName = tagData.tagName;
        
        found = NO;
        
        for (NSString *fullTitle in titles) {
            if ([fullTitle isEqualToString:sectionName]) {
                found = YES;
                break;
                //                NSLog (@" foundSectionIndex is %@", sectionIndex);
            }
        }
        
        if (found) {
            sectionItemCount +=1;
        } else {
            [titles addObject: sectionName];
            if (sectionCount > 0) {
                
                self.taggedSectionIndexData = [TaggedSectionIndexData alloc];
                
                if ([sectionNameToSave length] > 3) {
                    self.taggedSectionIndexData.sectionIndexTitle =  [sectionNameToSave substringToIndex: 3];
                } else {
                    self.taggedSectionIndexData.sectionIndexTitle = sectionNameToSave;
                }
                
                self.taggedSectionIndexData.sectionRange = NSMakeRange(currentLocation, sectionItemCount);
                self.taggedSectionIndexData.sectionIndexTitleIndex = sectionCount - 1;  //this will be an actual index
                [self.taggedSongSections addObject: self.taggedSectionIndexData];
                NSLog (@"Added object title=%@, range=%d %d, index=%d", self.taggedSectionIndexData.sectionIndexTitle, self.taggedSectionIndexData.sectionRange.location, self.taggedSectionIndexData.sectionRange.length, self.taggedSectionIndexData.sectionIndexTitleIndex);
            }
            sectionNameToSave = sectionName;
            currentLocation = currentLocation + sectionItemCount;
            sectionItemCount = 1;
            sectionCount += 1;
        }
        
    }
    //add last entry when done looping
    if (sectionCount > 0) {
        //        [titles addObject: tagData.tagName];
        self.taggedSectionIndexData = [TaggedSectionIndexData alloc];
        
        if ([sectionNameToSave length] > 3) {
            self.taggedSectionIndexData.sectionIndexTitle =  [sectionNameToSave substringToIndex: 3];
        } else {
            self.taggedSectionIndexData.sectionIndexTitle = sectionNameToSave;
        }
        
        self.taggedSectionIndexData.sectionRange = NSMakeRange(currentLocation, sectionItemCount);
        self.taggedSectionIndexData.sectionIndexTitleIndex = sectionCount - 1;
        [self.taggedSongSections addObject: self.taggedSectionIndexData];
        NSLog (@"Added last object title=%@, range=%d %d, index=%d", self.taggedSectionIndexData.sectionIndexTitle, self.taggedSectionIndexData.sectionRange.location, self.taggedSectionIndexData.sectionRange.length, self.taggedSectionIndexData.sectionIndexTitleIndex);
    }
    self.taggedSongSectionTitles = [titles copy];
    
}
- (void)checkForICloudItemsWithCompletion:(void (^)(BOOL result))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSDictionary *dict in self.taggedSongArray) {
            MPMediaItem *song = [dict objectForKey: @"Song"];
            if ([song valueForProperty: MPMediaItemPropertyIsCloudItem] == [NSNumber numberWithInt: 1]) {
                self.collectionContainsICloudItem = YES;
                break;
            }
        }
        
        // Check that there was not a nil handler passed.
        if( completionHandler ){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                NSLog (@"Done Checking For ICloud Items in SongViewController");
                NSLog (@"unfiltered CollectionContainsICloudItem = %d", self.collectionContainsICloudItem);
                [self reachabilityChanged: (NSNotification *) nil];
            });
        }
    });
}
- (void) createDurationArray {
    
    long playlistDuration = 0;
    
    for (NSDictionary *dict in self.taggedSongArray) {  //dict is a dictionary with 2 objects, mediaItem (song) and TagData
        MPMediaItem *song = [dict objectForKey: @"Song"];
        
        //calculate the duration of the the playlist
        
        long playbackDuration = [[song valueForProperty: MPMediaItemPropertyPlaybackDuration] longValue];
        
        int playlistMinutes = (playbackDuration / 60);     // Whole minutes
        int playlistSeconds = (playbackDuration % 60);                        // seconds
        NSString *itemDuration = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];
        [songDurations addObject: itemDuration];
        playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
        
        
    }
    self.collectionItem.duration = [NSNumber numberWithLong: playlistDuration];
    NSLog (@"Duration array complete");
}

//- (void) adjustTaggedDataSource {
////    LogMethod();
//
//    BOOL iCloudAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudAvailable"];
//    if (iCloudAvailable) {
//        if (currentDataSourceContainsICloudItems == NO) {
//            self.taggedSongArray = savedTaggedDataSource;
//            self.taggedPlaylistDuration = savedTaggedPlaylistDuration;
//            currentDataSourceContainsICloudItems = YES;
//        }
//    } else {
//        if (currentDataSourceContainsICloudItems) {
//            //save the array with all the items and the duration
//            savedTaggedDataSource = [self.taggedSongArray copy];
//            savedTaggedPlaylistDuration = [self.taggedPlaylistDuration copy];
//
//            //create a new array without the iCloudItems
//            NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
//            long playlistDuration = 0;
//            NSString *isCloudItem = @"0";  // the BOOL MPMediaItemPropertyIsCloudItem seems to be 0, but doesn't work as a BOOL
//
//            for (MPMediaItem *song in savedTaggedDataSource) {
//                isCloudItem = [song valueForProperty: MPMediaItemPropertyIsCloudItem];
//                if (isCloudItem.intValue != 1) {  //iCloud items should be 1
//                    [songMutableArray addObject: song];
//                    playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
//                }
//            }
//            //save the new array and duration to use
//            self.taggedSongArray = songMutableArray;
//            self.taggedPlaylistDuration = [NSNumber numberWithLong: playlistDuration];
//            currentDataSourceContainsICloudItems = NO;
//        }
//    }
//
//}
- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    
//131216 1.2 iOS 7 begin
    self.edgesForExtendedLayout = UIRectEdgeNone;
//131216 1.2 iOS 7 end
    self.swipeLeftRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTagButtonAndTitle:)];
    [self.swipeLeftRight setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
    [self.navigationController.navigationBar addGestureRecognizer:self.swipeLeftRight];
    
    [self buildRightNavBarArray];
    
    //set the navigation bar title
    self.navigationItem.titleView = [self customizeTitleView];
    
    //    // if rows have been scrolled, they have been added to this array, so need to scroll them back to 0
    //    YAY this works!!
    //    if ([scrolledCellIndexArray count] > 0) {
    if (self.cellScrolled) {
        //        for (NSIndexPath *indexPath in scrolledCellIndexArray) {
        for (NSIndexPath *indexPath in [self.songTableView indexPathsForVisibleRows]) {
            //            NSLog (@" indexPath to scroll %@", indexPath);
            SongCell *cell = (SongCell *)[self.songTableView cellForRowAtIndexPath:indexPath];
            [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        }
        
        self.cellScrolled = NO;
    }
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
    [super viewWillAppear: animated];
    
    return;
}
-(void) buildRightNavBarArray {
    //if there is a currently playing item, add a right button to the nav bar
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (showTags) {
        self.tagBarButton = self.noColorTagBarButton;
    } else {
        self.tagBarButton = self.colorTagBarButton;
    }
    if (playingItem && showTagButton) {
        //initWithTitle cannot be nil, must be @""
        //        self.navigationItem.rightBarButtonItem = self.playBarButton;
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:self.playBarButton, self.tagBarButton, nil]];
        self.title = nil;
    } else if (!playingItem && showTagButton) {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: self.tagBarButton, nil]];
        self.title = nil;
    } else if (!showTagButton && playingItem) {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: self.playBarButton, nil]];
        self.title = NSLocalizedString(self.songViewTitle, nil);
    } else if (!playingItem && !showTagButton) {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: nil]];
        self.title = NSLocalizedString(self.songViewTitle, nil);
    }
}
-(void) viewDidAppear:(BOOL)animated {
    //    LogMethod();
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super viewDidAppear:(BOOL)animated];
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
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    //    LogMethod();
//131216 1.2 iOS 7 begin
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat navBarAdjustment = isPortrait ? 0 : 7;
    
    
    //    CGFloat navBarAdjustment;
    //
    //    if (UIInterfaceOrientationIsPortrait(orientation)) {
    //        navBarAdjustment = 11;
    //        [self.collectionTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
    //
    //    } else {
    //        navBarAdjustment = 23;
    //        [self.collectionTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
    //    }
//131216 1.2 iOS 7 end
    //    //don't need to do this if the search table is showing
    //    if (!isSearching) {
    
    BOOL firstRowVisible = NO;
    
    //visibleRows is always 0 the first time through here for a table, populated after that
    if (firstLoad) {
        firstLoad = NO;
        firstRowVisible = YES;
    } else {
        NSArray *visibleRows = [self.songTableView indexPathsForVisibleRows];
        if ([visibleRows count] != 0) {
            NSIndexPath *index = [visibleRows objectAtIndex: 0];
            if (index.section == 0 && index.row == 0) {
                firstRowVisible = YES;
            }
        }
    }
    
    
    // hide the search bar and All Songs cell
    CGFloat tableViewHeaderHeight = self.shuffleView.frame.size.height;
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
    if (firstRowVisible) {
        //        [self.collectionTableView scrollRectToVisible:CGRectMake(0, adjustedHeaderHeight, 1, 1) animated:NO];
        [self.songTableView setContentOffset:CGPointMake(0, adjustedHeaderHeight)];
//140113 1.2 iOS 7 end
    }
    [self.songTableView reloadData];
    //    }
    self.cellScrolled = NO;
    
}
- (void)updateContentOffset {
    //this is only necessary when screen will not be filled - this method is executed afterDelay because ContentOffset is probably not correct until after layoutSubviews happens
    
    //    NSLog (@"tableView content size is %f %f",self.collectionTableView.contentSize.height, self.collectionTableView.contentSize.width);
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat largeHeaderAdjustment = isPortrait ? 11 : 23;
    
    CGFloat tableViewHeaderHeight = self.shuffleView.frame.size.height;
    
    [self.songTableView setContentOffset:CGPointMake(0, tableViewHeaderHeight - largeHeaderAdjustment)];
    
}
- (void) viewWillLayoutSubviews {
    //need this to pin portrait view to bounds otherwise if start in landscape, push to next view, rotate to portrait then pop back the original view in portrait - it will be too wide and "scroll" horizontally
    self.songTableView.contentSize = CGSizeMake(self.songTableView.frame.size.width, self.songTableView.contentSize.height);
    
    [super viewWillLayoutSubviews];
}
#pragma mark - Search Display methods

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    //    LogMethod();
    self.isSearching = YES;
    //    [[NSNotificationCenter defaultCenter] postNotificationName: @"Searching" object:nil];
    
}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //this needs to be here rather than DidEndSearch to avoid flashing wrong data first
    
    //    [self.collectionTableView reloadData];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    //    LogMethod();
    self.isSearching = NO;
    //reload the original tableView otherwise section headers are not visible :(  this seems to be an Apple bug
    
    CGFloat largeHeaderAdjustment;
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    if (isPortrait) {
        largeHeaderAdjustment = 11;
    } else {
        largeHeaderAdjustment = 23;
    }
    
    [self.songTableView scrollRectToVisible:CGRectMake(largeHeaderAdjustment, 0, 1, 1) animated:YES];
    [self.songTableView reloadData];
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    //    LogMethod();
    
    searchMediaItemProperty = MPMediaItemPropertyTitle;
    
    //    NSLog (@"searchMediaItemProperty is %@", searchMediaItemProperty);
    MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue: searchText
                                                                                 forProperty: searchMediaItemProperty
                                                                              comparisonType:MPMediaPredicateComparisonContains];
    
    
    MPMediaQuery *mySongQuery = [self.collectionQueryType copy];
    [mySongQuery addFilterPredicate: filterPredicate];
    
    NSArray *allMatchingSongs = [mySongQuery items];
    
    //    if (taggedList) {
    NSMutableArray *taggedSongsSearchResults = [[NSMutableArray alloc] init];
    for (MPMediaItem *song in allMatchingSongs) {
        TagData *tagData = [self retrieveTagForMediaItem: song];
        if (tagData) {
            [taggedSongsSearchResults addObject: song];
        }
    }
    self.searchResults = [taggedSongsSearchResults copy];
    //    } else {
    //        searchResults = [mySongQuery items];
    //    }
    
    //    NSLog (@"searchResults %@", searchResults);
    
    
}
- (TagData *) retrieveTagForMediaItem: (MPMediaItem *) mediaItem {
    
    //check to see if there is user data for this media item
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    UserDataForMediaItem *userDataForMediaItem = [mediaItemUserData containsItem: [mediaItem valueForProperty: MPMediaItemPropertyPersistentID]];
    return userDataForMediaItem.tagData;
    
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
    //    LogMethod();
    
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return [self.taggedSongSections count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //    LogMethod();
    
    return [self.taggedSongSectionTitles objectAtIndex: section];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //    LogMethod();
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else if (isIndexed) {
        
        return [[NSArray arrayWithObject:@"{search}"] arrayByAddingObjectsFromArray:self.taggedSongSectionTitles];
        //    return self.collectionSectionTitles;
    }  else {
        return nil;
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
    //    LogMethod();
    
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        //        NSLog (@" searchResults count is %d", [searchResults count]);
        return [searchResults count];
    } else {
        
        //        NSString *tagName = [self.taggedSongSectionTitles objectAtIndex: section];
        //
        //        return [[self.taggedSongSections valueForKey: tagName] count];
        TaggedSectionIndexData * sec = self.taggedSongSections[section];
        return sec.sectionRange.length;
        
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
        
        UIColor *sectionHeaderColor;
        
        NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
        if (sectionTitle == nil) {
            return nil;
        }
        
        CGFloat sectionViewHeight;
        CGFloat sectionViewWidth;
        sectionViewWidth = tableView.bounds.size.width;
        
        UILabel *sectionTitleLabel;
        
        sectionViewHeight = 60;
        sectionTitleLabel = [[UILabel alloc] initWithFrame: CGRectMake( 0, 0, sectionViewWidth, sectionViewHeight)];
        sectionTitleLabel.font = [UIFont systemFontOfSize:44];
        
        sectionTitleLabel.backgroundColor = [UIColor clearColor];
        sectionTitleLabel.textAlignment = NSTextAlignmentCenter;
        sectionTitleLabel.textColor = [UIColor yellowColor];
        sectionHeaderColor = [UIColor blackColor];
        
        sectionTitleLabel.text = sectionTitle;
        
        
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionViewWidth, sectionViewHeight)];
        [sectionView setBackgroundColor:sectionHeaderColor];
        
        [sectionView addSubview:sectionTitleLabel];
        CGRect frame = CGRectMake(0, 57, self.songTableView.frame.size.width, 3);
        UIView *separatorLine = [[UILabel alloc] initWithFrame:frame];
        separatorLine.backgroundColor = [UIColor whiteColor];
        [sectionView addSubview: separatorLine];
        
        frame = CGRectMake(0, 0, self.songTableView.frame.size.width, 3);
        separatorLine = [[UILabel alloc] initWithFrame:frame];
        separatorLine.backgroundColor = [UIColor whiteColor];
        [sectionView addSubview: separatorLine];
        return sectionView;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    LogMethod();
    
    if (self.isSearching) {
        return 0;
    } else {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
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
        CGFloat sectionFooterHeight;
        CGFloat sectionFooterWidth;
        UIColor *sectionFooterColor;
        //if there aren't enough for indexing, dispense with the section footers
        if (isIndexed) {
            sectionFooterHeight = 1;
            sectionFooterWidth = tableView.bounds.size.width;
            sectionFooterColor = [UIColor clearColor];
        } else {
            sectionFooterHeight = 0;
            sectionFooterWidth = 0;
        }
        
        UIView *sectionFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionFooterWidth, sectionFooterHeight)];
        [sectionFooter setBackgroundColor:sectionFooterColor];
        
        return sectionFooter;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    LogMethod();
    
    //don't use SongCell for searchResultsCell won't respond to touches to scroll anyway and terrible performance on GoBackClick when autoRotated
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *searchResultsCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	SongCell *cell = (SongCell *)[tableView
                                  dequeueReusableCellWithIdentifier:@"SongCell"];
    
//140116 1.2 iOS 7 begin
    //    //these are necessary to make the grouped cell look like ungrouped (makes the cell wider like ungrouped)
    //    cell.textLabelOffset = 8.0;
    //    // the info button is not far enough to the left with grouped cell, adjust for it here
    //    if (isIndexed) {
    //        cell.cellOffset = 0.0;
    //    } else {
    //        cell.cellOffset = 10.0;
    //    }
//140116 1.2 iOS 7 end
    //
    TaggedSectionIndexData * sec = self.taggedSongSections[indexPath.section];
    //    //    NSLog (@" section is %d", indexPath.section);
    
    
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
        NSString *mediaItemName;
        
        MPMediaItem  *item = [searchResults objectAtIndex: indexPath.row];
        mediaItemName = [item valueForProperty: MPMediaItemPropertyTitle];
        
        searchResultsCell.textLabel.text = mediaItemName;
        
        UIColor *tagColor;
        
        if (showTags) {
            tagColor = [self retrieveTagColorForMediaItem: item];
        } else {
            tagColor = [UIColor blackColor];
        }
//131203 1.2 iOS 7 begin
        
        //        UIImage *cellBackgroundImage = [UIImage imageNamed: @"list-background.png"];
        //        UIImage *coloredImage = [cellBackgroundImage imageWithTint: tagColor];
        //        searchResultsCell.backgroundView = [[UIImageView alloc] initWithImage:coloredImage];
        //        UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"list-background.png"] imageWithTint:tagColor];
        //        [searchResultsCell.textLabel setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
        
        searchResultsCell.backgroundColor = tagColor;
        searchResultsCell.textLabel.backgroundColor = tagColor;
        
//131203 1.2 iOS 7 end
        
        return searchResultsCell;
        
    } else {
        
        MPMediaItem *song;
        
        NSDictionary *dict = self.taggedSongArray [sec.sectionRange.location + indexPath.row];
        song = [dict objectForKey: @"Song"];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.nameLabel.text = [song valueForProperty:  MPMediaItemPropertyTitle];
//131203 1.2 iOS 7 begin
        
        //        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"list-background.png"]];
//        cell.selectedBackgroundView = [UIImageView alloc];
        
//131203 1.2 iOS 7 end
        
        

        
        UIColor *tagColor;
        tagColor = [UIColor blackColor];
        
        if (showTags) {
            TagData *tagData = [dict objectForKey:@"TagData"];
            if (tagData.tagName) {
                
                int red = [tagData.tagColorRed intValue];
                int green = [tagData.tagColorGreen intValue];
                int blue = [tagData.tagColorBlue intValue];
                int alpha = [tagData.tagColorAlpha intValue];
                
                tagColor = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
            }
        }
        
//131203 1.2 iOS 7 begin

//        UIImage *cellBackgroundImage = [UIImage imageNamed: @"list-background.png"];
//        UIImage *coloredImage = [cellBackgroundImage imageWithTint: tagColor];
//        [cell.cellBackgroundImageView  setImage: coloredImage];
        
        cell.contentView.backgroundColor = tagColor;
        
//131203 1.2 iOS 7 end


        
        CGRect frame = CGRectMake(0, 53, self.songTableView.frame.size.width, 1);
        UIView *separatorLine = [[UILabel alloc] initWithFrame:frame];
        separatorLine.backgroundColor = [UIColor whiteColor];
//140122 1.2 iOS 7 begin
//        [cell.cellBackgroundImageView addSubview: separatorLine];
        [cell.backgroundView addSubview: separatorLine];
//140122 1.2 iOS 7 end

        //playback duration of the song
        
        if (isPortrait) {
            showDuration = NO;
            cell.durationLabel.hidden = YES;
        } else {
            showDuration = YES;
            cell.durationLabel.hidden = NO;
            
            
            //if the array has been populated in the background at least to the point of the index, then use the table otherwise calculate the playlistDuration here
            
            
            if ([songDurations count] > (sec.sectionRange.location + indexPath.row)) {
                cell.durationLabel.text = songDurations[sec.sectionRange.location + indexPath.row];
            } else {
                long playbackDuration = [[song valueForProperty: MPMediaItemPropertyPlaybackDuration] longValue];
                
                int playbackHours = (playbackDuration / 3600);                         // returns number of whole hours fitted in totalSecs
                int playbackMinutes = ((playbackDuration / 60) - playbackHours*60);     // Whole minutes
                int playbackSeconds = (playbackDuration % 60);                        // seconds
                cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playbackMinutes, playbackSeconds];
            }
            
        }
        
        //show accessory if not indexed
        if (isIndexed) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [infoButton removeFromSuperview];
        } else {
            //make the accessory view into a custom info button
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            // need to adjust for widened cell for info button
            cell.durationToCellConstraint.constant = 54;
            
            UIImage *image = [UIImage imageNamed: @"infoLightButtonImage.png"];
            UIImage *infoBackgroundImage = [UIImage imageNamed: @"infoSelectedButtonImage.png"];
            
            infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
            
            infoButton.frame = frame;
            [infoButton setImage:image forState:UIControlStateNormal];
            [infoButton setImage: infoBackgroundImage forState:UIControlStateHighlighted];
            [infoButton addTarget:self action:@selector(infoButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
            
            [infoButton setIsAccessibilityElement:YES];
            [infoButton setAccessibilityLabel: NSLocalizedString(@"Info", nil)];
            [infoButton setAccessibilityTraits: UIAccessibilityTraitButton];
            [infoButton setAccessibilityHint: NSLocalizedString(@"View iTunes info and user notes.", nil)];
            
            UIView *superview = cell.contentView;
            
            [infoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [superview addSubview:infoButton];
            
            NSLayoutConstraint *myConstraint = [NSLayoutConstraint
                                                constraintWithItem:infoButton
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:superview
                                                attribute:NSLayoutAttributeTrailing
                                                multiplier:1.0
                                                constant:0];
            
            [superview addConstraint:myConstraint];
            
            myConstraint = [NSLayoutConstraint
                            constraintWithItem:infoButton
                            attribute:NSLayoutAttributeTop
                            relatedBy:NSLayoutRelationEqual
                            toItem:superview
                            attribute:NSLayoutAttributeTop
                            multiplier:1.0
                            constant:-3];
            
            [superview addConstraint:myConstraint];
            
        }
        
        //    NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
        //    NSNumber *duration = [song valueForProperty: MPMediaItemPropertyPlaybackDuration];
        //    NSLog (@"\t\t%@,%@", songTitle,duration);
        
        //set the red arrow on the row if this is the currently playing song
        if ([musicPlayer nowPlayingItem] == song) {
            cell.playingIndicator.image = [UIImage imageNamed:@"playing"];
        } else {
            cell.playingIndicator.image = [UIImage imageNamed:@"notPlaying"];
        }
        return [self handleCellScrolling: cell inTableView: tableView];
        
    }
    
}
- (UIColor *) retrieveTagColorForMediaItem: (MPMediaItem *) mediaItem {
    //    LogMethod();
    
    //check to see if there is user data for this media item
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    UserDataForMediaItem *userDataForMediaItem = [mediaItemUserData containsItem: [mediaItem valueForProperty: MPMediaItemPropertyPersistentID]];
    TagData *tagData = userDataForMediaItem.tagData;
    
    if (userDataForMediaItem.tagData.tagName) {
        
        int red = [tagData.tagColorRed intValue];
        int green = [tagData.tagColorGreen intValue];
        int blue = [tagData.tagColorBlue intValue];
        int alpha = [tagData.tagColorAlpha intValue];
        
        UIColor *tagColor = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        
        return tagColor;
    } else {
        return [UIColor blackColor];
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
- (SongCell *) handleCellScrolling: (SongCell *) cell inTableView: (UITableView *) tableView {
    //    LogMethod();
    
    //    cell.scrollViewToCellConstraint.constant = showDuration ? (30 + 130 + 5) : 48;
//140113 1.2 iOS 7 begin
    int portraitConstant;
    if (isIndexed) {
        portraitConstant = 5;
    } else {
        portraitConstant = 48;
    }
    cell.scrollViewToCellConstraint.constant = showDuration ? (30 + 130 + 5) : portraitConstant;
//140113 1.2 iOS 7 end
    
    //    NSLog (@"constraintConstant is %f", cell.scrollViewToCellConstraint.constant);
    
    NSUInteger scrollViewWidth;
    
    if (showDuration) {
        //        scrollViewWidth = (tableView.frame.size.width - durationLabelSize.width - cell.accessoryView.frame.size.width);
        //        scrollViewWidth = (tableView.frame.size.width - 178);
//140116 1.2 iOS 7 begin
        scrollViewWidth = (tableView.frame.size.width - 178);
        //        scrollViewWidth = (tableView.frame.size.width - 178 - cell.cellOffset);
        
    } else {
        scrollViewWidth = (tableView.frame.size.width - 61);
        //        scrollViewWidth = (tableView.frame.size.width - 61 - cell.cellOffset);
//140116 1.2 iOS 7 end
        
    }
    
    [cell.scrollView removeConstraint:cell.centerXAlignmentConstraint];
    
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
        //this code is needed to prevent scrollable song titles from "flying" around in their scrollview on the 3GS
        [cell.scrollView addConstraint:cell.centerYAlignmentConstraint];
        
        //        NSLog (@"%@ is scrollable", cell.nameLabel.text);
        
    }
    else {
        //        cell.scrollView.hidden = YES;
        //        cell.textLabel.hidden = NO;
        cell.scrollView.scrollEnabled = NO;
        //        [cell.scrollView removeConstraint:cell.centerYAlignmentConstraint];
        
        
    }
    //set to no to enable whole table to respond to scrollsToTop
    
    return cell;
}
#pragma mark - Table view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    //    LogMethod();
    if ([self.searchDisplayController isActive]) {
        
        selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        
        MPMediaItem *searchMediaItem = [searchResults objectAtIndex: selectedIndexPath.row];
        
        selectedSong = searchMediaItem;
        self.songCollection =  [MPMediaItemCollection collectionWithItems: searchResults];
        
        CollectionItem *searchCollectionItem = [CollectionItem alloc];
        searchCollectionItem.name = [selectedSong valueForProperty: MPMediaItemPropertyTitle];
        searchCollectionItem.duration = [self calculatePlaylistDuration: self.songCollection];
        searchCollectionItem.collectionArray = [NSMutableArray arrayWithArray:[self.songCollection items]];
        searchCollectionItem.collection = self.songCollection;
        
        self.collectionItemToSave = searchCollectionItem;
        
    } else {
        
        selectedIndexPath = indexPath;
        
        TaggedSectionIndexData * sec = self.taggedSongSections[indexPath.section];
        //        selectedSong = self.collectionItem.collectionArray[sec.range.location + indexPath.row];
        //
        //        self.songCollection = [MPMediaItemCollection collectionWithItems: self.collectionItem.collectionArray];
        //
        //        NSString *tagName = [self.taggedSongSectionTitles objectAtIndex: indexPath.section];
        ////            NSLog (@" tagName %@", tagName);
        //
        ////            NSArray *songArray = [[NSArray alloc] initWithArray: [self.taggedSongSections valueForKey: tagData.tagName]];
        //        NSArray *songArray = [[NSArray alloc] initWithArray: [self.taggedSongSections valueForKey: tagName]];
        //
        //
        //        NSDictionary *dict = [songArray objectAtIndex: indexPath.row];
        
        NSDictionary *dict = self.taggedSongArray [sec.sectionRange.location + indexPath.row];
        selectedSong = [dict objectForKey: @"Song"];
        
        //            NSLog (@"song is %@", [selectedSong valueForProperty: MPMediaItemPropertyTitle]);
        
        NSMutableArray *collectionArray = [[NSMutableArray alloc] initWithCapacity: [self.taggedSongArray count]];
        for (NSDictionary *dict in self.taggedSongArray) {
            MPMediaItem *song = [dict valueForKey: @"Song"];
            [collectionArray addObject: song];
        }
        self.songCollection = [MPMediaItemCollection collectionWithItems: collectionArray];
        
        self.collectionItem.collection = self.songCollection;
        
        self.collectionItemToSave = self.collectionItem;
        
        //        NSLog (@" self.collectionItemToSave is %@", self.collectionItemToSave);
        
        
        //set the "nowPlaying indicator" as the view disappears (already selected play indicator is still there too :(
        SongCell *cell = (SongCell*)[tableView cellForRowAtIndexPath:selectedIndexPath];
        cell.playingIndicator.image = [UIImage imageNamed:@"playing"];
    }
    [self performSegueWithIdentifier: @"PlaySong" sender: self];
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    LogMethod();
    
	if ([segue.identifier isEqualToString:@"ViewInfo"])
	{
        InfoTabBarController *infoTabBarController = segue.destinationViewController;
        infoTabBarController.managedObjectContext = self.managedObjectContext;
        infoTabBarController.infoDelegate = self;
        infoTabBarController.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
        infoTabBarController.mediaItemForInfo = self.mediaItemForInfo;
        infoTabBarController.mainViewIsSender = NO;
        
        //remove observer for playbackstatechanged because if editing, don't want to pop view
        //  observer will be added back in infoTabBarControllerDidCancel
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                      object: musicPlayer];
        
	}
    if ([segue.identifier isEqualToString:@"PlaySong"])
	{
        
        MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;
        
        mainViewController.itemToPlay = selectedSong;
        mainViewController.collectionItem = self.collectionItem;
        mainViewController.userMediaItemCollection = self.songCollection;
        
        mainViewController.playNew = YES;
        mainViewController.songShuffleButtonPressed = self.songShuffleButtonPressed;
        self.songShuffleButtonPressed = NO;
        
        mainViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
        //save collection in Core Data
        ItemCollection *itemCollection = [ItemCollection alloc];
        itemCollection.managedObjectContext = self.managedObjectContext;
        
        [itemCollection addCollectionToCoreData: self.collectionItemToSave];
        
        
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
- (IBAction)showTagColors {
    if (self.showTags) {
        self.showTags = NO;
        //        self.tagBarButton = self.colorTagBarButton;
        
        NSLog (@"don't show Tags ");
    } else {
        self.showTags = YES;
        //        self.tagBarButton = self.noColorTagBarButton;
        
        NSLog (@"show Tags");
    }
    [self buildRightNavBarArray];
    
    
    //showTags must persist so save to NSUserDefaults
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:self.showTags forKey:@"showTags"];
    
    [self.songTableView reloadData];
}
- (IBAction)goBackClick
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //    [self.navigationController.navigationBar removeGestureRecognizer:self.swipeLeftRight];
    
    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)infoButtonTapped:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    //    NSLog (@"touch is %@" ,touch);
    CGPoint currentTouchPosition = [touch locationInView:self.songTableView];
    //    NSLog (@"touchpoint  is %f %f" , currentTouchPosition.x, currentTouchPosition.y);
    
    NSIndexPath *indexPath = [self.songTableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
    {
        [self tableView: self.songTableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    TaggedSectionIndexData * sec = self.taggedSongSections[indexPath.section];
    NSDictionary *dict = self.taggedSongArray [sec.sectionRange.location + indexPath.row];
    self.mediaItemForInfo = [dict objectForKey: @"Song"];
    
    [self performSegueWithIdentifier: @"ViewInfo" sender: self];
    
}

- (IBAction)playWithShuffle:(id)sender {
    //    LogMethod();
    //Shuffle button selected
    //unpredictable end of playing shuffled songs when this is set here, works to set in mainViewController
    //    [musicPlayer setShuffleMode: MPMusicShuffleModeSongs];
    self.songShuffleButtonPressed = YES;
    
    NSMutableArray *collectionArray = [[NSMutableArray alloc] initWithCapacity: [self.taggedSongArray count]];
    for (NSDictionary *dict in self.taggedSongArray) {
        MPMediaItem *song = [dict valueForKey: @"Song"];
        [collectionArray addObject: song];
    }
    NSMutableArray *shuffleArray = collectionArray;
    
    int max = [shuffleArray count];
    int randNum = arc4random() % max;
    selectedSong = [shuffleArray objectAtIndex: randNum];
    
    self.songCollection = [MPMediaItemCollection collectionWithItems: shuffleArray];
    
    self.collectionItem.collection = self.songCollection;
    
    self.collectionItemToSave = self.collectionItem;
    
    [self performSegueWithIdentifier: @"PlaySong" sender: self];
    
}

- (IBAction) toggleTagButtonAndTitle:(id)sender {
    if (showTagButton) {
        self.showTagButton = NO;
        [self buildRightNavBarArray];
        //title will only be displayed if tag Button is not
        [UIView animateWithDuration:2.5 animations:^{
            self.navigationItem.titleView = [self customizeTitleView];
        }];
        NSLog (@"show Title ");
    } else {
        self.showTagButton = YES;
        [self buildRightNavBarArray];
        [UIView animateWithDuration:0.25 animations:^{
            //            self.title = nil;
            self.navigationItem.titleView = nil;
        }];
        NSLog (@"show Tag Button");
        
    }
}

- (void) registerForMediaPlayerNotifications {
    //    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(reachabilityChanged:)
                               name:kReachabilityChangedNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(tagDataChanged:)
                               name:@"TagDataForItemChanged"
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(tagDataChanged:)
                               name:@"TagDataChanged"
                             object:nil];
    
    [notificationCenter addObserver: self
                           selector: @selector(receiveCellScrolledNotification:)
                               name: @"CellScrolled"
                             object: nil];
    
    [notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
    
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

- (void)reachabilityChanged:(NSNotification *)notification {
    NSLog(@"reachability changed");
    BOOL networkAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"networkAvailable"];
    NSLog (@"networkAvailable BOOL from NSUserDefaults is %d", networkAvailable);
    if (self.collectionContainsICloudItem) {
        if (networkAvailable) {
            excludeICloudItems = NO;
            if (currentDataSourceContainsICloudItems == NO) {
                //    //create the songArray in the background
                //                [self loadSongArrayWithCompletion:^(BOOL result) {
                //                }];
                [self createTaggedSongArray];
                [self prepareArrayDependentData];
                [self.songTableView reloadData];
                [self updateLayoutForNewOrientation: self.interfaceOrientation];
                
            }
        } else {
            //if network is unAvailable
            excludeICloudItems = YES;
            if (currentDataSourceContainsICloudItems == YES) {
                //    //create the songArray in the background
                //                [self loadSongArrayWithCompletion:^(BOOL result) {
                //                }];
                [self createTaggedSongArray];
                [self prepareArrayDependentData];
                [self.songTableView reloadData];
                [self updateLayoutForNewOrientation: self.interfaceOrientation];
                
            }
        }
    }
    
}
- (void)loadSongArrayWithCompletion:(void (^)(BOOL result))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createSongArray];
        
        // Check that there was not a nil handler passed.
        if( completionHandler ){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                //                self.songArrayLoaded = YES;
                NSLog (@"Done Building Song Array in songviewController");
                [self prepareArrayDependentData];
                [self.songTableView reloadData];
            });
        }
    });
}
- (void) createSongArray {
    
    //    MPMediaQuery *mySongQuery = [[MPMediaQuery alloc] init];
    //    mySongQuery = [self.collectionQueryType copy];
    MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue:  [NSNumber numberWithInt: 0]
                                                                                 forProperty:  MPMediaItemPropertyIsCloudItem];
    if (excludeICloudItems) {
        //iCloud items have value 1 for MPMediaItemPropertyIsCloudItem so if excluding them, only choose items with value 0
        
        //        [mySongQuery addFilterPredicate: filterPredicate];
        [self.collectionQueryType addFilterPredicate: filterPredicate];
        
        currentDataSourceContainsICloudItems = NO;
    } else {
        [self.collectionQueryType removeFilterPredicate: filterPredicate];
        currentDataSourceContainsICloudItems = YES;
    }
    //    self.collectionItem.collectionArray = [[mySongQuery items] mutableCopy];
    self.taggedSongArray = [[self.collectionQueryType items] mutableCopy];
    
    
    //    //uncomment to slow the load way way down to test tinyArray
    //    for (MPMediaItem *song in self.songArray) {
    //        NSLog (@"SongName is %@", [song valueForProperty: MPMediaItemPropertyTitle]);
    //    }
    
}
- (void)tagDataChanged:(NSNotification *)notification {
    NSLog(@"tag data changed reload...");
    [self createTaggedSongArray];
    [self loadSectionData];
    if ([self.taggedSongArray count] > 0) {
        
        //create the array in the background
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // Perform async operation
            [self createDurationArray];
        });
    }
    if (isSearching) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void) receiveCellScrolledNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"CellScrolled"]) {
        
        self.cellScrolled = YES;
    }
}

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
// When the now-playing item changes, update the now-playing indicator and reload table
- (void) handle_NowPlayingItemChanged: (id) notification {
    //    LogMethod();
    
    [self.songTableView reloadData];
    self.cellScrolled = NO;
    //    scrolledCellIndexArray = [[NSMutableArray alloc] initWithCapacity: 20];
    
}
//#pragma mark - NotesTabBarControllerDelegate

- (void)infoTabBarControllerDidCancel:(InfoTabBarController *)controller
{
    //    [self willAnimateRotationToInterfaceOrientation: self.interfaceOrientation duration: 1];
    //need to add back observer for playbackStatechanged because it was removed before going to info in case user edits
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
}

- (void)dealloc {
    //    LogMethod();
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"TagDataForItemChanged"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"TagDataChanged"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: @"CellScrolled"
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: musicPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMediaLibraryDidChangeNotification
                                                  object: nil];
    
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    
    //    LogMethod();
    [super viewWillDisappear: animated];
    //remove the swipe gesture from the nav bar  (doesn't work to wait until dealloc) and need to remove it for going forward to info or going backward
    
    [self.navigationController.navigationBar removeGestureRecognizer:self.swipeLeftRight];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end