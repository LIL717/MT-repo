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
#import "AccessibleButton.h"
#import "MarqueeLabel.h"

@interface MainViewController ()


@end

#pragma mark Audio session callbacks_______________________

@implementation MainViewController

@synthesize userMediaItemCollection;	// the media item collection created by the user, using the media item picker
@synthesize musicPlayer;				// the music player, which plays media items from the iPod library

@synthesize navigationBar;				// the application's Navigation bar
//@synthesize nowPlayingLabel;			// descriptive text shown on the main screen about the now-playing media item
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
//140218 1.2 iOS 7 begin
@synthesize collectionRemainingLabel;
//140218 1.2 iOS 7 end
@synthesize rewindButton;
@synthesize playPauseButton;
@synthesize forwardButton;
@synthesize repeatButton;
@synthesize shuffleButton;



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
//131011 1.1 fix musicPlayer bug begin
BOOL isPlaying;
BOOL isPausedOrStopped;
BOOL delayPlaybackStateChange;
//131011 1.1 fix musicPlayer bug end




#pragma mark - Initial Display methods

// Configure the application.

- (void) viewDidLoad {
    //    LogMethod();
    [super viewDidLoad];

    [TestFlight passCheckpoint:@"MainViewController- viewDidLoad"];

    UIImage *backgroundImage = [UIImage imageNamed: @"blueInfoImage.png"];
    [self.nowPlayingInfoButton setImage: backgroundImage forState:UIControlStateHighlighted];
    self.nextLabel.textColor = [UIColor yellowColor];
    
//131204 1.2 iOS 7 begin

    self.navigationController.navigationBar.topItem.title = @"";

    UIButton *tempStopWatchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempStopWatchButton addTarget:self action:@selector(startStopWatch) forControlEvents:UIControlEventTouchUpInside];
    [tempStopWatchButton setImage:[UIImage imageNamed:@"stopWatchImage.png"] forState:UIControlStateNormal];
    [tempStopWatchButton setShowsTouchWhenHighlighted:NO];
    [tempStopWatchButton sizeToFit];
    
    self.stopWatchBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempStopWatchButton];
