//
//  MainViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import "MainViewController.h"
#import "CollectionItem.h"
#import "TextMagnifierViewController.h"
#import "TimeMagnifierViewController.h"
#import "AppDelegate.h"
#import "ItemCollection.h"
#import "UIImage+AdditionalFunctionalities.h"
#import "InfoTabBarController.h"
#import "MediaItemUserData.h"
#import "UserInfoViewcontroller.h"
#import "OBSlider.h"
//#import "AppDelegate.h"
//#import "NSDateFormatter+Duration.h"

#pragma mark Audio session callbacks_______________________

// Audio session callback function for responding to audio route changes. If playing
//		back application audio when the headset is unplugged, this callback pauses
//		playback and displays an alert that allows the user to resume or stop playback.
//
//		The system takes care of iPod audio pausing during route changes--this callback
//		is not involved with pausing playback of iPod audio.
//void audioRouteChangeListenerCallback (
//                                       void                      *inUserData,
//                                       AudioSessionPropertyID    inPropertyID,
//                                       UInt32                    inPropertyValueSize,
//                                       const void                *inPropertyValue
//                                       ) {
//	
//	// ensure that this callback was invoked for a route change
//	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
//    
//	// This callback, being outside the implementation block, needs a reference to the
//	//		MainViewController object, which it receives in the inUserData parameter.
//	//		You provide this reference when registering this callback (see the call to
//	//		AudioSessionAddPropertyListener).
//	MainViewController *controller = (__bridge MainViewController *) inUserData;
//	
//	// if application sound is not playing, there's nothing to do, so return.
//	if (controller.appSoundPlayer.playing == 0 ) {
//        
//		NSLog (@"Audio route change while application audio is stopped.");
//		return;
//		
//	} else {
//        
//		// Determines the reason for the route change, to ensure that it is not
//		//		because of a category change.
//		CFDictionaryRef	routeChangeDictionary = inPropertyValue;
//		
//		CFNumberRef routeChangeReasonRef =
//        CFDictionaryGetValue (
//                              routeChangeDictionary,
//                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
//                              );
//        
//		SInt32 routeChangeReason;
//		
//		CFNumberGetValue (
//                          routeChangeReasonRef,
//                          kCFNumberSInt32Type,
//                          &routeChangeReason
//                          );
//		
//		// "Old device unavailable" indicates that a headset was unplugged, or that the
//		//	device was removed from a dock connector that supports audio output. This is
//		//	the recommended test for when to pause audio.
//		if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
//            
//			[controller.appSoundPlayer pause];
//			NSLog (@"Output device removed, so application audio was paused.");
//            
//			UIAlertView *routeChangeAlertView =
//            [[UIAlertView alloc]	initWithTitle: NSLocalizedString (@"Playback Paused", @"Title for audio hardware route-changed alert view")
//                                       message: NSLocalizedString (@"Audio output was changed", @"Explanation for route-changed alert view")
//                                      delegate: controller
//                             cancelButtonTitle: NSLocalizedString (@"StopPlaybackAfterRouteChange", @"Stop button title")
//                             otherButtonTitles: NSLocalizedString (@"ResumePlaybackAfterRouteChange", @"Play button title"), nil];
//			[routeChangeAlertView show];
//			// release takes place in alertView:clickedButtonAtIndex: method
//            
//		} else {
//            
//			NSLog (@"A route change occurred that does not require pausing of application audio.");
//		}
//	}
//}
//


@implementation MainViewController

@synthesize userMediaItemCollection;	// the media item collection created by the user, using the media item picker
@synthesize musicPlayer;				// the music player, which plays media items from the iPod library

@synthesize navigationBar;				// the application's Navigation bar
@synthesize nowPlayingLabel;			// descriptive text shown on the main screen about the now-playing media item
@synthesize appSoundPlayer;				// An AVAudioPlayer object for playing application sound
@synthesize soundFileURL;				// The path to the application sound
@synthesize interruptedOnPlayback;		// A flag indicating whether or not the application was interrupted during application audio playback
@synthesize playedMusicOnce;			// A flag indicating if the user has played iPod library music at least one time since application launch.
@synthesize playing;					// An application that responds to interruptions must keep track of its playing not-playing state.
@synthesize playbackTimer;
@synthesize nowPlayingInfoCenter;
@synthesize playNew;                    //Flag set if new song has been selected to play
@synthesize itemToPlay;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize mediaItemForInfo;           // mediaItem which gets passed to info view controllers
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize showPlaylistRemaining;      //A flag the captures the user's preference from setting whether to display the amount of time left in playlist
@synthesize queueIsKnown;               //a flag the indicates whether the actually playing queue matches the queue that was saved
@synthesize initialView;                //used with the process of figuring our whether playing queue matches queue that was saved
@synthesize skippedBack;                //set when shipBack used with predictedNextPlaying
@synthesize savedNowPlaying;             //for some reason a new song calls the handle_NowPlayingItemChanged: method twice, so this is used to save and compare
//@synthesize appDelegate;
@synthesize predictedNextItem;
@synthesize userInfoViewController;
//these lines came from player view controller
@synthesize userIsScrubbing;
@synthesize hasFinishedMoving;
@synthesize songShuffleButtonPressed;
@synthesize collectionContainsICloudItem;
@synthesize stopWatchBarButton;

@synthesize currentQueue;
@synthesize elapsedTimeLabel;
@synthesize progressSlider;
@synthesize remainingTimeLabel;

@synthesize initialNowPlayingLabel;
@synthesize volumeView;
@synthesize nextLabel;
@synthesize nextSongScrollView;
@synthesize nextSongLabel;
@synthesize collectionItem;
@synthesize swipeLeftRight;
@synthesize stopWatchTime;

@synthesize rewindButton;
@synthesize playPauseButton;
@synthesize forwardButton;
@synthesize repeatButton;
@synthesize shuffleButton;

@synthesize leadingSpaceToSliderConstraint;
@synthesize trailingSpaceFromSliderConstraint;
@synthesize verticalSpaceBetweenSliderAndElapsedTime;
@synthesize verticalSpaceBetweenSliderAndRemainingTime;
@synthesize verticalSpaceBetweenRewindAndReplay;
@synthesize topSpaceToPlayButton;
@synthesize playButtonToBottomSpace;

@synthesize nextSongLabelWidthConstraint;
@synthesize nowPlayingInfoButton;

@synthesize currentPlaybackPosition;
@synthesize savedPlaybackState;

float savedHandleValue;
float saveVolume;
MPMusicPlaybackState savedPlaybackState;
long collectionRemainingSeconds;
long songRemainingSeconds;
NSTimeInterval stopWatchStartTime;
BOOL stopWatchRunning;



#pragma mark - Initial Display methods

// Configure the application.

