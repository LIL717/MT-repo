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


@interface CollectionViewController ()

@end

@implementation CollectionViewController

@synthesize collection;

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
                                          dequeueReusableCellWithIdentifier:@"CollectionItemCell"];
    
//    MPMediaPlaylist  *mediaPlaylist = [self.collection objectAtIndex:indexPath.row];
//    MPMediaItemCollection *currentQueue = [MPMediaItemCollection collectionWithItems: [[self.collection objectAtIndex:indexPath.row] items]];
    
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
    

//    MPMediaItemCollection *currentQueue = [MPMediaItemCollection collectionWithItems: [[self.collection objectAtIndex:indexPath.row] items]];
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

//    MPMediaItemCollection *currentQueue = [MPMediaItemCollection collectionWithItems: [mediaPlaylist items]];

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
    
	if ([segue.identifier isEqualToString:@"ViewSongs"])
	{
        SongViewController *songViewController = segue.destinationViewController;
//        MPMediaPlaylist *mediaPlaylist = [self.collection objectAtIndex:indexPath.row];
        
        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = [[self.collection objectAtIndex:indexPath.row] valueForProperty: MPMediaPlaylistPropertyName];
        collectionItem.duration = [self calculatePlaylistDuration: [self.collection objectAtIndex:indexPath.row]];
        
        songViewController.title = collectionItem.name;
        songViewController.itemCollection = [MPMediaItemCollection collectionWithItems: [[self.collection objectAtIndex:indexPath.row] items]];
        songViewController.collectionItem = collectionItem;

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
