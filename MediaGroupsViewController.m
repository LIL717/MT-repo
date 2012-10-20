//
//  MediaGroupsViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

#import "MediaGroupsViewController.h"
#import "CollectionItemCell.h"
#import "CollectionItem.h"
#import "CollectionViewController.h"
#import "AppDelegate.h"

@interface MediaGroupsViewController ()

@end

@implementation MediaGroupsViewController

@synthesize collection;
@synthesize playlist;

// Configures the table view.

- (void) viewDidLoad {
    
    [super viewDidLoad];
	
//    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[AppDelegate instance].colorSwitcher processImageWithName:@"background.png"]]];
}

#pragma mark Table view methods________________________

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
                                          dequeueReusableCellWithIdentifier:@"PlaylistCell"];
    MPMediaPlaylist  *mediaPlaylist = [self.collection objectAtIndex:indexPath.row];
    cell.nameLabel.text = [mediaPlaylist valueForProperty: MPMediaPlaylistPropertyName];
    NSLog (@"MPMediaItemPropertyTitle is %@", [mediaPlaylist valueForProperty: MPMediaPlaylistPropertyName]);
    
    NSNumber *playlistDurationNumber = [self calculatePlaylistDuration: mediaPlaylist];
    long playlistDuration = [playlistDurationNumber longValue];

    int playlistMinutes = (playlistDuration / 60);     // Whole minutes
    int playlistSeconds = (playlistDuration % 60);                        // seconds
    cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];

    return cell;
}
- (NSNumber *)calculatePlaylistDuration: (MPMediaPlaylist *) mediaPlaylist {

    MPMediaItemCollection *currentQueue = [MPMediaItemCollection collectionWithItems: [mediaPlaylist items]];

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
    NSIndexPath *indexPath = [ self.tableView indexPathForCell:sender];
    
	if ([segue.identifier isEqualToString:@"DisplayPlaylist"])
	{
        CollectionViewController *collectionViewController = segue.destinationViewController;
        MPMediaPlaylist *mediaPlaylist = [self.collection objectAtIndex:indexPath.row];
        
        CollectionItem *selectedPlaylist = [CollectionItem alloc];
        selectedPlaylist.name = [mediaPlaylist valueForProperty: MPMediaPlaylistPropertyName];
        selectedPlaylist.duration = [self calculatePlaylistDuration: mediaPlaylist];
        
        collectionViewController.title = selectedPlaylist.name;
        collectionViewController.itemCollection = [MPMediaItemCollection collectionWithItems: [mediaPlaylist items]];
        collectionViewController.playlist = selectedPlaylist;

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