//140127 1.2 iOS 7 end

    [self.stopWatchBarButton setIsAccessibilityElement:YES];
    [self.stopWatchBarButton setAccessibilityLabel: NSLocalizedString(@"Stopwatch", nil)];
    [self.stopWatchBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    
    //need this to use MPNowPlayingInfoCenter
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [self setPlayedMusicOnce: NO];
    
    [self setMusicPlayer: [MPMusicPlayerController systemMusicPlayer]];
    
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

	self.nowPlayingMarqueeLabel.marqueeType = MLContinuous;
	self.nowPlayingMarqueeLabel.continuousMarqueeExtraBuffer = 30.0;
	[self.nowPlayingMarqueeLabel setFont: [UIFont systemFontOfSize:44]];
	[self prepareNowPlayingLabel];

    if (playNew) {
        [musicPlayer setQueueWithItemCollection: self.userMediaItemCollection];
        [musicPlayer setNowPlayingItem: self.itemToPlay];
        [self playMusic];
        if (self.songShuffleButtonPressed) {
            [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
            [musicPlayer setShuffleMode: MPMusicShuffleModeSongs];
            self.songShuffleButtonPressed = NO;
            //            [self.shuffleButton setAccessibilityTraits: UIAccessibilityTraitButton];
            
        }
        musicPlayer.repeatMode = MPMusicRepeatModeNone;
        //        [self setPlayNew: NO];  this gets set in viewDidAppear instead
        
    } else if ([musicPlayer nowPlayingItem]) {
        
        MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
        //    NSLog (@" currentItem is %@", [currentItem valueForProperty: MPMediaItemPropertyTitle]);
        //check the queue stored in Core Data to see if the nowPlaying song is in that queue

        self.collectionItem = [self containsItem: [currentItem valueForProperty:  MPMediaItemPropertyPersistentID]];
        
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
        [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Play", nil)];
        
    } else if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [playPauseButton setImage: [UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
        [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Pause", nil)];
        
        
    }

//	self.nowPlayingMarqueeLabel.marqueeType = MLContinuous;
//	self.nowPlayingMarqueeLabel.continuousMarqueeExtraBuffer = 30.0;
//	[self.nowPlayingMarqueeLabel setFont: [UIFont systemFontOfSize:44]];
//	[self prepareNowPlayingLabel];

    NSLog (@"Shuffle Mode is %lu", musicPlayer.shuffleMode);
    
    if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffleblue.png"] forState: UIControlStateNormal];
        self.shuffleButton.isSelected = YES;
        
    } else {
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffle.png"] forState: UIControlStateNormal];
        self.shuffleButton.isSelected = NO;
        
        
        
    }
    NSLog (@"Repeat Mode is %lu", musicPlayer.repeatMode);
    
    if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat1blue.png"] forState: UIControlStateNormal];
        [self.repeatButton setAccessibilityLabel: NSLocalizedString(@"Repeat Track", nil)];
        [self.repeatButton setAccessibilityHint: NSLocalizedString(@"Changes repeat settings", nil)];
        
        
    } else if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeatblue.png"] forState: UIControlStateNormal];
        [self.repeatButton setAccessibilityLabel: NSLocalizedString(@"Repeat All", nil)];
        [self.repeatButton setAccessibilityHint: NSLocalizedString(@"Changes repeat settings", nil)];
        
        
        
    } else {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat.png"] forState: UIControlStateNormal];
        [self.repeatButton setAccessibilityLabel: NSLocalizedString(@"Repeat Off", nil)];
        [self.repeatButton setAccessibilityHint: NSLocalizedString(@"Changes repeat settings", nil)];
        
        
        
    }
    
    [self.volumeView setMinimumVolumeSliderImage:[UIImage imageNamed:@"slider-fill.png"] forState:UIControlStateNormal];
    [self.volumeView setMaximumVolumeSliderImage:[UIImage imageNamed:@"slider-trackGray.png"] forState:UIControlStateNormal];
    [self.volumeView setVolumeThumbImage:[UIImage imageNamed:@"shinyVolumeHandle.png"] forState:UIControlStateNormal];


	if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) { //landscape
		[self landscapeAdjustments];
	}
	if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) { //portrait
		[self portraitAdjustments];
	}

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
                NSLog (@"unfiltered CollectionContainsICloudItem = %d", self.collectionContainsICloudItem);
            });
        }
    });
}
- (CollectionItem *) containsItem: (NSNumber *) playingSongPersistentID
{
	BOOL itemFound;

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemCollection"
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];

	NSError *error = nil;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

	if (error) {
		NSLog(@"Error requesting items from Core Data: %@", [error localizedDescription]);
	}
	if (fetchedObjects == nil) {
			// Handle the error
		NSLog (@"fetch error");
	}

	itemFound = NO;
		//if there are no objects, set itemFound to NO
	if ([fetchedObjects count] == 0) {
		NSLog (@"no collection item objects fetched");
	} else {
			// if there is an object, need to see if song is in the list
		MPMediaItemCollection *mediaItemCollection = [[fetchedObjects firstObject] valueForKey: @"collection"];
		NSArray *savedQueue = [mediaItemCollection items];

		for (MPMediaItem *song in savedQueue) {
				//                if ([[song valueForProperty: MPMediaItemPropertyTitle] isEqual: playingSong]) {
			if ([[song valueForProperty: MPMediaItemPropertyPersistentID] isEqual: playingSongPersistentID]) {
				itemFound = YES;
			}
		}
	}
	if (itemFound) {
		return [fetchedObjects firstObject];
	} else {
		return nil;
	}
}
- (void) landscapeAdjustments {
	self.leadingSpaceToSliderConstraint.constant = 120;
	self.trailingSpaceFromSliderConstraint.constant = 135;
	self.verticalSpaceNowPlayingMarqueeToElapsedLabel.constant = 1;
	self.repeatButton.hidden = YES;
	self.shuffleButton.hidden = YES;
	self.volumeView.hidden = YES;
}
- (void) portraitAdjustments {
	self.leadingSpaceToSliderConstraint.constant = 20;
	self.trailingSpaceFromSliderConstraint.constant = 20;
	self.verticalSpaceNowPlayingMarqueeToElapsedLabel.constant = 53;

	self.repeatButton.hidden = NO;
	self.shuffleButton.hidden = NO;
	self.volumeView.hidden = NO;
}
- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    //    LogMethod();
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

	if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) { //landscape
		[self landscapeAdjustments];
    }

	if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) { //portrait
		[self portraitAdjustments];
    }
