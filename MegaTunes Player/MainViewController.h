//
//  MainViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MusicTableViewController.h"
#import "PlaylistDetailController.h"
#import "AppDelegate.h"

@interface MainViewController : UIViewController <MPMediaPickerControllerDelegate, MusicTableViewControllerDelegate, PlaylistDetailControllerDelegate, AVAudioPlayerDelegate> {
    
	AppDelegate                 *applicationDelegate;
	IBOutlet UIBarButtonItem	*artworkItem;
	IBOutlet UINavigationBar	*navigationBar;
	IBOutlet UILabel			*nowPlayingLabel;
	BOOL						playedMusicOnce;
    
	AVAudioPlayer				*appSoundPlayer;
//	NSURL						*soundFileURL;
//	IBOutlet UIButton			*appSoundButton;
//	IBOutlet UIButton			*addOrShowMusicButton;
	BOOL						interruptedOnPlayback;
	BOOL						playing ;
    
//	UIBarButtonItem				*playBarButton;
//	UIBarButtonItem				*pauseBarButton;
	MPMusicPlayerController		*musicPlayer;
	MPMediaItemCollection		*userMediaItemCollection;
//	UIImage						*noArtworkImage;
//	NSTimer						*backgroundColorTimer;
//    NSArray                     *playlists;
}

//@property (nonatomic, strong)	UIBarButtonItem			*artworkItem;
@property (nonatomic, strong)	UINavigationBar			*navigationBar;
@property (nonatomic, strong)	UILabel					*nowPlayingLabel;
@property (readwrite)			BOOL					playedMusicOnce;

//@property (nonatomic, strong)	UIBarButtonItem			*playBarButton;
//@property (nonatomic, strong)	UIBarButtonItem			*pauseBarButton;
@property (nonatomic, strong)	MPMediaItemCollection	*userMediaItemCollection;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
//@property (nonatomic, strong)	UIImage					*noArtworkImage;
//@property (nonatomic, strong)	NSTimer					*backgroundColorTimer;

@property (nonatomic, strong)	AVAudioPlayer			*appSoundPlayer;
//@property (nonatomic, strong)	NSURL					*soundFileURL;
//@property (nonatomic, strong)	IBOutlet UIButton		*appSoundButton;
//@property (nonatomic, strong)	IBOutlet UIButton		*addOrShowMusicButton;
@property (readwrite)			BOOL					interruptedOnPlayback;
@property (readwrite)			BOOL					playing;
@property (nonatomic, strong)   NSArray                 *playlists;

//@property (strong, nonatomic) NSArray *songs;
@property (nonatomic, strong)   MPMediaItemCollection *currentQueue;

@property (strong, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *previousButton;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UILabel *nextSongLabel;

- (IBAction)	playOrPauseMusic:		(id) sender;
//- (IBAction)	AddMusicOrShowMusic:	(id) sender;
//- (IBAction)	playAppSound:			(id) sender;

- (BOOL) useiPodPlayer;

@end