//
//  PlaylistPickerViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/20/12.
//
//

#import "PPlaylistPickerViewController.h"
#import "PlaylistCell.h"
#import "PlaylistDetailController.h"
#import "MainViewController.h"

@interface PPlaylistPickerViewController ()

@end

@implementation PPlaylistPickerViewController

@synthesize delegate;					// The main view controller is the delegate for this class.
@synthesize playlists;
@synthesize songs;

- (id)initWithStyle:(UITableViewStyle)style
{
        LogMethod();
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog (@"playlists count %d", [self.playlists count]);

    return [self.playlists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PlaylistCell *cell = (PlaylistCell *)[tableView
                             dequeueReusableCellWithIdentifier:@"PlaylistCell"];
    MPMediaPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
    cell.nameLabel.text = [playlist valueForProperty: MPMediaPlaylistPropertyName];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogMethod();

    // Navigation logic may go here. Create and push another view controller.

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LogMethod();
    NSIndexPath *indexPath = [ self.tableView indexPathForCell:sender];
    
	if ([segue.identifier isEqualToString:@"DisplayPlaylist"])
	{
//		UINavigationController *navigationController = segue.destinationViewController;
//		PlaylistDetailController *playlistDetailController = [[navigationController viewControllers] objectAtIndex:0];
        PlaylistDetailController *playlistDetailController = segue.destinationViewController;
        MPMediaPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
        
        self.songs = [playlist items];
        
        //************
        MPMediaItemCollection *mediaItemCollection = [MPMediaItemCollection collectionWithItems: self.songs];

//        MainViewController *mainViewController = (MainViewController *) self.delegate;
//        [mainViewController updatePlayerQueueWithMediaCollection: newQueue];
        
        [self.delegate updatePlayerQueueWithMediaCollection: mediaItemCollection];
        
        MainViewController *mainViewController = (MainViewController *) self.delegate;
        MPMediaItemCollection *currentQueue = mainViewController.userMediaItemCollection;
        //
        for (MPMediaItem *song in [currentQueue items]) {
            NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
            NSLog (@"\t\t%@", songTitle);
        }


//        //***************
//        
//        
//
//
//        playlistDetailController.songs = self.songs;
        playlistDetailController.title = [playlist valueForProperty: MPMediaPlaylistPropertyName];
//        navigationController.navigationItem.backBarButtonItem.title = @"Playlists";
	}
}
//#pragma mark - PlayerDetailsViewControllerDelegate
//
//- (void)playlistDetailControllerDidCancel:(PlaylistDetailController *)controller
//{
//	[self dismissViewControllerAnimated:YES completion:nil];
//}
//
////- (void)playlistDetailController:(PlaylistDetailController *)controller
////                       didAddPlaylist:(Playlist *)playlist
////{
////	[self.playlists addObject:playlist];
////	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.playlists count] - 1
////                       inSection:0];
////	[self.tableView insertRowsAtIndexPaths:
////     [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
////	[self dismissViewControllerAnimated:YES completion:nil];
////}
@end