//131001 make player compatible with iTunes Radio begin

    //if iTunes radio is playing the mainViewController will open, but need to hide info button and unused buttons
    long songDuration = [[self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
    
    if (!songDuration) {
        self.nowPlayingInfoButton.hidden = YES;
        self.progressSlider.hidden = YES;
        self.remainingTimeLabel.hidden = YES;
        self.rewindButton.hidden = YES;
        self.repeatButton.hidden = YES;
        self.shuffleButton.hidden = YES;
        self.nextSongScrollView.hidden = YES;
        self.nextSongLabel.hidden = YES;
        self.nextLabel.hidden = YES;
        
    }
//131001 make player compatible with iTunes Radio end

    
}
- (UILabel *) customizeTitleView
{

    CGRect frame = CGRectMake(0, 0, [self.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:44]}].width, 48);

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
    LogMethod();
    [super viewWillAppear: animated];
//131216 1.2 iOS 7 begin
    self.edgesForExtendedLayout = UIRectEdgeNone;
//131216 1.2 iOS 7 end
    
    self.swipeLeftRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(togglePlaylistRemainingAndTitle:)];
    [self.swipeLeftRight setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
    [self.navigationController.navigationBar addGestureRecognizer:self.swipeLeftRight];
    
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(updateTime)
                                                        userInfo:nil
                                                         repeats:YES];
    //omg this needs to be here or it does nothing!!
    //    [self scrollNextSongLabel];
//	[self.nowPlayingMarqueeLabel scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];//temp for ios 8
    [self.nextSongScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    //    if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
    //        [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
    //    } else if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
    //        [playPauseButton setImage: [UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
    //    }
    
    
}

-(void) viewDidAppear:(BOOL)animated {
    LogMethod();
    
    if (playNew) {
        [self setPlayNew: NO];
        
	} else {
			//need this here or 2nd scroll label is elevated until it fills screen :(
		[self prepareNowPlayingLabel];
	}
    [super viewDidAppear:(BOOL)animated];
    
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
        //                    //            [self.navigationController popViewControllerAnimated:YES];
        //                }
        //        }
        
        [self prepareAllExceptNowPlaying];
		[self prepareNowPlayingLabel];
        
    }
    
    
    
    
    self.savedNowPlaying = [musicPlayer nowPlayingItem];
//131001 make player compatible with iTunes Radio begin
    //if iTunes radio is playing the mainViewController will open, but need to hide info button
    long songDuration = [[self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
    
    if (!songDuration) {
        self.nowPlayingInfoButton.hidden = YES;
        self.progressSlider.hidden = YES;
        self.remainingTimeLabel.hidden = YES;
        self.rewindButton.hidden = YES;
        self.repeatButton.hidden = YES;
        self.shuffleButton.hidden = YES;
        self.nextSongScrollView.hidden = YES;
        self.nextSongLabel.hidden = YES;
        self.nextLabel.hidden = YES;
    }
//131001 make player compatible with iTunes Radio end

    
}

- (void) prepareAllExceptNowPlaying {
    //    LogMethod();
    
    //    MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
    ////    NSLog (@" currentItem is %@", [currentItem valueForProperty: MPMediaItemPropertyTitle]);
    //    //check the queue stored in Core Data to see if the nowPlaying song is in that queue
    //    ItemCollection *itemCollection = [ItemCollection alloc];
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

	//need these two lines otherwise 2nd label is elevated = weird
	self.nowPlayingMarqueeLabel.text = @"";
	[self.nowPlayingMarqueeLabel restartLabel];

    [self.nowPlayingMarqueeLabel setText: [[musicPlayer nowPlayingItem] valueForProperty:  MPMediaItemPropertyTitle]];

//131001 make player compatible with iTunes Radio begin

    if (!self.nowPlayingMarqueeLabel.text && musicPlayer.playbackState != MPMusicPlaybackStateStopped) {
        self.nowPlayingMarqueeLabel.text = @"  iTunes Radio";
    }

//131001 make player compatible with iTunes Radio end

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

//131210 1.2 iOS 7 begin
    
//    CGSize labelSize = [self.nextSongLabel.text sizeWithFont:self.nextSongLabel.font
//                                           constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(self.nextSongScrollView.bounds))
//                                               lineBreakMode:NSLineBreakByClipping];
    
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:self.nextSongLabel.text
                                                                        attributes:@{NSFontAttributeName: self.nextSongLabel.font}];
    
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(INT16_MAX, CGRectGetHeight(self.nextSongScrollView.bounds))
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize labelSize = rect.size;
    
//131210 1.2 iOS 7 end
    
    [self.nextSongScrollView removeConstraint:self.centerXInNextSongScrollView];
    
    //Make sure that label is aligned with scrollView
    [self.nextSongScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    //    NSLog (@" self.nextSongScrollView.frame.size.width = %f", self.nextSongScrollView.frame.size.width);
    //    NSLog (@" labelSize.width = %f", labelSize.width);
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
        //        elapsed -= secs;
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
//140218 1.2 iOS 7 begin
        [self.navigationController popViewControllerAnimated:YES];
//140218 1.2 iOS 7 end
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
//131001 make player compatible with iTunes Radio begin

    if (songDuration) {
        self.remainingTimeLabel.text = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:songRemainingTime]];
    } else {
        self.remainingTimeLabel.text = @"";
    }
