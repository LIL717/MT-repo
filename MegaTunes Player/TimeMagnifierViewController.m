//
//  TimeMagnifierViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/15/12.
//
//

#import "TimeMagnifierViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@interface TimeMagnifierViewController ()

@end

@implementation TimeMagnifierViewController

@synthesize magnifiedText;
@synthesize textToMagnify;
@synthesize delegate;
@synthesize playbackTimer;
@synthesize timeType;
@synthesize musicPlayer;


#pragma mark - Initial Display methods


- (void)viewDidLoad
{
//    LogMethod();
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];

//131203 1.2 iOS 7 begin
    
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
//131203 1.2 iOS 7 end

    [self.magnifiedText.titleLabel setNumberOfLines: 1];
    [self.magnifiedText.titleLabel setAdjustsFontSizeToFitWidth: YES];
    
    [self.magnifiedText setTitle: self.textToMagnify forState: UIControlStateNormal];

    [self registerForMediaPlayerNotifications];

}

- (void) updateTime {
    MainViewController *mainViewController =( MainViewController *) self.delegate;
    [mainViewController updateTime];
    
    if ([self.timeType isEqualToString: @"MagnifyElapsedTime"]) {
        [self.magnifiedText setTitle:  mainViewController.elapsedTimeLabel.text
                            forState: UIControlStateNormal];
    }
    if ([self.timeType isEqualToString:@"MagnifyRemainingTime" ]) {
        [self.magnifiedText setTitle: mainViewController.remainingTimeLabel.text
                            forState: UIControlStateNormal];
    }
    if ([self.timeType isEqualToString: @"MagnifyPlaylistRemaining"]) {
        [self.magnifiedText setTitle: mainViewController.navigationItem.rightBarButtonItem.title
                            forState: UIControlStateNormal];
    }
    if ([self.timeType isEqualToString: @"StartStopWatch"]) {
        [self.magnifiedText setTitle: mainViewController.stopWatchTime
                            forState: UIControlStateNormal];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    //    LogMethod();
    [super viewWillAppear: animated];
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateTime)
                                                        userInfo:nil
                                                         repeats:YES];
    
}
-(void) viewDidAppear:(BOOL)animated {
    //    LogMethod();
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super viewDidAppear:(BOOL)animated];
}
- (IBAction)cancel:(id)sender
{
    //    LogMethod();
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self.delegate timeMagnifierViewControllerDidCancel:self];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    //    LogMethod();
    [super viewWillDisappear: animated];
    [self.playbackTimer invalidate];
    
}
- (void) registerForMediaPlayerNotifications {
    //    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    //don't need handle_PlaybackStateChanged because that will only happen here is NowPlayingItemChanged and responding to both does not work
    
    [musicPlayer beginGeneratingPlaybackNotifications];
    
}
// If displaying now-playing item when it changes, update mediaItemForInfo and show info for currently playing song
- (void) handle_PlaybackStateChanged: (id) notification {
    LogMethod();
    
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];

    if (playbackState == MPMusicPlaybackStateStopped) {
        
        if ([self.timeType isEqualToString: @"StartStopWatch"]) {
            return;
        } else {
    //pop out of here if the player is stopped (except if the stop watch is going)

            [self.delegate timeMagnifierViewControllerDidCancel:self];
        }
    }
    
}

- (void)dealloc {
    LogMethod();
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
- (void)didReceiveMemoryWarning
{
    //    LogMethod();
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
