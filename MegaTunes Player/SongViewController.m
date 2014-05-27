//
//  SongViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
//130911 1.1 add iTunesStoreButton begin
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//130911 1.1 add iTunesStoreButton end
#import "MainViewController.h"
#import "InfoTabBarController.h"
#import "SongViewController.h"
#import "DTCustomColoredAccessory.h"
#import "SongCell.h"
#import "InCellScrollView.h"
#import "CollectionItem.h"
#import "ItemCollection.h"
#import "UIImage+AdditionalFunctionalities.h"
#import "UserDataForMediaItem.h"
#import "MediaItemUserData.h"
#import "MediaGroupViewController.h"
#import "MediaGroupCarouselViewController.h"
#import "Reachability.h"

@interface SongViewController ()
@property (nonatomic, strong) NSArray * songSections;
@property (nonatomic, strong) NSArray * songSectionTitles;
@end

@implementation SongViewController

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
@synthesize listIsAlphabetic;
@synthesize isSearching;
@synthesize songCollection;
@synthesize playBarButton;
@synthesize tagBarButton;
@synthesize colorTagBarButton;
@synthesize noColorTagBarButton;

@synthesize collectionQueryType;        //used as base of query for search
@synthesize searchResults;
//@synthesize collectionPredicate;
@synthesize collectionItemToSave;
@synthesize showTagButton;
@synthesize showTags;
@synthesize songViewTitle;
@synthesize swipeLeftRight;
//@synthesize sectionIndexColor;
@synthesize collectionContainsICloudItem;
@synthesize cellScrolled;
@synthesize songShuffleButtonPressed;
@synthesize tinyArray;
@synthesize mediaGroupViewController;
@synthesize mediaGroupCarouselViewController;

//130912 1.1 add iTunesStoreButton begin
@synthesize completeAlbumButton;
@synthesize collectionType;

@synthesize iTunesStoreSelector;
@synthesize artistLinkUrl;
@synthesize albumLinkUrl;
@synthesize locale;
@synthesize countryCode;
@synthesize albumNameFormatted;
@synthesize artistNameFormatted;
@synthesize songNameFormatted;
@synthesize iTunesLinkUrl;

NSString *myAffiliateID;

//130912 1.1 add iTunesStoreButton end



NSMutableArray *songDurations;
//NSMutableArray *savedDataSource;
//NSNumber *savedPlaylistDuration;
NSIndexPath *selectedIndexPath;
MPMediaItem *selectedSong;
NSString *searchMediaItemProperty;
CGFloat constraintConstant;
//UIImage *backgroundImage;
UIButton *infoButton;
//140220 1.2 iOS 7 begin
UIButton *tempPlayButton;
UIButton *tempColorButton;
UIButton *tempNoColorButton;
//140220 1.2 iOS 7 end

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
    
    self.mediaGroupViewController.delegate = self;
    self.mediaGroupCarouselViewController.delegate = self;
    
    firstLoad = YES;
    self.songShuffleButtonPressed = NO;
    
    self.songViewTitle = self.title;
    self.showTagButton = NO;
    self.songTableView.scrollsToTop = YES;
    self.showTags = [[NSUserDefaults standardUserDefaults] boolForKey:@"showTags"];
    
    
//131203 1.2 iOS 7 begin
    
    self.navigationController.navigationBar.topItem.title = @"";
    //set the navigation bar title
    self.navigationItem.titleView = [self customizeTitleView];

    tempPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempPlayButton addTarget:self action:@selector(viewNowPlaying) forControlEvents:UIControlEventTouchUpInside];
    [tempPlayButton setImage:[UIImage imageNamed:@"redWhitePlayImage.png"] forState:UIControlStateNormal];
    [tempPlayButton setShowsTouchWhenHighlighted:NO];
    [tempPlayButton sizeToFit];
//140127 1.2 iOS 7 end
    
    [self.playBarButton setIsAccessibilityElement:YES];
    [self.playBarButton setAccessibilityLabel: NSLocalizedString(@"Now Playing", nil)];
    [self.playBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
//140124 1.2 iOS 7 begin
    tempColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempColorButton addTarget:self action:@selector(showTagColors) forControlEvents:UIControlEventTouchUpInside];
    [tempColorButton setImage:[UIImage imageNamed:@"colorImage.png"] forState:UIControlStateNormal];
    [tempColorButton setShowsTouchWhenHighlighted:NO];
    [tempColorButton sizeToFit];
