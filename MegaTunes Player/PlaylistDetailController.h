//
//  PlaylistDetailController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
#import "DurationPickerController.h"
@class PlaylistDetailController;
@class Playlist;

@protocol PlaylistDetailControllerDelegate <NSObject>

- (void)playlistDetailControllerDidCancel: (PlaylistDetailController *)controller;
- (void)playlistDetailController: (PlaylistDetailController *)controller
                       didAddPlaylist:(Playlist *)playlist;
@end
@interface PlaylistDetailController : UITableViewController <DurationPickerControllerDelegate>

@property (nonatomic, weak) id <PlaylistDetailControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end