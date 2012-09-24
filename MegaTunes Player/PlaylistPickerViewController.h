//
//  PlaylistPickerViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/20/12.
//
//

#import <UIKit/UIKit.h>
#import "PlaylistDetailController.h"

@interface PlaylistPickerViewController : UITableViewController <PlaylistDetailControllerDelegate>

@property (nonatomic, strong) NSMutableArray *playlists;

@end
