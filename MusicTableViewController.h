//
//  MusicTableViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

#import <MediaPlayer/MediaPlayer.h>

@protocol MusicTableViewControllerDelegate; // forward declaration


@interface MusicTableViewController : UITableViewController <MPMediaPickerControllerDelegate, UITableViewDelegate> {

	id <MusicTableViewControllerDelegate>	__weak delegate;

}

@property (nonatomic, weak) id <MusicTableViewControllerDelegate>	delegate;
@property (nonatomic, strong)   NSArray *playlists;

@end

@protocol MusicTableViewControllerDelegate

// implemented in MainViewController.m
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;

@end