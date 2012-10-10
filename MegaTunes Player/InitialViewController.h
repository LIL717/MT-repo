//
//  InitialViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

//#import <UIKit/UIKit.h>
//#import <MediaPlayer/MediaPlayer.h>
//#import "MusicTableViewController.h"
#import "MainViewController.h"


@interface InitialViewController : UIViewController

@property (nonatomic, strong)           NSArray  *playlists;
@property (strong, nonatomic) IBOutlet  UIButton *choosePlaylist;
@property (strong, nonatomic) MainViewController *mainViewController;


- (IBAction)	choosePlaylist:	(id) sender;

@end
