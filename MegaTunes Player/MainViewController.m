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




#pragma mark Audio session callbacks_______________________

// Audio session callback function for responding to audio route changes. If playing
//		back application audio when the headset is unplugged, this callback pauses
//		playback and displays an alert that allows the user to resume or stop playback.
//
//		The system takes care of iPod audio pausing during route changes--this callback
//		is not involved with pausing playback of iPod audio.
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
	
	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
	// This callback, being outside the implementation block, needs a reference to the
	//		MainViewController object, which it receives in the inUserData parameter.
	//		You provide this reference when registering this callback (see the call to
	//		AudioSessionAddPropertyListener).
	MainViewController *controller = (__bridge MainViewController *) inUserData;
	
	// if application sound is not playing, there's nothing to do, so return.
	if (controller.appSoundPlayer.playing == 0 ) {
        
		NSLog (@"Audio route change while application audio is stopped.");
		return;
		
	} else {
        
		// Determines the reason for the route change, to ensure that it is not
		//		because of a category change.
		CFDictionaryRef	routeChangeDictionary = inPropertyValue;
		
		CFNumberRef routeChangeReasonRef =
        CFDictionaryGetValue (
                              routeChangeDictionary,
                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                              );
        
		SInt32 routeChangeReason;
		
		CFNumberGetValue (
                          routeChangeReasonRef,
                          kCFNumberSInt32Type,
                          &routeChangeReason
                          );
		
		// "Old device unavailable" indicates that a headset was unplugged, or that the
		//	device was removed from a dock connector that supports audio output. This is
		//	the recommended test for when to pause audio.
		if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
			[controller.appSoundPlayer pause];
			NSLog (@"Output device removed, so application audio was paused.");
            
			UIAlertView *routeChangeAlertView =
            [[UIAlertView alloc]	initWithTitle: NSLocalizedString (@"Playback Paused", @"Title for audio hardware route-changed alert view")
                                       message: NSLocalizedString (@"Audio output was changed", @"Explanation for route-changed alert view")
                                      delegate: controller
                             cancelButtonTitle: NSLocalizedString (@"StopPlaybackAfterRouteChange", @"Stop button title")
                             otherButtonTitles: NSLocalizedString (@"ResumePlaybackAfterRouteChange", @"Play button title"), nil];
			[routeChangeAlertView show];
			// release takes place in alertView:clickedButtonAtIndex: method
            
		} else {
            
			NSLog (@"A route change occurred that does not require pausing of application audio.");
		}
	}
}



@implementation MainViewController

@synthesize userMediaItemCollection;	// the media item collection created by the user, using the media item picker
@synthesize musicPlayer;				// the music player, which plays media items from the iPod library

@synthesize navigationBar;				// the application's Navigation bar
@synthesize nowPlayingLabel;			// descriptive text shown on the main screen about the now-playing media item
//@synthesize autoScrollLabel;
@synthesize appSoundPlayer;				// An AVAudioPlayer object for playing application sound
@synthesize soundFileURL;				// The path to the application sound
@synthesize interruptedOnPlayback;		// A flag indicating whether or not the application was interrupted during application audio playback
@synthesize playedMusicOnce;			// A flag indicating if the user has played iPod library music at least one time since application launch.
@synthesize playing;					// An application that responds to interruptions must keep track of its playing not-playing state.
@synthesize playbackTimer;
@synthesize nowPlayingInfoCenter;
@synthesize playNew;                    //Flag set if new song has been selected to play
@synthesize itemToPlay;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext;

//these lines came from player view controller

@synthesize currentQueue;
@synthesize elapsedTimeLabel;
@synthesize progressSlider;
@synthesize remainingTimeLabel;

@synthesize volumeView;
@synthesize nextLabel;
@synthesize nextSongLabel;
@synthesize collectionItem;
@synthesize playPauseButton;
@synthesize repeatShuffleButtons;
@synthesize playerButtonContraint;



//- (void) saveUserMediaItemCollection: (NSArray*) collectionArray {
//    [[NSUserDefaults standardUserDefaults] setObject: collectionArray forKey:@"CurrentCollection"];
//}
//- (NSArray*) retrieveUserMediaItemCollection {
//   NSArray* collectionArray= [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentCollection"];
//    return collectionArray;
//}
#pragma mark Music control________________________________