- (void) viewDidLoad {
//    LogMethod();
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"MainViewController"];
    
    UIImage *backgroundImage = [UIImage imageNamed: @"infoSelectedButtonImage.png"];
    [self.nowPlayingInfoButton setImage: backgroundImage forState:UIControlStateHighlighted];
    self.nextLabel.textColor = [UIColor yellowColor];

    
    self.navigationItem.hidesBackButton = YES; // Important
    //initWithTitle cannot be nil, must be @""
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBackClick)];
    
    self.navigationItem.leftBarButtonItem.title = @"";
    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    self.navigationItem.backBarButtonItem = self.navigationItem.leftBarButtonItem;
    

    
    self.stopWatchBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(startStopWatch)];
    
    UIImage *menuBarImageDefault = [[UIImage imageNamed:@"stopWatchIcon57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"stopWatchIcon68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.stopWatchBarButton setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.stopWatchBarButton setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    //need this to use MPNowPlayingInfoCenter
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    [self setPlayedMusicOnce: NO];

    [self setMusicPlayer: [MPMusicPlayerController iPodMusicPlayer]];

    self.showPlaylistRemaining = [[NSUserDefaults standardUserDefaults] boolForKey:@"showPlaylistRemaining"];

    //title will only be displayed if playlist remaining is turned off
    if (self.showPlaylistRemaining) {
        self.title = nil;
        self.navigationItem.titleView = nil;
    } else {
        self.title = NSLocalizedString(@"Now Playing", nil);
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.titleView = [self customizeTitleView];
    }

    self.swipeLeftRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(togglePlaylistRemainingAndTitle:)];
    [self.swipeLeftRight setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
    [self.navigationController.navigationBar addGestureRecognizer:self.swipeLeftRight];

    //    NSArray *returnedQueue = [self.userMediaItemCollection items];
    //
    //    for (MPMediaItem *song in returnedQueue) {
    //        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    //        NSLog (@"\t\t%@", songTitle);
    //    }
    //assume queue is known until it is validated by checking nextSong when it becomes the nowPlaying
    queueIsKnown = YES;
    initialView = YES;
    skippedBack = NO;

//    if (self.itemToPlay == [musicPlayer nowPlayingItem]) {
//        [self setPlayNew: NO];
//    }
    if (playNew) {
        [musicPlayer setQueueWithItemCollection: self.userMediaItemCollection];
        [musicPlayer setNowPlayingItem: self.itemToPlay];
        [self playMusic];
        if (self.songShuffleButtonPressed) {
            [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
            [musicPlayer setShuffleMode: MPMusicShuffleModeSongs];
            self.songShuffleButtonPressed = NO;
        }
//        [self setPlayNew: NO];  this gets set in viewDidAppear instead
        
    } else if ([musicPlayer nowPlayingItem]) {

        // Update the UI to reflect the now-playing item except nowPlayingLabel must be set in viewWillAppear instead of viewDidLoad or it appears from bottom
        
        MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
        //    NSLog (@" currentItem is %@", [currentItem valueForProperty: MPMediaItemPropertyTitle]);
        //check the queue stored in Core Data to see if the nowPlaying song is in that queue
        ItemCollection *itemCollection = [ItemCollection alloc];
        itemCollection.managedObjectContext = self.managedObjectContext;
        
        //    self.collectionItem = [itemCollection containsItem: [currentItem valueForProperty: MPMediaItemPropertyTitle]];
        self.collectionItem = [itemCollection containsItem: [currentItem valueForProperty:  MPMediaItemPropertyPersistentID]];
        
        self.userMediaItemCollection = collectionItem.collection;
        
        NSUInteger nextPlayingIndex = [musicPlayer indexOfNowPlayingItem] + 1;

        if (nextPlayingIndex < self.userMediaItemCollection.count) {
            predictedNextItem = [[self.userMediaItemCollection items] objectAtIndex: [musicPlayer indexOfNowPlayingItem] + 1 ];
        } else {
            predictedNextItem = nil;
        }
        [self prepareAllExceptNowPlaying];
    }
    // check if there are iCloud items in the queue
    self.collectionContainsICloudItem = NO;
    [self checkForICloudItemsWithCompletion:^(BOOL result) {
        
    }];
//    //print out the queue tat is saved
//    NSArray *returnedQueue = [self.userMediaItemCollection items];
//
//    for (MPMediaItem *song in returnedQueue) {
//        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSLog (@"\t\t%@", songTitle);
//    }
    
    if ([musicPlayer playbackState] != MPMusicPlaybackStatePlaying) {
        [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
    } else if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [playPauseButton setImage: [UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
    }
    
    //set the temp initialNowPlayingLabel so something is there when view loads, gets removed from view in viewDidAppear when autoScrollLabel is created
    self.initialNowPlayingLabel.text = [[musicPlayer nowPlayingItem] valueForProperty:  MPMediaItemPropertyTitle];

    NSLog (@"Shuffle Mode is %d", musicPlayer.shuffleMode);
    
    if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffleblue.png"] forState: UIControlStateNormal];
    } else {
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffle.png"] forState: UIControlStateNormal];

    }
    NSLog (@"Repeat Mode is %d", musicPlayer.repeatMode);

    if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat1blue.png"] forState: UIControlStateNormal];
        
    } else if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeatblue.png"] forState: UIControlStateNormal];
        
    } else {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat.png"] forState: UIControlStateNormal];

    }

    [self.volumeView setMinimumVolumeSliderImage:[UIImage imageNamed:@"slider-fill.png"] forState:UIControlStateNormal];
    [self.volumeView setMaximumVolumeSliderImage:[UIImage imageNamed:@"slider-trackGray.png"] forState:UIControlStateNormal];
    [self.volumeView setVolumeThumbImage:[UIImage imageNamed:@"shinyVolumeHandle.png"] forState:UIControlStateNormal];

    if (!UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [self.view removeConstraint:self.leadingSpaceToSliderConstraint];
        [self.view removeConstraint:self.trailingSpaceFromSliderConstraint];
        [self.view removeConstraint:self.verticalSpaceBetweenSliderAndElapsedTime];
        [self.view removeConstraint:self.verticalSpaceBetweenSliderAndRemainingTime];
        [self.view removeConstraint:self.verticalSpaceBetweenRewindAndReplay];
        [self.view removeConstraint:self.topSpaceToPlayButton];
        self.playButtonToBottomSpace.constant = 70;

    } else {

        [self.view removeConstraint:self.topSpaceToPlayButton];
        [self.view addConstraint: self.playButtonToBottomSpace];
        self.playButtonToBottomSpace.constant = 190;


    }
    
    [self willAnimateRotationToInterfaceOrientation: self.interfaceOrientation duration: 1];
    [self registerForMediaPlayerNotifications];
    [self setPlayedMusicOnce: YES];
    
}
- (void)checkForICloudItemsWithCompletion:(void (^)(BOOL result))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *mySongQuery = [MPMediaQuery songsQuery];
        MPMediaPropertyPredicate *filterPredicate = [MPMediaPropertyPredicate predicateWithValue:  [NSNumber numberWithInt: 1]
                                                                                     forProperty:  MPMediaItemPropertyIsCloudItem];
        [mySongQuery addFilterPredicate: filterPredicate];
        NSArray *filteredArray = [mySongQuery items];
        if ([filteredArray count] > 0) {
            self.collectionContainsICloudItem = YES;
        }
        
        // Check that there was not a nil handler passed.
        if( completionHandler ){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {                
                NSLog (@"Done Checking For ICloud Items in MainViewController");
                NSLog (@"unfiltered CollectionContainsICloudItem = %d", self.collectionContainsICloudItem);
            });
        }
    });
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
//    LogMethod();
    
    [nowPlayingLabel  refreshLabels];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.view removeConstraint:self.leadingSpaceToSliderConstraint];
        [self.view removeConstraint:self.trailingSpaceFromSliderConstraint];
        [self.view removeConstraint:self.verticalSpaceBetweenSliderAndElapsedTime];
        [self.view removeConstraint:self.verticalSpaceBetweenSliderAndRemainingTime];
        [self.view removeConstraint:self.verticalSpaceBetweenRewindAndReplay];
        [self.view removeConstraint:self.topSpaceToPlayButton];
        self.playButtonToBottomSpace.constant = 70;


        self.repeatButton.hidden = YES;
        self.shuffleButton.hidden = YES;
        self.volumeView.hidden = YES;
        
        // could add a button to call the following method to show a floating volume control alert 
