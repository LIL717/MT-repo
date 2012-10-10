//
//  InitialViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

#import "InitialViewController.h"
#import "MainViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

@synthesize playlists;
@synthesize choosePlaylist;
@synthesize mainViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.mainViewController = [[MainViewController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setChoosePlaylist:nil];
    [super viewDidUnload];
}

- (IBAction)	choosePlaylist:	(id) sender
{
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
    
    self.playlists = [myPlaylistsQuery collections];
    
    //        for (MPMediaPlaylist *playlist in self.playlists) {
    //            NSLog (@"%@", [playlist valueForProperty: MPMediaPlaylistPropertyName]);
    //            NSArray *songs = [playlist items];
    //            for (MPMediaItem *song in songs) {
    //                NSString *songTitle =
    //                [song valueForProperty: MPMediaItemPropertyTitle];
    //                NSLog (@"\t\t%@", songTitle);
    //            }
    
    //       }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LogMethod();
	if ([segue.identifier isEqualToString:@"ChoosePlaylist"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		MusicTableViewController *musicTableViewController = [[navigationController viewControllers] objectAtIndex:0];
        
        musicTableViewController.delegate = self.mainViewController;
		musicTableViewController.playlists = self.playlists;
	}
}

@end
