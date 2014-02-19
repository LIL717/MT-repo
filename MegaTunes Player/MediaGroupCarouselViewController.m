//
//  MediaGroupCarouselViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 5/31/13.
//
//

#import "MediaGroupCarouselViewController.h"
#import "MediaGroup.h"
#import "ArtistViewController.h"
#import "MediaGroupCell.h"
#import "SongViewController.h"
#import "CollectionItem.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"
#import "AlbumViewcontroller.h"
#import "GenreViewController.h"
#import "MediaGroupViewController.h"
#import "TaggedSongViewController.h"
#import "TagData.h"
#import "MediaItemUserData.h"
#import "UserDataForMediaItem.h"
#import "AppDelegate.h"


@interface MediaGroupCarouselViewController ()


@end

@implementation MediaGroupCarouselViewController

@synthesize delegate;
@synthesize carousel;
@synthesize backgroundView;
@synthesize collection;
@synthesize groupingData;
@synthesize selectedGroup;
@synthesize musicPlayer;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize rightBarButton;
@synthesize initialLandscapeImage;
@synthesize mediaGroupViewController;
@synthesize appDelegate;
@synthesize songArray;
@synthesize tinySongMutableArray;
@synthesize tinySongArray;
@synthesize sortedTaggedArray;

@synthesize playlistDuration;
@synthesize taggedPlaylistDuration;
@synthesize songArrayLoaded;
@synthesize taggedSongArrayLoaded;
@synthesize tinySongArrayLoaded;
@synthesize loadingAlert;


NSMutableArray *songArrayToLoad;

BOOL tinyArray;
BOOL listIsAlphabetic;
//130906 1.1 add Store Button begin
NSString *myAffiliateID;
//130906 1.1 add Store Button end

#pragma mark - Initial Display methods
- (void)awakeFromNib
{
    //    LogMethod();
    [self loadGroupingData];
    
//130906 1.1 add Store Button begin
    //get the affliate ID
    myAffiliateID = [[NSUserDefaults standardUserDefaults] stringForKey:@"affiliateID"];
    self.navigationItem.backBarButtonItem = nil; // Important
    //initWithTitle cannot be nil, must be @""
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(linkToiTunesStore)];
    
    UIImage *menuBarImage48 = [[UIImage imageNamed:@"iTunesStoreIcon57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImage58 = [[UIImage imageNamed:@"iTunesStoreIcon68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
//130906 1.1 add Store Button end
//140127 1.2 iOS 7 begin
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
    
    [self.navigationItem setHidesBackButton: YES animated: NO];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    self.appDelegate = (id) [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    [self registerForMediaPlayerNotifications];
    
}
- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
    
    self.mediaGroupViewController.delegate = self;
//140218 1.2 iOS 7 begin
    self.title = NSLocalizedString(@"Select Music", nil);
    self.navigationItem.titleView = [self customizeTitleView];
//140218 1.2 iOS 7 end
    //configure carousel
    carousel.type = iCarouselTypeCoverFlow2;
    
}
-(void) loadGroupingData
{
    MediaGroup* group0 = [[MediaGroup alloc] initWithName:@"Playlists" andImage:[UIImage imageNamed:@"PlaylistsIcon.png"]andQueryType: [MPMediaQuery playlistsQuery]];
    
    MediaGroup* group1 = [[MediaGroup alloc] initWithName:@"Artists" andImage:[UIImage imageNamed:@"ArtistsIcon.png"]andQueryType: [MPMediaQuery artistsQuery]];
    
    MediaGroup* group2 = [[MediaGroup alloc] initWithName:@"Songs" andImage:[UIImage imageNamed:@"SongsIcon.png"]andQueryType: [MPMediaQuery songsQuery]];
    
    MediaGroup* group3 = [[MediaGroup alloc] initWithName:@"Tagged" andImage:[UIImage imageNamed:@"TagsIcon.png"]andQueryType: [MPMediaQuery songsQuery]];
    
    MediaGroup* group4 = [[MediaGroup alloc] initWithName:@"Albums" andImage:[UIImage imageNamed:@"AlbumsIcon.png"]andQueryType: [MPMediaQuery albumsQuery]];
    
    MediaGroup* group5 = [[MediaGroup alloc] initWithName:@"Compilations" andImage:[UIImage imageNamed:@"CompilationsIcon.png"]andQueryType: [MPMediaQuery compilationsQuery]];
    
    MediaGroup* group6 = [[MediaGroup alloc] initWithName:@"Composers" andImage:[UIImage imageNamed:@"ComposersIcon.png"]andQueryType: [MPMediaQuery composersQuery]];
    
    MediaGroup* group7 = [[MediaGroup alloc] initWithName:@"Genres" andImage:[UIImage imageNamed:@"GenresIcon.png"]andQueryType: [MPMediaQuery genresQuery]];
    
    MediaGroup* group8 = [[MediaGroup alloc] initWithName:@"Podcasts" andImage:[UIImage imageNamed:@"PodcastsIcon.png"]andQueryType: [MPMediaQuery podcastsQuery]];
    
    
    
    
    self.groupingData = [NSArray arrayWithObjects:group0, group1, group2, group3, group4, group5, group6, group7,group8, nil];
    //    self.groupingData = [NSArray arrayWithObjects:group0, group1, group2, group3, group4, group5, group6, nil];
    
    
    return;
    
}


- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    [super viewWillAppear: animated];
//131216 1.2 iOS 7 begin
    self.edgesForExtendedLayout = UIRectEdgeNone;
//131216 1.2 iOS 7 end
    
    [self setIPodLibraryChanged: NO];
    [self.navigationItem setHidesBackButton: YES animated: NO];
    
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (playingItem) {
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    
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

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [self.groupingData count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 450.0f)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        //        view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 280, 300.0f, 50.0f)];
        
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [label.font fontWithSize:44];
        label.tag = 1;
        [view addSubview:label];
        
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    
    MediaGroup *group = [groupingData objectAtIndex:index];
    label.text = NSLocalizedString(group.name, nil);
    
    if ([group.name isEqualToString: @"Compilations"]) {
        label.font = [label.font fontWithSize:40];
    } else {
        label.font = [label.font fontWithSize:44];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50.0, 120.0, 200, 160)];
    if (!group.collectionImage) {
        [imageView setImage:[UIImage imageNamed:@"noAlbumImage320.png"]];
    } else {
        [imageView setImage:group.collectionImage];
    }
    [view addSubview:imageView];
    
    // need to create an image of the Playlist carousel item (index 0) to use as a placeholder when loading this after outside rotation
    if (index == 0) {
        UIGraphicsBeginImageContext((view.bounds.size));
        
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *playlistImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.mediaGroupViewController.initialLandscapeImage = (playlistImage);
        
    }
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.1f;
    }
    if (option == iCarouselOptionWrap)
    {
        return YES;
    }
    return value;
}