//        MPVolumeSettingsAlertShow();
        
//        if (self.showTitle) {
////            self.title = @"Now Playing";
////            self.navigationItem.titleView = [self customizeTitleView];
//        } else self.Title = @"";

        
    } else {
        
        [self.view addConstraint:self.leadingSpaceToSliderConstraint];
        [self.view addConstraint:self.trailingSpaceFromSliderConstraint];
        [self.view addConstraint:self.verticalSpaceBetweenSliderAndElapsedTime];
        [self.view addConstraint:self.verticalSpaceBetweenSliderAndRemainingTime];
        [self.view addConstraint:self.verticalSpaceBetweenRewindAndReplay];

        [self.view removeConstraint:self.topSpaceToPlayButton];
        [self.view addConstraint:self.playButtonToBottomSpace];

        self.playButtonToBottomSpace.constant = 190;


        self.repeatButton.hidden = NO;
        self.shuffleButton.hidden = NO;
        self.volumeView.hidden = NO;

//        self.title = @"";
//        self.navigationItem.titleView = [self customizeTitleView];
    }
    
}
- (UILabel *) customizeTitleView
{
//    LogMethod();

    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:44];
    label.textColor = [UIColor yellowColor];
    label.lineBreakMode = NSLineBreakByClipping;
    label.text = self.title;
    
    return label;
}
- (void)viewWillAppear:(BOOL)animated {
//    LogMethod();
    [super viewWillAppear: animated];

    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(updateTime)
                                                        userInfo:nil
                                                         repeats:YES];
    //omg this needs to be here or it does nothing!!
//    [self scrollNextSongLabel];
    [self.nextSongScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//    if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
//        [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
//    } else if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
//        [playPauseButton setImage: [UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
//    }

    
}

