//
//  CollectionViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//
@class CollectionItem;
#import "MediaGroupViewController.h"

@interface CollectionViewController : UITableViewController <MPMediaPickerControllerDelegate, MediaGroupViewControllerDelegate, UITableViewDelegate>

@property (nonatomic, strong)   NSArray *collection;

- (NSNumber *) calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue;

@end
