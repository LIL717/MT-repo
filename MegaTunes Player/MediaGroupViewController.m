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

@interface MediaGroupViewController ()

@end

@implementation MediaGroupViewController

@synthesize groupTableView;
@synthesize collection;
@synthesize groupingData;
@synthesize selectedGroup;
@synthesize musicPlayer;
@synthesize managedObjectContext;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize rightBarButton;

BOOL initialView;

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//	self = [super initWithCoder:aDecoder];
//	
//	return self;
//}
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
    
    initialView = YES;
}
-(void) loadGroupingData
{
    MediaGroup* group0 = [[MediaGroup alloc] initWithName:@"Playlists" andQueryType: [MPMediaQuery playlistsQuery]];
    
    MediaGroup* group1 = [[MediaGroup alloc] initWithName:@"Artists" andQueryType: [MPMediaQuery artistsQuery]];
    
    MediaGroup* group2 = [[MediaGroup alloc] initWithName:@"Songs" andQueryType: [MPMediaQuery songsQuery]];
    
    MediaGroup* group3 = [[MediaGroup alloc] initWithName:@"Albums" andQueryType: [MPMediaQuery albumsQuery]];

    MediaGroup* group4 = [[MediaGroup alloc] initWithName:@"Compilations" andQueryType: [MPMediaQuery compilationsQuery]];
    
    MediaGroup* group5 = [[MediaGroup alloc] initWithName:@"Composers" andQueryType: [MPMediaQuery composersQuery]];
    
    MediaGroup* group6 = [[MediaGroup alloc] initWithName:@"Genres" andQueryType: [MPMediaQuery genresQuery]];
    
    MediaGroup* group7 = [[MediaGroup alloc] initWithName:@"Podcasts" andQueryType: [MPMediaQuery podcastsQuery]];

    
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
        if (initialView) {
            initialView = NO;
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


- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];

}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.groupTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
    } else {
        [self.groupTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.groupTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}
- (void) viewWillLayoutSubviews {

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
        
        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
        
        [myCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
                                                predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeMusic]
                                                forProperty:MPMediaItemPropertyMediaType]];
         
        self.collection = [myCollectionQuery collections];

		genreViewController.collection = self.collection;
        genreViewController.collectionType = selectedGroup.name;
        genreViewController.collectionQueryType = selectedGroup.queryType;
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
        artistViewController.collectionQueryType = selectedGroup.queryType;
        artistViewController.title = NSLocalizedString(selectedGroup.name, nil);
        artistViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
	}

    if ([segue.identifier isEqualToString:@"AlbumCollections"])
	{
		AlbumViewController *albumViewController = segue.destinationViewController;
        albumViewController.managedObjectContext = self.managedObjectContext;
        
        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
        
        self.collection = [myCollectionQuery collections];
		albumViewController.collection = self.collection;
        albumViewController.collectionType = selectedGroup.name;
        albumViewController.collectionQueryType = selectedGroup.queryType;
        albumViewController.title = NSLocalizedString(selectedGroup.name, nil);
        albumViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
	}
    if ([segue.identifier isEqualToString:@"ViewSongCollection"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;

        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
                
        NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
        long playlistDuration = 0;

        NSArray *songs = [myCollectionQuery items];


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
    
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

