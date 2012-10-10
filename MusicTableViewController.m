//
//  MusicTableViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

#import "MusicTableViewController.h"
#import "MainViewController.h"
#import "PlaylistCell.h"
#import "PlaylistDetailController.h"


@interface MusicTableViewController ()

@end

@implementation MusicTableViewController

//static NSString *kCellIdentifier = @"Cell";

@synthesize delegate;					// The main view controller is the delegate for this class.
@synthesize playlists;

//		programmatically supports localization.


// Configures the table view.

- (void) viewDidLoad {
    
    [super viewDidLoad];
	
//    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
    
    NSLog (@"playlists count %d", [self.playlists count]);
    
    return [self.playlists count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
	PlaylistCell *cell = (PlaylistCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"PlaylistCell"];
    MPMediaPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
    cell.nameLabel.text = [playlist valueForProperty: MPMediaPlaylistPropertyName];
    return cell;
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
//	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();
    NSIndexPath *indexPath = [ self.tableView indexPathForCell:sender];
    
	if ([segue.identifier isEqualToString:@"DisplayPlaylist"])
	{
        PlaylistDetailController *playlistDetailController = segue.destinationViewController;

        MPMediaPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];

        MPMediaItemCollection *mediaItemCollection =
                            [MPMediaItemCollection collectionWithItems: [playlist items]];
        
        [self.delegate updatePlayerQueueWithMediaCollection: mediaItemCollection];
        
        playlistDetailController.delegate = (MainViewController *) self.delegate;
        playlistDetailController.title = [playlist valueForProperty: MPMediaPlaylistPropertyName];
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
    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
