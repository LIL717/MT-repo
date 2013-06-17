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

@interface MediaGroupViewController ()

@end

@implementation MediaGroupViewController

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
@synthesize initialPortraitImage;
@synthesize initialLandscapeImage;
UIViewController *presentingViewController;



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
    [self swapControllersIfNeeded];
}
- (void) createTempBackgroundForSwap
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        presentingViewController == self)
    {
        // NOTE: PUSHING A NEW VIEW CONTROLLER BEFORE viewDidAppear causes issues for the pop later - so just instantiate and build background here, push after viewDidAppear in swapControllerIfNeeded method
        
        self.mediaGroupCarouselViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaGroupCarouselView"];
        self.mediaGroupCarouselViewController.mediaGroupViewController = self;

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
    [self loadGroupingData];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(viewNowPlaying)];
    
    UIImage *menuBarImageDefault = [[UIImage imageNamed:@"redWhitePlay57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"redWhitePlay68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.rightBarButton setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.rightBarButton setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    [self registerForMediaPlayerNotifications];
    
    self.initialView = YES;

}

-(void) loadGroupingData
{
    MediaGroup* group0 = [[MediaGroup alloc] initWithName:@"Playlists" andImage:[UIImage imageNamed:@"PlaylistsIcon.png"]andQueryType: [MPMediaQuery playlistsQuery]];
    
    MediaGroup* group1 = [[MediaGroup alloc] initWithName:@"Artists" andImage:[UIImage imageNamed:@"ArtistsIcon.png"]andQueryType: [MPMediaQuery artistsQuery]];
    
    MediaGroup* group2 = [[MediaGroup alloc] initWithName:@"Songs" andImage:[UIImage imageNamed:@"SongsIcon.png"]andQueryType: [MPMediaQuery songsQuery]];
    
    MediaGroup* group3 = [[MediaGroup alloc] initWithName:@"Albums" andImage:[UIImage imageNamed:@"AlbumsIcon.png"]andQueryType: [MPMediaQuery albumsQuery]];
    
    MediaGroup* group4 = [[MediaGroup alloc] initWithName:@"Compilations" andImage:[UIImage imageNamed:@"CompilationsIcon.png"]andQueryType: [MPMediaQuery compilationsQuery]];
    
    MediaGroup* group5 = [[MediaGroup alloc] initWithName:@"Composers" andImage:[UIImage imageNamed:@"ComposersIcon.png"]andQueryType: [MPMediaQuery composersQuery]];
    
    MediaGroup* group6 = [[MediaGroup alloc] initWithName:@"Genres" andImage:[UIImage imageNamed:@"GenresIcon.png"]andQueryType: [MPMediaQuery genresQuery]];
    
    MediaGroup* group7 = [[MediaGroup alloc] initWithName:@"Podcasts" andImage:[UIImage imageNamed:@"PodcastsIcon.png"]andQueryType: [MPMediaQuery podcastsQuery]];
    
    
    self.groupingData = [NSArray arrayWithObjects:group0, group1, group2, group3, group4, group5, group6, group7, nil];
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
    if ([selectedGroup.name isEqualToString: @"Songs"]) {
        [self performSegueWithIdentifier: @"ViewSongCollection" sender: self];
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

//        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
        
        NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
        long playlistDuration = 0;

        NSArray *songs = [selectedGroup.queryType items];


        for (MPMediaItem *song in songs) {
            [songMutableArray addObject: song];
            playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
//                NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
//                NSLog (@"\t\t%@", songTitle);
        }

        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = selectedGroup.name;
        collectionItem.duration = [NSNumber numberWithLong: playlistDuration];
//        collectionItem.collection = [MPMediaItemCollection collectionWithItems: songMutableArray];
        collectionItem.collectionArray = songMutableArray;

        songViewController.title = NSLocalizedString(collectionItem.name, nil);
        songViewController.collectionItem = collectionItem;
        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        songViewController.listIsAlphabetic = YES;
        songViewController.collectionQueryType = [selectedGroup.queryType copy];
        
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
    
//    LogMethod();
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
}

- (void) registerForMediaPlayerNotifications {
//    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
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

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

