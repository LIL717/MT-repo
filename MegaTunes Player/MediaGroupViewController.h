//
//  IntialTableViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import <UIKit/UIKit.h>
#import "MediaGroup.h"

@protocol MediaGroupViewControllerDelegate <NSObject>

- (NSNumber *)calculatePlaylistDuration: (MPMediaPlaylist *) mediaPlaylist;

@end

@interface MediaGroupViewController : UITableViewController <MPMediaPickerControllerDelegate>

@property (nonatomic, weak) id <MediaGroupViewControllerDelegate> delegate;


@property (nonatomic, strong)           NSArray  *collection;
@property (nonatomic, strong)           NSArray *groupingData;
@property (nonatomic, strong)           MediaGroup *selectedGroup;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;


@end