- (IBAction)moveSlider:(id)sender {
    //    LogMethod();
    [musicPlayer setCurrentPlaybackTime: [self.progressSlider value]];
}

- (IBAction)skipBack:(id)sender {
    if ([musicPlayer currentPlaybackTime] > 5.0) {
        [musicPlayer skipToBeginning];
    } else {
        [musicPlayer skipToPreviousItem];
    }
}

- (IBAction)skipForward:(id)sender {
    [musicPlayer skipToNextItem];

}

- (IBAction)playPause:(id)sender {
//   LogMethod();
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];

	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
        [self playMusic];

	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[musicPlayer pause];
	}
}

//- (IBAction)playerButtonsChanged:(id)sender {
//#pragma mark TODO could this be a case statement?
//    NSLog (@"playerButtons.selectedSegmentIndex is %d", playerButtons.selectedSegmentIndex);
//    if (playerButtons.selectedSegmentIndex == 0) {
//        playerButtons.selectedSegmentIndex = -1;
//        if ([musicPlayer currentPlaybackTime] > 5.0) {
//            [musicPlayer skipToBeginning];
//        } else {
//            [musicPlayer skipToPreviousItem];
//        }
//    }else if (playerButtons.selectedSegmentIndex == 1){
//        playerButtons.selectedSegmentIndex = -1;
//        MPMusicPlaybackState playbackState = [musicPlayer playbackState];
//        
//        if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
//            [self playMusic];
//            
//        } else if (playbackState == MPMusicPlaybackStatePlaying) {
//            [musicPlayer pause];
//        }
//    }else if (playerButtons.selectedSegmentIndex == 2){
//        playerButtons.selectedSegmentIndex = -1;
//        [musicPlayer skipToNextItem];
//    }
////    [playerButtons setNeedsLayout];
//
//}

- (IBAction)repeatShuffleButtonsChanged:(id)sender {
    NSLog (@"repeatShuffleButtons.selectedSegmentIndex is %d", repeatShuffleButtons.selectedSegmentIndex);
    if (repeatShuffleButtons.selectedSegmentIndex == 0) {
        repeatShuffleButtons.selectedSegmentIndex = -1;
        //need to handle MPMusicRepeatModeOne
        //    NSLog (@"repeatMode is %d", [musicPlayer repeatMode]);
        if (musicPlayer.repeatMode == MPMusicRepeatModeNone) {
            [musicPlayer setRepeatMode: MPMusicRepeatModeAll];
            [repeatShuffleButtons setImage:[UIImage imageNamed:@"bigrepeat.png"] forSegmentAtIndex:0];

//            [self.repeatButton setImage: [UIImage imageNamed: @"bigrepeat.png"] forState: UIControlStateNormal];
            
        } else if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
            [musicPlayer setRepeatMode: MPMusicRepeatModeNone];
            UIImage *coloredImage = [[repeatShuffleButtons imageForSegmentAtIndex: 0] imageWithTint:[UIColor grayColor]];
            [repeatShuffleButtons setImage:coloredImage forSegmentAtIndex:0];

//            [self.repeatButton setImage: coloredImage forState: UIControlStateNormal];
        }
    }else if (repeatShuffleButtons.selectedSegmentIndex == 1){
        repeatShuffleButtons.selectedSegmentIndex = -1;
        //need to handle MPMusicShuffleModeAlbums
        if (musicPlayer.shuffleMode == MPMusicShuffleModeOff) {
            [musicPlayer setShuffleMode: MPMusicShuffleModeSongs];
            [repeatShuffleButtons setImage:[UIImage imageNamed:@"bigshuffle.png"] forSegmentAtIndex:1];

//            [self.shuffleButton setImage: [UIImage imageNamed: @"bigshuffle.png"] forState: UIControlStateNormal];
        } else if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
            [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
            UIImage *coloredImage = [[repeatShuffleButtons imageForSegmentAtIndex: 1] imageWithTint:[UIColor grayColor]];
            [repeatShuffleButtons setImage:coloredImage forSegmentAtIndex:1];
        }
    }
}
- (void) playMusic {
    
    [musicPlayer play];
    [self updateTime];
}

