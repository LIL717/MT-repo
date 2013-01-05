//
//  CollectionViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

#import "CollectionViewController.h"
#import "CollectionItemCell.h"
#import "CollectionItem.h"
#import "SongViewController.h"
#import "AppDelegate.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"


@interface CollectionViewController ()

@end

@implementation CollectionViewController

@synthesize collectionTableView;
@synthesize collection;
@synthesize managedObjectContext;


- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    [super viewDidLoad];
    
    self.navigationItem.titleView = [self customizeTitleView];
  
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MPMusicPlayerController *musicPlayer;

    if ([appDelegate useiPodPlayer]) {
        musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        NSLog (@"iPod");
    } else {
        musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        NSLog (@"app");
    }
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (playingItem) {
        //initWithTitle cannot be nil, must be @""
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(viewNowPlaying)];
        
        UIImage *menuBarImageDefault = [[UIImage imageNamed:@"redWhitePlay57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"redWhitePlay68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    
    return;
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
- (void) viewDidLoad {
    
    [super viewDidLoad];
	
//    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
    
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
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.collectionTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
    } else {
        [self.collectionTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.collectionTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}
- (void)goBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark Table view methods________________________
// Configures the table view.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
        
    return [self.collection count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
	CollectionItemCell *cell = (CollectionItemCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"CollectionItemCell"];
    
    MPMediaItemCollection *currentQueue = [MPMediaItemCollection collectionWithItems: [[self.collection objectAtIndex:indexPath.row] items]];    

    if (self.title == @"Playlists") {
        MPMediaPlaylist  *mediaPlaylist = [self.collection objectAtIndex:indexPath.row];
        cell.nameLabel.text = [mediaPlaylist valueForProperty: MPMediaPlaylistPropertyName];
    }
    if (self.title == @"Artists") {
        cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyArtist];
    }
    if (self.title == @"Albums") {
        cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyAlbumTitle];
    }
    if (self.title == @"Composers") {
        cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyComposer];
    }
    if (self.title == @"Genres") {
        cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyGenre];
    }
    if (self.title == @"Podcasts") {
        cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyPodcastTitle];
    }

    NSNumber *playlistDurationNumber = [self calculatePlaylistDuration: currentQueue];
    long playlistDuration = [playlistDurationNumber longValue];

    int playlistMinutes = (playlistDuration / 60);     // Whole minutes
    int playlistSeconds = (playlistDuration % 60);                        // seconds
    cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];
    
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
    accessory.highlightedColor = [UIColor blueColor];
    cell.accessoryView = accessory;

    return cell;
}
- (NSNumber *)calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue {

    NSArray *returnedQueue = [currentQueue items];
    
    long playlistDuration = 0;

    for (MPMediaItem *song in returnedQueue) {
        playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
    }

    return [NSNumber numberWithLong: playlistDuration];
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();
    NSIndexPath *indexPath = [ self.collectionTableView indexPathForCell:sender];
    
	if ([segue.identifier isEqualToString:@"ViewSongs"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;
        
        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = [[self.collection objectAtIndex:indexPath.row] valueForProperty: MPMediaPlaylistPropertyName];
        collectionItem.duration = [self calculatePlaylistDuration: [self.collection objectAtIndex:indexPath.row]];
        collectionItem.collection = [MPMediaItemCollection collectionWithItems: [[self.collection objectAtIndex:indexPath.row] items]];
        
        songViewController.title = collectionItem.name;
        songViewController.collectionItem = collectionItem;

	}
    if ([segue.identifier isEqualToString:@"ViewNowPlaying"])
	{
		MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;

        mainViewController.playNew = NO;
        
    }
}
- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
}


#pragma mark Application state management_____________
// Standard methods for managing application state.
- (void)didReceiveMemoryWarning {
    
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setCollectionTableView:nil];
    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