-(void) viewDidAppear:(BOOL)animated {
//    LogMethod();

    if (playNew) {
        [self setPlayNew: NO];
        
//    } else if ([musicPlayer nowPlayingItem]) {
//        [self prepareNowPlayingLabel];
//        [self.initialNowPlayingLabel removeFromSuperview];

    }
    [self prepareNowPlayingLabel];
    [self.initialNowPlayingLabel removeFromSuperview];

    [super viewDidAppear:(BOOL)animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}

#pragma mark Music notification handlers__________________

// When the now-playing item changes, update the now-playing label and the next label.
- (void) handle_NowPlayingItemChanged: (id) notification {
//    LogMethod();

// need to check if this method has already been executed because sometimes the notification gets sent twice for the same nowPlaying item, this workaround seems to solve the problem (check if the nowPlayingItem is the same as previous one)
    if (self.savedNowPlaying != [musicPlayer nowPlayingItem]) {
//        NSLog (@"actually handling it");
            //the next two methods are separated so that they can be executed separately in viewDidLoad and viewWillAppear the first time the view is loaded, afer that they can be executed together here
        //check if the predictedNextSong is actually the song that will play

        if (initialView == YES) {
            //the first time through, just assume it is the right queue
            queueIsKnown = YES;
            initialView = NO;
        } else {
            if (skippedBack) {
                queueIsKnown = YES;
            } else {
                NSLog (@"predictedNextItem is %@ and nowPlayingItem is %@", [predictedNextItem valueForProperty:  MPMediaItemPropertyTitle], [[musicPlayer nowPlayingItem] valueForProperty:  MPMediaItemPropertyTitle]);
                if (predictedNextItem == [musicPlayer nowPlayingItem]) {


                    queueIsKnown = YES;
                } else {
                    queueIsKnown = NO;
                }
            }
        }
        if (musicPlayer.shuffleMode == MPMusicShuffleModeOff) {

            if (!skippedBack) {
                //now set the nextPlayingItem to new item
                NSUInteger nextPlayingIndex = [musicPlayer indexOfNowPlayingItem] + 1;
                
                if (nextPlayingIndex < self.userMediaItemCollection.count) {
                    predictedNextItem = [[self.userMediaItemCollection items] objectAtIndex: [musicPlayer indexOfNowPlayingItem] + 1 ];
                } else {
                    predictedNextItem = nil;
                }
                NSLog (@"predictedNextItem is %@", [predictedNextItem valueForProperty:  MPMediaItemPropertyTitle]);
            }
        } else {
            //if shuffle mode is on, can't predict next item
            predictedNextItem = nil;
        }
        
        //    the BOOL MPMediaItemPropertyIsCloudItem seems to be 0, but doesn't work as a BOOL
        //    NSString *isCloudItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyIsCloudItem];
        //    if (isCloudItem.intValue == 1) {
//        if (self.collectionContainsICloudItem) {
//                BOOL networkAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"networkAvailable"];
//                if (!networkAvailable) {
//                    queueIsKnown = NO;
//                    
//                    //            [self goBackClick];
//                }
//        }
        
        [self prepareAllExceptNowPlaying];
        if (!playNew) {
            //don't do this here if playNew, it will happen in viewWillAppear
            [self prepareNowPlayingLabel];
        }
//        [self.initialNowPlayingLabel removeFromSuperview];

    }
    
    

    
    self.savedNowPlaying = [musicPlayer nowPlayingItem];

}
- (void) refreshNowPlayingLabel:  (id) notification {
//    LogMethod();
    [nowPlayingLabel  refreshLabels];
//    [self prepareAllExceptNowPlaying];
    
//    NSLog (@"nowPlayingLabel refreshed");
}
- (void) prepareAllExceptNowPlaying {
//    LogMethod();

//    MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
////    NSLog (@" currentItem is %@", [currentItem valueForProperty: MPMediaItemPropertyTitle]);
//    //check the queue stored in Core Data to see if the nowPlaying song is in that queue
//    ItemCollection *itemCollection = [ItemCollection alloc];
//    itemCollection.managedObjectContext = self.managedObjectContext;
//    
////    self.collectionItem = [itemCollection containsItem: [currentItem valueForProperty: MPMediaItemPropertyTitle]];
//    self.collectionItem = [itemCollection containsItem: [currentItem valueForProperty:  MPMediaItemPropertyPersistentID]];
//
//    self.userMediaItemCollection = collectionItem.collection;
    // the predicted next item is the next one in this app's saved queue, it might not actually be the next item, so save it and compare when playingItem changes
//    NSUInteger nextPlayingIndex = [musicPlayer indexOfNowPlayingItem] + 1;
//    
//    if (nextPlayingIndex < self.userMediaItemCollection.count) {
//        predictedNextItem = [[self.userMediaItemCollection items] objectAtIndex: [musicPlayer indexOfNowPlayingItem] + 1 ];
//    } else {
//        predictedNextItem = nil;
//    }
    // set up data to pass to info page if chosen
    
    self.mediaItemForInfo = [musicPlayer nowPlayingItem];
    
    self.nextSongLabel.text = [NSString stringWithFormat: @""];
    self.nextLabel.text = [NSString stringWithFormat:@""];
//    NSLog (@"shuffle mode??? %d", musicPlayer.shuffleMode);
    // only show next song if shuffle off and NOT repeat one song mode
    if (musicPlayer.shuffleMode == MPMusicShuffleModeOff && musicPlayer.repeatMode != MPMusicRepeatModeOne) {
        [self prepareNextSongLabel];
    } else {
        self.nextSongScrollView.hidden = YES;
        self.nextSongLabel.hidden = YES;
        self.nextLabel.hidden = YES;
    }
    [self updateTime];
    [self dataForNowPlayingInfoCenter];
}
- (void) prepareNowPlayingLabel {
//    LogMethod();

    // Display the song name for the now-playing media item
    // scroll marquee style if too long for field
    
    [self.nowPlayingLabel setText: [[musicPlayer nowPlayingItem] valueForProperty:  MPMediaItemPropertyTitle]];
//    NSLog (@"nowPlayingLabel.text is %@", self.nowPlayingLabel.text);
    UIFont *newFont = [UIFont systemFontOfSize:44];
    [self.nowPlayingLabel setFont: newFont];
}
- (void) prepareNextSongLabel {
//    LogMethod();
    if (!queueIsKnown) {
        return;
    }
    NSUInteger nextPlayingIndex = [musicPlayer indexOfNowPlayingItem] + 1;

    MPMediaItem *nextPlayingItem;
    if (skippedBack) {
        nextPlayingItem = predictedNextItem;
    } else {
        if (nextPlayingIndex < self.userMediaItemCollection.count) {
            nextPlayingItem = [[self.userMediaItemCollection items] objectAtIndex: nextPlayingIndex];
            predictedNextItem = nextPlayingItem;
        } else {
            self.nextSongScrollView.hidden = YES;
            self.nextSongLabel.hidden = YES;
            self.nextLabel.hidden = YES;
            nextPlayingItem = nil;
        }
    }
    //set up next-playing media item with duration
    
//    if (nextPlayingIndex >= self.userMediaItemCollection.count) {
////        self.nextSongLabel.text = [NSString stringWithFormat: @""];
////        self.nextLabel.text = [NSString stringWithFormat:@""];
//        self.nextSongScrollView.hidden = YES;
//        self.nextSongLabel.hidden = YES;
//        self.nextLabel.hidden = YES;
//    } else {
    if (nextPlayingItem) {
        self.nextSongScrollView.hidden = NO;
        self.nextSongLabel.hidden = NO;
        self.nextLabel.hidden = NO;
        [self.nextSongLabel setUserInteractionEnabled:YES];
        long nextDuration = [[nextPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
        NSString *formattedNextDuration = [NSString stringWithFormat:@"%2lu:%02lu",nextDuration/60,nextDuration -(nextDuration/60)*60];
        
        self.nextSongLabel.text = [NSString stringWithFormat: @"%@  %@",[nextPlayingItem valueForProperty:  MPMediaItemPropertyTitle], formattedNextDuration];
        
        [self scrollNextSongLabel];

        self.nextLabel.text = [NSString stringWithFormat: @"%@:", NSLocalizedString(@"Next", nil)];
        
    }
    [self setSkippedBack: NO];

}
- (void) scrollNextSongLabel {
//    LogMethod();
    
    //calculate the label size to fit the text with the font size
    CGSize labelSize = [self.nextSongLabel.text sizeWithFont:self.nextSongLabel.font
                                           constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(self.nextSongScrollView.bounds))
                                               lineBreakMode:NSLineBreakByClipping];
    
    //Make sure that label is aligned with scrollView
    [self.nextSongScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    //disable scroll if the content fits within the scrollView
    if (labelSize.width > self.nextSongScrollView.frame.size.width) {
        self.nextSongScrollView.scrollEnabled = YES;
    }
    else {
        self.nextSongScrollView.scrollEnabled = NO;
        
    }
}
- (void) dataForNowPlayingInfoCenter {
    //  Set nowPlayingInfo
    //        MPMediaItemPropertyAlbumTitle
    //        MPMediaItemPropertyAlbumTrackCount
    //        MPMediaItemPropertyAlbumTrackNumber
    //        MPMediaItemPropertyArtist
    //        MPMediaItemPropertyArtwork
    //        MPMediaItemPropertyComposer
    //        MPMediaItemPropertyDiscCount
    //        MPMediaItemPropertyDiscNumber
    //        MPMediaItemPropertyGenre
    //        MPMediaItemPropertyPersistentID
    //        MPMediaItemPropertyPlaybackDuration
    //        MPMediaItemPropertyTitle
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        
        NSMutableDictionary *playingInfo = [[NSMutableDictionary alloc] init];
        
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTitle]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTitle] forKey:MPMediaItemPropertyAlbumTitle];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTrackCount]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTrackCount] forKey:MPMediaItemPropertyAlbumTrackCount];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTrackNumber]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTrackNumber] forKey:MPMediaItemPropertyAlbumTrackNumber];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyArtist]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyArtist] forKey:MPMediaItemPropertyArtist];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyArtwork]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyArtwork] forKey:MPMediaItemPropertyArtwork];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyComposer]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyComposer] forKey:MPMediaItemPropertyComposer];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyDiscCount]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyDiscCount] forKey:MPMediaItemPropertyDiscCount];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyDiscNumber]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyDiscNumber] forKey:MPMediaItemPropertyDiscNumber];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyGenre]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyGenre] forKey:MPMediaItemPropertyGenre];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyPersistentID]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyPersistentID] forKey:MPMediaItemPropertyPersistentID];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyPlaybackDuration]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyPlaybackDuration] forKey:MPMediaItemPropertyPlaybackDuration];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle] forKey:MPMediaItemPropertyTitle];
        }
        //        NSString *const MPNowPlayingInfoPropertyElapsedPlaybackTime
        //        NSString *const MPNowPlayingInfoPropertyPlaybackRate;
        //        NSString *const MPNowPlayingInfoPropertyPlaybackQueueIndex;
        //        NSString *const MPNowPlayingInfoPropertyPlaybackQueueCount;
        //        NSString *const MPNowPlayingInfoPropertyChapterNumber;
        //        NSString *const MPNowPlayingInfoPropertyChapterCount;
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyPlaybackRate]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyPlaybackRate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        }
        NSNumber *queueCount = [[NSNumber alloc]  initWithInteger: userMediaItemCollection.count];
        [playingInfo setObject: queueCount forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
        NSNumber *queueIndex  = [[NSNumber alloc]  initWithInteger: [musicPlayer indexOfNowPlayingItem]];
        [playingInfo setObject: queueIndex forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
        
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyChapterNumber]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyChapterNumber] forKey:MPNowPlayingInfoPropertyChapterNumber];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyChapterCount]) {
            [playingInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyChapterCount] forKey:MPNowPlayingInfoPropertyChapterCount];
        }
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:playingInfo];
        
        //        NSMutableDictionary *showSongInfo = [[NSMutableDictionary alloc]
        //                                             initWithDictionary: [[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
        //
        //        NSLog (@"Audio Title %@", [showSongInfo objectForKey: MPMediaItemPropertyTitle]);
        //        NSLog (@"Playback Queue Count %d",[[showSongInfo objectForKey: MPNowPlayingInfoPropertyPlaybackQueueCount] intValue]);
        //        NSLog (@"Playback Queue Index %d",[[showSongInfo objectForKey: MPNowPlayingInfoPropertyPlaybackQueueIndex] intValue]);
    }
    
}