- (void) updateTime
{
    long playbackSeconds = musicPlayer.currentPlaybackTime;
    long songDuration = [[self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
    long songRemainingSeconds = songDuration - playbackSeconds;
    
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
    
    long collectionDuration = [self.collectionItem.duration longValue];
    long collectionElapsed;
    long collectionRemainingSeconds;
    
    if (collectionDuration > 0) {
        collectionElapsed = [[self calculatePlaylistElapsed] longValue] + playbackSeconds;
        collectionRemainingSeconds = collectionDuration - collectionElapsed;
    } else {
        collectionRemainingSeconds = 0;
    }
    
    NSString *collectionRemaining = [[NSString alloc] init];
    
    if (collectionRemainingSeconds >= 3600) {
        collectionRemaining = [NSString stringWithFormat:@"%lu:%02lu:%02lu",
                                         collectionRemainingSeconds / 3600,
                                         (collectionRemainingSeconds % 3600)/60,
                                         collectionRemainingSeconds % 60];

        formatter.dateFormat = @"H:mm:ss";
    } else {
        collectionRemaining = [NSString stringWithFormat:@"%lu:%02lu",
                               collectionRemainingSeconds /60,
                               collectionRemainingSeconds % 60];

        formatter.dateFormat = @"m:ss";
    }
    NSDate *collectionRemainingTime = [formatter dateFromString:collectionRemaining];
        
    if (collectionRemainingTime) {
        if (collectionRemainingSeconds > 0) {

        NSString *collectionRemainingLabel = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:collectionRemainingTime]];
        

        UIBarButtonItem *durationButton = [[UIBarButtonItem alloc] initWithTitle:collectionRemainingLabel style:UIBarButtonItemStyleBordered target:self action: @selector(magnify)];
        
        self.navigationItem.rightBarButtonItem=durationButton;
        } else {
            self.navigationItem.rightBarButtonItem=nil;
        }
    } 
    [self positionSlider];
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
#pragma mark TODO aborts on this line on reload

        playlistElapsed = (playlistElapsed + [[[returnedQueue objectAtIndex: i] valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);

    }

    return [NSNumber numberWithLong: playlistElapsed];
}
- (void)positionSlider {
    self.progressSlider.value = musicPlayer.currentPlaybackTime;
    self.progressSlider.minimumValue = 0;
    
    NSNumber *duration = [self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    
    float totalTime = [duration floatValue];
    
    self.progressSlider.maximumValue = totalTime;
}

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

#pragma mark Music notification handlers__________________

// When the now-playing item changes, update the now-playing label and the next label.
- (void) handle_NowPlayingItemChanged: (id) notification {
//   LogMethod();

	MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
    
    //check the queue stored in Core Data to see if the nowPlaying song is in that queue
    ItemCollection *itemCollection = [ItemCollection alloc];
    itemCollection.managedObjectContext = self.managedObjectContext;
    
    self.collectionItem = [itemCollection containsItem: [currentItem valueForProperty: MPMediaItemPropertyTitle]];
    self.userMediaItemCollection = collectionItem.collection;
    
    // Display the song name for the now-playing media item and next-playing media item with duration
    // scroll marquee style if too long for field
    
    self.nowPlayingLabel.text = [currentItem valueForProperty:  MPMediaItemPropertyTitle];
//    NSLog (@"nowPlayingLabel.text is %@", self.nowPlayingLabel.text);
    self.nowPlayingLabel.textColor = [UIColor whiteColor];
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:44];
    self.nowPlayingLabel.font = newFont;
    
    NSUInteger nextPlayingIndex = [musicPlayer indexOfNowPlayingItem] + 1;
    
    if (nextPlayingIndex >= self.userMediaItemCollection.count) {
        self.nextSongLabel.text = [NSString stringWithFormat: @""];
        self.nextLabel.text = [NSString stringWithFormat:@""];
    } else {
        long nextDuration = [[[[self.userMediaItemCollection items] objectAtIndex: nextPlayingIndex] valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
        NSString *formattedNextDuration = [NSString stringWithFormat:@"%2lu:%02lu",nextDuration/60,nextDuration -(nextDuration/60)*60];
        self.nextSongLabel.text = [NSString stringWithFormat: @"%@  %@",[[[self.userMediaItemCollection items] objectAtIndex: nextPlayingIndex] valueForProperty:  MPMediaItemPropertyTitle], formattedNextDuration];
        self.nextLabel.text = [NSString stringWithFormat: @"Next:"];
        ;
    }
    self.nextSongLabel.textColor = [UIColor whiteColor];
    self.nextSongLabel.font = newFont;
    self.nextSongLabel.textAlignment = NSTextAlignmentLeft;
    
    [self updateTime];
    [self nowPlayingInfo];
    
}
- (void) nowPlayingInfo {
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
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTitle]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTitle] forKey:MPMediaItemPropertyAlbumTitle];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTrackCount]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTrackCount] forKey:MPMediaItemPropertyAlbumTrackCount];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTrackNumber]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyAlbumTrackNumber] forKey:MPMediaItemPropertyAlbumTrackNumber];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyArtist]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyArtist] forKey:MPMediaItemPropertyArtist];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyArtwork]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyArtwork] forKey:MPMediaItemPropertyArtwork];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyComposer]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyComposer] forKey:MPMediaItemPropertyComposer];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyDiscCount]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyDiscCount] forKey:MPMediaItemPropertyDiscCount];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyDiscNumber]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyDiscNumber] forKey:MPMediaItemPropertyDiscNumber];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyGenre]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyGenre] forKey:MPMediaItemPropertyGenre];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyPersistentID]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyPersistentID] forKey:MPMediaItemPropertyPersistentID];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyPlaybackDuration]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyPlaybackDuration] forKey:MPMediaItemPropertyPlaybackDuration];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle] forKey:MPMediaItemPropertyTitle];
        }
        //        NSString *const MPNowPlayingInfoPropertyElapsedPlaybackTime
        //        NSString *const MPNowPlayingInfoPropertyPlaybackRate;
        //        NSString *const MPNowPlayingInfoPropertyPlaybackQueueIndex;
        //        NSString *const MPNowPlayingInfoPropertyPlaybackQueueCount;
        //        NSString *const MPNowPlayingInfoPropertyChapterNumber;
        //        NSString *const MPNowPlayingInfoPropertyChapterCount;
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyPlaybackRate]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyPlaybackRate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        }
        NSNumber *queueCount = [[NSNumber alloc]  initWithInteger: userMediaItemCollection.count];
        [songInfo setObject: queueCount forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
        NSNumber *queueIndex  = [[NSNumber alloc]  initWithInteger: [musicPlayer indexOfNowPlayingItem]];
        [songInfo setObject: queueIndex forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
        
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyChapterNumber]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyChapterNumber] forKey:MPNowPlayingInfoPropertyChapterNumber];
        }
        if ([[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyChapterCount]) {
            [songInfo setObject:[[musicPlayer nowPlayingItem] valueForProperty: MPNowPlayingInfoPropertyChapterCount] forKey:MPNowPlayingInfoPropertyChapterCount];
        }
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
        //        NSMutableDictionary *showSongInfo = [[NSMutableDictionary alloc]
        //                                             initWithDictionary: [[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
        //
        //        NSLog (@"Audio Title %@", [showSongInfo objectForKey: MPMediaItemPropertyTitle]);
        //        NSLog (@"Playback Queue Count %d",[[showSongInfo objectForKey: MPNowPlayingInfoPropertyPlaybackQueueCount] intValue]);
        //        NSLog (@"Playback Queue Index %d",[[showSongInfo objectForKey: MPNowPlayingInfoPropertyPlaybackQueueIndex] intValue]);
    }

}
// When the playback state changes, set the play/pause button appropriately.
- (void) handle_PlaybackStateChanged: (id) notification {
   LogMethod();    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
	if (playbackState == MPMusicPlaybackStatePaused) {
        
//        playerButtons.selectedSegmentIndex = 1;
//        [playerButtons setImage:[UIImage imageNamed:@"bigplay.png"] forSegmentAtIndex:1];
        [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
		
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
        
//        [playerButtons setImage:[UIImage imageNamed:@"bigpause.png"] forSegmentAtIndex:1];

        [playPauseButton setImage: [UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
        
	} else if (playbackState == MPMusicPlaybackStateStopped) {
        
//        [playerButtons setImage:[UIImage imageNamed:@"bigplay.png"] forSegmentAtIndex:1];

        [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
		
		// Even though stopped, invoking 'stop' ensures that the music player will play
		//		its queue from the start.
        [self.navigationController popViewControllerAnimated:YES];  
		[musicPlayer stop];
        
	}

}

- (void) handle_iPodLibraryChanged: (id) notification {
   LogMethod();    
	// Implement this method to update cached collections of media items when the
	// user performs a sync while your application is running. This sample performs
	// no explicit media queries, so there is nothing to update.
}



#pragma mark Application playback control_________________

// delegate method for the audio route change alert view; follows the protocol specified
//	in the UIAlertViewDelegate protocol.
- (void) alertView: routeChangeAlertView clickedButtonAtIndex: buttonIndex {
    
	if ((NSInteger) buttonIndex == 1) {
		[appSoundPlayer play];
	} else {
		[appSoundPlayer setCurrentTime: 0];
	}
	
}



#pragma mark AV Foundation delegate methods____________

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) appSoundPlayer successfully: (BOOL) flag {
   LogMethod();    
	playing = NO;
}

- (void) audioPlayerBeginInterruption: player {
    LogMethod();   
	NSLog (@"Interrupted. The system has paused audio playback.");
	
	if (playing) {
        
		playing = NO;
		interruptedOnPlayback = YES;
	}
}

- (void) audioPlayerEndInterruption: player {
   LogMethod();    
	NSLog (@"Interruption ended. Resuming audio playback.");
	
	// Reactivates the audio session, whether or not audio was playing
	//		when the interruption arrived.
	[[AVAudioSession sharedInstance] setActive: YES error: nil];
	
	if (interruptedOnPlayback) {
        
		[appSoundPlayer prepareToPlay];
		[appSoundPlayer play];
		playing = YES;
		interruptedOnPlayback = NO;
	}
}


#pragma mark Application setup____________________________

#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: iPod library access works only when running on a device.
#endif

//- (void) setupApplicationAudio {
//	LogMethod();
//	// Gets the file system path to the sound to play.
//	NSString *soundFilePath = [[NSBundle mainBundle]	pathForResource:	@"sound"
//                                                              ofType:				@"caf"];
//    
//	// Converts the sound's file path to an NSURL object
//	NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
//	self.soundFileURL = newURL;
//    
//	// Registers this class as the delegate of the audio session.
//	[[AVAudioSession sharedInstance] setDelegate: self];
//	
//	// The AmbientSound category allows application audio to mix with Media Player
//	// audio. The category also indicates that application audio should stop playing
//	// if the Ring/Siilent switch is set to "silent" or the screen locks.
//	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
//    /*
//     // Use this code instead to allow the app sound to continue to play when the screen is locked.
//     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
//     
//     UInt32 doSetProperty = 0;
//     AudioSessionSetProperty (
//     kAudioSessionProperty_OverrideCategoryMixWithOthers,
//     sizeof (doSetProperty),
//     &doSetProperty
//     );
//     */
//    
//	// Registers the audio route change listener callback function
//	AudioSessionAddPropertyListener (
//                                     kAudioSessionProperty_AudioRouteChange,
//                                     audioRouteChangeListenerCallback,
//                                     (__bridge void *)(self)
//                                     );
//    
//	// Activates the audio session.
//	
//	NSError *activationError = nil;
//	[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
//    
//	// Instantiates the AVAudioPlayer object, initializing it with the sound
//	AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: nil];
//	self.appSoundPlayer = newPlayer;
//	
//	// "Preparing to play" attaches to the audio hardware and ensures that playback
//	//		starts quickly when the user taps Play
//	[appSoundPlayer prepareToPlay];
//	[appSoundPlayer setVolume: 1.0];
//	[appSoundPlayer setDelegate: self];
//}


// To learn about notifications, see "Notifications" in Cocoa Fundamentals Guide.
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
    
    /*
     // This sample doesn't use libray change notifications; this code is here to show how
     //		it's done if you need it.
     [notificationCenter addObserver: self
     selector: @selector (handle_iPodLibraryChanged:)
     name: MPMediaLibraryDidChangeNotification
     object: musicPlayer];
     
     [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
     */
    
	[musicPlayer beginGeneratingPlaybackNotifications];
}

// Configure the application.

- (void) viewDidLoad {
      LogMethod();
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES; // Important
    //initWithTitle cannot be nil, must be @""
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBackClick)];
    
    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    //need this to use MPNowPlayingInfoCenter
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];

    //not sure, but think this is only needed to play sounds not music
