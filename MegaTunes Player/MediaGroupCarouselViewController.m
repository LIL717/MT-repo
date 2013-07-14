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
@synthesize collectionContainsICloudItem;
@synthesize songArrayLoaded;
@synthesize taggedSongArrayLoaded;
@synthesize tinySongArrayLoaded;


NSMutableArray *songArrayToLoad;

UIAlertView *alert;
BOOL tinyArray;
BOOL listIsAlphabetic;

#pragma mark - Initial Display methods
- (void)awakeFromNib
{
//    LogMethod();
    [self loadGroupingData];
    
    self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(viewNowPlaying)];
    
    UIImage *menuBarImageDefault = [[UIImage imageNamed:@"redWhitePlay57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"redWhitePlay68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.rightBarButton setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.rightBarButton setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
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
//
//- (void) createSongArray {
//    
//    MPMediaQuery *mySongQuery = [[MPMediaQuery alloc] init];
//    mySongQuery = [MPMediaQuery songsQuery];
//    
//    self.songArray = [mySongQuery items];
//    
//    //uncomment to slow the load way way down to test tinyArray
//    //    for (MPMediaItem *song in self.songArray) {
//    //        NSLog (@"SongName is %@", [song valueForProperty: MPMediaItemPropertyTitle]);
//    //    }
//    
//}
//- (void)loadTaggedSongArrayWithCompletion:(void (^)(BOOL result))completionHandler {
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self createTaggedSongArray];
//        
//        // Check that there was not a nil handler passed.
//        if( completionHandler ){
//            dispatch_sync(dispatch_get_main_queue(), ^(void) {
//                self.taggedSongArrayLoaded = YES;
//                [self hideActivityIndicator];
//                NSLog (@"Done Building Tagged Song Array");
//            });
//        }
//    });
//}
//- (void) createTaggedSongArray {
//    
//    NSMutableArray *songDictMutableArray = [NSMutableArray arrayWithCapacity: 20];
//    //    self.taggedSongArray = [NSMutableArray arrayWithCapacity: 20];
//    
//    long taggedDuration = 0;
//    
//    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
//    mediaItemUserData.managedObjectContext = self.managedObjectContext;
//    
//    NSArray *taggedMediaItems = [mediaItemUserData containsTag];
//    
//    for (MediaItemUserData *taggedMediaItem in taggedMediaItems) {
//        //        NSLog (@" song is %@ with persistentID %@", taggedMediaItem.title, taggedMediaItem.persistentID);
//        
//        MPMediaQuery *mySongQuery = [[MPMediaQuery alloc] init];
//        mySongQuery = [MPMediaQuery songsQuery];
//        MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue: taggedMediaItem.persistentID
//                                                                                     forProperty:  MPMediaItemPropertyPersistentID];
//        [mySongQuery addFilterPredicate: filterPredicate];
//        NSArray *filteredArray = [mySongQuery items];
//        if ([filteredArray count] > 0) {
//            
//            MPMediaItem *song = [MPMediaItem alloc];
//            for (MPMediaItem *filteredItem in filteredArray) {
//                //                NSLog (@"item with persistentID %@", [filteredItem valueForProperty: MPMediaItemPropertyPersistentID]);
//                song = filteredItem;
//            }
//            
//            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: song, @"Song", taggedMediaItem.tagData, @"TagData", nil];
//            
//            [songDictMutableArray addObject: dict];
//            taggedDuration = (taggedDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
//            //                NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
//            //                NSLog (@"\t\t%@", songTitle);
//        }
//    }
//    
//    self.sortedTaggedArray = [songDictMutableArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        TagData *firstTagData = [(NSDictionary *)a objectForKey: @"TagData"];
//        TagData *secondTagData = [(NSDictionary *)b objectForKey: @"TagData"];
//        return [firstTagData.sortOrder compare: secondTagData.sortOrder];
//    }];
//    
//    self.taggedPlaylistDuration = [NSNumber numberWithLong: taggedDuration];
//}

- (void) viewWillAppear:(BOOL)animated
{
//    LogMethod();
    [super viewWillAppear: animated];
    
    [self setIPodLibraryChanged: NO];
    self.title = NSLocalizedString(@"Select Music", nil);
    self.navigationItem.titleView = [self customizeTitleView];
    [self.navigationItem setHidesBackButton: YES animated: NO];
    
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (playingItem) {
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }

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
        NSLog (@"TinySongArrayLoaded = %d", self.tinySongArrayLoaded);
        songViewController.tinyArray = self.tinySongArrayLoaded;
        
        songViewController.collectionQueryType = [selectedGroup.queryType copy];
        songViewController.collectionContainsICloudItem = self.collectionContainsICloudItem;        
        
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
        songViewController.listIsAlphabetic = NO;
        songViewController.collectionQueryType = [selectedGroup.queryType copy];
        songViewController.collectionContainsICloudItem = self.collectionContainsICloudItem;
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
    
    if (alert) {
        
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        alert = nil;
        if ([selectedGroup.name isEqualToString: @"Songs"]) {
            songArrayToLoad = [self.tinySongArray mutableCopy];
            listIsAlphabetic = NO;
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

- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingSongArray:(NSArray *)array
{
    songArrayToLoad = [array mutableCopy];
    listIsAlphabetic = YES;
    self.songArrayLoaded = YES;

}

- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTinySongArray:(NSArray *) array
{
    self.tinySongArray = array;
    self.tinySongArrayLoaded = YES;
    [self hideActivityIndicator];
}
- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTaggedSongArray:(NSArray *) array
{
    self.sortedTaggedArray = array;
    self.taggedSongArrayLoaded = YES;
    [self hideActivityIndicator];
}
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