//140124 1.2 iOS 7 end
    
    [self.colorTagBarButton setIsAccessibilityElement:YES];
    [self.colorTagBarButton setAccessibilityLabel: NSLocalizedString(@"Show tag colors", nil)];
    [self.colorTagBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
//140124 1.2 iOS 7 begin
    tempNoColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempNoColorButton addTarget:self action:@selector(showTagColors) forControlEvents:UIControlEventTouchUpInside];
    [tempNoColorButton setImage:[UIImage imageNamed:@"noColorImage.png"] forState:UIControlStateNormal];
    [tempNoColorButton setShowsTouchWhenHighlighted:NO];
    [tempNoColorButton sizeToFit];
//140124 1.2 iOS 7 end
    
    [self.noColorTagBarButton setIsAccessibilityElement:YES];
    [self.noColorTagBarButton setAccessibilityLabel: NSLocalizedString(@"Hide tag colors", nil)];
    [self.noColorTagBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    //    self.currentQueue = self.mainViewController.userMediaItemCollection;
    
    //    NSArray *returnedQueue = [self.currentQueue items];
    //
    //    for (MPMediaItem *song in returnedQueue) {
    //        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    //        NSLog (@"\t\t%@", songTitle);
    //    }
    [self registerForMediaPlayerNotifications];
    //    scrolledCellIndexArray = [[NSMutableArray alloc] initWithCapacity: 20];
    self.cellScrolled = NO;
    
    
    
    //list can be alphabetic - if All Songs was chosen or in track order, only index alphabetic with more than 20 rows
    
    self.songTableView.sectionIndexMinimumDisplayRowCount = 20;
    //131203 1.2 iOS 7 begin
    
    [self.songTableView setSectionIndexColor:[UIColor whiteColor]];
    [self.songTableView setSectionIndexBackgroundColor:[UIColor blackColor]];
    
    //131203 1.2 iOS 7 end
    
    isIndexed = NO;
    
    [self prepareArrayDependentData];
    
    //check if collection has ICloud Items
    
    self.collectionContainsICloudItem = NO;
    [self checkForICloudItemsWithCompletion:^(BOOL result) {
        
    }];
    
    
}
- (void) prepareArrayDependentData {
    
    //set up an array of durations to be used in landscape mode
    songDurations = [[NSMutableArray alloc] initWithCapacity: [self.collectionItem.collectionArray count]];
    
    //    NSLog (@" count of collection array %d", [self.collectionItem.collectionArray count]);
    
    if ([self.collectionItem.collectionArray count] > 0) {
        //create the array in the background
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // Perform async operation
            [self createDurationArray];
        });
    }
    if ([self.collectionItem.collectionArray count] > 1) {
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
    if (listIsAlphabetic) {
        if ([self.collectionItem.collectionArray count] >= self.songTableView.sectionIndexMinimumDisplayRowCount) {
            isIndexed = YES;
            // format of collectionSections is <MPMediaQuerySection: 0x1cd34c80> title=B, range={0, 5}, sectionIndexTitleIndex=1,
            
        }
    }
    
    if (tinyArray) {
        MPMediaQuerySection *firstSection = [[self.collectionQueryType collectionSections] objectAtIndex: 0];
        self.songSections = [[NSArray alloc] initWithObjects: firstSection, nil];
        
    } else {
        self.songSections = [self.collectionQueryType collectionSections];
    }
    //    NSLog (@"songSections %@", self.songSections);
    //    NSLog (@"collection %@", self.collectionItem.collectionArray);
    
    NSMutableArray * titles = [NSMutableArray arrayWithCapacity:[self.songSections count]];
    for (MPMediaQuerySection * sec in self.songSections) {
        [titles addObject:sec.title];
    }
    self.songSectionTitles = [titles copy];
    //    NSLog (@"songSectionTitles %@", self.songSectionTitles);
    
//130912 1.1 add iTunesStoreButton begin
    if ([self.collectionType isEqualToString: @"Albums"] || [self.collectionType isEqualToString: @"Artists"]) {
        //get the affliate ID
        myAffiliateID = [[NSUserDefaults standardUserDefaults] stringForKey:@"affiliateID"];
        //show the More button for iTunes
        [self establishITunesLink];
        self.completeAlbumButton.hidden = YES;
        [self.completeAlbumButton addTarget:self action:@selector(linkToiTunesStore:)  forControlEvents:UIControlEventTouchUpInside];
        
        [self.completeAlbumButton setIsAccessibilityElement:YES];
        [self.completeAlbumButton setAccessibilityLabel: NSLocalizedString(@"ITunesStore", nil)];
        [self.completeAlbumButton setAccessibilityTraits: UIAccessibilityTraitButton];
        [self.completeAlbumButton setAccessibilityHint: NSLocalizedString(@"View songs on this album.", nil)];
    } else {
        self.completeAlbumButton.hidden = YES;
    }
//130912 1.1 add iTunesStoreButton end

}
//130911 1.1 add iTunesStoreButton begin
//fetch the iTunes link info in the background
- (void) establishITunesLink {
    self.locale = [NSLocale currentLocale];
    self.countryCode = [self.locale objectForKey: NSLocaleCountryCode];

    //get itunes link        
        
    MPMediaItem *song = [self.collectionItem.collectionArray objectAtIndex: 0];
    
    self.artistNameFormatted = [[song valueForProperty:  MPMediaItemPropertyAlbumArtist] stringByReplacingOccurrencesOfString:@" "
                                                                                                             withString:@"+"];
    
    self.albumNameFormatted = [[song valueForProperty:  MPMediaItemPropertyAlbumTitle] stringByReplacingOccurrencesOfString:@" "
                                                                                                                withString:@"+"];
    
    self.songNameFormatted = [[song valueForProperty: MPMediaItemPropertyTitle] stringByReplacingOccurrencesOfString:@" "
                                                                                                        withString:@"+"];

    NSString *iTunesSearchString;
    
    if ([self.collectionType isEqualToString: @"Albums"]) {
        iTunesSearchString = [NSString stringWithFormat: @"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/itmsSearch?lang=1&output=json&country=%@&term=%@%%20%@%%20%@&media=music&limit=50", self.countryCode, self.artistNameFormatted, self.albumNameFormatted, self.songNameFormatted];
    } else {
        iTunesSearchString = [NSString stringWithFormat: @"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/itmsSearch?lang=1&output=json&country=%@&term=%@%%20%@&media=music&limit=50", self.countryCode, self.artistNameFormatted, self.songNameFormatted];
    }
//    NSString *iTunesSearchString = [NSString stringWithFormat: @"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/itmsSearch?lang=1&output=json&country=US&term=&media=music"];

        NSURL *iTunesSearchURL = [NSURL URLWithString: iTunesSearchString];
        
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            iTunesSearchURL];
            [self performSelectorOnMainThread:@selector(fetchedAlbum:)
                                   withObject:data waitUntilDone:YES];
        });
    
}
//130911 1.1 add iTunesStoreButton end