//    [self setupApplicationAudio];
    
    [self setPlayedMusicOnce: NO];
            
    // Instantiate the music player. If you specied the iPod music player in the Settings app,
    //		honor the current state of the built-in iPod app.
    
    if ([appDelegate useiPodPlayer]) {
        
        [self setMusicPlayer: [MPMusicPlayerController iPodMusicPlayer]];
        
    } else {
        
        [self setMusicPlayer: [MPMusicPlayerController applicationMusicPlayer]];
        
        // By default, an application music player takes on the shuffle and repeat modes
        //		of the built-in iPod app. Here they are both turned off.
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [musicPlayer setRepeatMode: MPMusicRepeatModeNone];
    }

//    NSArray *returnedQueue = [self.userMediaItemCollection items];
//    
//    for (MPMediaItem *song in returnedQueue) {
//        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSLog (@"\t\t%@", songTitle);
//    }
    if (playNew) {
        [musicPlayer setQueueWithItemCollection: self.userMediaItemCollection];
        
        [musicPlayer setNowPlayingItem: self.itemToPlay];
        [self playMusic];
        [self setPlayNew: NO];
    } else if ([musicPlayer nowPlayingItem]) {
        
        // Update the UI to reflect the now-playing item.
        [self handle_NowPlayingItemChanged: nil];
        
        if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
//            [playerButtons setImage:[UIImage imageNamed:@"bigplay.png"] forSegmentAtIndex:1];

            [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
            //            [nowPlayingLabel setText: NSLocalizedString (@"Instructions", @"Brief instructions to user, shown at launch")];
            
        }
    }
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {

        self.repeatShuffleButtons = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: [UIImage imageNamed: @"bigrepeat.png" ], [UIImage imageNamed: @"bigshuffle.png" ], nil]];
        self.repeatShuffleButtons.frame = CGRectMake(35, 240, 250, 60);
        self.repeatShuffleButtons.segmentedControlStyle = UISegmentedControlStyleBar;
        self.repeatShuffleButtons.selectedSegmentIndex = 0;
        self.repeatShuffleButtons.tintColor = [UIColor blackColor];
        [self.repeatShuffleButtons addTarget:self action:@selector(repeatShuffleButtonsChanged:) forControlEvents: UIControlEventValueChanged];
        [self.view addSubview: self.repeatShuffleButtons];
        
        if (musicPlayer.shuffleMode == MPMusicShuffleModeOff) {
            UIImage *coloredImage = [[self.repeatShuffleButtons imageForSegmentAtIndex: 1] imageWithTint:[UIColor whiteColor]];
            [self.repeatShuffleButtons setImage:coloredImage forSegmentAtIndex:1];
        }
        if (musicPlayer.repeatMode == MPMusicRepeatModeNone) {
            UIImage *coloredImage = [[self.repeatShuffleButtons imageForSegmentAtIndex: 0] imageWithTint:[UIColor whiteColor]];
            [self.repeatShuffleButtons setImage:coloredImage forSegmentAtIndex:0];
        }
        self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(40,320,240,50)];
        

        [self.volumeView setMinimumVolumeSliderImage:[UIImage imageNamed:@"slider-fill.png"] forState:UIControlStateNormal];
        [self.volumeView setMaximumVolumeSliderImage:[UIImage imageNamed:@"slider-trackGray.png"] forState:UIControlStateNormal];
        [self.volumeView setVolumeThumbImage:[UIImage imageNamed:@"volume_down.png"] forState:UIControlStateNormal];

        [self.view addSubview: self.volumeView];
    } else {
        [self.view removeConstraint:self.playerButtonContraint];

    }
    
    [nowPlayingLabel  refreshLabels];
    [nextSongLabel    refreshLabels];
    
