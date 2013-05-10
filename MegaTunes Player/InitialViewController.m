//
//  InitialViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

#import "InitialViewController.h"
#import "ArtistViewController.h"
#import "AppDelegate.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

@synthesize playlists;
@synthesize choosePlaylist;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
    [self.choosePlaylist setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self.choosePlaylist setBackgroundColor: [UIColor clearColor]];
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

- (IBAction) choosePlaylist: (id) sender
{
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
    
    self.playlists = [myPlaylistsQuery collections];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LogMethod();
	if ([segue.identifier isEqualToString:@"ChoosePlaylist"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		ArtistViewController *musicTableViewController = [[navigationController viewControllers] objectAtIndex:0];
        
		musicTableViewController.collection = self.playlists;
	}
}

@end