//- (void) adjustDataSource {
//    BOOL iCloudAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudAvailable"];
//    if (iCloudAvailable) {
//        if (currentDataSourceContainsICloudItems == NO) {
//            self.collectionItem.collectionArray = savedDataSource;
//            self.collectionItem.duration = savedPlaylistDuration;
//            currentDataSourceContainsICloudItems = YES;
//        }
//    } else {
//        if (currentDataSourceContainsICloudItems) {
//            //save the array with all the items and the duration
//            savedDataSource = [self.collectionItem.collectionArray copy];
//            savedPlaylistDuration = [self.collectionItem.duration copy];
//
//            //create a new array without the iCloudItems
//            NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
//            long playlistDuration = 0;
//
//            NSString *isCloudItem = @"0";  // the BOOL MPMediaItemPropertyIsCloudItem seems to be 0, but doesn't work as a BOOL
//
//            for (MPMediaItem *song in savedDataSource) {
//                isCloudItem = [song valueForProperty: MPMediaItemPropertyIsCloudItem];
//                if (isCloudItem.intValue != 1) {  //iCloud items should be 1
//                    [songMutableArray addObject: song];
//                    playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
//                }
//            }
//                //save the new array and duration to use
//            self.collectionItem.collectionArray = songMutableArray;
//            self.collectionItem.duration = [NSNumber numberWithLong: playlistDuration];
//            currentDataSourceContainsICloudItems = NO;
//        }
//    }
//
//}
- (void)checkForICloudItemsWithCompletion:(void (^)(BOOL result))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *mySongQuery = [self.collectionQueryType copy];
        MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue:  [NSNumber numberWithInt: 1]
                                                                                     forProperty:  MPMediaItemPropertyIsCloudItem];
        [mySongQuery addFilterPredicate: filterPredicate];
        NSArray *filteredArray = [mySongQuery items];
        if ([filteredArray count] > 0) {
            self.collectionContainsICloudItem = YES;
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
    
    for (MPMediaItem *song in self.collectionItem.collectionArray) {
        //get the duration of the item
        
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
//130911 1.1 add iTunesStoreButton begin

- (void)fetchedAlbum:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    self.albumLinkUrl = nil;
    self.artistLinkUrl = nil;
    
    MPMediaItem *song = [self.collectionItem.collectionArray objectAtIndex: 0];
    
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
                if ([self.collectionType isEqualToString: @"Albums"]) {
                    if ([[item objectForKey: @"itemParentName"] isEqualToString: [song valueForProperty:  MPMediaItemPropertyAlbumTitle]]
                    && [[item objectForKey: @"kind"] isEqualToString: @"song"]
    //                && [[item objectForKey: @"itemName"] isEqualToString: [song valueForProperty:  MPMediaItemPropertyTitle]]
                    && [[item objectForKey: @"artistName"] isEqualToString: [song valueForProperty:  MPMediaItemPropertyAlbumArtist]]) {

                        self.albumLinkUrl = [item objectForKey: @"itemParentLinkUrl"];
                        break;
                    }
                } else {
                    if ([[item objectForKey: @"kind"] isEqualToString: @"song"]
    //                    && [[item objectForKey: @"itemName"] isEqualToString: [song valueForProperty:  MPMediaItemPropertyTitle]]
                        && [[item objectForKey: @"artistName"] isEqualToString: [song valueForProperty:  MPMediaItemPropertyAlbumArtist]]) {
                        
                        self.artistLinkUrl = [item objectForKey: @"artistLinkUrl"];
                        break;
                    }
                }
            }
        }
    }
    
    if (self.albumLinkUrl || self.artistLinkUrl) {
        self.completeAlbumButton.hidden = NO;
//        [self.songTableView reloadData];
    }
