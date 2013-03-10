//
//  SongViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
#import "MainViewController.h"
#import "InfoTabBarController.h"
#import "SongViewController.h"
#import "SongCell.h"
#import "inCellScrollView.h"
#import "CollectionItem.h"
#import "ItemCollection.h"
#import "UIImage+AdditionalFunctionalities.h"

@implementation SongViewController

@synthesize songTableView;
@synthesize collectionItem;
@synthesize musicPlayer;
@synthesize managedObjectContext;
@synthesize mediaItemForInfo;
@synthesize itemToPlay;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync


- (void)viewDidLoad
{
//    LogMethod();
    [super viewDidLoad];
    
    //set the backround image for the view
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    //make the back arrow for left bar button item
    
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
    

    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];

    //    self.currentQueue = self.mainViewController.userMediaItemCollection;
    
    //    NSArray *returnedQueue = [self.currentQueue items];
    //
    //    for (MPMediaItem *song in returnedQueue) {
    //        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    //        NSLog (@"\t\t%@", songTitle);
    //    }
    [self registerForMediaPlayerNotifications];
    
}

- (void) viewWillAppear:(BOOL)animated
{
//    LogMethod();
    [super viewWillAppear: animated];
    
    //set the navigation bar title
    self.navigationItem.titleView = [self customizeTitleView];
    
    //if there is a currently playing item, add a right button to the nav bar
    
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
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];

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

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
//    LogMethod();
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.songTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];

    } else {
        [self.songTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        //if rotating to landscape and row 0 will be visible, need to scrollRectToVisible to align it correctly
        NSArray *indexes = [self.songTableView indexPathsForVisibleRows];
        for (NSIndexPath *index in indexes) {
            if (index.row == 0) {
                [self.songTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                return;
            }
            
        }
    }
}
- (void) viewWillLayoutSubviews {
        //need this to pin portrait view to bounds otherwise if start in landscape, push to next view, rotate to portrait then pop back the original view in portrait - it will be too wide and "scroll" horizontally
    self.songTableView.contentSize = CGSizeMake(self.songTableView.frame.size.width, self.songTableView.contentSize.height);
    [super viewWillLayoutSubviews];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    LogMethod();
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [[self.collectionItem.collection items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SongCell *cell = (SongCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"SongCell"];
    
    MPMediaItem *song = [[self.collectionItem.collection items] objectAtIndex:indexPath.row];
    

    
    //make the accessory view into a custom info button
    
    UIImage *image = [UIImage imageNamed: @"infoLightButtonImage.png"];
    UIImage *backgroundImage = [UIImage imageNamed: @"infoSelectedButtonImage.png"];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage: backgroundImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(infoButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    //this would need some work - crashes with auto layout issues
//    [cell.infoBackground addSubview: button];
//    
//    cell.infoBackground.translatesAutoresizingMaskIntoConstraints = NO;
//    button.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(cell.infoBackground, button);
//    
//    [cell.infoBackground addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|" options:0 metrics: 0 views:viewsDictionary]];
//    [cell.infoBackground addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics: 0 views:viewsDictionary]];

    //playback duration of the song
    
    long playbackDuration = [[song valueForProperty: MPMediaItemPropertyPlaybackDuration] longValue];
    
    //if song has been deleted during a sync then pop to rootViewController
    if (playbackDuration == 0 && self.iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        NSLog (@"BOOM");
    }
    int playbackHours = (playbackDuration / 3600);                         // returns number of whole hours fitted in totalSecs
    int playbackMinutes = ((playbackDuration / 60) - playbackHours*60);     // Whole minutes
    int playbackSeconds = (playbackDuration % 60);                        // seconds
    cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playbackMinutes, playbackSeconds];
    
//    NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
//    NSNumber *duration = [song valueForProperty: MPMediaItemPropertyPlaybackDuration];
//    NSLog (@"\t\t%@,%@", songTitle,duration);
    
    //set the red arrow on the row if this is the currently playing song
    if ([musicPlayer nowPlayingItem] == song) {
        cell.playingIndicator.image = [UIImage imageNamed:@"playing"];
    } else {
        cell.playingIndicator.image = [UIImage imageNamed:@"notPlaying"];
    }
    // Display text

    cell.nameLabel.text = [song valueForProperty:  MPMediaItemPropertyTitle];

    //calculate the label size to fit the text with the font size
    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
                                       constrainedToSize:CGSizeMake(INT16_MAX, tableView.rowHeight)
                                           lineBreakMode:NSLineBreakByClipping];

    //calculate the width of the actual scrollview
    //cell.playingIndicator is 20
    //durationLabelSize.width is 98
    //cell.accessoryView.frame.size.width is 42
    // so scrollViewWidth should be 480-24-98-42 = 316   or 320-28-42= 250
    NSUInteger scrollViewWidth;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        scrollViewWidth = (tableView.frame.size.width - 28 - cell.accessoryView.frame.size.width);
    } else {
        scrollViewWidth = (tableView.frame.size.width - 24 - 98 - cell.accessoryView.frame.size.width);
    }
    //Make sure that label is aligned with scrollView
    [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    if (labelSize.width>scrollViewWidth) {

        cell.scrollView.scrollEnabled = YES;
        //        NSLog (@"scrollEnabled");
    }
    else {
        cell.scrollView.scrollEnabled = NO;
        //        NSLog (@"scrollDisabled");
    }
    return cell;
}


#pragma mark - Table view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    //set the "nowPlaying indicator" as the view disappears (already selected play indicator is still there too :(
    SongCell *cell = (SongCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.playingIndicator.image = [UIImage imageNamed:@"playing"];
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
        NSIndexPath *indexPath = [self.songTableView indexPathForCell:sender];
        mainViewController.itemToPlay = [[self.collectionItem.collection items] objectAtIndex:indexPath.row];


        mainViewController.userMediaItemCollection = self.collectionItem.collection;
        mainViewController.playNew = YES;
        mainViewController.iPodLibraryChanged = self.iPodLibraryChanged;

        
        //save collection in Core Data
        ItemCollection *itemCollection = [ItemCollection alloc];
        itemCollection.managedObjectContext = self.managedObjectContext;
        
        [itemCollection addCollectionToCoreData: self.collectionItem];

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
- (void)goBackClick
{
    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
    [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)infoButtonTapped:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.songTableView];
    NSIndexPath *indexPath = [self.songTableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
    {
        [self tableView: self.songTableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    MPMediaItem *song = [[self.collectionItem.collection items] objectAtIndex:indexPath.row];
    
    self.mediaItemForInfo = song;
    
    [self performSegueWithIdentifier: @"ViewInfo" sender: self];
}

- (void) registerForMediaPlayerNotifications {
//    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
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
// When the now-playing item changes, update the now-playing indicator and reload table
- (void) handle_NowPlayingItemChanged: (id) notification {
//    LogMethod();

    [self.songTableView reloadData];
}
//#pragma mark - NotesTabBarControllerDelegate

- (void)infoTabBarControllerDidCancel:(InfoTabBarController *)controller
{
    [self willAnimateRotationToInterfaceOrientation: self.interfaceOrientation duration: 1];
    //need to add back observer for playbackStatechanged because it was removed before going to info in case user edits
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
}
- (void)dealloc {
//    LogMethod();
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
