//
//  SongInfoViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

#import "SongInfoViewController.h"
#import "AppDelegate.h"
#import "SongInfo.h"

@interface SongInfoViewController ()

@end

@implementation SongInfoViewController

@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize songInfo;

@synthesize songName;
@synthesize album;
@synthesize artist;
@synthesize albumImage;

- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
    
    self.songName = self.songInfo.songName;
    self.album = self.songInfo.album;
    self.artist = self.songInfo.artist;
    self.albumImage = self.songInfo.albumImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setArtist:nil];
    [self setSongName:nil];
    [self setAlbum:nil];
    [self setAlbumImage:nil];
    [super viewDidUnload];
}
@end
