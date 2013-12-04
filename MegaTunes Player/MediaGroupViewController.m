//
//  MediaGroupViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import "MediaGroupViewController.h"
#import "ArtistViewController.h"
#import "MediaGroup.h"
#import "MediaGroupCell.h"
#import "SongViewController.h"
#import "CollectionItem.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"
#import "AlbumViewcontroller.h"
#import "GenreViewController.h"
#import "MediaGroupCarouselViewController.h"
#import "TagData.h"
#import "MediaItemUserData.h"
#import "UserDataForMediaItem.h"
#import "TaggedSongViewController.h"
#import "AppDelegate.h"


@interface MediaGroupViewController ()

@end

@implementation MediaGroupViewController

@synthesize delegate;
@synthesize groupTableView;
@synthesize collection;
@synthesize groupingData;
@synthesize selectedGroup;
@synthesize musicPlayer;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize isShowingLandscapeView;
@synthesize rightBarButton;
@synthesize initialView;
@synthesize mediaGroupCarouselViewController;
@synthesize pView;
@synthesize lView;
@synthesize appDelegate;
@synthesize songArray;
@synthesize tinySongMutableArray;
@synthesize tinySongArray;
@synthesize sortedTaggedArray;

@synthesize playlistDuration;
@synthesize taggedPlaylistDuration;
//@synthesize collectionContainsICloudItem;
@synthesize songArrayLoaded;
@synthesize taggedSongArrayLoaded;
@synthesize tinySongArrayLoaded;
@synthesize currentDataSourceContainsICloudItems;


@synthesize initialPortraitImage;
@synthesize initialLandscapeImage;

UIViewController *presentingViewController;

NSMutableArray *songArrayToLoad;

UIAlertView *alert;
BOOL listIsAlphabetic;

//130906 1.1 add Store Button begin
NSString *myAffiliateID;
//130906 1.1 add Store Button end



#pragma mark - Initial Display methods

