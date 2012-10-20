//
//  MediaGroupsViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//
@class CollectionItem;

@interface MediaGroupsViewController : UITableViewController <MPMediaPickerControllerDelegate, UITableViewDelegate>

@property (nonatomic, strong)   NSArray *collection;
@property (nonatomic, strong)   CollectionItem *playlist;

- (NSNumber *) calculatePlaylistDuration: (MPMediaPlaylist *) playlist;

@end
