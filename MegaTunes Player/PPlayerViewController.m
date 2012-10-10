//
//  PlayerViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/30/12.
//
//

#import "PPlayerViewController.h"

@interface PPlayerViewController ()

@end

@implementation PPlayerViewController

@synthesize songs;
@synthesize nowPlayingLabel;
@synthesize elapsedTimeLabel;
@synthesize progressSlider;
@synthesize remainingTimeLabel;
@synthesize previousButton;
@synthesize playPauseButton;
@synthesize nextButton;
@synthesize nextSongLabel;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.nowPlayingLabel.text = [[self.songs objectAtIndex:0] valueForProperty:  MPMediaItemPropertyTitle];
    self.nextSongLabel.text = [[self.songs objectAtIndex:1] valueForProperty:  MPMediaItemPropertyTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNowPlayingLabel:nil];
    [self setElapsedTimeLabel:nil];
    [self setProgressSlider:nil];
    [self setRemainingTimeLabel:nil];
    [self setPreviousButton:nil];
    [self setPlayPauseButton:nil];
    [self setNextButton:nil];
    [self setNextSongLabel:nil];
    [super viewDidUnload];
}
@end