//    if (self.artistLinkUrl) {
    NSLog (@"artistLinkUrl is %@", self.artistLinkUrl);
    NSLog (@"albumLinkUrl is %@", self.albumLinkUrl);

//        self.completeAlbumButton.hidden = NO;
//    }
    
    //itemLinkUrl = "https://itunes.apple.com/us/album/you-love-me/id464532842?i=464532972&uo=4";
}
//130911 1.1 add iTunesStoreButton end
- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
//131216 1.2 iOS 7 begin
    //this moved here when goBackClick removed
    if (iPodLibraryChanged) {
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
//131216 1.2 iOS 7 end
    self.swipeLeftRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTagButtonAndTitle:)];
    [self.swipeLeftRight setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
    [self.navigationController.navigationBar addGestureRecognizer:self.swipeLeftRight];
    
//    [self buildRightNavBarArray];
    
    
    //    // if rows have been scrolled, they have been added to this array, so need to scroll them back to 0
    //    YAY this works!!
    //    if ([scrolledCellIndexArray count] > 0) {
    if (self.cellScrolled) {
        //        for (NSIndexPath *indexPath in scrolledCellIndexArray) {
        for (NSIndexPath *indexPath in [self.songTableView indexPathsForVisibleRows]) {
            //            if (indexPath.row > 0) {
            
            //            NSLog (@" indexPath to scroll %@", indexPath);
            SongCell *cell = (SongCell *)[self.songTableView cellForRowAtIndexPath:indexPath];
            [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            //            }
        }
        //        [self.songTableView reloadRowsAtIndexPaths:scrolledCellIndexArray withRowAnimation: UITableViewRowAnimationNone];
        
        //        [scrolledCellIndexArray removeAllObjects];
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
    
    CGFloat navBarAdjustment = isPortrait ? 0 : 9;
    
    if (isPortrait) {

        [tempPlayButton setContentEdgeInsets: UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
        self.playBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempPlayButton];
        
        [tempColorButton setContentEdgeInsets: UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
        self.colorTagBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempColorButton];

        [tempNoColorButton setContentEdgeInsets: UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
        self.noColorTagBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempNoColorButton];
        
    } else {

        [tempPlayButton setContentEdgeInsets: UIEdgeInsetsMake(3.0, 0.0, -3.0, 0.0)];
        self.playBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempPlayButton];

        [tempColorButton setContentEdgeInsets: UIEdgeInsetsMake(3.0, 0.0, -3.0, 0.0)];
        self.colorTagBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempColorButton];
        
        [tempNoColorButton setContentEdgeInsets: UIEdgeInsetsMake(3.0, 0.0, -3.0, 0.0)];
        self.noColorTagBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempNoColorButton];
        
    }
    
    [self buildRightNavBarArray];
    
