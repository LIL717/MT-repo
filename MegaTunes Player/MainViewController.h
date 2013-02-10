//
//  MainViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class CollectionItem;
@class ItemCollection;
#import "TimeMagnifierViewController.h"
#import "TextMagnifierViewController.h"
#import "NotesTabBarController.h"

//#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AutoScrollLabel.h"

@interface MainViewController : UIViewController <MPMediaPickerControllerDelegate, AVAudioPlayerDelegate, TimeMagnifierViewControllerDelegate, TextMagnifierViewControllerDelegate, NotesTabBarControllerDelegate, NSFetchedResultsControllerDelegate> {
    
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
    NSFetchedResultsController  *fetchedResultsController;
    NSManagedObjectContext      *managedObjectContext;
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
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext    *managedObjectContext;
@property (nonatomic, strong)   MPMediaItem             *mediaItemForInfo;
@property (readwrite)           BOOL                    iPodLibraryChanged;
@property (readwrite)           BOOL                    showPlaylistRemaining;
@property (nonatomic, strong)   MPMediaItem             *savedNowPlaying;

@property (strong, nonatomic) IBOutlet UILabel *initialNowPlayingLabel;
@property (strong, nonatomic) IBOutlet AutoScrollLabel	*nowPlayingLabel;
@property (strong, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (strong, nonatomic) IBOutlet MPVolumeView *volumeView;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *repeatButton;
@property (strong, nonatomic) IBOutlet UIButton *shuffleButton;

@property (strong, nonatomic) IBOutlet UILabel *nextLabel;
@property (strong, nonatomic) IBOutlet UIButton *nowPlayingInfoButton;

@property (strong, nonatomic) IBOutlet UIScrollView *nextSongScrollView;
@property (strong, nonatomic) IBOutlet UILabel *nextSongLabel;

@property (strong, nonatomic) CollectionItem *collectionItem;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerButtonContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *repeatButtonHeightContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *volumeViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nextSongLabelWidthConstraint;

- (IBAction)moveSlider:(id)sender;
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
- (void) notesTabBarControllerDidCancel:(NotesTabBarController *)controller;

@end