#pragma mark - Carousel view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    //    LogMethod();
    
    //    if (index == carousel.currentItemIndex) {
    //self.selectedGroup is a MediaGroup with a name and a querytype
    self.selectedGroup = [self.groupingData objectAtIndex:index];
    if (([self.selectedGroup.name isEqualToString: @"Tagged"])) {
        if (!self.taggedSongArrayLoaded) {
            [self showActivityIndicator];
        } else {
            [self performSegueWithIdentifier: @"ViewTaggedSongCollection" sender: self];
        }
    } else {
        if ([self.selectedGroup.name isEqualToString: @"Songs"]) {
            if (!self.songArrayLoaded) {
                if (!self.tinySongArrayLoaded) {
                    [self showActivityIndicator];
                } else {
                    songArrayToLoad = [self.tinySongArray mutableCopy];
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
            if ([self.selectedGroup.name isEqualToString:@"Artists"]) {
                //works more like Apple with AlbumArtist rather than just Artist
                MPMediaQuery *myCollectionQuery = [[MPMediaQuery alloc] init];
                [myCollectionQuery setGroupingType: MPMediaGroupingAlbumArtist];
                selectedGroup.queryType = myCollectionQuery;
                [self performSegueWithIdentifier: @"ArtistCollections" sender: self];
            } else {
                if ([self.selectedGroup.name isEqualToString:@"Composers"]) {
                    [self performSegueWithIdentifier: @"ArtistCollections" sender: self];
                } else {
                    if ([self.selectedGroup.name isEqualToString:@"Genres"]) {
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
        songViewController.mediaGroupCarouselViewController = self;
        
        
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
    
}
//- (TagData *) retrieveTagForMediaItem: (MPMediaItem *) mediaItem {
//
//    //check to see if there is user data for this media item
//    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
//    mediaItemUserData.managedObjectContext = self.managedObjectContext;
//
//    UserDataForMediaItem *userDataForMediaItem = [mediaItemUserData containsItem: [mediaItem valueForProperty: MPMediaItemPropertyPersistentID]];
//    return userDataForMediaItem.tagData;
//
//}

- (void)hideActivityIndicator {
    
    if (self.loadingAlert) {
        
        [self.loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.loadingAlert = nil;
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
    if (self.loadingAlert)
        return;
    self.loadingAlert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [self.loadingAlert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(self.loadingAlert.bounds.size.width * 0.5f, self.loadingAlert.bounds.size.height * 0.5f);
    
    [indicator startAnimating];
    [self.loadingAlert addSubview:indicator];
}

- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingSongArray:(NSArray *)array
{
    //    LogMethod();
    
    self.songArray = array;
    listIsAlphabetic = YES;
    self.songArrayLoaded = YES;
    [self hideActivityIndicator];
    [self.delegate viewController:self didFinishLoadingSongArray:array];
    
}

- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTinySongArray:(NSArray *) array
{
    //    LogMethod();
    
    self.tinySongArray = array;
    self.tinySongArrayLoaded = YES;
    [self hideActivityIndicator];
}
- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTaggedSongArray:(NSArray *) array
{
    //    LogMethod();
    
    self.sortedTaggedArray = array;
    self.taggedSongArrayLoaded = YES;
    [self hideActivityIndicator];
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
    //                           selector:@selector(tagDataChanged:)
    //                               name:@"TagDataForItemChanged"
    //                             object:nil];
    //
    //    [notificationCenter addObserver:self
    //                           selector:@selector(tagDataChanged:)
    //                               name:@"TagDataChanged"
    //                             object:nil];
    
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
//- (void)tagDataChanged:(NSNotification *)notification {
//    NSLog(@"tag data changed reload...");
//    //create the taggedSongArray in the background
//    [self loadTaggedSongArrayWithCompletion:^(BOOL result) {
//
//    }];
//
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
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    carousel.delegate = nil;
    carousel.dataSource = nil;
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:@"TagDataForItemChanged"
    //                                                  object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:@"TagDataChanged"
    //                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMediaLibraryDidChangeNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

