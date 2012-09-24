//
//  MusicTableViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import "MusicTableViewController.h"
#import "MainViewController.h"

@interface MusicTableViewController ()

@end

@implementation MusicTableViewController

static NSString *kCellIdentifier = @"Cell";

@synthesize delegate;					// The main view controller is the delegate for this class.
@synthesize mediaItemCollectionTable;	// The table shown in this class's view.
@synthesize addMusicButton;				// The button for invoking the media item picker. Setting the title
//		programmatically supports localization.

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Configures the table view.
- (void) viewDidLoad {
    
    [super viewDidLoad];
	
	[self.addMusicButton setTitle: NSLocalizedString (@"AddMusicFromTableView", @"Add button shown on table view for invoking the media item picker")];
	
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}


// When the user taps Done, invokes the delegate's method that dismisses the table view.
- (IBAction) doneShowingMusicList: (id) sender {
    
	[self.delegate musicTableViewControllerDidFinish: self];
}


// Configures and displays the media item picker.
- (IBAction) showMediaPicker: (id) sender {
    
	MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	
	picker.delegate						= self;
	picker.allowsPickingMultipleItems	= YES;
	picker.prompt						= NSLocalizedString (@"AddSongsPrompt", @"Prompt to user to choose some songs to play");
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];
    
	[self presentModalViewController: picker animated: YES];
//	[picker release];
}


// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
	[self dismissModalViewControllerAnimated: YES];
	[self.delegate updatePlayerQueueWithMediaCollection: mediaItemCollection];
	[self.mediaItemCollectionTable reloadData];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}


// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
	[self dismissModalViewControllerAnimated: YES];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}



#pragma mark Table view methods________________________

// To learn about using table views, see the TableViewSuite sample code
//		and Table View Programming Guide for iPhone OS.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
    
	MainViewController *mainViewController = (MainViewController *) self.delegate;
	MPMediaItemCollection *currentQueue = mainViewController.userMediaItemCollection;
	return [currentQueue.items count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
	NSInteger row = [indexPath row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier];
	
	if (cell == nil) {
        
		cell = [[[UITableViewCell alloc] initWithFrame: CGRectZero
									   reuseIdentifier: kCellIdentifier] autorelease];
	}
	
	MainViewController *mainViewController = (MainViewController *) self.delegate;
	MPMediaItemCollection *currentQueue = mainViewController.userMediaItemCollection;
	MPMediaItem *anItem = (MPMediaItem *)[currentQueue.items objectAtIndex: row];
	
	if (anItem) {
		cell.textLabel.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
	}
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	return cell;
}
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	PlaylistCell *cell = (PlaylistCell *)[tableView
//                                          dequeueReusableCellWithIdentifier:@"Playlist"];
//	Playlist *playlist = [self.playlists objectAtIndex:indexPath.row];
//    cell.nameLabel.text = playlist.name;
//    cell.durationLabel.text = playlist.duration;
//    cell.coverImageView.image = [UIImage imageNamed:@"vinyl-record.jpg"];
//    return cell;
//}


//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark Application state management_____________
// Standard methods for managing application state.
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end