//131001 make player compatible with iTunes Radio end

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
            
//140128 1.2 iOS 7 begin
            self.collectionRemainingLabel = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:collectionRemainingTime]];
            UIButton *tempDurationButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [tempDurationButton setTitle: self.collectionRemainingLabel forState:UIControlStateNormal];
            [tempDurationButton addTarget:self action:@selector(magnify) forControlEvents:UIControlEventTouchUpInside];
            [tempDurationButton setShowsTouchWhenHighlighted:NO];
            tempDurationButton.titleLabel.font            = [UIFont systemFontOfSize: 44];
            [tempDurationButton sizeToFit];

            UIBarButtonItem *durationButton = [[UIBarButtonItem alloc] initWithCustomView:tempDurationButton];
//140128 1.2 iOS 7 end
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
        textMagnifierViewController.textToMagnify = self.nowPlayingMarqueeLabel.text;
        textMagnifierViewController.textType = segue.identifier;
        textMagnifierViewController.mainViewController = self;
        
	}
    
    if ([segue.identifier isEqualToString:@"MagnifyPlaylistRemaining"])
	{
        TimeMagnifierViewController *timeMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        timeMagnifierViewController.delegate = self;
//140218 1.2 iOS 7 begin
        timeMagnifierViewController.textToMagnify = self.collectionRemainingLabel;
//140218 1.2 iOS 7 end
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
        infoTabBarController.mainViewIsSender = YES;
        
        //remove observer for playbackstatechanged because if editing, don't want to pop view
        //  observer will be added back in infoTabBarControllerDidCancel
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                      object: musicPlayer];
        
	}
    
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
   LogMethod();
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
        [self.repeatButton setAccessibilityLabel: NSLocalizedString(@"Repeat All", nil)];
        [self.repeatButton setAccessibilityHint: NSLocalizedString(@"Changes repeat settings", nil)];
        
        
        //        UIImage *coloredImage = [[UIImage imageNamed: @"bigrepeatblue.png"] imageWithTint:[UIColor blueColor]];
        //        [self.repeatButton setImage: coloredImage forState:UIControlStateNormal];
        
    } else if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
        [musicPlayer setRepeatMode: MPMusicRepeatModeOne];
        //        UIImage *coloredImage = [[UIImage imageNamed: @"bigrepeat1blue.png"] imageWithTint:[UIColor blueColor]];
        //        [self.repeatButton setImage: coloredImage forState:UIControlStateNormal];
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat1blue.png"] forState: UIControlStateNormal];
        [self.repeatButton setAccessibilityLabel: NSLocalizedString(@"Repeat Track", nil)];
        [self.repeatButton setAccessibilityHint: NSLocalizedString(@"Changes repeat settings", nil)];
        
        self.nextSongScrollView.hidden = YES;
        self.nextSongLabel.hidden = YES;
        self.nextLabel.hidden = YES;
        
    } else if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
        [musicPlayer setRepeatMode: MPMusicRepeatModeNone];
        //        UIImage *coloredImage = [[UIImage imageNamed: @"bigrepeat.png"] imageWithTint:[UIColor whiteColor]];
        //        [self.repeatButton setImage: coloredImage forState:UIControlStateNormal];
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat.png"] forState: UIControlStateNormal];
        [self.repeatButton setAccessibilityLabel: NSLocalizedString(@"Repeat Off", nil)];
        [self.repeatButton setAccessibilityHint: NSLocalizedString(@"Changes repeat settings", nil)];
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
        self.shuffleButton.isSelected = YES;
        //        [self.shuffleButton setAccessibilityTraits: UIAccessibilityTraitSelected];
        
        //        self.nextSongLabel.text = [NSString stringWithFormat: @""];
        //        self.nextLabel.text = [NSString stringWithFormat:@""];
        self.nextSongScrollView.hidden = YES;
        self.nextSongLabel.hidden = YES;
        self.nextLabel.hidden = YES;
    } else if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffle.png"] forState: UIControlStateNormal];
        self.shuffleButton.isSelected = NO;
        
        
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

