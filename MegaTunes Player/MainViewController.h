//
//  MainViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class CollectionItem;
@class ItemCollection;
@class UserInfoViewController;
@class OBSlider;
@class AccessibleButton;

#import "TimeMagnifierViewController.h"
#import "TextMagnifierViewController.h"
#import "InfoTabBarController.h"

//#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AutoScrollLabel.h"


@interface MainViewController : UIViewController <MPMediaPickerControllerDelegate, AVAudioPlayerDelegate, TimeMagnifierViewControllerDelegate, TextMagnifierViewControllerDelegate, InfoTabBarControllerDelegate> {
    
	BOOL						playedMusicOnce;
    
	AVAudioPlayer				*appSoundPlayer;
    NSURL						*soundFileURL;
	BOOL						interruptedOnPlayback;
	BOOL						playing ;
	MPMusicPlayerController		*musicPlayer;
	MPMediaItemCollection		*userMediaItemCollection;
    NSTimer                     *playbackTimer;
    MPNowPlayingInfoCenter      *nowPlayingInfoCenter;
    BOOL                        playNew;
    MPMediaItem                 *itemToPlay;
    NSManagedObjectContext      *managedObjectContext_;
    BOOL                        iPodLibraryChanged;
}
@property (nonatomic, strong)	UINavigationBar			*navigationBar;
@property (readwrite)			BOOL					playedMusicOnce;
@property (nonatomic, strong)	MPMediaItemCollection	*userMediaItemCollection;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)	AVAudioPlayer			*appSoundPlayer;
@property (nonatomic, strong)	NSURL					*soundFileURL;
@property (readwrite)			BOOL					interruptedOnPlayback;
@property (readwrite)			BOOL					playing;
@property (nonatomic, strong)   MPMediaItemCollection   *currentQueue;
@property (nonatomic, retain)   NSTimer                 *playbackTimer;
@property (nonatomic, strong)   MPNowPlayingInfoCenter  *nowPlayingInfoCenter;
@property (readwrite)           BOOL                    playNew;
@property (nonatomic, strong)   MPMediaItem             *itemToPlay;
@property (nonatomic, retain)   NSManagedObjectContext  *managedObjectContext;
@property (nonatomic, strong)   MPMediaItem             *mediaItemForInfo;
@property (readwrite)           BOOL                    iPodLibraryChanged;
@property (readwrite)           BOOL                    showPlaylistRemaining;
@property (readwrite)           BOOL                    queueIsKnown;
@property (readwrite)           BOOL                    initialView;
@property (readwrite)           BOOL                    skippedBack;
@property (nonatomic, strong)   MPMediaItem             *savedNowPlaying;
@property (nonatomic, strong)   MPMediaItem             *predictedNextItem;
@property (nonatomic, strong)   UserInfoViewController  *userInfoViewController;
@property (readwrite)           BOOL                    userIsScrubbing;
@property (readwrite)           BOOL                    hasFinishedMoving;
@property (nonatomic)           BOOL                    scrubbing; // Whether the player is currently scrubbing
@property (nonatomic)           MPMusicPlaybackState    savedPlaybackState;
@property (readwrite)           BOOL                    songShuffleButtonPressed;
@property (nonatomic)           BOOL                    collectionContainsICloudItem;
@property (nonatomic, strong)   UIBarButtonItem         *stopWatchBarButton;



@property (strong, nonatomic) IBOutlet UILabel *initialNowPlayingLabel;
@property (strong, nonatomic) IBOutlet AutoScrollLabel	*nowPlayingLabel;
@property (strong, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (strong, nonatomic) IBOutlet OBSlider *progressSlider;
@property (strong, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (strong, nonatomic) IBOutlet MPVolumeView *volumeView;
@property (strong, nonatomic) IBOutlet AccessibleButton *rewindButton;
@property (strong, nonatomic) IBOutlet AccessibleButton *playPauseButton;
@property (strong, nonatomic) IBOutlet AccessibleButton *forwardButton;
@property (strong, nonatomic) IBOutlet UIButton *repeatButton;
@property (strong, nonatomic) IBOutlet AccessibleButton *shuffleButton;

@property (strong, nonatomic) IBOutlet UILabel *nextLabel;
@property (strong, nonatomic) IBOutlet UIButton *nowPlayingInfoButton;

@property (strong, nonatomic) IBOutlet UIScrollView *nextSongScrollView;
@property (strong, nonatomic) IBOutlet UILabel *nextSongLabel;

@property (strong, nonatomic) CollectionItem *collectionItem;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeftRight;
@property (strong, nonatomic) NSString *stopWatchTime;
//140218 1.2 iOS 7 begin
@property (strong, nonatomic) NSString *collectionRemainingLabel;
//140218 1.2 iOS 7 end

//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nextSongLabelWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leadingSpaceToSliderConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *trailingSpaceFromSliderConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceBetweenSliderAndElapsedTime;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceBetweenSliderAndRemainingTime;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceBetweenRewindAndReplay;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topSpaceToPlayButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playButtonToBottomSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerXInScrollView;

- (IBAction)handleScrub:(id)sender;
- (IBAction)handleScrubberTouchDown:(id)sender;
- (IBAction)handleScrubberTouchUp:(id)sender;
- (IBAction)skipBack:(id)sender;
- (IBAction)playPause:(id)sender;
- (IBAction)skipForward:(id)sender;

- (IBAction)nowPlayingTapDetected:(UITapGestureRecognizer *)sender;
- (IBAction)nextSongTapDetected:(UITapGestureRecognizer *)sender;
- (IBAction)magnifyRemainingTime:(id)sender;
- (IBAction)magnifyElapsedTime:(id)sender;
- (IBAction)repeatModeChanged:(id)sender;
- (IBAction)shuffleModeChanged:(id)sender;

- (void) playMusic;
- (void) prepareAllExceptNowPlaying;
- (void) prepareNowPlayingLabel;
- (void) registerForMediaPlayerNotifications;
- (void) updateTime;
- (void) timeMagnifierViewControllerDidCancel:(TimeMagnifierViewController *)controller;
- (void) textMagnifierViewControllerDidCancel:(TextMagnifierViewController *)controller;
- (void) infoTabBarControllerDidCancel:(InfoTabBarController *)controller;

/// The Current Playback position in seconds
@property (nonatomic) CGFloat currentPlaybackPosition;

@end