- (void) playMusic {
    LogMethod();
    [musicPlayer play];
    [self prepareAllExceptNowPlaying];
}

- (void) updateTime
{
    //   LogMethod();

    if (stopWatchRunning) {
    
        //calculate elapsed time
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval elapsed = currentTime - stopWatchStartTime;
        
        //extract out the minutes,seonds, and fraction of seconds from elapsed time:
        int mins = (int) (elapsed / 60.0);
        elapsed -= mins * 60;
        int secs = (int) (elapsed);
        elapsed -= secs;
//        int fraction = elapsed * 10.0;
        
        //update text string using a format of 0:00.0
        self.stopWatchTime = [NSString stringWithFormat: @"%2u:%02u", mins, secs];
        
    } else {
        self.stopWatchTime = @"";
    }
    
    long playbackSeconds = musicPlayer.currentPlaybackTime;
    long songDuration = [[self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
    songRemainingSeconds = songDuration - playbackSeconds;

    //if the currently playing song has been deleted during a sync then stop playing and pop to rootViewController
    if (songDuration == 0 && self.iPodLibraryChanged) {
        [musicPlayer stop];
        [self.playbackTimer invalidate];
        [self goBackClick];
//        [self.navigationController popToRootViewControllerAnimated:YES];
        NSLog (@"BOOM");
        return;
    }
    
    NSString *elapsed = [NSString stringWithFormat:@"%02lu:%02lu",playbackSeconds/60,playbackSeconds-(playbackSeconds/60)*60];
    NSString *songRemaining = [NSString stringWithFormat:@"%02lu:%02lu",songRemainingSeconds/60,songRemainingSeconds-(songRemainingSeconds/60)*60];

    //Use NSDateFormatter to get seconds and minutes from the time string:
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"m:ss";
    NSDate *elapsedTime = [formatter dateFromString:elapsed];
    self.elapsedTimeLabel.textColor = [UIColor whiteColor];
    self.elapsedTimeLabel.text = [formatter stringFromDate:elapsedTime];
    
    NSDate *songRemainingTime = [formatter dateFromString:songRemaining];
    self.remainingTimeLabel.text = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:songRemainingTime]];
    self.remainingTimeLabel.textColor = [UIColor whiteColor];
    
    if (!self.userIsScrubbing) {
        [self positionSlider];
    }
    
    self.navigationItem.rightBarButtonItems = nil;

    // only show the collection remaining if the setting is on and shuffle is off and repeat is off
    if (showPlaylistRemaining) {

        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.stopWatchBarButton, nil];

        if (musicPlayer.shuffleMode == MPMusicShuffleModeOff && musicPlayer.repeatMode == MPMusicRepeatModeNone) {
//        NSString * collectionRemaining = [self calculateCollectionRemaining];
            [self calculateCollectionRemaining];
        }
    }
    
}
- (void)positionSlider {

    self.progressSlider.minimumValue = 0;
    
    NSNumber *duration = [self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    float totalTime = [duration floatValue];
    self.progressSlider.maximumValue = totalTime;
    //note to self: setting of value must be after setting of minimum and maximum to show correctly on viewdidload
    if (!self.userIsScrubbing) {
        if (self.hasFinishedMoving) {
            self.progressSlider.value = savedHandleValue;
            self.hasFinishedMoving = NO;     //set up for next scrubbing session
        } else {
        self.progressSlider.value = musicPlayer.currentPlaybackTime;
        }
    }

//    NSLog (@" currentPlaybackTime is %f", musicPlayer.currentPlaybackTime);
}

- (void) calculateCollectionRemaining {
    
    long playbackSeconds = musicPlayer.currentPlaybackTime;
    long collectionDuration = [self.collectionItem.duration longValue];
    long collectionElapsed;
//    long collectionRemainingSeconds;
    
    if (collectionDuration > 0) {
        collectionElapsed = [[self calculatePlaylistElapsed] longValue] + playbackSeconds;
        collectionRemainingSeconds = collectionDuration - collectionElapsed;
    } else {
        collectionRemainingSeconds = 0;
    }
    
//    // don't show collectionRemaining if it is the same as songRemaining
//    if (collectionRemainingSeconds <= songRemainingSeconds) {
//        self.navigationItem.rightBarButtonItems=nil;
//        return;
//    }
    
    NSString *collectionRemaining;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    if (collectionRemainingSeconds >= 3600) {
        collectionRemaining = [NSString stringWithFormat:@"%lu:%02lu:%02lu",
                               collectionRemainingSeconds / 3600,
                               (collectionRemainingSeconds % 3600)/60,
                               collectionRemainingSeconds % 60];
        formatter.dateFormat = @"H:mm:ss";
//        if (self.showPlaylistRemaining) {
//            self.showTitle = NO;
//        }
    } else {
//        self.showTitle = YES;
        collectionRemaining = [NSString stringWithFormat:@"%02lu:%02lu",

                               collectionRemainingSeconds /60,
                               collectionRemainingSeconds % 60];
        formatter.dateFormat = @"m:ss";
    }
    NSDate *collectionRemainingTime = [formatter dateFromString:collectionRemaining];
    
    if (collectionRemainingTime) {

        if (collectionRemainingSeconds > 0) {
            
            NSString *collectionRemainingLabel = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:collectionRemainingTime]];
            
            UIBarButtonItem *durationButton = [[UIBarButtonItem alloc] initWithTitle: collectionRemainingLabel
                                                                               style: UIBarButtonItemStyleBordered
                                                                              target: self
                                                                              action: @selector(magnify)];
            [durationButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:44], UITextAttributeFont,nil] forState:UIControlStateNormal];
            [durationButton setBackgroundImage:[UIImage imageNamed:@"rightButtonBackground.png"] forState: UIControlStateNormal barMetrics:UIBarMetricsDefault];

            const CGFloat TextOffset = 10.0f;
            [durationButton setTitlePositionAdjustment: UIOffsetMake(TextOffset, 5.0f) forBarMetrics: UIBarMetricsDefault];
            [durationButton setTitlePositionAdjustment: UIOffsetMake(TextOffset, 9.0f) forBarMetrics: UIBarMetricsLandscapePhone];


