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
#import "AppDelegate.h"

@interface MainViewController : UIViewController <MPMediaPickerControllerDelegate, MusicTableViewControllerDelegate, AVAudioPlayerDelegate> {
    
	AddMusicAppDelegate			*applicationDelegate;
	IBOutlet UIBarButtonItem	*artworkItem;
	IBOutlet UINavigationBar	*navigationBar;
	IBOutlet UILabel			*nowPlayingLabel;
	BOOL						playedMusicOnce;
    
	AVAudioPlayer				*appSoundPlayer;
	NSURL						*soundFileURL;
	IBOutlet UIButton			*appSoundButton;
	IBOutlet UIButton			*addOrShowMusicButton;
	BOOL						interruptedOnPlayback;
	BOOL						playing ;
    
	UIBarButtonItem				*playBarButton;
	UIBarButtonItem				*pauseBarButton;
	MPMusicPlayerController		*musicPlayer;
	MPMediaItemCollection		*userMediaItemCollection;
	UIImage						*noArtworkImage;
	NSTimer						*backgroundColorTimer;
}

@property (nonatomic, retain)	UIBarButtonItem			*artworkItem;
@property (nonatomic, retain)	UINavigationBar			*navigationBar;
@property (nonatomic, retain)	UILabel					*nowPlayingLabel;
@property (readwrite)			BOOL					playedMusicOnce;

@property (nonatomic, retain)	UIBarButtonItem			*playBarButton;
@property (nonatomic, retain)	UIBarButtonItem			*pauseBarButton;
@property (nonatomic, retain)	MPMediaItemCollection	*userMediaItemCollection;
@property (nonatomic, retain)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, retain)	UIImage					*noArtworkImage;
@property (nonatomic, retain)	NSTimer					*backgroundColorTimer;

@property (nonatomic, retain)	AVAudioPlayer			*appSoundPlayer;
@property (nonatomic, retain)	NSURL					*soundFileURL;
@property (nonatomic, retain)	IBOutlet UIButton		*appSoundButton;
@property (nonatomic, retain)	IBOutlet UIButton		*addOrShowMusicButton;
@property (readwrite)			BOOL					interruptedOnPlayback;
@property (readwrite)			BOOL					playing;

- (IBAction)	playOrPauseMusic:		(id) sender;
- (IBAction)	AddMusicOrShowMusic:	(id) sender;
- (IBAction)	playAppSound:			(id) sender;

- (BOOL) useiPodPlayer;

@end