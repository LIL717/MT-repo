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
@synthesize collectionItem;
@synthesize saveIndexPath;


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
    [self.collectionTableView reloadData];
    
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

    //get the duration of the the playlist
    
    NSNumber *playlistDurationNumber = [self calculatePlaylistDuration: currentQueue];
    long playlistDuration = [playlistDurationNumber longValue];
    
    int playlistMinutes = (playlistDuration / 60);     // Whole minutes
    int playlistSeconds = (playlistDuration % 60);                        // seconds
    cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];
    

    
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
    accessory.highlightedColor = [UIColor blueColor];
    cell.accessoryView = accessory;
    
    //size of duration Label is set at 138 to match the fixed size that it is set in interface builder
    // note that cell.durationLabel.frame.size.width) = 0 here
    //    NSLog (@"************************************width of durationLabel is %f", cell.durationLabel.frame.size.width);

    // if want to make scrollview width flex with width of duration label, need to set it up in code rather than interface builder - not doing that now, but don't see any problem with doing it
    
//    CGSize durationLabelSize = [cell.durationLabel.text sizeWithFont:cell.durationLabel.font
//                                                   constrainedToSize:CGSizeMake(135, CGRectGetHeight(cell.durationLabel.bounds))
//                                                       lineBreakMode:NSLineBreakByClipping];
    
    NSUInteger scrollViewWidth;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        scrollViewWidth = (tableView.frame.size.width - cell.accessoryView.frame.size.width);
    } else {
//        scrollViewWidth = (tableView.frame.size.width - durationLabelSize.width - cell.accessoryView.frame.size.width);
        scrollViewWidth = (tableView.frame.size.width - 138 - cell.accessoryView.frame.size.width);

    }
    
    //calculate the label size to fit the text with the font size
    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
                                       constrainedToSize:CGSizeMake(INT16_MAX, tableView.rowHeight)
                                           lineBreakMode:NSLineBreakByClipping];
    
    //build a new label that will hold all the text
    UILabel *newLabel = [[UILabel alloc] initWithFrame: cell.nameLabel.frame];
    CGRect frame = newLabel.frame;
    frame.size.height = labelSize.height;
    frame.size.width = labelSize.width + 1;
    frame.origin = CGPointZero;
    newLabel.frame = frame;

    
    //calculate the size (w x h) for the scrollview content
    CGSize size;
    size.width = CGRectGetWidth(newLabel.bounds);
    size.height = CGRectGetHeight(newLabel.bounds);
    cell.scrollView.contentSize = size;
    
//    CGRect scrollFrame = cell.scrollView.frame;
//    scrollFrame.size.width = scrollViewWidth;
//    cell.scrollView.frame = scrollFrame;
    cell.nameLabel.frame = newLabel.frame;
//    cell.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    
//    NSLog (@"size of newLabel is %f x %f", newLabel.frame.size.width, newLabel.frame.size.height);
//    NSLog (@"size of scrollViewWidth is %d", scrollViewWidth);
//    NSLog (@"cell.nameLabel.text is %@", cell.nameLabel.text);

    //enable scroll if the content will not fit within the scrollView
    if (cell.scrollView.contentSize.width>scrollViewWidth) {
        cell.scrollView.scrollEnabled = YES;
//        NSLog (@"scrollEnabled");
    }
    else {
        cell.scrollView.scrollEnabled = NO;
//        NSLog (@"scrollDisabled");

    }
    //the gesture recognizers for tap in the scrollview was somehow lost, so add it again to whole cell
    // add tap gesture to whole cell
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapDetected:)];

    [cell addGestureRecognizer:tap];
    
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
    
    LogMethod();
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();
//    NSIndexPath *indexPath = [ self.collectionTableView indexPathForCell:sender];
    
	if ([segue.identifier isEqualToString:@"ViewSongs"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;
        
        songViewController.title = self.collectionItem.name;
        NSLog (@"self.collectionItem.name is %@", self.collectionItem.name);
        songViewController.collectionItem = self.collectionItem;
        
//        CollectionItem *collectionItem = [CollectionItem alloc];
//        collectionItem.name = [[self.collection objectAtIndex:indexPath.row] valueForProperty: MPMediaPlaylistPropertyName];
//        collectionItem.duration = [self calculatePlaylistDuration: [self.collection objectAtIndex:indexPath.row]];
//        collectionItem.collection = [MPMediaItemCollection collectionWithItems: [[self.collection objectAtIndex:indexPath.row] items]];
//        
//        songViewController.title = collectionItem.name;
//        songViewController.collectionItem = collectionItem;

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

// need to handle the tap manually because scrollview lost recognition of tap when sized

-(void)tapDetected:(UITapGestureRecognizer*)tapGesture
    {

        if (tapGesture.state == UIGestureRecognizerStateEnded)
        {
            UITableView* tableView = (UITableView*)self.view;
            CGPoint touchPoint = [tapGesture locationInView:self.view];
//            NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:touchPoint];
            self.saveIndexPath = [tableView indexPathForRowAtPoint:touchPoint];

//            if (indexPath != nil) {
//                self.collectionItem = [CollectionItem alloc];
//                self.collectionItem.name = [[self.collection objectAtIndex:indexPath.row] valueForProperty: MPMediaPlaylistPropertyName];
//                self.collectionItem.duration = [self calculatePlaylistDuration: [self.collection objectAtIndex:indexPath.row]];
//                self.collectionItem.collection = [MPMediaItemCollection collectionWithItems: [[self.collection objectAtIndex:indexPath.row] items]];
//                
            if (saveIndexPath != nil) {
                
                CollectionItemCell *cell = (CollectionItemCell *)[tableView cellForRowAtIndexPath:saveIndexPath];
                cell.nameLabel.highlighted = YES;
                
                self.collectionItem = [CollectionItem alloc];
//                self.collectionItem.name = [[self.collection objectAtIndex:saveIndexPath.row] valueForProperty: MPMediaPlaylistPropertyName];
                self.collectionItem.name = cell.nameLabel.text;
                self.collectionItem.duration = [self calculatePlaylistDuration: [self.collection objectAtIndex:saveIndexPath.row]];
                self.collectionItem.collection = [MPMediaItemCollection collectionWithItems: [[self.collection objectAtIndex:saveIndexPath.row] items]];
                

                
                //have to set these manually
                
                cell.durationLabel.highlighted = YES;
                DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
                accessory.highlightedColor = [UIColor blueColor];
                accessory.highlighted = YES;
                cell.accessoryView = accessory;

                [self performSegueWithIdentifier: @"ViewSongs" sender: self];
            }
        }
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
// neeed to programmatically unhighlight because highlighting was done programmatically

- (void)viewDidDisappear:(BOOL)animated {
    //    LogMethod();
    [super viewDidDisappear: animated];

    if (saveIndexPath != nil) {
        CollectionItemCell *cell = (CollectionItemCell *)[self.collectionTableView cellForRowAtIndexPath:saveIndexPath];
        cell.nameLabel.highlighted = NO;
        cell.durationLabel.highlighted = NO;
        DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
        accessory.highlightedColor = [UIColor blueColor];
        accessory.highlighted = NO;
        cell.accessoryView = accessory;
    }
}
@end