//        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        [negativeSpacer setWidth:-15];
//            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:durationButton, self.stopWatchBarButton, negativeSpacer, nil];
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:durationButton, self.stopWatchBarButton, nil];

        } else {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.stopWatchBarButton, nil];

        }

    } 
    return;
}
- (NSNumber *)calculatePlaylistElapsed {
        
    NSArray *returnedQueue = [self.userMediaItemCollection items];
    
    // when nowPlayingItem is done, indexOfNowPlayingItem becomes unpredictable, don't perform this calculation
    NSUInteger count;
    if ([musicPlayer nowPlayingItem]) {
        count = [musicPlayer indexOfNowPlayingItem];
    } else {
        count = 0;
    }
    long playlistElapsed = 0;
    
    for (NSUInteger i = 0; i < count; i++) {
        playlistElapsed = (playlistElapsed + [[[returnedQueue objectAtIndex: i] valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
    }

    return [NSNumber numberWithLong: playlistElapsed];
}

#pragma mark Prepare for Seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();

    UINavigationController *navigationController = segue.destinationViewController;

	if ([segue.identifier isEqualToString:@"MagnifyRemainingTime"])
	{
        TimeMagnifierViewController *timeMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        timeMagnifierViewController.delegate = self;
        timeMagnifierViewController.textToMagnify = self.remainingTimeLabel.text;
        timeMagnifierViewController.timeType = segue.identifier;
	}
    
    if ([segue.identifier isEqualToString:@"MagnifyElapsedTime"])
	{
        TimeMagnifierViewController *timeMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        timeMagnifierViewController.delegate = self;
        timeMagnifierViewController.textToMagnify = self.elapsedTimeLabel.text;
        timeMagnifierViewController.timeType = segue.identifier;

	}
    
    if ([segue.identifier isEqualToString:@"MagnifyNowPlaying"])
	{
        TextMagnifierViewController *textMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        textMagnifierViewController.delegate = self;
        textMagnifierViewController.textToMagnify = self.nowPlayingLabel.text;
        textMagnifierViewController.textType = segue.identifier;
        textMagnifierViewController.mainViewController = self;

	}
    
    if ([segue.identifier isEqualToString:@"MagnifyPlaylistRemaining"])
	{
        TimeMagnifierViewController *timeMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        timeMagnifierViewController.delegate = self;
        UIBarButtonItem *playlistRemainingButton = [self.navigationItem.rightBarButtonItems objectAtIndex: 0];
        timeMagnifierViewController.textToMagnify = playlistRemainingButton.title;
        timeMagnifierViewController.timeType = segue.identifier;

	}
    
    if ([segue.identifier isEqualToString:@"StartStopWatch"])
	{
        TimeMagnifierViewController *timeMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        timeMagnifierViewController.delegate = self;
        int mins = 0;
        int secs = 0;
        self.stopWatchTime = [NSString stringWithFormat: @"%2u:%02u", mins, secs];
        timeMagnifierViewController.textToMagnify = self.stopWatchTime;
//        timeMagnifierViewController.textToMagnify = @"0:00";
        timeMagnifierViewController.timeType = segue.identifier;
        
	}
    
    if ([segue.identifier isEqualToString:@"MagnifyNextSong"])
	{
        TextMagnifierViewController *textMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        textMagnifierViewController.delegate = self;
        textMagnifierViewController.textToMagnify = self.nextSongLabel.text;
        textMagnifierViewController.textType = segue.identifier;
        textMagnifierViewController.mainViewController = self;

	}
    if ([segue.identifier isEqualToString:@"ViewInfo"])
	{
        InfoTabBarController *infoTabBarController = segue.destinationViewController;
        infoTabBarController.managedObjectContext = self.managedObjectContext;
        infoTabBarController.infoDelegate = self;
        infoTabBarController.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
        infoTabBarController.mediaItemForInfo = self.mediaItemForInfo;
        //remove observer for playbackstatechanged because if editing, don't want to pop view
        //  observer will be added back in infoTabBarControllerDidCancel
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                      object: musicPlayer];
        
	}
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}
#pragma mark Music control________________________________

- (IBAction)handleScrub:(id)sender {
    //    LogMethod();
//    //if scrub has gone to the end don't update the currentPlaybackTime to the full duration until the touch has ended so the nowPlayingSongChanged is not triggered
//    if ([self.progressSlider value] >= [[self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue]) {
//        [musicPlayer setCurrentPlaybackTime: ([self.progressSlider value] - 0.5)];
//    } else {
        [musicPlayer setCurrentPlaybackTime: [self.progressSlider value]];
//    }
    [self updateTime];
}

- (IBAction)handleScrubberTouchDown:(id)sender {
    self.userIsScrubbing = YES;
    self.hasFinishedMoving = NO;
    [self setScrubbingUI: YES];
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    savedPlaybackState = playbackState;
    if (playbackState == MPMusicPlaybackStatePlaying) {
		[musicPlayer pause];
	}
}

- (IBAction)handleScrubberTouchUp:(id)sender {
    self.userIsScrubbing = NO;
    self.hasFinishedMoving = YES;
    savedHandleValue = self.progressSlider.value;
    [self setScrubbingUI: NO];
    if (savedPlaybackState == MPMusicPlaybackStatePlaying) {
        [musicPlayer play];
    }
}

/*
 * Updates the UI according to the current scrubbing state given.
 */
-(void)setScrubbingUI:(BOOL)scrubbingState {
    float alpha = ( scrubbingState ? .5 : 0 );
    [UIView animateWithDuration:0.25 animations:^{
        self.repeatButton.alpha = 1-alpha;
        self.shuffleButton.alpha = 1-alpha;
        self.playPauseButton.alpha = 1-alpha;
        self.rewindButton.alpha = 1-alpha;
        self.forwardButton.alpha = 1-alpha;
        self.volumeView.alpha = 1 - alpha;
        self.nextSongLabel.alpha = 1 - alpha;
        self.nextLabel.alpha = 1 - alpha;
    }];
}
- (IBAction)skipBack:(id)sender {
    if ([musicPlayer currentPlaybackTime] > 5.0) {
        [musicPlayer skipToBeginning];
    } else {
        predictedNextItem = [musicPlayer nowPlayingItem];
        [self setSkippedBack: YES];
        [musicPlayer skipToPreviousItem];
    }
}

- (IBAction)skipForward:(id)sender {
    [musicPlayer skipToNextItem];
    
}

- (IBAction)playPause:(id)sender {
//   LogMethod();
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
//	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
    if (playbackState != MPMusicPlaybackStatePlaying) {
        [self playMusic];
        
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[musicPlayer pause];
	}
}

//    Tap to magnify
- (IBAction)nowPlayingTapDetected:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier: @"MagnifyNowPlaying" sender: self];
    
}
//    Tap to magnify
- (IBAction)nextSongTapDetected:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier: @"MagnifyNextSong" sender: self];
    
}

