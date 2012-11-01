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


#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AutoScrollLabel.h"


@interface MainViewController : UIViewController <MPMediaPickerControllerDelegate, AVAudioPlayerDelegate, TimeMagnifierViewControllerDelegate, TextMagnifierViewControllerDelegate, NSFetchedResultsControllerDelegate> {
    
	IBOutlet UINavigationBar	*navigationBar;
	IBOutlet AutoScrollLabel 	*nowPlayingLabel;
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
//    ItemCollection              *itemCollection;
}
@property (nonatomic, strong)	UINavigationBar			*navigationBar;
@property (nonatomic, strong)	AutoScrollLabel			*nowPlayingLabel;
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

@property (strong, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *previousButton;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UILabel *nextLabel;
@property (strong, nonatomic) IBOutlet AutoScrollLabel *nextSongLabel;
@property (strong, nonatomic) CollectionItem *collectionItem;

- (IBAction)playOrPauseMusic:(id)sender;
- (IBAction)skipBack:(id)sender;
- (IBAction)skipForward:(id)sender;
- (IBAction)moveSlider:(id)sender;

- (void) playMusic;
- (void) updateTime;
- (NSNumber *)calculatePlaylistElapsed;
- (void)actualizeSlider;
- (void) playMusic;
- (void)timeMagnifierViewControllerDidCancel:(TimeMagnifierViewController *)controller;
- (void)textMagnifierViewControllerDidCancel:(TextMagnifierViewController *)controller;

@end
