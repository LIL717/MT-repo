//
//  PlayerViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/30/12.
//
//

#import <MediaPlayer/MediaPlayer.h>

@interface PPlayerViewController : UIViewController

@property (strong, nonatomic) NSArray *songs;
@property (strong, nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (strong, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *previousButton;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UILabel *nextSongLabel;

@end
