//
//  PlaylistDetailController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

//#import <MediaPlayer/MediaPlayer.h>
//#import "MainViewController.h"
//
//@class PlaylistDetailController;
//
//@interface PlaylistDetailController : UITableViewController 
//
//@property (strong, nonatomic)        MPMediaItemCollection *currentQueue;
//
//@end
#import <MediaPlayer/MediaPlayer.h>
@class MainViewController;


@protocol PlaylistDetailControllerDelegate; // forward declaration

@interface PlaylistDetailController : UITableViewController <MPMediaPickerControllerDelegate, UITableViewDelegate> {
    
	id <PlaylistDetailControllerDelegate>	__weak delegate;
    
}

@property (nonatomic, weak) id <PlaylistDetailControllerDelegate>	delegate;
@property (nonatomic, strong)   MPMediaItemCollection *currentQueue;
@property (nonatomic, strong)  MainViewController *mainViewController;

@end



@protocol PlaylistDetailControllerDelegate

// implemented in MainViewController.m
//- (void) musicTableViewControllerDidFinish: (MMusicTableViewController *) controller;
//- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;

@end