- (IBAction)magnifyRemainingTime:(id)sender {
    [self performSegueWithIdentifier: @"MagnifyRemainingTime" sender: self];
}

- (IBAction)magnifyElapsedTime:(id)sender {
    [self performSegueWithIdentifier: @"MagnifyElapsedTime" sender: self];
    
}

- (IBAction)repeatModeChanged:(id)sender {
    //need to handle MPMusicRepeatModeOne
    //    NSLog (@"repeatMode is %d", [musicPlayer repeatMode]);
    if (musicPlayer.repeatMode == MPMusicRepeatModeNone) {
        [musicPlayer setRepeatMode: MPMusicRepeatModeAll];
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeatblue.png"] forState: UIControlStateNormal];
//        UIImage *coloredImage = [[UIImage imageNamed: @"bigrepeatblue.png"] imageWithTint:[UIColor blueColor]];
//        [self.repeatButton setImage: coloredImage forState:UIControlStateNormal];

    } else if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
        [musicPlayer setRepeatMode: MPMusicRepeatModeOne];
//        UIImage *coloredImage = [[UIImage imageNamed: @"bigrepeat1blue.png"] imageWithTint:[UIColor blueColor]];
//        [self.repeatButton setImage: coloredImage forState:UIControlStateNormal];
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat1blue.png"] forState: UIControlStateNormal];
        self.nextSongScrollView.hidden = YES;
        self.nextSongLabel.hidden = YES;
        self.nextLabel.hidden = YES;
    
    } else if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
        [musicPlayer setRepeatMode: MPMusicRepeatModeNone];
//        UIImage *coloredImage = [[UIImage imageNamed: @"bigrepeat.png"] imageWithTint:[UIColor whiteColor]];
//        [self.repeatButton setImage: coloredImage forState:UIControlStateNormal];
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat.png"] forState: UIControlStateNormal];
        //show nextSongLabel when repeat one is turned off as long as shuffle is off
        if (musicPlayer.shuffleMode == MPMusicShuffleModeOff) {
            queueIsKnown = YES;
            [self prepareNextSongLabel];
    
        }
    }
}

- (IBAction)shuffleModeChanged:(id)sender {
    //need to handle MPMusicShuffleModeAlbums
    if (musicPlayer.shuffleMode == MPMusicShuffleModeOff) {
        [musicPlayer setShuffleMode: MPMusicShuffleModeSongs];
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffleblue.png"] forState: UIControlStateNormal];
//        self.nextSongLabel.text = [NSString stringWithFormat: @""];
//        self.nextLabel.text = [NSString stringWithFormat:@""];
        self.nextSongScrollView.hidden = YES;
        self.nextSongLabel.hidden = YES;
        self.nextLabel.hidden = YES;
    } else if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffle.png"] forState: UIControlStateNormal];

        //show nextSongLabel when shuffle is off as long as not repeat one song mode
        if (musicPlayer.repeatMode != MPMusicRepeatModeOne) {
            queueIsKnown = YES;
            [self prepareNextSongLabel];
        }
    }
}
- (IBAction) togglePlaylistRemainingAndTitle:(id)sender {
    if (showPlaylistRemaining) {
        self.showPlaylistRemaining = NO;
        //title will only be displayed if playlist remaining is turned off
        self.title = NSLocalizedString(@"Now Playing", nil);
        [UIView animateWithDuration:2.5 animations:^{
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.titleView = [self customizeTitleView];
        }];
        //        NSLog (@"show Playlist Remaining");
    } else {
        self.showPlaylistRemaining = YES;
//        [UIView animateWithDuration:0.15 animations:^{
            self.title = nil;
            self.navigationItem.titleView = nil;
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.stopWatchBarButton, nil];

            [self updateTime];
//        }];
        //        NSLog (@"don't show Playlist Remaining");
    }
    //showPlaylistRemaining must persist so save to NSUserDefaults
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:self.showPlaylistRemaining forKey:@"showPlaylistRemaining"];
}
- (IBAction)magnify {
    
    [self performSegueWithIdentifier: @"MagnifyPlaylistRemaining" sender: self];
}
- (IBAction) startStopWatch {
    
    stopWatchStartTime = [NSDate timeIntervalSinceReferenceDate];
    stopWatchRunning = YES;
    [self performSegueWithIdentifier: @"StartStopWatch" sender: self];
}
- (void)goBackClick
{
//    LogMethod();

    //don't start networkActivityIndicator if stopwatch is running
    if (!stopWatchRunning) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    //remove the swipe gesture from the nav bar  (doesn't work to wait until dealloc)
    [self.navigationController.navigationBar removeGestureRecognizer:self.swipeLeftRight];

    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Application state changes____________________________

#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: iPod library access works only when running on a device.
#endif


- (void) registerForMediaPlayerNotifications {
    //      LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
//    [notificationCenter addObserver: self
//                           selector: @selector (iCloudAccountAvailabilityChanged:)
//                               name: NSUbiquityIdentityDidChangeNotification
//                             object: nil];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    
    [notificationCenter addObserver:self
                           selector:@selector(refreshNowPlayingLabel:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_iPodLibraryChanged:)
                               name: MPMediaLibraryDidChangeNotification
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_ApplicationDidBecomeActive:)
                               name: UIApplicationDidBecomeActiveNotification
                             object: nil];
    
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    
	[musicPlayer beginGeneratingPlaybackNotifications];
}

//- (void) iCloudAccountAvailabilityChanged:(NSNotification *) notification
//{
//    
//// need to know whether iCloud is available when a new song will play
//    
//    [self initializeiCloudAccessWithCompletion:^(BOOL available) {
//        
//        _iCloudAvailable = available;
//        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
//        [standardUserDefaults setBool: _iCloudAvailable forKey:@"iCloudAvailable"];
//        BOOL iCloudAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudAvailable"];
//        NSLog (@"iCloudAvailable BOOL from NSUserDefaults is %d", iCloudAvailable);
//        
//    }];
//
//    
//}
//
//- (void)initializeiCloudAccessWithCompletion:(void (^)(BOOL available)) completion {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        _iCloudRoot = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
//        if (_iCloudRoot != nil) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"iCloud available at: %@", _iCloudRoot);
//                completion(TRUE);
//            });
//        }
//        else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"iCloud not available");
//                completion(FALSE);
//            });
//        }
//    });
//}
// If the music player was paused, leave it paused. If it was playing, it will continue to
//		play on its own. The music player state is "stopped" only if the previous list of songs
//		had finished or if this is the first time the user has chosen songs after app
//		launch--in which case, invoke play.
- (void) restorePlaybackState {
    LogMethod();
	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped && userMediaItemCollection) {
		
		if (playedMusicOnce == NO) {
            
			[self setPlayedMusicOnce: YES];
			[self playMusic];
		}
	}
    
}