- (void)awakeFromNib
{
    //    LogMethod();
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self.navigationController setDelegate: self];
    
    self.pView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-568h.png"]];
    self.lView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundLandscape-568h.png"]];
    
}
// Called when a new view is shown before viewDidAppear

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    //    LogMethod();
    // May be coming back from another controller to find we're
    // showing the wrong controller for the orientation.
    presentingViewController = (UIViewController *)viewController;
    [self createTempBackgroundForSwap];
}
// Called when a new view is shown. (
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    //    LogMethod();
    // May be coming back from another controller to find we're
    // showing the wrong controller for the orientation.
    [self swapControllersIfNeeded];
}
// Method to handle orientation changes.
- (void)orientationChanged:(NSNotification *)notification
{
    //    LogMethod();
    
    [self swapControllersIfNeeded];
}
- (void) createTempBackgroundForSwap
{
    //    LogMethod();
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        presentingViewController == self)
    {
        // NOTE: PUSHING A NEW VIEW CONTROLLER BEFORE viewDidAppear causes issues for the pop later - so just instantiate and build background here, push after viewDidAppear in swapControllerIfNeeded method
        
        self.mediaGroupCarouselViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaGroupCarouselView"];
        self.mediaGroupCarouselViewController.mediaGroupViewController = self;
        self.mediaGroupCarouselViewController.taggedSongArrayLoaded = self.taggedSongArrayLoaded;
        self.mediaGroupCarouselViewController.songArrayLoaded = self.songArrayLoaded;
        self.mediaGroupCarouselViewController.tinySongArrayLoaded = self.tinySongArrayLoaded;
        self.mediaGroupCarouselViewController.tinySongArray = self.tinySongArray;
        self.mediaGroupCarouselViewController.songArray = self.songArray;
        self.mediaGroupCarouselViewController.sortedTaggedArray = self.sortedTaggedArray;
        
        //initialLandscapeImage is created from the Playlist carousel view the first time it is loaded
        if (self.initialLandscapeImage) {
            UIImageView *lImageView =[[UIImageView alloc] initWithImage: initialLandscapeImage];
            CGRect frame = lImageView.frame;
            frame.origin.x = (self.view.bounds.size.width / 2 - lImageView.frame.size.width / 2);
            frame.origin.y = (self.view.bounds.size.height / 2 - lImageView.frame.size.height / 2 - 11);
            lImageView.frame = frame;
            
            [self.lView addSubview: lImageView];
            
        }
        [self.view addSubview: self.lView];
    }
    
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             presentingViewController == self.mediaGroupCarouselViewController)
    {
        //initialPortraitImage is a screen image of the portrait screen the first time it is loaded
        
        if (self.initialPortraitImage) {
            //            self.pView =[[UIImageView alloc] initWithImage: initialPortraitImage];
            //            CGRect frame = self.pView.frame;
            //            frame.origin.y = 11.0f;
            //            self.pView.frame = frame;
            UIImageView *pImageView =[[UIImageView alloc] initWithImage: initialPortraitImage];
            CGRect frame = pImageView.frame;
            //            frame.origin.x = (self.view.bounds.size.width / 2 - pImageView.frame.size.width / 2);
            //            frame.origin.y = (self.view.bounds.size.height / 2 - pImageView.frame.size.height / 2 - 11);
            frame.origin.y = 11.0f;
            pImageView.frame = frame;
            
            [self.pView addSubview: pImageView];
        }
        [self.mediaGroupCarouselViewController.view addSubview: self.pView];
        
    }
}
- (void)swapControllersIfNeeded
{
    //    LogMethod();
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    // Check that we're not showing the wrong controller for the orientation.
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        self.navigationController.visibleViewController == self)
    {
        // Orientation is landscape but the visible controller is this one,
        // which is the portrait one.
        // Create new instance of landscape controller from the storyboard.
        // Use a property to keep track of it because we need it for
        // the check in the else branch.
        // If it was already instantiated in createTempBackgroundForSwap, then just push
        if (!self.mediaGroupCarouselViewController) {
            self.mediaGroupCarouselViewController =
            [self.storyboard instantiateViewControllerWithIdentifier:@"MediaGroupCarouselView"];
            self.mediaGroupCarouselViewController.mediaGroupViewController = self;
            self.mediaGroupCarouselViewController.taggedSongArrayLoaded = self.taggedSongArrayLoaded;
            self.mediaGroupCarouselViewController.songArrayLoaded = self.songArrayLoaded;
            self.mediaGroupCarouselViewController.tinySongArrayLoaded = self.tinySongArrayLoaded;
            self.mediaGroupCarouselViewController.tinySongArray = self.tinySongArray;
            self.mediaGroupCarouselViewController.songArray = self.songArray;
            self.mediaGroupCarouselViewController.sortedTaggedArray = self.sortedTaggedArray;
        }
        // Push the new controller rather than use a segue so that we can do it
        // without animation.
        [self.navigationController pushViewController:self.mediaGroupCarouselViewController
                                             animated:NO];
        [self.lView removeFromSuperview];
        
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             self.navigationController.visibleViewController == self.mediaGroupCarouselViewController)
    {
        // Orientation is portrait but the visible controller is
        // the landscape controller. Pop the top controller, we
        // know the portrait controller, self, is the next one down.
        //        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController popToRootViewControllerAnimated:NO];
        self.mediaGroupCarouselViewController = nil;
        [self.pView removeFromSuperview];
        
    }
}

- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
    
    self.initialView = YES;
    
    songArrayToLoad = [[NSMutableArray alloc] initWithCapacity: 19];
    
//131203 1.2 iOS 7 begin

    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
//131203 1.2 iOS 7 end