//131216 1.2 iOS 7 end
    
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
    
    searchResults = [mySongQuery items];
    
    NSLog (@"searchResults %@", searchResults);
    
    
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
        //        if (isIndexed) {
        return [self.songSections count];
        //        } else {
        //            return 1;
        //        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //    LogMethod();
    
    MPMediaQuerySection * sec = nil;
    sec = self.songSections[section];
    return sec.title;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //    LogMethod();
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else if (listIsAlphabetic) {
        
        return [[NSArray arrayWithObject:@"{search}"] arrayByAddingObjectsFromArray:self.songSectionTitles];
        //    return self.collectionSectionTitles;
    }  else {
        return nil;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //    LogMethod();
    
    NSLog (@"SectionIndexTitle is %@ at index %d", title, index);
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
        MPMediaQuerySection * sec = self.songSections[section];
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
        CGFloat sectionHeaderHeight;
        CGFloat sectionHeaderWidth;
        UIColor *sectionHeaderColor;
        //if there aren't enough for indexing, dispense with the section headers
        if (isIndexed) {
            sectionHeaderHeight = 10;
            sectionHeaderWidth = tableView.bounds.size.width;
            sectionHeaderColor = [UIColor whiteColor];
        } else {
            sectionHeaderHeight = 0;
            sectionHeaderWidth = 0;
        }
        
        UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionHeaderWidth, sectionHeaderHeight)];
        [sectionHeader setBackgroundColor:sectionHeaderColor];
        //    [sectionView addSubview:label];
        
        return sectionHeader;
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
            sectionFooterColor = [UIColor whiteColor];
        } else {
            sectionFooterHeight = 0;
            sectionFooterWidth = 0;
        }
        
        UIView *sectionFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionFooterWidth, sectionFooterHeight)];
        [sectionFooter setBackgroundColor:sectionFooterColor];
        //    [sectionView addSubview:label];
        
        return sectionFooter;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    LogMethod();
    
    //don't use SongCell for searchResultsCell won't respond to touches to scroll anyway and terrible performance on return when autoRotated
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
    
    MPMediaQuerySection * sec = self.songSections[indexPath.section];
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
        NSString *mediaItemName;
        //        MPMediaItemCollection *searchCollection = [searchResults objectAtIndex: indexPath.row];
        
        MPMediaItem  *item = [searchResults objectAtIndex: indexPath.row];
        mediaItemName = [item valueForProperty: MPMediaItemPropertyTitle];
        
        
        //        NSArray *searchCollectionArray = [searchCollection items];
        //        for (MPMediaItem *item in searchCollectionArray) {
        //            //            NSLog (@" whatIsThis %@", [[artistCollection representativeItem] valueForProperty: MPMediaItemPropertyAlbumArtist]);
        //            NSLog (@" whatIsThis %@", [item valueForProperty: MPMediaItemPropertyTitle]);
        //        }
        searchResultsCell.textLabel.text = mediaItemName;
        
        UIColor *tagColor;
        
        if (showTags) {
            tagColor = [self retrieveTagColorForMediaItem: item];
        } else {
            tagColor = [UIColor blackColor];
        }

//131203 1.2 iOS 7 begin
        searchResultsCell.backgroundColor = tagColor;
        searchResultsCell.textLabel.backgroundColor = tagColor;
        
