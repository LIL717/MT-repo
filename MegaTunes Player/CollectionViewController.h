//
//  CollectionViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//
@class CollectionItem;
//#import "MediaGroupViewController.h"
//#import "ViewController.h"

//@interface CollectionViewController : UITableViewController <MPMediaPickerControllerDelegate, MediaGroupViewControllerDelegate, ViewControllerDelegate,UITableViewDelegate> {
@interface CollectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate> {

    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic)   IBOutlet UITableView *collectionTableView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   NSArray *collection;

- (NSNumber *) calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue;

@end
