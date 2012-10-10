//
//  MusicTableViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/25/12.
//
//


#import "MMusicTableViewController.h"
#import "MainViewController.h"
#import "PlaylistCell.h"


@interface MMusicTableViewController ()

@end

@implementation MMusicTableViewController

static NSString *kCellIdentifier = @"Cell";

@synthesize delegate;					// The main view controller is the delegate for this class.
@synthesize mediaItemCollectionTable;	// The table shown in this class's view.
@synthesize addMusicButton;				// The button for invoking the media item picker. Setting the title
//		programmatically supports localization.


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
    
    [self presentViewController: picker animated:YES completion:NULL];
}


// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
	[self.delegate updatePlayerQueueWithMediaCollection: mediaItemCollection];
	[self.mediaItemCollectionTable reloadData];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}


// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
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

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
	PlaylistCell *cell = (PlaylistCell *)[tableView
                                            dequeueReusableCellWithIdentifier:@"MusicListCell"];
    
	MainViewController *mainViewController = (MainViewController *) self.delegate;
	MPMediaItemCollection *currentQueue = mainViewController.userMediaItemCollection;
	MPMediaItem *anItem = (MPMediaItem *)[currentQueue.items objectAtIndex:indexPath.row];
    
	if (anItem) {
		cell.nameLabel.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
	}
    
    //	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
	return cell;
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}



- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
    
	MainViewController *mainViewController = (MainViewController *) self.delegate;
	MPMediaItemCollection *currentQueue = mainViewController.userMediaItemCollection;
	return [currentQueue.items count];
}

#pragma mark Application state management_____________
// Standard methods for managing application state.
- (void)didReceiveMemoryWarning {
    
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