//131203 1.2 iOS 7 end

        return searchResultsCell;
        
    } else {
        
        //    MPMediaItem *song = [self.collectionItem.collectionArray objectAtIndex:indexPath.row];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        MPMediaItem *song = self.collectionItem.collectionArray[sec.range.location + indexPath.row];
        
        cell.nameLabel.text = [song valueForProperty:  MPMediaItemPropertyTitle];
        //        NSLog (@"song in table is %@", cell.nameLabel.text);
        
//131203 1.2 iOS 7 begin

        cell.selectedBackgroundView = [UIImageView alloc];

//131203 1.2 iOS 7 end

        UIColor *tagColor;
        
        if (showTags) {
            tagColor = [self retrieveTagColorForMediaItem: song];
        } else {
            tagColor = [UIColor blackColor];
        }
        
//131203 1.2 iOS 7 begin

        cell.contentView.backgroundColor = tagColor;
        
//131203 1.2 iOS 7 end

        CGRect frame = CGRectMake(0, 53, self.songTableView.frame.size.width, 1);
        UIView *separatorLine = [[UILabel alloc] initWithFrame:frame];
        separatorLine.backgroundColor = [UIColor whiteColor];
//        [cell.cellBackgroundImageView addSubview: separatorLine];
        [cell.backgroundView addSubview:separatorLine];
        

        
        //playback duration of the song
        
        if (isPortrait) {
            showDuration = NO;
            cell.durationLabel.hidden = YES;
        } else {
            showDuration = YES;
            cell.durationLabel.hidden = NO;
            
            //if the array has been populated in the background at least to the point of the index, then use the table otherwise calculate the playlistDuration here
            if ([songDurations count] > (sec.range.location + indexPath.row)) {
                cell.durationLabel.text = songDurations[sec.range.location + indexPath.row];
            } else {
                long playbackDuration = [[song valueForProperty: MPMediaItemPropertyPlaybackDuration] longValue];
                
                int playbackHours = (playbackDuration / 3600);                         // returns number of whole hours fitted in totalSecs
                int playbackMinutes = ((playbackDuration / 60) - playbackHours*60);     // Whole minutes
                int playbackSeconds = (playbackDuration % 60);                        // seconds
                cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playbackMinutes, playbackSeconds];
            }
            
        }
        
        //show accessory if not indexed
        if (isIndexed || tinyArray) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [infoButton removeFromSuperview];
        } else {
            //make the accessory view into a custom info button
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            // need to adjust for widened cell for info button
            cell.durationToCellConstraint.constant = 54;
            
            UIImage *image = [UIImage imageNamed: @"whiteInfoImage.png"];
            UIImage *infoBackgroundImage = [UIImage imageNamed: @"blueInfoImage.png"];

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
                            constant:7];
            
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
        //
        //        // Display text
        //
        //        //cell.durationLabel.frame.size.width = 111 - have to hard code because not calculated yet at this point
        //
        //        CGFloat contraintConstant = isPortrait ? 50 : (50 + 111 + 5);
        //
        //        cell.scrollViewToCellConstraint.constant = contraintConstant;
        //
        //        cell.nameLabel.text = [song valueForProperty:  MPMediaItemPropertyTitle];
        //        //set the textLabel to the same thing - it is used if the text does not need to scroll
        //
        ////        cell.textLabel.font = [UIFont systemFontOfSize:44];
        ////        cell.textLabel.textColor = [UIColor whiteColor];
        ////        cell.textLabel.highlightedTextColor = [UIColor blueColor];
        ////        cell.textLabel.backgroundColor = [UIColor clearColor];
        ////    //    cell.textLabel.lineBreakMode = NSLineBreakByClipping;
        ////        cell.textLabel.text = cell.nameLabel.text;
        //
        //        [cell.scrollView removeConstraint:cell.centerXAlignmentConstraint];
        //        //calculate the label size to fit the text with the font size
        //        CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
        //                                           constrainedToSize:CGSizeMake(INT16_MAX, tableView.rowHeight)
        //                                               lineBreakMode:NSLineBreakByClipping];
        //
        //        //calculate the width of the actual scrollview
        //        //cell.playingIndicator is 20
        //        //durationLabelSize.width is 111
        //        //cell.accessoryView.frame.size.width is 42
        //        // so scrollViewWidth should be 480-24-98-42 = 316   or 320-28-42= 250
        //        NSUInteger scrollViewWidth;
        //
        //        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        //            scrollViewWidth = (tableView.frame.size.width - 32 - cell.accessoryView.frame.size.width);
        //        } else {
        //            scrollViewWidth = (tableView.frame.size.width - 24 - 111 - cell.accessoryView.frame.size.width);
        //        }
        //        //Make sure that label is aligned with scrollView
        //        [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        //
        //        cell.scrollView.delegate = cell.scrollView;
        //        cell.scrollView.scrollEnabled = YES;
        //        //        NSLog (@"scrollEnabled");
        //
        //        if (labelSize.width>scrollViewWidth) {
        ////            cell.scrollView.hidden = NO;
        ////            cell.textLabel.hidden = YES;
        //            cell.scrollView.scrollEnabled = YES;
        ////            [cell.scrollView addConstraint:cell.centerYAlignmentConstraint];
        //
        //        }
        //        else {
        ////            cell.scrollView.hidden = YES;
        ////            cell.textLabel.hidden = NO;
        //            cell.scrollView.scrollEnabled = NO;
        ////            [cell.scrollView removeConstraint:cell.centerYAlignmentConstraint];
        //
        //        }
        //        return cell;
    }
    
}
- (UIColor *) retrieveTagColorForMediaItem: (MPMediaItem *) mediaItem {
    
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
    int landscapeConstant;
    if (isIndexed || tinyArray) {
        portraitConstant = 5;
        landscapeConstant = 0;
    } else {
        portraitConstant = 48;
        landscapeConstant = 30;
    }
    cell.scrollViewToCellConstraint.constant = showDuration ? (landscapeConstant + 130 + 5) : portraitConstant;
//140113 1.2 iOS 7 end
    
    //    NSLog (@"constraintConstant is %f", cell.scrollViewToCellConstraint.constant);
    
    NSUInteger scrollViewWidth;
    
    if (showDuration) {
        //        scrollViewWidth = (tableView.frame.size.width - durationLabelSize.width - cell.accessoryView.frame.size.width);
//140116 1.2 iOS 7 begin
        scrollViewWidth = (tableView.frame.size.width - 178);
//        scrollViewWidth = (tableView.frame.size.width - 178 - cell.cellOffset);
        
    } else {
        scrollViewWidth = (tableView.frame.size.width - 61);
//        scrollViewWidth = (tableView.frame.size.width - 61 - cell.cellOffset);
//140116 1.2 iOS 7 end
    }
    
    [cell.scrollView removeConstraint:cell.centerXAlignmentConstraint];
    
//131210 1.2 iOS 7 begin
    
    //calculate the label size to fit the text with the font size
//    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
//                                       constrainedToSize:CGSizeMake(INT16_MAX,cell.frame.size.height)
//                                           lineBreakMode:NSLineBreakByClipping];
    
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:cell.nameLabel.text
                                                                        attributes:@{NSFontAttributeName: cell.nameLabel.font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize)CGSizeMake(INT16_MAX,cell.frame.size.height)
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
        
        MPMediaQuerySection * sec = self.songSections[indexPath.section];
        selectedSong = self.collectionItem.collectionArray[sec.range.location + indexPath.row];
        self.songCollection = [MPMediaItemCollection collectionWithItems: self.collectionItem.collectionArray];
        
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
        //        self.collectionItem.collection = [MPMediaItemCollection collectionWithItems: self.collectionItem.collectionArray];
        
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
        
        //        [itemCollection addCollectionToCoreData: self.collectionItem];
        [itemCollection addCollectionToCoreData: self.collectionItemToSave];
        
        
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
    //    [standardUserDefaults synchronize];
    
    [self.songTableView reloadData];
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
    
    MPMediaQuerySection * sec = self.songSections[indexPath.section];
    MPMediaItem *song = self.collectionItem.collectionArray[sec.range.location + indexPath.row];
    //    MPMediaItem *song = [self.collectionItem.collectionArray objectAtIndex:indexPath.row];
    
    self.mediaItemForInfo = song;
    
    [self performSegueWithIdentifier: @"ViewInfo" sender: self];
}

