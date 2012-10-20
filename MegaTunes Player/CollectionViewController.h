//
//  CollectionViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class CollectionItem;

@interface CollectionViewController : UITableViewController <MPMediaPickerControllerDelegate, UITableViewDelegate>

@property (nonatomic, strong)   MPMediaItemCollection *itemCollection;
@property (nonatomic, strong)   CollectionItem *playlist;


@end