//    [self willAnimateRotationToInterfaceOrientation: self.interfaceOrientation duration: 1];
    [self registerForMediaPlayerNotifications];
    [self setPlayedMusicOnce: YES];
    
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    LogMethod();

    [nowPlayingLabel  refreshLabels];
    [nextSongLabel    refreshLabels];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.view removeConstraint:self.playerButtonContraint];
        self.repeatShuffleButtons.hidden = YES;
        self.volumeView.hidden = YES;
        
    } else {

        [self.view addConstraint:self.playerButtonContraint];
        self.repeatShuffleButtons.hidden = NO;
        self.volumeView.hidden = NO;

//        CGRect rect = self.progressSlider.frame;
//        rect.origin.y = rect.origin.y - 12;
//        self.progressSlider.frame = rect;
//
//        rect = self.playerButtons.frame;
//        rect.origin.y = rect.origin.y + 30;
//        self.playerButtons.frame = rect;
//        
//        rect = self.elapsedTimeLabel.frame;
//        rect.origin.y = rect.origin.y + 30;
//        self.elapsedTimeLabel.frame = rect;
//        
//        rect = self.remainingTimeLabel.frame;
//        rect.origin.y = rect.origin.y + 30;
//        self.remainingTimeLabel.frame = rect;


    }

}