- (IBAction)playWithShuffle:(id)sender {
    //    LogMethod();
    //Shuffle button selected
    //unpredictable end of playing shuffled songs when this is set here, works to set in mainViewController
    //    [musicPlayer setShuffleMode: MPMusicShuffleModeSongs];
    self.songShuffleButtonPressed = YES;
    
    //    int min = 0;
    //    int max = [self.collectionItem.collectionArray count] -1;
    //    int randNum = rand() % (max - min) + min; //create the random number.
    
    int max = [self.collectionItem.collectionArray count];
    int randNum = arc4random() % max;
    
    selectedSong = [self.collectionItem.collectionArray objectAtIndex: randNum];
    
    self.songCollection = [MPMediaItemCollection collectionWithItems: self.collectionItem.collectionArray];
    self.collectionItem.collection = self.songCollection;
    
    self.collectionItemToSave = self.collectionItem;
    
    [self performSegueWithIdentifier: @"PlaySong" sender: self];
    
}

- (IBAction) toggleTagButtonAndTitle:(id)sender {
    if (showTagButton) {
        self.showTagButton = NO;
        [self buildRightNavBarArray];
        //title will only be displayed if tag Button is not
        //        self.title = NSLocalizedString(self.songViewTitle, nil);
        [UIView animateWithDuration:2.5 animations:^{
            //            self.navigationItem.rightBarButtonItem = nil;
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
    
    //    [notificationCenter addObserver: self
    //                           selector: @selector (iCloudAccountAvailabilityChanged:)
    //                               name: NSUbiquityIdentityDidChangeNotification
    //                             object: nil];
    [notificationCenter addObserver:self
                           selector:@selector(reachabilityChanged:)
                               name:kReachabilityChangedNotification
                             object:nil];
    
    [notificationCenter addObserver: self
                           selector: @selector(receiveCellScrolledNotification:)
                               name: @"CellScrolled"
                             object: nil];
    
    //    [notificationCenter addObserver: self
    //                           selector: @selector(receiveSongArrayLoadedNotification:)
    //                               name: @"SongArrayLoaded"
    //                             object: nil];
    
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
                [self createSongArray];
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
                [self createSongArray];
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
    self.collectionItem.collectionArray = [[self.collectionQueryType items] mutableCopy];
    
    
    //    //uncomment to slow the load way way down to test tinyArray
    //    for (MPMediaItem *song in self.songArray) {
    //        NSLog (@"SongName is %@", [song valueForProperty: MPMediaItemPropertyTitle]);
    //    }
    
}
- (void) receiveCellScrolledNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"CellScrolled"]) {
        
        //        NSDictionary *userInfo = notification.userInfo;
        //
        //        UIEvent *touchEvent = [userInfo objectForKey:@"touchKey"];
        //
        //        NSSet *touches = [touchEvent allTouches];
        //        UITouch *touch = [touches anyObject];
        //        CGPoint currentTouchPosition = [touch locationInView:self.songTableView];
        //        NSIndexPath *indexPath = [self.songTableView indexPathForRowAtPoint: currentTouchPosition];
        //
        //        NSLog (@" touch in indexPath %d", indexPath.row);
        //
        //        BOOL addIndexPath = YES;
        //        // Add to index path array
        //        if (indexPath) {
        //            for (NSIndexPath *existingIndexPath in scrolledCellIndexArray) {
        //                if (indexPath == existingIndexPath) {
        //                    addIndexPath = NO;
        //                }
        //            }
        //            if (addIndexPath) {
        //                [scrolledCellIndexArray addObject:indexPath];
        //            }
        //        }
        self.cellScrolled = YES;
    }
}
//130909 1.1 add iTunesStoreButton begin