//130906 1.1 add Store Button begin
    //get the affliate ID
    myAffiliateID = [[NSUserDefaults standardUserDefaults] stringForKey:@"affiliateID"];
    
    self.navigationItem.backBarButtonItem = nil; // Important
    //initWithTitle cannot be nil, must be @""
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @""
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(linkToiTunesStore)];

    UIImage *menuBarImage48 = [[UIImage imageNamed:@"iTunesStoreIcon57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImage58 = [[UIImage imageNamed:@"iTunesStoreIcon68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];

//130906 1.1 add Store Button end

    self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(viewNowPlaying)];
    
    UIImage *menuBarImageDefault = [[UIImage imageNamed:@"redWhitePlay57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"redWhitePlay68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.rightBarButton setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.rightBarButton setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    [self.rightBarButton setIsAccessibilityElement:YES];
    [self.rightBarButton setAccessibilityLabel: NSLocalizedString(@"Now Playing", nil)];
    [self.rightBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    
    self.appDelegate = (id) [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    //    BOOL networkAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"networkAvailable"];
    //    if (networkAvailable) {
    //        excludeICloudItems = NO;
    //    } else {
    //        excludeICloudItems = YES;
    //    }
    [self loadSongArraysInBackground];
    
    
    [self loadGroupingData];
    
}
-(void) loadSongArraysInBackground  {
    //    //create the tinySongArray in the background
    [self loadTinySongArrayWithCompletion:^(BOOL result) {
        
    }];
    //    //create the songArray in the background
    [self loadSongArrayWithCompletion:^(BOOL result) {
        
    }];
    
    //create the taggedSongArray in the background
    [self loadTaggedSongArrayWithCompletion:^(BOOL result) {
        
    }];
    
    //    self.collectionContainsICloudItem = NO;
    //    [self checkForICloudItemsWithCompletion:^(BOOL result) {
    //
    //    }];
}

- (void)loadTinySongArrayWithCompletion:(void (^)(BOOL result))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // load the first section of data only to this tiny array, it will be displayed until the full array loads
        self.tinySongMutableArray = [[NSMutableArray alloc] initWithCapacity: 19];
        
        MPMediaQuery *mySongQuery = [MPMediaQuery songsQuery];
        MPMediaQuerySection *firstSection = [[mySongQuery collectionSections] objectAtIndex: 0];
        NSRange firstRange = firstSection.range;
        int endOfRange = firstRange.length;
        int i;
        for (i = 0; i < endOfRange; i++) {
            MPMediaItem *song = [[mySongQuery items] objectAtIndex: i];
            [self.tinySongMutableArray addObject: song];
            //        NSLog (@"song in tinyArray is %@", [song valueForProperty: MPMediaItemPropertyTitle]);
            
        }
        
        self.tinySongArray = [self.tinySongMutableArray mutableCopy];
        //uncomment to slow the load way way down to test tinyArray
        
        //        NSArray *tempArray = [mySongQuery items];
        //        for (MPMediaItem *song in self.tinySongArray) {
        //            NSLog (@"TinySongName is %@", [song valueForProperty: MPMediaItemPropertyTitle]);
        //        }
        
        // Check that there was not a nil handler passed.
        if( completionHandler ){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                self.tinySongArrayLoaded = YES;
                [self hideActivityIndicator];
                [self.delegate viewController:self didFinishLoadingTinySongArray:self.tinySongArray];
                NSLog (@"Done Building Tiny Song Array");
            });
        }
    });
}
- (void)loadSongArrayWithCompletion:(void (^)(BOOL result))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createSongArray];
        
        // Check that there was not a nil handler passed.
        if( completionHandler ){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                self.songArrayLoaded = YES;
                [self hideActivityIndicator];
                [self.delegate viewController:self didFinishLoadingSongArray:self.songArray];
                NSLog (@"Done Building Song Array");
            });
        }
    });
}

