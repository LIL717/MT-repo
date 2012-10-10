//
//  PlaylistPickerViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/20/12.
//
//
#import <MediaPlayer/MediaPlayer.h>

//@class PlaylistPickerViewController;

@protocol PlaylistPickerViewControllerDelegate; // forward declaration

@interface PPlaylistPickerViewController : UITableViewController <MPMediaPickerControllerDelegate, UITableViewDelegate> {
    
    id <PlaylistPickerViewControllerDelegate>	__weak delegate;
}

@property (nonatomic, weak) id <PlaylistPickerViewControllerDelegate>	delegate;
@property (nonatomic, strong)   NSArray *playlists;
@property (nonatomic, strong)   NSArray *songs;


@end

@protocol PlaylistPickerViewControllerDelegate

// implemented in MainViewController.m
- (void) playlistPickerViewControllerDidFinish: (PPlaylistPickerViewController *) controller;
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;

@end