- (IBAction)linkToiTunesStore:(id)sender {

    if ([self.collectionType isEqualToString: @"Albums"]) {
        self.iTunesLinkUrl = [NSString stringWithFormat: @"%@&%@", self.albumLinkUrl, myAffiliateID];
    } else {
        self.iTunesLinkUrl = [NSString stringWithFormat: @"%@&%@", self.artistLinkUrl, myAffiliateID];

    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.iTunesLinkUrl]];
    
    NSLog (@"iTunesLink is %@", self.iTunesLinkUrl);
    
}

//130909 1.1 add iTunesStoreButton end
//- (void) receiveSongArrayLoadedNotification:(NSNotification *) notification
//{
//
//    self.collectionItem.collectionArray = self.mediaGroupViewController.songMutableArray;
//    tinyArray = NO;
//    [self prepareArrayDependentData];
//    [self.songTableView reloadData];
//
//}
//- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingSongArray:(NSArray *)array
//{
//    LogMethod();
//
//    self.collectionItem.collectionArray = [array mutableCopy];
//    tinyArray = NO;
//    listIsAlphabetic = YES;
//    [self prepareArrayDependentData];
//    [self.songTableView reloadData];
//}
- (void) viewController:(id) controller didFinishLoadingSongArray:(NSArray *)array
{
    //    LogMethod();
    //only reload if the query is for all songs, other views of songs (playlists, artist, etc. should not reload)
    if (self.collectionQueryType == [MPMediaQuery songsQuery]) {
        self.collectionItem.collectionArray = [array mutableCopy];
        tinyArray = NO;
        listIsAlphabetic = YES;
        [self prepareArrayDependentData];
        [self.songTableView reloadData];
    }
}

- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTinySongArray:(NSArray *) array{
    //part of delegate protocol but doesn't need to do anything here
}
- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTaggedSongArray:(NSArray *) array {
    //part of delegate protocol but doesn't need to do anything here
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
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: @"CellScrolled"
                                                  object: nil];
    //    
    //    [[NSNotificationCenter defaultCenter] removeObserver: self
    //                                                    name: @"SongArrayLoaded"
    //                                                  object: nil];
    
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
    [self.navigationController.navigationBar removeGestureRecognizer:self.swipeLeftRight];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