#pragma mark Application state changes____________________________

#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: iPod library access works only when running on a device.
#endif


- (void) registerForMediaPlayerNotifications {
    //      LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];

    [notificationCenter addObserver: self
                           selector: @selector (handle_iPodLibraryChanged:)
                               name: MPMediaLibraryDidChangeNotification
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_ApplicationDidBecomeActive:)
                               name: UIApplicationDidBecomeActiveNotification
                             object: nil];
    
//    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];

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
//131011 1.1 fix musicPlayer bug begin
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
    NSLog (@"                                           playbackState = %ld", playbackState);

    if (!delayPlaybackStateChange) {
        delayPlaybackStateChange = YES;
        [self performSelector:@selector(delayedHandlePlaybackChange) withObject:nil afterDelay:1.0];
    }
}
- (void) delayedHandlePlaybackChange {
    LogMethod();

    delayPlaybackStateChange = NO;
    
//131011 1.1 fix musicPlayer bug begin
    //play is paused during scrubbing to prevent skipping to new song, so do not change the UI
    if (!userIsScrubbing) {
        
        MPMusicPlaybackState playbackState = [musicPlayer playbackState];
        
        NSLog (@" playbackState = %lu", playbackState);
        
        if (playbackState != MPMusicPlaybackStatePlaying) {
            
            [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
            [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Play", nil)];
            
            savedPlaybackState = playbackState;
            
        } else if (playbackState == MPMusicPlaybackStatePlaying) {
            
            [playPauseButton setImage: [UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
            [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Pause", nil)];
            
            savedPlaybackState = playbackState;
            
            
        }
        //131011 1.1 fix musicPlayer playbackState bug begin
        if ([self isPlaybackStateBugActive]) {
            saveVolume = [musicPlayer volume];
            [musicPlayer setVolume: 0.0];
            NSLog (@"turned volume off");
        }
        //131011 1.1 fix musicPlayer playbackState bug end

//131011 1.1 fix musicPlayer bug begin

        if (isPlaying) {
            [playPauseButton setImage: [UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
            [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Pause", nil)];
            
            savedPlaybackState = playbackState;
            isPlaying = NO;
            [musicPlayer pause];
            [musicPlayer play];
            [musicPlayer setVolume: saveVolume];
            NSLog (@"turned volume on");


        }
        if (isPausedOrStopped) {
            [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
            [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Play", nil)];

            savedPlaybackState = playbackState;
            isPausedOrStopped = NO;
            [musicPlayer play];
            [musicPlayer pause];
            [musicPlayer setVolume: saveVolume];
            NSLog (@"turned volume on");

        }
        NSLog (@" Final playbackState = %ld", playbackState);

//131011 1.1 fix musicPlayer bug end

        if (playbackState == MPMusicPlaybackStateStopped) {
            
            //            [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
            //            savedPlaybackState = playbackState;
            
            
            if (!playNew) {
                // Even though stopped, invoking 'stop' ensures that the music player will play
                //		its queue from the start. - !except if first time thru and state is stopped
                [musicPlayer stop];
                
                BOOL userIsEditing = [[NSUserDefaults standardUserDefaults] boolForKey:@"userIsEditing"];
//140218 1.2 iOS 7 begin
                //if the user is editing, we don't want to pop, so call pop controller in InfoTabBarDidCancel
                if (!userIsEditing) {
                    [self.navigationController popViewControllerAnimated:YES];
//140218 1.2 iOS 7 end
                }
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
//131011 1.1 fix musicPlayer playbackState bug begin
//-(BOOL) isPlaybackStateBugActive {

-(BOOL) isPlaybackStateBugActive {
    MPMusicPlaybackState playbackState = self.musicPlayer.playbackState;
    isPausedOrStopped = NO;
    isPlaying = NO;
    if (playbackState == MPMusicPlaybackStatePlaying) {
        AudioSessionInitialize (NULL, NULL, NULL, NULL);
        UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
        AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
        AudioSessionSetActive (true);
        
        UInt32 audioIsPlaying;
        UInt32 size = sizeof(audioIsPlaying);
        AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &size, &audioIsPlaying);
        
        if (!audioIsPlaying){
            NSLog(@"                                           PlaybackState bug is active");
            isPausedOrStopped = YES;
//            [playPauseButton setImage:[UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
//            [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Pause", nil)];
            return YES;
        }
    }
    if (playbackState == MPMusicPlaybackStatePaused || playbackState == MPMusicPlaybackStateStopped) {
        AudioSessionInitialize (NULL, NULL, NULL, NULL);
        UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
        AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
        AudioSessionSetActive (true);
        
        UInt32 audioIsPlaying;
        UInt32 size = sizeof(audioIsPlaying);
        AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &size, &audioIsPlaying);
        
        if (audioIsPlaying){
            NSLog(@"PlaybackState bug is active");
            isPlaying = YES;

//            [playPauseButton setImage:[UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
//            [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Play", nil)];
            return YES;
        }
    }
    return NO;
}
//131011 1.1 fix musicPlayer playbackState bug end

- (void) handle_ApplicationDidBecomeActive: (id) notification
{

    
    if (musicPlayer.playbackState == MPMusicPlaybackStateInterrupted) {
        NSLog (@"savedPlaybackState is %lu", savedPlaybackState);
        if (savedPlaybackState == MPMusicPlaybackStatePlaying) {
            [playPauseButton setImage:[UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
            [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Play", nil)];
            
            
            [musicPlayer play];
            //            NSLog (@"****************Playing");
        } else {
            [playPauseButton setImage:[UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
            [playPauseButton setAccessibilityLabel: NSLocalizedString(@"Pause", nil)];
            
            
            saveVolume = [musicPlayer volume];
            [musicPlayer setVolume: 0.0];
            [self performSelector:@selector(delayedPlay) withObject:nil afterDelay:0.0];
            //            NSLog (@"**************NOT Playing");
        }
    }
    NSLog (@"Shuffle Mode is %lu", musicPlayer.shuffleMode);
    
    if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffleblue.png"] forState: UIControlStateNormal];
        self.shuffleButton.isSelected = YES;
        //        [self.shuffleButton setAccessibilityTraits: UIAccessibilityTraitSelected];
        
        
    } else {
        [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffle.png"] forState: UIControlStateNormal];
        self.shuffleButton.isSelected = NO;
        
        
    }
    NSLog (@"Repeat Mode is %lu", musicPlayer.repeatMode);
    
    if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat1blue.png"] forState: UIControlStateNormal];
        [self.repeatButton setAccessibilityLabel: NSLocalizedString(@"Repeat Track", nil)];
        [self.repeatButton setAccessibilityHint: NSLocalizedString(@"Changes repeat settings", nil)];
        
    } else if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeatblue.png"] forState: UIControlStateNormal];
        [self.repeatButton setAccessibilityLabel: NSLocalizedString(@"Repeat All", nil)];
        [self.repeatButton setAccessibilityHint: NSLocalizedString(@"Changes repeat settings", nil)];
        
    } else {
        [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat.png"] forState: UIControlStateNormal];
        [self.repeatButton setAccessibilityLabel: NSLocalizedString(@"Repeat Off", nil)];
        [self.repeatButton setAccessibilityHint: NSLocalizedString(@"Changes repeat settings", nil)];
        
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
}
//#pragma mark - TextMagnifierViewControllerDelegate

- (void)timeMagnifierViewControllerDidCancel:(TimeMagnifierViewController *)controller
{
    stopWatchRunning = NO;
    //	[self dismissViewControllerAnimated:YES completion:nil];
    [controller dismissViewControllerAnimated:YES completion:nil];
}
//#pragma mark - InfoTabBarControllerDelegate

- (void)infoTabBarControllerDidCancel:(InfoTabBarController *)controller
{
    //need to add back observer for playbackStatechanged because it was removed before going to info in case user edits
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStateStopped) {
//140218 1.2 iOS 7 begin
        [self.navigationController popViewControllerAnimated:YES];
//140218 1.2 iOS 7 end
    }
    
}
- (void)viewWillDisappear:(BOOL)animated {
    LogMethod();
    [super viewWillDisappear: animated];
    //remove the swipe gesture from the nav bar  (doesn't work to wait until dealloc)
    [self.navigationController.navigationBar removeGestureRecognizer:self.swipeLeftRight];
    
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

//    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];

	[musicPlayer endGeneratingPlaybackNotifications];
    
    
}
- (void) didReceiveMemoryWarning {
    //    LogMethod();
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [self setNowPlayingMarqueeLabel:nil];
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
    //    [self setNextSongLabelWidthConstraint:nil];
    
    
    
	
	// Release any cached data, images, etc that aren't in use.
}
@end