#pragma mark Application state management_____________

- (void) didReceiveMemoryWarning {
       LogMethod();
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [self setNowPlayingLabel:nil];
    [self setElapsedTimeLabel:nil];
    [self setProgressSlider:nil];
    [self setRemainingTimeLabel:nil];
    [self setNextSongLabel:nil];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
//       LogMethod();
    /*
     // This sample doesn't use libray change notifications; this code is here to show how
     //		it's done if you need it.
     [[NSNotificationCenter defaultCenter] removeObserver: self
     name: MPMediaLibraryDidChangeNotification
     object: musicPlayer];
     
     [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
     
     */
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: musicPlayer];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
	[musicPlayer endGeneratingPlaybackNotifications];

    
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
	}
    
    if ([segue.identifier isEqualToString:@"MagnifyPlaylistRemaining"])
	{
        TimeMagnifierViewController *timeMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        timeMagnifierViewController.delegate = self;
        timeMagnifierViewController.textToMagnify = self.navigationItem.rightBarButtonItem.title;
        timeMagnifierViewController.timeType = segue.identifier;

	}
    
    if ([segue.identifier isEqualToString:@"MagnifyNextSong"])
	{
        TextMagnifierViewController *textMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        textMagnifierViewController.delegate = self;
        textMagnifierViewController.textToMagnify = self.nextSongLabel.text;
	}
    

}
- (IBAction)magnify {

    [self performSegueWithIdentifier: @"MagnifyPlaylistRemaining" sender: self];
}