- (void) createSongArray {
    
    MPMediaQuery *mySongQuery = [MPMediaQuery songsQuery];
    
    self.songArray = [mySongQuery items];
    
    //    //uncomment to slow the load way way down to test tinyArray
    //    for (MPMediaItem *song in self.songArray) {
    //        NSLog (@"SongName is %@", [song valueForProperty: MPMediaItemPropertyTitle]);
    //    }
    
}
- (void)loadTaggedSongArrayWithCompletion:(void (^)(BOOL result))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createTaggedSongArray];
        
        // Check that there was not a nil handler passed.
        if( completionHandler ){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                self.taggedSongArrayLoaded = YES;
                [self hideActivityIndicator];
                [self.delegate viewController:self didFinishLoadingTaggedSongArray:self.sortedTaggedArray];
                NSLog (@"Done Building Tagged Song Array");
            });
        }
    });
}
- (void) createTaggedSongArray {
    
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
    
    self.taggedPlaylistDuration = [NSNumber numberWithLong: taggedDuration];
}
//- (void)checkForICloudItemsWithCompletion:(void (^)(BOOL result))completionHandler {
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        MPMediaQuery *mySongQuery = [[MPMediaQuery alloc] init];
//        mySongQuery = [MPMediaQuery songsQuery];
//        MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue:  [NSNumber numberWithInt: 1]
//                                                                                     forProperty:  MPMediaItemPropertyIsCloudItem];
//        [mySongQuery addFilterPredicate: filterPredicate];
//        NSArray *filteredArray = [mySongQuery items];
//        if ([filteredArray count] > 0) {
//            self.collectionContainsICloudItem = YES;
//        }
//
//        // Check that there was not a nil handler passed.
//        if( completionHandler ){
//            dispatch_sync(dispatch_get_main_queue(), ^(void) {
//                NSLog (@"Done Checking For ICloud Items");
//                NSLog (@"unfiltered CollectionContainsICloudItem = %d", self.collectionContainsICloudItem);
//            });
//        }
//    });
//}
-(void) loadGroupingData
{
    MediaGroup* group0 = [[MediaGroup alloc] initWithName:@"Playlists" andImage:[UIImage imageNamed:@"PlaylistsIcon.png"]andQueryType: [MPMediaQuery playlistsQuery]];
    
    MediaGroup* group1 = [[MediaGroup alloc] initWithName:@"Artists" andImage:[UIImage imageNamed:@"ArtistsIcon.png"]andQueryType: [MPMediaQuery artistsQuery]];
    
    MediaGroup* group2 = [[MediaGroup alloc] initWithName:@"Songs" andImage:[UIImage imageNamed:@"SongsIcon.png"]andQueryType: [MPMediaQuery songsQuery]];
    
    MediaGroup* group3 = [[MediaGroup alloc] initWithName:@"Tagged" andImage:[UIImage imageNamed:@"TagsIcon.png"]andQueryType: [MPMediaQuery songsQuery]];
    
    MediaGroup* group4= [[MediaGroup alloc] initWithName:@"Albums" andImage:[UIImage imageNamed:@"AlbumsIcon.png"]andQueryType: [MPMediaQuery albumsQuery]];
    
    MediaGroup* group5 = [[MediaGroup alloc] initWithName:@"Compilations" andImage:[UIImage imageNamed:@"CompilationsIcon.png"]andQueryType: [MPMediaQuery compilationsQuery]];
    
    MediaGroup* group6 = [[MediaGroup alloc] initWithName:@"Composers" andImage:[UIImage imageNamed:@"ComposersIcon.png"]andQueryType: [MPMediaQuery composersQuery]];
    
    MediaGroup* group7 = [[MediaGroup alloc] initWithName:@"Genres" andImage:[UIImage imageNamed:@"GenresIcon.png"]andQueryType: [MPMediaQuery genresQuery]];
    
    MediaGroup* group8 = [[MediaGroup alloc] initWithName:@"Podcasts" andImage:[UIImage imageNamed:@"PodcastsIcon.png"]andQueryType: [MPMediaQuery podcastsQuery]];
    
    
    
    self.groupingData = [NSArray arrayWithObjects:group0, group1, group2, group3, group4, group5, group6, group7, group8, nil];
    //    self.groupingData = [NSArray arrayWithObjects:group0, group1, group2, group3, group4, group5, group6, nil];
    
    
    return;
    
}



- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    [super viewWillAppear: animated];
    
    [self setIPodLibraryChanged: NO];
    self.title = NSLocalizedString(@"Select Music", nil);
    self.navigationItem.titleView = [self customizeTitleView];
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (playingItem) {
        if (self.initialView) {
            self.initialView = NO;
            [self viewNowPlaying];
        } else {
            self.navigationItem.rightBarButtonItem = self.rightBarButton;
        }
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
    return;
}
-(void) viewDidAppear:(BOOL)animated {
    //    LogMethod();
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    initialView = NO;
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsPortrait(deviceOrientation)) {
        self.initialPortraitImage = ([self makeImage]);
    }
    [super viewDidAppear:(BOOL)animated];
}
-(UIImage*) makeImage {
    
    UIGraphicsBeginImageContext(self.groupTableView.bounds.size);
    
    [self.groupTableView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *portraitImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return portraitImage;
    
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


- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    //    LogMethod();
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    //    LogMethod();
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.groupTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
    } else {
        [self.groupTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.groupTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}
- (void) viewWillLayoutSubviews {
    //    LogMethod();
    //need this to pin portrait view to bounds otherwise if start in landscape, push to next view, rotate to portrait then pop back the original view in portrait - it will be too wide and "scroll" horizontally
    self.groupTableView.contentSize = CGSizeMake(self.groupTableView.frame.size.width, self.groupTableView.contentSize.height);
    [super viewWillLayoutSubviews];
}

#pragma mark - Table view data source
// Configures the table view.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.groupingData count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
	MediaGroupCell *cell = (MediaGroupCell *)[tableView
                                              dequeueReusableCellWithIdentifier:@"MediaGroupCell"];
    MediaGroup *group = [self.groupingData objectAtIndex:indexPath.row];
    cell.nameLabel.text = NSLocalizedString(group.name, nil);
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
    accessory.highlightedColor = [UIColor blueColor];
    cell.accessoryView = accessory;
    
    return cell;
}

#pragma mark - Table view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    //    LogMethod();
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    //self.selectedGroup is a MediaGroup with a name and a querytype
    self.selectedGroup = [self.groupingData objectAtIndex:indexPath.row];
    if (([selectedGroup.name isEqualToString: @"Tagged"])) {
        if (!self.taggedSongArrayLoaded) {
            [self showActivityIndicator];
        } else {
            [self performSegueWithIdentifier: @"ViewTaggedSongCollection" sender: self];
        }
    } else {
        if ([selectedGroup.name isEqualToString: @"Songs"]) {
            if (!self.songArrayLoaded) {
                if (!self.tinySongArrayLoaded) {
                    [self showActivityIndicator];
                } else {
                    songArrayToLoad = [self.tinySongMutableArray mutableCopy];
                    listIsAlphabetic = NO;
                    [self performSegueWithIdentifier: @"ViewSongCollection" sender: self];
                }
            } else {
                songArrayToLoad = [self.songArray mutableCopy];
                self.tinySongArrayLoaded = NO;
                listIsAlphabetic = YES;
                [self performSegueWithIdentifier: @"ViewSongCollection" sender: self];
            }
        } else {
            if ([selectedGroup.name isEqualToString:@"Artists"]) {
                //works more like Apple with AlbumArtist rather than just Artist
                MPMediaQuery *myCollectionQuery = [[MPMediaQuery alloc] init];
                [myCollectionQuery setGroupingType: MPMediaGroupingAlbumArtist];
                selectedGroup.queryType = myCollectionQuery;
                [self performSegueWithIdentifier: @"ArtistCollections" sender: self];
            } else {
                if ([selectedGroup.name isEqualToString:@"Composers"]) {
                    [self performSegueWithIdentifier: @"ArtistCollections" sender: self];
                } else {
                    if ([selectedGroup.name isEqualToString:@"Genres"]) {
                        [self performSegueWithIdentifier: @"ViewGenres" sender: self];
                    } else {
                        // Playlists, Albums, Compilations, Podcasts go to albumCollections
                        [self performSegueWithIdentifier:@"AlbumCollections" sender:self];
                    }
                }
            }
        }
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    LogMethod();
    
	if ([segue.identifier isEqualToString:@"ViewGenres"])
	{
		GenreViewController *genreViewController = segue.destinationViewController;
        genreViewController.managedObjectContext = self.managedObjectContext;
        
        MPMediaQuery *myCollectionQuery = [selectedGroup.queryType copy];
        
        [myCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
                                                predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeMusic]
                                                forProperty:MPMediaItemPropertyMediaType]];
        
        self.collection = [myCollectionQuery collections];
        
		genreViewController.collection = self.collection;
        genreViewController.collectionType = selectedGroup.name;
        genreViewController.collectionQueryType = myCollectionQuery;
        genreViewController.title = NSLocalizedString(selectedGroup.name, nil);
        genreViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
	}
    if ([segue.identifier isEqualToString:@"ArtistCollections"])
	{
		ArtistViewController *artistViewController = segue.destinationViewController;
        artistViewController.managedObjectContext = self.managedObjectContext;
        
        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
        
        self.collection = [myCollectionQuery collections];
		artistViewController.collection = self.collection;
        artistViewController.collectionType = selectedGroup.name;
        artistViewController.collectionQueryType = [selectedGroup.queryType copy];
        artistViewController.title = NSLocalizedString(selectedGroup.name, nil);
        artistViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
	}
    
    if ([segue.identifier isEqualToString:@"AlbumCollections"])
	{
		AlbumViewController *albumViewController = segue.destinationViewController;
        albumViewController.managedObjectContext = self.managedObjectContext;
        
        //        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
        
        self.collection = [selectedGroup.queryType collections];
		albumViewController.collection = self.collection;
        albumViewController.collectionType = selectedGroup.name;
        albumViewController.collectionQueryType = [selectedGroup.queryType copy];
        albumViewController.title = NSLocalizedString(selectedGroup.name, nil);
        albumViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        albumViewController.collectionPredicate = nil;
        
	}
    if ([segue.identifier isEqualToString:@"ViewSongCollection"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;
        
        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = selectedGroup.name;
        //        collectionItem.duration = self.playlistDuration;
        //        collectionItem.collection = [MPMediaItemCollection collectionWithItems: songMutableArray];
        //        collectionItem.collectionArray = self.songMutableArray;
        collectionItem.collectionArray = songArrayToLoad;
        
        
        
        songViewController.title = NSLocalizedString(collectionItem.name, nil);
        songViewController.collectionItem = collectionItem;
        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        songViewController.listIsAlphabetic = listIsAlphabetic;
//130912 1.1 add iTunesStoreButton begin
        songViewController.collectionType = selectedGroup.name;
//130912 1.1 add iTunesStoreButton end
        NSLog (@"TinySongArrayLoaded = %d", self.tinySongArrayLoaded);
        songViewController.tinyArray = self.tinySongArrayLoaded;
        
        songViewController.collectionQueryType = [selectedGroup.queryType copy];
        songViewController.mediaGroupViewController = self;
        
        
	}
    if ([segue.identifier isEqualToString:@"ViewTaggedSongCollection"])
	{
        TaggedSongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;
        
        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = selectedGroup.name;
        collectionItem.duration = self.taggedPlaylistDuration;
        //        collectionItem.collectionArray = [self.songArray mutableCopy];
        
        songViewController.title = NSLocalizedString(collectionItem.name, nil);
        songViewController.collectionItem = collectionItem;
        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        //        songViewController.listIsAlphabetic = NO;
        songViewController.collectionQueryType = [selectedGroup.queryType copy];
        songViewController.taggedSongArray = [self.sortedTaggedArray mutableCopy];
        
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
- (void)hideActivityIndicator {
    
    if (alert) {
        
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        alert = nil;
        if ([selectedGroup.name isEqualToString: @"Songs"]) {
            if (self.songArrayLoaded) {
                songArrayToLoad = [self.songArray mutableCopy];
                listIsAlphabetic = YES;
                self.tinySongArrayLoaded = NO;
            } else {
                songArrayToLoad = [self.tinySongArray mutableCopy];
                listIsAlphabetic = NO;
                self.tinySongArrayLoaded = YES;
            }
            [self performSegueWithIdentifier: @"ViewSongCollection" sender: self];
        }
        if ([selectedGroup.name isEqualToString: @"Tagged"]) {
            [self performSegueWithIdentifier: @"ViewTaggedSongCollection" sender: self];
        }
    }
    
}

- (void)showActivityIndicator {
    if (alert)
        return;
    alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [alert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(alert.bounds.size.width * 0.5f, alert.bounds.size.height * 0.5f);
    
    [indicator startAnimating];
    [alert addSubview:indicator];
}
//130906 1.1 add Store Button begin
                                                                        
- (IBAction)linkToiTunesStore {
    
    LogMethod();
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    
    NSString *iTunesLink = [NSString stringWithFormat: @"itms://itunes.apple.com/%@?%@", countryCode, myAffiliateID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];

}
//130906 1.1 add Store Button end

- (IBAction)viewNowPlaying {
    
    //    LogMethod();
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
}

- (void) registerForMediaPlayerNotifications {
    //    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    //    [notificationCenter addObserver:self
    //                         selector:@selector(reachabilityChanged:)
    //                             name:kReachabilityChangedNotification
    //                           object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(tagDataChanged:)
                               name:@"TagDataForItemChanged"
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(tagDataChanged:)
                               name:@"TagDataChanged"
                             object:nil];
    
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
//- (void)reachabilityChanged:(NSNotification *)notification {
//    NSLog(@"reachability changed");
//    BOOL networkAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"networkAvailable"];
//    NSLog (@"networkAvailable BOOL from NSUserDefaults is %d", networkAvailable);
//    if (self.collectionContainsICloudItem) {
//        if (networkAvailable) {
//            excludeICloudItems = NO;
//            if (currentDataSourceContainsICloudItems == NO) {
//                [self loadSongArraysInBackground];
//            }
//        } else {
//            //if network is unAvailable
//            excludeICloudItems = YES;
//            if (currentDataSourceContainsICloudItems == YES) {
//                [self loadSongArraysInBackground];
//            }
//        }
//    }
//
//}

- (void)tagDataChanged:(NSNotification *)notification {
    NSLog(@"tag data changed reload...");
    //create the taggedSongArray in the background
    [self loadTaggedSongArrayWithCompletion:^(BOOL result) {
        
    }];
    
}

- (void) handle_iPodLibraryChanged: (id) changeNotification {
    LogMethod();
	// Implement this method to update cached collections of media items when the
	// user performs a sync while application is running.
    [self setIPodLibraryChanged: YES];
    [self loadSongArraysInBackground];
    
    
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
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:kReachabilityChangedNotification
    //                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"TagDataForItemChanged"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"TagDataChanged"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMediaLibraryDidChangeNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];
    
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