// When the playback state changes, set the play/pause button appropriately.
- (void) handle_PlaybackStateChanged: (id) notification {
//    LogMethod();
    //    //temporary nslogs for debugging
    //
    //    NSLog (@"size of nextSongLabel is %f, %f", self.nextSongLabel.frame.size.width, self.nextSongLabel.frame.size.height);
    //    NSLog (@"size of nextSongScrollView is %f, %f", self.nextSongScrollView.frame.size.width, self.nextSongScrollView.frame.size.height);
    
    //play is paused during scrubbing to prevent skipping to new song, so do not change the UI
    if (!userIsScrubbing) {
    
        MPMusicPlaybackState playbackState = [musicPlayer playbackState];
        
//        NSLog (@" playbackState = %d", playbackState);
        
        if (playbackState != MPMusicPlaybackStatePlaying) {
            
            [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
            savedPlaybackState = playbackState;

        } else if (playbackState == MPMusicPlaybackStatePlaying) {
            
            [playPauseButton setImage: [UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
            savedPlaybackState = playbackState;


        }
        if (playbackState == MPMusicPlaybackStateStopped) {
                    
//            [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
//            savedPlaybackState = playbackState;

            
            if (!playNew) {
                // Even though stopped, invoking 'stop' ensures that the music player will play
                //		its queue from the start. - !except if first time thru and state is stopped
                [musicPlayer stop];
                
                BOOL userIsEditing = [[NSUserDefaults standardUserDefaults] boolForKey:@"userIsEditing"];
                //if the user is editing, we don't want to pop, so call goBackClick in InfoTabBarDidCancel
                if (!userIsEditing) {
                    [self goBackClick];
                }
//                if (iPodLibraryChanged) {
//                    [self.navigationController popToRootViewControllerAnimated:YES];
//                } else {
//                    [self.navigationController popViewControllerAnimated:YES];
//                }
            }
        }
    }
}

- (void) handle_iPodLibraryChanged: (id) changeNotification {
    //   LogMethod();
	// Implement this method to update cached collections of media items when the
	// user performs a sync while application is running.
    [self setIPodLibraryChanged: YES];
    
}

- (void) handle_ApplicationDidBecomeActive: (id) notification
{
    if (musicPlayer.playbackState == MPMusicPlaybackStateInterrupted) {
        NSLog (@"savedPlaybackState is %d", savedPlaybackState);
        if (savedPlaybackState == MPMusicPlaybackStatePlaying) {
            [playPauseButton setImage:[UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
            [musicPlayer play];
//            NSLog (@"****************Playing");
        } else {
            [playPauseButton setImage:[UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
            saveVolume = [musicPlayer volume];
            [musicPlayer setVolume: 0.0];
            [self performSelector:@selector(delayedPlay) withObject:nil afterDelay:0.0];            
//            NSLog (@"**************NOT Playing");
        }
    }
    NSLog (@"Shuffle Mode is %d", musicPlayer.shuffleMode);
    
    if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffleblue.png"] forState: UIControlStateNormal];
    } else {
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffle.png"] forState: UIControlStateNormal];
        
    }
    NSLog (@"Repeat Mode is %d", musicPlayer.repeatMode);
    
    if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat1blue.png"] forState: UIControlStateNormal];
        
    } else if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeatblue.png"] forState: UIControlStateNormal];
        
    } else {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat.png"] forState: UIControlStateNormal];
        
    }
}
- (void) delayedPlay {
    [musicPlayer play];
    [musicPlayer pause];
    [musicPlayer setVolume: saveVolume];

}
#pragma mark Application playback control_________________

// //delegate method for the audio route change alert view; follows the protocol specified in the UIAlertViewDelegate protocol.
//- (void) alertView: routeChangeAlertView clickedButtonAtIndex: buttonIndex {
//    LogMethod();
//	if ((NSInteger) buttonIndex == 1) {
//		[appSoundPlayer play];
//	} else {
//		[appSoundPlayer setCurrentTime: 0];
//	}
//
//}



//#pragma mark AV Foundation delegate methods____________
//
//- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) appSoundPlayer successfully: (BOOL) flag {
//    LogMethod();
//	playing = NO;
//}
//
//- (void) audioPlayerBeginInterruption: player {
//    LogMethod();
//	NSLog (@"Interrupted. The system has paused audio playback.");
//	
//	if (playing) {
//        
//		playing = NO;
//		interruptedOnPlayback = YES;
//	}
//}
//
//- (void) audioPlayerEndInterruption: player {
//    LogMethod();
//	NSLog (@"Interruption ended. Resuming audio playback.");
//	
//	// Reactivates the audio session, whether or not audio was playing
//	//		when the interruption arrived.
//	[[AVAudioSession sharedInstance] setActive: YES error: nil];
//	
//	if (interruptedOnPlayback) {
//        
//		[appSoundPlayer prepareToPlay];
//		[appSoundPlayer play];
//		playing = YES;
//		interruptedOnPlayback = NO;
//	}
//}


#pragma mark - TextMagnifierViewControllerDelegate

- (void)textMagnifierViewControllerDidCancel:(TextMagnifierViewController *)controller
{
//    LogMethod();

	[controller dismissViewControllerAnimated:YES completion:nil];
    [self willAnimateRotationToInterfaceOrientation: self.interfaceOrientation duration: 1];
}
//#pragma mark - TextMagnifierViewControllerDelegate

- (void)timeMagnifierViewControllerDidCancel:(TimeMagnifierViewController *)controller
{
    stopWatchRunning = NO;
//	[self dismissViewControllerAnimated:YES completion:nil];
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self willAnimateRotationToInterfaceOrientation: self.interfaceOrientation duration: 1];
}
//#pragma mark - InfoTabBarControllerDelegate

- (void)infoTabBarControllerDidCancel:(InfoTabBarController *)controller
{
    [self willAnimateRotationToInterfaceOrientation: self.interfaceOrientation duration: 1];
    //need to add back observer for playbackStatechanged because it was removed before going to info in case user edits 
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];

    MPMusicPlaybackState playbackState = [musicPlayer playbackState];

    if (playbackState == MPMusicPlaybackStateStopped) {
        [self goBackClick];
    }

}
- (void)viewWillDisappear:(BOOL)animated {
    LogMethod();
    [super viewWillDisappear: animated];
    [self.playbackTimer invalidate];
    
}
- (void)dealloc {
//       LogMethod();
    
//    [[NSNotificationCenter defaultCenter] removeObserver: self
//                                                    name: NSUbiquityIdentityDidChangeNotification
//                                                  object: nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: musicPlayer];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMediaLibraryDidChangeNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIApplicationDidBecomeActiveNotification
												  object: nil];
    
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    
	[musicPlayer endGeneratingPlaybackNotifications];

    
}
- (void) didReceiveMemoryWarning {
//    LogMethod();
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [self setNowPlayingLabel:nil];
    [self setElapsedTimeLabel:nil];
    [self setProgressSlider:nil];
    [self setRemainingTimeLabel:nil];
    [self setNextSongLabel:nil];
    [self setNextLabel:nil];
    [self setVolumeView:nil];
    [self setPlayPauseButton:nil];
    [self setRepeatButton:nil];
    [self setShuffleButton:nil];
    [self setNextSongScrollView:nil];
    [self setNextSongLabel:nil];
    [self setNextSongLabelWidthConstraint:nil];



	
	// Release any cached data, images, etc that aren't in use.
}
@end