//#pragma mark - TextMagnifierViewControllerDelegate

- (void)textMagnifierViewControllerDidCancel:(TextMagnifierViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}
//#pragma mark - TextMagnifierViewControllerDelegate

- (void)timeMagnifierViewControllerDidCancel:(TimeMagnifierViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];

}
- (void)viewWillAppear:(BOOL)animated {
//    LogMethod();
    [super viewWillAppear: animated];
    
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateTime)
                                                        userInfo:nil
                                                         repeats:YES];
    
    self.navigationItem.titleView = [self customizeTitleView];
}
- (UILabel *) customizeTitleView
{
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:44];
    label.font = newFont;
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}
- (void)goBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
//    LogMethod();
    [super viewWillDisappear: animated];
    [self.playbackTimer invalidate];

}
- (void)viewDidUnload {
    [self setNextLabel:nil];
    [self setRepeatShuffleButtons:nil];
    [self setVolumeView:nil];
    [self setPlayerButtonContraint:nil];
    [self setPlayPauseButton:nil];
    [super viewDidUnload];
}
//
//#pragma mark - Fetched results controller
//
//- (NSFetchedResultsController *)fetchedResultsController
//{
//    
//    if (fetchedResultsController_ != nil)
//    {
//        return fetchedResultsController_;
//    }
//    
//    /*
//     Set up the fetched results controller.
//     */
//    // Create the fetch request for the entity.
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    // Edit the entity name as appropriate.
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemCollection" inManagedObjectContext:self.managedObjectContext];
//    
//    [fetchRequest setEntity:entity];
//    
//    // Set the batch size to a suitable number.
//    [fetchRequest setFetchBatchSize:20];
//    
//    // Edit the sort key as appropriate.
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//    
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    
//    // Edit the section name key path and cache name if appropriate.
//    // nil for section name key path means "no sections".
//    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
//    aFetchedResultsController.delegate = self;
//    self.fetchedResultsController = aFetchedResultsController;
//    
//	NSError *error = nil;
//	if (![self.fetchedResultsController performFetch:&error])
//    {
//        UIAlertView* alertView =
//        [[UIAlertView alloc] initWithTitle:@"Data Management Error"
//                                   message:@"Press the Home button to quit this application."
//                                  delegate:self
//                         cancelButtonTitle:@"OK"
//                         otherButtonTitles: nil];
//        [alertView show];
//
//	}
//    
//    return fetchedResultsController_;
//}
@end
